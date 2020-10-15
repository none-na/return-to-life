-- CycloneLib - contents/net.lua

-- Dependencies:
---- CycloneLib.table

-- Commented ones can already be sent
local NSH_TYPES = {
	"Achievement",
	"Artifact",
	"Buff",
	"Difficulty",
	"EliteType",
	--"Object",
	"Interactable",
	--"Item",
	"ItemPool",
	"MonsterCard",
	"MonsterLog",
	"ParentObject",
	"ParticleType",
	"Room",
	--"Sound",
	--"Sprite",
	"Stage",
	"Survivor",
}
NSH_TYPES = CycloneLib.table.swap(NSH_TYPES)

local _net = {}

--[[
All methods of assigning net ids come with compromises
Below are some methods with the conditions they are optimal in
	ex_sync : The object is exclusively sent over the network by the mod
	ex_assign : The object is exclusively assigned net ids by the mod
--]]

-- Use when (not ex_sync and ex_assign)
-- Use especially when (ex_sync and ex_assign)
-- Better than assignNegativeNetID when (not ex_sync)
_net.assignDirectNetID = function(instance)
	instance:set("m_id", instance.id)
end

-- Use when (ex_sync and not ex_assign)
-- Better than assignDirectNetID when (not ex_assign)
_net.assignNegativeNetID = function(instance)
	instance:set("m_id", -instance.id)
end

-- Use if (not ex_sync and not ex_assign)
-- Better than assignLeastNetID when (not ex_sync)
_net.assignGreatestNetID = function(instance)
	local id
	local object = instance:getObject()
	for _,i_other in ipairs(object:findMatchingOp("m_id", "~=", nil, "m_id", "~=", -1)) do
		local m_id = i_other:get("m_id")
		id = ((id == nil) or (m_id > id)) and m_id or id
	end
	id = id + 1
	instance:set("m_id", id)
end

-- Use if (not ex_sync and not ex_assign)
-- Better than assignGreatestNetID when (not ex_assign)
_net.assignLeastNetID = function(instance)
	local id
	local object = instance:getObject()
	for _,i_other in ipairs(object:findMatchingOp("m_id", "~=", nil, "m_id", "~=", -1)) do
		local m_id = i_other:get("m_id")
		id = ((id == nil) or (m_id < id)) and m_id or id
	end
	id = id - 1
	if id == -1 then id = id - 1 end
	instance:set("m_id", id)
end

-- Use if (ex_sync and not ex_assign)
-- Better than assignReverseNetID when (ex_sync)
_net.assignDecimalNetID = function(instance)
	instance:set("m_id", instance.id + math.random())
end

-- Use if (not ex_sync and not ex_assign)
local RANGE = (((2^8)^4)/2) - 2
_net.assignReverseNetID = function(instance)
	instance:set("m_id", RANGE - instance.id)
end

-- Checks if the net id of the instance is valid
_net.validNetID = function(instance)
	return instance:get("m_id") ~= nil and instance:get("m_id") ~= -1
end

-- Assigns a net id to an instance
_net.assignNetID = function(instance)
	_net.assignReverseNetID(instance)
end

-- Assigns a net id to an instance if it doesn't have a valid one
_net.sanitizeNetID = function(instance)
	if _net.validNetID(instance) then return nil end
	_net.assignNetID(instance)
end

do
	local callbacks = {}
	local callback_to_id = {}
	local callback_instance_stack = {}

	-- Just in case
	callback.register("onGameStart", function()
		for callback_id,stack in pairs(callback_instance_stack) do
			local count = #stack
			if count > 0 then
				callback_instance_stack[callback] = {}
				error(string.format(
					"CycloneLib.net.auto_create encountered a leak in mod '%s' with callback id '%s' (%s)",
					modloader.getActiveNamespace(),
					callback_id,
					callbacks[callback_id]
				))
			end
		end
	end)

	-- Default callback
	callbacks[0] = function(object, x, y)
		return object:create(x, y)
	end
	callback_instance_stack[0] = {}

	local function getCallback(callback_id)
		return callbacks[callback_id] or callbacks[0]
	end

	local function push_instance(callback_id, netID)
		table.insert(callback_instance_stack[callback_id], netID)
	end

	local function pop_instance(callback_id)
		return table.remove(callback_instance_stack[callback_id], 1)
	end

	-- Registers a callback that will be called to construct the object requested
	_net.onCreate = function(callback)
		table.insert(callbacks, callback)
		local callback_id = #callbacks
		callback_to_id[callback] = callback_id
		callback_instance_stack[callback_id] = {}
	end

	local create_sync = net.Packet.new("CycloneLibNetCreate", function(sender, object, x, y, netID, callback_id)
		--object:create(x, y):set("m_id", netID)
		local callback = getCallback(callback_id)
		local instance = callback(object, x, y, netID)
		if not (instance and instance:isValid()) then
			error("Net create callback didn't return a valid instance")
		end
		instance:set("m_id", netID)
	end)

	local auto_create_sync = net.Packet.new("CycloneLibNetAutoCreate", function(sender, object, x, y, netID, callback_id)
		local callback = getCallback(callback_id)
		local instance = callback(object, x, y, netID)
		if not (instance and instance:isValid()) then
			error("Net create callback didn't return a valid instance")
		end
		instance:set("m_id", netID)
		push_instance(callback_id, netID)
	end)

	-- Creates an object that is synced and returns the instance created
	-- In most cases the returned instance shouldn't be used
	-- Instead register a callback with onCreate()
	-- Callback is the callback returned from onCreate() (leave empty if no custom creation is needed)
	-- The exclusive parameter when true means (ex_assign) (explained above)
	-- Leave it empty if unsure
	_net.create = function(object, x, y, callback, exclusive)
		local callback = callback or 0
		if net.host then
			local instance = object:create(x, y)
			if exclusive then
				-- No need to check valid either
				_net.assignDirectNetID(instance)
			else
				_net.sanitizeNetID(instance)
			end
			create_sync:sendAsHost(
				net.ALL,
				nil,
				object,
				x,
				y,
				instance:get("m_id"),
				callback
			)
			return instance
		end
	end

	-- Same functionality with net.create but with a twist
	-- Now the returned instance can be used
	-- But every player (all the clients and the host) has to call the function in the right order
	-- That is for every call to auto_create in the host, every client should call it as well in the same order
	-- Useful inside AutoPacket
	_net.auto_create = function(object, x, y, callback, exclusive)
		local callback = callback or 0
		if net.host then
			local instance = object:create(x, y)
			if exclusive then
				-- No need to check valid either
				_net.assignDirectNetID(instance)
			else
				_net.sanitizeNetID(instance)
			end
			auto_create_sync:sendAsHost(
				net.ALL,
				nil,
				object,
				x,
				y,
				instance:get("m_id"),
				callback
			)
			return instance
		else
			local id = pop_instance(callback)
			return object:findMatching("m_id", id)[1]
		end
	end
end

-- Returns a function, that when executed will execute the given function with the given arguments on all players
_net.AllPacket = function(name, f)
	local host = net.Packet.new(name .. "_host", function(sender, ...)
		f(...)
	end)
	local client = net.Packet.new(name .. "_client", function(sender, ...)
		f(...)
		host:sendAsHost(net.EXCLUDE, sender, ...)
	end)
	return function(...)
		f(...)
		host:sendAsHost(net.ALL, nil, ...)
		client:sendAsClient(...)
	end
end

local packet_index = 0
local function toNetArgs(...)
	local net_args = {""}
	local n = 1
	
	local args = {...}
	local length = select("#", ...)
	
	local decode_string = ""
	
	for i=1,length do
		local _type = type(args[i])
		if NSH_TYPES[_type] then
			table.insert(net_args, _type)
			table.insert(net_args, args[i]:getName())
			table.insert(net_args, args[i]:getOrigin())
			decode_string = decode_string .. "m"
			n = n + 3
		elseif isa(args[i], "Instance") then
			local status, net_instance = pcall(args[i].getNetIdentity, args[i])
			if not status then print("AutoPacket: " .. net_instance) end
			table.insert(net_args, status and net_instance or 0)
			decode_string = decode_string .. "i"
			n = n + 1
		elseif args[i] == nil then
			table.insert(net_args, 0)
			decode_string = decode_string .. "n"
			n = n + 1
		else
			table.insert(net_args, args[i])
			decode_string = decode_string .. "r"
			n = n + 1
		end
	end
	
	net_args[1] = decode_string
	
	return net_args, n
end
local function toArgs(...)
	local args = {}
	local n = 0
	
	local net_args = {...}
	local length = select("#", ...)
	
	local decode_string = net_args[1]
	
	local d = 0
	local i = 2
	while i <= length do
		d = d + 1
		local hint = decode_string:sub(d, d)
		if hint == "m" then
			args[d] = _G[net_args[i]].find(net_args[i + 1], net_args[i + 2])
			i = i + 3
		elseif hint == "i" then
			if isa(net_args[i], "NetInstance") then
				args[d] = net_args[i]:resolve()
			--else
				--args[d] = nil
			end
			i = i + 1
		elseif hint == "n" then
			--args[d] = nil
			i = i + 1
		else
			assert(hint == "r")
			args[d] = net_args[i]
			i = i + 1
		end
	end
	
	n = d
	
	assert(#decode_string == n)
	
	return args, n
end

-- Automatically handles some of the packet code
-- Similiar to AllPacket but also handles other types passes to it like nil, instances or the NSH_TYPES above
-- Note that some instances can't be sent
-- This means that such instances will be nil on recipients
-- Doesn't handle tables yet
-- CycloneLib.net.create can be used inside an AutoPacket in most cases (the returned instance should be valid)
-- Better yet CycloneLib.net.auto_create can be used and the returned instance used
_net.AutoPacket = function(f)
	packet_index = packet_index + 1
	local host_packet = net.Packet.new(string.format("CycloneLibAutoPacket_%s_host", packet_index), function(sender, ...)
		local args, n = toArgs(...)
		f(unpack(args, 1, n))
	end)
	local client_packet = net.Packet.new(string.format("CycloneLibAutoPacket_%s_client", packet_index), function(sender, ...)
		local args, n = toArgs(...)
		f(unpack(args, 1, n))
		--host_packet:sendAsHost(net.EXCLUDE, sender, ...)
		host_packet:sendAsHost(net.ALL, nil, ...)
	end)
	return function(...)
		local net_args, n = toNetArgs(...)
		--f(...)
		if net.host then f(...) end
		host_packet:sendAsHost(net.ALL, nil, unpack(net_args, 1, n))
		client_packet:sendAsClient(unpack(net_args, 1, n))
	end
end

--#########--
-- Exports --
--#########--

export("CycloneLib.net", _net)
return _net

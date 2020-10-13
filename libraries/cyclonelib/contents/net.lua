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
-- This means that such instances will be nill on recipients
-- Doesn't handle tables yet
_net.AutoPacket = function(f)
	packet_index = packet_index + 1
	local host_packet = net.Packet.new(string.format("%s_host", packet_index), function(sender, ...)
		local args, n = toArgs(...)
		f(unpack(args, 1, n))
	end)
	local client_packet = net.Packet.new(string.format("%s_client", packet_index), function(sender, ...)
		local args, n = toArgs(...)
		f(unpack(args, 1, n))
		host_packet:sendAsHost(net.EXCLUDE, sender, ...)
	end)
	return function(...)
		local net_args, n = toNetArgs(...)
		f(...)
		host_packet:sendAsHost(net.ALL, nil, unpack(net_args, 1, n))
		client_packet:sendAsClient(unpack(net_args, 1, n))
	end
end

--#########--
-- Exports --
--#########--

export("CycloneLib.net", _net)
return _net
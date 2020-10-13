-- Restre

--[[
Load Restre as such:
require("restre")()

If you want to be more complete (don't call cd if you're at the mod root):
local restre_key
if (not restre) or (not restre.valid()) then
    restre_key = require("restre")()
    restre.cd("submodfolder/", "main.lua")
end
--]]

-- Guard
if restre then return restre end

-- Global
restre = {}
restre.VALID = setmetatable({}, { __mode = 'v' })
restre.PATH = ""
restre.FILE = ""
restre.STORE_INDEX = false
restre.STORED_INDEX = nil

restre.valid = function()
	collectgarbage()
	return next(restre.VALID) ~= nil
end

-- Establishes a contract that as long as you hold the key restre isn't lost
local function restre_key()
	local key = {}
	table.insert(restre.VALID, key)
	return key
end
restre.key = restre_key

restre.cd = function(path, file)
	if path then restre.PATH = path end
	if file then restre.FILE = file end
end

restre.baseName = function(path)
	local index = path:reverse():find("/")
	local base = path:sub(1, -(index or 0))
	local file = path:sub(-((index or 0) - 1), -1)
	return base, file
end

local _require = require
restre.require = function(path)
	local base, file = restre.baseName(path)
	local old_path, old_file = restre.PATH, restre.FILE
	restre.PATH, restre.FILE = restre.PATH .. base, file
	local _return = _require(restre.PATH .. file)
	restre.PATH, restre.FILE = old_path, old_file
	return _return
end

-- I know
restre.pwd = function(path)
	local path = path or ""
	return restre.PATH .. path
end

restre.file = function()
	return restre.FILE
end

restre.full = function()
	return restre.PATH .. restre.FILE .. ".lua"
end

local _spriteLoad = Sprite.load
restre.spriteLoad = function(name, fname, frames, xorigin, yorigin)
	if not yorigin then
		return _spriteLoad(restre.PATH .. name, restre.PATH .. name, fname, frames, xorigin)
	end
	return _spriteLoad(name, restre.PATH .. fname, frames, xorigin, yorigin)
end

local _soundLoad = Sound.load
restre.soundLoad = function(name, fname)
	if not fname then
		return _soundLoad(restre.PATH .. name, restre.PATH .. name)
	end
	return _soundLoad(name, restre.PATH .. fname)
end

local _fontFromFile = graphics.fontFromFile
restre.fontFromFile = function(fname, size, bold, italic)
	return _fontFromFile(restre.PATH .. fname, size, bold, italic)
end

do
	local function restre_store(key)
		if restre.STORE_INDEX then
			restre.STORED_INDEX = key
			restre.STORE_INDEX = false
		end
	end

	local _m = getmetatable(_G)
	if _m == nil then
		_m = {
			__index = function(t, k)
				restre_store(k)
				return nil
			end
		}
		setmetatable(_G, _m)
	else
		local __index = _m.__index
		local itype = type(__index)
		_m.__index = function(t, k)
			local value
			if itype == "function" then value = __index(t, k) end
			if itype == "table" then value = __index[k] end
			if t ~= _G  or value ~= nil then return value end
			restre_store(k)
			return nil
		end
	end
end
local function depwarn(name, fatal)
	local message = string.format(
		"Couldn't find dependency '%s' for file '%s', it won't be loaded.",
		name,
		restre.full()
	)
	local func = fatal and error or print
	func(message)
	return false
end
local restre_depends = function(name, fatal)
	local name = name
	local _type = type(name)
	if _type ~= "nil" and _type ~= "string" then return true end
	if name == nil then
		name = restre.STORED_INDEX
		restre.STORE_INDEX = false
		restre.STORED_INDEX = nil
		return depwarn(name, fatal)
	end
	local parts = {}
	for part in string.gmatch(name, string.format("([^%s]+)", './\\')) do
		table.insert(parts, part)
	end
	local t = _G
	for i=1,#parts do
		t = t[parts[i]]
		if (t == nil) or (type(t) ~= "table" and i ~= #parts) then
			return depwarn(name, fatal)
		end
	end
	return true
end

local restre_override = function()
	-- Compatibility
	for name,value in pairs(restre) do
		if type(value) == "function" then
			local old_name = string.format("restre_%s", name)
			_G[old_name] = function(...)
				print(string.format(
					"Warning: '%s' using deprecated function '%s'. Please use '%s' instead.",
					restre.full(),
					old_name,
					string.format("restre.%s", name)
				))
				return value(...)
			end
		end
	end
end

setmetatable(restre, {
	__call = function() restre_override(); return restre_key() end,
	__index = function(t, k)
		if t ~= restre then return nil end
		if k == "depends" then
			restre.STORE_INDEX = true
			return restre_depends
		end
	end
})

return restre

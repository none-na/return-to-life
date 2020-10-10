-- Restre - restre.lua

-- Dependencies:
---- Nothing

--[[
Load Restre as such:
require("restre")()
--]]

RESTRE_DIR = RESTRE_DIR or ""

local function baseName(path)
	local index = path:reverse():find("/")
	local base = path:sub(1, -(index or 0))
	local file = path:sub(-((index or 0) - 1), -1)
	return base, file
end

local _require = require
local restre_require = function(path)
	local base, file = baseName(path)
	local OLD_RESTRE_DIR = RESTRE_DIR
	RESTRE_DIR = RESTRE_DIR .. base
	local _return = _require(RESTRE_DIR .. file)
	RESTRE_DIR = OLD_RESTRE_DIR
	return _return
end

local restre = function(path)
	local path = path or ""
	return RESTRE_DIR .. path
end

local _spriteLoad = Sprite.load
local restre_spriteLoad = function(name, fname, frames, xorigin, yorigin)
	if not yorigin then
		return _spriteLoad(RESTRE_DIR .. name, RESTRE_DIR .. name, fname, frames, xorigin)
	end
	return _spriteLoad(name, RESTRE_DIR .. fname, frames, xorigin, yorigin)
end

local _soundLoad = Sound.load
local restre_soundLoad = function(name, fname)
	if not fname then
		return _soundLoad(RESTRE_DIR .. name, RESTRE_DIR .. name)
	end
	return _soundLoad(name, RESTRE_DIR .. fname)
end

local _fontFromFile = graphics.fontFromFile
local restre_fontFromFile = function(fname, size, bold, italic)
	return _fontFromFile(RESTRE_DIR .. fname, size, bold, italic)
end

local restre_pwd = function()
	return RESTRE_DIR
end

local restre_override = function()
	_G.restre = restre
	_G.restre_require = restre_require
	_G.restre_spriteLoad = restre_spriteLoad
	_G.restre_soundLoad = restre_soundLoad
	_G.restre_fontFromFile = restre_fontFromFile
	_G.restre_pwd = restre_pwd
end


--#########--
-- Exports --
--#########--

return restre_override, restre_require, restre_spriteLoad, restre_soundLoad, restre_fontFromFile, restre_pwd

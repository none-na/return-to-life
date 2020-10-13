-- CycloneLib - contents/graphics.lua

-- Dependencies:
---- Nothing

local FONT_OFFSET = {
	[graphics.FONT_DEFAULT] = { x = 2, y = 2 },
	[graphics.FONT_DAMAGE] = { x = -1, y = 1 },
}

local _graphics = {}

_graphics.cleanColor = function(text)
	return text:gsub("&[^&]*&", "")
end

_graphics.print = function(text, x, y, font)
	local font = font or graphics.FONT_DEFAULT
	local offset = FONT_OFFSET[font] or { x = 0, y = 0 }
	local clean_text = _graphics.cleanColor(text)
	local w = graphics.textWidth(clean_text, font)
	local h = graphics.textHeight(clean_text, font)
	local x = x - w / 2 + offset.x
	local y = y - h / 2 + offset.y
	graphics.print(text, x, y, font)
end

_graphics.printColor = function(text, x, y, font)
	local font = font or graphics.FONT_DEFAULT
	local offset = FONT_OFFSET[font] or { x = 0, y = 0 }
	local clean_text = _graphics.cleanColor(text)
	local w = graphics.textWidth(clean_text, font)
	local h = graphics.textHeight(clean_text, font)
	local x = x - w / 2 + offset.x
	local y = y - h / 2 + offset.y
	graphics.printColor(text, x, y, font)

	-- Text Alignment Debug Lines
	--[[
	x = x - offset.x
	y = y - offset.y
	for i=0,2 do
		graphics.alpha(0.4) ; graphics.color(Color.PINK)
		graphics.line(x, 0, x, 20000)
		graphics.line(0, y, 20000, y)
		x = x + w/2
		y = y + h/2
	end
	--]]
end


--#########--
-- Exports --
--#########--

export("CycloneLib.graphics", _graphics)
return _graphics

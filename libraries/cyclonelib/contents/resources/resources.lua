-- CycloneLib - contents/resources.lua

-- Dependencies:
---- Nothing

local _resources = {}

-- Creates a flat color sprite with the given properties
-- Don't rely on the generated sprites for collision
_resources.generateFlatSprite = function(name, frames, xorigin, yorigin, width, height, color, alpha)
	local frames = frames or 1
	local xorigin = xorigin or 0
	local yorigin = yorigin or 0
	local width = width or 1
	local height = height or 1
	local color = color or Color.WHITE
	local alpha = alpha or 1

	local dynamic_sprite
	local surface = Surface.new(width, height)
	for frame=1,frames do
		surface:clear()

		graphics.color(color) ; graphics.alpha(alpha)
		graphics.rectangle(-1, -1, surface.width, surface.height)

		if not dynamic_sprite then
			dynamic_sprite = surface:createSprite(
				xorigin,
				yorigin,
				0,
				0,
				surface.width,
				surface.height
			)
		else
			dynamic_sprite:addFrame(surface, 0, 0, surface.width, surface.height)
		end
	end

	return dynamic_sprite:finalize(name)
end

_resources.transparent1x1 = restre.spriteLoad("transparent1x1", "transparent1x1.png", 1, 0, 0)
_resources.transparent2x2 = restre.spriteLoad("transparent2x2", "transparent2x2.png", 1, 0, 0)
_resources.transparent2x2origin = restre.spriteLoad("transparent2x2origin", "transparent2x2.png", 1, 1, 1)

_resources.white1x1 = restre.spriteLoad("white1x1", "white1x1.png", 1, 0, 0)
_resources.white2x2 = restre.spriteLoad("white2x2", "white2x2.png", 1, 0, 0)
_resources.white2x2origin = restre.spriteLoad("white2x2origin", "white2x2.png", 1, 1, 1)

_resources.pixel = _resources.white1x1
_resources.empty = _resources.transparent2x2origin

export("CycloneLib.resources", _resources)
return _resources

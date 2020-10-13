-- MapObject

-- host sets activator and alarm
-- fireworks
-- stop animation

if not restre.depends("CycloneLib.collision") then return nil end

local o_player = Object.find("P", "Vanilla")

local DEFAULT_COLOR = "w"
local DEFAULT_COST_COLOR = "y"
local DEFAULT_COST_SYMBOL = "$"
local SPRITE_SPEED = 0.2
local FONT_OFFSET = {
	[graphics.FONT_DEFAULT] = { x = 2, y = 2 },
	[graphics.FONT_DAMAGE] = { x = -1, y = 1 },
}
local FLOAT = 24
local SINK = 8

local function cleancolor(text)
	return text:gsub("&[^&]*&", "")
end

local function colorPrint(text, x, y, font, alpha)
	local offset = FONT_OFFSET[font] or { x = 0, y = 0 }
	local clean_text = cleancolor(text)
	local w = graphics.textWidth(clean_text, font)
	local h = graphics.textHeight(clean_text, font)
	local x = x - w / 2 + offset.x
	local y = y - h / 2 + offset.y
	graphics.alpha(alpha or 1)
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

local MapObject = {}

MapObject.new = function(name)
	local object = Object.base("MapObject", name)

	object:addCallback("create", function(instance)
		instance.spriteSpeed = 0
		instance:set("active", 0)
		instance.y = CycloneLib.collision.getGround(instance.x, instance.y)
	end)

	object:addCallback("step", function(instance)
		if instance:get("active") == 0 then
			local player = o_player:findNearest(instance.x, instance.y)
			if player:collidesWith(instance, player.x, player.y) then
				instance:set("myplayer", player.id) -- vanilla
				if player:control("enter") == input.PRESSED then
					instance:set("active", 1)
					instance.spriteSpeed = SPRITE_SPEED
					local sound = Sound.fromID(instance:get("sound") or -1)
					if sound then sound:play(1, 1) end
					-- Activate
				end
			end
		end
	end)

	object:addCallback("draw", function(instance)
		if instance:get("active") == 0 then
			local player = o_player:findNearest(instance.x, instance.y)
			if player:collidesWith(instance, player.x, player.y) then
				local text = string.format(
					"&%s&Press &y&'%s'&%s& %s &%s&(%s%s)&%s&",
					DEFAULT_COLOR,
					input.getControlString("enter", player),
					DEFAULT_COLOR,
					instance:get("text") or "to activate",
					instance:get("cost_color") or DEFAULT_COST_COLOR,
					instance:get("cost_symbol") or DEFAULT_COST_SYMBOL,
					instance:get("cost") or 0,
					DEFAULT_COLOR
				)
				colorPrint(
					text,
					instance.x,
					instance.y - instance.sprite.height - FLOAT,
					graphics.FONT_DEFAULT
				)
			end

			local cost = instance:get("cost") or 0
			if cost ~= 0 then
				local cost_text = string.format(
					"&%s&%s%s&%s&",
					instance:get("cost_color") or DEFAULT_COST_COLOR,
					instance:get("cost_symbol") or DEFAULT_COST_SYMBOL,
					cost,
					DEFAULT_COLOR
				)
				colorPrint(cost_text, instance.x, instance.y + SINK, graphics.FONT_DAMAGE, 0.8)
			end
		end
	end)

	local iname
	if name then iname = name .. "Interactable" end
	local interactable = Interactable.new(object, iname)

	return object, interactable
end

export("MapObject", MapObject)
return MapObject

-- MapObject

if not restre.depends("CycloneLib.net") then return nil end
if not restre.depends("CycloneLib.collision") then return nil end
if not restre.depends("CycloneLib.graphics") then return nil end

local o_player = Object.find("P", "Vanilla")
local s_fail = Sound.find("Error", "Vanilla")

local DEFAULT_COLOR = "w"
local DEFAULT_COST_COLOR = "y"
local DEFAULT_COST_SYMBOL = "$"
local SPRITE_SPEED = 0.2
local CLIMB = 24
local SINK = 8

local fireworks = Item.find("Bundle of Fireworks", "Vanilla")
local o_firework = Object.find("EfFirework", "Vanilla")
local function procFireworks(player, x, y)
	local count = player:countItem(fireworks)
	if count > 0 then
		for i=1,(6 + 3 * count) do
			o_firework:create(x, y):set("damage", 36 + 9 * player:get("level"))
		end
	end
end

local MapObject = {}
local callbacks = {}

local function playID(id)
	local sound = Sound.fromID(id or -1)
	if sound then sound:play(1, 1) end
end

local function activate(instance, player)
	if instance:get("active") ~= 0 then return nil end
	if instance:get("proc_fireworks") then
		procFireworks(player, instance.x, instance.y)
	end
	instance:set("active", 1)
	instance:set("activator", player.id)
	instance.spriteSpeed = SPRITE_SPEED
	playID(instance:get("sound"))
	local shake = instance:get("shake")
	if shake > 0 then misc.shakeScreen(shake) end
	instance:setAlarm(0, 30 - 1)
end

local sync_activate = CycloneLib.net.AutoPacket(function(instance, player)
	if not instance then print("No inst") end
	if (not instance) or (not player) then print("Not Synced") ; return nil end
	activate(instance, player)
end)

MapObject.addCallback = function(object, name, callback)
	callbacks[object][name] = callback
end

MapObject.shouldActivate = function(instance)
	return instance:getAlarm(0) == 1
end

MapObject.new = function(name)
	local object = Object.base("MapObject", name)

	callbacks[object] = {}
	callbacks[object].canActivate = function(instance, player) return false end

	object:addCallback("create", function(instance)
		instance.spriteSpeed = 0

		instance
		:set("active", 0)
		:set("activator", 3)
		:set("myplayer", -4)
		:set("fail_sound", s_fail.id)
		:set("proc_fireworks", 1)
		:set("shake", 1)

		instance.y = CycloneLib.collision.getGround(instance.x, instance.y)
	end)

	object:addCallback("step", function(instance)
		local alarm = instance:getAlarm(0)
		if alarm >= 0 then instance:setAlarm(0, alarm - 1) end

		if instance:get("active") == 0 then
			local player = o_player:findNearest(instance.x, instance.y)
			if player:collidesWith(instance, player.x, player.y) then
				instance:set("myplayer", player.id)
				if player:control("enter") == input.PRESSED and player:get("activity") == 0 then
					if callbacks[object].canActivate(instance, player) then
						sync_activate(instance, player)
					else
						playID(instance:get("fail_sound"))
					end
				end
			end
		else
			if instance.subimage + instance.spriteSpeed >= instance.sprite.frames then
				instance.subimage = instance.sprite.frames
				instance.spriteSpeed = 0
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
				graphics.alpha(1)
				CycloneLib.graphics.printColor(
					text,
					instance.x,
					instance.y - instance.sprite.height - CLIMB,
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
				graphics.alpha(0.8)
				CycloneLib.graphics.printColor(
					cost_text,
					instance.x,
					instance.y + SINK,
					graphics.FONT_DAMAGE
				)
			end
		end
	end)

	local iname
	if name then iname = name .. "Interactable" end
	local interactable = Interactable.new(object, iname)

	return object, interactable
end

export("CycloneLib.MapObject", MapObject)
export("MapObject", MapObject)
return MapObject

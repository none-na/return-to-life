if not restre.depends("CycloneLib.MapObject") then return nil end
if not restre.depends("CycloneLib.graphics") then return nil end
if not restre.depends("Lunar") then return nil end

local const = {
	TEXT = "to obliterate yourself from existence",
	MESSAGE = "FATE UNKNOWN",
	COINS = 5,
	PT_MIN = 10,
	PT_MAX = 30,
	CONFIRM_TIMER = 2 * 60,
	CONFIRM_TEXT = "if you are sure",
	SHINE_COUNT = 4,
	SHORT_DELAY = 4,
}

local sprites = {
	obelisk = restre.spriteLoad("obelisk", 1, math.ceil(73/2), 93),
}

local sounds = {
	windup     = restre.soundLoad("obeliskWindup"),
	obliterate = restre.soundLoad("eradicate.ogg"),
}

local pt_obliterate = ParticleType.new("Obliterate")
pt_obliterate:shape("square")
pt_obliterate:color(Color.WHITE, Color.AQUA)
pt_obliterate:additive(true)
pt_obliterate:scale(0.1, 0.1)
pt_obliterate:size(1, 1, -0.01, 0)
pt_obliterate:angle(0, 360, 0, 0, false)
pt_obliterate:direction(0, 360, 0, 0)
pt_obliterate:speed(0.4, 0.9, -0.01, 0)

local obliterated = false
callback.register("onGameStart", function()
	obliterated = false
end)

local o_player = Object.find("P", "Vanilla")
local o_dead = Object.find("EfPlayerDead", "Vanilla")
callback.register("onStep", function()
	if obliterated then
		for _,i_dead in ipairs(o_dead:findAll()) do
			local data = i_dead:getData()
			if not data.obliterated then
				local ac = i_dead:getAccessor()
				ac.vspeed = 0
				ac.hspeed = 0
				ac.death_message = const.MESSAGE
				--i_dead.visible = false
				i_dead.sprite = CycloneLib.resources.transparent2x2
				local pt_count = math.random(const.PT_MIN, const.PT_MAX)
				pt_obliterate:burst("above", i_dead.x, i_dead.y, pt_count)
				data.obliterated = true
			end
		end
	end
end)

local obelisk, in_obelisk = CycloneLib.MapObject.new("Obelisk")
obelisk.sprite = sprites.obelisk

obelisk:addCallback("create", function(i_obelisk)
	i_obelisk.depth = 8
	i_obelisk:set("cost", 0)
	i_obelisk:set("text", const.TEXT)
	i_obelisk:set("sound", sounds.windup.id)
	i_obelisk:set("charges", 1)
	i_obelisk:set("cooldown", const.CONFIRM_TIMER)
end)

CycloneLib.MapObject.addCallback(obelisk, "canActivate", function(i_obelisk)
	return i_obelisk:getAlarm(1) == -1
end)

obelisk:addCallback("step", function(i_obelisk)
	print(i_obelisk:getAlarm(1))
	local data = i_obelisk:getData()

	if not data.confirm then
		if CycloneLib.MapObject.beginActivate(i_obelisk) then
			i_obelisk:set("text", const.CONFIRM_TEXT)
			i_obelisk:set("sound", sounds.obliterate.id)
			i_obelisk:set("activate_delay", const.SHORT_DELAY)
		end
		if CycloneLib.MapObject.shouldActivate(i_obelisk) then
			data.confirm = true
		end
	else
		if CycloneLib.MapObject.shouldActivate(i_obelisk) then
			obliterated = true
			Lunar.give(Lunar.getLocal(), const.COINS)
			for _,player in ipairs(misc.players) do
				if player:get("dead") == 0 then
					--player:getData().obliterate = true
					player:kill()
				end
			end
		end
	end
end)

obelisk:addCallback("draw", function(i_obelisk)
	local alpha = i_obelisk:getAlarm(1) / const.CONFIRM_TIMER
	if alpha > 0 then
		graphics.setBlendMode("additive")
		for i=1,const.SHINE_COUNT do
			CycloneLib.graphics.replicate(i_obelisk, {
				alpha = alpha,
			})
		end
	end
end)

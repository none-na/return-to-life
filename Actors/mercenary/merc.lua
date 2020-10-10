--require("Misc.loadout")
--require("Libraries.skill.main")

---------------
-- Resources --
---------------

local baseSprites = {
	idle = Sprite.find("SamuraiIdle", "vanilla"),
	walk = Sprite.find("SamuraiWalk", "vanilla"),
	jump = Sprite.find("SamuraiJump", "vanilla"),
	climb = Sprite.find("SamuraiClimb", "vanilla"),
	death = Sprite.find("SamuraiDeath", "vanilla"),
	
}

local sprites = {
	shoot1_1 = Sprite.find("SamuraiShoot1_1", "vanilla"),
	shoot1_2 = Sprite.find("SamuraiShoot1_2", "vanilla"),
	shoot2 = Sprite.find("SamuraiShoot2", "vanilla"),
	shoot2b = Sprite.load("MercShoot2Alt", "Actors/mercenary/shoot2alt", 5, 8, 14),
	shoot3 = Sprite.find("SamuraiShoot3_1", "vanilla"),
	shoot4 = Sprite.find("SamuraiShoot4", "vanilla"),
	shoot5 = Sprite.find("SamuraiShoot5", "vanilla"),
	palettes = Sprite.load("MercPalettes", "Actors/mercenary/palettes", 2, 0, 0),
	icons = Sprite.load("MercSkills", "Actors/mercenary/skills", 11, 0, 0),
	loadout = Sprite.find("SelectSamurai", "vanilla"),
	sparks9 = Sprite.find("Sparks9", "vanilla"),
	sparks9r = Sprite.find("Sparks9r", "vanilla"),
	sparks10 = Sprite.find("Sparks10", "vanilla"),
	sparks10r = Sprite.find("Sparks10r", "vanilla"),
}

local sounds = {
	samuraiShoot1 = Sound.find("SamuraiShoot1", "vanilla"),
	minerShoot2 = Sound.find("MinerShoot2", "vanilla"),
	guardDeath = Sound.find("GuardDeath", "vanilla"),
	geyser = Sound.find("Geyser", "vanilla"),
}


local objects = {
	dust = Object.find("MinerDust", "vanilla"),

}


local actors = ParentObject.find("actors", "vanilla")
local enemies = ParentObject.find("enemies", "vanilla")

------------
--  Misc  --
------------

local function initActivity(player, index, sprite, speed, scaleSpeed, resetHSpeed)
	if player:get("activity") == 0 then
		player:survivorActivityState(index, sprite, speed, scaleSpeed, resetHSpeed)
		player:activateSkillCooldown(index)
		return true
	end
	return false
end

local function setPlayerX(player, x)
	player.x = x
	player:set("ghost_x", x)
end

local function setPlayerY(player, y)
	player.y = y
	player:set("ghost_y", y)
end

local stepwidth = 6

local function dashMove(player, maxdist, facing)	
	if player:collidesMap(player.x, player.y) then
		return
	end
	
	local dist = 0
	local x, y = player.x, player.y
	
	while true do
		dist = math.min(dist + stepwidth, maxdist)
		local tx = x + dist * facing
		if player:collidesMap(tx, y) then
			break
		elseif dist == maxdist then
			setPlayerX(player, tx)
			return
		end
	end
	for i = 1, stepwidth do
		dist = dist - 1
		local tx = x + dist * facing
		if not player:collidesMap(tx, y) then
			setPlayerX(player, tx)
			return
		end
	end
end


------------
-- Skills --
------------

-- Cybernetic Enhancements
local doubleJump = Skill.new()

doubleJump.displayName = "Cybernetic Enhancements"
doubleJump.description = "The Mercenary can jump twice."
doubleJump.icon = sprites.icons
doubleJump.iconIndex = 9
doubleJump.cooldown = -1


-- Laser Sword
local sword = Skill.new()

sword.displayName = "Laser Sword"
sword.description = "Slash in front of you, damaging up to 3 enemies for 130% damage."
sword.icon = sprites.icons
sword.iconIndex = 1
sword.cooldown = 10

sword:setEvent("init", function(player, index)
	local choice = player:getAnimation("shoot1_1")
	if math.random() < 0.5 then
		choice = player:getAnimation("shoot1_2")
	end
	if initActivity(player, index, choice, 0.25, true, true) then
		player:setAlarm(index + 1, sword.cooldown / player:get("attack_speed"))
		return true
	end
	return false
end)

local function shootLaserSword(player)
	for i = 0, player:get("sp") do
        local bullet = player:fireExplosion(player.x + (12 * player.xscale), player.y + 8, 1, 3, 1.3, nil, sprites.sparks9)
        bullet:set("max_hit_number", 3)
		bullet:set("climb", 0 + i * 8)
    end
    --player.x = player.x + (3* player.xscale)
	sounds.samuraiShoot1:play(0.8 + math.random() * 0.2)
end

sword:setEvent(3, function(player)
	if player:survivorFireHeavenCracker(1) then return end
	shootLaserSword(player)
    dashMove(player, 3, player.xscale)
end)


-- Whirlwind
local whirlwind = Skill.new()

whirlwind.displayName = "Whirlwind"
whirlwind.description = "Quickly slice twice, dealing 2x80% damage to all nearby enemies."
whirlwind.icon = sprites.icons
whirlwind.iconIndex = 2
whirlwind.cooldown = 120

whirlwind:setEvent("init", function(player, index)
	if initActivity(player, index, player:getAnimation("shoot2"), 0.3, true, true) then
		player:setAlarm(index + 1, whirlwind.cooldown)
		player:set("activity", 2)
		return true
	end
	return false
end)

whirlwind:setEvent(1, function(player)
	player:set("pVspeed", math.min(-player:get("pVmax")*1, player:get("pVspeed") - player:get("pVmax") * 0.3))
	for i = 0, player:get("sp") do
        local bullet = player:fireExplosion(player.x, player.y, 1.8, 5, 0.8, nil, sprites.sparks9)
        bullet:set("max_hit_number", 3)
		bullet:set("climb", 0 + i * 8)
    end
	sounds.samuraiShoot1:play(1.2 + math.random() * 0.2)
end)

whirlwind:setEvent(3, function(player)
	for i = 0, player:get("sp") do
        local bullet = player:fireExplosion(player.x, player.y, 1.8, 5, 0.8, nil, sprites.sparks9)
        bullet:set("max_hit_number", 3)
		bullet:set("climb", (0 + i * 8) + 11)
    end
	sounds.samuraiShoot1:play(1.2 + math.random() * 0.2)
end)

-- Rising Thunder
local uppercut = Skill.new()

uppercut.displayName = "Rising Thunder"
uppercut.description = "Unleash a slicing uppercut, dealing 450% damage and sending you airborne."
uppercut.icon = sprites.icons
uppercut.iconIndex = 11
uppercut.cooldown = 120



uppercut:setEvent("init", function(player, index)
	if initActivity(player, index, player:getAnimation("shoot2b"), 0.3, true, true) then
		player:setAlarm(index + 1, uppercut.cooldown)
		player:set("activity", 2)
		return true
	end
	return false
end)
uppercut:setEvent(2, function(player)
	player:set("pVspeed", -player:get("pVmax")*2)
	if player:get("free") == 0 then
		objects.dust:create(player.x + (player.sprite.width * player.xscale), player.y).xscale = -player.xscale
	end
	for i = 0, player:get("sp") do
        local bullet = player:fireExplosion(player.x, player.y, 1.8, 5, 0.8, nil, sprites.sparks9)
        bullet:set("knockup", player:get("pVmax")*2)
		bullet:set("climb", 0 + i * 8)
    end
	sounds.samuraiShoot1:play(0.7 + math.random() * 0.1)
	
	sounds.geyser:play(1 + math.random() * 0.1)
end)


-- Blinding Assault

local blindingAssault = Skill.new()


blindingAssault.displayName = "Blinding Assault"
blindingAssault.description = "Dash forwards a large distance, shortly stunning enemies and dealing 120% damage. If you hit an enemy, you can dash again, up to 3 times."
blindingAssault.icon = sprites.icons
blindingAssault.iconIndex = 3
blindingAssault.cooldown = 360

local assaultReset = 3*60

local AssaultStep = function(player)
	local p = player:getAccessor()
	if p.dash_again and p.dash_timer then
		if p.dash_again > 0 then
			p.dash_timer = p.dash_timer + 1
			if p.dash_timer > assaultReset then
				p.dash_timer = 0
				p.dash_again = 0
				player:setAlarm(4, blindingAssault.cooldown)
			end
		end
	else
		p.dash_again = 0
		p.dash_timer = 0
	end
end

local HitscanCheck = function(player, distance, direction)
	for _, inst in ipairs(actors:findAllLine(player.x, player.y, player.x + (distance * player.xscale), player.y)) do
		if inst:isValid() then
			print(inst)
			if inst:get("team") ~= player:get("team") then
				return true
			end
		end
	end
	return false
end

local FireAssault = function(player)
	local bullet = nil
	for i = 0, player:get("sp") do
        bullet = player:fireBullet(player.x, player.y, 90 - (90 * player.xscale), math.abs(player:get("pHmax")*10*player.xscale*4), 1, sprites.sparks10, DAMAGER_BULLET_PIERCE)
		bullet:set("climb", (0 + i * 8))
		bullet:set("stun", 0.5)
	end
	return bullet
end

blindingAssault:setEvent("init", function(player, index)
	local p = player:getAccessor()
	if initActivity(player, index, player:getAnimation("shoot3"), 0.25, true, true) or (p.dash_again and p.dash_again ~= 0) then
		if not player:getAccessor().assault then
			player:getAccessor().assault = 1
			p.dash_again = 0
			p.dash_timer = 0
		end
		local dist = (player:get("pHmax") * 10) * 4
		if player:get("free") == 0 then
			for i = 0, dist do
				if i % dist / 3 == 0 then
					local inst = objects.dust:create(player.x + (i * player.xscale), player.y)
					inst.xscale = player.xscale
				end
			end
		end
		p.invincible = 5
		misc.shakeScreen(5)
		sounds.minerShoot2:play(1.4 + math.random() * 0.1)
		local bullet = FireAssault(player)
		if p.dash_again >= 2 then
			p.dash_again = 0
		else
			if HitscanCheck(player, dist, player.xscale) then
				player:setAlarm(index + 1, 30)
				p.dash_again = p.dash_again + 1
				Skill.set(player, index, blindingAssault)
				p.dash_timer = 0
			else
				p.dash_again = 0
				p.dash_timer = 0
			end
		end
		player:setSkill(index, blindingAssault.displayName, blindingAssault.description, blindingAssault.icon, 3 + p.dash_again, blindingAssault.cooldown)
		dashMove(player, dist, player.xscale)
		return true
	end
	return false
end)
blindingAssault:setEvent("last", function(player)
	if player:get("invincible") <= 5 then
		player:set("invincible", 0)
	end
	player:set("pHspeed", 0)
end)

-- Eviscerate
local evis = Skill.new()

evis.displayName = "Eviscerate"
evis.description = "Target the nearest enemy, quickly attacking them for 6x110% damage. You cannot be hit for the duration."
evis.icon = sprites.icons
evis.iconIndex = 6
evis.cooldown = 360

local searchArea = 100

local FindUltTarget = function(player)
	local dist = {}
	local smallest = math.huge
	local tg = -1
	for _, inst in ipairs(enemies:findAllEllipse(player.x - searchArea, player.y - searchArea, player.x + searchArea, player.y + searchArea)) do
		if inst:isValid() then
			dist[inst] = util.distance(player.x, player.y, inst.x, inst.y)
			if dist[inst] < smallest then
				smallest = dist[inst]
				tg = inst.id
			end

		end
	end
	--[[local target =  enemies:findNearest(player.x, player.y)
	if target and Object.findInstance(target.id) and Object.findInstance(target.id):isValid() then
		if util.distance(player.x, player.y, target.x, target.y) < 100 then
			return target.id
		end
	end]]
	return tg
end

local FireEviscerate = function(player, target, scepter)
	local hitsprite = nil
	if scepter then
		if math.random() < 0.5 then
			hitsprite = sprites.sparks9r
		else
			hitsprite = sprites.sparks10r
		end
	else
		if math.random() < 0.5 then
			hitsprite = sprites.sparks9
		else
			hitsprite = sprites.sparks10
		end
	end
	sounds.samuraiShoot1:play(0.8 + math.random() * 0.2, 1)
	sounds.guardDeath:play(1.8 + math.random() * 0.2, 0.85)
	local xx = (Sprite.fromID(target:get("sprite_idle")).xorigin + 2 + math.random(Sprite.fromID(target:get("sprite_idle")).width - 2))
	local yy = (Sprite.fromID(target:get("sprite_idle")).yorigin + 2 + math.random(Sprite.fromID(target:get("sprite_idle")).height - 2))
	for i = 0, player:get("sp") do
        local bullet = player:fireBullet(target.x - xx, target.y + yy, GetAngleTowards(target.x- xx, target.y + yy, target.x, target.y), 18, 1.1, hitsprite, nil)
		bullet:set("climb", (5 * (math.floor(player.subimage) - 4)) + (5*i))
		bullet:set("specific_target", target.id)
	end
	if scepter then

		if target:get("hp") - (1.1 * player:get("damage")) <= 0 then
			print(target)
			player:getAccessor().ult_target = FindUltTarget(player)
			print(Object.findInstance(player:getAccessor().ult_target))
			player.subimage = 4
		end
	end
end

evis:setEvent("init", function(player, index)
	if initActivity(player, index, player:getAnimation("shoot4"), 0.3, true, true) then
		player:setAlarm(index + 1, evis.cooldown)
		local p = player:getAccessor()
		p.ult_target = FindUltTarget(player)
		return true
	end
	return false
end)

evis:setEvent("all", function(player)
	player:set("invincible", 5)
end)

for i = 4, 14 do
	if i % 2 == 0 then
		evis:setEvent(i, function(player, index)
			local p = player:getAccessor()
			if p.ult_target and Object.findInstance(p.ult_target) then
				FireEviscerate(player, Object.findInstance(p.ult_target), false)
			end
		end)
	end
end

evis:setEvent("last", function(player)	
	player:set("invincible", 0)
end)



-- Massacre
local massacre = Skill.new()

massacre.displayName = "Massacre"
massacre.description = "Target the nearest enemy, quickly attacking them for 6x110% damage. You cannot be hit for the duration. Refreshes duration on kills, jumping to nearby enemies."
massacre.icon = sprites.icons
massacre.iconIndex = 7
massacre.cooldown = 360

massacre:setEvent("init", function(player, index)
	if initActivity(player, index, player:getAnimation("shoot5"), 0.3, true, true) then
		player:setAlarm(index + 1, massacre.cooldown)
		local p = player:getAccessor()
		p.ult_target = FindUltTarget(player)
		return true
	end
	return false
end)

massacre:setEvent("all", function(player)
	player:set("invincible", 5)
end)


for i = 4, 14 do
	if i % 2 == 0 then
		massacre:setEvent(i, function(player, index)
			local p = player:getAccessor()
			if p.ult_target and Object.findInstance(p.ult_target) then
				FireEviscerate(player, Object.findInstance(p.ult_target), true)
			end
		end)
	end
end

massacre:setEvent("last", function(player)
	player:set("invincible", 0)
end)

-- Slicing Winds
local winds = Skill.new()

winds.displayName = "Slicing Winds"
winds.description = "Fire a wind of blades that attack up to 3 enemies for 8x100% damage."
winds.icon = sprites.icons
winds.iconIndex = 10
winds.cooldown = 120


------------
-- OnStep --
------------

registercallback("postStep", function()
	for _, player in ipairs(misc.players) do
		local p = player:getAccessor()
		if p.assault then
			AssaultStep(player)
		end
	end
end)

--------------
--  Skins   --
--------------

local s_default = Skill.new()

s_default.displayName = "Default"
s_default.description = ""
s_default.icon = sprites.palettes
s_default.iconIndex = 1
s_default.cooldown = -1

local defaultSprites = {
	["loadout"] = sprites.loadout,
	["idle"] = baseSprites.idle,
	["walk"] = baseSprites.walk,
	["jump"] = baseSprites.jump,
	["climb"] = baseSprites.climb,
	["death"] = baseSprites.death,
	["shoot1_1"] = sprites.shoot1_1,
	["shoot1_2"] = sprites.shoot1_2,
	["shoot2"] = sprites.shoot2,
	["shoot2b"] = sprites.shoot2b,
	["shoot3"] = sprites.shoot3,
	["shoot4"] = sprites.shoot4,
	["shoot5"] = sprites.shoot5,
}

local s_oni = Skill.new()

s_oni.displayName = "Oni"
s_oni.description = ""
s_oni.icon = sprites.palettes
s_oni.iconIndex = 2
s_oni.cooldown = -1

local onisprites = {
	["loadout"] = Sprite.load("MercLoadoutSkin1", "Actors/mercenary/oni/select.png", sprites.loadout.frames, sprites.loadout.xorigin, sprites.loadout.yorigin),
	["idle"] = baseSprites.idle,
	["walk"] = baseSprites.walk,
	["jump"] = baseSprites.jump,
	["climb"] = baseSprites.climb,
	["death"] = baseSprites.death,
	["shoot1_1"] = sprites.shoot1_1,
	["shoot1_2"] = sprites.shoot1_2,
	["shoot2"] = sprites.shoot2,
	["shoot2b"] = sprites.shoot2b,
	["shoot3"] = sprites.shoot3,
	["shoot4"] = sprites.shoot4,
	["shoot5"] = sprites.shoot5,
}



--------------
-- Survivor --
--------------

local merc = Survivor.new("Mercenary 2.0")
local vanilla = Survivor.find("Mercenary")

local loadout = Loadout.new()
loadout.survivor = merc
loadout.description = [[The &y&Mercenary&!& deals fast damage while dodging incoming threats.
&y&Whirlwind&!& can be used to stay in mid-air longer.
Fit skills between &y&Blinding Assaults&!& to maximize time spent invincible.]]

local passive = loadout:getSlot("Passive")
passive.showInLoadoutMenu = true
passive.showInCharSelect = true
loadout:addSkill("Passive", doubleJump, {
	loadoutDescription = [[The Mercenary can jump twice.]],
	apply = function(player) 
		player:set("feather", player:get("feather") + 1) 
	end,
	remove = function(player, hardRemove)
		if hardRemove then
			player:set("feather", 0)
		else
			player:set("feather", player:get("feather") - 1)
		end 
	end,
})
loadout:addSkill("Passive", Loadout.PresetSkills.NoPassive, {
	displayName = "Disable the Mercenary's Passive abilities."
})
loadout:addSkill("Primary", sword, {
	loadoutDescription = [[Slash in front of you, damaging up
to &y&3 enemies&!& for &y&130% damage&!&.]]
})
loadout:addSkill("Secondary", whirlwind, {
	loadoutDescription = [[Quickly slice twice, dealing &y&2x80% damage&!& to all nearby enemies.]]
})
loadout:addSkill("Secondary", uppercut,{
	loadoutDescription = [[Unleash a slicing uppercut, dealing &y&450% damage&!& and 
sending you and the target airborne.]],
locked = true,
})
loadout:addSkill("Utility", blindingAssault,{
	loadoutDescription = [[&y&Dash forwards&!&, stunning enemies for &y&120% damage&!&.
If you hit an enemy, &b&you can dash again&!&, &y&up to 3 times.&!&]]
})
loadout:addSkill("Special", evis,{
	loadoutDescription = [[Target the nearest enemy, attacking them for &y&6x110% damage&!&.
&b&You cannot be hit for the duration.&!&]],
	upgrade = loadout:addSkill("Special", massacre, {hidden = true}) 
}) 
loadout:addSkill("Special", winds,{
	loadoutDescription = [[Fire a wind of blades that attack up to &y&3&!& enemies for &y&8x100% damage&!&.]],
locked = true,
})
loadout:addSkin(s_default, defaultSprites)
loadout:addSkin(s_oni, onisprites, {
	locked = true
})

merc.titleSprite = baseSprites.walk
merc.loadoutColor = Color.fromRGB(171, 226, 248)
merc.loadoutSprite = sprites.loadout
merc.endingQuote = "..and so he left, never to become human again." 

merc:addCallback("init", function(player)
	player:setAnimations(baseSprites)
	player:survivorSetInitialStats(122, 12, 0.04)
end)

merc:addCallback("levelUp", function(player)
	player:survivorLevelUpStats(36, 3, 0.003, 3)
	player:set("attack_speed", player:get("attack_speed") + 0.025)
end)

merc:addCallback("scepter", function(player)
	Loadout.Upgrade(loadout, player, "Special")
end)

Loadout.RegisterSurvivorID(merc)


----------------------------------------------------------


local vanillaUnlock = Achievement.find("unlock_mercenary", "vanilla")

local mercUnlock = Achievement.new("unlock_merc_ror2")
mercUnlock:assignUnlockable(merc)
mercUnlock.requirement = 1
mercUnlock.description = "Obliterate yourself at the Obelisk."
mercUnlock.deathReset = false

local ManageMercUnlock = function()
	if vanillaUnlock:isComplete() and not mercUnlock:isComplete() then
		mercUnlock:increment(1)
	end
end

ManageMercUnlock()

callback.register("postStep", function()
	ManageMercUnlock()
end)

return merc
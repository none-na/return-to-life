--require("Misc.loadout")
--require("Libraries.skill.main")

---------------
-- Resources --
---------------

local baseSprites = {
	idle_nailgun = Sprite.load("toolbot_idle_nailgun", "Actors/mult/idle1", 1, 11, 17),
	idle_rebar = Sprite.load("toolbot_idle_rebar", "Actors/mult/idle2", 1, 11, 17),
	idle_buzzsaw = Sprite.load("toolbot_idle_buzzsaw", "Actors/mult/idle4", 1, 11, 17),
	---------------------------
	walk_nailgun = Sprite.load("toolbot_walk_nailgun", "Actors/mult/walk1", 2, 11, 17),
	walk_rebar = Sprite.load("toolbot_walk_rebar", "Actors/mult/walk2", 2, 11, 17),
	walk_buzzsaw = Sprite.load("toolbot_walk_buzzsaw", "Actors/mult/walk4", 2, 11, 17),
	---------------------------
	jump_nailgun = Sprite.load("toolbot_jump_nailgun", "Actors/mult/jump1", 1, 13, 17),
	jump_rebar = Sprite.load("toolbot_jump_rebar", "Actors/mult/jump2", 1, 13, 17),
	jump_buzzsaw = Sprite.load("toolbot_jump_buzzsaw", "Actors/mult/jump4", 1, 13, 17),
	---------------------------
	climb_nailgun = Sprite.load("toolbot_climb_nailgun", "Actors/mult/climb1", 2, 9, 16),
	climb_rebar = Sprite.load("toolbot_climb_rebar", "Actors/mult/climb2", 2, 9, 16),
	climb_buzzsaw = Sprite.load("toolbot_climb_buzzsaw", "Actors/mult/climb4", 2, 9, 16),
	---------------------------
	death_nailgun = Sprite.load("toolbot_death_nailgun", "Actors/mult/death1", 14, 13, 24),
	death_rebar = Sprite.load("toolbot_death_rebar", "Actors/mult/death2", 14, 13, 24),
	death_buzzsaw = Sprite.load("toolbot_death_buzzsaw", "Actors/mult/death4", 14, 13, 24),
	---------------------------
	decoy = Sprite.load("toolbot_decoy", "Actors/mult/decoy", 1, 9, 14),
}

local sprites = {
	shoot1_nailgun = Sprite.load("toolbot_shoot1_1", "Actors/mult/shoot1_1", 4, 11, 17),
	shoot1_nailgun_end = Sprite.load("toolbot_shoot1_1cooldown", "Actors/mult/shoot1_1end", 4, 11, 17),
	shoot1_rebar = Sprite.load("toolbot_shoot1_2", "Actors/mult/shoot1_2", 10, 11, 17),
	shoot2_nailgun = Sprite.load("toolbot_shoot2_1", "Actors/mult/shoot2_1", 8, 11, 17),
	shoot2_rebar = Sprite.load("toolbot_shoot2_2", "Actors/mult/shoot2_2", 8, 11, 17),
	shoot3_1_nailgun = Sprite.load("toolbot_shoot3_1_1", "Actors/mult/shoot3_1_1", 4, 11, 14),
	shoot3_1_rebar = Sprite.load("toolbot_shoot3_1_2", "Actors/mult/shoot3_1_2", 4, 11, 14),
	shoot3_2 = Sprite.load("toolbot_shoot3_2", "Actors/mult/shoot3_2", 2, 11, 10),
	shoot3_3_nailgun = Sprite.load("toolbot_shoot3_3_1", "Actors/mult/shoot3_3_1", 4, 11, 14),
	shoot3_3_rebar = Sprite.load("toolbot_shoot3_3_2", "Actors/mult/shoot3_3_2", 4, 11, 14),
	shoot4_1_nailgun = Sprite.load("toolbot_shoot4_1_nailgun", "Actors/mult/shoot4_1_nailgun", 4, 11, 17),
	shoot4_1_rebar = Sprite.load("toolbot_shoot4_1_rebar", "Actors/mult/shoot4_1_rebar", 4, 11, 17),
	shoot4_2_nailgun = Sprite.load("toolbot_shoot4_2_nailgun", "Actors/mult/shoot4_2_nailgun", 5, 11, 17),
	shoot4_2_rebar = Sprite.load("toolbot_shoot4_2_rebar", "Actors/mult/shoot4_2_rebar", 5, 11, 17),
	-------------------
	icons = Sprite.load("toolbot_skills", "Actors/mult/skills", 9, 0, 0),
	palettes = Sprite.load("ToolbotPalettes", "Actors/mult/palettes", 2, 0, 0),
	loadout = Sprite.load("toolbot_select", "Actors/mult/select", 16, 2, 0),
	-------------------
	nailgunImpact = Sprite.load("toolbot_shoot1_1hitsprite", "Actors/mult/nails", 6, 8, 4),
	rebarImpact = Sprite.load("toolbot_shoot1_2hitsprite", "Actors/mult/rebar", 8, 34, 9),
	refurbish = Sprite.load("refurbSprite","Actors/mult/refurbished", 1, 3, 3),
	stunbomb = Sprite.load("toolbot_stunBombSprite", "Actors/mult/stunBomb", 4, 4, 4),
	bombMask = Sprite.load("toolbot_stunBombMask", "Actors/mult/bombMask", 1, 6, 6),
	sparks1 = Sprite.find("Sparks1", "vanilla"),
	sparks2 = Sprite.find("Sparks2", "vanilla"),
	explosive = Sprite.find("EfExplosive","vanilla"),
	bombExplode = Sprite.find("EfBombExplode","vanilla"),
}

local sounds = {
	nailgunFireSound = Sound.load("toolbotShoot1_1a", "Sounds/SFX/mult/multMinigun.ogg"),
	nailgunCooldownSound = Sound.load("toolbotShoot1_1b", "Sounds/SFX/mult/multGunWinddown.ogg"),
	rebarWindUp = Sound.load("toolbot_shoot1_2a", "Sounds/SFX/mult/rebarWindup.ogg"),
	rebarFireSound = Sound.load("toolbotShoot1_2b", "Sounds/SFX/mult/multRebarPuncher.ogg"),
	bombFireSound =  Sound.load("toolbotShoot2_1", "Sounds/SFX/mult/multBombLoad.ogg"),
	stunBombExplosionSound = Sound.load("toolbotShoot2_2", "Sounds/SFX/mult/multBomb.ogg"),
	bombletExplosionSound = Sound.load("toolbotShoot2_3", "Sounds/SFX/mult/multBomblets.ogg"),
	transportEnterSound = Sound.load("toolbotShoot3_1", "Sounds/SFX/mult/transportStart.ogg"),
	transportLoopSound = Sound.load("toolbotShoot3_2", "Sounds/SFX/mult/multTransportB.ogg"),
	transportHitSound = Sound.load("toolbotShoot3_3", "Sounds/SFX/mult/multImpact.ogg"),
	CowboyShoot2 = Sound.find("CowboyShoot2", "vanilla"),
	chest2 = Sound.find("Chest2", "vanilla"),
	retool = Sound.load("toolbotShoot4", "Sounds/SFX/mult/multRetool.ogg"),
}

local objects = {
	dust = Object.find("MinerDust", "vanilla")
}

local enemies = ParentObject.find("enemies", "vanilla")

------------
-- Stuff  --
------------
local nailRotationOffset = 5 --Furthest variation a nail's angle will have.
local transportTime = 2*60
local transportSpeedMultiplier = 2 -- MUL-T will go X times his pHmax when in transport mode.


local stunBomb = Object.new("EfStunbomb")
stunBomb.sprite = sprites.stunbomb

stunBomb:addCallback("create", function(self)
	local s = self:getAccessor()
	local data = self:getData()
	self.mask = sprites.bombMask
	s.ay = 0.22
	s.rotate = 20
	s.detonate = 0
end)
stunBomb:addCallback("step", function(self)
	local s = self:getAccessor()
	local data = self:getData()
	local parent = data.parent
	if s.detonate == 0 then
		PhysicsStep(self)
		local nearest = enemies:findNearest(self.x, self.y)
		if Stage.collidesPoint(self.x, self.y) or (nearest and self:collidesWith(nearest, self.x, self.y)) then
			s.detonate = 1
			return
		end
	end
	if s.detonate == 1 then
		if data.bomblet then
			sounds.bombletExplosionSound:play(0.9 + math.random() * 0.1)
			if parent then
				local boom = parent:fireExplosion(self.x, self.y, 0.5, 1, 0.44, sprites.explosive, nil)
				boom:set("stun", 1)
			end
			self:destroy()
			return
		else
			sounds.stunBombExplosionSound:play(0.9 + math.random() * 0.15)
			if parent then
				local boom = parent:fireExplosion(self.x, self.y, 1, 1, 2.2, sprites.bombExplode, nil)
				boom:set("stun", 2)
				for i = 1, 4 do
					local bomblet = stunBomb:create(self.x, self.y-0.5)
					bomblet:getData().parent = parent
					bomblet:getData().bomblet = true
					bomblet.xscale = 0.5
					bomblet.yscale = 0.5
					bomblet:set("vy", math.random(-1, -3))
					bomblet:set("vx", math.random(-3, 3))
				end
			end
			self:destroy()
			return
		end
	end
end)



------------
-- Skills --
------------

local function initActivity(player, index, sprite, speed, scaleSpeed, resetHSpeed)
	if player:get("activity") == 0 then
		player:survivorActivityState(index, sprite, speed, scaleSpeed, resetHSpeed)
		player:activateSkillCooldown(index)
		return true
	end
	return false
end

-- Auto-Nailgun

local nailgun = Skill.new()

nailgun.displayName = "Auto-Nailgun"
nailgun.description = "Rapidly fire nails for 60% damage. Fires six nails when initially pressed."
nailgun.icon = sprites.icons
nailgun.iconIndex = 1
nailgun.cooldown = 30

local nailgunStep = function(player)
	local p = player:getAccessor()
	local data = player:getData()
	if data.nailgun_phase == 1 then
		if p.activity == 0 then
			player:survivorActivityState(1, player:getAnimation("shoot1_nailgun"), 0.25, true, true)
		end
		player.sprite = player:getAnimation("shoot1_nailgun")
		if (math.floor(player.subimage) % 2 == 0) and math.floor(player.subimage) ~= (data.lastSubimage) then
			sounds.nailgunFireSound:play(1 + math.random() * 0.5)
			data.bulletToFire = (data.bulletToFire + 1) % 11
			local bullet
			if data.bulletToFire >= 4 then
				bullet = player:fireBullet(player.x, player.y, player:getFacingDirection() + math.random(-nailRotationOffset, nailRotationOffset), 300, 0.6, sprites.nailgunImpact)
			else
				bullet = player:fireBullet(player.x, player.y, player:getFacingDirection() + math.random(-nailRotationOffset, nailRotationOffset), 300, 0.6, sprites.nailgunImpact, DAMAGER_NO_PROC)
			end
			bullet:set("climb", 8*data.bulletToFire)
		end
	elseif data.nailgun_phase == 2 then
		p.activity = 0
		data.bulletToFire = 0
		sounds.nailgunCooldownSound:play(1)
		player:survivorActivityState(1, player:getAnimation("shoot1_nailgun_end"), 0.25, true, true)
		player:setAlarm(2, nailgun.cooldown / player:get("attack_speed"))
		data.nailgun_phase = 0
		return
	end
	data.lastSubimage = math.floor(player.subimage)
end

local nailgunInputStep = function(player)
	local p = player:getAccessor()
	local data = player:getData()
	if input.checkControl("ability1", player) == input.HELD or input.checkControl("ability1", player) == input.PRESSED then
		if p.activity == 0 and player:getAlarm(2) == -1 then
			data.nailgun_phase = 1
		end
	elseif input.checkControl("ability1", player) == input.RELEASED and data.nailgun_phase == 1 then
		data.nailgun_phase = 2
	end
end


-- Rebar Puncher

local rebar = Skill.new()

rebar.displayName = "Rebar Puncher"
rebar.description = "Fire a piercing rebar that deals 300% damage."
rebar.icon = sprites.icons
rebar.iconIndex = 2
rebar.cooldown = 50

rebar:setEvent("init", function(player, index)
	local p = player:getAccessor()
	local data = player:getData()
	if initActivity(player, index, player:getAnimation("shoot1_rebar"), 0.25, true, true) then
		sounds.rebarWindUp:play(player:get("attack_speed") + math.random() * 0.05)
		player:setAlarm(index + 1, rebar.cooldown / player:get("attack_speed"))
		return true
	end
	return false 
end)

rebar:setEvent(6, function(player, index)
	local p = player:getAccessor()
	local data = player:getData()
	if not player:survivorFireHeavenCracker(1) then
		sounds.rebarFireSound:play(1 + math.random() * 0.05, 1.5)
		player:fireBullet(player.x, player.y, player:getFacingDirection(), 500, 3, sprites.rebarImpact, DAMAGER_BULLET_PIERCE)
	else
		sounds.rebarFireSound:play(1 + math.random() * 0.05, 1.5)
		player:fireBullet(player.x, player.y, player:getFacingDirection(), 500, 3, sprites.rebarImpact, DAMAGER_BULLET_PIERCE)
	end
end)



-- Scrap Launcher

local scrap = Skill.new()

scrap.displayName = "Scrap Launcher"
scrap.description = "Fire an arcing hunk that explodes for 360% damage. Hold up to 4."
scrap.icon = sprites.icons
scrap.iconIndex = 3
scrap.cooldown = 22

-- Power-Saw

local buzzsaw = Skill.new()

buzzsaw.displayName = "Power-Saw"
buzzsaw.description = "Constantly damages nearby enemies for 1000% damage per second."
buzzsaw.icon = sprites.icons
buzzsaw.iconIndex = 4
buzzsaw.cooldown = 22

local SkillToString = {
	[nailgun] = "nailgun",
	[rebar] = "rebar",
	[scrap] = "scrap",
	[buzzsaw] = "buzzsaw",
}

-- Blast Canister



---------------------------------------

local blastCanister = Skill.new()

blastCanister.displayName = "Blast Canister"
blastCanister.description = "Launch a stun canister for 220% damage. Drops stun bomblets for 5x44% damage."
blastCanister.icon = sprites.icons
blastCanister.iconIndex = 5
blastCanister.cooldown = 5*60

blastCanister:setEvent("init", function(player, index)
	local p = player:getAccessor()
	local data = player:getData()
	local anim
	if data.reTooled == 1 then	
		anim = player:getAnimation("shoot2_"..SkillToString[data.Loadout["Misc."].obj])
	else	
		anim = player:getAnimation("shoot2_"..SkillToString[data.Loadout["Primary"].obj])
	end
	if initActivity(player, index, anim, 0.25, true, true) then
		sounds.bombFireSound:play(player:get("attack_speed") + math.random() * 0.05)
		return true
	end
	return false 
end)

blastCanister:setEvent(4, function(player)
	local p = player:getAccessor()
	local data = player:getData()
	sounds.CowboyShoot2:play(p.attack_speed)
	local bomb = stunBomb:create(player.x + (8 * player.xscale), player.y - 3)
	bomb.xscale = player.xscale
	bomb:set("vx", 3*player.xscale)
		:set("vy", -3)
	bomb:getData().parent = player
end)

-- Transport Mode

local transportMode = Buff.new("Transport Mode")
transportMode.sprite = Sprite.load("transportModeIcon", "Actors/mult/transportMode", 1, 3, 3)


local TransportModeWrapUp = function(player)
	local playerA = player:getAccessor()
	local data = player:getData()
	sounds.transportLoopSound:stop()
	sounds.retool:play()
	playerA.activity = 0
	local anim
	if data.reTooled == 1 then	
		anim = player:getAnimation("shoot3_3_"..SkillToString[data.Loadout["Misc."].obj])
	else	
		anim = player:getAnimation("shoot3_3_"..SkillToString[data.Loadout["Primary"].obj])
	end
	player:survivorActivityState(3, anim, 0.15, true, true)
	playerA.armor = playerA.armor - 200
	data.transportPhase = 2
	return
end

local TransportModeStep = function(player)
	local playerA = player:getAccessor()
	local data = player:getData()
	----------------------------------------
	if not sounds.transportLoopSound:isPlaying() then
		sounds.transportLoopSound:loop()
	end
	----------------------------------------
	local d = objects.dust:findNearest(player.x, player.y)
	if (not d or not player:collidesWith(d, player.x, player.y)) and player:get("free") == 0 then
		local dusty = objects.dust:create(player.x, player.y)
		dusty.xscale = player.xscale
	end
	----------------------------------------
	local nearest = enemies:findNearest(player.x, player.y)
	if nearest and nearest:isValid() then
		if not data.transportHit[nearest] and player:collidesWith(nearest, player.x, player.y) then
			local largeEnemy = false
			local playerSprite = player:getAnimation("idle")
			local enemySprite = nearest:getAnimation("idle")
			if enemySprite then
				local enemySize = (enemySprite.width + enemySprite.height)/2
				local playerSize = (playerSprite.width + playerSprite.height)/2
				if enemySize > playerSize then
					largeEnemy = true
				end
			end
			local dmg = 2.2 * (math.abs(playerA.pHspeed) / 1.3)
			misc.shakeScreen(5)
			sounds.transportHitSound:play(0.9 + math.random() * 0.1, 1)
			if largeEnemy then
				local hit = player:fireBullet(nearest.x, nearest.y, 0, 1, 4*dmg, sprites.sparks1, nil)
				hit:set("specific_target", nearest.id)
				hit:set("stun", 1.5)
				player:set("pVspeed", -3)
				player:removeBuff(transportMode)
				TransportModeWrapUp(player)
				return
			else
				local hit = player:fireBullet(nearest.x, nearest.y, 0, 1, dmg, sprites.sparks1, nil)
				hit:set("specific_target", nearest.id)
				hit:set("knockup", 3)
			end
			data.transportHit[nearest] = true
		end
	end
	----------------------------------------
	playerA.activity = 0
	player:survivorActivityState(3, sprites.shoot3_2, 0.15, true, false)
	if player:getFacingDirection() == 180 then
		playerA.pHspeed = -playerA.pHmax * transportSpeedMultiplier
	else
		playerA.pHspeed = playerA.pHmax * transportSpeedMultiplier
	end
	----------------------------------------
end

transportMode:addCallback("start", function(player)
	local playerA = player:getAccessor()
	local data = player:getData()
	data.transportHit = {}
	playerA.armor = playerA.armor + 200
end)

transportMode:addCallback("step", function(player)
	TransportModeStep(player)
end)

transportMode:addCallback("end", function(player)
	TransportModeWrapUp	(player)
end)


callback.register("onGameEnd", function()
	sounds.transportLoopSound:stop()
end)

local transport = Skill.new()

transport.displayName = "Transport Mode"
transport.description = "Zoom forward, gaining armor and speed. Deals 250% damage to enemies in the way. Deals more damage at higher speeds."
transport.icon = sprites.icons
transport.iconIndex = 6
transport.cooldown = 5*60

transport:setEvent("init", function(player, index)
	local p = player:getAccessor()
	local data = player:getData()
	local anim
	if data.reTooled == 1 then	
		anim = player:getAnimation("shoot3_1_"..SkillToString[data.Loadout["Misc."].obj])
	else	
		anim = player:getAnimation("shoot3_1_"..SkillToString[data.Loadout["Primary"].obj])
	end
	if data.transportPhase == 0 then
		if initActivity(player, index, anim, 0.25, true, true) then
			sounds.transportEnterSound:play(player:get("attack_speed") + math.random() * 0.05)
			return true
		end
	end
	return false 
end)

transport:setEvent(3, function(player, index)
	local p = player:getAccessor()
	local data = player:getData()
	if data.transportPhase == 0 then
		player:applyBuff(transportMode, transportTime)
		data.transportPhase = 1
	end
end)

transport:setEvent("last", function(player, index)
	local data = player:getData()
	if data.transportPhase == 2 then
		data.transportPhase = 0
		return
	end
end)

-- Retool

local retool = Skill.new()

retool.displayName = "Retool"
retool.description = "Switches primary fire between MUL-T's 2 selected primary skills."
retool.icon = sprites.icons
retool.iconIndex = 7
retool.cooldown = 60

local ReToolIntro = function(player, index)
	local playerA = player:getAccessor()
	local data = player:getData()
	local anim
	if data.reTooled == 1 then
		anim = player:getAnimation("shoot4_1_"..SkillToString[data.Loadout["Misc."].obj])
	else
		anim = player:getAnimation("shoot4_1_"..SkillToString[data.Loadout["Primary"].obj])
	end
	if initActivity(player, index, anim, 0.25, false, true) then
		sounds.retool:play(0.9 + math.random() * 0.1)
		data.retooling = true
		return true
	end
	return false
end

local ReToolApply = function(player, index)
	local playerA = player:getAccessor()
	local data = player:getData()
	if data.retooling then
		local anim
		if data.reTooled == 1 then
			anim = player:getAnimation("shoot4_2_"..SkillToString[data.Loadout["Primary"].obj])
			Skill.set(player, 1, data.Loadout["Primary"].obj)
			player.useItem = data.useItemSlot1.item
			player:setAlarm(0, data.useItemSlot1.cooldown or -1)
			data.reTooled = 0
		else
			anim = player:getAnimation("shoot4_2_"..SkillToString[data.Loadout["Misc."].obj])
			Skill.set(player, 1, data.Loadout["Misc."].obj)
			player.useItem = data.useItemSlot2.item
			player:setAlarm(0, data.useItemSlot2.cooldown or -1)
			data.reTooled = 1
		end
		playerA.activity = 0
		initActivity(player, index, anim, 0.25, false, true)
		player.subimage = 1
		data.retooling = false
	end
end

retool:setEvent("init", function(player, index)
	return ReToolIntro(player, index)
end)

retool:setEvent(4, function(player, index)
	local playerA = player:getAccessor()
	local data = player:getData()
	if data.retooling then
		ReToolApply(player, index)
	end
end)

-- Refurbish

local refurbish = Skill.new()

refurbish.displayName = "Refurbish"
refurbish.description = "Switches primary fire between MUL-T's 2 selected primary skills. Boosts the damage of your next attack."
refurbish.icon = sprites.icons
refurbish.iconIndex = 8
refurbish.cooldown = 60

refurbish:setEvent("init", function(player, index)
	return ReToolIntro(player, index)
end)

refurbish:setEvent(4, function(player, index)
	local playerA = player:getAccessor()
	local data = player:getData()
	if data.retooling then
		ReToolApply(player, index)
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
	--------------------
	["idle_nailgun"] = baseSprites.idle_nailgun,
	["idle_rebar"] = baseSprites.idle_rebar,
	["idle_scrap"] = baseSprites.idle_rebar,
	["idle_buzzsaw"] = baseSprites.idle_buzzsaw,
	--------------------
	["walk_nailgun"] = baseSprites.walk_nailgun,
	["walk_rebar"] = baseSprites.walk_rebar,
	["walk_scrap"] = baseSprites.walk_rebar,
	["walk_buzzsaw"] = baseSprites.walk_buzzsaw,
	--------------------
	["jump_nailgun"] = baseSprites.jump_nailgun,
	["jump_rebar"] = baseSprites.jump_rebar,
	["jump_scrap"] = baseSprites.jump_rebar,
	["jump_buzzsaw"] = baseSprites.jump_buzzsaw,
	--------------------
	["climb_nailgun"] = baseSprites.climb_nailgun,
	["climb_rebar"] = baseSprites.climb_rebar,
	["climb_scrap"] = baseSprites.climb_rebar,
	["climb_buzzsaw"] = baseSprites.climb_buzzsaw,
	--------------------
	["death_nailgun"] = baseSprites.death_nailgun,
	["death_rebar"] = baseSprites.death_rebar,
	["death_scrap"] = baseSprites.death_rebar,
	["death_buzzsaw"] = baseSprites.death_buzzsaw,
	--------------------
	["shoot1_nailgun"] = sprites.shoot1_nailgun,
	["shoot1_nailgun_end"] = sprites.shoot1_nailgun_end,
	--------------------
	["shoot1_rebar"] = sprites.shoot1_rebar,
	--------------------
	["shoot2_nailgun"] = sprites.shoot2_nailgun,
	["shoot2_rebar"] = sprites.shoot2_rebar,
	["shoot2_scrap"] = sprites.shoot2_rebar,
	["shoot2_buzzsaw"] = sprites.shoot2_rebar,
	--------------------
	["shoot3_1_nailgun"] = sprites.shoot3_1_nailgun,
	["shoot3_1_rebar"] = sprites.shoot3_1_rebar,
	["shoot3_1_scrap"] = sprites.shoot3_1_rebar,
	["shoot3_1_buzzsaw"] = sprites.shoot3_1_rebar,
	["shoot3_2"] = sprites.shoot3_2,
	["shoot3_3_nailgun"] = sprites.shoot3_3_nailgun,
	["shoot3_3_rebar"] = sprites.shoot3_3_rebar,
	["shoot3_3_scrap"] = sprites.shoot3_3_rebar,
	["shoot3_3_buzzsaw"] = sprites.shoot3_3_rebar,
	---------------------
	["shoot4_1_nailgun"] = sprites.shoot4_1_nailgun,
	["shoot4_1_rebar"] = sprites.shoot4_1_rebar,
	["shoot4_1_scrap"] = sprites.shoot4_1_rebar,
	["shoot4_1_buzzsaw"] = sprites.shoot4_1_rebar,
	["shoot4_2_nailgun"] = sprites.shoot4_2_nailgun,
	["shoot4_2_rebar"] = sprites.shoot4_2_rebar,
	["shoot4_2_scrap"] = sprites.shoot4_2_rebar,
	["shoot4_2_buzzsaw"] = sprites.shoot4_2_rebar,
}

local s_janitor = Skill.new()

s_janitor.displayName = "Janitor"
s_janitor.description = ""
s_janitor.icon = sprites.palettes
s_janitor.iconIndex = 2
s_janitor.cooldown = -1


--------------
-- Survivor --
--------------


local toolbot = Survivor.new("MUL-T")

local loadout = Loadout.new()
loadout.survivor = toolbot
loadout.description = [[&y&MUL-T&!& is an aggressive survivor who has the tools necessary for any job! 
&y&Auto-Nailgun&!& has an &y&extremely high damage output&!&, but has a &r&short range&!&. 
&y&Transport Mode&!& can be both a great tool to &y&run down small groups of monsters&!&.
Constantly &y&Retooling&!& can help eliminate &b&fragile enemies&!& with &y&Rebar Puncher&!& while
keeping &b&damage output high&!& with &y&Auto-Nailgun&!&.]]

local misc = loadout:addSlot("Misc.")
misc.displayOrder = loadout:getSlot("Primary").displayOrder+0.1

loadout:addSkill("Primary", nailgun, {
	loadoutDescription = [[Rapidly fire nails for &y&60% damage.&!& Fires &y&six&!& nails 
when initially pressed.]]
})
loadout:addSkill("Primary", rebar, {
	loadoutDescription = [[Fire a piercing rebar that deals &y&300% damage&!&.]]
})
loadout:addSkill("Primary", Loadout.PresetSkills.Unfinished)
loadout:addSkill("Primary", Loadout.PresetSkills.Unfinished)

--loadout:addSkill("Primary", scrap, {
--	loadoutDescription = [[Fire an arcing hunk that explodes for &y&360% damage&!&. &b&Hold up to 4&!&.]]
--})
--loadout:addSkill("Primary", buzzsaw, {
--	loadoutDescription = [[Constantly damages nearby enemies for &y&1000% damage per second&!&.]]
--})
loadout:setCurrentSkill("Primary", nailgun)
-------------------------------------------
loadout:addSkill("Misc.", nailgun, {
	loadoutDescription = [[Rapidly fire nails for &y&60% damage.&!& Fires &y&six&!& nails 
when initially pressed.]]
})
loadout:addSkill("Misc.", rebar, {
	loadoutDescription = [[Fire a piercing rebar that deals &y&300% damage&!&.]]
})
loadout:addSkill("Misc.", Loadout.PresetSkills.Unfinished)
loadout:addSkill("Misc.", Loadout.PresetSkills.Unfinished)
--loadout:addSkill("Misc.", scrap, {
--	loadoutDescription = [[Fire an arcing hunk that explodes for &y&360% damage&!&. &b&Hold up to 4&!&.]]
--})
--loadout:addSkill("Misc.", buzzsaw, {
--	loadoutDescription = [[Constantly damages nearby enemies for &y&1000% damage per second&!&.]]
--})
loadout:setCurrentSkill("Misc.", rebar)
--------------------------------------------
loadout:addSkill("Secondary", blastCanister, {
	loadoutDescription = [[Launch a &y&stun&!& canister for &y&220% damage&!&. Drops 
&y&stun bomblets&!& for &y&5x44% damage&!&.]]
})
loadout:addSkill("Utility", transport,{
	loadoutDescription = [[Zoom forward, gaining &b&armor&!& and &b&speed&!&. Deals &y&250% damage&!& 
to enemies in the way. Deals more damage at higher speeds.]]
})
loadout:addSkill("Special", retool,{
	loadoutDescription = [[Switches his primary fire between MUL-T's 2 selected primary skills.]],
	--upgrade = loadout:addSkill("Special", refurbish, {hidden = true})
}) 


loadout:addSkin(s_default, defaultSprites)
loadout:addSkin(s_janitor, defaultSprites)


toolbot.titleSprite = baseSprites.walk_nailgun
toolbot.loadoutColor = Color.fromRGB(200,100,0)
toolbot.loadoutSprite = sprites.loadout
toolbot.loadoutWide = true
toolbot.endingQuote = "..and so it left, aiming to find a new purpose."
if math.random(1000) == 0 then
	toolbot.endingQuote = "..and so it left, having finally become a real boy."
end

toolbot:addCallback("init", function(player)
	local playerA = player:getAccessor()
	local data = player:getData()
	player:setAnimations(baseSprites)
	player:survivorSetInitialStats(200, 11, 0.01)
	--data.primaryA = loadout:getCurrent()
	data.Loadout = {
		["Primary"] = loadout:getSlot("Primary").current,
		["Misc."] = loadout:getSlot("Misc.").current,
	}
	data.reTooled = 0
	data.retooling = false
	data.bulletToFire = 1
	data.lastSubimage = 0
	data.nailgun_phase = 0
	data.transportPhase = 0
	data.useItemSlot1 = {item = nil, cooldown = 0}
	data.useItemSlot2 = {item = nil, cooldown = 0}
	playerA.endingTransportMode = 0
end)

toolbot:addCallback("levelUp", function(player)
	player:survivorLevelUpStats(60, 6, 0.002, 5)
end)

toolbot:addCallback("scepter", function(player)
	Loadout.Upgrade(loadout, player, "Special")
end)

registercallback("onPlayerStep", function(player)
	local playerA = player:getAccessor()
	local data = player:getData()
	if player:getSurvivor() == toolbot then
		if Skill.get(player, 1) == nailgun then
			nailgunInputStep(player)
			nailgunStep(player)
		end
		-- Manage Sprites --
		local skillA = SkillToString[loadout:getSlot("Primary").current.obj] --MULT's first skill slot
		local skillB = SkillToString[loadout:getSlot("Misc.").current.obj] --MULT's second skill slot
		if data.reTooled == 1 then
			player:setAnimation("idle", player:getAnimation("idle_"..skillB))
			player:setAnimation("walk", player:getAnimation("walk_"..skillB))
			player:setAnimation("jump", player:getAnimation("jump_"..skillB))
			player:setAnimation("climb", player:getAnimation("climb_"..skillB))
			player:setAnimation("death", player:getAnimation("death_"..skillB))
		else
			player:setAnimation("idle", player:getAnimation("idle_"..skillA))
			player:setAnimation("walk", player:getAnimation("walk_"..skillA))
			player:setAnimation("jump", player:getAnimation("jump_"..skillA))
			player:setAnimation("climb", player:getAnimation("climb_"..skillA))
			player:setAnimation("death", player:getAnimation("death_"..skillA))
		end
		----------------
		if player:isValid() then
			if player.useItem then
				if data.reTooled == 1 then
					if data.useItemSlot2 then
						data.useItemSlot2.item = player.useItem
						data.useItemSlot2.cooldown = player:getAlarm(0)
						if data.useItemSlot1.cooldown > -1 then
							data.useItemSlot1.cooldown = data.useItemSlot1.cooldown - 1
						end
					else
						data.useItemSlot2 = {item = nil, cooldown = 0}
					end
				else
					if data.useItemSlot1 then
						data.useItemSlot1.item = player.useItem
						data.useItemSlot1.cooldown = player:getAlarm(0)
						if data.useItemSlot2.cooldown > -1 then
							data.useItemSlot2.cooldown = data.useItemSlot2.cooldown - 1
						end
					else
						data.useItemSlot1 = {item = nil, cooldown = 0}
					end
				end
			end
		end
	end
end)

registercallback("onUseItemUse", function(player)
	if player:getSurvivor() == toolbot then
		if player:isValid() then
			local playerA = player:getAccessor()
			local data = player:getData()
			if player.useItem then
				if data.reTooled == 1 then
					data.useItemSlot2.cooldown = player:getAlarm(0)
				else
					data.useItemSlot1.cooldown = player:getAlarm(0)
				end
			end
		end
	end
end)

registercallback("onPlayerHUDDraw", function(player, hudx, hudy)
	if player:getSurvivor() == toolbot then
		if player:isValid() then
			local playerA = player:getAccessor()
			local data = player:getData()
			local dataSlot
			if data.reTooled == 1 then
				dataSlot = data.useItemSlot1
			else
				dataSlot = data.useItemSlot2
			end
			if dataSlot and dataSlot.item then
				if dataSlot.cooldown > -1 then
					graphics.drawImage{
						image = dataSlot.item.sprite,
						subimage = 2,
						x = hudx + 140, 
						y = hudy + 4,
						scale = 0.75,
						alpha = 0.25
						}
					graphics.print(math.round(dataSlot.cooldown/60), hudx + 140, hudy + 9, graphics.FONT_LARGE, graphics.ALIGN_MIDDLE, graphics.ALIGN_CENTER)
				else
					graphics.drawImage{
						image = dataSlot.item.sprite,
						subimage = 2,
						x = hudx + 140, 
						y = hudy + 4,
						alpha = 0.5
					}
				end
			end
		end
	end
end)

Loadout.RegisterSurvivorID(toolbot)


-------------------------------------------------------------------------------

local verified = Achievement.new("Verified")
verified.requirement = 5
verified.deathReset = false
verified.description = "Complete the first Teleporter event five times."
verified.highscoreText = "\'MUL-T\' Unlocked"
verified:assignUnlockable(toolbot)

local teleporter = Object.find("Teleporter", "vanilla")
callback.register("onStep", function()
	for _, tpInst in ipairs(teleporter:findAll()) do
		if misc.director and misc.director:get("stages_passed") <= 0 then	
			local data = misc.director:getData()
			if tpInst:get("time") == tpInst:get("maxtime") and not data.verify then
				verified:increment(1)
				data.verify = true
			end
		end
	end
end)


return toolbot
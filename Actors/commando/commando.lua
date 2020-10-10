--require("Misc.loadout")
--require("Libraries.skill.main")

---------------
-- Resources --
---------------

local baseSprites = {
	idle = Sprite.find("GManIdle", "vanilla"),
	walk = Sprite.find("GManWalk", "vanilla"),
	jump = Sprite.find("GManJump", "vanilla"),
	climb = Sprite.find("GManClimb", "vanilla"),
	death = Sprite.find("GManDeath", "vanilla"),
	--palette = Sprite.load("CommandoPal", "Actors/commando/palette", 1, 0, 0)
}

local sprites = {
	shoot1 = Sprite.find("GManShoot1", "vanilla"),
	shoot2 = Sprite.find("GManShoot2", "vanilla"),
	shoot2b = Sprite.load("GManShoot2_alt", "Actors/commando/altshoot2", 7, 6, 5),
	shoot3 = Sprite.find("GManShoot3", "vanilla"),
	shoot4_1 = Sprite.find("GManShoot4_1", "vanilla"),
	shoot4_2 = Sprite.find("GManShoot4_2", "vanilla"),
	shoot4b =  Sprite.load("GManShoot4_alt", "Actors/commando/altshoot4", 5, 10, 5),
	shoot5_1 = Sprite.find("GManShoot5_1", "vanilla"),
	shoot5_2 = Sprite.find("GManShoot5_2", "vanilla"),
	icons = Sprite.load("CommandoSkills", "Actors/commando/skills", 8, 0, 0),
	palettes = Sprite.load("CommandoPalettes", "Actors/commando/palettes", 2, 0, 0),
	loadout = Sprite.find("SelectCharGMan", "vanilla"),
	sparks1 = Sprite.find("Sparks1", "vanilla"),
	sparks2 = Sprite.find("Sparks2", "vanilla"),
	grenade = Sprite.load("GManNade", "Actors/commando/grenade", 1, 2.5, 3.5),
	nadeMask = Sprite.load("GManNadeMask", "Actors/commando/grenadeMask", 1, 2.5, 3.5),
	detonate = Sprite.find("EfExplosive", "vanilla")
}

local sounds = {
	bullet1 = Sound.find("bullet1", "vanilla"),
	bullet2 = Sound.find("bullet2", "vanilla"),
	bullet3 = Sound.find("bullet3", "vanilla"),
	guardDeath = Sound.find("GuardDeath", "vanilla"),
	detonate = Sound.find("ExplosiveShot", "vanilla"),
	bounce = Sound.find("Click", "vanilla")
}

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

-- Double Tap

local doubleTap = Skill.new()

doubleTap.displayName = "Double Tap"
doubleTap.description = "Fire your gun twice for 2x60% damage."
doubleTap.icon = sprites.icons
doubleTap.iconIndex = 1
doubleTap.cooldown = 22

doubleTap:setEvent("init", function(player, index)
	if initActivity(player, index, player:getAnimation("shoot1"), 0.25, true, true) then
		player:setAlarm(index + 1, doubleTap.cooldown / player:get("attack_speed"))
		return true
	end
	return false
end)

local function shootDoubleTap(player, climb)
	for i = 0, player:get("sp") do
		local bullet = player:fireBullet(player.x, player.y, player:getFacingDirection(), 700, 0.6, sprites.sparks1)
		bullet:set("climb", climb or 0 + i * 8)
	end
	sounds.bullet1:play(0.85 + math.random() * 0.15)
end

doubleTap:setEvent(1, function(player)
	if player:survivorFireHeavenCracker(1) then return end
	shootDoubleTap(player)
end)

doubleTap:setEvent(3, function(player)
	shootDoubleTap(player, 9)
end)

-- Full Metal Jacket

local fmj = Skill.new()

fmj.displayName = "Full Metal Jacket"
fmj.description = "Shoot a bullet that passes through enemies for 230% damage, knocking them back."
fmj.icon = sprites.icons
fmj.iconIndex = 2
fmj.cooldown = 3 * 60

fmj:setEvent("init", function(player, index)
	return initActivity(player, index, player:getAnimation("shoot2"), 0.25, true, true)
end)

fmj:setEvent(1, function(player)
	for i = 0, player:get("sp") do
		local bullet = player:fireBullet(player.x, player.y, player:getFacingDirection(), 700, 2.3, sprites.sparks2, DAMAGER_BULLET_PIERCE)
		bullet:set("climb", i * 8)
		bullet:set("knockback", bullet:get("knockback") + 6)
	end
	misc.shakeScreen(4)
	sounds.bullet2:play()
end)

-- Phase Round

local phaseSprites = {
	sprite = Sprite.load("PhaseRound", "Actors/commando/phaseRound", 3, 10, 6),
	mask = Sprite.load("PhaseRoundM", "Actors/commando/phaseMask", 1, 10, 6),
}

local phaseProj = Object.new("phaseProjectile")
phaseProj.sprite = phaseSprites.sprite
local actors = ParentObject.find("actors", "vanilla")

phaseProj:addCallback("create", function(self)
	local data = self:getData()
	self.mask = phaseSprites.sprite
	self.spriteSpeed = 0.2
	data.hit = {}
	data.parent = nil
	data.vx = 4
	data.team = "player"
	data.damage = 12
	data.life = 5*60
end)
phaseProj:addCallback("step", function(self)
	local data = self:getData()
	data.life = data.life - 1
	self.x = self.x + (data.vx * self.xscale)
	local nearest = actors:findNearest(self.x, self.y)
	if nearest then
		if nearest:isValid() then
			if nearest:get("team") ~= data.team and not data.hit[nearest] then
				if data.parent then
					local bullet = data.parent:fireBullet(self.x, self.y, 0, 1, 2.3, sprites.sparks2)
					bullet:set("specific_target", nearest.id)
				else
					local bullet = misc.fireBullet(self.x, self.y, 0, 1, 2.3 * data.damage, data.team, sprites.sparks2)
					bullet:set("specific_target", nearest.id)
				end
				data.hit[nearest] = true
			end
		end
	end
	if data.life <= -1 then
		self:destroy()
	end
end)

local pRound = Skill.new()

pRound.displayName = "Phase Round"
pRound.description = "Fire a bullet that pierces both enemies and walls in a line for 230% damage."
pRound.icon = sprites.icons
pRound.iconIndex = 6
pRound.cooldown = 3 * 60

pRound:setEvent("init", function(player, index)
	return initActivity(player, index, player:getAnimation("shoot2"), 0.25, true, true)
end)

pRound:setEvent(1, function(player)
	for i = 0, player:get("sp") do
		local bullet = phaseProj:create(player.x, player.y)
		bullet:getData().parent = player
		bullet.xscale = player.xscale
	end
	sounds.guardDeath:play()
end)

-- Phase Blast

local pBlast = Skill.new()

pBlast.displayName = "Phase Blast"
pBlast.description = "Fire two close range blasts that deal 8x200% damage total."
pBlast.icon = sprites.icons
pBlast.iconIndex = 7
pBlast.cooldown = 3 * 60

pBlast:setEvent("init", function(player, index)
	return initActivity(player, index, player:getAnimation("shoot2b"), 0.25, true, true)
end)

local function FirePhaseBlast(player)
	for i = 0, 4 + player:get("sp") do
		local bullet = player:fireBullet(player.x, player.y, player:getFacingDirection() + math.random(-10, 10), 300, 2, sprites.sparks2)
		bullet:set("climb", i * 8)
	end
	misc.shakeScreen(1)
	sounds.guardDeath:play()
end

pBlast:setEvent(1, function(player)
	FirePhaseBlast(player)
end)

pBlast:setEvent(3, function(player)
	FirePhaseBlast(player)
end)

-- Tactical Roll

local roll = Skill.new()

roll.displayName = "Tactical Dive"
roll.description = "Rolls forward a small distance."
roll.icon = sprites.icons
roll.iconIndex = 3
roll.cooldown = 4 * 60

roll:setEvent("init", function(player, index)
	return initActivity(player, index, player:getAnimation("shoot3"), 0.25, false, false)
end)

roll:setEvent("all", function(player)
	local p = player:getAccessor()
	p.invincible = math.max(p.invincible, 5)
	if p.pHspeed ~= 0 then
		p.pHspeed = p.pHmax * 2 * player.xscale
	else
		p.pHspeed = 2.6 * player.xscale
	end
end)

roll:setEvent("last", function(player)
	if player:get("invincible") <= 5 then
		player:set("invincible", 0)
	end
	player:set("pHspeed", 0)
end)

-- Suppressive Fire

local function fireInit(player, index, sprite1, sprite2, speed)
	if util.checkLine(player, 0, 300) and util.checkLine(player, 180, 300) then
		if initActivity(player, index, sprite1, speed, true, true) then
			player:set("activity_var1", 0)
			return true
		end 
		return false
	else
		if initActivity(player, index, sprite2, speed, true, true) then
			player:set("activity_var1", -1)
			return true
		end 
		return false
	end
end

local function suppShoot(player, scepter)
	local var = player:get("activity_var1")
	
	for i = 0, player:get("sp") do
		local bullet = player:fireBullet(player.x, player.y, player:getFacingDirection() + 180 * math.max(var, 0), 700, 0.6, sprites.sparks1)
		bullet:set("stun", 0.5)
		if var == -1 then
			bullet:set("climb", i * 8)
		else
			bullet:set("climb", 5 * (math.floor(player.subimage) - 1) + i * 5)
			player:set("activity_var1", (var + 1) % 2)
		end
		if scepter then
			sounds.guardDeath:play(1.8 + math.random() * 0.2, 0.25)
		end
	end
	sounds.bullet3:play(0.85 + math.random() * 0.15)
end

local suppFire = Skill.new()

suppFire.displayName = "Suppressive Fire"
suppFire.description = "Fires rapidly, stunning and hitting nearby enemies for 6x60% damage total."
suppFire.icon = sprites.icons
suppFire.iconIndex = 4
suppFire.cooldown = 5 * 60

suppFire:setEvent("init", function(player, index) 
	if fireInit(player, index, player:getAnimation("shoot4_1"), player:getAnimation("shoot4_2"), 0.3) then
		player:activateSkillCooldown(index)
		return true
	end 
	return false
end)

for frame = 1, 11, 2 do
	suppFire:setEvent(frame, function(player) suppShoot(player, false) end)
end

-- Suppressive Barrage

local suppBarr = Skill.new()

suppBarr.displayName = "Suppressive Barrage"
suppBarr.description = "Fires rapidly, stunning and hitting nearby enemies for 10x60% damage total."
suppBarr.icon = sprites.icons
suppBarr.iconIndex = 5
suppBarr.cooldown = 5 * 60

suppBarr:setEvent("init", function(player, index) 
	if fireInit(player, index, player:getAnimation("shoot5_1"), player:getAnimation("shoot5_2"), 0.4) then
		player:activateSkillCooldown(index)
		return true
	end 
	return false
end)

for frame = 1, 19, 2 do
	suppBarr:setEvent(frame, function(player) suppShoot(player, true) end)
end

-- Frag Grenade

local grenade = Skill.new()

--local grenadeSound = Sound.find("WormExplosion", "vanilla")

local fragGrenade = Object.new("Frag Grenade")
fragGrenade.sprite = sprites.grenade


fragGrenade:addCallback("create", function(self)
	self.spriteSpeed = 0.25
	self.mask = sprites.nadeMask
	self:set("vx", 0)
	self:set("vy", 0)
	self:set("ay", 0.25)
	self:set("rotate", 1)
	self:set("life", 1*60)
	self:set("bounce", 1)
end)

fragGrenade:addCallback("step", function(self)
	if self:get("life") <= 0 then
		if math.round(self.subimage) >= sprites.detonate.frames then
			self:destroy()
		end
	else
		self.x = self.x + (self:get("vx") or 0)
		self.y = self.y + (self:get("vy") or 0)	
		self:set("vx", (self:get("vx") or 0) + (self:get("ax") or 0))
		self:set("vy", (self:get("vy") or 0) + (self:get("ay") or 0))
		if self:get("vx") > 0 then self:set("direction", 1)
		elseif self:get("vx") < 0 then self:set("direction", -1)
		else self:set("direction", 0) end
		if self:get("rotate") ~= nil then
			self.yscale = 1
			self.xscale = 1
			local _pvx = self:get("vx") or 0
			local _pvy = -(self:get("vy") or 0)
			local _angle = math.atan(_pvy/_pvx)*(180/math.pi)
			if _pvx < 0 then _angle = _angle + 180 end
			self.angle = (self:get("rotate") + _angle)%360
		end
		if self:collidesMap(self.x,self.y) then
			local _vx = (self:get("vx") or 0)
			local _vy = (self:get("vy") or 0)
			self.x = self.x - _vx
			self.y = self.y - _vy
			local _vcollision = self:collidesMap(self.x, self.y + _vy)
			local _hcollision = self:collidesMap(self.x + _vx, self.y)
			if (not _hcollision) and (not _vcollision) then
				self:set("vx", - _vx * self:get("bounce"))
				self:set("vy", - _vy * self:get("bounce"))
			elseif _vcollision then
				self:set("vy", - _vy * self:get("bounce"))
			elseif _hcollision then
				self:set("vx", - _vx * self:get("bounce"))
			end
			misc.fireExplosion(self.x, self.y, 0.1, 0.1, 0, "player", nil, nil)
			sounds.bounce:play()
		end
		self:set("life", self:get("life") - 1)
		if self:get("life") <= 0 then
			self.sprite = sprites.detonate
			self.angle = 0
			sounds.detonate:play(0.8 + math.random() * 0.8)
			misc.shakeScreen(5)
			misc.fireExplosion(self.x, self.y, 1.5, 2, 1.75 * (self:get("damage") or 12), self:get("team") or "player", nil, nil)
			misc.fireExplosion(self.x, self.y, 0.3, 1, 3 * (1.75 * (self:get("damage") or 12)), self:get("team") or "player", nil, nil)
			self.subimage = 1
		end
	end
end)

grenade.displayName = "Frag Grenade"
grenade.description = "Throw a grenade that explodes for 175% damage. Deals 4x damage in the center of the explosion. Can hold up to 2."
grenade.icon = sprites.icons
grenade.iconIndex = 8
grenade.cooldown = 5 * 60

grenade:setEvent("init", function(player, index)
	return initActivity(player, index, player:getAnimation("shoot4b"), 0.25, true, true)
end)

grenade:setEvent(4, function(player)
	local nade = fragGrenade:create(player.x, player.y)
	nade:set("damage", player:get("damage"))
	nade:set("team", player:get("team"))
	nade:set("vy", -1)
	nade:set("vx", (player:get("pHmax") * 2) * player.xscale)
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
	["shoot1"] = sprites.shoot1,
	["shoot2"] = sprites.shoot2,
	["shoot2b"] = sprites.shoot2b,
	["shoot3"] = sprites.shoot3,
	["shoot4_1"] = sprites.shoot4_1,
	["shoot4_2"] = sprites.shoot4_2,
	["shoot4b"] = sprites.shoot4b,
	["shoot5_1"] = sprites.shoot5_1,
	["shoot5_2"] = sprites.shoot5_2,
}

local s_hornet = Skill.new()

s_hornet.displayName = "Hornet"
s_hornet.description = ""
s_hornet.icon = sprites.palettes
s_hornet.iconIndex = 2
s_hornet.cooldown = -1

local hornetSprites = {
	["loadout"] = Sprite.load("SelectCommando_Skin1", "Actors/commando/hornet/select", 13, 2, 0),
	["idle"] = Sprite.load("CommandoIdleSkin1", "Actors/commando/hornet/idle", baseSprites.idle.frames, baseSprites.idle.xorigin, baseSprites.idle.yorigin),
	["walk"] = Sprite.load("CommandoWalkSkin1", "Actors/commando/hornet/walk", baseSprites.walk.frames, baseSprites.walk.xorigin, baseSprites.walk.yorigin),
	["jump"] = Sprite.load("CommandoJumpSkin1", "Actors/commando/hornet/jump", baseSprites.jump.frames, baseSprites.jump.xorigin, baseSprites.jump.yorigin),
	["climb"] =Sprite.load("CommandoClimbSkin1", "Actors/commando/hornet/climb", baseSprites.climb.frames, baseSprites.climb.xorigin, baseSprites.climb.yorigin),
	["death"] = Sprite.load("CommandoDeathSkin1", "Actors/commando/hornet/death", baseSprites.death.frames, baseSprites.death.xorigin, baseSprites.death.yorigin),
	["shoot1"] = Sprite.load("CommandoShoot1Skin1", "Actors/commando/hornet/shoot1", sprites.shoot1.frames, sprites.shoot1.xorigin, sprites.shoot1.yorigin),
	["shoot2"] = Sprite.load("CommandoShoot2Skin1", "Actors/commando/hornet/shoot2", sprites.shoot2.frames, sprites.shoot2.xorigin, sprites.shoot2.yorigin),
	["shoot2b"] = Sprite.load("CommandoShoot2bSkin1", "Actors/commando/hornet/altshoot2", sprites.shoot2b.frames, sprites.shoot2b.xorigin, sprites.shoot2b.yorigin),
	["shoot3"] = Sprite.load("CommandoShoot3Skin1", "Actors/commando/hornet/shoot3", sprites.shoot3.frames, sprites.shoot3.xorigin, sprites.shoot3.yorigin),
	["shoot4_1"] = Sprite.load("CommandoShoot4_1Skin1", "Actors/commando/hornet/shoot4_1", sprites.shoot4_1.frames, sprites.shoot4_1.xorigin, sprites.shoot4_1.yorigin),
	["shoot4_2"] = Sprite.load("CommandoShoot4_2Skin2", "Actors/commando/hornet/shoot4_2", sprites.shoot4_2.frames, sprites.shoot4_2.xorigin, sprites.shoot4_2.yorigin),
	["shoot4b"] = Sprite.load("CommandoShoot4bSkin1", "Actors/commando/hornet/altshoot4", sprites.shoot4b.frames, sprites.shoot4b.xorigin, sprites.shoot4b.yorigin),
	["shoot5_1"] = Sprite.load("CommandoShoot5_1Skin1", "Actors/commando/hornet/shoot5_1", sprites.shoot5_1.frames, sprites.shoot5_1.xorigin, sprites.shoot5_1.yorigin),
	["shoot5_2"] = Sprite.load("CommandoShoot5_2Skin2", "Actors/commando/hornet/shoot5_2", sprites.shoot5_2.frames, sprites.shoot5_2.xorigin, sprites.shoot5_2.yorigin),
}

--------------
-- Survivor --
--------------

local commando = Survivor.new("Commando 2.0")
local vanilla = Survivor.find("Commando")

local loadout = Loadout.new()
loadout.survivor = commando
loadout.description = [[The &y&Commando&!& is characterized by long range and mobility.
Effective use of his &y&Tactical Dive&!& will grant increased survivability,
while &y&suppressive fire&!& deals massive damage.
&y&FMJ&!& can then be used to dispose of large mobs.]]

loadout:addSkill("Primary", doubleTap, {
	loadoutDescription = [[Shoot twice for &y&2x60% damage.&!&]]
})
loadout:addSkill("Secondary", fmj, {
	loadoutDescription = [[Shoot &y&through enemies&!& for &y&230% damage,
knocking them back.&!&]]
})
loadout:addSkill("Secondary", pRound,{
	loadoutDescription = [[Fire a bullet that pierces &y&both enemies and walls&!& 
in a line for &y&230% damage&!&.]]
})
loadout:addSkill("Secondary", pBlast,{
	loadoutDescription = [[Fire two close range blasts for &y&8x200% damage total&!&.]],
	locked = true,
	unlockText = "Commando: land the killing blow on an Overloading Magma Worm."
})
loadout:addSkill("Utility", roll,{
	loadoutDescription = [[&y&Roll forward&!& a small distance.
You &b&cannot be hit&!& while rolling.]]
})
loadout:addSkill("Special", suppFire,{
	loadoutDescription = [[Fire rapidly, &y&stunning&!& and hitting nearby enemies
for &y&6x60% damage&!&.]],
	upgrade = loadout:addSkill("Special", suppBarr, {hidden = true}) 
}) 
loadout:addSkill("Special", grenade,{
	loadoutDescription = [[Throw a grenade that explodes for &y&175% damage&!&. Deals &b&4x 
&b&damage&!& in the center of the explosion. Can hold &g&up to 2.&!&]],
	locked = true,
	apply = function(player)
		Ability.AddCharge(player, "v", 1, true)
	end,
	remove = function(player, hardRemove)
		Ability.Disable(player, "v")
	end,
	unlockText = "Commando: clear 20 stages without picking up any Lunar items."
})
loadout:addSkin(s_default, defaultSprites)
loadout:addSkin(s_hornet, hornetSprites, {
	locked = true,
	unlockText = "Commando: Obliterate yourself at the Obelisk on Monsoon difficulty."
})

commando.titleSprite = baseSprites.walk
commando.loadoutColor = Color.fromRGB(193, 128, 62)
commando.loadoutSprite = sprites.loadout
commando.endingQuote = "..and so he left, with everything but his humanity."

commando:addCallback("init", function(player)
	player:setAnimations(baseSprites)
	player:survivorSetInitialStats(110, 12, 0.01)
end)

commando:addCallback("levelUp", function(player)
	player:survivorLevelUpStats(32, 3, 0.002, 2)
end)

commando:addCallback("scepter", function(player)
	Loadout.Upgrade(loadout, player, "Special")
end)

Loadout.RegisterSurvivorID(commando)

---------------------------------

local hornetUnlock = Achievement.new("unlock_commando_skin1")
hornetUnlock.requirement = 1
hornetUnlock.sprite = MakeAchievementIcon(sprites.palettes, 2)
hornetUnlock.unlockText = "New skin: \'Hornet\' unlocked."
hornetUnlock.highscoreText = "Commando: \'Hornet\' unlocked"
hornetUnlock.description = "Commando: Obliterate yourself at the Obelisk on Monsoon difficulty."
hornetUnlock.deathReset = false
hornetUnlock:addCallback("onComplete", function()
	loadout:getSkillEntry(s_hornet).locked = false
	Loadout.Save(loadout)
end)

return commando
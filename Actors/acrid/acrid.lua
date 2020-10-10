--require("Misc.loadout")
--require("Libraries.skill.main")

---------------
-- Resources --
---------------

local baseSprites = {
	idle = Sprite.find("Feral2Idle", "vanilla"),
	walk = Sprite.find("Feral2Walk", "vanilla"),
	jump = Sprite.find("Feral2Jump", "vanilla"),
	climb = Sprite.find("Feral2Climb", "vanilla"),
	death = Sprite.find("Feral2Death", "vanilla"),
	--palette = Sprite.load("CommandoPal", "Actors/commando/palette", 1, 0, 0)
}

local sprites = {
	shoot1_1 = Sprite.find("Feral2Shoot1_1", "vanilla"),
	shoot1_2 = Sprite.find("Feral2Shoot1_2", "vanilla"),
	shoot2 = Sprite.find("Feral2Shoot2", "vanilla"),
	icons = Sprite.load("AcridSkills", "Actors/commando/skills", 8, 0, 0),
	palettes = Sprite.load("AcridPalettes", "Actors/commando/palettes", 2, 0, 0),
	loadout = Sprite.find("SelectFeral", "vanilla"),
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

local festeringWounds = Skill.new()

festeringWounds.displayName = "Festering Wounds"
festeringWounds.description = "Maul an enemy for 120% damage. The target is poisoned for 24% damage per second."
festeringWounds.icon = sprites.icons
festeringWounds.iconIndex = 1
festeringWounds.cooldown = 22

-- Full Metal Jacket

local neurotoxin = Skill.new()

neurotoxin.displayName = "Neurotoxin"
neurotoxin.description = "Spit toxic bile for 220% damage, stunning enemies in a line for 1 second."
neurotoxin.icon = sprites.icons
neurotoxin.iconIndex = 2
neurotoxin.cooldown = 2 * 60

-- Tactical Roll

local spreadSludge = Skill.new()

spreadSludge.displayName = "Caustic Sludge"
spreadSludge.description = "Secrete poisonous sludge for 2 seconds. Speeds up allies, while slowing and hurting enemies for 90% damage."
spreadSludge.icon = sprites.icons
spreadSludge.iconIndex = 3
spreadSludge.cooldown = 17 * 60

-- Suppressive Fire

local epidemic = Skill.new()

epidemic.displayName = "Epidemic"
epidemic.description = "Release a deadly disease, poisoning enemies for 100% per second. The contagion spreads to two targets after 1 second."
epidemic.icon = sprites.icons
epidemic.iconIndex = 4
epidemic.cooldown = 11 * 60

-- Pandemic

local pandemic = Skill.new()

pandemic.displayName = "Pandemic"
pandemic.description = "Release a deadly disease, poisoning enemies for 100% per second. The contagion spreads to two targets after 1 second. If an enemy is killed by Pandemic, you are healed."
pandemic.icon = sprites.icons
pandemic.iconIndex = 4
pandemic.cooldown = 11 * 60

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

local s_albino = Skill.new()

s_albino.displayName = "Albino"
s_albino.description = ""
s_albino.icon = sprites.palettes
s_albino.iconIndex = 2
s_albino.cooldown = -1

--[[local albinoSprites = {
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
}]]

--------------
-- Survivor --
--------------

local acrid = Survivor.new("Acrid 2.0")
local vanilla = Survivor.find("Acrid")

local loadout = Loadout.new()
loadout.survivor = acrid
loadout.description = [[&y&Acrid&!& deals &y&huge amount of damage&!& after &y&stacking poisons&!& from his
&y&Festering Wounds, Caustic Sludge, and Epidemic&!&. 
Try to &y&stun targets inside your Caustic Sludge&!& for maximum damage. 
Remember that you can fight at &y&both melee and range!&!&]]

loadout:addSkill("Primary", festeringWounds, {
	loadoutDescription = [[Shoot twice for &y&2x60% damage.&!&]]
})
loadout:addSkill("Secondary", neurotoxin, {
	loadoutDescription = [[Shoot &y&through enemies&!& for &y&230% damage,
knocking them back.&!&]]
})
loadout:addSkill("Utility", spreadSludge,{
	loadoutDescription = [[&y&Roll forward&!& a small distance.
You &b&cannot be hit&!& while rolling.]]
})
loadout:addSkill("Special", epidemic,{
	loadoutDescription = [[Fire rapidly, &y&stunning&!& and hitting nearby enemies
for &y&6x60% damage&!&.]],
	upgrade = loadout:addSkill("Special", epidemic, {hidden = true}) 
}) 
loadout:addSkin(s_default, defaultSprites)
loadout:addSkin(s_albino, defaultSprites, {
	locked = true,
	unlockText = "Acrid: Obliterate yourself at the Obelisk on Monsoon difficulty."
})

acrid.titleSprite = baseSprites.walk
acrid.loadoutColor = Color.fromRGB(201, 242, 77)
acrid.loadoutSprite = sprites.loadout
acrid.endingQuote = "..and so it left, with a new hunger: to be left alone."

acrid:addCallback("init", function(player)
	player:setAnimations(baseSprites)
	player:survivorSetInitialStats(114, 12, 0.01)
	player:set("armor", 15)
	player:set("pHmax", 1.4)
	player:set("pVmax", 3)
end)

acrid:addCallback("levelUp", function(player)
	player:survivorLevelUpStats(50, 3, 0.03, 2)
end)

acrid:addCallback("scepter", function(player)
	Loadout.Upgrade(loadout, player, "Special")
end)

Loadout.RegisterSurvivorID(acrid)

---------------------------------

local albinoUnlock = Achievement.new("unlock_acrid_skin1")
albinoUnlock.requirement = 1
albinoUnlock.sprite = MakeAchievementIcon(sprites.palettes, 2)
albinoUnlock.unlockText = "New skin: \'Albino\' unlocked."
albinoUnlock.highscoreText = "Acrid: \'Albino\' unlocked"
albinoUnlock.description = "Acrid: Obliterate yourself at the Obelisk on Monsoon difficulty."
albinoUnlock.deathReset = false
albinoUnlock:addCallback("onComplete", function()
	loadout:getSkillEntry(s_albino).locked = false
	Loadout.Save(loadout)
end)


return acrid
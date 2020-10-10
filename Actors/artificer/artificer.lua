--require("Misc.loadout")
--require("Libraries.skill.main")

---------------
-- Resources --
---------------

local baseSprites = {
	idle = Sprite.load("mage_idle", "Actors/artificer/idle", 1, 4, 7),
	walk = Sprite.load("mage_walk", "Actors/artificer/walk", 4, 4, 7),
	jump = Sprite.load("mage_jump", "Actors/artificer/jump", 1, 4, 7),
	climb = Sprite.load("mage_climb", "Actors/artificer/climb", 2, 4, 7),
	death = Sprite.load("mage_death", "Actors/artificer/death", 6, 7, 8),
	decoy = Sprite.load("mage_decoy", "Actors/artificer/decoy", 1, 8, 11),
	--palette = Sprite.load("CommandoPal", "Actors/commando/palette", 1, 0, 0)
}

local sprites = {
	shoot1 = Sprite.load("mage_shoot1", "Actors/artificer/shoot1", 4, 4, 8),
    shoot2_1 = Sprite.load("mage_shoot2_charge1", "Actors/artificer/shoot2_charge", 8, 7, 8),
    shoot2_2 = Sprite.load("mage_shoot2_charge4", "Actors/artificer/shoot2_charge4", 2, 7, 8),
    shoot2_3 = Sprite.load("mage_shoot2_fire", "Actors/artificer/shoot2_fire", 6, 7, 8),
    shoot3 = Sprite.load("mage_shoot3", "Actors/artificer/shoot3", 8, 8, 8),
	shoot4_1_idle = Sprite.load("mage_shoot4_1_idle", "Actors/artificer/shoot4_1_1", 4, 5, 7),
    shoot4_1_forwards = Sprite.load("mage_shoot4_1_forwards", "Actors/artificer/shoot4_1_2", 4, 5, 7),
    shoot4_1_backwards = Sprite.load("mage_shoot4_1_backwards", "Actors/artificer/shoot4_1_3", 4, 5, 7),
    shoot4_2_idle = Sprite.load("mage_shoot4_2_idle", "Actors/artificer/shoot4_2_1", 4, 5, 7),
    shoot4_2_forwards = Sprite.load("mage_shoot4_2_forwards", "Actors/artificer/shoot4_2_2", 4, 5, 7),
    shoot4_2_backwards = Sprite.load("mage_shoot4_2_backwards", "Actors/artificer/shoot4_2_3", 4, 5, 7),
	shoot5_1 = Sprite.find("GManShoot5_1", "vanilla"),
	shoot5_2 = Sprite.find("GManShoot5_2", "vanilla"),
	icons = Sprite.load("MageSkills", "Actors/commando/skills", 8, 0, 0),
	palettes = Sprite.load("MagePalettes", "Actors/commando/palettes", 2, 0, 0),
    loadout = Sprite.load("mage_select", "Actors/artificer/select", 4, 2, 0),
    -------------
    boltSpr = Sprite.load("EfFireboltSpr", "Actors/artificer/bolt", 4, 12, 4),
    boltMask = Sprite.load("boltMask", "Actors/artificer/boltMask", 1, 12, 4),
    firey = Sprite.find("EfFirey","vanilla"),
    nanoBombSpr = Sprite.load("EfNanoBomb", "Actors/artificer/nanoBomb", 8, 8.5, 8.5),
    nanoBombImpactSpr = Sprite.load("EfNanoBombImpact", "Actors/artificer/nanoBombImpact", 21, 17, 19),
    nanoBombMask = Sprite.load("EfNanoBombMask", "Actors/artificer/nanoBombMask", 1, 8.5, 8.5),
    sprFireL1 = Sprite.load("efFlamethrowerL", "Actors/artificer/flamethrowerL1", 6, 32, 7.5),
    sprFireR1 = Sprite.load("efFlamethrowerR", "Actors/artificer/flamethrowerR1", 6, 32, 7.5),
    sprFireL2 = Sprite.load("efFlamethrowerSuperL", "Actors/artificer/flamethrowerL2", 6, 32, 7.5),
    sprFireR2 = Sprite.load("efFlamethrowerSuperR", "Actors/artificer/flamethrowerR2", 6, 32, 7.5),
    
}
local iceSprites = {
    idle = Sprite.load("EfSnapfreeze", "Actors/artificer/iceIdle", 7, 6, 4),
    mask = Sprite.load("EfSnapfreezeMask", "Actors/artificer/iceMask", 1, 6, 4),
    spawn = Sprite.load("EfSnapfreezeSummon", "Actors/artificer/iceSpawn", 4, 6, 12),
    death = Sprite.load("EfSnapfreezeDeath", "Actors/artificer/iceDeath", 7, 6, 7),
    impact = Sprite.find("Sparks2", "vanilla")
}


local sounds = {
	shoot1Snd = Sound.find("Bullet3", "vanilla"),
    shoot1ImpactSnd = Sound.find("GiantJellyExplosion", "vanilla"),
    shoot2Snd = Sound.load("mage_shoot2_fire_snd", "Sounds/SFX/artificer/mageFireNanoBomb.ogg"),
    nanoBombChargeSnd = Sound.load("mage_shoot2_charge_snd", "Sounds/SFX/artificer/mageNanoBombCharge.ogg"),--Sound.find("BossSkill2", "vanilla")
    nanoBombImpactSnd = Sound.load("mage_shoot2_impact_snd", "Sounds/SFX/artificer/mageNanoBombImpact.ogg"),--Sound.find("BossSkill2", "vanilla")
    iceSnd = Sound.find("MissileLaunch","vanilla"),
    iceDeathSnd = Sound.find("Frozen","vanilla"),
    fireStartSnd = Sound.load("mage_shoot4_start_snd", "Sounds/SFX/artificer/mageFlamethrowerStart.ogg"),--Sound.find("WispBShoot1", "vanilla")
    fireLoopSnd = Sound.find("WormBurning", "vanilla"),

}

local particles = {
    shoot1FX = ParticleType.find("Spark", "vanilla"),
    nanoBombFX = ParticleType.find("FireIce", "vanilla"),
}

local enemies = ParentObject.find("enemies", "vanilla")

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

-- ENV Suit
local envSuit = {}
local envSuitFX = ParticleType.new("jetpack")
envSuitFX:shape("Disc")
envSuitFX:color(Color.fromRGB(255,239, 182), Color.fromRGB(205, 100, 50), Color.fromRGB(163, 0, 1))
envSuitFX:alpha(1, 0)
envSuitFX:additive(true)
envSuitFX:size(0.05, 0.05, -0.001, 0)
envSuitFX:life(30, 30)
envSuitFX:speed(1, 1, 0, 0)
envSuitFX:direction(270, 270, 0, 0)

local HoverStep = function(player)
    if player:get("geyser") then
        if player:collidesWith(Object.find("Geyser","vanilla"), player.x, player.y) and player:get("geyser") <= 0 then
            player:set("geyser", 30)
        end
        if player:get("geyser") > 0 then
            player:set("geyser", player:get("geyser") - 1)
        end
    else
        player:set("geyser", 0)
    end
    if player:get("moveUpHold") == 1 and player:get("free") == 1 and player:get("geyser") <= 0 then
        envSuit[player] = envSuit[player] + 1
        if envSuit[player] >= 15 then
            player:set("pVspeed", 0)
            if envSuit[player] % 5 == 0 then
                envSuitFX:burst("middle", player.x - (2 * player.xscale), player.y, 1)
                envSuitFX:burst("middle", player.x + (1 * player.xscale), player.y, 1)
                player:set("pVspeed", player:get("pGravity1")) 
            end
        end
    else
        envSuit[player] = 0
    end
end

local hover = Skill.new()

hover.displayName = "ENV Suit"
hover.description = "Holding the Jump key causes the Artificer to hover in the air."
hover.icon = sprites.icons
hover.iconIndex = 1
hover.cooldown = 22

-- Flame Bolt
local fireBolt = Object.new("MageFlameBolt")
fireBolt.sprite = sprites.boltSpr
fireBolt:addCallback("create", function(self)
    local data = self:getData()
    self.mask = sprites.boltMask
    local this = self:getAccessor()
    this.direction = 0
    this.speed = 5
end)
fireBolt:addCallback("step", function(self)
    local data = self:getData()
    local this = self:getAccessor()
    if math.random(100) < 33 then
        particles.shoot1FX:burst("middle", self.x, self.y, 1)
    end
    local nearest = enemies:findNearest(self.x, self.y)
    if (nearest and nearest:isValid() and self:collidesWith(nearest, self.x, self.y)) or self:collidesMap(self.x, self.y) then
        if data.parent then
            local hit = data.parent:fireExplosion(self.x, self.y, 0.25, 1, 2, sprites.firey,nil)
            hit:set("burn", 1)
        end
        self:destroy()
        return
    end
end)

local boltCount = {}
local maxBolts = 4
local boltRechargeDelay = 30

local flameBolt = Skill.new()

flameBolt.displayName = "Flame Bolt"
flameBolt.description = "Fire a bolt for 200% damage that ignites enemies. Hold up to 4."
flameBolt.icon = sprites.icons
flameBolt.iconIndex = 1
flameBolt.cooldown = 4*60

local function boltInit(player, index, sprite, speed)
    if Ability.getCharge(player, "z") > 0 then
        return initActivity(player, index, sprite, speed, true, true)
    else return false end
end

flameBolt:setEvent("init", function(player, index) 
    if boltInit(player, index, player:getAnimation("shoot1"), 0.2) then
        --Ability.setCharge(player, "z", Ability.getCharge(player, "z") - 1)
        if Ability.getCharge(player, "z") <= 1 then
            Ability.setCooldown(player, "z", flameBolt.cooldown)
        else
            Ability.setCooldown(player, "z", 60)
        end
		return true
	end 
	return false
end)
flameBolt:setEvent(2, function(player, index) 
    sounds.shoot1Snd:play(player:get("attack_speed") + math.random() * 0.1)
    local f = fireBolt:create(player.x + (3 * player.xscale), player.y)
    f:getData().parent = player
    f:set("direction", player:getFacingDirection())
end)

-- Nanobomb

local m2Charge = {}
local m2Phase = {}
local maxCharge = 120
local nanoBombShockRange = 50

local nanoBomb = Object.new("MageNanoBomb")
nanoBomb.sprite = sprites.nanoBombSpr
nanoBomb:addCallback("create", function(self)
    local data = self:getData()
    self.mask = sprites.nanoBombMask
    data.charge = 1
    local this = self:getAccessor()
    this.direction = 0
    this.speed = 3
end)
nanoBomb:addCallback("step", function(self)
    local data = self:getData()
    local this = self:getAccessor()
    self.xscale = data.charge
    self.yscale = data.charge
    for _, e in ipairs(enemies:findAllEllipse(self.x - nanoBombShockRange, self.y - nanoBombShockRange, self.x + nanoBombShockRange, self.y + nanoBombShockRange)) do
        if e and e:isValid() then
            if math.random(100) < 33 then
                local bolt = DrawLightning(self.x, self.y, e.x, e.y)
                bolt.blendColor = Color.ROR_BLUE
                if data.parent then
                    local b = data.parent:fireBullet(e.x, e.y, 0, 1, 1, nil, nil)
                    b:set("specific_target", e.id)
                end
            end

        end
    end
    local nearest = enemies:findNearest(self.x, self.y)
    if (nearest and nearest:isValid() and self:collidesWith(nearest, self.x, self.y)) or self:collidesMap(self.x, self.y) then
        misc.shakeScreen(5)
        sounds.nanoBombImpactSnd:play()
        if data.parent then
            local hit = data.parent:fireExplosion(self.x, self.y, 2, 3.5, 4 + (8*data.charge), sprites.nanoBombImpactSpr,nil)
            hit:set("stun", 1)
        end
        for i = 0, math.random(2, 3) do
            local bolt = DrawLightning(self.x + math.random(-nanoBombShockRange, nanoBombShockRange), self.y + math.random(-nanoBombShockRange, nanoBombShockRange), self.x + math.random(-nanoBombShockRange, nanoBombShockRange), self.y + math.random(-nanoBombShockRange, nanoBombShockRange))
            bolt.blendColor = Color.ROR_BLUE
        end
        self:destroy()
        return
    end
end)

local ChargeSecondaryInputStep = function(player)
    local data = player:getData()
    local p = player:getAccessor()
    if m2Phase[player] == 0 then --Accept initial input; trigger attack
        if p.activity == 0 and player:getAlarm(3) == -1 then
            if input.checkControl("ability2", player) == input.PRESSED or input.checkControl("ability2", player) == input.HELD then
                p.activity = 2
                p.activity_type = 1
                player.sprite = player:getAnimation("shoot2_1")
                player.subimage = 1
                p.activity_var1 = 0
                m2Charge[player] = 0
                sounds.nanoBombChargeSnd:play(p.attack_speed)
                m2Phase[player] = 1
                return
            end
        end
    elseif m2Phase[player] == 1 then --Startup animation
        if math.floor(player.subimage) >= player:getAnimation("shoot2_1").frames then
            player.sprite = player:getAnimation("shoot2_2")
            player.subimage = 1
            m2Phase[player] = 2
            return
        end
    elseif m2Phase[player] == 2 then --Holding down attack, charging it further
        if input.checkControl("ability2", player) ~= input.HELD or m2Charge[player] >= maxCharge then
            player.sprite = player:getAnimation("shoot2_3")
            player.subimage = 1
            m2Phase[player] = 3
            return
        end

    elseif m2Phase[player] == 3 then --Releasing attack, firing it
        

    elseif m2Phase[player] == 4 then --Winding down, cleaning up attack
        m2Phase[player] = 0
        m2Charge[player] = 0
        p.activity = 0
        p.activity_type = 0
        p.activity_var1 = 0
        player.sprite = player:getAnimation("idle")
        player:activateSkillCooldown(2)
    end
end

local ChargeSecondaryStep = function(player)
    local data = player:getData()
    local p = player:getAccessor()
    if m2Phase[player] == 1 or m2Phase[player] == 2 then
        m2Charge[player] = math.approach(m2Charge[player], maxCharge, p.attack_speed)
    elseif m2Phase[player] == 3 then
        if math.floor(player.subimage) == 3 then
            if p.activity_var1 == 0 then
                if sounds.nanoBombChargeSnd:isPlaying() then
                    sounds.nanoBombChargeSnd:stop()
                end
                sounds.shoot2Snd:play(p.attack_speed)
                local bomb = nanoBomb:create(player.x + (3*player.xscale), player.y)
                bomb:set("direction", player:getFacingDirection())
                bomb:getData().parent = player
                bomb:getData().charge = (m2Charge[player] / maxCharge)
                p.activity_var1 = 1
            end
        elseif math.floor(player.subimage) >= player:getAnimation("shoot2_3").frames-1 then
            m2Phase[player] = 4
            return
        end
    end
end

callback.register("onGameEnd", function()
    if sounds.nanoBombChargeSnd:isPlaying() then
        sounds.nanoBombChargeSnd:stop()
    end
end)

local launchNanoBomb = Skill.new()

launchNanoBomb.displayName = "Charged Nano-Bomb"
launchNanoBomb.description = "Charge a nano-bomb that deals 400%-1200% damage and stuns enemies."
launchNanoBomb.icon = sprites.icons
launchNanoBomb.iconIndex = 2
launchNanoBomb.cooldown = 3 * 60

-- Snapfreeze

local snapfreeze = Skill.new()

snapfreeze.displayName = "Snapfreeze"
snapfreeze.description = "Create a barrier that freezes enemies for 100% damage. Enemies at low health are instantly killed if frozen."
snapfreeze.icon = sprites.icons
snapfreeze.iconIndex = 7
snapfreeze.cooldown = 3 * 60

-- Flamethrower
local ultPhase = {}
local ultDirection = {}
local ultLoop = {}
local maxFlamethrowerTime = 3*60

local fire = Object.new("MageFlamethrower")
fire.sprite = sprites.firey

fire:addCallback("create", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    self.direction = 0
    self.speed = 2
    this.angle = math.random(0, 360)
    data.angleRate = math.random(-1, 1)
    this.spriteSpeed = 0.2
    data.hit = {}
    data.burn = false
    data.doDamage = false
    data.damage = 14
    data.team = "playerproc"
end)
fire:addCallback("step", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    local nearest = enemies:findNearest(this.x, this.y)
    if data.doDamage then
        if nearest and nearest:isValid() then
            if this:collidesWith(nearest, this.x, this.y) then
                if not data.hit[nearest] then
                    local b = nil
                    if data.parent and data.parent:isValid() then
                        b = data.parent:fireBullet(nearest.x, nearest.y, self.direction, 1, 1, nil, nil)
                        if data.burn then
                            b:set("burn", 1)
                        end
                    else
                        b = misc.fireBullet(nearest.x, nearest.y, self.direction, 1, data.damage, data.team, nil, nil)
                    end
                    b:set("specific_target", nearest.id)
                    data.hit[nearest] = true
                end
            end
        end
    end
    this.angle = this.angle + data.angleRate
    if math.floor(this.subimage) == this.sprite.frames then
        this:destroy()
        return
    end
end)

callback.register("onGameEnd", function()
    if sounds.fireLoopSnd:isPlaying() then
        sounds.fireLoopSnd:stop()
    end
end)

local FlamethrowerInputStep = function(player)
    if ultPhase[player] == 0 and player:getAlarm(5) == -1 then
        if input.checkControl("ability4", player) == input.PRESSED then
            if player:getFacingDirection() == 180 then
                ultDirection[player] = -1
            else
                ultDirection[player] = 1
            end
            sounds.fireStartSnd:play(0.8 + math.random() * 0.2)
            sounds.fireLoopSnd:loop()
            ultLoop[player] = 0
            player:set("activity", 4)
            player:set("activity_type", 0)
            ultPhase[player] = 1
        end
    end
end

local FlamethrowerStep = function(player)
    if ultPhase[player] == 1 then
        if ultLoop[player] <= (maxFlamethrowerTime) then
            ultLoop[player] = ultLoop[player] + 1
            local f = fire:create(player.x + (4 * ultDirection[player]), player.y)
            if ultDirection[player] == -1 then
                f:set("direction", 180)
            else
                f:set("direction", 0)
            end
            if ultLoop[player] % 8 == 0 then
                f:getData().doDamage = true
                f:getData().parent = player
                f:getData().damage = player:get("damage")
                f:getData().team = player:get("team").."proc"
                if player:get("activity_var1") == 0 then
                    f:getData().burn = true
                    player:set("activity_var1", 1)
                else
                    player:set("activity_var1", 0)
                end
            end
        else
            ultPhase[player] = 2
            return
        end
        local anim = player:get("scepter") + 1
        if player:get("free") == 1 then
            player.sprite = player:getAnimation("shoot4_"..anim.."_idle")
        else
            player:set("pHspeed", 0)
            player.sprite = player:getAnimation("shoot4_"..anim.."_idle")
            if player:get("moveLeft") == 1 then
                if ultDirection[player] == -1 then
                    player.sprite = player:getAnimation("shoot4_"..anim.."_forwards")
                else
                    player.sprite = player:getAnimation("shoot4_"..anim.."_backwards")
                end
                player:set("pHspeed", -player:get("pHmax"))
            end
            if player:get("moveRight") == 1 then
                if ultDirection[player] == -1 then
                    player.sprite = player:getAnimation("shoot4_"..anim.."_backwards")
                else
                    player.sprite = player:getAnimation("shoot4_"..anim.."_forwards")
                end
                player:set("pHspeed", player:get("pHmax"))
            end
        end
        if player.xscale ~= ultDirection[player] then
            player.xscale = ultDirection[player]
        end
    elseif ultPhase[player] == 2 then
        if sounds.fireLoopSnd:isPlaying() then
            sounds.fireLoopSnd:stop()
        end
        player:set("activity", 0)
        player:set("activity_type", 0)
        player:activateSkillCooldown(4)
        ultPhase[player] = 0
        return
    end

end

local flameThrower = Skill.new()

flameThrower.displayName = "Flamethrower"
flameThrower.description = "Burn all enemies in front of you for 1700% damage."
flameThrower.icon = sprites.icons
flameThrower.iconIndex = 3
flameThrower.cooldown = 4 * 60

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
    ["decoy"] = baseSprites.decoy,
    ---------------------
	["shoot1"] = sprites.shoot1,
	["shoot2_1"] = sprites.shoot2_1,
	["shoot2_2"] = sprites.shoot2_2,
	["shoot2_3"] = sprites.shoot2_3,
	["shoot3"] = sprites.shoot3,
	["shoot4_1_idle"] = sprites.shoot4_1_idle,
	["shoot4_1_forwards"] = sprites.shoot4_1_forwards,
	["shoot4_1_backwards"] = sprites.shoot4_1_backwards,
	["shoot4_2_idle"] = sprites.shoot5_1_idle,
	["shoot4_2_forwards"] = sprites.shoot5_1_forwards,
	["shoot4_2_backwards"] = sprites.shoot5_1_backwards,
}

local s_chrome = Skill.new()

s_chrome.displayName = "Chrome"
s_chrome.description = ""
s_chrome.icon = sprites.palettes
s_chrome.iconIndex = 2
s_chrome.cooldown = -1

--[[local chromeSprites = {
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

local mage = Survivor.new("Artificer")

local loadout = Loadout.new()
loadout.survivor = mage
loadout.description = [[&y&Artificer&!& is a high burst damage survivor who excels in &y&fighting large groups 
and bosses alike&!&. &b&Frozen enemies&!& are &y&executed at low health&!&, making it great to eliminate tanky enemies. 
Remember that Artificer has &y&NO defensive skills&!& - positioning and defensive items are key!]]


local passive = loadout:getSlot("Passive")
passive.showInLoadoutMenu = true
passive.showInCharSelect = true
loadout:addSkill("Passive", hover, {
	loadoutDescription = [[Holding the &y&Jump key&!& causes the Artificer to 
hover in the air.]],
    apply = function(player)
        envSuit[player] = 0
    end,
})
loadout:addSkill("Primary", flameBolt, {
	loadoutDescription = [[Fire a bolt for &y&200% damage&!& that &r&ignites&!& enemies. 
&b&Hold up to 4&!&.]],
    apply = function(player)
        Ability.AddCharge(player, "z", 3, true)
    end,
    remove = function(player, hardRemove)
        Ability.Disable(player, "z")
    end,
})
loadout:addSkill("Secondary", launchNanoBomb, {
	loadoutDescription = [[Charge a nano-bomb that deals &y&400%-1200% damage&!& 
and stuns enemies.]],
    apply = function(player)
        m2Phase[player] = 0
        m2Charge[player] = 0
    end
})
loadout:addSkill("Utility", snapfreeze,{
	loadoutDescription = [[Fire two close range blasts for &y&8x200% damage total&!&.]],
})
loadout:addSkill("Special", flameThrower,{
    loadoutDescription = [[&r&Burn&!& all enemies in front of you for &y&1700% damage&!&.]],
    apply = function(player)    
        ultPhase[player] = 0
        ultLoop[player] = 0
        ultDirection[player] = player.xscale
    end,
	--upgrade = loadout:addSkill("Special", suppBarr, {hidden = true}) 
}) 
loadout:addSkin(s_default, defaultSprites)
loadout:addSkin(s_chrome, defaultSprites, {
	locked = true,
	unlockText = "Artificer: Obliterate yourself at the Obelisk on Monsoon difficulty."
})

mage.titleSprite = baseSprites.walk
mage.loadoutColor = Color.fromRGB(247,193,253)
mage.loadoutSprite = sprites.loadout
mage.endingQuote = "..and so she left, her boundless curiosity having shriveled on the planet."

mage:addCallback("init", function(player)
	player:setAnimations(baseSprites)
    player:survivorSetInitialStats(110, 14, 0.01)
end)

mage:addCallback("levelUp", function(player)
    player:survivorLevelUpStats(33, 2.4, 0.003, 2.4)
end)

mage:addCallback("scepter", function(player)
	Loadout.Upgrade(loadout, player, "Special")
end)

registercallback("onPlayerStep", function(player)
    if player:isValid() then
        if player:getSurvivor() == mage then
            if loadout:getCurrentSkill("Passive").obj == hover then
                HoverStep(player)
            end
            if loadout:getCurrentSkill("Secondary").obj == launchNanoBomb then
                ChargeSecondaryInputStep(player)
                ChargeSecondaryStep(player)
            end
            if loadout:getCurrentSkill("Special").obj == flameThrower then
                FlamethrowerInputStep(player)
                FlamethrowerStep(player)
            end
        end
    end
end)

Loadout.RegisterSurvivorID(mage)


-------------------------------------

local pause = Achievement.new("Pause")
pause.requirement = 1
pause.deathReset = false
pause.description = "Free the survivor suspended in time."
pause.highscoreText = "\'Artificer\' Unlocked"
--pause:assignUnlockable(mage)

local crystal = Object.base("mapobject", "mageLocked")
crystal.sprite = Sprite.load("mageLocked", "Graphics/artificerImprisoned", 1, 11, 27)

local player = Object.find("P", "vanilla")
local useText = "&w&Press &y&'"..input.getControlString("enter").."'&w& to free the Survivor. &y&(10 Lunar)&!&"
local activeText = "10 LUNAR"

crystal:addCallback("create", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    self.name = "Imprisoned Survivor"
    this.y = FindGround(this.x, this.y)
end)
crystal:addCallback("step", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    if this:collidesWith(player:findNearest(this.x, this.y), this.x, this.y) then
        local target = player:findNearest(this.x, this.y)
        if input.checkControl("enter", target) == input.PRESSED then
            if target:get("lunar_coins") and target:get("lunar_coins") > 10 then
                local flash = Object.find("WhiteFlash", "vanilla"):create(this.x, this.y)
                flash:set("rate", 0.01)
                Sound.find("VagrantBlast", "RoR2Demake"):play(1 + math.random() * 0.05)
                misc.shakeScreen(30)
                target:set("lunar_coins", math.clamp(target:get("lunar_coins") - 10, 0, target:get("lunar_coins")))
                pause:increment(1)
                this:destroy()
                return
            else
                Sound.find("Error", "vanilla"):play(1)
            end
        end
    end
end)
crystal:addCallback("draw", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    graphics.alpha(0.7+(math.random()*0.15))
    graphics.printColor("&y&"..activeText.."&!&", this.x - (graphics.textWidth(activeText, NewDamageFont) / 2), this.y + (graphics.textHeight(activeText, NewDamageFont)), NewDamageFont)
    if this:collidesWith(player:findNearest(this.x, this.y), this.x, this.y) then
        graphics.alpha(1)
        local useFormatted = useText:gsub("&[%a]&", "")
        graphics.printColor(useText, (this.x - (graphics.textWidth(useFormatted, graphics.FONT_DEFAULT) / 2)), (this.y - (this.sprite.height + (graphics.textHeight(useText, graphics.FONT_DEFAULT) + 5))), graphics.FONT_DEFAULT) 
    end
end)


return mage
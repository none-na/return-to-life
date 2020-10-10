--require("Misc.loadout")
--require("Libraries.skill.main")

---------------
-- Resources --
---------------

local baseSprites = {
	idle = Sprite.load("treebot_idle", "Actors/rex/idle", 1, 9, 18),
    walk = Sprite.load("treebot_walk_1", "Actors/rex/walk1", 6, 12, 18),
    walkBackwards = Sprite.load("treebot_walk_2", "Actors/rex/walk2", 6, 12, 18),
	jump = Sprite.load("treebot_jump", "Actors/rex/jump", 1, 9, 18),
	climb = Sprite.load("treebot_climb", "Actors/rex/climb", 4, 11, 23),
	death = Sprite.load("treebot_death", "Actors/rex/death", 14, 15, 18),
	decoy = Sprite.load("treebot_decoy", "Actors/mult/idle1", 1, 9, 18),
}

local sprites = {
	shoot1 = Sprite.load("treebot_shoot1", "Actors/rex/shoot1", 8, 10, 18),
	shoot2 = Sprite.load("treebot_shoot2", "Actors/rex/shoot2", 6, 11, 54),
	shoot3 = Sprite.load("treebot_shoot3", "Actors/rex/shoot3", 6, 10, 18),
	shoot4 = Sprite.load("treebot_shoot4", "Actors/rex/shoot4", 6, 10, 18),
	icons = Sprite.load("treebot_skills", "Actors/rex/skills", 8, 0, 0),
	palettes = Sprite.load("treebotPalettes", "Actors/rex/palettes", 2, 0, 0),
    loadout = Sprite.load("treebot_select", "Actors/rex/select", 12, 2, 0),
    --------------------
    weaken = Sprite.load("EftreebotDebuff", "Actors/rex/debuff", 1, 9, 7),
    bite2 = Sprite.find("Bite2", "vanilla"),
    mortarWarning = Sprite.load("EfTreeMortarWarning", "Actors/rex/mortarWarning", 6, 25, 7),
    mortarDetonate = Sprite.load("EfTreeMortarImpact", "Actors/rex/mortarImpact", 10, 25, 90),
    sonicBoom = Sprite.load("EfSonicBoom", "Actors/rex/sonicBoom", 7, 10, 10),
    growthSeed = Sprite.load("EfSeed", "Actors/rex/seed", 10, 5, 7),
    growthSeedScepter = Sprite.load("EfSeed2", "Actors/rex/seed2", 10, 5, 7),
    growthFlower = Sprite.load("EfBrambleFlower", "Actors/rex/flower", 6, 8, 10),
    growthFlowerScepter = Sprite.load("EfBrambleFlower2", "Actors/rex/flower2", 6, 8, 10),
    growthDeath = Sprite.load("EfBrambleFlowerDeath", "Actors/rex/flowerDeath", 5, 8, 10),
    growthDeathScepter = Sprite.load("EfBrambleFlowerDeath2", "Actors/rex/flowerDeath2", 5, 8, 10),
    growthVine = Sprite.load("EfBrambleVine", "Actors/rex/vine", 1, 3, 8),
    growthVineScepter = Sprite.load("EfBrambleVine2", "Actors/rex/vine2", 1, 3, 8),
    growthDebuff = Sprite.load("EfBrambleIcon", "Actors/rex/bramble", 1, 9, 7),
}

local objects = {
    heal2 = Object.find("EfHeal2", "vanilla"),
    enemies = ParentObject.find("enemies", "vanilla")
}

local particles = {
    heal = ParticleType.find("Heal", "vanilla")
}

local sounds = {
    shoot1 = Sound.load("treebot_shoot1_snd","Sounds/SFX/rex/shoot1.ogg"),
    use = Sound.find("Use", "vanilla"),
    shoot2 = Sound.load("treebot_shoot2_1_snd","Sounds/SFX/rex/shoot2_1.ogg"),
    shoot2Impact = Sound.load("treebot_shoot2_2_snd","Sounds/SFX/rex/shoot2_2.ogg"),
    shoot3 = Sound.load("treebot_shoot3_snd","Sounds/SFX/rex/shoot3.ogg"),
    MushShoot1 = Sound.find("MushShoot1", "vanilla"),
    shoot4Impact = Sound.load("treebot_shoot4_snd","Sounds/SFX/rex/shoot4.ogg"),
    snare = Sound.load("treebot_snare_snd","Sounds/SFX/rex/snare.ogg"),
    
}

------------
-- Skills --
------------

local rexRecoilDamage = function(player, percentHP)
    local bullet = misc.fireBullet(player.x, player.y, 0, 1, (player:get("hp") * percentHP), "neutral", nil, DAMAGER_NO_PROC + DAMAGER_NO_RECALC)
    bullet:set("damage_fake", bullet:get("damage"))
    if bullet:get("critical") == 1 then
        bullet:set("critical", 0)
        bullet:set("damage", bullet:get("damage") / 2)
    end
    bullet:set("damage_fake", bullet:get("damage"))
end

local function initActivity(player, index, sprite, speed, scaleSpeed, resetHSpeed)
	if player:get("activity") == 0 then
		player:survivorActivityState(index, sprite, speed, scaleSpeed, resetHSpeed)
		player:activateSkillCooldown(index)
		return true
	end
	return false
end

-- Natural Toxins

local weaken = Buff.new("treebotDebuff")
weaken.sprite = sprites.weaken
weaken:addCallback("start", function(actor)
    actor.blendColor = Color.fromRGB(230, 255, 200)
    actor:set("damage", actor:get("damage") - 5)
    actor:set("pHmax", actor:get("pHmax") - 0.3)
    actor:set("armor", actor:get("armor") - 50)
end)
weaken:addCallback("end", function(actor)
    actor.blendColor = Color.fromRGB(255, 255, 255)
    actor:set("damage", actor:get("damage") + 5)
    actor:set("pHmax", actor:get("pHmax") + 0.3)
    actor:set("armor", actor:get("armor") + 50)
end)

registercallback("onHit", function(damager, hit, x, y)
    local parent = damager:getParent()
    if parent then
        if damager:get("weaken") ~= nil and hit:isValid() then
            if damager:get("weaken") > 0 then
                hit:applyBuff(weaken, (3.5*60) * damager:get("weaken"))
            end
        end
    end
end)

local toxins = Skill.new()

toxins.displayName = "Natural Toxins"
toxins.description = "toxins"
toxins.icon = sprites.icons
toxins.iconIndex = 1
toxins.cooldown = -1


-- DIRECTIVE: Inject

registercallback("onHit", function(damager, hit, x, y)
    local parent = damager:getParent()
    if parent then
        if damager:get("drainHP") ~= nil and hit:isValid() then
            if damager:get("drainHP") > 0 then
                local heal = math.round(damager:get("damage") * damager:get("drainHP"))
                
                if modloader.checkFlag("rex_instant_heal") then
                    sounds.heal:play(0.9 + math.random() * 0.1)
                    particles.heal:burst("above", parent.x, parent.y, damager:get("drainHP") * 10)
                    misc.damage(heal, parent.x, parent.y - (parent.sprite.height / 2), false, Color.DAMAGE_HEAL)
                    parent:set("hp", parent:get("hp") + (heal))
                else
                    local orb = objects.heal2:create(x, y)
                    orb:set("target", parent.id)
                    orb:set("value", heal)
                end
            end
        end
    end
end)

local inject = Skill.new()

inject.displayName = "DIRECTIVE: Inject"
inject.description = "Fire 3 syringes for 3*80% damage. The last syringe Weakens and heals for 30% of damage dealt."
inject.icon = sprites.icons
inject.iconIndex = 2
inject.cooldown = 30

local FireInject = function(player, heal)
	for i = 0, player:get("sp") do
        local syringe = player:fireBullet(player.x, player.y, player:getFacingDirection(), 9999, 0.8, sprites.bite2, nil)
        if heal then
            syringe:set("weaken", 1)
            syringe:set("drainHP", 0.6)
        end
	end
	sounds.shoot1:play(player:get("attack_speed") + math.random() * 0.3)

end

inject:setEvent("init", function(player, index)
	return initActivity(player, index, player:getAnimation("shoot1"), 0.25, true, true)
end)
inject:setEvent(1, function(player)
    FireInject(player, false)
end)
inject:setEvent(3, function(player)
    FireInject(player, false)
end)
inject:setEvent(5, function(player)
    FireInject(player, true)
end)
inject:setEvent(7, function(player)
    player:activateSkillCooldown(1)
end)

-- Seed Barrage
local m2Phase = {}
local m2Direction = {}
local mortarOffset = {}
local defaultOffset = {x = 100, y = 0}
local mortarDelay = 30

local seedBarrage = Object.new("EfTreeMortar")
seedBarrage.sprite = sprites.mortarWarning

seedBarrage:addCallback("create", function(self)
    self.spriteSpeed = 0.25
    self:set("life", mortarDelay)
end)

seedBarrage:addCallback("step", function(self)
    self:set("life", self:get("life") - 1)
    if self:get("life") <= -1 then
        self.alpha = 0
        local parent = Object.findInstance(self:get("parent"))
        sounds.shoot2Impact:play(0.9 + math.random() * 0.2)
        misc.shakeScreen(5)
        if parent then
            local explosion = parent:fireExplosion(self.x, self.y + (self.sprite.height / 2), sprites.mortarWarning.width / 19, sprites.mortarWarning.width / 4, 4.5, sprites.mortarDetonate, nil)
        end
        self:destroy()
    end
end)

local ChargeInputStep = function(player)
    if m2Phase[player] == 0 then
        if input.checkControl("ability2", player) == input.HELD and player:getAlarm(3) <= -1 then
            if player:getFacingDirection() == 180 then
                m2Direction[player] = -1
            else
                m2Direction[player] = 1
            end
            player:set("activity", 0)
            m2Phase[player] = 1
            player:set("activity_var1", 0)
            player:survivorActivityState(2, player:getAnimation("idle"), 0.25, true, true)
        end
    elseif m2Phase[player] == 1 then
        if input.checkControl("ability2", player) == input.HELD then
            if player:get("free") == 1 then
                player.sprite = player:getAnimation("jump")
            elseif input.checkControl("left", player) == input.HELD then
                if m2Direction[player] == -1 then
                    player.sprite = player:getAnimation("walk")
                else
                    player.sprite = player:getAnimation("walkBackwards")
                end
                player:set("pHspeed", -player:get("pHmax"))
            elseif input.checkControl("right", player) == input.HELD then
                if m2Direction[player] == -1 then
                    player.sprite = player:getAnimation("walkBackwards")
                else
                    player.sprite = player:getAnimation("walk")
                end
                player:set("pHspeed", player:get("pHmax"))
            else
                player.sprite = player:getAnimation("idle")
            end
        elseif input.checkControl("ability2", player) == input.RELEASED then
            player:set("activity", 0)
            m2Phase[player] = 2
            player.subimage = 0
            player:survivorActivityState(2, player:getAnimation("shoot2"), 0.25, true, true)
        end

    end
end

local ChargeStep = function(player, frame)
    if m2Phase[player] > 0 then
        if player.xscale ~= m2Direction[player] then
            player.xscale = m2Direction[player]
        end
    end
    if m2Phase[player] == 1 then
        local enemyInRange = objects.enemies:findLine(player.x, player.y, player.x + (mortarOffset[player].x * player.xscale), player.y + mortarOffset[player].y)
        if enemyInRange then
            mortarOffset[player].x = math.abs(player.x - (enemyInRange.x))
        else
            mortarOffset[player] = defaultOffset
        end
    elseif m2Phase[player] == 2 then
        if frame == 4 then
            if player:get("activity_var1") == 0 then
                sounds.shoot2:play(0.9 + math.random() * 0.1)
                local mortar = seedBarrage:create(player.x + (mortarOffset[player].x * player.xscale), player.y + mortarOffset[player].y)
                rexRecoilDamage(player, 0.15)
                mortar:set("parent", player.id)
                mortarOffset[player].x = 100
                mortarOffset[player].y = 0
                player:set("activity_var1", 1)
            end
        elseif frame >= 5 then
            player:activateSkillCooldown(2)
            m2Phase[player] = 0
            return
        end
    end
end

local barrage = Skill.new()

barrage.displayName = "Seed Barrage"
barrage.description = "Costs 15% of your current health. Launch a mortar into the sky for 450% damage."
barrage.icon = sprites.icons
barrage.iconIndex = 3
barrage.cooldown = 10

-- DIRECTIVE: Disperse

registercallback("onHit", function(damager, hit, x, y)
    local parent = damager:getParent()
    if parent then
        if damager:get("sonicBoom") and hit:isValid() then
            if damager:get("sonicBoom") > 0 then
                hit:set("lasthit_x", parent.x)
                hit:set("force_knockback", 1)
            end
        end
    end
end)

local disperse = Skill.new()

disperse.displayName = "DIRECTIVE: Disperse"
disperse.description = "Fire a sonic boom that pushes and Weakens all enemies hit. Pushes you backwards if you are airborne."
disperse.icon = sprites.icons
disperse.iconIndex = 4
disperse.cooldown = 5 * 60

disperse:setEvent("init", function(player, index)
	return initActivity(player, index, player:getAnimation("shoot3"), 0.25, true, true)
end)
disperse:setEvent("all", function(player)
    if player:get("free") == 1 then
        player:set("pHspeed", ((10 * player:get("pHmax")) / math.floor(player.subimage)) * -player.xscale)
    end
end)
disperse:setEvent(2, function(player)
    player:set("pVspeed", 0)
    sounds.shoot3:play(1 + math.random() * 0.2)
    local boomInst = player:fireExplosion(player.x + (10 * player.xscale), player.y, sprites.sonicBoom.width/19, sprites.sonicBoom.height/4, 0, sprites.sonicBoom, nil, DAMAGER_NO_PROC)
    boomInst:set("weaken", 2)
    boomInst:set("sonicBoom", 1)
    boomInst:set("knockback", 10)
end)
disperse:setEvent(5, function(player)
    player:activateSkillCooldown(3)
end)

-- Tangling Grwoth

local tanglingGrowth = Object.new("EfBramble")
tanglingGrowth.sprite = sprites.growthFlower

local brambleDebuff = Buff.new("treeBotSnare")
brambleDebuff.sprite = sprites.growthDebuff

brambleDebuff:addCallback("start", function(actor)
    actor:getData().originalSpeed = actor:get("pHmax")
    actor:set("pHmax", 0)
end)
brambleDebuff:addCallback("end", function(actor)
    actor:set("pHmax", actor:getData().originalSpeed or 1.3)
end)

local brambleRadius = 100
local healCoefficient = 0.025
local brambleLife = 10*60
local healDelay = 30
local succThreshold = 30


tanglingGrowth:addCallback("create", function(self)
    self.spriteSpeed = 0.25
    local data = self:getData()
    data.snaredTargets = {}
    self:set("life", brambleLife)
    self:set("healDelay", healDelay)
    self:set("radius", brambleRadius)
    local parent = data.parent
    
end)
tanglingGrowth:addCallback("step", function(self)
    if math.round(self.subimage) >= sprites.growthFlower.frames + 1 then
        self.spriteSpeed = 0
    end
    local data = self:getData()
    local parent = data.parent
    if self:get("life") > -1 then
        if self:get("life") == brambleLife then
            if parent then
                if parent:get("scepter") > 0 then
                    self:set("radius", self:get("radius") * 1.5)
                    self.sprite = sprites.growthFlowerScepter
                end
            end
        end
        for _, enemyInst in ipairs(objects.enemies:findAllEllipse(self.x - self:get("radius"), self.y - self:get("radius"), self.x + self:get("radius"), self.y + self:get("radius"))) do
            if enemyInst:isValid() then
                if enemyInst:getObject() ~= Object.find("WormBody", "vanilla") or enemyInst:getObject() ~= Object.find("WurmBody", "vanilla") then
                    enemyInst:applyBuff(brambleDebuff, 3*60)
                    if parent then
                        if parent:get("scepter") > 0 then
                            enemyInst:applyBuff(weaken, 1*60)
                        end
                    end
                    if not data.snaredTargets[enemyInst] then
                        data.snaredTargets[enemyInst] = enemyInst
                        if parent then
                            sounds.snare:play(1 + math.random() * 0.1)
                            local damage = 2
                            if parent:get("scepter") > 0 then
                                damage = 3.5
                            end
                            local snare = parent:fireBullet(enemyInst.x, enemyInst.y, 0, 1, damage, shoot1Impact, DAMAGER_NO_PROC)
                            snare:set("specific_target", enemyInst.id)
                        end
                        enemyInst:set("bramble", self.id)
                    end
                    local xx = enemyInst.x-self.x
                    local yy = enemyInst.y-self.y
                    local zz = math.sqrt(math.pow(xx, 2) + math.pow(yy, 2))
                    if math.abs(zz) > succThreshold then
                        local moveDistance = zz / 10
                        for i = 0, moveDistance do
                            if enemyInst:collidesMap(enemyInst.x + (xx * (i/zz)),enemyInst.y + (yy * (i/zz)))then
                                moveDistance = i
                                return
                            end
                        end
                        if xx < succThreshold then
                            enemyInst.x = enemyInst.x + moveDistance
                        else
                            enemyInst.x = enemyInst.x - moveDistance
                        end
                    end
                end            
            end
        end
        if parent then
            local i = 0
            for _, snaredEnemy in pairs(data.snaredTargets) do
                if snaredEnemy:isValid() then
                    i = i + 1
                end
            end
            local heal = math.round((parent:get("maxhp") * healCoefficient) * i)
            if self:get("healDelay") <= -1 then
                if heal > 0 then
                    if modloader.checkFlag("rex_instant_heal") then
                        sounds.heal:play(0.9 + math.random() * 0.1)
                        particles.heal:burst("above", parent.x, parent.y, 10)
                        misc.damage(heal, parent.x, parent.y - (parent.sprite.height / 2), false, Color.DAMAGE_HEAL)
                        parent:set("hp", parent:get("hp") + (heal))
                    else
                        local orb = objects.heal2:create(self.x, self.y)
                        orb:set("target", parent.id)
                        orb:set("value", heal)
                    end
                end
                self:set("healDelay", healDelay)
            else
                self:set("healDelay", self:get("healDelay") - 1)
            end
        end
        self:set("life", self:get("life") - 1)
        if self:get("life") == -1 then
            self.subimage = 1
        end
    else
        local data = self:getData()
        local parent = data.parent
        local sprite = sprites.growthDeath
        if parent then
            if parent:get("scepter") > 0 then
                sprite = sprites.growthDeathScepter
            end
        end
        self.sprite = sprite
        self.spriteSpeed = 0.25
        if math.round(self.subimage) >= sprites.growthDeath.frames - 1 then
            self.alpha = 0
            self:getData().snaredTargets = {}
            self:destroy()
        end
    end
    

end)
tanglingGrowth:addCallback("draw", function(self)
    graphics.color(Color.fromRGB(134,158,85))
    graphics.alpha(0.5 + (math.sin(self:get("life")/(healDelay*2))/5))
    graphics.circle(self.x, self.y, self:get("radius"), true)
    ---
    local data = self:getData()
    local parent = data.parent
    local count = 0
    for _, enemy in ipairs(objects.enemies:findAll()) do
        if enemy:get("bramble") then
            if enemy:hasBuff(brambleDebuff) and enemy:get("bramble") == self.id then
                if enemy:getObject() ~= Object.find("WormBody", "vanilla") or enemy:getObject() ~= Object.find("WurmBody", "vanilla") then
                    count = count + 1
                    local xx = enemy.x-self.x
                    local yy = enemy.y-self.y
                    local zz = math.sqrt(math.pow(xx, 2) + math.pow(yy, 2))
                    local angle2 = math.atan2(enemy.x-self.x,enemy.y-self.y) * (180/math.pi)
                    for i = 0, zz do
                        if i % sprites.growthVine.height == 0 then
                            local sprite = sprites.growthVine
                            if parent then
                                if parent:get("scepter") > 0 then
                                    sprite = sprites.growthVineScepter
                                end
                            end
                            graphics.drawImage{
                                image = sprite,
                                x = self.x + (xx * (i/zz)),
                                y = self.y + (yy * (i/zz)),
                                angle = angle2
                            }
                        end
                    end
                end
            end
        end
    end
    if count > 0 then
        graphics.color(Color.fromRGB(134,158,90))
        graphics.alpha(0.7 + (math.sin(self:get("life")/(healDelay*2))/15))
        graphics.line(self.x, self.y, parent.x, parent.y, 2)
    end
end)

local seedMissile = Object.new("rexSeedMissile")
seedMissile.sprite = sprites.growthSeed
seedMissile:addCallback("create", function(this)
    local self = this:getAccessor()
    local data = this:getData()
    self.direction = 0
    self.speed = 4
    this.mask = sprites.growthSeed
end)
seedMissile:addCallback("step", function(this)
    local self = this:getAccessor()
    local data = this:getData()
    this.angle = self.direction - 90
    local nearest = objects.enemies:findNearest(this.x, this.y)
    if (nearest and nearest:isValid() and this:collidesWith(nearest, this.x, this.y)) or this:collidesMap(this.x, this.y) then
        if data.parent then
            data.parent:fireExplosion(this.x, this.y, 1, 4, data.damage, nil, nil)
            misc.shakeScreen(5)
            sounds.shoot4Impact:play(0.8 + math.random() * 0.2)
            local growthInst = tanglingGrowth:create(self.x, self.y)
            growthInst:getData().parent = data.parent
        end
        this:destroy()
        return
    end
end)


local fireGrowth = Skill.new()

fireGrowth.displayName = "Tangling Growth"
fireGrowth.description = "Costs 25% of your current health. Fire a flower that roots for 200% damage. Heals for every target hit."
fireGrowth.icon = sprites.icons
fireGrowth.iconIndex = 5
fireGrowth.cooldown = 12 * 60

fireGrowth:setEvent("init", function(player, index)
	return initActivity(player, index, player:getAnimation("shoot4"), 0.25, true, true)
end)
fireGrowth:setEvent(2, function(player)
    sounds.MushShoot1:play(0.9 + math.random() * 0.1)
    rexRecoilDamage(player, 0.25)
    local seedInst = seedMissile:create(player.x + (2*player.xscale), player.y - 1)
    seedInst:set("direction", player:getFacingDirection() + (5 * -player.xscale))
    seedInst:getData().parent = player
    seedInst:getData().damage = 2
    if player:get("scepter") > 0 then
        seedInst.sprite = sprites.growthSeedScepter
        seedInst:getData().damage = 3.5
    end
end)
fireGrowth:setEvent(5, function(player)
    player:activateSkillCooldown(3)
end)

-- Chocking Bramble

local fireGrowthSuper = Skill.new()

fireGrowthSuper.displayName = "Choking Bramble"
fireGrowthSuper.description = "Costs 25% of your current health. Fire a flower that roots for 350% damage. Heals for every target hit."
fireGrowthSuper.icon = sprites.icons
fireGrowthSuper.iconIndex = 6
fireGrowthSuper.cooldown = 12 * 60

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
	["walkBackwards"] = baseSprites.walkBackwards,
	["jump"] = baseSprites.jump,
	["climb"] = baseSprites.climb,
    ["death"] = baseSprites.death,
    ["decoy"] = baseSprites.decoy,
	["shoot1"] = sprites.shoot1,
	["shoot2"] = sprites.shoot2,
	["shoot3"] = sprites.shoot3,
    ["shoot4"] = sprites.shoot4,
}

local s_smoothie = Skill.new()

s_smoothie.displayName = "Smoothie"
s_smoothie.description = ""
s_smoothie.icon = sprites.palettes
s_smoothie.iconIndex = 2
s_smoothie.cooldown = -1

local smoothieSprites = {
	["loadout"] = sprites.loadout,
	["idle"] = baseSprites.idle,
	["walk"] = baseSprites.walk,
	["walkBackwards"] = baseSprites.walkBackwards,
	["jump"] = baseSprites.jump,
	["climb"] = baseSprites.climb,
    ["death"] = baseSprites.death,
    ["decoy"] = baseSprites.decoy,
	["shoot1"] = sprites.shoot1,
	["shoot2"] = sprites.shoot2,
	["shoot3"] = sprites.shoot3,
    ["shoot4"] = sprites.shoot4,
}

--------------
-- Survivor --
--------------

local treebot = Survivor.new("REX")

local loadout = Loadout.new()
loadout.survivor = treebot
loadout.description = [[&y&REX&!& is a plant-robot hybrid that uses &g&HP&!& to cast devastating skills from a distance. 
The plant nor the robot could survive this planet alone - thankfully they have each other. 
&b&Seed Barrage&!& can be  positioned by holding the skill - &y&just make sure to watch your HP!&!&]]

local passive = loadout:getSlot("Passive")
passive.showInLoadoutMenu = true
passive.showInCharSelect = true
loadout:addSkill("Passive", toxins, {
	loadoutDescription = [[Certain attacks &y&Weaken&!&, reducing movement speed, 
armor, and damage.]]
})
loadout:addSkill("Passive", Loadout.PresetSkills.NoPassive, {
	displayName = "Disable REX's Passive abilities."
})
loadout:addSkill("Primary", inject, {
	loadoutDescription = [[Fire 3 syringes for &y&3*80% damage&!&. The last syringe 
&y&Weakens&!& and &g&heals for 30% of damage dealt&!&.]]
})
loadout:addSkill("Secondary", barrage, {
	loadoutDescription = [[&r&Costs 15% of your current health&!&. Hold and release
to launch a mortar into the sky for &y&450% damage&!&.]]
})
loadout:addSkill("Secondary", Loadout.PresetSkills.Unfinished)
loadout:addSkill("Utility", disperse,{
	loadoutDescription = [[Fire a sonic boom that pushes and &y&Weakens&!& all enemies 
hit. &b&Pushes you backwards if you are airborne&!&.]]
})
loadout:addSkill("Secondary", Loadout.PresetSkills.Unfinished)
loadout:addSkill("Special", fireGrowth,{
	loadoutDescription = [[&r&Costs 25% of your current health&!&. Fire a flower that 
roots for &y&200% damage&!&. &g&Heals for every target hit&!&.]]
}) 
loadout:addSkin(s_default, defaultSprites)
loadout:addSkin(s_smoothie, smoothieSprites, {
	locked = true,
	unlockText = "REX: Obliterate yourself at the Obelisk on Monsoon difficulty."
})

treebot.titleSprite = baseSprites.walk
treebot.loadoutColor = Color.fromRGB(134,158,85)
treebot.loadoutSprite = sprites.loadout
treebot.loadoutWide = true
treebot.endingQuote = "..and so they left, their scars weighing them down forever."

treebot:addCallback("init", function(player)
    player:setAnimations(baseSprites)
    m2Phase[player] = 0
    m2Direction[player] = player.xscale
    mortarOffset[player] = defaultOffset
	player:survivorSetInitialStats(130, 14, 0.01)
end)

treebot:addCallback("levelUp", function(player)
	player:survivorLevelUpStats(39, 2.8, 0.002, 3)
end)

treebot:addCallback("scepter", function(player)
	Loadout.Upgrade(loadout, player, "Special")
end)

callback.register("onPlayerStep", function(player)
	if player:getSurvivor() == treebot then
        if loadout:getCurrentSkill("Secondary").obj == barrage then
            ChargeInputStep(player)
            ChargeStep(player, math.floor(player.subimage))
		end
	end
end)

registercallback("onPlayerDrawAbove", function(player)
    if player:getSurvivor() == treebot then
        if m2Phase[player] == 1 and input.checkControl("ability2", player) == input.HELD then
            graphics.color(Color.WHITE)
            graphics.alpha(1)
            graphics.circle(player.x + ((mortarOffset[player].x or 100) * player.xscale), player.y + (mortarOffset[player].y or 0), sprites.mortarWarning.width/2, true)
            for i=0, 100 do
                if i % 10 ~= 0 then
                    graphics.pixel(player.x + ((mortarOffset[player].x or 100) * player.xscale), (player.y + (mortarOffset[player].y or 0) - i) - sprites.mortarWarning.width/2)
                end
            end
        end
    end
end)

Loadout.RegisterSurvivorID(treebot)



---------------------------------

local smoothieUnlock = Achievement.new("unlock_rex_skin1")
smoothieUnlock.requirement = 1
smoothieUnlock.sprite = MakeAchievementIcon(sprites.palettes, 2)
smoothieUnlock.unlockText = "New skin: \'Smoothie\' unlocked."
smoothieUnlock.highscoreText = "REX: \'Smoothie\' unlocked"
smoothieUnlock.description = "REX: Obliterate yourself at the Obelisk on Monsoon difficulty."
smoothieUnlock.deathReset = false
smoothieUnlock:addCallback("onComplete", function()
	loadout:getSkillEntry(s_smoothie).locked = false
	Loadout.Save(loadout)
end)

--------------------------------

local powerPlant = Achievement.new("Power Plant")
powerPlant.requirement = 1
powerPlant.deathReset = false
powerPlant.description = "Repair the broken robot with an Escape Pod's Fuel Array."
powerPlant.highscoreText = "\'REX\' Unlocked"
powerPlant:assignUnlockable(treebot)

local brokenRex = Object.base("mapobject", "treebotBroken")
brokenRex.sprite = Sprite.load("treebotBroken", "Graphics/hiddenRex", 7, 15, 21)
local mask = Sprite.load("treebotBrokenMask", "Graphics/hiddenRexMask", 1, 15, 21)

local player = Object.find("P", "vanilla")
local useText = "&w&Press &y&'"..input.getControlString("enter").."'&w& to repair the robot. &y&(1 &or&Fuel Array&y&)&!&"

brokenRex:addCallback("create", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    self.name = "Broken Robot"
    this.mask = mask
    data.phase = 0
    this.spriteSpeed = 0
    this.y = FindGround(this.x, this.y)
end)
brokenRex:addCallback("step", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    if data.phase == 0 then
        if this:collidesWith(player:findNearest(this.x, this.y), this.x, this.y) then
            local target = player:findNearest(this.x, this.y)
            if input.checkControl("enter", target) == input.PRESSED then
                if target.useItem and target.useItem == Item.find("Fuel Array", "RoR2Demake") then
                    misc.shakeScreen(5)
                    Sound.find("BubbleShield", "vanilla"):play(1)
                    this.spriteSpeed = 0.25
                    powerPlant:increment(1)
                    data.phase = 1
                    return
                else
                    Sound.find("Error", "vanilla"):play(1)
                end
            end
        end
    end
end)
brokenRex:addCallback("draw", function(drone)
    local data = drone:getData()
    local self = drone:getAccessor()
    if drone:collidesWith(player:findNearest(drone.x, drone.y), drone.x, drone.y) and data.phase == 0 then
        graphics.alpha(1)
        local useFormatted = useText:gsub("&[%a]&", "")
        graphics.printColor(useText, (drone.x - (graphics.textWidth(useFormatted, graphics.FONT_DEFAULT) / 2)), (drone.y - (drone.sprite.height + (graphics.textHeight(useText, graphics.FONT_DEFAULT) + 5))), graphics.FONT_DEFAULT) 
    end
end)

callback.register("onStageEntry", function()
    if Stage.getCurrentStage().displayName == "Temple of the Elders" then
        brokenRex:create(220, 624)
    end
end)


return treebot
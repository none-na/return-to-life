
------ rex.lua
---- Adds REX from ROR2 as a playable character.

local treebot = Survivor.new("REX")

-- Load all of our sprites into a table
local sprites = {
	idle = Sprite.load("treebot_idle", "Actors/rex/idle", 1, 9, 18),
	walk = Sprite.load("treebot_walk_1", "Actors/rex/walk1", 6, 12, 18),
	jump = Sprite.load("treebot_jump", "Actors/rex/jump", 1, 9, 18),
	climb = Sprite.load("treebot_climb", "Actors/rex/climb", 4, 11, 23),
	death = Sprite.load("treebot_death", "Actors/rex/death", 14, 15, 18),
	-- This sprite is used by the Crudely Drawn Buddy
	-- If the player doesn't have one, the Commando's sprite will be used instead
	decoy = Sprite.load("treebot_decoy", "Actors/mult/idle1", 1, 9, 18),
}
-- The sprite used by the skill icons
local sprSkills = Sprite.load("treebot_skills", "Actors/rex/skills", 5, 0, 0)

local sprSkillsLoadout = Sprite.load("treebot_skills_loadout", "Actors/rex/skillsLoadout", 4, 0, 0)

treebot.idleSprite = sprites.idle

local Projectile = require("Libraries.Projectile")

local rexRecoilDamage = function(player, percentHP)
    local bullet = misc.fireBullet(player.x, player.y, 0, 1, (player:get("hp") * percentHP), "neutral", nil, DAMAGER_NO_PROC + DAMAGER_NO_RECALC)
    bullet:set("damage_fake", bullet:get("damage"))
    if bullet:get("critical") == 1 then
        bullet:set("critical", 0)
        bullet:set("damage", bullet:get("damage") / 2)
    end
    bullet:set("damage_fake", bullet:get("damage"))
end


-- Natural Toxins --
local weaken = Buff.new("treebotDebuff")
weaken.sprite = Sprite.load("EftreebotDebuff", "Actors/rex/debuff", 1, 9, 7)
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

-- DIRECTIVE: Inject --
local sprShoot1 = Sprite.load("treebot_shoot1", "Actors/rex/shoot1", 8, 10, 18)
local shoot1Snd = Sound.load("treebot_shoot1_snd","Sounds/SFX/rex/shoot1.ogg")--Sound.find("SamuraiShoot2", "vanilla")
local shoot1Impact = Sprite.find("Bite2", "vanilla")
local healSnd = Sound.find("Use", "vanilla")
local healParticle = ParticleType.find("Heal", "vanilla")
local healOrb = Object.find("EfHeal2", "vanilla")
registercallback("onHit", function(damager, hit, x, y)
    local parent = damager:getParent()
    if parent then
        if damager:get("drainHP") ~= nil and hit:isValid() then
            if damager:get("drainHP") > 0 then
                local heal = math.round(damager:get("damage") * damager:get("drainHP"))
                
                if modloader.checkFlag("rex_instant_heal") then
                    healSnd:play(0.9 + math.random() * 0.1)
                    healParticle:burst("above", parent.x, parent.y, damager:get("drainHP") * 10)
                    misc.damage(heal, parent.x, parent.y - (parent.sprite.height / 2), false, Color.DAMAGE_HEAL)
                    parent:set("hp", parent:get("hp") + (heal))
                else
                    local orb = healOrb:create(x, y)
                    orb:set("target", parent.id)
                    orb:set("value", heal)
                end
            end
        end
    end
end)

-- Seed Barrage --
local seedPhase = {}
local seedDirection = {}
local mortarOffset = {}
local defaultOffset = {x = 100, y = 0}
local sprShoot2 = Sprite.load("treebot_shoot2", "Actors/rex/shoot2", 6, 11, 54)
local shoot2Snd = Sound.load("treebot_shoot2_1_snd","Sounds/SFX/rex/shoot2_1.ogg")--Sound.find("ClayShoot1", "vanilla")
local shoot2ImpactSnd = Sound.load("treebot_shoot2_2_snd","Sounds/SFX/rex/shoot2_2.ogg")--Sound.find("MinerShoot4", "vanilla")
local walkBackwards = Sprite.load("treebot_walk_2", "Actors/rex/walk2", 6, 12, 18)

local enemies = ParentObject.find("enemies", "vanilla")
local collision = Object.find("B", "vanilla")

local mortarSprites = {
    warning = Sprite.load("EfTreeMortarWarning", "Actors/rex/mortarWarning", 6, 25, 7),
    detonate = Sprite.load("EfTreeMortarImpact", "Actors/rex/mortarImpact", 10, 25, 90)
}
local mortarDelay = 30



local seedBarrage = Object.new("EfTreeMortar")
seedBarrage.sprite = mortarSprites.warning

seedBarrage:addCallback("create", function(self)
    self.spriteSpeed = 0.25
    self:set("life", mortarDelay)
end)

seedBarrage:addCallback("step", function(self)
    self:set("life", self:get("life") - 1)
    if self:get("life") <= -1 then
        self.alpha = 0
        local parent = Object.findInstance(self:get("parent"))
        shoot2ImpactSnd:play(0.9 + math.random() * 0.2)
        misc.shakeScreen(5)
        if parent then
            local explosion = parent:fireExplosion(self.x, self.y + (self.sprite.height / 2), mortarSprites.warning.width / 19, mortarSprites.warning.width / 4, 4.5, mortarSprites.detonate, nil)
        end
        self:destroy()
    end
end)

registercallback("onPlayerStep", function(player)
    if player:getSurvivor() == treebot then
        if seedPhase[player] < 0 and input.checkControl("ability2") ~= input.HELD then
            player:set("activity", 0)
            seedPhase[player] = 2
            player.subimage = 0
            player:survivorActivityState(2, sprShoot2, 0.25, true, true)
        end
    end
end)

registercallback("onPlayerDrawAbove", function(player)
    if player:getSurvivor() == treebot then
        if seedPhase[player] == 1 and input.checkControl("ability2", player) == input.HELD then
            graphics.color(Color.WHITE)
            graphics.alpha(1)
            graphics.circle(player.x + ((mortarOffset[player].x or 100) * player.xscale), player.y + (mortarOffset[player].y or 0), mortarSprites.warning.width/2, true)
            for i=0, 100 do
                if i % 10 ~= 0 then
                    graphics.pixel(player.x + ((mortarOffset[player].x or 100) * player.xscale), (player.y + (mortarOffset[player].y or 0) - i) - mortarSprites.warning.width/2)
                end
            end
        end
    end
end)

local ChargeStep = function(player, frame)
    if seedPhase[player] == 0 and player:getAlarm(3) <= -1 then
        if player:getFacingDirection() == 180 then
            seedDirection[player] = -1
        else
            seedDirection[player] = 1
        end
        player:set("activity", 0)
        seedPhase[player] = 1
        player:survivorActivityState(2, sprites.idle, 0.25, true, true)
    elseif seedPhase[player] == 1 then
        if input.checkControl("ability2", player) == input.HELD then
            if player:get("free") == 1 then
                player.sprite = sprites.jump
            elseif input.checkControl("left", player) == input.HELD then
                if seedDirection[player] == -1 then
                    player.sprite = sprites.walk
                else
                    player.sprite = walkBackwards
                end
                player:set("pHspeed", -player:get("pHmax"))
            elseif input.checkControl("right", player) == input.HELD then
                if seedDirection[player] == -1 then
                    player.sprite = walkBackwards
                else
                    player.sprite = sprites.walk
                end
                player:set("pHspeed", player:get("pHmax"))
            else
                player.sprite = sprites.idle
            end
            if player.xscale ~= seedDirection[player] then
                player.xscale = seedDirection[player]
            end
            local enemyInRange = enemies:findLine(player.x, player.y, player.x + (mortarOffset[player].x * player.xscale), player.y + mortarOffset[player].y)
            if enemyInRange then
                mortarOffset[player].x = math.abs(player.x - (enemyInRange.x))
            else
                mortarOffset[player] = defaultOffset
            end
            if math.round(player.subimage) >= 6 then
                player:set("activity", 0)
                player:survivorActivityState(2, player.sprite, 0.25, true, true)
            end
        else
            player:set("activity", 0)
            seedPhase[player] = 2
            player.subimage = 0
            player:survivorActivityState(2, sprShoot2, 0.25, true, true)
        end
    elseif seedPhase[player] == 2 then
        if frame == 4 then
            shoot2Snd:play(0.9 + math.random() * 0.1)
            local mortar = seedBarrage:create(player.x + (mortarOffset[player].x * player.xscale), player.y + mortarOffset[player].y)
            rexRecoilDamage(player, 0.15)
            mortar:set("parent", player.id)
            mortarOffset[player].x = 100
            mortarOffset[player].y = 0
        elseif frame >= 5 then
            player:activateSkillCooldown(2)
            seedPhase[player] = 0
        end
    end
end

-- DIRECTIVE: Disperse --
local sprShoot3 = Sprite.load("treebot_shoot3", "Actors/rex/shoot3", 6, 10, 18)
local sonicBoom = Sprite.load("EfSonicBoom", "Actors/rex/sonicBoom", 7, 10, 10)
local shoot3Snd = Sound.load("treebot_shoot3_snd","Sounds/SFX/rex/shoot3.ogg")--Sound.find("CowboyShoot2", "vanilla")
registercallback("onHit", function(damager, hit, x, y)
    local parent = damager:getParent()
    if parent then
        if damager:get("sonicBoom") ~= nil and hit:isValid() then
            if damager:get("sonicBoom") > 0 then
                hit:set("lasthit_x", parent.x)
                hit:set("force_knockback", 1)
            end
        end
    end
end)


-- Tangling Growth --
local sprShoot4 = Sprite.load("treebot_shoot4", "Actors/rex/shoot4", 6, 10, 18)
local growthSprites = {
    seed = Sprite.load("EfSeed", "Actors/rex/seed", 10, 5, 7),
    seedScepter = Sprite.load("EfSeed2", "Actors/rex/seed2", 10, 5, 7),
    flower = Sprite.load("EfBrambleFlower", "Actors/rex/flower", 6, 8, 10),
    flowerScepter = Sprite.load("EfBrambleFlower2", "Actors/rex/flower2", 6, 8, 10),
    death = Sprite.load("EfBrambleFlowerDeath", "Actors/rex/flowerDeath", 5, 8, 10),
    deathScepter = Sprite.load("EfBrambleFlowerDeath2", "Actors/rex/flowerDeath2", 5, 8, 10),
    vine = Sprite.load("EfBrambleVine", "Actors/rex/vine", 1, 3, 8),
    vineScepter = Sprite.load("EfBrambleVine2", "Actors/rex/vine2", 1, 3, 8),
    debuff = Sprite.load("EfBrambleIcon", "Actors/rex/bramble", 1, 9, 7)
}
local shoot4Snd = Sound.find("MushShoot1", "vanilla")
local shoot4ImpactSnd = Sound.load("treebot_shoot4_snd","Sounds/SFX/rex/shoot4.ogg")----Sound.find("Pickup", "vanilla")
local snareSnd = Sound.load("treebot_snare_snd","Sounds/SFX/rex/snare.ogg")

local seedMissile = Projectile.new({
    name = "Tangling Growth",
    vx = 6,
    vy = 0,
    ax = 0,
    ay = 0.005,
    sprite = growthSprites.seed,
    mask = growthSprites.seed,
    damage = 2,
    pierce = false,
    life = 9999*60,
    explosion = true,
    ghost = false,
    multihit = false,
    explosionw = 20,
    explosionh = 20,
    impact_explosion = false,
    rotate = 5,
    })

local tanglingGrowth = Object.new("EfBramble")
tanglingGrowth.sprite = growthSprites.flower

local brambleDebuff = Buff.new("treeBotSnare")
brambleDebuff.sprite = growthSprites.debuff

brambleDebuff:addCallback("start", function(actor)
    actor:getData().originalSpeed = actor:get("pHmax")
    actor:set("pHmax", 0)
end)
brambleDebuff:addCallback("end", function(actor)
    actor:set("pHmax", actor:getData().originalSpeed or 1.3)
end)

local enemies = ParentObject.find("enemies", "vanilla")
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
    if math.round(self.subimage) >= growthSprites.flower.frames + 1 then
        self.spriteSpeed = 0
    end
    local data = self:getData()
    local parent = data.parent
    if self:get("life") > -1 then
        if self:get("life") == brambleLife then
            if parent then
                if parent:get("scepter") > 0 then
                    self:set("radius", self:get("radius") * 1.5)
                    self.sprite = growthSprites.flowerScepter
                end
            end
        end
        for _, enemyInst in ipairs(enemies:findAllEllipse(self.x - self:get("radius"), self.y - self:get("radius"), self.x + self:get("radius"), self.y + self:get("radius"))) do
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
                            snareSnd:play(1 + math.random() * 0.1)
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
                        healSnd:play(0.9 + math.random() * 0.1)
                        healParticle:burst("above", parent.x, parent.y, 10)
                        misc.damage(heal, parent.x, parent.y - (parent.sprite.height / 2), false, Color.DAMAGE_HEAL)
                        parent:set("hp", parent:get("hp") + (heal))
                    else
                        local orb = healOrb:create(self.x, self.y)
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
        local sprite = growthSprites.death
        if parent then
            if parent:get("scepter") > 0 then
                sprite = growthSprites.deathScepter
            end
        end
        self.sprite = sprite
        self.spriteSpeed = 0.25
        if math.round(self.subimage) >= growthSprites.death.frames - 1 then
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
    for _, enemy in ipairs(enemies:findAll()) do
        if enemy:get("bramble") then
            if enemy:hasBuff(brambleDebuff) and enemy:get("bramble") == self.id then
                if enemy:getObject() ~= Object.find("WormBody", "vanilla") or enemy:getObject() ~= Object.find("WurmBody", "vanilla") then
                    count = count + 1
                    local xx = enemy.x-self.x
                    local yy = enemy.y-self.y
                    local zz = math.sqrt(math.pow(xx, 2) + math.pow(yy, 2))
                    local angle2 = math.atan2(enemy.x-self.x,enemy.y-self.y) * (180/math.pi)
                    for i = 0, zz do
                        if i % growthSprites.vine.height == 0 then
                            local sprite = growthSprites.vine
                            if parent then
                                if parent:get("scepter") > 0 then
                                    sprite = growthSprites.vineScepter
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

seedMissile:addCallback("step", function(self)
    if self:isValid() then
        if self:get("Projectile_dead") > 0 then
            misc.shakeScreen(5)
            shoot4ImpactSnd:play(0.8 + math.random() * 0.2)
            local growthInst = tanglingGrowth:create(self.x, self.y)
            growthInst:getData().parent = Projectile.getParent(self)
        end
    end
end)



-- Set the description of the character and the sprite used for skill icons
treebot:setLoadoutInfo(
[[&y&REX&!& is a plant-robot hybrid that uses &g&HP&!& to cast devastating skills from a distance. 
The plant nor the robot could survive this planet alone - thankfully they have each other.
&b&Seed Barrage&!& can be positioned by holding the skill - &y&just make sure to watch your HP!&!&
A well-aimed &b&Tangling Growth&!& can keep REX in the fight forever. &y&Rooting multiple monsters&!&
will guarantee you recover the &g&initial HP costs&!&.]], sprSkillsLoadout)

-- Set the character select skill descriptions

treebot:setLoadoutSkill(1, "Natural Toxins",
[[Certain attacks &y&Weaken&!&, reducing movement speed, 
armor, and damage.]])

treebot:setLoadoutSkill(2, "DIRECTIVE: Inject",
[[Fire 3 syringes for &y&3*80% damage&!&. The last syringe 
&y&Weakens&!& and &g&heals for 30% of damage dealt&!&.]])

treebot:setLoadoutSkill(3, "Seed Barrage",
[[&r&Costs 15% of your current health&!&. Hold and release
to launch a mortar into the sky for &y&450% damage&!&.]])

treebot:setLoadoutSkill(4, "DIRECTIVE: Disperse:\n\n\nTangling Growth",
[[Fire a sonic boom that pushes and &y&Weakens&!& all enemies 
hit. &b&Pushes you backwards if you are airborne&!&.

&r&Costs 25% of your current health&!&. Fire a flower that 
roots for &y&200% damage&!&. &g&Heals for every target hit&!&.]])

-- The color of the character's skill names in the character select
treebot.loadoutColor = Color.fromRGB(134,158,85)

-- The character's sprite in the selection pod
treebot.loadoutSprite = Sprite.load("treebot_select", "Actors/rex/select", 12, 2, 0)
treebot.loadoutWide = true

-- The character's walk animation on the title screen when selected
treebot.titleSprite = sprites.walk

-- Quote displayed when the game is beat as the character
treebot.endingQuote = "..and so they left, their scars weighing them down forever."


-- Called when the player is created
treebot:addCallback("init", function(player)
	local playerA = player:getAccessor()
	local data = player:getData()
	-- Set the player's sprites to those we previously loaded
	player:setAnimations(sprites)
	-- Set the player's starting stats
    player:survivorSetInitialStats(130, 14, 0.01)
    -- initialize variables
    seedPhase[player] = 0
    seedDirection[player] = player.xscale
    mortarOffset[player] = defaultOffset
	-- Set the player's skill icons
	player:setSkill(1,
		"DIRECTIVE: Inject",
		"Fire 3 syringes for 3*80% damage. The last syringe Weakens and heals for 30% of damage dealt.",
		sprSkills, 1,
		30
	)
	player:setSkill(2,
		"Seed Barrage",
		"Costs 15% of your current health. Launch a mortar into the sky for 450% damage.",
		sprSkills, 2,
		10
	)
	player:setSkill(3,
		"DIRECTIVE: Disperse",
		"Fire a sonic boom that pushes and Weakens all enemies hit. Pushes you backwards if you are airborne.",
		sprSkills, 3,
		5 * 60
	)
	player:setSkill(4,
		"Tangling Growth",
		"Costs 25% of your current health. Fire a flower that roots for 200% damage. Heals for every target hit.",
		sprSkills, 4,
		60 * 12
	)
end)

-- Called when the player levels up
treebot:addCallback("levelUp", function(player)
	player:survivorLevelUpStats(39, 2.8, 0.002, 3)
end)

-- Called when the player picks up the Ancient Scepter
treebot:addCallback("scepter", function(player)
	player:setSkill(4,
		"Choking Bramble",
		"Costs 25% of your current health. Fire a flower that roots for 350% damage and Weakens snared targets. Heals for every target hit.",
		sprSkills, 5,
		60 * 12
	)
end)



-- Called when the player tries to use a skill
treebot:addCallback("useSkill", function(player, skill)
	-- Make sure the player isn't doing anything when pressing the button
	local playerA = player:getAccessor()
	if playerA.activity == 0 then
		-- Set the player's state
		if skill == 1 then
			-- Z skill
			player:survivorActivityState(1, sprShoot1, 0.25, true, true)
		elseif skill == 2 then
            -- X skill
            player:survivorActivityState(2, sprites.walk, 0.25, true, true)
		elseif skill == 3 then
			-- C skill
			player:survivorActivityState(3, sprShoot3, 0.25, true, true)
		elseif skill == 4 then
            -- V skill
            player:survivorActivityState(4, sprShoot4, 0.25, true, true)
		end
	end
end)

-- Called each frame the player is in a skill state
treebot:addCallback("onSkill", function(player, skill, relevantFrame)
	-- The 'relevantFrame' argument is set to the current animation frame only when the animation frame is changed
	-- Otherwise, it will be 0
	local playerA = player:getAccessor()
    local data = player:getData()
    
	if skill == 1 then 
		-- Z skill: DIRECTIVE: Inject
        if relevantFrame == 1 or relevantFrame == 3 or relevantFrame == 5 then
            if relevantFrame == 1 then
                player:survivorFireHeavenCracker(0.8)
            end
            shoot1Snd:play(1 + math.random() * 0.3)
            local syringe = player:fireBullet(player.x, player.y, player:getFacingDirection(), 9999, 0.8, shoot1Impact, nil)
            if relevantFrame == 5 then
                syringe:set("weaken", 1)
                syringe:set("drainHP", 0.3)
            end
        elseif relevantFrame >= 7 then
            player:activateSkillCooldown(1)
        end
		
		
	elseif skill == 2 then
        -- X skill: Seed Barrage
        
	elseif skill == 3 then
        -- C skill: DIRECTIVE: Disperse
        if relevantFrame == 1 then

        end
        if relevantFrame > 1 and player:get("free") == 1 then
            player:set("pHspeed", ((10 * player:get("pHmax")) / relevantFrame) * -player.xscale)
        end
        if relevantFrame == 2 then
            player:set("pVspeed", 0)
            shoot3Snd:play(1 + math.random() * 0.2)
            local boomInst = player:fireExplosion(player.x + (10 * player.xscale), player.y, sonicBoom.width/19, sonicBoom.height/4, 0, sonicBoom, nil, DAMAGER_NO_PROC)
            boomInst:set("weaken", 2)
            boomInst:set("sonicBoom", 1)
            boomInst:set("knockback", 10)
        elseif relevantFrame >= 5 then
            player:activateSkillCooldown(3)
        end
		
	elseif skill == 4 then
        -- V skill: Tangling Growth
        if relevantFrame == 2 then
            shoot4Snd:play(0.9 + math.random() * 0.1)
            rexRecoilDamage(player, 0.25)
            local seedInst = Projectile.fire(seedMissile, player.x + (2 * player.xscale), player.y - 1, player)
            if player:get("scepter") > 0 then
                Projectile.configure(seedInst,{
                    sprite = growthSprites.seedScepter,
                    damage = 3.5
                })
            end
        elseif relevantFrame >= 5 then
            player:activateSkillCooldown(4)
        end
	end
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
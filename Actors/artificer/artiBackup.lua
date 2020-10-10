
------ Artificer.lua
---- Adds Artificer from ROR2 as a playable character.

local mage = Survivor.new("Artificer")

-- Load all of our sprites into a table
local sprites = {
	idle = Sprite.load("mage_idle", "Actors/artificer/idle", 1, 4, 7),
	walk = Sprite.load("mage_walk", "Actors/artificer/walk", 4, 4, 7),
	jump = Sprite.load("mage_jump", "Actors/artificer/jump", 1, 4, 7),
	climb = Sprite.load("mage_climb", "Actors/artificer/climb", 2, 4, 7),
	death = Sprite.load("mage_death", "Actors/artificer/death", 6, 7, 8),
	-- This sprite is used by the Crudely Drawn Buddy
	-- If the player doesn't have one, the Commando's sprite will be used instead
	decoy = Sprite.load("mage_decoy", "Actors/artificer/decoy", 1, 8, 11),
}
-- The sprite used by the skill icons
local sprSkills = Sprite.load("mage_skills", "Actors/artificer/skills", 10, 0, 11)

local sprSkillsLoadout = Sprite.load("mage_skills_loadout", "Actors/artificer/skillsLoadout", 4, 0, 0)

mage.idleSprite = sprites.idle

local Projectile = require("Libraries.Projectile")
local Burn = require("Misc.burn")

-- Flame Bolt --
local boltCount = {}
local maxBolts = 4
local boltRechargeDelay = 30
local sprShoot1 = Sprite.load("mage_shoot1", "Actors/artificer/shoot1", 4, 4, 8)
local shoot1Snd = Sound.find("Bullet3", "vanilla")
local shoot1ImpactSnd = Sound.find("GiantJellyExplosion", "vanilla")
local shoot1FX = ParticleType.find("Spark", "vanilla")
local boltSpr = Sprite.load("EfFireboltSpr", "Actors/artificer/bolt", 4, 12, 4)
local boltMask = Sprite.load("boltMask", "Actors/artificer/boltMask", 1, 12, 4)
local fireBolt = Projectile.new({
    name = "Firebolt",
    vx = 5,
    vy = 0,
    ax = 0,
    ay = 0,
    sprite = boltSpr,
    mask = boltMask,
    damage = 2,
    pierce = false,
    deathsprite_life = Sprite.find("EfFirey","vanilla"),
    deathsprite_collision = Sprite.find("EfFirey","vanilla"),
    life = 999*60,
    explosion = false,
    ghost = false,
    multihit = false,
    impact_explosion = true,
    damager_variables = {burn = 1}
    })
fireBolt:addCallback("create", function(self)
    if self:isValid() then
        self.spriteSpeed = 0.25
        if math.random() <= 0.5 then
            self.yscale = -1
        end
    end
end)
fireBolt:addCallback("step", function(self)
    if self:isValid() then
        if self:get("Projectile_life") % 5 == 0 then
            shoot1FX:burst("middle", self.x, self.y, 1)
        end
        if self:get("Projectile_dead") > 0 then
            shoot1ImpactSnd:play(0.8 + math.random() * 0.2)
        end
    end
end)

registercallback("onPlayerStep", function(player)
	local playerA = player:getAccessor()
	if(player:getSurvivor() == mage) then
		if player:getAlarm(11) <= 1 and player:getAlarm(2) == -1 then
			if boltCount[player] < maxBolts then
				boltCount[player] = boltCount[player] + 1
			end
			player:setAlarm(11, boltRechargeDelay)
		elseif player:getAlarm(2) == 1 then
			if boltCount[player] < maxBolts then
				boltCount[player] = boltCount[player] + 1
			end
			player:setAlarm(11, boltRechargeDelay)
		end
		player:setSkill(1,
		"Flame Bolt",
		"Fire a bolt for 200% that ignites enemies. Hold up to 4.",
		sprSkills, math.clamp(boltCount[player] + 1, 1, 5),
		60*1.3
		)
	end
end)

-- Nano Bomb --
local nanoBombCharge = {}
local nanoBombPhase = {}
local maxCharge = 120
local shoot2Snd = Sound.load("mage_shoot2_fire_snd", "Sounds/SFX/artificer/mageFireNanoBomb.ogg")--Sound.find("MissileLaunch", "vanilla")
local sprShoot2_1 = Sprite.load("mage_shoot2_charge1", "Actors/artificer/shoot2_charge1", 2, 7, 8)
local sprShoot2_2 = Sprite.load("mage_shoot2_charge2", "Actors/artificer/shoot2_charge2", 2, 7, 8)
local sprShoot2_3 = Sprite.load("mage_shoot2_charge3", "Actors/artificer/shoot2_charge3", 2, 7, 8)
local sprShoot2_4 = Sprite.load("mage_shoot2_charge4", "Actors/artificer/shoot2_charge4", 2, 7, 8)
local sprShoot2_5 = Sprite.load("mage_shoot2_fire", "Actors/artificer/shoot2_fire", 6, 7, 8)

local nanoBombSpr = Sprite.load("EfNanoBomb", "Actors/artificer/nanoBomb", 8, 8.5, 8.5)
local nanoBombImpactSpr = Sprite.load("EfNanoBombImpact", "Actors/artificer/nanoBombImpact", 21, 17, 19)
local nanoBombChargeSnd = Sound.load("mage_shoot2_charge_snd", "Sounds/SFX/artificer/mageNanoBombCharge.ogg")--Sound.find("BossSkill2", "vanilla")
local nanoBombImpactSnd = Sound.load("mage_shoot2_impact_snd", "Sounds/SFX/artificer/mageNanoBombImpact.ogg")--Sound.find("BossSkill2", "vanilla")
local nanoBombMask = Sprite.load("EfNanoBombMask", "Actors/artificer/nanoBombMask", 1, 8.5, 8.5)
local nanoBombFX = ParticleType.find("FireIce", "vanilla")

local enemies = ParentObject.find("enemies", "vanilla")
local shockRange = 30
local nanobomb = Projectile.new({
    name = "Charged Nano-Bomb",
    vx = 2.5,
    vy = 0,
    ax = 0,
    ay = 0,
    sprite = nanoBombSpr,
    mask = nanoBombMask,
    damage = 2,
    pierce = false,
    deathsprite_life = nanoBombImpactSpr,
    deathsprite_collision = nanoBombImpactSpr,
    life = 999*60,
    explosion = true,
    ghost = false,
    multihit = false,
    impact_explosion = true,
	explosionw = 100,
	explosionh = 100,
    damager_variables = {lightning = 1}
    })
    
local lightning = Object.find("ChainLightning", "vanilla")
nanobomb:addCallback("create", function(self)
    if self:isValid() then
        self:set("scale", self.xscale)
    end
end)

nanobomb:addCallback("step", function(self)
    if self:isValid() then
        if self:get("chargeCoefficient") then
            self.xscale = math.clamp(self:get("scale") * (self:get("chargeCoefficient") / maxCharge), 0.5, 1)
            self.yscale = math.clamp(self:get("scale") * (self:get("chargeCoefficient") / maxCharge), 0.5, 1)
        end
        if self:get("Projectile_dead") > 0 then
            misc.shakeScreen(15)
            nanoBombImpactSnd:play(0.9 + math.random() * 0.2)
        elseif self:get("Projectile_life") % 10 == 0 and self:get("Projectile_dead") <= 0 then
            nanoBombFX:burst("middle", self.x, self.y, 1)
            local nearestEnemy = enemies:findNearest(self.x, self.y)
            if nearestEnemy ~= nil then
                if (nearestEnemy.x <= self.x + shockRange and nearestEnemy.x >= self.x - shockRange) and (nearestEnemy.y <= self.y + shockRange and nearestEnemy.y >= self.y - shockRange) then
                    local lightningInst = lightning:create(self.x, self.y)
                    lightningInst:set("damage", (Projectile.getParent(self):get("damage") * 0.5))
                end
            end
        end
    end
end)

-- Snapfreeze --
local sprShoot3 = Sprite.load("mage_shoot3", "Actors/artificer/shoot3", 8, 8, 8)
local iceSprites = {
    idle = Sprite.load("EfSnapfreeze", "Actors/artificer/iceIdle", 7, 6, 4),
    mask = Sprite.load("EfSnapfreezeMask", "Actors/artificer/iceMask", 1, 6, 4),
    spawn = Sprite.load("EfSnapfreezeSummon", "Actors/artificer/iceSpawn", 4, 6, 12),
    death = Sprite.load("EfSnapfreezeDeath", "Actors/artificer/iceDeath", 7, 6, 7),
    impact = Sprite.find("Sparks2", "vanilla")
}

local iceSnd = Sound.find("MissileLaunch","vanilla")
local iceDeathSnd = Sound.find("Frozen","vanilla")

local icePillar = Object.new("EfSnapfreeze")
icePillar.sprite = iceSprites.idle

local enemies = ParentObject.find("enemies", "vanilla")

icePillar:addCallback("create", function(self)
    
    iceSnd:play(0.9 + math.random() * 0.2)
    self.mask = iceSprites.mask
    self.sprite = iceSprites.spawn
    self.spriteSpeed = 0.25
    if math.random() < 0.5 then
        self.xscale = -1
    end
    self:set("state", 0)
    self:set("life", 10*60)
    local data = self:getData()
    if self:collidesMap(self.x, self.y) then
        local closestGround = Object.find("B", "vanilla"):findNearest(self.x, self.y)
        self.y = closestGround.y - (iceSprites.idle.height/2)
    end
    data.hit = {}
end)

icePillar:addCallback("step", function(self)
    if self:get("state") == 0 then
        if math.round(self.subimage) >= iceSprites.spawn.frames then
            self:set("state", 1)
            self.sprite = iceSprites.idle
            self.subimage = 0
        end
    elseif self:get("state") == 1 then
        self:set("life", self:get("life") - 1)
        if self:get("life") > -1 then
            local data = self:getData()
            for _, enemy in ipairs(enemies:findAll()) do
                if enemy:isValid() then
                    if not data.hit[enemy] then
                        if self:collidesWith(enemy, self.x, self.y) then
                            local hit
                            if data.parent then
                                hit = data.parent:fireBullet(self.x, self.y, 0, 1, 1, iceSprites.impact)
                            else
                                hit = misc.fireBullet(self.x, self.y, 0, 1, 14, "player",  iceSprites.impact)
                            end
                            hit:set("specific_target", enemy.id)
                            hit:set("freeze", 1)
                            if enemy:get("hp") <= (enemy:get("maxhp") * 0.2) and not enemy:isBoss() then
                                enemy:kill()
                            end
                            table.insert(data.hit, enemy)
                            self:set("life", -1)
                        end
                    end
                end
            end
        else
            self.sprite = iceSprites.death
            self:set("state", 2)
            self.subimage = 1
            iceDeathSnd:play(0.9 + math.random() * 0.2)
        end
    elseif self:get("state") == 2 then
        if math.round(self.subimage) >= iceSprites.death.frames - 1 then
            self.alpha = 0
            self:destroy()
        end
    end
end)


-- Flamethrower --
local flamethrowerPhase = {}
local flamethrowerDirection = {}
local flamethrowerLoop = {}
local maxFlamethrowerTime = 5*60
local sprShoot4_1_idle = Sprite.load("mage_shoot4_1_idle", "Actors/artificer/shoot4_1_1", 4, 5, 7)
local sprShoot4_1_forwards = Sprite.load("mage_shoot4_1_forwards", "Actors/artificer/shoot4_1_2", 4, 5, 7)
local sprShoot4_1_backwards = Sprite.load("mage_shoot4_1_backwards", "Actors/artificer/shoot4_1_3", 4, 5, 7)

local fireStartSnd = Sound.load("mage_shoot4_start_snd", "Sounds/SFX/artificer/mageFlamethrowerStart.ogg")--Sound.find("WispBShoot1", "vanilla")
local fireLoopSnd = Sound.find("WormBurning", "vanilla")

local sprShoot4_2_idle = Sprite.load("mage_shoot4_2_idle", "Actors/artificer/shoot4_2_1", 4, 5, 7)
local sprShoot4_2_forwards = Sprite.load("mage_shoot4_2_forwards", "Actors/artificer/shoot4_2_2", 4, 5, 7)
local sprShoot4_2_backwards = Sprite.load("mage_shoot4_2_backwards", "Actors/artificer/shoot4_2_3", 4, 5, 7)

local sprFireL1 = Sprite.load("efFlamethrowerL", "Actors/artificer/flamethrowerL1", 6, 32, 7.5)
local sprFireR1 = Sprite.load("efFlamethrowerR", "Actors/artificer/flamethrowerR1", 6, 32, 7.5)
local sprFireL2 = Sprite.load("efFlamethrowerSuperL", "Actors/artificer/flamethrowerL2", 6, 32, 7.5)
local sprFireR2 = Sprite.load("efFlamethrowerSuperR", "Actors/artificer/flamethrowerR2", 6, 32, 7.5)

registercallback("onGameEnd", function()
    if fireLoopSnd:isPlaying() then
        fireLoopSnd:stop()
    end
end)

-- ENV Suit --
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


registercallback("onPlayerStep", function(player)
    if player:isValid() then
        if player:getSurvivor() == mage then
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
    end
end)


-- Set the description of the character and the sprite used for skill icons
mage:setLoadoutInfo(
[[&y&Artificer&!& is a high burst damage survivor who excels in &y&fighting large groups 
and bosses alike&!&. &y&Flame Bolt&!& &y&expends stocks quickly&!& but &y&recharges slowly&!& - try 
to weave in basic attacks between skill casts. &b&Frozen enemies&!& are &y&executed at
low health&!&, making it great to eliminate tanky enemies. Remember that Artificer 
has &y&NO defensive skills&!& - positioning and defensive items are key!]], sprSkillsLoadout)

-- Set the character select skill descriptions

mage:setLoadoutSkill(1, "ENV Suit",
[[Holding the &y&Jump key&!& causes the Artificer to 
hover in the air.]])

mage:setLoadoutSkill(2, "Flame Bolt",
[[Fire a bolt for &y&200% damage&!& that &r&ignites&!& enemies. 
&b&Hold up to 4&!&.]])

mage:setLoadoutSkill(3, "Charged Nano-Bomb",
[[Charge a nano-bomb that deals &y&400%-1200% damage&!& 
and stuns enemies.]])

mage:setLoadoutSkill(4, "Snapfreeze:\n\n\nFlamethrower",
[[Create a barrier that &b&freezes enemies&!& for &y&100% damage&!&. 
Enemies at low health are &y&instantly killed if frozen&!&.

&r&Burn&!& all enemies in front of you for &y&1700% damage&!&.]])

-- The color of the character's skill names in the character select
mage.loadoutColor = Color.fromRGB(247,193,253)

-- The character's sprite in the selection pod
mage.loadoutSprite = Sprite.load("mage_select", "Actors/artificer/select", 4, 2, 0)
mage.loadoutWide = false

-- The character's walk animation on the title screen when selected
mage.titleSprite = sprites.walk

-- Quote displayed when the game is beat as the character
mage.endingQuote = "..and so she left, her quest for knowledge having crippled her boundless curiosity."


-- Called when the player is created
mage:addCallback("init", function(player)
	local playerA = player:getAccessor()
	local data = player:getData()
	-- Set the player's sprites to those we previously loaded
	player:setAnimations(sprites)
	-- Set the player's starting stats
    player:survivorSetInitialStats(110, 14, 0.01)
    -- initialize variables
    nanoBombPhase[player] = 0
    nanoBombCharge[player] = 0
    boltCount[player] = maxBolts
    envSuit[player] = 0
    flamethrowerPhase[player] = 0
    flamethrowerLoop[player] = 0
    flamethrowerDirection[player] = player.xscale
	-- Set the player's skill icons
	player:setSkill(1,
		"Flame Bolt",
		"Fire a bolt for 200% damage that ignites enemies.",
		sprSkills, 4,
		60*1.3
	)
	player:setSkill(2,
		"Charged Nano-Bomb",
		"Charge a nano-bomb that deals 400%-1200% damage and stuns enemies.",
		sprSkills, 7,
		5 * 60
	)
	player:setSkill(3,
		"Snapfreeze",
		"Create a barrier that freezes enemies for 100% damage. Enemies at low health are instantly killed if frozen.",
		sprSkills, 8,
		12 * 60
	)
	player:setSkill(4,
		"Flamethrower",
		"Burn all enemies in front of you for 1700% damage.",
		sprSkills, 9,
		60 * 5
	)
end)

-- Called when the player levels up
mage:addCallback("levelUp", function(player)
	player:survivorLevelUpStats(33, 2.4, 0.003, 2.4)
end)

-- Called when the player picks up the Ancient Scepter
mage:addCallback("scepter", function(player)
	player:setSkill(4,
		"Plasma Wave",
		"Incinerate all enemies in front of you for 2500% damage. Shocks nearby enemies.",
		sprSkills, 10,
		60 * 5
	)
end)



-- Called when the player tries to use a skill
mage:addCallback("useSkill", function(player, skill)
	-- Make sure the player isn't doing anything when pressing the button
	local playerA = player:getAccessor()
	if playerA.activity == 0 then
		-- Set the player's state
		if skill == 1 then
			-- Z skill
			player:survivorActivityState(1, sprShoot1, 0.25, true, true)
		elseif skill == 2 then
            -- X skill
			player:survivorActivityState(2, sprShoot2_1, 0.25, true, true)
		elseif skill == 3 then
			-- C skill
			player:survivorActivityState(3, sprShoot3, 0.25, true, true)
		elseif skill == 4 then
            -- V skill
            if player:get("scepter") > 0 then
                player:survivorActivityState(4, sprShoot4_2_idle, 0.25, true, true)
            else
                player:survivorActivityState(4, sprShoot4_1_idle, 0.25, true, true)
            end
		end
	end
end)

-- Called each frame the player is in a skill state
mage:addCallback("onSkill", function(player, skill, relevantFrame)
	-- The 'relevantFrame' argument is set to the current animation frame only when the animation frame is changed
	-- Otherwise, it will be 0
	local playerA = player:getAccessor()
	
	if skill == 1 then 
		-- Z skill: fireBolt
        if relevantFrame == 2 then
            shoot1Snd:play(0.9 + math.random() * 0.1)
            if player:survivorFireHeavenCracker(2) == nil then
                local boltInst = Projectile.fire(fireBolt, player.x + (7 * player.xscale), player.y - 3, player)
                boltCount[player] = boltCount[player] - 1
			    player:setAlarm(11, boltRechargeDelay)
			    if boltCount[player] < 1 then
                    player:activateSkillCooldown(1)
                    player:setAlarm(2, 1.3*60)
		    	end    
            end
            
        end
		
		
	elseif skill == 2 then
        -- X skill: Charged Nano-Bomb
        if nanoBombPhase[player] == 0 then
            if relevantFrame == 1 then
                nanoBombCharge[player] = 0
                nanoBombPhase[player] = 1
                player:set("activity", 0)
                player:survivorActivityState(2, sprShoot2_1, 0.25, true, true)
                nanoBombChargeSnd:play(player:get("attack_speed") + math.random() * 0.05)
            end
        elseif nanoBombPhase[player] == 1 then
            nanoBombCharge[player] = nanoBombCharge[player] + player:get("attack_speed")
            if input.checkControl("ability2", player) == input.HELD and nanoBombCharge[player] < maxCharge then
                if relevantFrame >= 1 then
                    player:set("activity", 0)
                    if nanoBombCharge[player] <= 30 then
                        player:survivorActivityState(2, sprShoot2_1, 0.25, true, true)
                    elseif nanoBombCharge[player] > 30 and nanoBombCharge[player] <= 60 then
                        player:survivorActivityState(2, sprShoot2_2, 0.25, true, true)
                    elseif nanoBombCharge[player] > 60 and nanoBombCharge[player] <= 90 then
                        player:survivorActivityState(2, sprShoot2_3, 0.25, true, true)
                    elseif nanoBombCharge[player] > 90 then
                        player:survivorActivityState(2, sprShoot2_4, 0.25, true, true)
                    end
                    nanoBombPhase[player] = 1
                end
            else
                nanoBombPhase[player] = 2
                player:set("activity", 0)
                player:survivorActivityState(2, sprShoot2_5, 0.25, true, true)
            end
        elseif nanoBombPhase[player] == 2 then
            if relevantFrame == 2 then
                if nanoBombChargeSnd:isPlaying() then
                    nanoBombChargeSnd:stop()
                end
                shoot2Snd:play(0.9 + math.random() * 0.2)
                local nanoInst = Projectile.fire(nanobomb, player.x + (7 * player.xscale), player.y - 3, player)
                nanoInst:set("chargeCoefficient", (nanoBombCharge[player]))
                Projectile.configure(nanoInst,
                {
                    damage = math.clamp(2 + (12 * (nanoBombCharge[player] / maxCharge)), 2, 14),
                    explosionw = math.clamp(100 * (nanoBombCharge[player] / maxCharge), 25, 100),
                    explosionh= math.clamp(100 * (nanoBombCharge[player] / maxCharge), 25, 100),
                })
            elseif relevantFrame == 5 then
                player:activateSkillCooldown(2)
                nanoBombPhase[player] = 0
                nanoBombCharge[player] = 0
            end
        end

	elseif skill == 3 then
		-- C skill: Snapfreeze
        if relevantFrame >= 4 and relevantFrame <= 7 then
            local iceInst = icePillar:create(player.x + ((15 * relevantFrame)*player.xscale), player.y)
            iceInst:getData().parent = player
            if relevantFrame >= 7 then
                player:activateSkillCooldown(3)
            end
        end
		
		
	elseif skill == 4 then
        -- V skill: Flamethrower
        if flamethrowerPhase[player] == 0 and player:getAlarm(5) == -1 then
            if flamethrowerLoop[player] == 0 then
                fireStartSnd:play(0.8 + math.random() * 0.2)
                fireLoopSnd:loop()
                if player:getFacingDirection() == 180 then
                    flamethrowerDirection[player] = -1
                else
                    flamethrowerDirection[player] = 1
                end
            end
            flamethrowerLoop[player] = flamethrowerLoop[player] + 1
            if player:get("scepter") > 0 then
                if input.checkControl("left", player) == input.HELD then
                    if flamethrowerDirection[player] == -1 then
                        player.sprite = sprShoot4_2_forwards
                    else
                        player.sprite = sprShoot4_2_backwards
                    end
                    player:set("pHspeed", -player:get("pHmax"))
                elseif input.checkControl("right", player) == input.HELD then
                    if flamethrowerDirection[player] == -1 then
                        player.sprite = sprShoot4_2_backwards
                    else
                        player.sprite = sprShoot4_2_forwards
                    end
                    player:set("pHspeed", player:get("pHmax"))
                else
                    player.sprite = sprShoot4_2_idle
                end
            else
                if input.checkControl("left", player) == input.HELD then
                    if flamethrowerDirection[player] == -1 then
                        player.sprite = sprShoot4_1_forwards
                    else
                        player.sprite = sprShoot4_1_backwards
                    end
                    player:set("pHspeed", -player:get("pHmax"))
                elseif input.checkControl("right", player) == input.HELD then
                    if flamethrowerDirection[player] == -1 then
                        player.sprite = sprShoot4_1_backwards
                    else
                        player.sprite = sprShoot4_1_forwards
                    end
                    player:set("pHspeed", player:get("pHmax"))
                else
                    player.sprite = sprShoot4_1_idle
                end
            end
            if player.xscale ~= flamethrowerDirection[player] then
                player.xscale = flamethrowerDirection[player]
            end
            if flamethrowerLoop[player] == 0 or flamethrowerLoop[player] % 8 == 0 then
                local fire
                if player:get("scepter") > 0 then
                    if flamethrowerDirection[player] == -1 then
                        if flamethrowerLoop[player] % 5 == 0 then
                            fire = player:fireExplosion(player.x + (40 * player.xscale), player.y - 4, (sprFireR1.width/19), sprFireR1.height / 4, 1, sprFireL2, Sprite.find("EfFirey","vanilla"), DAMAGER_NO_PROC) 
                        else
                            fire = player:fireExplosion(player.x + (40 * player.xscale), player.y - 4, (sprFireR1.width/19), sprFireR1.height / 4, 1, sprFireL2, Sprite.find("EfFirey","vanilla"))
                        end
                    else
                        if flamethrowerLoop[player] % 5 == 0 then
                            fire = player:fireExplosion(player.x + (40 * player.xscale), player.y - 4, (sprFireR1.width/19), sprFireR1.height / 4, 1, sprFireR2, Sprite.find("EfFirey","vanilla"), DAMAGER_NO_PROC) 
                        else
                            fire = player:fireExplosion(player.x + (40 * player.xscale), player.y - 4, (sprFireR1.width/19), sprFireR1.height / 4, 1, sprFireR2, Sprite.find("EfFirey","vanilla")) 
                        end
                    end
                    fire:set("lightning", 1)
                else
                    if flamethrowerDirection[player] == -1 then
                        if flamethrowerLoop[player] % 5 == 0 then
                            fire = player:fireExplosion(player.x + (40 * player.xscale), player.y - 4, (sprFireR1.width/19), sprFireR1.height / 4, 0.68, sprFireL1, Sprite.find("EfFirey","vanilla"), DAMAGER_NO_PROC) 
                        else
                            fire = player:fireExplosion(player.x + (40 * player.xscale), player.y - 4, (sprFireR1.width/19), sprFireR1.height / 4, 0.68, sprFireL1, Sprite.find("EfFirey","vanilla")) 
                        end
                    else
                        if flamethrowerLoop[player] % 5 == 0 then
                            fire = player:fireExplosion(player.x + (40 * player.xscale), player.y - 4, (sprFireR1.width/19), sprFireR1.height / 4, 0.68, sprFireR1, Sprite.find("EfFirey","vanilla"), DAMAGER_NO_PROC) 
                        else
                            fire = player:fireExplosion(player.x + (40 * player.xscale), player.y - 4, (sprFireR1.width/19), sprFireR1.height / 4, 0.68, sprFireR1, Sprite.find("EfFirey","vanilla")) 
                        end
                    end
                end
                fire:set("burn", 0.1)
                player:set("activity", 0)
                if player:get("scepter") > 0 then
                    player:survivorActivityState(4, sprShoot4_2_idle, 0.25, true, true)

                else
                    player:survivorActivityState(4, sprShoot4_1_idle, 0.25, true, true)
                end
            end
            if flamethrowerLoop[player] >= maxFlamethrowerTime then
                flamethrowerPhase[player] = 1
            end
        elseif flamethrowerPhase[player] == 1 then
            print("phase 1")
            player:activateSkillCooldown(4)
            if fireLoopSnd:isPlaying() then
                fireLoopSnd:stop()
            end
            flamethrowerLoop[player] = 0
            flamethrowerPhase[player] = 0
        end
	end
end)

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
                Sound.find("Teleporter", "vanilla"):play(1 + math.random() * 0.05)
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
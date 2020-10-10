
local palettes = {
    glacial = Sprite.load("GlacialPal", "Graphics/elitePalGlacial", 1, 0, 0),
    malachite = Sprite.load("PoisonPal", "Graphics/elitePalPoison", 1, 0, 0),
    celestine = Sprite.load("HauntedPal", "Graphics/elitePalHaunted", 1, 0, 0),
}

local actors = ParentObject.find("actors", "vanilla")

-----------------------------------------------

local Glacial = EliteType.new("Glacial")
local Malachite = EliteType.new("Malachite")
local Celestine = EliteType.new("Celestine")

local vanillaElites = {
    Blazing = EliteType.find("Blazing", "vanilla"),
    Overloading = EliteType.find("Overloading", "vanilla"),
    Leeching = EliteType.find("Leeching", "vanilla"),
    Frenzied = EliteType.find("Frenzied", "vanilla"),
    Volatile = EliteType.find("Volatile", "vanilla"),
}

-----------------------------------------------

local enemies = MonsterCard.findAll("vanilla")
for _, card in ipairs(enemies) do
    card.eliteTypes:add(Glacial)
    if not card.isBoss then
        card.eliteTypes:add(Malachite)
        card.eliteTypes:add(Celestine)
    end
end


-----------------------------------------------

local spawnSignal = {
    [Malachite] = Sound.load("PoisonElite", "Sounds/SFX/malachite.ogg"), --Malachite
    [Celestine] = Sound.load("HauntedElite", "Sounds/SFX/celestine.ogg"), --Celestine
}

local costModifier = {
    [Malachite] = 36,
    [Celestine] = 25,
}

local affixes = {
    [vanillaElites.Blazing] = affixRed,
    [vanillaElites.Frenzied] = affixYellow,
    [vanillaElites.Leeching] = affixGreen,
    [vanillaElites.Overloading] = affixBlue,
    [vanillaElites.Volatile] = affixOrange,
    [Glacial] = affixWhite,
    [Malachite] = affixPoison,
    [Celestine] = affixHaunted
}

local InitElites = {}

local SetElites = function(_, prefix, id)
    local actor = Object.findInstance(id)
    if actor then
        actor:makeElite(EliteType.find("prefix"))
        if prefix and InitElites[prefix] then
            InitElites[prefix](actor)
        end
    end
end

local SyncEliteReRoll = net.Packet("syncRoR2EliteReRoll", SetElites)

callback.register("onActorInit", function(actor)
    if type(actor) ~= "PlayerInstance" then
        local prefix = actor:getElite()
        if prefix and net.host then
            --Check if director can afford total cost
            local card = nil
            for _, c in ipairs(enemies) do
                if actor:getObject() == c.object then
                    card = c
                    break
                end
            end
            if card then
                local cost = card.cost
                local director = misc.director
                local prefixes = card.eliteTypes
                if prefixes then
                    prefixes:remove(prefix)
                    local costMod = costModifier[prefix] or 1
                    --print("Checking if Director can afford "..prefix:getName().." "..actor:getObject():getName().." ("..costMod.." x "..cost..")")
                    if director:get("points") < ((cost * costMod) - cost) then
                        --print("Attempting to roll for new EliteType.")
                        local attempts = prefixes:len()
                        for i = 0, attempts do
                            local eliteType = prefixes:toTable()[math.random(prefixes:len())]
                            local costMod = costModifier[eliteType] or 1
                            --print("Checking if Director can afford "..eliteType:getName().." "..actor:getObject():getName().." ("..costMod.." x "..cost..")")
                            if director:get("points") >= ((cost * costMod) - cost) then
                                --print("Director can afford "..eliteType:getName().." "..actor:getObject():getName().." ("..costMod.." x "..cost.." >= "..director:get("points")..")!")
                                prefix = eliteType
                                actor:makeElite(eliteType)
                                if net.online then
                                    SyncEliteReRoll(net.ALL, nil, eliteType:getName(), actor.id)
                                end
                                break
                            end
                        end
                    end
                end 
            end
            if prefix and InitElites[prefix] then
                InitElites[prefix](actor)
            end
        end
    end
end)

eliteCheck = function(actor, prefix)
    if actor and actor:isValid() then
        if type(actor) == "PlayerInstance" then
            if (affixes[prefix] and actor.useItem == affixes[prefix]) or (EliteAffixBuffs[prefix] and actor:hasBuff(EliteAffixBuffs[prefix])) then
                return true
            else
                return false
            end

        elseif type(actor) == "ActorInstance" then
            if actor:getElite() == prefix then
                return true
            else
                return false
            end
        end
    end
    return false

end

-----------------------------------------------
-- Changes to Vanilla elites --
if not modloader.checkFlag("disable_elite_updates") then
    
    -- Blazing --
    local burn = Burned
    callback.register("onFire", function(damager)
        local parent = damager:getParent()
        if parent then
            if eliteCheck(parent, vanillaElites.Blazing) then --Blazing
                if parent:get("elite_is_hard") == 1 then
                    damager:set("burn", 2.5)
                else
                    damager:set("burn", 1)
                end
            end
        end
    end)
    

    -- Overloading --
    callback.register("onFire", function(damager)
        damager:set("overloadingMine", 0)
        local parent = damager:getParent()
        if parent then
            if eliteCheck(parent, vanillaElites.Overloading) then
                if parent:get("elite_is_hard") == 1 then
                    damager:set("overloadingMine", 2)
                else
                    damager:set("overloadingMine", 1)
                end
            end
        end
    end)

    local shield = Sprite.load("OverloadingShield", "Graphics/overloadingShield", 1, 5, 5)
    
    callback.register("onActorInit", function(actor)
        local a = actor:getAccessor()
        if actor:getObject() ~= Object.find("WormHead") and actor:getObject() ~= Object.find("WormBody") then
            if eliteCheck(actor, vanillaElites.Overloading) then
                a.maxhp = a.maxhp / 2
                a.maxshield = a.maxhp
                a.shield = a.maxshield
            end

        end
    end)
        
    callback.register("onDraw", function()
        for _, actor in ipairs(actors:findAll()) do
            if actor and actor:isValid() then
                if eliteCheck(actor, vanillaElites.Overloading) then
                    if actor:get("shield") > 0 then
                        graphics.drawImage{
                            image = shield,
                            x = actor.x - 11,
                            y = actor.y - 11,
                        }
                    end
                end
            end
        end
    end)
    
    
    local mineSprites = {
        idle = Sprite.load("Graphics/electricMine", 6, 2, 2),
        detonate = Sprite.load("Graphics/electricMineBlast", 6, 8, 8)
    }
    local electricMineDetonation = Sound.find("ChainLightning", "vanilla")
    local electricMine = Object.new("Overloading Mine")
    electricMine.sprite = mineSprites.idle
    
    electricMine:addCallback("create", function(self)
        self:set("life", 60)
        self:set("damage", 1)
        self:set("team", "enemy")
        self.spriteSpeed = 0.25
    end)
    
    electricMine:addCallback("step", function(self)
        if self:isValid() then
            for _, target in ipairs(actors:findMatching("id", self:get("target"))) do
                if target:isValid() then
                    self.x = target.x + self:get("xOff")
                    self.y = target.y + self:get("yOff")
                end
            end
            if self:get("life") > 0 then
                self:set("life", self:get("life") - 1)
            else
                self.alpha = 0
                if math.round(self.subimage) == 1 then
                    electricMineDetonation:play(0.8 + math.random() * 0.2)
                    self.spriteSpeed = 0
                    local parent = nil
                    for _, actor in ipairs(actors:findMatching("id", self:get("parent"))) do
                        parent = actor
                    end
                    local mine
                    if parent ~= nil then
                        mine = parent:fireExplosion(self.x, self.y, mineSprites.detonate.width/19, mineSprites.detonate.height/4, ((parent:get("damage") / 5) or 20)/10,mineSprites.detonate, nil, DAMAGER_NO_PROC)
                    else
                        mine = misc.fireExplosion(self.x, self.y, mineSprites.detonate.width/19, mineSprites.detonate.height/4, self:get("damage"),self:get("team"),mineSprites.detonate, nil, DAMAGER_NO_PROC)
                    end
                    mine:set("overloadingMine", 0)
                    self:destroy()
                end
            end
        end
    end)
    callback.register("onImpact", function(damager, x, y)
        local parent = damager:getParent()
        if damager:get("overloadingMine") and damager:get("overloadingMine") > 0 then
            local mine = electricMine:create(x, y)
            if parent and parent:isValid() then
                mine:set("parent", parent.id)
                mine:set("damage", (parent:get("damage") * damager:get("overloadingMine")))
                mine:set("team", parent:get("team"))
            else
                mine:set("parent", -1)
                mine:set("damage", (12 * damager:get("overloadingMine")))
                mine:set("team", "enemy")
            end
            mine.spriteSpeed = 0.25
            
        end
    end)
    
    -- Frenzied --
    local frenziedFX = ParticleType.find("Speed")
    local bonus = 1.5 --Max bonus Frenzied elites can recieve. 1 is equal to no bonus
    
    registercallback("onStep", function()
        for _, actor in ipairs(actors:findAll()) do
            if actor:isValid() then
                if eliteCheck(actor, vanillaElites.Frenzied) then
                    if actor:get("hp") > actor:get("maxhp") * 0.75 then
                        actor:set("base_attack_speed", actor:get("attack_speed"))
                        actor:set("base_Hmax", actor:get("pHmax"))
                    else
                        if actor:get("base_attack_speed") and actor:get("base_Hmax") then
                            local maxAttackSpeedBonus = actor:get("base_attack_speed") * bonus
                            local maxMoveSpeedBonus = actor:get("base_Hmax") * bonus
                            local hpRatio = (actor:get("hp") / (actor:get("maxhp") * 0.75))
                            local bonusMult = 1 - hpRatio
                            local mult = 10^(2 or 0)
                            bonusMult = math.floor(bonusMult * mult + 0.5) / mult
                            actor:set("attack_speed", math.clamp(actor:get("base_attack_speed") + (actor:get("base_attack_speed") * bonusMult), actor:get("base_attack_speed") or 1, maxAttackSpeedBonus))
                            actor:set("pHmax", math.clamp(actor:get("base_Hmax") + (actor:get("base_Hmax") * bonusMult), actor:get("base_Hmax") or 1, maxMoveSpeedBonus))
                            if math.random(10 * hpRatio) <= 1 and actor:get("pHspeed") ~= 0 then
                                frenziedFX:burst("middle", actor.x, actor.y + (math.random(-actor.sprite.height/2, actor.sprite.height/2)), 1, Color.YELLOW)
                            end
                        end
                    end
                end
            end
        end
    end)
    
    -- Volatile --
    local grenadeSprites = {
        idle = Sprite.load("volatileGrenadeIdle", "Graphics/volatileGrenade", 10, 4.5, 4.5),
        explosion = Sprite.load("volatileGrenadeDetonate", "Graphics/volatileGrenadeExplosion", 5, 13, 18),
        mask = Sprite.load("volatileGrenadeMask", "Graphics/grenadeMask", 1, 4.5, 4.5),
    }   
    local grenadeSound = Sound.find("WormExplosion", "vanilla")
    
    local volatileGrenade = Object.new("Volatile Grenade")
    volatileGrenade.sprite = grenadeSprites.idle
    
    volatileGrenade:addCallback("create", function(self)
        self.spriteSpeed = 0.25
        self.mask = grenadeSprites.mask
        self:set("vx", math.random(-4, 4))
        self:set("vy", math.random(-3, -10))
        self:set("ay", 0.25)
        self:set("life", math.random(1, 3)*60)
        self:set("bounce", 0.6)
    end)
    
    volatileGrenade:addCallback("step", function(self)
        if self:get("life") <= 0 then
            if math.round(self.subimage) >= grenadeSprites.explosion.frames then
                self:destroy()
            end
        else
            PhysicsStep(self)
            self:set("life", self:get("life") - 1)
            for _, actor in ipairs(actors:findAll()) do
                if self:isValid() and self:collidesWith(actor, self.x, self.y) then
                    if actor:get("team") ~= self:get("team") then
                        self:set("life", 0)
                    end
                end
            end
            if self:get("life") <= 0 then
                self.sprite = grenadeSprites.explosion
                grenadeSound:play(0.8 + math.random() * 0.8)
                misc.shakeScreen(5)
                misc.fireExplosion(self.x, self.y, grenadeSprites.explosion.width / 19, grenadeSprites.explosion.height / 4, (self:get("damage") or 12), self:get("team") or "neutral", nil, nil)
                self.subimage = 1
            end
        end
    end)

    local volatileHandler = net.Packet.new("Volatile Bomb Handler", function(player, x, y, vx, vy, life, team, rotate, damage)
        local bomb = volatileGrenade:create(x, y)
        bomb:set("vx", vx)
            :set("vy", vy)
            :set("life", life)
            :set("team", team)
            :set("rotate", rotate)
            :set("damage", damage)
    end)

    registercallback("onStep", function()
        for _, actor in ipairs(actors:findAll()) do
            if actor:isValid() then
                local data = actor:getData()
                if eliteCheck(actor, vanillaElites.Volatile) then
                    if actor:get("hp") <= 0 and not data.volatileBomb then
                        for i = 0, math.clamp(actor:get("lastHp")%6,2,5) do
                            local grenade = volatileGrenade:create(actor.x, actor.y)
                            grenade:set("team", actor:get("team"))
                            grenade:set("rotate", math.clamp(actor:get("lastHp")%5,1,4))
                            grenade:set("damage", actor:get("damage"))
                            if net.host then
                                volatileHandler:sendAsHost(net.ALL, nil, actor.x, actor.y, grenade:get("vx"), grenade:get("vy"), grenade:get("life"), grenade:get("team"), grenade:get("rotate"), grenade:get("damage"))
                            end
                        end
                        data.volatileBomb = true
                    end
                end
            end
        end
    end)
    
    -- Leeching --
    
    local regenCooldown = 3*60
    
    local regenCoefficient = 0.001
    
    registercallback("onStep", function()
        for _, actor in ipairs(actors:findAll()) do
            if actor:isValid() then
                if eliteCheck(actor, vanillaElites.Leeching) then
                    if actor:get("regen_cooldown") ~= nil then
                        if actor:get("regen_cooldown") <= 0 then
                            if (actor:get("hp") + ((actor:get("maxhp") * regenCoefficient)) > actor:get("maxhp")) == false then
                                actor:set("hp", actor:get("hp") + (actor:get("maxhp") * regenCoefficient))
                            end
                        else
                            actor:set("regen_cooldown", actor:get("regen_cooldown") - 1)
                        end
                    end
                end 
            end
        end
    end)
    
    registercallback("onActorInit", function(actor)
        actor:set("regen_cooldown", regenCooldown)
    end)
    
    registercallback("onHit", function(damager, hit, x, y)
        local hitActor = hit
        if hitActor:isValid() then
            if eliteCheck(hitActor, vanillaElites.Leeching) then
                hit:set("regen_cooldown", regenCooldown)
            end
        end
    end)
end

-----------------------------------------------

-- Glacial --
Glacial.displayName = "Glacial"
Glacial.color = Color.fromRGB(100, 200, 255)
Glacial.palette = palettes.glacial

InitElites[Glacial] = function(actor)
    if actor:get("elite_is_hard") == 1 and type(actor) ~= "PlayerInstance" then
        GlobalItem.initActor(actor)
        GlobalItem.addItem(actor, Item.find("Permafrost", "vanilla"), 1)
    end
end

Frigid = Buff.new("iceSlow")
Frigid.sprite = Sprite.find("Buffs", "vanilla")
Frigid.subimage = 8
Frigid.frameSpeed = 0
local snow = ParticleType.find("PixelDust", "vanilla")



Frigid:addCallback("start", function(actor)
    actor.blendColor = Color.fromRGB(220,250,255)
    actor:set("pHmax", actor:get("pHmax") - 0.26)
end)
Frigid:addCallback("step", function(actor)
    if math.random() <= 0.1 then
        snow:burst("middle", actor.x + math.random(-actor.sprite.width/2, actor.sprite.width/2), actor.y + math.random(-actor.sprite.height/2, actor.sprite.height/2), 1)
    end
end)
Frigid:addCallback("end", function(actor)
    actor.blendColor = Color.fromRGB(255,255,255)
    actor:set("pHmax", actor:get("pHmax") + 0.26)
end)
export("Frigid")

local frigidBaseLength = 2*60

registercallback("onHit", function(damager, hit, x, y)
    local parent = damager:getParent()
    if parent ~= nil then
        if parent:isValid() then
            if eliteCheck(parent, Glacial) then
                if hit:isValid() then
                    hit:applyBuff(Frigid, frigidBaseLength * (parent:get("elite_is_hard")))
                end
            end
        end
    end  
end)

local bombSprites = {
    idle = Sprite.load("frostBomb1", "Graphics/glacialBomb1", 3, 12, 16),
    detonate = Sprite.load("frostBomb2", "Graphics/glacialBomb2", 7, 44, 44)
}
local frostBomb = Object.new("EfFrostBomb")

local frostSound = Sound.find("Frozen", "vanilla")
local frostChargeSound = Sound.find("ChildGShoot1", "vanilla")
local frostBombLife = 60

frostBomb:addCallback("create", function(self)
    self:set("life", frostBombLife)
    self:set("radius", 1)
    self.sprite = bombSprites.idle
    self.spriteSpeed = 0.25
    self.angle = math.random(360)
    frostChargeSound:play(0.5)
end)
frostBomb:addCallback("step", function(self)
    self:set("life", self:get("life") - 1)
    if self:get("life") <= 0 then
        if frostChargeSound:isPlaying() then
            frostChargeSound:stop()
        end
        local damage = self:get("damage") or 14
        frostSound:play(1 + math.random() * 0.2)
        local freeze = misc.fireExplosion(self.x, self.y, 2 * self:get("radius"), 2 * self:get("radius"), 1.5 * damage, self:get("team") or "enemy", bombSprites.detonate, nil)
        freeze:set("freeze", 1)
        self:destroy()
    end
end)
frostBomb:addCallback("draw", function(self)
    graphics.drawImage{
        image = bombSprites.detonate,
        subimage = 1,
        x = self.x,
        y = self.y,
        alpha = (frostBombLife - self:get("life")) / frostBombLife,
        scale = self:get("radius") or 1
    }
end)
callback.register("onStep", function()
    for _, actor in ipairs(actors:findAll()) do
        local data = actor:getData()
        if eliteCheck(actor, Glacial) then
            if actor:get("hp") <= 0 and not data.iceBomb then
                local freeze = frostBomb:create(actor.x, actor.y)
                freeze:set("damage", actor:get("damage") or 14)
                if actor:get("elite_is_hard") == 1 then
                    freeze:set("radius", 1.5)
                end
                freeze:set("team", actor:get("team"))
                data.iceBomb = true
            end
        end
    end
end)

-----------------------------------------------

-- Malachite --
Malachite.displayName = "Malachite"
Malachite.color = Color.fromRGB(0, 50, 0)
Malachite.palette = palettes.malachite

InitElites[Malachite] = function(actor)
    spawnSignal[Malachite]:play(0.9 + math.random() * 0.1)
    if actor:get("name2") == "" then
        actor:set("name2", "Anathema")
    end
    actor:set("maxhp", actor:get("maxhp")*2.5)
    actor:set("hp", actor:get("maxhp"))
    actor:set("damage", math.round(actor:get("damage")*1.5))
    if actor:get("exp_worth") then
        actor:set("exp_worth", actor:get("exp_worth") * 10)
    end
    if actor:get("knockback_cap") then
        actor:set("knockback_cap", math.round(actor:get("knockback_cap")*20))
    end
    actor:set("NoHealOnHit", 1)
    actor:set("show_boss_health", 1)
end


local malachiteCooldown = 4*60
local malachiteMineLife = 10*60


local vignette = Object.find("vignette", "RoR2Demake")

local malachiteVignette = nil

local noHeal = Buff.new("NoHeal")
noHeal.sprite = Sprite.load("EfNoHeal", "Graphics/noHealingBuff", 1, 9, 7)

noHeal:addCallback("step", function(actor)
    local actorA = actor:getAccessor()
    local hpDelta = ((actorA.hp + actorA.hp_regen) - actorA.lastHp)
	if hpDelta > 0 then
        actorA.hp = actorA.lastHp - actorA.hp_regen
    end
end)
callback.register("preHit", function(damager)
    local parent = damager:getParent()
    if parent and parent:isValid() then
        if parent:get("NoHealOnHit") and parent:get("NoHealOnHit") > 0 then
            damager:set("NoHealOnHit", parent:get("NoHealOnHit"))
        else
            damager:set("NoHealOnHit", 0)
        end
    end
end)

callback.register("onPlayerHUDDraw", function(player)
    if not malachiteVignette then
        malachiteVignette = vignette:create(0, 0)
        malachiteVignette.blendColor = Color.fromRGB(25, 50, 25)
        malachiteVignette.alpha = 0
        malachiteVignette.depth = misc.hud.depth + 10
        malachiteVignette:getData().rate = 0.01
    else
        if player:hasBuff(noHeal) then
            malachiteVignette.alpha = 1
        end
    end
end)

callback.register("onHit", function(damager, hit, x, y)
    if damager:get("NoHealOnHit") and damager:get("NoHealOnHit") > 0 then
        hit:applyBuff(noHeal, (8*60) * damager:get("NoHealOnHit"))
    end
end)

local malasprites = {
    idle = Sprite.load("poisonMine1","Graphics/poisonMine", 1, 4, 4),
    maskIdle = Sprite.load("Graphics/poisonMineMask1", 1, 4, 4),
    detonate = Sprite.load("poisonMine2", "Graphics/poisonMineDetonate", 5, 19, 21),
    maskDetonate = Sprite.load("Graphics/poisonMineMask2", 1, 19, 21),
}
local sounds = {
    toss = Sound.load("PoisonMineThrow", "Sounds/SFX/malachiteBombToss.ogg"),
    detonate = Sound.load("PoisonMineDetonate", "Sounds/SFX/malachiteBombDetonate.ogg")
}


local malachiteMine = Object.new("ElitePoisonMine")
malachiteMine.sprite = malasprites.idle
malachiteMine:addCallback("create", function(self)
    self:set("phase", 0)
    local data = self:getData()
    if data.parent then
        self:set("team", data.parent:get("team"))
    else
        self:set("team", "neutral")
    end
    if not self:get("vx") then
        self:set("vx", -1):set("vy", -3):set("ay", 0.25)
    end
    self:set("life", malachiteMineLife)
    data.collisions = {}
    self.mask = malasprites.maskIdle
    self.spriteSpeed = 0.25
end)

malachiteMine:addCallback("step", function(self)
    local data = self:getData()
    if self:get("phase") == 0 then
        if self:get("life") == nil then
            self:set("life", malachiteMineLife)
        end
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
            self.angle = 0
            self.sprite = malasprites.detonate
            self.subimage = 1
            sounds.detonate:play(1 + math.random() * 0.3)
            self.mask = malasprites.maskDetonate
            if math.random() < 0.5 then
                self.xscale = -1
            else
                self.xscale = 1
            end
            self.y = FindGround(self.x, self.y)
            self:set("phase", 1)
        end
    elseif self:get("phase") == 1 then
        if self.subimage >= malasprites.detonate.frames then
            self.spriteSpeed = 0
        else
            self.spriteSpeed = 0.25
        end
        if self:get("life") > -1 then
            self:set("life", self:get("life") - 1)
            local nearestActor = actors:findNearest(self.x, self.y)
            if self:collidesWith(nearestActor, self.x, self.y) then
                if nearestActor:isValid() and nearestActor:get("team") ~= self:get("team") then
                    nearestActor:applyBuff(noHeal, 8*60)
                end
            end
        else
            self:destroy()
        end
    end

end)

malachiteMine:addCallback("draw", function(self)
    if self:get("phase") == 1 then
        graphics.color(Color.fromRGB(95, 152, 99))
        graphics.alpha(0.5)
        graphics.circle(self.x, self.y, 20, true)
    end
end)

local malachiteParticle = ParticleType.new("PoisonAura")
malachiteParticle:angle(0, 360, 1, 2, true)
malachiteParticle:speed(1, 2, -0.01, 0.5)
malachiteParticle:direction(0, 360, 10, 45)
malachiteParticle:life(60, 60)
malachiteParticle:shape("Square")
malachiteParticle:color(Color.BLACK)
malachiteParticle:alpha(0.5)
malachiteParticle:scale(0.05, 0.07)
malachiteParticle:size(0.9, 1, -0.01, 0.005)

local malachiteAura = ParticleType.new("PoisonTrail")
malachiteAura:color(Color.fromRGB(39, 79, 61))
malachiteAura:shape("Square")
malachiteAura:alpha(1, 0.5, 0)
malachiteAura:scale(0.02, 0.02)
malachiteAura:size(1, 1, -0.01, 0)
malachiteAura:angle(0, 360, 0.1, 0, false)
malachiteAura:life(15, 15)

malachiteParticle:createOnStep(malachiteAura, 1)


callback.register("onStep", function()
    if misc.getTimeStop() == 0 then
        for _, inst in ipairs(actors:findAll()) do
            if inst:isValid() and eliteCheck(inst, Malachite) then
                if inst:get("poisonCooldown") then
                    if inst:get("poisonCooldown") <= -1 then
                        sounds.toss:play(1 + math.random() * 0.05)
                        for i =0, inst:get("elite_is_hard")+1 do
                            local mine = malachiteMine:create(inst.x, inst.y)
                            local data = mine:getData()
                            mine:set("team", inst:get("team"))
                            data.parent = inst
                            if i == 0 then
                                mine:set("vx", -1):set("vy", -3):set("ay", 0.25)
                            elseif i == 1 then
                                mine:set("vx", 1):set("vy", -3):set("ay", 0.25)
                            elseif i == 2 then
                                mine:set("vx", 0):set("vy", -3):set("ay", 0.25)
                            end
                        end
                        inst:set("poisonCooldown", malachiteCooldown)
                    else
                        inst:set("poisonCooldown", inst:get("poisonCooldown") - 1)
                        if inst:get("poisonCooldown") % 20 == 0 then
                            malachiteParticle:burst("middle", inst.x + math.random(-inst.sprite.width, inst.sprite.width), inst.y + math.random(-inst.sprite.height, inst.sprite.height), 1)
                        end
                    end
                else
                    inst:set("poisonCooldown", malachiteCooldown)
                end
            end
        end
    end
end)


-----------------------------------------------

-- Celestine --
Celestine.displayName = "Celestine"
Celestine.color = Color.fromRGB(0, 255, 255)
Celestine.palette = palettes.celestine

InitElites[Celestine] = function(actor)
    --Celestine
    spawnSignal[Celestine]:play(0.9 + math.random() * 0.1)
    if actor:get("name2") == "" then
        actor:set("name2", "Eidolic Medium")
    end
    actor:set("maxhp", actor:get("maxhp")*2.5)
    actor:set("hp", actor:get("maxhp"))
    actor:set("damage", math.round(actor:get("damage")*1.5))
    if actor:get("exp_worth") then
        actor:set("exp_worth", actor:get("exp_worth") * 10)
    end
    if actor:get("knockback_cap") then
        actor:set("knockback_cap", math.round(actor:get("knockback_cap")*20))
    end
    actor:set("show_boss_health", 1)
end

local trail = Object.find("EfTrail", "vanilla")

local ghostFX = ParticleType.new("GhostFX")
ghostFX:shape("Square")
ghostFX:color(Color.fromRGB(119, 255, 193), Color.fromRGB(0, 181, 165))
ghostFX:alpha(0.5)
ghostFX:additive(true)
ghostFX:scale(0.05, 0.07)
ghostFX:size(0.9, 1, -0.01, 0.005)
ghostFX:angle(0, 360, 1, 0.5, true)
ghostFX:life(30, 30)

local invisible = Buff.new("GhostlyBuff")
invisible.sprite = Sprite.find("Empty")

local buff2 = Buff.new("GhostIcon")
buff2.sprite = Sprite.load("CelestineBuff", "Graphics/invisibility", 1, 9, 6.5)

local celestineRange = 100

invisible:addCallback("start", function(actor)
    local self = actor:getAccessor()
    local inst = trail:create(actor.x, actor.y)
    inst.sprite = actor.sprite
    inst.subimage = actor.subimage
    inst.angle = actor.angle
    inst.xscale = actor.xscale
    inst.yscale = actor.yscale
    inst:set("ghost", 1)
    if self.team == "player" then
        actor.alpha = 0.5
    else
        actor.alpha = 0
    end

end)
invisible:addCallback("step", function(actor)
    if actor:get("team") == "player" then
        actor:applyBuff(buff2, 2)
    end
    if isa(actor, "PlayerInstance") and Object.findInstance(actor:get("child_poi")) then
        Object.findInstance(actor:get("child_poi")):destroy()
    end
    if actor:get("activity") ~= 0 then
        local inst = trail:create(actor.x, actor.y)
        inst.sprite = actor.sprite
        inst.subimage = actor.subimage
        inst.angle = actor.angle
        inst.xscale = actor.xscale
        inst.yscale = actor.yscale
        inst:set("ghost", 1)
    end
end)
invisible:addCallback("end", function(actor)
    local inst = trail:create(actor.x, actor.y)
    inst.sprite = actor.sprite
    inst.subimage = actor.subimage
    inst.angle = actor.angle
    inst.xscale = actor.xscale
    inst.yscale = actor.yscale
    inst:set("ghost", 1)
    actor.alpha = 1
    if isa(actor, "PlayerInstance") and not Object.findInstance(actor:get("child_poi")) then
        local newPoi = Object.find("POI", "vanilla"):create(actor.x, actor.y)
        newPoi:set("parent", actor.id)
        actor:set("child_poi", newPoi.id)
    end
end)

callback.register("onStep", function()
    if misc.getTimeStop() == 0 then
        for _, inst in ipairs(actors:findAll()) do
            if inst:isValid() and eliteCheck(inst, Celestine) then
                local trailInst = trail:create(inst.x, inst.y)
                trailInst.sprite = inst.sprite
                trailInst.subimage = inst.subimage
                trailInst.angle = inst.angle
                trailInst.xscale = inst.xscale
                trailInst.yscale = inst.yscale
                trailInst:set("ghost", 1)
                trailInst:set("rate", 0.1)
                trailInst.blendColor = Color.fromRGB(0, 181, 165)
                for _, a in ipairs(actors:findAllEllipse(inst.x - (celestineRange * ((inst:get("elite_is_hard") * 0.5) + 1)), inst.y - (celestineRange * ((inst:get("elite_is_hard") * 0.5) + 1)), inst.x + (celestineRange * ((inst:get("elite_is_hard") * 0.5) + 1)), inst.y + (celestineRange * ((inst:get("elite_is_hard") * 0.5) + 1)))) do
                    if a:get("team") == inst:get("team") and a ~= inst then
                        a:applyBuff(invisible, 30)
                    end
                end
            end
        end
    end
end)

callback.register("onDraw", function()
    if misc.getTimeStop() == 0 then
        for _, inst in ipairs(actors:findAll()) do
            if inst:isValid() and eliteCheck(inst, Celestine) then
                graphics.alpha(math.clamp(math.sin(misc.director:get("time_start")/10), 0.1, 0.5))
                graphics.color(Color.fromRGB(0, 181, 165))
                graphics.circle(inst.x, inst.y, (celestineRange * ((inst:get("elite_is_hard") * 0.5) + 1)), true)
                local angle = math.random(0, 360)
                local xx = math.cos(math.rad(angle)) * (celestineRange * ((inst:get("elite_is_hard") * 0.5) + 1))
                local yy = math.sin(math.rad(angle)) * (celestineRange * ((inst:get("elite_is_hard") * 0.5) + 1))
                ghostFX:burst("middle", inst.x + xx, inst.y + yy, 1)
            end
        end
    end
end)

--------------------------------------------------------------------------
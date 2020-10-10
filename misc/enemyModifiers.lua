
local burn = Burned

-- Enemies to inflict burn on hit
local elderLemurian = Object.find("LizardG", "vanilla")
local direSeeker = Object.find("LizardGS", "vanilla")
local cremator = Object.find("Turtle", "vanilla")
local ifrit = Object.find("Ifrit", "vanilla")

-- Magma Worm
local worm = {
    main = Object.find("Worm", "vanilla"),
    head = Object.find("WormHead", "vanilla"),
    body = Object.find("WormBody", "vanilla"),
    warning = Object.find("WormWarning", "vanilla")
}

worm.warning:addCallback("create", function(self)
    local data = self:getData()
    data.createdBombs = false
end)

local bombSprites = {
    fireIdle = Sprite.load("magmaBombIdle", "Graphics/magmaBomb", 10, 4.5, 4.5),
    fireExplosion = Sprite.find("EfPillar", "vanilla"),
    electricIdle = Sprite.load("lightningBombIdle", "Graphics/electroBomb", 10, 4.5, 4.5),
    electricExplosion = Sprite.load("lightningDetonate", "Graphics/lightning", 13, 24, 153),
    electricIdle2 = Sprite.load("lightningBombIdle2", "Graphics/electricMine", 6, 2, 2),
    electricExplosion2 = Sprite.load("lightningDetonate2", "Graphics/electricMineBlast", 6, 8, 8),
    mask = Sprite.load("magmaBombMask", "Graphics/grenadeMask", 1, 4.5, 4.5),
}   
local magmaBombSound = Sound.find("WormExplosion", "vanilla")
local electroBombSound = Sound.find("ChainLightning", "vanilla")

local actors = ParentObject.find("actors", "vanilla")

-- Make Bombs
local magmaBomb = Object.new("Magma Bomb")
magmaBomb.sprite = bombSprites.fireIdle
magmaBomb:addCallback("create", function(self)
    self.spriteSpeed = 0.25
    self.mask = bombSprites.mask
    self:set("ay", 0.25)
    self:set("rotate", math.random(1, 4))
    self:set("life", 3*60)
end)
magmaBomb:addCallback("step", function(self)
    if self:get("life") <= 0 then
        if math.round(self.subimage) >= bombSprites.fireExplosion.frames then
            self:destroy()
        end
    else
        PhysicsStep(self)
        self:set("life", self:get("life") - 1)
        if self:collidesMap(self.x,self.y) and self:get("life") < 160 then
            self:set("life", 0)
        end
        for _, actor in ipairs(actors:findAll()) do
            if self:isValid() and self:collidesWith(actor, self.x, self.y) then
                if actor:get("team") ~= self:get("team") then
                    self:set("life", 0)
                end
            end
        end
        if self:get("life") <= 0 then
            self.alpha = 0
            magmaBombSound:play(0.8 + math.random() * 0.4)
            misc.shakeScreen(5)
            local magmaHit = misc.fireExplosion(self.x, self.y, 20 / 19, 20 / 4, 2 * (self:get("damage") or 100), self:get("team") or "neutral", bombSprites.fireExplosion, nil)
            self:destroy()
        end
    end
end)
local minielectroBomb = Object.new("Electro Bomblet")
minielectroBomb.sprite = bombSprites.electricIdle2
minielectroBomb:addCallback("create", function(self)
    self.spriteSpeed = 0.25
    self.mask = bombSprites.mask
    self:set("ay", 0.25)
    self:set("rotate", math.random(1, 4))
    self:set("life", 3*60)
end)
minielectroBomb:addCallback("step", function(self)
    if self:get("life") <= 0 then
        if math.round(self.subimage) >= bombSprites.fireExplosion.frames then
            self:destroy()
        end
    else
        
        PhysicsStep(self)
        self:set("life", self:get("life") - 1)
        if self:collidesMap(self.x,self.y) and self:get("life") < 160 then
            self:set("life", 0)
        end
        for _, actor in ipairs(actors:findAll()) do
            if self:isValid() and self:collidesWith(actor, self.x, self.y) then
                if actor:get("team") ~= self:get("team") then
                    self:set("life", 0)
                end
            end
        end
        if self:get("life") <= 0 then
            self.alpha = 0
            electroBombSound:play(0.8 + math.random() * 0.4)
            misc.shakeScreen(5)
            local electricHit = misc.fireExplosion(self.x, self.y, bombSprites.electricExplosion2.width / 19, bombSprites.electricExplosion2.height / 4, 2 * (self:get("damage") or 100), self:get("team") or "neutral", bombSprites.electricExplosion2, nil)
            self:destroy()
        end
    end
end)
local electroBomb = Object.new("Electro Bomb")
electroBomb.sprite = bombSprites.electricIdle
electroBomb:addCallback("create", function(self)
    self.spriteSpeed = 0.25
    self.mask = bombSprites.mask
    self:set("ay", 0.25)
    self:set("rotate", math.random(1, 4))
    self:set("life", 3*60)
end)
electroBomb:addCallback("step", function(self)
    if self:get("life") <= 0 then
        if math.round(self.subimage) >= bombSprites.fireExplosion.frames then
            self:destroy()
        end
    else
        PhysicsStep(self)
        self:set("life", self:get("life") - 1)
        if self:collidesMap(self.x,self.y) and self:get("life") < 160 then
            self:set("life", 0)
        end
        for _, actor in ipairs(actors:findAll()) do
            if self:isValid() and self:collidesWith(actor, self.x, self.y) then
                if actor:get("team") ~= self:get("team") then
                    self:set("life", 0)
                end
            end
        end
        if self:get("life") <= 0 then
            self.alpha = 0
            magmaBombSound:play(0.8 + math.random() * 0.4)
            misc.shakeScreen(5)
            local electricHit = misc.fireExplosion(self.x, self.y, 20 / 19, 20 / 4, 2 * (self:get("damage") or 100), self:get("team") or "neutral", bombSprites.electricExplosion, nil)
            for i=0, 3 do 
                local bomb1 = minielectroBomb:create(self.x, self.y)
                bomb1:set("vx", 1):set("vy", -5)
                bomb1:set("team", self:get("team"))
                bomb1:set("damage", self:get("damage") / 2)
                if i % 2 == 0 then
                    bomb1:set("vx", bomb1:get("vx") * -1)
                end
                if i > 2 then
                    bomb1:set("vx", bomb1:get("vx") / 2)
                end
            end
            self:destroy()
        end
    end
end)

-- Make Bombs spawn on breach
registercallback("onStep", function()
    for _, wormInst in ipairs(worm.head:findAll()) do
        local warning = worm.warning:findNearest(wormInst.x, wormInst.y)
        if warning ~= nil then
            if warning:isValid() then
                local data = warning:getData()
                local bombToMake = magmaBomb
                if wormInst:getElite() == EliteType.find("Overloading", "vanilla") then
                    bombToMake = electroBomb
                elseif wormInst:getElite() == EliteType.find("Volatile", "vanilla") then
                    bombToMake = Object.find("EfMissileEnemy","vanilla")
                elseif wormInst:getElite() == EliteType.find("Glacial", "RoR2Demake") then
                    bombToMake = Object.find("EfFrostBomb","RoR2Demake")
                elseif wormInst:getElite() == EliteType.find("Malachite", "RoR2Demake") then
                    bombToMake = Object.find("ElitePoisonMine","RoR2Demake")
                end
                if wormInst:collidesWith(warning, wormInst.x, wormInst.y) then
                    if not data.createdBombs then
                        if wormInst:getElite() == EliteType.find("Overloading", "vanilla") or wormInst:get("prefix_type") == 0 then
                            local controller = worm.main:findNearest(wormInst.x, wormInst.y)
                            local bombs = 2
                            for i=1, bombs do 
                                local bomb1 = bombToMake:create(warning.x, warning.y)
                                if bombToMake == magmaBomb or bombToMake == electroBomb then
                                    bomb1:set("vx", 2):set("vy", -5)
                                    bomb1:set("team", wormInst:get("team"))
                                    bomb1:set("damage", controller:get("damage") or 55)
                                    if i % 2 == 0 then
                                        bomb1:set("vx", bomb1:get("vx") * -1)
                                    end
                                    if i > 4 then
                                        bomb1:set("vx", bomb1:get("vx") / 4)
                                    elseif i > 2 then
                                        bomb1:set("vx", bomb1:get("vx") / 2)
                                    end
                                end
                            end
                        elseif wormInst:getElite() == EliteType.find("Glacial", "RoR2Demake") then
                            local bomb = bombToMake:create(warning.x, warning.y)
                            bomb:set("damage", wormInst:get("damage"))
                            bomb:set("team", wormInst:get("team"))
                        elseif wormInst:getElite() == EliteType.find("Malachite", "RoR2Demake") then
                            for i = 1, 4 do
                                local mine = bombToMake:create(warning.x, warning.y-1)
                                mine:set("life")
                                if i == 1 then
                                    mine:set("vx", -1):set("vy", -3):set("ay", 0.25)
                                elseif i == 2 then
                                    mine:set("vx", 1):set("vy", -3):set("ay", 0.25)
                                elseif i == 3 then
                                    mine:set("vx", -3):set("vy", -3):set("ay", 0.25)
                                elseif i == 4 then
                                    mine:set("vx", 3):set("vy", -3):set("ay", 0.25)
                                end
                            end
                        end
                        
                        data.createdBombs = true
                    end
                end
            end
        end
    end
end)


-- Inflict Burn
registercallback("onHit", function(damager, hit, x, y)
    local parent = damager:getParent()
    if parent ~= nil then
        if parent:isValid() then
            if parent:getObject() == elderLemurian or parent:getObject() == direSeeker or parent:getObject() == ifrit or parent:getObject() == worm.main or parent:getObject() == worm.head or parent:getObject() == worm.body then
                damager:set("burn", 1)
            end
        end
    end
end)

-- Golem Lasers
require("Actors.golem.golem")

-- Lemurian Fireballs
require("Actors.lemurian.lemurian")
require("Actors.elderLemurian.elderLemurian")

-- MEME
local colossus = Object.find("GolemG", "vanilla")
local sprite = Sprite.load("Actors/colossus/tpose", 10, 86, 58)
colossus:addCallback("create", function(self)
    if math.random() <= 0.01 then
        self:setAnimations{
            idle = sprite,
            walk = sprite,
            shoot1 = sprite,
            shoot2 = sprite,
        }
        self:set("name2", "The Most Powerful Being on the Planet")
    end
end)
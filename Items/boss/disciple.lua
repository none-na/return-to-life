--RoR2 Demake Project
--Made by Sivelos
--disciple.lua
--File created 2019/07/1

local disciple = Item("Little Disciple")
disciple.pickupText = "Fire tracking Wisps while moving."

disciple.sprite = Sprite.load("Items/boss/Graphics/disciple.png", 1, 16, 16)
--disciple:setTier("rare")
disciple.color = "y"

disciple:setLog{
    group = "boss",
    description = "While moving, fire tracking Wisps for &y&100% every 0.5s&!&.",
    story = "I believe I've pieced some things together about these wisps... The Grovetender carried a massive container filled with some kind of powdered fuel. I don't know what it's composed of, but the fuel can be infused into an object and ignited, which creates a Wisp of power relative to the amount of fuel used. I've made a few so far, but they are never sentient and only exist to obey my commands without question.\n\nA brief, but empty company. Will I ever find another kind soul on this damned planet?",
    destination = "Scorched Acres,\nUnknown",
    date = "6/25/2056"
}

local Projectile = require("Libraries.Projectile")

local sprites = {
    bullet = Sprite.load("EfWispBullet", "Graphics/wispBullet", 4, 13, 5),
    mask = Sprite.load("EfWispBulletMask", "Graphics/wispMask", 1, 13, 5),
    impact = Sprite.find("WispG2Spark", "vanilla")
}

local sounds = {
    impact = Sound.find("WispHit", "vanilla"),
    fire = Sound.find("JarSouls", "vanilla")
}

local actors = ParentObject.find("actors", "vanilla")
local enemies = ParentObject.find("enemies", "vanilla")
local triggerRadius = 100

local bullet = Object.new("WispBullet")
bullet.sprite = sprites.bullet

bullet:addCallback("create", function(self)
    local data = self:getData()
    self.mask = sprites.mask
    self:set("life",0)
    self:set("damage", 12)
    self:set("team", "neutral")
    sounds.fire:play(0.95 + math.random() * 0.1)
    self:set("angle", math.random(0, 360))
    self:set("acceleration", 0)
    self:set("vz", 2)
    data.vx = 0
    data.vy = 0
    self:set("targetAngle", 0)
    self:set("activity", 0)
    data.x = 0
    data.y = 0
    if data.parent then
        self:set("team", data.parent:get("team"))
        self:set("damage", data.parent:get("damage"))
    end
end)
bullet:addCallback("step", function(self)
    local data = self:getData()
    if data.parent then
        self:set("team", data.parent:get("team"))
        self:set("damage", data.parent:get("damage"))
    end
    self.angle = math.deg(math.atan2(math.sin(math.rad(self:get("angle"))) * self:get("vz"),math.cos(math.rad(self:get("angle"))) * self:get("vz")))
    self:set("life", self:get("life") + 1)
    if not data.target or not data.target:isValid() then
        local nearby = nil
        for _, inst in ipairs(actors:findMatchingOp("team", "~=", self:get("team"))) do
            if inst:isValid() then
                nearby = inst
                break
            end
        end
        if nearby and nearby:get("team") ~= self:get("team") then
            debugPrint("Inst #"..self.id..": Found new target!")
            data.target = nearby
        end
    end
    ---
    if self:get("activity") < 2 then
        self.x = self.x + math.cos(math.rad(self:get("angle"))) * self:get("vz")
        self.y = self.y + math.sin(math.rad(self:get("angle"))) * self:get("vz")
    end
    if self:get("activity") == 0 then --Wander
        self:set("angle", (self:get("angle") + (math.random(-self:get("vz"), self:get("vz")))) % 360)
        if self:get("life") >= 120 and data.target and data.target:isValid() then
            debugPrint("Inst #"..self.id..": Target is valid and found, moving to chase mode")
            self:set("acceleration", 0.01)
            data.x = data.target.x
            data.y = data.target.y
            self:set("activity", 1)
        end
    elseif self:get("activity") == 1 then --Chase
        if data.parent and isa(data.parent, "PlayerInstance") and data.target:isValid() then
            data.x = data.target.x
            data.y = data.target.y
        end
        self:set("targetAngle", math.deg(math.atan2(data.y-self.y,data.x-self.x)))
        self:set("vz", self:get("vz") + self:get("acceleration"))
        local incriment = 0
        local dif = self:get("targetAngle") - self:get("angle")
        if self:get("angle") ~= self:get("targetAngle") then
            incriment = dif / self:get("vz")
        end
        self:set("angle", self:get("angle") + incriment)
        if ((self.x >= data.x - 5 and self.x <= data.x + 5) and (self.y >= data.y - 5 and self.y <= data.y + 5)) or self:get("life") > 10*60 then
            self:set("activity", 2)
        end
    elseif self:get("activity") == 2 then --Detonate
        if data.parent and IsOnScreen(data.parent, self) then
            misc.shakeScreen(10)
            sounds.impact:play(0.9 + math.random() * 0.2)
        end
        local explosion = nil
        if data.parent then
            explosion = data.parent:fireExplosion(self.x, self.y, 0.25, 1, 1, sprites.impact, nil, nil)
        else
            explosion = misc.fireExplosion(self.x, self.y, 0.25, 1, self:get("damage"), self:get("team"), sprites.impact, nil, nil)
        end
        self:destroy()
        return
    end
    

end)
bullet:addCallback("draw", function(self)
    local data = self:getData()
    if self:get("activity") == 1 and self:get("team") ~= "player" then
        graphics.color(Color.WHITE)
        graphics.alpha(1)
        graphics.circle(data.x, data.y, (self:get("life")/2) % 5, true)
    end
end)

registercallback("onPlayerInit", function(player)
	player:set("wispBullet", 0)
end)

registercallback("onPlayerStep", function(player)
    if player then
        if player:countItem(disciple) > 0 then
            if (player:get("moveLeft") == 1 or player:get("moveRight") == 1) and player:get("pHspeed") ~= 0 then
                player:set("wispBullet", player:get("wispBullet") + 1)
                if enemies:findEllipse(player.x - triggerRadius, player.y - triggerRadius, player.x + triggerRadius, player.y + triggerRadius) then
                    if player:get("wispBullet") >= 30 then
                        sounds.fire:play(1.5 + math.random() * 0.5)
                        local wispInst = bullet:create(player.x, player.y)
                        wispInst:set("team", player:get("team"))
                        wispInst:set("damage", player:get("damage"))
                        local info = wispInst:getData()
                        info.parent = player
                        info.target = enemies:findNearest(player.x, player.y)
                        player:set("wispBullet", 0)
                    end
                end
            end
        end
    end
end)


GlobalItem.items[disciple] = {
    step = function(inst, count)
        if (inst:get("moveLeft") == 1 or inst:get("moveRight") == 1) and inst:get("pHspeed") ~= 0 then
            inst:set("wispBullet", (inst:get("wispBullet") or 0) + 1)
            for _, a in pairs(actors:findAllEllipse(inst.x - triggerRadius, inst.y - triggerRadius, inst.x + triggerRadius, inst.y + triggerRadius)) do
                if inst:get("wispBullet") >= 30 then
                    if a:get("team") ~= inst:get("team") then
                        sounds.fire:play(1.5 + math.random() * 0.5)
                        local wispInst = bullet:create(inst.x, inst.y)
                        wispInst:set("team", inst:get("team"))
                        wispInst:set("damage", (inst:get("damage") * count))
                        local info = wispInst:getData()
                        info.parent = inst
                        info.target = actors:findNearest(inst.x, inst.y)
                        inst:set("wispBullet", 0)
                        return
                    end
                end
            end
        end
    end,
}
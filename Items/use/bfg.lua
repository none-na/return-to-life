--RoR2 Demake Project
--Made by Sivelos
--bfg.lua
--File created 2019/05/23

local bfg = Item("Preon Accumulator")
bfg.pickupText = "Fire a ball of energy that electrocutes nearby enemies before detonating."

bfg.sprite = restre.spriteLoad("Graphics/bfg.png", 2, 16, 16)
bfg:setTier("use")

bfg.isUseItem = true
bfg.useCooldown = 140

bfg:setLog{
    group = "use_locked",
    description = "Fire a ball of energy that electrocutes nearby enemies before detonating for 4000%.",
    priority = "&or&MILITARY&!&",
    story = "The [REDACTED] Fusion Cannon is complete. It uses multiple [REDACTED] micro-reactors for fuel, so it packs a helluva punch. Be careful when handling it... You don't want to be on the business end of this thing. Trust me.",
    destination = "[REDACTED]",
    date = "2/25/2056"
}

local Projectile = require("libraries.Projectile")


local Projsprites = {
	sprite = Sprite.load("preonBlast", "Graphics/bfgProjectile", 9, 8, 8),
    mask = Sprite.load("preonMask", "Graphics/bfgMask", 1, 8, 8),
    explosion = Sprite.load("preonBoom", "Graphics/bfgExplosion", 5, 27, 25)
}

local fireSnd = Sound.find("Chest5", "vanilla")
local blastSnd = Sound.find("Smite", "vanilla")
local preonBall = Object.new("preonBlast")
preonBall.sprite = Projsprites.sprite

local shockRange = 60
local enemies = ParentObject.find("enemies", "vanilla")

preonBall:addCallback("create", function(this)
    local self = this:getAccessor()
    local data = this:getData()
    this.mask = Projsprites.mask
    data.damage = 12
    data.team = "player"
    self.speed = 3
end)
preonBall:addCallback("step", function(this)
    local self = this:getAccessor()
    local data = this:getData()
    for _, enemy in ipairs(enemies:findAllEllipse(this.x - shockRange, this.y - shockRange, this.x + shockRange, this.y + shockRange)) do
        if enemy and enemy:isValid() then
            local bolt = DrawLightning(this.x, this.y, enemy.x, enemy.y)
            bolt.blendColor = Color.fromRGB(194, 255, 175)
            local bullet = misc.fireBullet(enemy.x, enemy.y, 0, 1, 0.1 * data.damage, data.team.."proc", nil, nil)
            bullet:set("specific_target", enemy.id)
        end
    end
    local nearestEnemy = enemies:findNearest(this.x, this.y)
    if (nearestEnemy and nearestEnemy:isValid() and (this:collidesWith(nearestEnemy, this.x, this.y))) or this:collidesMap(this.x, this.y) then
        misc.shakeScreen(30)
        blastSnd:play()
        local explosion = misc.fireExplosion(this.x, this.y, 100/19, 100/4, 40 * data.damage, data.team.."proc", Projsprites.explosion, nil)
        for i = 0, math.random(3, 5) do
            local bolt = DrawLightning(this.x + math.random(-50, 50), this.y + math.random(-50, 50), this.x + math.random(-70, 70), this.y + math.random(-70, 70), 0.01)
            bolt.blendColor = Color.fromRGB(194, 255, 175)
        end
        this:destroy()
        return
    end

end)

local preonCharge = ParticleType.new("Preon Tendril Trail")
preonCharge:sprite(Sprite.load("Graphics/bfgCharge", 8, 0, 20), true, true, false)
preonCharge:angle(0, 360, 0, 0, false)
preonCharge:additive(true)
preonCharge:life(20, 20)

local preonBox = Object.new("preonBox")
local chargeSound = Sound.find("CutsceneJet", "vanilla")
preonBox:addCallback("create", function(self)
    if not self:get("life") then
        self:set("life", 60*2)
    end
    chargeSound:play(1.5 + math.random() * 0.5)
end)

preonBox:addCallback("step", function(self)
    local data = self:getData()
    if data.parent then
        data.parent:setAlarm(0, (140 * 60) * (data.parent:get("use_cooldown")/45))
        self.x = data.parent.x
        self.y = data.parent.y
        if self:get("life") <= -1 then
            if chargeSound:isPlaying() then
                chargeSound:stop()
            end
            fireSnd:play(0.9 + math.random() * 0.2)
            local blast = preonBall:create(self.x, self.y)
            blast:getAccessor().direction = data.parent:getFacingDirection()
            blast:getData().damage = data.parent:get("damage")
            blast:getData().team = data.parent:get("team")
            blast.spriteSpeed = 0.25
            self:destroy()
            return
        else
            preonCharge:direction(0, 0, 0, 0)
            preonCharge:speed(0, 0, 0, 0)
            if math.random(self:get("life")) % 3 == 0 then
                preonCharge:burst("middle", self.x, self.y, 1)
            end
            self:set("life", self:get("life") - 1)
        end
    else
        self:destroy()
    end
end)

bfg:addCallback("use", function(player, embryo)
    local box = preonBox:create(player.x, player.y)
    local data = box:getData()
    data.parent = player
    if embryo then
        box:set("life", 0)
    else
        box:set("life", 60*2)
    end
end)

GlobalItem.items[bfg] = {
    use = function(inst, count, embryo)
        local box = preonBox:create(inst.x, inst.y)
        local data = box:getData()
        data.parent = inst
        if embryo then
            box:set("life", 0)
        else
            box:set("life", 60*2)
        end
    end,
}

--- Timed Chest
--local MapObject = require("Libraries.mapObjectLib")

local targetTime = 10 --How many minutes before timed chest is locked

local sprites = {
    idle = Sprite.load("Graphics/timedChest", 8, 28, 15),
    mask = Sprite.load("Graphics/timedChestMask", 1, 28, 15),
    clock = Sprite.load("Graphics/timedChestClock", 11, 2, 3)
}

--[[local timedChest = MapObject.new({
    name = "Timed Security Chest",
    sprite = sprites.idle,
    baseCost = 0,
    currency = "gold",
    costIncrease = 0,
    affectedByDirector = false,
    mask = sprites.mask,
    useText = "&w&Press &y&'"..input.getControlString("use").."'&w& to open Timed Security Chest.&!&",
    activeText = "",
    maxUses = 1,
    triggerFireworks = true,
})

timedChest:addCallback("draw", function(self)
    if self:get("dead") == 0 and self:get("active") == 0 and self.subimage <= 1 then
        local m, s = misc.getTime()
        if m >= 20 then
            graphics.drawImage{
                image = sprites.clock,
                x = self.x - 7,
                y = self.y - 2,
                subimage = 11
            }
            graphics.drawImage{
                image = sprites.clock,
                x = self.x - 3,
                y = self.y - 2,
                subimage = 10
            }
            graphics.drawImage{
                image = sprites.clock,
                x = self.x + 3,
                y = self.y - 2,
                subimage = 6
            }
            graphics.drawImage{
                image = sprites.clock,
                x = self.x + 7,
                y = self.y - 2,
                subimage = 10
            }
        else
            --Draw - sign
            if m >= targetTime then
                graphics.drawImage{
                    image = sprites.clock,
                    x = self.x - 7,
                    y = self.y - 2,
                    subimage = 11
                }
            end
            --Draw minutes
            local mm = nil
            if m >= targetTime then
                mm = m-1
            else
                mm = math.abs((targetTime - 1) - m) + 1
            end
            graphics.drawImage{
                image = sprites.clock,
                x = self.x - 3,
                y = self.y - 2,
                subimage = math.clamp(mm, 1, 10)
            }
            --Draw Seconds
            local ss = nil
            if m >= targetTime then
                ss = s + 1
            else
                ss = math.abs(59 - s) + 2
            end
            local digit1 = (ss / 10) % 10
            local digit2 = ss % 10
            if digit2 <= 0 then
                if m < targetTime then
                    digit2 = 10
                    digit1 = digit1 - 1
                else
                    digit2 = 10
                    digit1 = digit1 - 1
                end
            end
            graphics.drawImage{
                image = sprites.clock,
                x = self.x + 3,
                y = self.y - 2,
                subimage = math.clamp(digit1 + 1, 1, 10)
            }
            graphics.drawImage{
                image = sprites.clock,
                x = self.x + 7,
                y = self.y - 2,
                subimage = math.clamp(digit2, 1, 10)
            }
        end
    end
end)

local redacted = Achievement.new("[REDACTED]")
redacted.requirement = 1
redacted.deathReset = false
redacted.description = "Open the Timed Security Chest on the third level."
redacted.highscoreText = "\'Preon Accumulator\' Unlocked"
redacted:assignUnlockable(bfg)


timedChest:addCallback("step", function(self)
    local m, s = misc.getTime()
    if m >= targetTime then
        MapObject.configure(self, {
            useText = "",
        })
        self:set("cost", 99999999999999999999999999999999999)
    end
end)

registercallback("onObjectActivated", function(objectInstance, frame, player, x, y)
    if objectInstance:getObject() == timedChest then
        local m, s = misc.getTime()
        if m < targetTime then
            if frame == 1 then
                Sound.find("Chest5", "vanilla"):play(1 + math.random() * 0.2)
                misc.shakeScreen(5)
                redacted:increment(1)
            elseif frame == 7 then
                bfg:create(x, y - (objectInstance.sprite.height + 5))
            end
        else
            Sound.find("Error", "vanilla"):play(1)
            if objectInstance:get("uses") > 0 then
                objectInstance:set("uses", objectInstance:get("uses") - 1)
            end
            objectInstance.subimage = 1
            objectInstance:set("activated", 0)
            objectInstance:set("waitTimer", 60)
        end
    end
end)
registercallback("onObjectFailure", function(objectInstance, player)
    if objectInstance:getObject() == timedChest then
        Sound.find("Error", "vanilla"):play(1)
    end
end)]]

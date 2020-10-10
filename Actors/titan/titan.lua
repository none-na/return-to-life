local sprites = {
    idle = Sprite.load("TitanIdle", "Actors/titan/idle", 1, 27,68),
    idleG = Sprite.load("TitanGoldIdle", "Actors/titan/idleGold", 1, 27,71),
    walk = Sprite.load("TitanWalk", "Actors/titan/walk", 10, 32,67),
    walkG = Sprite.load("TitanGoldWalk", "Actors/titan/walkGold", 10, 32,70),
    shoot1 = Sprite.load("TitanShoot1", "Actors/titan/punch", 34, 35, 68),
    shoot1G = Sprite.load("TitanGoldShoot1", "Actors/titan/punchGold", 34, 36, 68),
    death = Sprite.load("TitanDeath", "Actors/titan/death", 14, 78,106),
    deathG = Sprite.load("TitanGoldDeath", "Actors/titan/deathGold", 14, 78,106),
    mask = Sprite.load("TitanMask", "Actors/titan/mask", 1,27,68),
    portraitG = Sprite.load("TitanGPortait", "Actors/titan/portraitGold", 1, 119.5,119.5)
}
local sounds = {
    hurt = Sound.find("GolemHit", "vanilla"),
    spawn = Sound.load("TitanSpawn", "Sounds/SFX/titan/titanSpawn.ogg"),
    death = Sound.load("TitanDeath", "Sounds/SFX/titan/titanDeath.ogg"),
    shoot1_1 = Sound.load("TitanShoot1_1", "Sounds/SFX/titan/titanPrepareFist.ogg"),
    shoot1_2 = Sound.load("TitanShoot1_2", "Sounds/SFX/titan/titanFist.ogg"),
    shoot2_1 = Sound.load("TitanShoot2_1", "Sounds/SFX/titan/titanLaserStart.ogg"),
    shoot2_2 = Sound.load("TitanShoot2_2", "Sounds/SFX/titan/titanLaser.ogg"),
    shoot3_1 = Sound.load("TitanShoot3_1", "Sounds/SFX/titan/titanRocksStart.ogg"),
    shoot3_2 = Sound.load("TitanShoot3_2", "Sounds/SFX/titan/titanRocks.ogg"),
    shoot3_3 = Sound.load("TitanShoot3_3", "Sounds/SFX/titan/titanBlast.ogg"),
    shoot3_4 = Sound.find("GiantJellyExplosion", "vanilla")
}

local player = Object.find("P", "vanilla")
local actors = ParentObject.find("actors", "vanilla")
local enemy = ParentObject.find("enemies", "vanilla")

local titanBullet = Object.new("TitanBullet")

local bulletFX = ParticleType.new("TitanBullet")
bulletFX:shape("Disc")
bulletFX:color(Color.fromRGB(186, 84, 86))
bulletFX:alpha(1, 0.5, 0)
bulletFX:additive(true)
bulletFX:size(0.1, 0.1, -0.0025, 0)
bulletFX:angle(0, 360, 1, 0, true)
bulletFX:life(120, 120)


local bulletHit = ParticleType.find("Rubble1", "vanilla")

titanBullet:addCallback("create", function(self)
    local data = self:getData()
    self:set("life",0)
    self:set("team", "enemy")
    sounds.shoot3_3:play(0.95 + math.random() * 0.1)
    self:set("angle", math.random(0, 360))
    self:set("acceleration", 0)
    self:set("vz", 2)
    data.vx = 0
    data.vy = 0
    self:set("targetAngle", 0)
    self:set("activity", 0)
    data.x = 0
    data.y = 0
end)
titanBullet:addCallback("step", function(self)
    if misc.getTimeStop() == 0 then
        local data = self:getData()
        self:set("life", self:get("life") + 1)
        bulletFX:burst("middle", self.x, self.y, 1)
        if not data.target then
            local nearby = nil
            for _, inst in ipairs(actors:findMatchingOp("team", "~=", self:get("team"))) do
                if inst:isValid() then
                    nearby = inst
                    break
                end
            end
            if nearby and nearby:get("team") ~= self:get("team") then
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
                self:set("acceleration", 0.01)
                data.x = data.target.x
                data.y = data.target.y
                self:set("activity", 1)
            end
        elseif self:get("activity") == 1 then --Chase
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
            misc.shakeScreen(10)
            sounds.shoot3_4:play(0.9 + math.random() * 0.2)
            bulletHit:burst("middle", self.x, self.y, math.random(1, 5))
            local explosion = misc.fireExplosion(self.x, self.y, 1, 1, 40 * Difficulty.getScaling("damage"), self:get("team"), nil, nil, nil)
            self:destroy()
            return
        end
    end
end)
titanBullet:addCallback("draw", function(self)
    local data = self:getData()
    if self:get("activity") == 1 then
        graphics.color(Color.WHITE)
        graphics.alpha(1)
        graphics.circle(data.x, data.y, (self:get("life")/2) % 5, true)
    end
end)

local titanLaser = Object.new("TitanLaser")
local maxLaserLength = 200
local laserOffsets = {
    [Sprite.find("TitanIdle")] = {
        [1] = {x = 6, y = 53},
    },
    [Sprite.find("TitanWalk")] = {
        [1] = {x = 8, y = 48},
        [2] = {x = 6, y = 50},
        [3] = {x = 6, y = 51},
        [4] = {x = 6, y = 52},
        [5] = {x = 9, y = 47},
        [6] = {x = 8, y = 49},
        [7] = {x = 7, y = 50},
        [8] = {x = 7, y = 51},
        [9] = {x = 7, y = 52},
        [10] = {x = 7, y = 47},
    },
    [Sprite.find("TitanShoot1")] = {
        [1] = {x = 6, y = 53},
        [2] = {x = 6, y = 50},
        [3] = {x = 10, y = 44},
        [4] = {x = 12, y = 42},
        [5] = {x = 12, y = 43},
        [6] = {x = 12, y = 42},
        [7] = {x = 12, y = 43},
        [8] = {x = 12, y = 43},
        [9] = {x = 12, y = 43},
        [10] = {x = 12, y = 43},
        [11] = {x = 12, y = 43},
        [12] = {x = 10, y = 41},
        [13] = {x = 10, y = 42},
        [14] = {x = 9, y = 42},
        [15] = {x = 10, y = 42},
        [16] = {x = 10, y = 42},
        [17] = {x = 10, y = 42},
        [18] = {x = 10, y = 42},
        [19] = {x = 10, y = 42},
        [20] = {x = 10, y = 42},
        [21] = {x = 10, y = 42},
        [22] = {x = 10, y = 42},
        [23] = {x = 10, y = 42},
        [24] = {x = 10, y = 42},
        [25] = {x = 9, y = 42},
        [26] = {x = 10, y = 41},
        [27] = {x = 13, y = 42},
        [28] = {x = 12, y = 41},
        [29] = {x = 12, y = 41},
        [30] = {x = 12, y = 41},
        [31] = {x = 12, y = 42},
        [32] = {x = 10, y = 44},
        [33] = {x = 6, y = 50},
        [34] = {x = 6, y = 53},
    },
    [Sprite.find("TitanDeath")] = {
        [1] = {x = 3, y = 55},
    },
    [Sprite.find("TitanGoldIdle")] = {
        [1] = {x = 6, y = 53},
    },
    [Sprite.find("TitanGoldWalk")] = {
        [1] = {x = 8, y = 48},
        [2] = {x = 6, y = 50},
        [3] = {x = 6, y = 51},
        [4] = {x = 6, y = 52},
        [5] = {x = 9, y = 47},
        [6] = {x = 8, y = 49},
        [7] = {x = 7, y = 50},
        [8] = {x = 7, y = 51},
        [9] = {x = 7, y = 52},
        [10] = {x = 7, y = 47},
    },
    [Sprite.find("TitanGoldShoot1")] = {
        [1] = {x = 6, y = 53},
        [2] = {x = 6, y = 50},
        [3] = {x = 10, y = 44},
        [4] = {x = 12, y = 42},
        [5] = {x = 12, y = 43},
        [6] = {x = 12, y = 42},
        [7] = {x = 12, y = 43},
        [8] = {x = 12, y = 43},
        [9] = {x = 12, y = 43},
        [10] = {x = 12, y = 43},
        [11] = {x = 12, y = 43},
        [12] = {x = 10, y = 41},
        [13] = {x = 10, y = 42},
        [14] = {x = 9, y = 42},
        [15] = {x = 10, y = 42},
        [16] = {x = 10, y = 42},
        [17] = {x = 10, y = 42},
        [18] = {x = 10, y = 42},
        [19] = {x = 10, y = 42},
        [20] = {x = 10, y = 42},
        [21] = {x = 10, y = 42},
        [22] = {x = 10, y = 42},
        [23] = {x = 10, y = 42},
        [24] = {x = 10, y = 42},
        [25] = {x = 9, y = 42},
        [26] = {x = 10, y = 41},
        [27] = {x = 13, y = 42},
        [28] = {x = 12, y = 41},
        [29] = {x = 12, y = 41},
        [30] = {x = 12, y = 41},
        [31] = {x = 12, y = 42},
        [32] = {x = 10, y = 44},
        [33] = {x = 6, y = 50},
        [34] = {x = 6, y = 53},
    },
    [Sprite.find("TitanGoldDeath")] = {
        [1] = {x = 3, y = 55},
    },
}

titanLaser:addCallback("create", function(self)
    local data = self:getData()
    data.phase = 0
    data.life = 0
    data.x = self.x
    data.y = self.y
    data.angle = 0
    data.targetAngle = 0
    if not data.parent then
        data.speed = 1
        data.xOff = 0
        data.yOff = 0
        data.parent = actors:findNearest(self.x, self.y)
        data.angle = data.parent:getFacingDirection()
    end
    data.alpha = 0

end)
titanLaser:addCallback("step", function(self)
    if misc.getTimeStop() == 0 then
        local data = self:getData()
        if data.parent then --if the laser has a parent, move it to its appropriate location
            if not data.parent:isValid() then
                self:destroy()
                return
            end
            local xOff = laserOffsets[data.parent.sprite][math.floor(data.parent.subimage)].x or laserOffsets[data.parent.sprite][1].x
            local yOff = laserOffsets[data.parent.sprite][math.floor(data.parent.subimage)].y or laserOffsets[data.parent.sprite][1].y
            self.x = data.parent.x + (xOff * data.parent.xscale)
            self.y = data.parent.y - yOff
            if data.gold then
                data.speed = data.parent:get("attack_speed") * 1.5
            else
                data.speed = data.parent:get("attack_speed")
            end
        end
        data.wiggle = data.speed
        if data.gold then
            data.wiggle = data.wiggle / 5
        end
        data.targetAngle = math.deg(math.atan2(self.y-data.y,self.x-data.x)) --get angle to target
        data.angle = math.approach(data.angle, data.targetAngle, 0.1) --incriment angle
        data.angle = data.angle + math.random(-data.wiggle, data.wiggle)
    
        --find target
        data.target = nil
        local target = nil
        if data.parent and data.parent:get("target") then
            target = Object.findInstance(data.parent:get("target"))
        end
        if target then
            data.target = target
        else
            local potentialTargets = actors:findMatchingOp("team", "~=", data.parent:get("team"))
            for _, inst in ipairs(potentialTargets) do
                if data.parent:get("team") == "player" and inst:getObject() ~= Object.find("P", "vanilla") then
                    if inst:isValid() then
                        data.target = inst
                        break
                    end
                else
                    if inst:isValid() then
                        data.target = inst
                        break
                    end
                end
            end
        end
        -------
        local zz = math.clamp(math.sqrt(math.pow(self.x - data.x,2) + math.pow(self.y - data.y,2)), 0, maxLaserLength) --approximate laser length
        for i = 0, zz do
            if data.target:collidesMap(self.x + ((data.target.x - self.x) * (i / zz)),self.y + ((data.target.y - self.y) * (i / zz))) or data.target:getObject():findLine(self.x, self.y, self.x + ((data.target.x - self.x) * (i / zz)), self.y + ((data.target.y - self.y) * (i / zz))) then
                if data.phase == 0 then
                    data.x = self.x + (( data.target.x - self.x) * (i / zz))
                    data.y = self.y + (( data.target.y - self.y) * (i / zz))
    
                elseif data.phase == 1 then
                    if data.target:collidesMap(data.x,data.y) or data.target:getObject():findLine(self.x, self.y, data.x, data.y) then
                        data.x = self.x + (( data.target.x - self.x) * (i / zz))
                        data.y = self.y + (( data.target.y - self.y) * (i / zz))
    
                    else
                        data.x = math.approach(data.x, self.x + (( data.target.x - self.x) * (i / zz)), data.speed)
                        data.y = math.approach(data.y, self.y + (( data.target.y - self.y) * (i / zz)), data.speed)
                    end
                end
                i = zz
                break
            else
                data.x = self.x + (( data.target.x - self.x) * (i / zz))
                data.y = self.y + (( data.target.y - self.y) * (i / zz))
            end
        end
    
        if data.phase == 0 then
            data.life = data.life + 1
            if data.life >= 3*60 then
                data.life = 0
                sounds.shoot2_1:play(1 + math.random() * 0.005)
                data.phase = 1
            end
        elseif data.phase == 1 then
            if not sounds.shoot2_2:isPlaying() then
                sounds.shoot2_2:loop()
            end
            data.life = math.round(data.life + data.speed)
            if data.life % 10 == 0 then
                if data.parent then
                    if data.gold then
                        data.parent:fireExplosion(data.x, data.y, 0.25, 1, 0.1, nil, nil, nil)
                    else
                        data.parent:fireExplosion(data.x, data.y, 0.25, 1, 0.125, nil, nil, nil)
                    end
                end
            end
            if data.life % 15 == 0 and data.gold then
                if data.parent then
                    local bullet = titanBullet:create(self.x, self.y)
                    local info = bullet:getData()
                    bullet:set("angle", data.parent:getFacingDirection() + math.random(-20, 20))
                    info.target = data.target
                    bullet:set("team", data.parent:get("team"))
                end
            end
            if data.life > 240 then
                self:destroy()
            end
        end
        if data.parent then
            if not data.parent:isValid() or data.parent:get("stunned") > 0 or data.parent:get("state") == "feared" then
                self:destroy()
            end
        end
    end
end)
titanLaser:addCallback("destroy", function(self)
    local data = self:getData()
    if sounds.shoot2_2:isPlaying() then
        sounds.shoot2_2:stop()
    end
end)
titanLaser:addCallback("draw", function(self)
    local data = self:getData()
    if data.phase == 0 then
        if data.life < 60 then
            data.alpha = math.clamp(data.alpha + 0.01, 0, 1)
        elseif data.life >= 2.5*60 then
            data.alpha = math.sin(data.life)
        end
        graphics.alpha(data.alpha)
        graphics.circle(self.x, self.y, math.sin(data.life) * 5, true)
        graphics.color(Color.fromRGB(186, 84, 86))
        graphics.line(self.x, self.y, data.x, data.y, 2)
        graphics.circle(data.x, data.y, 3, false)
    elseif data.phase == 1 then
        graphics.setBlendMode("additive")
        graphics.alpha(0.5)
        graphics.color(Color.fromRGB(186, 84, 86))
        graphics.circle(self.x, self.y, 4 + math.cos(data.life), false)
        graphics.line(self.x, self.y, data.x, data.y, 5 + math.sin(data.life))
        if data.gold then
            graphics.color(Color.YELLOW)
        else 
            graphics.color(Color.ROR_RED)
        end
        graphics.circle(self.x, self.y, 2 + math.sin(data.life), false)
        graphics.line(self.x, self.y, data.x, data.y, 1 + math.sin(data.life))
        bulletFX:burst("middle", data.x, data.y, 1)
        graphics.setBlendMode("normal")
    end
end)


local titanRocks = Object.new("TitanRocks")
local rubble = ParticleType.new("Rubble3")
rubble:sprite(Sprite.find("EfRubble", "vanilla"), false, false, true)
rubble:size(0.9, 1.1, -0.02, 0)
rubble:angle(0, 360, 0, 0, true)
rubble:speed(0.1, 1, 0, 0)
rubble:direction(0, 360, 0, 0)
rubble:life(30, 30)


titanRocks:addCallback("create", function(self)
    local data = self:getData()
    data.life = 0
    data.height = sprites.idle.height
    data.heightCount = data.height
    sounds.shoot3_1:play(1 + math.random() * 0.05)
end)
titanRocks:addCallback("step", function(self)
    if misc.getTimeStop() == 0 then
        local data = self:getData()
        data.life = data.life + 1
        if data.life == 60 and not sounds.shoot3_2:isPlaying() then
            sounds.shoot3_2:loop()
        end
        if data.parent then
            if not data.parent:isValid() then
                self:destroy()
                return
            end
            if data.heightCount > 0 then
                data.yOff = data.yOff - (math.sin((data.life * (0.5 * math.pi))/data.height))
                data.heightCount = data.heightCount - 1
            end
            self.x = data.parent.x + data.xOff
            self.y = data.parent.y + data.yOff
            local target = Object.findInstance(data.parent:get("target"))
            if target then
                if data.life % 120 == 0 then
                    local bullet = titanBullet:create(self.x, self.y)
                    local info = bullet:getData()
                    bullet:set("angle", data.parent:getFacingDirection() + math.random(-20, 20))
                    info.target = target
                    bullet:set("team", data.parent:get("team"))
                end
            end
        end
        if data.life > 20*60 then
            self:destroy()
        end

    end
end)
titanRocks:addCallback("destroy", function(self)
    local data = self:getData()
    if sounds.shoot3_2:isPlaying() then
        sounds.shoot3_2:stop()
    end
end)
titanRocks:addCallback("draw", function(self)
    local data = self:getData()
    bulletFX:burst("middle", self.x + math.random(-2, 2), self.y + math.random(-2, 2), 1)
    if data.life % 1 == 0 then
        rubble:burst("middle", self.x + math.random(-6, 6), self.y + math.random(-6, 6), 1)
    end
end)

local titanFist = Object.new("TitanFist")
local fistSprites = {
    normal = Sprite.load("TitanFist", "Actors/titan/fist", 14, 19, 35),
    gold = Sprite.load("TitanGoldFist", "Actors/titan/fistGold", 14, 19, 35),
}
titanFist:addCallback("create", function(self)
    local data = self:getData()
    if data.gold then
        self.sprite = fistSprites.gold
    else
        self.sprite = fistSprites.normal
    end
    if data.parent then
        self.spriteSpeed = data.parent:get("attack_speed")
    else
        self.spriteSpeed = 0.25
    end
    data.phase = 0
    data.life = 0
    data.next = false
    data.attack = nil
    if math.random() < 0.5 then self.xscale = -1 else self.xscale = 1 end

end)
titanFist:addCallback("step", function(self)
    local data = self:getData()
    data.life = data.life + 1
    if data.life >= 10*60 then
        self:destroy()
        return
    end
    if data.phase == 0 then --Initial state
        if math.floor(self.subimage) == 6 then
            self.spriteSpeed = 0
        end
        if data.next and data.next == true then
            misc.shakeScreen(5)
            sounds.shoot1_2:play(1 + math.random() * 0.05)
            if data.parent then
                self.spriteSpeed = data.parent:get("attack_speed") * 0.2
            else
                self.spriteSpeed = 0.25
            end
            for i = 0, math.random(5, 10) do
                bulletHit:burst("middle", self.x + math.random(-self.sprite.width/2, self.sprite.width/2), self.y, 1)
            end
            data.phase = 1
            data.life = 0
            data.next = nil
        end
    elseif data.phase == 1 then --PUNCH
        if math.floor(self.subimage) == 8 and not data.attack then
            local explosion
            if data.parent and data.parent:isValid() then
                explosion = data.parent:fireExplosion(self.x, self.y, 1, 1, 1, nil, nil, nil)
            else
                explosion = misc.fireExplosion(self.x, self.y, 1, 1, 40 * Difficulty.getScaling("damage"), "enemy", nil, nil)
            end
            explosion:set("climb", self.sprite.height)
            explosion:set("knockup", 5)
            data.attack = true
        elseif math.floor(self.subimage) == 10 then
            self.spriteSpeed = 0
        end
        if data.next and data.next == true then
            data.phase = 2
            if data.parent then
                self.spriteSpeed = 0.2 * data.parent:get("attack_speed")
            else
                self.spriteSpeed = 0.2
            end
            data.next = false
        end
    elseif data.phase == 2 then --Retract into ground
        if math.floor(self.subimage) >= 14 then
            self:destroy()
        end
    end

end)


callback.register("onGameEnd", function()
    if sounds.shoot2_2:isPlaying() then
        sounds.shoot2_2:stop()
    end
    if sounds.shoot3_2:isPlaying() then
        sounds.shoot3_2:stop()
    end
end)

local titan = Object.base("BossClassic", "Titan")
titan.sprite = sprites.idle

titan:addCallback("create", function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    self.name = "Stone Titan"
    self.name2 = "Crisis Vanguard"
    self.maxhp = 1400 * Difficulty.getScaling("hp")
    self.hp = self.maxhp
    self.damage = 40 * Difficulty.getScaling("damage")
    self.armor = 20
    self.pHmax = 0.5
    actor:setAnimations{
        idle = sprites.idle,
        walk = sprites.walk,
        jump = sprites.idle,
        shoot1 = sprites.shoot1,
        death = sprites.death
    }
    self.sound_hit = sounds.hurt.id
    self.sound_death = sounds.death.id
    actor.mask = sprites.mask
    self.show_boss_health = 1
    self.health_tier_threshold = 1
    self.knockback_cap = self.maxhp
    actor:set("sprite_palette", Sprite.find("GolemPal", "vanilla").id)
    self.z_range = 0
    self.x_range = 200
    data.fist = nil
    self.c_range = 0
    data.rocks = nil
    self.v_range = 300
    self.shake_frame = 7
    self.can_drop = 0
    self.can_jump = 0
    data.rage = false
    actor.y = FindGround(actor.x, actor.y)
end)

titan:addCallback("step", function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    self.z_skill = 0
    if self.hp <= self.maxhp*0.5 and not data.rage then
        self.x_range = 9999
        self.c_skill = 1
        self.state = "attack3"
        data.rage = true
    end
    if self.state == "attack1" then
        self.state = "chase"
    end
    if self.state == "attack2" then --PUNCH
        if actor:getAlarm(3) <= -1 then
            if self.free ~= 1 then
                self.pHspeed = 0
            end
            if actor.sprite == sprites.shoot1 then
                local frame = math.floor(actor.subimage)
                if frame >= sprites.shoot1.frames or self.state == "feared" or self.state ~= "attack2" or self.stunned > 0 then
                    if data.fist then 
                        if data.fist:isValid() then
                            data.fist:destroy() 
                        end
                        data.fist = nil
                    end
                    self.activity = 0
                    self.activity_type = 0
                    actor.spriteSpeed = 0.25
                    self.state = "chase"
                    data.fist = nil
                    actor:setAlarm(3, (5*60))
                    --actor.sprite = sprites.idle
                    self.activity_var1 = 0
                    return
                end
                if frame == 1 then
                    if self.activity_var1 == 0 then
                        sounds.shoot1_1:play(1 + math.random() * 0.05)
                        self.activity_var1 = 1
                    end
                    if not data.fist then
                        local target = Object.findInstance(self.target)
                        data.fist = titanFist:create(target.x, FindGround(target.x, target.y))
                        data.fist:getData().parent = actor
                    end
                elseif frame == 12 then
                    misc.shakeScreen(5)
                    if data.fist:getData().phase and data.fist:getData().phase == 0 then
                        data.fist:getData().next = true
                    end
                elseif frame == 25 then
                    if data.fist:getData().phase and data.fist:getData().phase == 1 then
                        data.fist:getData().next = true
                    end
                end
            else
                actor.subimage = 1
                self.z_skill = 0
                actor.sprite = sprites.shoot1
                actor.spriteSpeed = self.attack_speed * 0.20
                self.activity = 2
                self.activity_type = 1
            end
        else
            print("Can't use skill now, still on cooldown :(")
        end
    end
    if self.state == "attack3" and data.rage == true then --Summon Rocks
        if data.rocks then
            if data.rocks:isValid() then
                return
            end
        end
        if actor:getAlarm(4) <= -1 then
            if self.free ~= 1 then
                self.pHspeed = 0
            end
            if actor.sprite == sprites.shoot1 then
                self.stun_immune = 1
                local frame = math.floor(actor.subimage)
                if frame >= sprites.shoot1.frames or self.state == "feared" or self.state ~= "attack3" or self.stunned > 0 then
                    self.activity = 0
                    self.activity_type = 0
                    actor.spriteSpeed = 0.25
                    self.state = "chase"
                    
                    actor:setAlarm(4, (40*60))
                    return
                end
                if frame == 1 then
                    if not data.rocks then
                        local target = Object.findInstance(self.target)
                        local xOff = actor.sprite.width * actor.xscale
                        data.rocks = titanRocks:create(actor.x + xOff, actor.y)
                        data.rocks:getData().xOff = xOff
                        data.rocks:getData().yOff = 0
                        data.rocks:getData().parent = actor
                    end
                end
            else
                actor.subimage = 1
                self.x_skill = 0
                actor.sprite = sprites.shoot1
                actor.spriteSpeed = 0.20
                self.activity = 3
                self.activity_type = 1
            end
        end
    end
    if self.state == "attack4" then --Laser
        if actor:getAlarm(5) <= -1 then
            local laser = titanLaser:create(actor.x, actor.y - (actor.sprite.height/2))
            local info = laser:getData()
            info.parent = actor
            info.xOff = 5
            info.yOff = -actor.sprite.height + 20
            laser:set("team", self.team)
            info.target = Object.findInstance(self.target)
            --info.gold = true
            laser.depth = actor.depth - 1
            actor:setAlarm(5, (20*60))
            self.state = "chase"
        end
    end
end)

local monsLog = MonsterLog.new("Stone Titan")
MonsterLog.map[titan] = monsLog

monsLog.displayName = "Stone Titan"
monsLog.story = "A flash of red lightning, and a hillside moved to form this gargantuan warrior.\n\nIt towers over its lesser brethren... Could it be a higher ranking construct? It certainly seems to be, using a potent laser weapon to tear through whatever defenses I throw up.\n\n...First the Golems, then the Colossus, and now this."
monsLog.statHP = 2100
monsLog.statDamage = 40
monsLog.statSpeed = 0.5
monsLog.sprite = sprites.shoot1
monsLog.portrait = sprites.idle
monsLog.portraitSubimage = 1

local titanCard = MonsterCard.new("Stone Titan", titan)
titanCard.sprite = sprites.idle
titanCard.sound = sounds.spawn
titanCard.canBlight = true
titanCard.isBoss = true
titanCard.type = "classic"
titanCard.cost = 620
for _, elite in ipairs(EliteType.findAll("vanilla")) do
    titanCard.eliteTypes:add(elite)
end

local titanSpawns = {
    Stage.find("Desolate Forest", "vanilla"),
    Stage.find("Dried Lake", "vanilla"),
    Stage.find("Ancient Valley", "vanilla"),
    Stage.find("Magma Barracks", "vanilla"),
    Stage.find("Risk of Rain", "vanilla"),
}

for _, stage in ipairs(titanSpawns) do
    stage.enemies:add(titanCard)
end

local titanGold = Object.base("BossClassic", "TitanGold")
titanGold.sprite = sprites.idleG

titanGold:addCallback("create", function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    self.name = "Aurelionite"
    self.name2 = "Titanic Goldweaver"
    self.maxhp = 2100 * Difficulty.getScaling("hp")
    self.hp = self.maxhp
    self.damage = 40 * Difficulty.getScaling("damage")
    self.armor = 20
    self.pHmax = 0.5
    actor:setAnimations{
        idle = sprites.idleG,
        walk = sprites.walkG,
        jump = sprites.idleG,
        shoot1 = sprites.shoot1G,
        death = sprites.deathG
    }
    self.sound_hit = sounds.hurt.id
    self.sound_death = sounds.death.id
    actor.mask = sprites.mask
    self.show_boss_health = 1
    self.health_tier_threshold = 1
    self.knockback_cap = self.maxhp
    --actor.sprite = sprites.spawnself.z_range = 100
    self.z_range = 9999
    data.fist = {}
    self.x_range = 2000
    data.rocks = nil
    self.v_range = 300
    self.shake_frame = 7
    self.can_drop = 0
    self.can_jump = 0
    data.rage = false
    actor.y = FindGround(actor.x, actor.y)
end)
titanGold:addCallback("step", function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    self.z_skill = 0
    if self.hp <= self.maxhp*0.5 and not data.rage then
        self.x_range = 9999
        self.c_skill = 1
        self.state = "attack3"
        data.rage = true
    end
    if self.state == "attack1" then
        self.state = "chase"
    end
    if self.state == "attack2" then --PUNCH
        if actor:getAlarm(3) <= -1 then
            if self.free ~= 1 then
                self.pHspeed = 0
            end
            if actor.sprite == sprites.shoot1G then
                self.state = "attack2"
                local frame = math.floor(actor.subimage)
                if frame >= sprites.shoot1G.frames or self.state == "feared" or self.state ~= "attack2" or self.stunned > 0 then
                    if data.fist then 
                        for _, inst in ipairs(data.fist) do
                            if inst:isValid() then
                                inst:destroy() 
                            end
                        end
                        data.fist = nil
                    end
                    self.activity = 0
                    self.activity_type = 0
                    actor.spriteSpeed = 0.25
                    self.state = "chase"
                    data.fist = nil
                    actor:setAlarm(3, (5*60))
                    --actor.sprite = sprites.idle
                    self.activity_var1 = 0
                    return
                end
                if frame == 1 then
                    if self.activity_var1 == 0 then
                        sounds.shoot1_1:play(1 + math.random() * 0.05)
                        self.activity_var1 = 1
                        data.fist = nil
                    end
                    if not data.fist then
                        local target = Object.findInstance(self.target)
                        local x = actor.x
                        local y = actor.y
                        if target and target.x and target.y then
                            x = target.x
                            y = target.y
                        end
                        data.fist = {
                            [1] = titanFist:create(x - (fistSprites.gold.width * 2), FindGround(x, y)),
                            [2] = titanFist:create(x - (fistSprites.gold.width * 1), FindGround(x, y)),
                            [3] = titanFist:create(x, FindGround(x, y)),
                            [4] = titanFist:create(x + (fistSprites.gold.width * 1), FindGround(x, y)),
                            [5] = titanFist:create(x + (fistSprites.gold.width * 2), FindGround(x, y)),
                        }
                        for _, i in ipairs(data.fist) do
                            i:getData().gold = true
                            i.sprite = fistSprites.gold
                            i:getData().parent = actor
                        end
                    end
                elseif frame == 12 then
                    misc.shakeScreen(5)
                    if data.fist[1]:getData().phase and data.fist[1]:getData().phase == 0 then
                        data.fist[1]:getData().next = true
                    end
                elseif frame == 13 then
                    misc.shakeScreen(5)
                    if data.fist[2]:getData().phase and data.fist[2]:getData().phase == 0 then
                        data.fist[2]:getData().next = true
                    end
                elseif frame == 14 then
                    misc.shakeScreen(5)
                    if data.fist[3]:getData().phase and data.fist[3]:getData().phase == 0 then
                        data.fist[3]:getData().next = true
                    end
                elseif frame == 15 then
                    misc.shakeScreen(5)
                    if data.fist[4]:getData().phase and data.fist[4]:getData().phase == 0 then
                        data.fist[4]:getData().next = true
                    end
                elseif frame == 16 then
                    misc.shakeScreen(5)
                    if data.fist[5]:getData().phase and data.fist[5]:getData().phase == 0 then
                        data.fist[5]:getData().next = true
                    end
                elseif frame == 25 then
                    for _, i in ipairs(data.fist) do
                        if i:getData().phase and i:getData().phase == 1 then
                            i:getData().next = true
                        end
                    end
                end
            else
                actor.subimage = 1
                self.z_skill = 0
                actor.sprite = sprites.shoot1G
                actor.spriteSpeed = self.attack_speed * 0.20
                self.activity = 2
                self.activity_type = 1
            end
        end
    end
    if self.state == "attack3" and data.rage == true then --Summon Rocks
        if data.rocks then
            if data.rocks:isValid() then
                return
            end
        end
        if actor:getAlarm(4) <= -1 then
            if self.free ~= 1 then
                self.pHspeed = 0
            end
            if actor.sprite == sprites.shoot1 then
                self.stun_immune = 1
                local frame = math.floor(actor.subimage)
                if frame >= sprites.shoot1.frames or self.state == "feared" or self.state ~= "attack3" or self.stunned > 0 then
                    self.activity = 0
                    self.activity_type = 0
                    actor.spriteSpeed = 0.25
                    self.state = "chase"
                    
                    actor:setAlarm(4, (40*60))
                    return
                end
                if frame == 1 then
                    if not data.rocks then
                        local target = Object.findInstance(self.target)
                        local xOff = actor.sprite.width * actor.xscale
                        data.rocks = titanRocks:create(actor.x + xOff, actor.y)
                        data.rocks:getData().xOff = xOff
                        data.rocks:getData().yOff = 0
                        data.rocks:getData().parent = actor
                    end
                end
            else
                actor.subimage = 1
                self.x_skill = 0
                actor.sprite = sprites.shoot1
                actor.spriteSpeed = 0.20
                self.activity = 3
                self.activity_type = 1
            end
        end
    end
    if self.state == "attack4" then --Laser
        if actor:getAlarm(5) <= -1 then
            local laser = titanLaser:create(actor.x, actor.y - (actor.sprite.height/2))
            local info = laser:getData()
            info.parent = actor
            info.xOff = 5
            info.yOff = -actor.sprite.height + 20
            laser:set("team", self.team)
            info.target = Object.findInstance(self.target)
            info.gold = true
            laser.depth = actor.depth - 1
            actor:setAlarm(5, (20*60))
            self.state = "chase"
        end
    end
end)

local monsLogGold = MonsterLog.new("Aurelionite")
MonsterLog.map[titanGold] = monsLogGold

monsLogGold.displayName = "Aurelionite"
monsLogGold.story = "???"
monsLogGold.statHP = 2100
monsLogGold.statDamage = 40
monsLogGold.statSpeed = 0.5
monsLogGold.sprite = sprites.idleG
monsLogGold.portrait = sprites.portraitG
monsLogGold.portraitSubimage = 1

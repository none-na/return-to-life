local sprites = {
    idle = Sprite.load("ClayGIdle", "Actors/templar/idle", 1, 13,24),
    walk = Sprite.load("ClayGWalk", "Actors/templar/walk", 7, 13,27),
    --jump = Sprite.load("ClayGJump", "Actors/beetleGuard/jump", 1, 6,3),
    shoot1_1 = Sprite.load("ClayGShoot1_1", "Actors/templar/shoot1_1", 14, 13, 24),
    shoot1_2 = Sprite.load("ClayGShoot1_2", "Actors/templar/shoot1_2", 4, 12, 23),
    shoot1_3 = Sprite.load("ClayGShoot1_3", "Actors/templar/shoot1_3", 9, 13, 23),
    shoot2 = Sprite.load("ClayGShoot2", "Actors/templar/shoot2", 9, 13, 23),
    spawn = Sprite.load("ClayGSpawn", "Actors/templar/spawn", 12,13,32),
    death = Sprite.load("ClayGDeath", "Actors/templar/death", 13, 45,33),
    mask = Sprite.load("ClayGMask", "Actors/templar/mask", 1,13,24),
    palette = Sprite.load("ClayGPal", "Actors/templar/palette", 1,0,0),
}

local sounds = {
    death = Sound.load("ClayGDeath", "Sounds/SFX/templar/death.ogg"),
    shoot1_1 = Sound.load("ClayGShoot1_1", "Sounds/SFX/templar/shoot1_1.ogg"),
    shoot1_2 = Sound.load("ClayGShoot1_2", "Sounds/SFX/templar/shoot1_2.ogg"),
    shoot1_3 = Sound.load("ClayGShoot1_3", "Sounds/SFX/templar/shoot1_3.ogg"),
}

local templars = {}
local templarDirection = {}

callback.register("onStageEntry", function()
    templars = {}
end)

callback.register("onGameEnd", function()
    templars = {}
end)

local player = Object.find("P", "vanilla")
local enemy = ParentObject.find("enemies", "vanilla")

local maxGunTime = 5*60

local slowBuff = Buff.find("slow", "vanilla")

local barrage = Object.new("ClayGBarrage")
local impactSprite = Sprite.load("ClayGSparks", "Actors/templar/impact", 4, 10, 9)

barrage:addCallback("create", function(self)
    local data = self:getData()
    self:set("life", 30)
    if data.parent then
        data.target = Object.findInstance(data.parent:get("target"))
        self:set("damage", data.parent:get("damage"))
        self:set("team", data.parent:get("team"))
    else
        data.target = player:findNearest(self.x, self.y)
        self:set("damage", 16 * misc.director:get("enemy_buff"))
        self:set("team", "enemy")
    end
    data.x = data.target.x + math.random(-data.target:get("pHmax")*10, data.target:get("pHmax")*10) + (math.random() * (data.target:get("pHspeed") * 30))
    data.y = data.target.y + math.random(-data.target:get("pHmax")*10, data.target:get("pHmax")*10)
    
end)

barrage:addCallback("step", function(self)
    local data = self:getData()
    if self:get("life") > -1 then
        self:set("life", self:get("life") - 1)
    else
        if data.parent and data.parent:isValid() then 
            local explosion = data.parent:fireExplosion(data.x, data.y, 0.5, 1, 0.1, impactSprite, nil)
            if explosion:get("burn") then
                explosion:set("burn", explosion:get("burn") * 0.1)
            end
            explosion.xscale = templarDirection[data.parent] or 1
        end
        self:destroy()
    end
end)

barrage:addCallback("draw", function(self)
    local data = self:getData()
    if self:get("life") > -1 then
        graphics.color(Color.WHITE)
        graphics.alpha(1)
        graphics.circle(data.x, data.y, self:get("life") % 10, true)
        -----------------------
        graphics.color(Color.fromRGB(64, 64, 72))
        graphics.line(self.x + (15 * (templarDirection[data.parent] or 0)), self.y - 2, data.x, data.y, math.abs(math.sin(((2*math.pi)*self:get("life"))/30)))
    end
end)

local templar = Object.base("EnemyClassic", "ClayG")
templar.sprite = sprites.idle
EliteType.registerPalette(sprites.palette, templar)

templar:addCallback("create", function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    self.name = "Clay Templar"
    self.maxhp = 700 * Difficulty.getScaling("hp")
    self.hp = self.maxhp
    self.damage = 16 * Difficulty.getScaling("damage")
    self.pHmax = 1
    actor:setAnimations{
        idle = sprites.idle,
        walk = sprites.walk,
        jump = sprites.idle,
        shoot1 = sprites.shoot1_1,
        death = sprites.death
    }
    self.sound_hit = Sound.find("ClayHit","vanilla").id
    self.sound_death = sounds.death.id
    actor.mask = sprites.mask
    self.health_tier_threshold = 3
    self.knockback_cap = self.maxhp
    self.exp_worth = 50
    self.shake_frame = 8
    actor:set("sprite_palette", sprites.palette.id)
    self.z_range = 300
    self.x_range = 40
    data.shoot1 = 0
    templarDirection[actor] = 1
    self.can_drop = 0
    self.can_jump = 0
    data.lastSubimage = 0
end)

templar:addCallback("step", function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    if self.activity == 0 then
        templarDirection[actor] = actor.xscale
    end
    if self.state == "attack1" then --barrage
        if actor:getAlarm(2) <= -1 then
            local frame = math.floor(actor.subimage)
            if self.state == "feared" or self.state ~= "attack1" or self.stunned > 0 then
                self.activity = 0
                self.activity_type = 0
                actor.spriteSpeed = 0.25
                self.state = "chase"
                actor:setAlarm(2, (3*60))
                self.activity_var1 = 0
                self.activity_var2 = 0
                data.shoot1 = 0
                return
            end
            if data.shoot1 == 0 then --Wind up
                self.pHspeed = 0
                if actor.sprite == sprites.shoot1_1 then
                    if frame ~= data.lastSubimage then
                        if self.activity_var1 == 0 then
                            sounds.shoot1_1:play(self.attack_speed + math.random() * 0.05)
                            self.activity_var1 = 1
                        end
                        if frame >= sprites.shoot1_1.frames then
                            actor.subimage = 1
                            actor.sprite = sprites.shoot1_2
                            actor.spriteSpeed = self.attack_speed * 0.20
                            self.activity = 2
                            data.gunTime = 0
                            self.activity_type = 1
                            self.state = "attack1"
                            data.shoot1 = 1
                            return
                        end

                    end
                else
                    actor.subimage = 1
                    actor.sprite = sprites.shoot1_1
                    actor.spriteSpeed = self.attack_speed * 0.20
                    self.activity = 2
                    self.activity_type = 1
                end
            elseif data.shoot1 == 1 then --Barrage
                if actor.sprite == sprites.shoot1_2 then
                    data.gunTime = data.gunTime + 1
                    local target = Object.findInstance(self.target)
                    if frame ~= data.lastSubimage then
                        sounds.shoot1_2:play(0.8 + math.random() * 0.4)
                        local bullet = barrage:create(actor.x, actor.y)
                        local data2 = bullet:getData()
                        data2.parent = actor
                    end
                    if data.gunTime >= maxGunTime or ((actor.xscale == 1 and target.x < actor.x) or (actor.xscale == -1 and target.y > actor.x)) or (target and target:isValid() and GroundBetween(actor.x, actor.y, target.x, target.y)) then
                        actor.subimage = 1
                        actor.sprite = sprites.shoot1_3
                        actor.spriteSpeed = 0.2
                        self.activity = 2
                        self.activity_type = 1
                        data.shoot1 = 2
                        self.state = "attack1"
                        return
                    end
                    if self.z_skill == 1 then
                        if frame >= sprites.shoot1_2.frames then
                            actor.subimage = 1
                            actor.sprite = sprites.shoot1_2
                            actor.spriteSpeed = 0.2 * self.attack_speed
                            self.activity = 2
                            self.activity_type = 1
                            data.shoot1 = 1
                            self.state = "attack1"
                            return
                        end
                    end
                else
                    actor.subimage = 1
                    --self.z_skill = 0
                    actor.sprite = sprites.shoot1_1
                    actor.spriteSpeed = self.attack_speed * 0.20
                    self.activity = 2
                    self.activity_type = 1
                end

            elseif data.shoot1 == 2 then --Wind down
                if actor.sprite == sprites.shoot1_3 then
                    if frame ~= data.lastSubimage then
                        if frame == 1 then
                            sounds.shoot1_3:play(1 + math.random() * 0.05)
                        elseif frame >= sprites.shoot1_3.frames then
                            self.activity = 0
                            self.activity_type = 0
                            actor.spriteSpeed = 0.25
                            self.state = "chase"
                            actor:setAlarm(2, (3*60))
                            self.activity_var1 = 0
                            self.activity_var2 = 0
                            data.shoot1 = 0
                            return
                        end

                    end
                else
                    actor.subimage = 1
                    actor.sprite = sprites.shoot1_3
                    actor.spriteSpeed = 0.20
                    self.activity = 2
                    self.activity_type = 1
                end

            end
        end
    end
    if self.state == "attack2" then --barrage
        if actor:getAlarm(3) <= -1 then
            local frame = math.floor(actor.subimage)
            if frame >= sprites.shoot2.frames or self.state == "feared" or self.state ~= "attack1" or self.stunned > 0 then
                self.activity = 0
                self.activity_type = 0
                actor.spriteSpeed = 0.25
                self.state = "chase"
                actor:setAlarm(3, (5*60))
                self.activity_var1 = 0
                self.activity_var2 = 0
                return
            end
            if actor.sprite == sprites.shoot2 then
                self.pHspeed = 0
            else
                self.x_skill = 0
                self.activity = 3
                self.activity_type = 1
                self.activity_var1 = 0
                actor.sprite = sprites.shoot2
                actor.subimage = 1
                actor.spriteSpeed = 0.2 * self.attack_speed
                return
            end
        end
    end
    data.lastSubimage = math.floor(actor.subimage)
end)

local monsCard = MonsterCard.new("Clay Templar", templar)
monsCard.cost = 160
monsCard.type = "classic"
monsCard.sound = Sound.find("ClaySpawn", "vanilla")
monsCard.sprite = sprites.spawn
for _, e in ipairs(EliteType.findAll("vanilla")) do
    monsCard.eliteTypes:add(e)
end
monsCard.canBlight = true
monsCard.isBoss = false

local Stages = {
    ancientValley = Stage.find("Ancient Valley", "vanilla"),
    sunkenTomb = Stage.find("Sunken Tomb", "vanilla"),
    elders = Stage.find("Temple of the Elders", "vanilla"),
    ror = Stage.find("Risk of Rain", "vanilla"),
}

for _, s in ipairs(Stages) do
    s.enemies:add(monsCard)
end

local monsLog = MonsterLog.new("Clay Templar")
MonsterLog.map[templar] = monsLog

monsLog.displayName = "Clay Templar"
monsLog.story = "A brother of the Clay Man, the Templar wields a massive pot, easily the size of a man. From this pot spews a barrage of a tar-like substance. This tar is ghastly, and it seems to leech the life out of anything it touches. I saw a Lemurian stumble and fall into a pit of the stuff, and the poor creature shriveled to a husk.\n\nI attempted to scavenge the Templar's weapon, but I could hardly lift it. The thing must weigh a ton, and not even the Templars can lift it without issue. There's a single moment, after they fire, where they struggle with the weight of their pots. It is then that I must strike, if I am to survive."
monsLog.statHP = 700
monsLog.statDamage = 16
monsLog.statSpeed = 1
monsLog.sprite = sprites.shoot1_2
monsLog.portrait = sprites.idle
monsLog.portraitSubimage = 1
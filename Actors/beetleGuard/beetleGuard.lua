local sprites = {
    idle = Sprite.load("BeetleGIdle", "Actors/beetleGuard/idle", 1, 10,13),
    walk = Sprite.load("BeetleGWalk", "Actors/beetleGuard/walk", 12, 10,15),
    jump = Sprite.load("BeetleGJump", "Actors/beetleGuard/jump", 1, 6,12),
    shoot1 = Sprite.load("BeetleGShoot1", "Actors/beetleGuard/shoot1", 10, 12, 22),
    shoot2 = Sprite.load("BeetleGShoot2", "Actors/beetleGuard/shoot2", 9, 12, 34),
    spawn = Sprite.load("BeetleGSpawn", "Actors/beetleGuard/spawn", 8,8,16),
    death = Sprite.load("BeetleGDeath", "Actors/beetleGuard/death", 11, 17,21),
    mask = Sprite.load("BeetleGMask", "Actors/beetle/mask", 1, 6,6),
    palette = Sprite.find("BeetlePal", "RoR2Demake"),
    shoot1FX = Sprite.load("Slam", "Actors/beetleGuard/slam", 9, 16, 27)
}

local allySprites = {
    idle = Sprite.load("BeetleGSIdle", "Actors/beetleGuardAlly/idle", 1, 10,13),
    walk = Sprite.load("BeetleGSWalk", "Actors/beetleGuardAlly/walk", 12, 10,16),
    jump = Sprite.load("BeetleGSJump", "Actors/beetleGuardAlly/jump", 1, 6,12),
    shoot1 = Sprite.load("BeetleGSShoot1", "Actors/beetleGuardAlly/shoot1", 10, 12, 22),
    shoot2 = Sprite.load("BeetleGSShoot2", "Actors/beetleGuardAlly/shoot2", 9, 12, 34),
    spawn = Sprite.load("BeetleGSSpawn", "Actors/beetleGuardAlly/spawn", 8,17,16),
    death = Sprite.load("BeetleGSDeath", "Actors/beetleGuardAlly/death", 11, 17,21),
}

local sounds = {
    spawn = Sound.load("BeetleGSpawn", "Sounds/SFX/beetleGuard/spawn.ogg"),
    death = Sound.load("BeetleGDeath", "Sounds/SFX/beetleGuard/death.ogg"),
    slam = Sound.load("BeetleGShoot1", "Sounds/SFX/beetleGuard/slam.ogg"),
    sunder = Sound.load("BeetleGShoot2", "Sounds/SFX/beetleGuard/pound.ogg"),
}

local objects = {
    dust = Object.find("MinerDust", "vanilla"),
    sparks = Object.find("EfSparks", "vanilla")
}

local player = Object.find("P", "vanilla")
local poi = Object.find("POI", "vanilla")
local enemy = ParentObject.find("enemies", "vanilla")
local enemySearchRange = 150
local shouldBeWithinXOfParent = 50
local tpToParentRange = 500

local sunderProj = Object.new("SunderProjectile")
sunderProj:addCallback("create", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    data.life = 3*60
    data.team = "enemy"
    this.mask = sprites.mask
    this.sprite = sprites.mask
    data.damage = 12 * Difficulty.getScaling("damage")
    self.speed = 5
    self.direction = 0
    this.y = FindGround(this.x, this.y)
    data.target = poi:findNearest(this.x, this.y)
end)
sunderProj:addCallback("step", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    -------------------------
    if data.life > -1 then
        data.life = data.life - 1
    else
        this:destroy()
        return
    end
    -------------------------
    local dir = 1
    if self.direction == 180 then
        dir = -1
    end
    if not this:collidesMap(this.x, this.y) then
        if this:collidesMap(this.x, this.y + 16) then
            this.y = FindGround(this.x, this.y)
        else
            this:destroy()
            return
        end
    end
    if this:collidesMap(this.x + (self.speed * dir), this.y - 8) then
        if not this:collidesMap(this.x + (self.speed * dir), this.y - 16) then
            this.y = this.y - 16
        else
            this:destroy()
            return
        end
    end
    if data.target and data.target:isValid() then
        if data.target:get("parent") then
            local tgParent = Object.findInstance(data.target:get("parent"))
            if tgParent and this:collidesWith(tgParent, this.x, this.y) then
                this:destroy()
                return
            end
        end
        if this:collidesWith(data.target, this.x, this.y) then
            this:destroy()
            return
        end
    end
    -------------------------
    local dust = objects.dust:findNearest(this.x, this.y)
    if not dust or not this:collidesWith(dust, this.x, this.y - 6) then
        local d = objects.dust:create(this.x, this.y - 6)
        d.xscale = dir
    end
end)

sunderProj:addCallback("destroy", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    misc.shakeScreen(5)
    local exp
    if data.parent then
        exp = data.parent:fireExplosion(this.x, this.y, 1, 1, 1, sprites.shoot1FX, nil, nil)
    else
        exp = misc.fireExplosion(this.x, this.y, 1, 1, data.damage, data.team, sprites.shoot1FX, nil, nil)
    end
    exp:set("knockup", 3)
end)


local beetleG = Object.base("EnemyClassic", "BeetleG")
beetleG.sprite = sprites.idle

local beetleGAlly = Object.base("EnemyClassic", "BeetleGS")
beetleGAlly.sprite = sprites.idle

EliteType.registerPalette(sprites.palette, beetleG)

local InitBeetleGuard = function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    self.name = "Beetle Guard"
    self.maxhp = 600 * Difficulty.getScaling("hp")
    self.hp = self.maxhp
    self.damage = 12 * Difficulty.getScaling("damage")
    self.pHmax = 1.5
    actor:setAnimations{
        idle = sprites.idle,
        walk = sprites.walk,
        jump = sprites.idle,
        shoot1 = sprites.shoot1,
        shoot2 = sprites.shoot2,
        death = sprites.death
    }
    self.sound_hit = Sound.find("MushHit","vanilla").id
    self.sound_death = sounds.death.id
    actor.mask = sprites.mask
    self.health_tier_threshold = 3
    self.knockback_cap = self.maxhp
    self.exp_worth = 50
    self.shake_frame = 7
    self.stun_immune = 1
    actor:set("sprite_palette", sprites.palette.id)
    self.z_range = 20
    self.x_range = 150
    self.can_drop = 1
    self.can_jump = 1
end

local InitBeetleGuardAlly = function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    self.team = "player"
    self.name = "Beetle Guard"
    self.maxhp = 1200 * Difficulty.getScaling("hp")
    self.hp_regen = 0.1
    self.hp = self.maxhp
    self.damage = 12 * Difficulty.getScaling("damage")
    self.pHmax = 1.5
    actor:setAnimations{
        idle = allySprites.idle,
        walk = allySprites.walk,
        jump = allySprites.idle,
        shoot1 = allySprites.shoot1,
        shoot2 = allySprites.shoot2,
        death = allySprites.death
    }
    self.sound_hit = Sound.find("MushHit","vanilla").id
    self.sound_death = sounds.death.id
    actor.mask = sprites.mask
    self.health_tier_threshold = 1
    self.knockback_cap = self.maxhp
    self.shake_frame = 7
    self.stun_immune = 1
    actor:set("sprite_palette", sprites.palette.id)
    self.z_range = 20
    self.x_range = 150
    self.can_drop = 1
    self.can_jump = 1
    data.ally = true
    local p = poi:create(actor.x, actor.y)
    p:set("parent", actor.id)
end



local BeetleGStep = function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    if data.ally then
        local parent = data.parent
        if Distance(actor.x, actor.y, parent.x, parent.y) > shouldBeWithinXOfParent and Distance(actor.x, actor.y, parent.x, parent.y) <= shouldBeWithinXOfParent / 3 and actor.x >= parent.x - 16 and actor.x <= parent.x + 16 then
            if parent.x > actor.x then
                actor:set("moveLeft", 1)
                actor:set("moveRight", 0)
            else
                actor:set("moveLeft", 0)
                actor:set("moveRight", 1)
            end
        elseif Distance(actor.x, actor.y, parent.x, parent.y) > tpToParentRange then
            actor.x = parent.x
            actor.y = parent.y - actor.sprite.yorigin
        end
        if self.state == "spawn" then
            if actor.sprite == allySprites.spawn then
                self.invincible = 2
                local frame = math.floor(actor.subimage)
                if frame >= allySprites.spawn.frames then
                    self.activity = 0
                    self.activity_type = 0
                    actor.spriteSpeed = 0.25
                    self.state = "chase"
                    actor.sprite = allySprites.idle
                    return
                end
            else
                actor.sprite = allySprites.spawn
                actor.spriteSpeed = 0.25
                self.activity = 5
                self.activity_type = 3
                return
            end
        end
    end
    ---------------------------------------------------------
    if self.state == "attack1" then --slam
        if actor:getAlarm(2) <= -1 then
            if self.free ~= 1 then
                self.pHspeed = 0
            end
            if actor.sprite == actor:getAnimation("shoot1") then
                local frame = math.floor(actor.subimage)
                if frame >= actor:getAnimation("shoot1").frames or self.state == "feared" or self.state ~= "attack1" or self.stunned > 0 then
                    self.activity = 0
                    self.activity_type = 0
                    actor.spriteSpeed = 0.25
                    self.state = "chase"
                    actor:setAlarm(2, (3*60))
                    self.activity_var1 = 0
                    self.activity_var2 = 0
                    return
                end
                if frame == 1 then
                    if self.activity_var1 == 0 then
                        sounds.slam:play(self.attack_speed + math.random() * 0.05)
                        self.activity_var1 = 1
                    end
                elseif frame == 8 then
                    if self.activity_var2 == 0 then
                        misc.shakeScreen(5)
                        local slam = actor:fireExplosion(actor.x + (5 * actor.xscale), FindGround(actor.x, actor.y), 1, 1, 4.4, sprites.shoot1FX, nil, nil)
                        slam:getAccessor().knockup = 5
                        slam.depth = actor.depth - 1
                        self.activity_var2 = 1
                    end
                end
            else
                actor.subimage = 1
                self.z_skill = 0
                actor.sprite = actor:getAnimation("shoot1")
                actor.spriteSpeed = self.attack_speed * 0.20
                self.activity = 2
                self.activity_type = 1
            end
        end
    end
    if self.state == "attack2" then --sunder
        if actor:getAlarm(3) <= -1 then
            if self.free ~= 1 then
                self.pHspeed = 0
            end
            if actor.sprite == actor:getAnimation("shoot2") then
                local frame = math.floor(actor.subimage)
                if frame >= actor:getAnimation("shoot2").frames or self.state == "feared" or self.state ~= "attack2" or self.stunned > 0 then
                    self.activity = 0
                    self.activity_type = 0
                    actor.spriteSpeed = 0.25
                    self.state = "chase"
                    actor:setAlarm(3, (3*60))
                    self.activity_var1 = 0
                    self.activity_var2 = 0
                    return
                end
                if frame == 1 then
                    if self.activity_var1 == 0 then
                        sounds.sunder:play(self.attack_speed + math.random() * 0.05)
                        self.activity_var1 = 1
                    end
                elseif frame == 8 then
                    if self.activity_var2 == 0 then
                        misc.shakeScreen(5)
                        local s = sunderProj:create(actor.x + (8 * actor.xscale), actor.y)
                        s:set("direction", actor:getFacingDirection())
                        s:getData().parent = actor
                        s:getData().team = self.team
                        s:getData().damage = self.damage
                        s:getData().target = Object.findInstance(self.target)
                        self.activity_var2 = 1
                    end
                end
            else
                actor.subimage = 1
                self.z_skill = 0
                actor.sprite = actor:getAnimation("shoot2")
                actor.spriteSpeed = self.attack_speed * 0.20
                self.activity = 2
                self.activity_type = 1
            end
        end
    end
end

beetleG:addCallback("create", function(actor)
    InitBeetleGuard(actor)
end)

beetleG:addCallback("step", function(actor)
    if actor:isValid() then
        BeetleGStep(actor)
    end
end)

beetleGAlly:addCallback("create", function(actor)
    InitBeetleGuardAlly(actor)
end)

beetleGAlly:addCallback("step", function(actor)
    if actor:isValid() then
        BeetleGStep(actor)
    end
end)

beetleGAlly:addCallback("destroy", function(actor)
    local data = actor:getData()
    local parent = data.parent
    if parent then
        local d = parent:getData()
        d.guards = math.max(d.guards - 1, 0)
    end
end)

local monsCard = MonsterCard.new("Beetle Guard", beetleG)
monsCard.cost = 120
monsCard.type = "classic"
monsCard.sound = sounds.spawn
monsCard.sprite = sprites.spawn
for _, e in ipairs(EliteType.findAll("vanilla")) do
    monsCard.eliteTypes:add(e)
end
monsCard.canBlight = true
monsCard.isBoss = false

local monsLog = MonsterLog.new("Beetle Guard")
MonsterLog.map[beetleG] = monsLog

monsLog.displayName = "Beetle Guard"
monsLog.story = "The Beetle Guard is a vast and powerful beast, demanding fear and respect among the lesser Beetle drones. The Guard is absolutely terrifying to face in battle, as its chitin armor is much more durable than the average Beetle's. I spent many of my dwindling supplies trying to fell just one of them, and that battle took about an hour.\n\nDespite their hunched posture, the Guard is deceptively mobile, able to cross a 100 meter gap in under a minute. It attacks by swinging its tree trunk-like arms, sending rocks and dirt flying.\n\nAmong the Beetle hierarchy, the Guard seems to rank much higher than the lesser Beetle workers. I've observed a pack of Beetles fleeing once a Guard wandered into the area."
monsLog.statHP = 600
monsLog.statDamage = 12
monsLog.statSpeed = 1.5
monsLog.sprite = sprites.shoot1
monsLog.portrait = sprites.idle
monsLog.portraitSubimage = 1
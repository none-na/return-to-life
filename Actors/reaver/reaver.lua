local sprites = {
    idle = Sprite.load("NullifierIdle", "Actors/reaver/idle", 1, 16, 32),
    walk = Sprite.load("NullifierWalk", "Actors/reaver/walk", 10, 17, 34),
    death = Sprite.load("NullifierDeath", "Actors/reaver/death", 9, 16, 32),
    palette = Sprite.load("NullifierPal", "Actors/reaver/palette", 1, 0, 0),
    mask = Sprite.load("NullifierMask", "Actors/reaver/mask", 1, 16, 32),
    ----------------------------
    warning = Sprite.load("NullifierMortarWarning", "Actors/reaver/warning", 5, 6,9),
    blast = Sprite.load("NullifierMortarBlast", "Actors/reaver/blast", 4, 15, 56),
    nova = Sprite.load("NullifierDeathNova", "Actors/reaver/deathNova", 8, 50, 50),
    buffs = Sprite.load("VoidBuffs", "Graphics/voidBuff", 3, 9, 6.5)
}
local objects = {
    actors = ParentObject.find("actors", "vanilla"),
    sparks = Object.find("EfSparks", "vanilla"),
    flash = Object.find("EfFlash", "vanilla")
}
local sounds = {
    hurt = Sound.load("NullifierHit", "Sounds/SFX/reaver/hurt.ogg"),
    death = Sound.load("NullifierDeath", "Sounds/SFX/reaver/death.ogg"),
    death2 = Sound.load("NullifierDeath2", "Sounds/SFX/reaver/death2.ogg"),
    shoot1 = Sound.load("NullifierShoot1", "Sounds/SFX/reaver/shoot.ogg"),
    spawn = Sound.load("NullifierSpawn", "Sounds/SFX/reaver/spawn.ogg"),
    attack1 = Sound.load("NullifierMortar1", "Sounds/SFX/reaver/attack1.ogg"),
    attack2 = Sound.load("NullifierMortar2", "Sounds/SFX/reaver/attack2.ogg"),
    deathNovaCharge = Sound.load("NullifierNovaCharge", "Sounds/SFX/reaver/deathNovaCharge.ogg"),
    deathNovaBlast = Sound.load("NullifierNovaBlast", "Sounds/SFX/reaver/deathNovaBlast.ogg"),
}

local voidFX = ParticleType.new("ReaverParticle")
voidFX:shape("Square")
voidFX:color(Color.fromRGB(28, 8, 50), Color.fromRGB(135, 77, 150))
voidFX:alpha(0.5)
voidFX:scale(0.05, 0.07)
voidFX:size(0.9, 1, -0.02, 0.005)
voidFX:angle(0, 360, 1, 0.5, true)
voidFX:life(30, 30)


local debuffs = {
    [0] = Buff.new("Nullified1"),
    [1] = Buff.new("Nullified2"),
    [2] = Buff.new("NullifiedFull"),
}

debuffs[0].sprite = sprites.buffs
debuffs[0].subimage = 1

debuffs[1].sprite = sprites.buffs
debuffs[1].subimage = 2

debuffs[2].sprite = sprites.buffs
debuffs[2].subimage = 3

debuffs[2]:addCallback("start", function(actor)
    actor:set("pHmax2", actor:get("pHmax"))
    actor:set("pHmax", 0)
end)

debuffs[2]:addCallback("end", function(actor)
    actor:set("pHmax", actor:get("pHmax2"))
    actor:set("pHmax2", 0)
end)

callback.register("onHit", function(damager, hit, x, y)
    if damager:get("nullify") then
        if hit:hasBuff(debuffs[1]) or hit:hasBuff(debuffs[2]) then
            hit:removeBuff(debuffs[1])
            hit:applyBuff(debuffs[2], (3*60) * damager:get("nullify"))
        elseif hit:hasBuff(debuffs[0]) then
            hit:removeBuff(debuffs[0])
            hit:applyBuff(debuffs[1], (3*60) * damager:get("nullify"))
        else
            hit:applyBuff(debuffs[0], (3*60) * damager:get("nullify"))
        end
    end
end)

local MortarInit = function(this)
    local self = this:getAccessor()
    local data = this:getData()
    this.sprite = sprites.warning
    data.damage = 12 * Difficulty.getScaling("damage")
    data.team = "enemy"
    data.life = 60
    this.y = FindGround(this.x, this.y)
    this.spriteSpeed = 0.25
end

local MortarStep = function(this)
    local self = this:getAccessor()
    local data = this:getData()
    if data.life > -1 then
        data.life = data.life - 1
        if data.life == 15 then
            if math.random() < 0.5 then
                sounds.attack2:play(0.9 + math.random() * 0.2)
            else
                sounds.attack1:play(0.9 + math.random() * 0.2)
            end
        end
    else
        if data.parent and data.parent:isValid() then
            local explosion = data.parent:fireExplosion(this.x, this.y - (sprites.blast.height/2), 1, 5, 1, nil, nil)
            explosion:set("nullify", 1)
        else
            local explosion = misc.fireExplosion(this.x, this.y - (sprites.blast.height/2), 1, 5, data.damage, data.team, nil, nil)
            explosion:set("nullify", 1)
        end
        local sparks = objects.sparks:create(this.x, this.y)
        sparks.sprite = sprites.blast
        sparks.yscale = 1
        for i = 0, math.random(4, 10) do
            voidFX:burst("middle", this.x + math.random(-10, 10), this.y - math.random(sprites.blast.height), 1)
        end
        if math.random() < 0.5 then
            sparks.xscale = -1
        else
            sparks.xscale = 1
        end
        misc.shakeScreen(10)
        this:destroy()
        return
    end
end

local mortar = Object.new("NullifierMortar")
mortar.sprite = sprites.warning

mortar:addCallback("create", function(this)
    MortarInit(this)
end)

mortar:addCallback("step", function(this)
    MortarStep(this)
end)

local deathMessage = "You have been detained.\nAwait your sentence at the end of time."
local deathRadius = 100


local DeathNovaInit = function(this)
    local data = this:getData()
    data.maxLife = 200
    data.life = data.maxLife
    data.rate = 1
    local w, h = graphics.getGameResolution()
    data.r = w
    sounds.deathNovaCharge:play(data.rate + math.random() * 0.05)
end

local DeathNovaStep = function(this)
    local data = this:getData()
    if data.life > -1 then
        data.life = data.life - 1
        
    else
        local s = objects.sparks:create(this.x, this.y)
        s.sprite = sprites.nova
        misc.shakeScreen(30)
        sounds.deathNovaBlast:play(1 + math.random() * 0.05)
        for i = 0, math.random(25, 50) do
            local range = math.random(deathRadius)
            local angle = math.random(0, 360)
            local xx = math.cos(math.rad(angle)) * (range)
            local yy = math.sin(math.rad(angle)) * (range)
            voidFX:burst("middle", this.x + xx, this.y + yy, 1)
        end
        for _, inst in ipairs(objects.actors:findAllEllipse(this.x - deathRadius, this.y - deathRadius, this.x + deathRadius, this.y + deathRadius)) do
            if inst and inst:isValid() then
                inst:set("voidDeath", 1)
                inst:kill()
            end
        end
        this:destroy()
        return
    end
end
local DeathNovaDraw = function(this)
    local data = this:getData()
    if data.life > -1 then
        ------------------------------------------
        graphics.color(Color.fromRGB(135, 77, 150))
        graphics.alpha(math.clamp(0.5 * ((data.maxLife - data.life)/(data.maxLife*0.25)), 0, 0.5))
        graphics.circle(this.x, this.y, data.r * (data.life / data.maxLife), false)
        -----------------------------------------
        if math.random((data.life / data.maxLife)) == 0 then
            local range = 10
            local angle = math.random(0, 360)
            local xx = math.cos(math.rad(angle)) * (range)
            local yy = math.sin(math.rad(angle)) * (range)
            voidFX:burst("middle", this.x + xx, this.y + yy, 1)
        end
    end
end

local corpse = Object.find("EfPlayerDead", "vanilla")
callback.register("onStep", function()
    for _, body in ipairs(corpse:findAll()) do
        local b = body:getAccessor()
        local nearest = Object.find("P", "vanilla"):findNearest(b.x, b.y)
        if nearest and nearest:get("voidDeath") and nearest:get("voidDeath") > 0 then
            if not b.voided then
                b.vspeed = 0
                b.hspeed = 0
                body.sprite = Sprite.find("Empty")
                for i = 0, math.random(10, 30) do
                    voidFX:burst("above", body.x, body.y, 1)
                end
                b.death_message = deathMessage
                b.voided = 1
            end
        end
    end
end)


local deathNova = Object.new("NullifierNova")

deathNova:addCallback("create", function(this)
    DeathNovaInit(this)
end)
deathNova:addCallback("step", function(this)
    DeathNovaStep(this)
end)
deathNova:addCallback("draw", function(this)
    DeathNovaDraw(this)
end)

local nullifier = Object.base("EnemyClassic", "Nullifier")
nullifier.sprite = sprites.idle

EliteType.registerPalette(sprites.palette, nullifier)

local NullifierInit = function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    self.name = "Void Reaver"
    self.maxhp = 1900 * Difficulty.getScaling("hp")
    self.hp = self.maxhp
    self.damage = 12 * Difficulty.getScaling("damage")
    self.armor = 10
    self.pHmax = 0.65
    actor:setAnimations{
        idle = sprites.idle,
        walk = sprites.walk,
        jump = sprites.idle,
        death = sprites.death,
    }
    self.sound_hit = sounds.hurt.id
    self.sound_death = sounds.death.id
    actor.mask = sprites.mask
    self.health_tier_threshold = 3
    self.shake_frame = 5
    self.knockback_cap = self.maxhp
    actor:set("sprite_palette", sprites.palette.id)
    self.can_drop = 0
    self.can_jump = 0
    self.z_range = 500
    data.burstRadius = 50
end


local NullifierStep = function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    ---------------------------------------------
    local target = Object.findInstance(self.target)
    if not target then return end
    if self.z_skill == 1 and actor:getAlarm(2) == -1 then
        sounds.shoot1:play(self.attack_speed + math.random() * 0.05)
        local f = objects.flash:create(actor.x, actor.y)
        f:set("parent", actor.id)
        f:set("image_blend", Color.fromRGB(135, 77, 150).gml)
        for i=0, 7 do
            local xx = target.x + math.random(-data.burstRadius, data.burstRadius)
            local yy = FindGround(xx, target.y - math.random(0, data.burstRadius))
            local m = mortar:create(xx, yy)
            m:getData().parent = actor
            m:getData().damage = self.damage
            m:getData().team = self.team
        end
        self.z_skill = 0
        self.state = "idle"
        self.activity = 0
        actor:setAlarm(2, 5*60)
        return
    end
end

nullifier:addCallback("create", function(this)
    NullifierInit(this)
end)

nullifier:addCallback("step", function(this)
    NullifierStep(this)
end)

nullifier:addCallback("destroy", function(this)
    local exp = deathNova:create(this.x, this.y - 20)
end)

local monsLog = MonsterLog.new("Void Reaver")
MonsterLog.map[nullifier] = monsLog

monsLog.displayName = "Void Reaver"
monsLog.story = "I have little words to describe these monstrous Void Reavers.\n\nEven the most hostile creatures on this planet appear afraid of these crustacean... things. Towering over me, they shamble around on four articulated legs. Despite their slow movement, they use some form of ranged artillery to attack. Upon detonation, it snares me in some form of trap... I was barely able to escape when their attacks had immobilized me completely. I was just able to wriggle free from their grip when they attempted to drag me into some kind of portal.\n\nUnlike most creatures I've encountered, they don't seem to want me dead- if they did, I would certainly be dead by now. Whatever purpose they have for me lies beyond that nightmarish gateway they emerge from. A sense of dread fills me as I ponder the Reavers and whatever action of mine provoked their attack."
monsLog.statHP = 1900
monsLog.statDamage = 12
monsLog.statSpeed = 0.65
monsLog.sprite = sprites.walk
monsLog.portrait = sprites.idle
monsLog.portraitSubimage = 1

local monsCard = MonsterCard.new("Void Reaver", nullifier)
monsCard.sprite = sprites.idle
monsCard.sound = sounds.spawn
monsCard.canBlight = false
monsCard.isBoss = false
monsCard.type = "offscreen"
monsCard.cost = 1000
for _, elite in ipairs(EliteType.findAll("vanilla")) do
    monsCard.eliteTypes:add(elite)
end
for _, elite in ipairs(EliteType.findAll("RoR2Demake")) do
    monsCard.eliteTypes:add(elite)
end

callback.register("onStageEntry", function()
    local dir = misc.director
    if dir:get("stages_passed") >= 5 then
        local stage = Stage.getCurrentStage()
        if not stage.enemies:contains(monsCard) then
            stage.enemies:add(monsCard)
        end
    end
end)
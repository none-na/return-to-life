--Beetle.lua

local sprites = {
    idle = Sprite.load("BeetleIdle", "Actors/beetle/idle", 1, 6,11),
    walk = Sprite.load("BeetleWalk", "Actors/beetle/walk", 7, 7,12),
    jump = Sprite.load("BeetleJump", "Actors/beetle/jump", 1, 6,12),
    shoot1 = Sprite.load("BeetleShoot1", "Actors/beetle/shoot1", 10, 6, 14),
    spawn = Sprite.load("BeetleSpawn", "Actors/beetle/spawn", 13,8,12),
    death = Sprite.load("BeetleDeath", "Actors/beetle/death", 6, 19,15),
    mask = Sprite.load("BeetleMask", "Actors/beetle/idle", 1, 6,11),
    palette = Sprite.load("BeetlePal", "Actors/beetle/palette", 1, 0,0),
    hit = Sprite.find("Bite1", "vanilla")
}

local sounds = {
    attack = Sound.load("BeetleShoot1", "Sounds/SFX/beetle/attack.ogg"),
    spawn = Sound.load("BeetleSpawn", "Sounds/SFX/beetle/spawn.ogg"),
    death = Sound.load("BeetleDeath", "Sounds/SFX/beetle/beetleDeath.ogg"),
}

local beetle = Object.base("EnemyClassic", "Beetle")
beetle.sprite = sprites.idle

beetle:addCallback("create", function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    self.name = "Beetle"
    self.maxhp = 80 * Difficulty.getScaling("hp")
    self.hp = self.maxhp
    self.damage = 12 * Difficulty.getScaling("damage")
    self.pHmax = 1
    actor:setAnimations{
        idle = sprites.idle,
        walk = sprites.walk,
        jump = sprites.idle,
        shoot1 = sprites.shoot1,
        death = sprites.death
    }
    self.sound_hit = Sound.find("MushHit","vanilla").id
    self.sound_death = sounds.death.id
    actor.mask = sprites.mask
    self.health_tier_threshold = 3
    self.knockback_cap = 5
    self.exp_worth = 3
    actor:set("sprite_palette", sprites.palette.id)
    self.z_range = 10
    self.can_drop = 1
    self.can_jump = 1
end)

beetle:addCallback("step", function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    if self.state == "attack1" then --nibble
        if actor:getAlarm(2) <= -1 then
            if self.free ~= 1 then
                self.pHspeed = 0
            end
            if actor.sprite == sprites.shoot1 then
                local frame = math.floor(actor.subimage)
                if frame >= sprites.shoot1.frames or self.state == "feared" or self.state ~= "attack1" or self.stunned > 0 then
                    self.activity = 0
                    self.activity_type = 0
                    actor.spriteSpeed = 0.25
                    self.state = "chase"
                    actor:setAlarm(2, (2*60))
                    self.activity_var1 = 0
                    self.activity_var2 = 0
                    return
                end
                if frame == 1 then
                    if self.activity_var1 == 0 then
                        sounds.attack:play(self.attack_speed + math.random() * 0.05)
                        self.activity_var1 = 1
                    end
                elseif frame == 8 then
                    if self.activity_var2 == 0 then
                        actor:fireExplosion(actor.x + (5 * actor.xscale), actor.y, 1, 1, 2, nil, sprites.hit, nil)
                        self.activity_var2 = 1
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
        end
    end
end)

--------------------------------------

local card = MonsterCard.new("Beetle", beetle)
card.sprite = sprites.spawn
card.sound = sounds.spawn
card.canBlight = true
card.type = "classic"
card.cost = 8
for _, elite in ipairs(EliteType.findAll("vanilla")) do
    card.eliteTypes:add(elite)
end

local stages = {
    Stage.find("Desolate Forest", "vanilla"),
    Stage.find("Dried Lake", "vanilla"),
    Stage.find("Boar Beach", "vanilla"),
    Stage.find("Sky Meadow", "vanilla"),
    Stage.find("Temple of the Elders", "vanilla"),
}

for _, stage in ipairs(stages) do
    print("Adding Beetle card to "..stage:getName())
    stage.enemies:add(card)
end

local monsLog = MonsterLog.new("Beetle")
MonsterLog.map[beetle] = monsLog

monsLog.displayName = "Beetle"
monsLog.story = "Day 4. I encountered several insect-like lifeforms. They emerged from the ground, pushing up from the dirt. They were roughly each the size of a small cow, and were covered in several chitin plates. Initially, all they did was glower at me until they built up enough courage and numbers to attack.\n\nNow and then I catch glimpses of them from afar. They have a bizarre social hierarchy that I can't discern. I spotted a lone Beetle minding its own business, and several more Beetles approached and mercilessly attacked the creature, leaving it bloodied and bruised. I almost felt pity for the Beetle, but I knew that it too would attack me with the same ferocity as its brethren.\n\nOccasionally, I've seen them hop around repeatedly in place. Is this some kind of dance?"
monsLog.statHP = 80
monsLog.statDamage = 12
monsLog.statSpeed = 1
monsLog.sprite = sprites.walk
monsLog.portrait = sprites.idle
monsLog.portraitSubimage = 1

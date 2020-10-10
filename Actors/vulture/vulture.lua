
local sprites = {
    idle = Sprite.load("VultureIdle", "Actors/vulture/idle", 1, 34, 21),
    walk = Sprite.load("VultureWalk", "Actors/vulture/walk", 6, 34, 22),
    mask1 = Sprite.load("VultureMask1", "Actors/vulture/mask1", 1, 34, 21),
    flying = Sprite.load("VultureFlightIdle", "Actors/vulture/fly", 10, 40, 20),
    land = Sprite.load("VultureLand", "Actors/vulture/land", 4, 52, 45),
    takeOff = Sprite.load("VultureTakeOff", "Actors/vulture/takeOff", 4, 52, 45),
    palette = Sprite.load("VulturePal", "Actors/vulture/palette", 1, 0, 0),
}

local vulture = Object.base("EnemyClassic", "Vulture")
vulture.sprite = sprites.idle

EliteType.registerPalette(sprites.palette, vulture)

local InitVulture = function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    self.name = "Alloy Vulture"
    actor.mask = sprites.mask1
    self.maxhp = 200 * Difficulty.getScaling("hp")
    self.hp = self.maxhp
    self.damage = 15 * Difficulty.getScaling("damage")
    self.armor = 10
    self.pHmax = 0.5
    actor:setAnimations{
        idle = sprites.idle,
        walk = sprites.walk,
        jump = sprites.flying,
        death = sprites.idle,
    }
    --self.sound_hit = sounds.hurt.id
    --self.sound_death = sounds.death.id
    actor.mask = sprites.mask
    data.flying = false
    data.gravity = 0.25
    self.health_tier_threshold = 3
    actor:set("sprite_palette", sprites.palette.id)
    self.can_drop = 1
    self.can_jump = 1
    --self.z_range = 500
    data.burstRadius = 50
end

local StepVulture = function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    if data.flying then
        self.pGravity1 = 0

    else
        self.pGravity1 = data.gravity
    end

end

vulture:addCallback("create", function(actor)
    InitVulture(actor)
end)
vulture:addCallback("step", function(actor)
    StepVulture(actor)
end)
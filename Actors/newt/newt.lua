local sprites = {
    idle = Sprite.load("NewtIdle", "Actors/newt/newt", 4, 22,35),
    spawn = Sprite.load("NewtSpawn", "Actors/newt/spawn", 9,28,63),
}

local sounds = {
    [1] = Sound.load("Sounds/SFX/newt/0285.ogg"),
    [2] = Sound.load("Sounds/SFX/newt/0388.ogg"),
    [3] = Sound.load("Sounds/SFX/newt/0440.ogg"),
    [4] = Sound.load("Sounds/SFX/newt/0585.ogg"),
}

local lizard = Object.find("Lizard","vanilla")
local player = Object.find("P", "vanilla")
local enemy = ParentObject.find("enemies", "vanilla")
local enemySearchRange = 150
local shouldBeWithinXOfParent = 30
local tpToParentRange = 150

local newt = Object.base("EnemyClassic", "Newt")
newt.sprite = sprites.idle

newt:addCallback("create", function(actor)
    actor:set("name", "Newt")
    actor:set("maxhp", 500000000000000000)
    actor:set("hp", actor:get("maxhp"))
    actor:set("damage", 12)
    actor:set("pHmax", 0)
    actor:set("team", "newtral")
    actor:set("knockback_cap", 9999999999999999)
    actor:set("stun_immune", 1)
    actor:set("can_jump", 0)
    actor:set("can_drop", 0)
    actor:set("exp_worth", 0)
    actor:set("point_value", 0)
    actor:setAnimations{
        idle = sprites.idle,
        death = sprites.idle
    }
    actor.y = FindGround(actor.x, actor.y)
    actor.subimage = 0
end)

newt:addCallback("step", function(actor)
    actor:set("move_left", 0)
    actor:set("move_right", 0)
    if actor:getAlarm(2) == -1 then
        sounds[math.random(1, #sounds)]:play(0.9 + math.random() * 0.2)
        actor:setAlarm(2, 10*60)
        return
    end
end)
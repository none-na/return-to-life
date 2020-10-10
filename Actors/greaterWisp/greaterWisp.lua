
local sprites = {
    idle = Sprite.load("WispGIdle", "Actors/greaterWisp/idle", 4, 9, 11),
    idleWFire = Sprite.load("WispGIdle2", "Actors/greaterWisp/idleBook", 4, 16, 28),
    fire = Sprite.load("WispGFire", "Actors/greaterWisp/fireBall", 4, 16, 28),
    spawn = Sprite.load("WispGSpawn","Actors/greaterWisp/spawn", 4, 8, 13),
    shoot1 = Sprite.load("WispGShoot1","Actors/greaterWisp/shoot1", 9, 10, 13),
    death = Sprite.load("WispGDeath","Actors/greaterWisp/death", 12, 26, 21),
    palette = Sprite.load("WispGPal", "Actors/greaterWisp/palette", 1, 0, 0)
}

local sounds = {
    hit = Sound.find("WispHit", "vanilla"),
    death = Sound.find("WispGDeath", "vanilla"),
    spawn = Sound.find("WispSpawn", "vanilla"),
    shoot1 = Sound.find("WispGShoot1", "vanilla"),
}

local greaterWisp = Object.base("EnemyClassic", "GreaterWisp")
greaterWisp.sprite = sprites.idleWFire
EliteType.registerPalette(sprites.palette, greaterWisp)
local defaultColor = Color.fromRGB(151, 210, 106)
local tilt = 20

local actors = ParentObject.find("actors")

local DrawFire = function(handler)
    local d = handler:getData()
    local this = d.parent
    local data = this:getData()
    local color = defaultColor
    if not this:isValid() then
        handler:destroy()
        return
    end
    if this:getElite() then
        local prefix = this:getElite()
        if prefix.color then
            color = prefix.color
        end
    end
    graphics.setBlendMode("additive")
    graphics.drawImage{
        image = data.fireSprite,
        x = this.x,
        y = this.y,
        subimage = data.fireFrame,
        color = color,
        alpha = this.alpha,
        xscale = this.xscale,
        yscale = this.yscale
    }
    graphics.drawImage{
        image = data.fireSprite,
        x = this.x,
        y = this.y,
        subimage = data.fireFrame,
        color = color,
        xscale = this.xscale,
        yscale = this.yscale,
        width = data.fireSprite.width * 0.75,
        height = data.fireSprite.height * 0.75,
    }
    graphics.setBlendMode("normal")
    
end

local InitGWisp = function(this)
    local self = this:getAccessor()
    local data = this:getData()
    data.fireFrame = 1
    data.drawFire = true
    data.fireSprite = sprites.fire
    self.name = "Greater Wisp"
    self.maxhp = 750 * Difficulty.getScaling("hp")
    self.hp = self.maxhp
    self.damage = 15 * Difficulty.getScaling("damage")
    self.pHmax = 0.65
    this:setAnimations{
        idle = sprites.idle,
        walk = sprites.idle,
        jump = sprites.idle,
        death = sprites.death,
        shoot1 = sprites.shoot1,
    }
    self.sound_hit = sounds.hit.id
    self.sound_death = sounds.death.id
    local fire = graphics.bindDepth(this.depth + 1, DrawFire)
    fire:getData().parent = this
    self.flying = 1
end

local StepGWisp = function(this)
    local self = this:getAccessor()
    local data = this:getData()
    -------------------------------------------------------------
    if not data.flightManager then
        data.flightManager = GetManager(this)
        data.flightManager:getData().ax = 0.002
        data.flightManager:getData().ay = 0.002
        data.flightManager:getData().mVx = 0.65
        data.flightManager:getData().mVy = 0.65
        data.flightManager:getData().easingRange = 10
        data.flightManager:getData().noGroundRange = 5
    else
        data.flightManager:getData().mVx = self.pHmax
        data.flightManager:getData().mVy = self.pHmax
    end
    -------------------------------------------------------------
    if misc.getTimeStop() == 0 then
        data.fireFrame = data.fireFrame + (self.attack_speed * 0.2)
        local target = Object.findInstance(self.target)
        if target and target:isValid() then
            
        end
    end
end

local DrawGWisp = function(this)

end

greaterWisp:addCallback("create", function(this)
    InitGWisp(this)
end)
greaterWisp:addCallback("step", function(this)
    StepGWisp(this)
end)

greaterWisp:addCallback("draw", function(this)
    DrawGWisp(this)
end)

--[[local WispG = Object.find("WispG", "vanilla")

local oldSprites = {
    "WispGIdle",
    "WispGSpawn",
    "WispGShoot1",
    "WispGDeath",
    "WispGPalette",
}

local newSprites = {
    idle = Sprite.load("WispGNewIdle","Actors/greaterWisp/idle", 4, 8, 13),
    spawn = Sprite.load("WispGNewSpawn","Actors/greaterWisp/spawn", 4, 8, 13),
    shoot1 = Sprite.load("WispGNewShoot1","Actors/greaterWisp/shoot1", 9, 10, 13),
    death = Sprite.load("WispGNewDeath","Actors/greaterWisp/death", 12, 26, 21),
    palette = Sprite.load("WispGNewPalette","Actors/greaterWisp/palette", 1, 0, 0)
}

local wispGFlame = ParticleType.new("Green Fire")
wispGFlame:shape("Disc")
wispGFlame:color(Color.fromRGB(255, 255, 255))
wispGFlame:alpha(1, 0)
if not modloader.checkFlag("ror2_disable_wisp_glow") then
    wispGFlame:additive(true)
end
wispGFlame:size(0.1, 0.1, -0.005, 0.0001)
wispGFlame:angle(0, 360, 0.1, 0, true)
wispGFlame:speed(0.1, 1, 0.01, 0)
wispGFlame:direction(88, 92, 0, 0)
wispGFlame:life(15, 60)



for _, sprite in ipairs(oldSprites) do
    local spriteToReplace = Sprite.find(sprite, "vanilla")
    if spriteToReplace ~= nil then
        if sprite == "WispGIdle" then
            spriteToReplace:replace(newSprites.idle)
        elseif sprite == "WispGSpawn" then
            spriteToReplace:replace(newSprites.spawn)
        elseif sprite == "WispGShoot1" then
            spriteToReplace:replace(newSprites.shoot1)
        elseif sprite == "WispGDeath" then
            spriteToReplace:replace(newSprites.death)
        elseif sprite == "WispGPalette" then
            spriteToReplace:replace(newSprites.palette)
        end
    end
end

registercallback("onStep", function()
    for _, wispG in ipairs(WispG:findAll()) do
        if wispG:get("ghost") == 1 then
            wispGFlame:alpha(0.75, 0)
        end
        local color = Color.fromRGB(151, 210, 106)
        if wispG:get("elite") ~= 0 then
            if (wispG:get("elite_tier") == 0 or wispG:get("elite_tier") == 9) then --Blazing
                color = Color.fromRGB(186, 61, 29)
            elseif (wispG:get("elite_tier") == 1 or wispG:get("elite_tier") == 8) then --Frenzied
                color = Color.fromRGB(231, 241, 37)
            elseif (wispG:get("elite_tier") == 2 or wispG:get("elite_tier") == 7) then --Leeching
                color =  Color.fromRGB(70, 209, 35)
            elseif (wispG:get("elite_tier") == 3 or wispG:get("elite_tier") == 6) then --Overloading
                color = Color.fromRGB(119, 255, 238)
            elseif (wispG:get("elite_tier") == 4 or wispG:get("elite_tier") == 5) then --Volatile
                color = Color.fromRGB(255, 249, 170)
            end
        end
        local i = math.random(1, 3)
        for x = 0, i do 
            wispGFlame:burst("middle", wispG.x + (math.random(-8, 7) + (-3 * wispG.xscale)), wispG.y - math.random(-1, 15), 1, color)
        end
    end
end)
]]
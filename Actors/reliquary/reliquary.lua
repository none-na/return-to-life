-- artifact reliquary

local key = Item("Artifact Key")
key.pickupText = "A stone shard with immense power."

key.sprite = Sprite.load("Items/artifactKey.png", 1, 16, 16)

local sprites = {
    mask = Sprite.load("ReliquaryMask", "Actors/reliquary/mask", 1, 24, 24),
    bulletMask = Sprite.load("ReliquaryBulletMask", "Actors/reliquary/bulletMask", 1, 2.5, 2.5),
    sparks2 = Sprite.find("Sparks2", "vanilla")
}

local color = Color.fromRGB(150, 30, 100)
local player = Object.find("P", "vanilla")
local poi = Object.find("POI", "vanilla")
local sparks = Object.find("EfSparks", "vanilla")
local circle = Object.find("EfCircle", "vanilla")
local flash = Object.find("WhiteFlash", "vanilla")

local bulletFX = ParticleType.new("ReliquaryBullet")
bulletFX:shape("Square")
bulletFX:color(Color.ROR_BLUE)
bulletFX:alpha(1, 0.5, 0)
bulletFX:additive(true)
bulletFX:size(0.06, 0.06, -0.0025, 0)
bulletFX:angle(0, 360, 1, 0, true)
bulletFX:life(30, 30)

local relicMissile = Object.new("ReliquaryMissile")
relicMissile:addCallback("create", function(self)
    local data = self:getData()
    self.mask = sprites.bulletMask
    data.damage = 16
    data.life = 120
    data.alarm1 = 30
    data.alarm2 = 40
    data.aim = 1
    data.team = "enemy"
    data.target = nil
    self:set("direction", math.random(0, 360))
    self:set("speed", 3)

end)
relicMissile:addCallback("step", function(self)
    local data = self:getData()
    if data.life > -1 then
        bulletFX:burst("middle", self.x, self.y, 1)
        data.life = data.life - 1
        if data.alarm2 > -1 then
            data.alarm2 = data.alarm2 - 1
        else
            if data.alarm1 > -1 then
                data.alarm1 = data.alarm1 - 1
                data.target = poi:findNearest(self.x, self.y)
                if data.target and data.target:isValid() then
                    local targetAngle = GetAngleTowards(self.x, self.y, data.target.x, data.target.y)
                    self:set("direction", math.approach(self:get("direction"), data.aim, math.rad(targetAngle)))
                end
            end
            if data.target and data.target:isValid() then
                if self:collidesWith(data.target, self.x, self.y) then
                    data.life = -1
                end
            end

        end
    else
        local spark = sparks:create(self.x, self.y)
        misc.shakeScreen(3)
        spark.sprite = sprites.sparks2
        spark.spriteSpeed = 0.2
        misc.fireExplosion(self.x, self.y, 0.25, 0.25, data.damage * 2, data.team, nil, nil)
        self:destroy()
    end
end)


local ReliquaryBurst = function(reliquary)
    local data = reliquary:getData()
    for _, p in ipairs(player:findAll()) do
        p:removeItem(key, p:countItem(key))
    end
    for _, k in ipairs(key:getObject():findAll()) do
        k:destroy()
    end
    local c = circle:create(reliquary.x, reliquary.y)
    c:set("radius", 40)
    c:set("rate", 0.1)
    local f = flash:create(reliquary.x, reliquary.y)
    reliquary:set("hp", reliquary:get("hp") - (reliquary:get("maxhp") / 4))
    data.phase = data.phase + 1
    misc.shakeScreen(10)
    local burst = reliquary:fireExplosion(reliquary.x, reliquary.y, 3, 10, 0.1, nil, nil)
    burst:set("knockback", 10)
    burst:set("knockup", 5)
end

local ReliquaryFire = function(reliquary, angle, aim, alarm1, alarm2)
    local data = reliquary:getData()
    local xx = reliquary.x + (sprites.mask.width * math.cos(math.rad(angle)))
    local yy = reliquary.y - (sprites.mask.height * math.sin(math.rad(angle)))
    local bullet = relicMissile:create(xx, yy)
    bullet:set("direction", angle)
    bullet:getData().aim = aim
    bullet:getData().alarm1 = alarm1
    bullet:getData().alarm2 = alarm2
    bullet:getData().damage = reliquary:get("damage")
end

local reliquary = Object.base("Boss", "Reliquary")
reliquary:addCallback("create", function(self)
    local data = self:getData()
    data.phase = 0
    data.f = 0
    self.alpha = 0
    data.showText = false
    data.text = "&w&Press &y&'"..input.getControlString("enter").."'&w& to use &y&Artifact Key&w&."
    local artifacts = {}
    for _, artifact in ipairs(Artifact.findAll("vanilla")) do
        if not artifact.disabled then
            artifacts[#artifacts+1] = artifact
        end
    end
    for _, namespace in ipairs(modloader.getMods()) do
        
        for _, artifact in ipairs(Artifact.findAll(namespace)) do
            if not artifact.disabled then
                artifacts[#artifacts+1] = artifact
            end
        end
    end
    data.artifact = table.irandom(artifacts)
    if data.artifact then
        print("Artifact Chosen: "..data.artifact:getName())
        data.artifact.active = true
    end
    self.mask = sprites.mask
    self:set("name", "Artifact Reliquary")
    self:set("name2", "Stabilized")
    self:set("maxhp", 100000 * Difficulty.getScaling("hp"))
    self:set("hp", self:get("maxhp"))
    self:set("damage", 16 * Difficulty.getScaling("damage"))
    self:set("exp_worth", 0)
end)


reliquary:addCallback("step", function(self)
    local data = self:getData()
    data.f = (data.f + 1) % 360
    self:set("invincible", 9999)
    local nearest = player:findNearest(self.x, self.y)
    if nearest and nearest:isValid() then
        if self:collidesWith(nearest, self.x, self.y) then
            if nearest:countItem(key) > 0 then
                data.showText = true
                if input.checkControl("enter", nearest) == input.PRESSED then
                    ReliquaryBurst(self)
                end
            end
        else
            data.showText = false
        end
    end
    if data.phase <= 0 then
        local director = misc.director
        director:set("points", 0)
    end
    if data.phase > 0 then
        if data.phase == 1 then
            if data.f % 60 == 0 then
                ReliquaryFire(self, math.random(0, 360), 0.1, 0, 120)
            end
        elseif data.phase == 2 then
            if data.f % 30 == 0 then
                ReliquaryFire(self, math.random(0, 360), 0.2, 40, 40)
            end

        elseif data.phase == 3 then
            if data.f % 10 == 0 then
                ReliquaryFire(self, data.f, 0.5, 60, 60)
                ReliquaryFire(self, data.f+180, 0.5, 60, 60)
            end
        end
    end
end)
reliquary:addCallback("draw", function(self)
    local data = self:getData()
    graphics.color(color)
    graphics.alpha(0.3)
    graphics.circle(self.x, self.y, 40 + math.random(-4, 4), false)
    graphics.circle(self.x, self.y, 24 + math.random(-2, 2), false)
    graphics.color(Color.WHITE)
    graphics.circle(self.x, self.y, 10 + math.random(-1, 1), false)
    graphics.alpha(1)
    if data.artifact then
        graphics.drawImage{
            image = data.artifact.pickupSprite,
            x = self.x,
            y = self.y,
            alpha = 1
        }
    end
    graphics.color(color)
    graphics.circle(self.x, self.y, 44, true)
    ------------------------------------------
    if data.showText then
        graphics.color(Color.WHITE)
        graphics.alpha(1)
        graphics.printColor(data.text, self.x - (graphics.textWidth(data.text, graphics.FONT_DEFAULT)/2), self.y - 64, graphics.FONT_DEFAULT)
    end

end)
reliquary:addCallback("destroy", function(self)
    local data = self:getData()
    if data.artifact then
        data.artifact.active = false
        data.artifact:getObject():create(self.x, self.y)
    end
end)

callback.register("onGameEnd", function()
    for _, re in ipairs(reliquary:findAll()) do
        if re and re:isValid() then
            local data = re:getData()
            data.artifact.active = false
        end
    end
end)
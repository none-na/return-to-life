--tc280.lua

local sprites = {
    idle = Sprite.load("MegadroneIdle", "Actors/tc280/idle", 4, 32, 20),
    shoot1 = Sprite.load("MegadroneShoot1", "Actors/tc280/shoot1", 6, 32, 18),
    sparks1 = Sprite.find("Sparks4", "vanilla")
}

local megadrone = Object.base("drone", "Megadrone")
megadrone.sprite = sprites.idle

local light = ParticleType.new("MegadroneLight")
light:sprite(Sprite.find("Sparks2","vanilla"), true, true, false)
light:additive(true)
light:life(30, 30)

megadrone:addCallback("create", function(self)
    self:set("name", "TC-280 Prototype")
    self:set("sprite_idle", sprites.idle.id)
    self:set("sprite_idle_broken", sprites.idle.id)
    self:set("x_range", 300)
    self:set("y_range", 15)
    self:set("maxhp", 900 * Difficulty.getScaling("hp"))
    self:set("hp", self:get("maxhp"))
    self:set("damage", 14 * Difficulty.getScaling("damage"))
    local data = self:getData()
    data.x = self.x + (self.sprite.width/2)
    if Object.find("B", "vanilla"):findLine(self.x, self.y, self.x, self.y + 100) then
        data.y = Object.find("B", "vanilla"):findLine(self.x, self.y, self.x, self.y + 100).y
    else
        data.y = self.y + 10
    end
    self:set("f", 0)
end)

megadrone:addCallback("step", function(self)
    local drone = self:getAccessor()
    local target = Object.findInstance(self:get("target"))
    self:set("f", ((self:get("f") + 1) % 100))
    local data = self:getData()
    local master = Object.findInstance(drone.master)
    local target = Object.findInstance(drone.target)
    if drone.state == "chase" then
        if target and master then
            self.x = (master.x + drone.xx + self.x) / 2
            self.y = target.y
        end
    end
end)

megadrone:addCallback("draw", function(self)
    local data = self:getData()
    graphics.alpha(0.5)
    graphics.setBlendMode("additive")
    graphics.color(Color.ROR_YELLOW)
    graphics.triangle(self.x, self.y, data.x + (5 + (math.sin(self:get("f"))/2)), data.y, data.x - (5 + (math.sin(self:get("f"))/2)), data.y)
    graphics.triangle(self.x, self.y, data.x + (3 + (math.cos(self:get("f"))/2)), data.y, data.x - (3 + (math.cos(self:get("f"))/2)), data.y)
end)
--RoR2 Demake Project
--Made by Sivelos
--cube.lua
--File created 2019/04/09

local cube = Item("Primordial Cube")
cube.pickupText = "Fire a black hole that draws enemies in."

cube.sprite = Sprite.load("Items/cube.png", 2, 12, 13)

cube.isUseItem = true
cube.useCooldown = 60

local blackHoleSpr = Sprite.load("Graphics/blackHole", 1, 5, 5)
local blackHoleMask = Sprite.load("Graphics/blackHoleMask", 1, 5, 5)
local succFX = Sprite.load("succ", "Graphics/suckLine", 7, 5, 16)
local holeAura = Sprite.load("glow", "Graphics/blackAura", 1, 10, 10)

cube:setTier("use")
cube:setLog{
    group = "use",
    description = "Fire a black hole that draws nearby enemies in.",
    story = "I'm still shaking with excitement as I write this. The Solar System's first ever containment device for a black hole... It's small, yeah, but it's just a proof of concept. Could you imagine if we get the green light for more serious testing? Do you reckon we could ever encapsulate Sagittarius A*? It may be a pipe dream, but this baby shows that it may not be too farfetched.\n\nOh yeah, uh, this goes with out saying but make sure not to drop it. There is, after all, a LITERAL black hole in that thing. Only open it in secure environments or to show off to your coworkers.",
    destination = "LIGO Gravitational Testing Facility,\nNevada,\nEarth",
    date = "11/4/2056"
}

local enemies = ParentObject.find("enemies", "vanilla")

local Projectile = require("Libraries.Projectile")

local succThreshold = 10

local blackHole = Projectile.new({
    name = "Black Hole",
    mask = blackHoleMask,
    vx = 0.5,
    vy = 0,
    ax = 0,
    ay = 0,
    sprite = blackHoleSpr,
    damage = 0,
    pierce = true,
    ghost = false,
    life = 600,
    multihit = true,
    })

local suckLine = ParticleType.new("Here comes the succ")
suckLine:sprite(succFX, true, true, false)
suckLine:angle(0, 360, 0, 0, false)
suckLine:life(35, 35)

local acretionDisc = ParticleType.new("acretionDisc")
acretionDisc:sprite(holeAura, true, true, false)
acretionDisc:angle(0, 360, 5, 0, false)
acretionDisc:additive(true)
acretionDisc:alpha(0, 1, 0)
acretionDisc:size(1, 1, -0.001, 0)
acretionDisc:life(60, 60)

local enemies = ParentObject.find("enemies", "vanilla")

blackHole:addCallback("step", function(self)
    if self:isValid() then
        local dir = 0
        if self.xscale < 1 then
            dir = 180
        end
        suckLine:direction(dir, dir, 0, 0)
        suckLine:speed(self:get("Projectile_vx") * self.xscale, self:get("Projectile_vx") * self.xscale, 0, 0)
        acretionDisc:direction(dir, dir, 0, 0)
        acretionDisc:speed(self:get("Projectile_vx") * self.xscale, self:get("Projectile_vx") * self.xscale, 0, 0)
        if self:get("Projectile_life") % 60 == 0 then
            acretionDisc:burst("middle", self.x, self.y, 1)
        end
        if self:get("Projectile_life") % 10 == 0 then
            suckLine:burst("middle", self.x, self.y, 1)
        end
        -----------------------------------------------
        for _, enemyInst in ipairs(enemies:findAllEllipse(self.x - self:get("range"), self.y - self:get("range"), self.x + self:get("range"), self.y + self:get("range"))) do
            if enemyInst:getObject() ~= Object.find("WormBody", "vanilla") or enemyInst:getObject() ~= Object.find("WurmBody", "vanilla") then
                local xx = enemyInst.x-self.x
                local yy = enemyInst.y-self.y
                local zz = math.sqrt(math.pow(xx, 2) + math.pow(yy, 2))
                if math.abs(zz) > succThreshold then
                    local moveDistance = zz / 15
                    for i = 0, moveDistance do
                        if enemyInst:collidesMap(enemyInst.x + (xx * (i/zz)),enemyInst.y + (yy * (i/zz)))then
                            moveDistance = i
                            return
                        end
                    end
                    if xx < 0 then
                        enemyInst.x = enemyInst.x + moveDistance
                    else
                        enemyInst.x = enemyInst.x - moveDistance
                    end
                end
            end
        end
    end
end)

blackHole:addCallback("draw", function(self)
    if self:isValid() then
        for _, enemyInst in ipairs(enemies:findAllEllipse(self.x - self:get("range"), self.y - self:get("range"), self.x + self:get("range"), self.y + self:get("range"))) do
            graphics.alpha(0.3)
            graphics.color(Color.fromRGB(177, 90, 213))
            graphics.line(self.x, self.y, enemyInst.x, enemyInst.y, 3)
        end
    end
end)

cube:addCallback("use", function(player, embryo)
    local playerA = player:getAccessor()
    local count = 1
    -- Increase spawn count if embryo is procced
    if embryo then
        count = 2
    end
    for i = 1, count do
        local blackInst = Projectile.fire(blackHole, player.x, player.y, player)
        blackInst:set("range", 50 * count)
    end
end)
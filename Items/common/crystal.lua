--RoR2 Demake Project
--Made by Sivelos
--crystal.lua
--File created 2019/09/25

local crystal = Item("Focus Crystal")
crystal.pickupText = "Deal extra damage to nearby enemies."

crystal.sprite = restre.spriteLoad("Graphics/crystal.png", 1, 16, 16)
crystal:setTier("common")

crystal:setLog{
    group = "common",
    description = "Increase damage dealt to nearby enemies by +15%.",
    story = "---",
    destination = "---,\n---,\n---",
    date = "--/--/2056"
}

local effectRange = 30
local proc = Sprite.load("Graphics/crystalBonus", 5, 5.5, 5.5)
local procSound = Sound.load("Sounds/SFX/crystal.ogg")
local sparks = Object.find("EfSparks", "vanilla")

callback.register("onHit", function(damager, hit, x, y)
    local parent = damager:getParent()
    if parent and isa(parent, "PlayerInstance") and parent:countItem(crystal) > 0 then
        local xx = parent.x - hit.x
        local yy = parent.y - hit.y
        local zz = math.sqrt(math.pow(xx, 2) + math.pow(yy, 2))
        if zz <= effectRange then
            local effect = sparks:create(x, y)
            effect.sprite = proc
            if IsOnScreen(parent, hit) then
                procSound:play(0.95 + math.random() * 0.1)
            end
            effect.xscale = parent.xscale
            local dmgr = damager:getAccessor()
            local damage = dmgr.damage
            dmgr.damage = dmgr.damage + ((damage * 0.15) * parent:countItem(crystal))
            dmgr.damage_fake = dmgr.damage_fake + ((damage * 0.15) * parent:countItem(crystal))
        end
    end
end)

callback.register("onPlayerDraw", function(player)
    if player:countItem(crystal) > 0 then
        graphics.color(Color.fromRGB(231,84,58))
        graphics.alpha(0.5)
        graphics.circle(player.x, player.y, effectRange, true)
    end
end)

GlobalItem.items[crystal] = {
    hit = function(inst, count, damager, hit, x, y)
        if Distance(inst.x, inst.y, hit.x, hit.y) <= effectRange then
            local effect = sparks:create(x, y)
            effect.sprite = proc
            if IsOnScreen(inst, hit) then
                procSound:play(0.95 + math.random() * 0.1)
            end
            effect.xscale = inst.xscale
            local dmgr = damager:getAccessor()
            local damage = dmgr.damage
            dmgr.damage = dmgr.damage + ((damage * 0.15) * count)
            dmgr.damage_fake = dmgr.damage_fake + ((damage * 0.15) * count)
        end
    end,
    draw = function(inst, count) 
        graphics.color(Color.fromRGB(231,84,58))
        graphics.alpha(0.5)
        graphics.circle(inst.x, inst.y, effectRange, true)
    end,
}
--RoR2 Demake Project
--Made by Sivelos
--fireRing.lua
--File created 2019/05/13

local iceRing = Item("Runald's Band")
iceRing.pickupText = "Chance on hit to cast a slowing runic ice blast."

iceRing.sprite = Sprite.load("Items/iceRing.png", 1, 16, 16)
iceRing:setTier("uncommon")

iceRing:setLog{
    group = "uncommon",
    description = "&b&8%&!& chance on hit to cast a &b&runic ice blast&!& for &y&250%&!& that &b&slows enemies&!&.",
    story = "To my dearest Kjaro... I cannot leave with you. The Bulwark has given us so much, and I could never advocate for turning my back on him. While we and a few others were unaffected by his dominion, that is no reason to betray him. The intruders... the demons who fell from the sky, you have seen what they've done to our people. To our children. To our brethren in the tunnels. Should you come back to reason... I await your safe return.",
    destination = "Lost Planet\nUnknown",
    date = "3/24/2056"
}

GlobalItem.items[iceRing] = {
    apply = function(inst, count)
        inst:set("iceRing", (inst:get("iceRing") or 0) + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("iceRing", inst:get("iceRing") - count)
    end
}

local Projectile = require("libraries.Projectile")
local iceFX = Sprite.load("Graphics/iceBlast", 4, 9, 11)
local iceSound = Sound.find("Frozen", "vanilla")
local iceParticle = ParticleType.find("Ice", "vanilla")
local actors = ParentObject.find("actors", "vanilla")
local spellBand = ParticleType.new("Ice Spell")
spellBand:sprite(Sprite.load("iceBand", "Graphics/spellBand", 8, 8, 8), true, true, true)
spellBand:color(Color.WHITE, Color.AQUA)
spellBand:alpha(1, 0)
spellBand:additive(true)
spellBand:size(0, 0, 0.025, 0)
spellBand:angle(0, 360, -1, 0, true)
spellBand:life(30, 120)

local iceBlast = Object.new("RunaldProc")
iceBlast.sprite = iceFX
iceBlast:addCallback("create", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    data.life = 100
    data.hit = {}
    data.damage = 12
    data.damageCoeff = 2.5
    data.team = "player"
    this.angle = math.random(0, 360)
    for i = 0, math.random(3, 10) do
        iceParticle:burst("middle", this.x, this.y, 1)
    end
end)

iceBlast:addCallback("step", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    data.life = data.life - 1
    local nearest = actors:findNearest(this.x, this.y)
    if this:collidesWith(nearest, this.x, this.y) and nearest:isValid() then
        if not data.hit[nearest] then
            local proc = misc.fireExplosion(this.x, this.y, 0.25, 1, data.damage * data.damageCoeff, data.team, nil, nil)
            proc:getAccessor().slow_on_hit = 5
            data.hit[nearest] = nearest
        end
    end
    if this.subimage >= iceFX.frames then
        this.spriteSpeed = 0
    end
    if data.life < 25 then
        this.alpha = data.life / 25
    end
    if data.life <= -1 then
        this:destroy()
        return
    end
end)

registercallback("onPlayerStep", function(player)
    player:set("iceRing", player:countItem(iceRing))
end)

IRL.setRemoval(iceRing, function(player)
    adjust(player, "iceRing", -1)
end)


registercallback("onFire", function(damager)
    --Initialize elementalRing variable
    damager:set("elementalRing", 0)
end)

local SyncRunaldVar = net.Packet.new("Sync Runald's Band Variables", function(player, id, var)
    local damager = Object.findInstance(id):getNetIdentity()
    if damager:resolve() then
        damager:set("elementalRing", var)
    end
end)

registercallback("preHit", function(damager)
    local parent = damager:getParent()
    if parent then
        if parent:isValid() then
            if parent:get("iceRing") then
                --Indicate that the parent has Runald's Band
                damager:set("iceRing", parent:get("iceRing") or 0)
                if net.host then
                    if math.random() <= 0.08 and parent:get("iceRing") > 0 then
                        --Proc Runald's Band
                        damager:set("elementalRing", parent:get("iceRing") or 0)
                        if net.online then
                            --SyncRunaldVar:sendAsHost(net.ALL, nil, damager.id, parent:get("iceRing") or 0)
                        end
                    end
                end
            end
        end
    end
end)

registercallback("onHit", function(damager, hit, x, y)
    local parent = damager:getParent()
    if parent then
        if damager:get("elementalRing") > 0 and (damager:get("iceRing") and damager:get("iceRing") > 0) then
            iceSound:play(0.8 + math.random() * 0.2)
            spellBand:burst("above", x, y, 1)
            local blast = iceBlast:create(x, y)
            blast:getData().damage = damager:get("damage")
            blast:getData().damageCoeff = 2.5 + (1.25 * (damager:get("elementalRing") - 1))
            blast:getData().team = parent:get("team")
        end
    end
end)
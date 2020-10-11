--RoR2 Demake Project
--Made by Sivelos
--fireRing.lua
--File created 2019/05/13

local fireRing = Item("Kjaro's Band")
fireRing.pickupText = "Chance on hit to cast a runic fire tornado."

fireRing.sprite = Sprite.load("Items/uncommon/GraphicsfireRing.png", 1, 16, 16)
fireRing:setTier("uncommon")

fireRing:setLog{
    group = "uncommon",
    description = "&b&8%&!& chance on hit to cast a &y&runic fire tornado&!& for &y&500%&!&.",
    story = "To my dearest Runald... I hope you understand why I must leave. I love the Bulwark with all my heart, but I cannot agree with his actions towards the ones who fell from the sky. If you ever change your mind... Should your heart's warmth blossom forth... You know where you will find me.",
    destination = "Lost Planet\nUnknown",
    date = "3/24/2056"
}

GlobalItem.items[fireRing] = {
    apply = function(inst, count)
        inst:set("fireRing", (inst:get("fireRing") or 0) + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("fireRing", inst:get("fireRing") - count)
    end
}

local fireFX = Sprite.load("Graphics/fireTornado", 4, 5, 15)
local fireImpact = Sprite.find("EfFirey", "vanilla")
local fireSound = Sound.find("WispBShoot1", "vanilla")
local fireParticle = ParticleType.find("Fire2", "vanilla")
local actors = ParentObject.find("actors", "vanilla")

local spellBand = ParticleType.new("Fire Spell")
spellBand:sprite(Sprite.load("fireBand", "Graphics/spellBand", 8, 8, 8), true, true, true)
spellBand:color(Color.WHITE, Color.ORANGE)
spellBand:alpha(1, 0)
spellBand:additive(true)
spellBand:size(0, 0, 0.025, 0)
spellBand:angle(0, 360, 1, 0, true)
spellBand:life(30, 120)

local fireTornado = Object.new("KjaroProc")
fireTornado.sprite = fireFX
fireTornado:addCallback("create", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    this.spriteSpeed = 0.25
    data.life = 100
    data.hit = {}
    data.vx = 0.5
    data.damage = 12
    data.damageCoeff = 5
    data.team = "player"
end)

fireTornado:addCallback("step", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    data.life = data.life - 1
    this.x = this.x + (data.vx * this.xscale)
    local nearest = actors:findNearest(this.x, this.y)
    if this:collidesWith(nearest, this.x, this.y) and nearest:isValid() then
        if not data.hit[nearest] then
            local proc = misc.fireExplosion(this.x, this.y, 0.25, 1, data.damage * data.damageCoeff, data.team, nil, fireImpact)
            data.hit[nearest] = nearest
        end
    end
    if data.life < 25 then
        this.alpha = data.life / 25
    end
    fireParticle:burst("middle", this.x, this.y + (this.sprite.height/2), 1)
    if data.life <= -1 then
        this:destroy()
        return
    end
end)

registercallback("onPlayerStep", function(player)
    player:set("fireRing", player:countItem(fireRing))
end)

IRL.setRemoval(fireRing, function(player)
    adjust(player, "fireRing", -1)
end)

local SyncKjaroVar = net.Packet.new("Sync Kjaro's Band Variables", function(player, id, var)
    local damager = Object.findInstance(id):getNetIdentity()
    if damager:resolve() then
        damager:set("elementalRing", var)
    end
end)

registercallback("preHit", function(damager)
    local parent = damager:getParent()
    if parent then
        if parent:isValid() then
            if parent:get("fireRing") then
                --Indicate that the parent has Kjaro's Band
                damager:set("fireRing", parent:get("fireRing") or 0)
                if net.host then
                    if math.random() <= 0.08 and parent:get("fireRing") > 0 then
                        --Proc Kjaro's Band
                        damager:set("elementalRing", parent:get("fireRing") or 0)
                        if net.online then --i took her to my penthouse and i synced it
                            --SyncKjaroVar:sendAsHost(net.ALL, nil, damager.id, parent:get("fireRing") or 0)
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
        if damager:get("elementalRing") > 0 and (damager:get("fireRing") and damager:get("fireRing") > 0) then
            fireSound:play(0.8 + math.random() * 0.2)
            spellBand:burst("above", x, y, 1)
            local tornado = fireTornado:create(x, y)
            tornado:getData().damage = damager:get("damage")
            tornado:getData().damageCoeff = 5 + (2.5 * (damager:get("elementalRing") - 1))
            tornado:getData().team = parent:get("team")
            tornado.xscale = parent.xscale
        end
    end
end)
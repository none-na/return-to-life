--RoR2 Demake Project
--Made by N4K0
--aprounds.lua
--File created 2019/04/09

local item = Item("Armor Piercing Rounds")
item.pickupText = "Increases damage against bosses."

item.sprite = Sprite.load("Items/common/Graphicsaprounds.png", 1, 16, 16)

item:setTier("common")
item:setLog{
    group = "common",
    description = "Increases damage against bosses by 20%.",
    story = "Alright, just to clarify, these ammo rounds aren't faulty. Hell, I'd say they're better than normal, but... that's just it. I don't know if it was a new shipment of materials, or a problem with the assembly line, but these rounds are supposed to pierce armor, not fly through not just the armor, but also five feet of concrete. These things are MUCH sharper than they should be. Could you guys look into this so we don't like, violate any Geneva conventions or anything?",
    destination = "PO Box 1023-A,\nFort Margaret,\nJonesworth System",
    date = "5/6/2056"
}

local apBuff = {}

local function reset()
    apBuff = {}
end

registercallback("onGameStart", reset)
registercallback("onGameEnd", reset)

registercallback("onPLayerInit",
function(player)
    apBuff[player] = false
end)

registercallback("onHit",
function(bullet, actor, hitx, hity)
    local parent = bullet:getParent()
    if type(parent) == "PlayerInstance" then
        local count = parent:countItem(item)
        if count > 0 and actor:isBoss() then
            bullet:set("damage", bullet:get("damage") * (1.1 + count / 10))
        end
    end
end)

GlobalItem.items[item] = {
    hit = function(inst, count, damager, hit, x, y)
        if hit:isBoss() then
            damager:set("damage", damager:get("damage") * (1.1 + count / 10))
        end
    end,
}
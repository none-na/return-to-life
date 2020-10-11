--RoR2 Demake Project
--Made by Sivelos
--chronobauble.lua
--File created 2019/06/12

local bauble = Item("Chronobauble")
bauble.pickupText = "Slow enemies on hit."

bauble.sprite = Sprite.load("Items/chronobauble.png", 1, 16, 16)

bauble:setTier("uncommon")
bauble:setLog{
    group = "uncommon",
    description = "Slow enemies for 2 seconds on hit.",
    story = "What a bizarre knicknack. It messes with the temporal energies of anything it touches, making them suuuuuperrrrr slowwwwwwwww...\n\nI hope it doesn't cause any problems with transit.",
    destination = "Felt Mansion,\nGreen Moon,\nSolar System",
    date = "12/31/9999"
}

local slowDebuff = Buff.find("slow", "vanilla")

registercallback("onPlayerStep", function(player)
    player:set("slowOnHit", player:countItem(bauble))
end)

registercallback("preHit", function(damager)
    local parent = damager:getParent()
    if parent ~= nil then
        if parent:get("slowOnHit") ~= nil then
            damager:set("slowOnHit", parent:get("slowOnHit") or 0)
        else
            damager:set("slowOnHit", 0)
        end
    end
end)

registercallback("onHit", function(damager, hit, x, y)
    local parent = damager:getParent()
    if parent ~= nil then
        if damager:get("slowOnHit") > 0 then
            hit:applyBuff(slowDebuff, 120*damager:get("slowOnHit"))
        end
    end
end)
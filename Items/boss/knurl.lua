--RoR2 Demake Project
--Made by Sivelos
--knurl.lua
--File created 2019/06/5

local knurl = Item("Colossal Snowball")
knurl.pickupText = "Increases damage and attack speed. Chance on hit to freeze enemies."

knurl.sprite = Sprite.load("Items/knurl.png", 1, 16, 16)
--knurl:setTier("rare")

knurl:setLog{
    group = "boss",
    description = "Increase damage by 5, Attack Speed by 5%, and chance to freeze enemies on hit by +5%.",
    story = "It seems earth and rock is not the only thing Golems can animate. While traversing a glacier, several \"Snow Golems\" appeared and attacked me. They had no discerning qualities from their rock brethren, apart from being comprised of snow and ice. I managed to nab a piece of one, and it's been attempting to reform itself since then.\n\nThe thing is surprisingly hard... I performed some carbon dating and found that the ice at its core dates back over 3000 years. Incredible! The ice must be harder than steel, if it's lasted this long. Thankfully I have a mean throwing arm...",
    destination = "7125,\nVast Glacier,\nUnknown",
    date = "12/22/2056"
}

knurl:addCallback("pickup", function(actor)
    actor:set("damage", actor:get("damage") + 5)
    actor:set("attack_speed", actor:get("attack_speed") + 0.05)
end)

callback.register("onFire", function(damager)
    local parent = damager:getParent()
    if parent and isa(parent, "PlayerInstance") then
        if parent:countItem(knurl) > 0 then
            if math.random() <= (0.05 + (0.025 * (parent:countItem(knurl) - 1))) then
                damager:set("freeze", damager:get("freeze") + 1)
            end
        end
    end
end)
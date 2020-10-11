--RoR2 Demake Project
--Made by Sivelos
--aegis.lua
--File created 2019/07/1

local aegis = Item("Aegis")
aegis.pickupText = "Healing past full grants you a temporary barrier."

--aegis.sprite = Sprite.load("Items/rare/Graphicsaegis.png", 1, 16, 16)
aegis.sprite = restre_spriteLoad("aegis", "rare/Graphics/aegis.png", 1, 16, 16)
aegis:setTier("rare")

aegis:setLog{
    group = "rare",
    description = "Healing past full grants you a &or&temporary barrier&!& for 50% HP restored.",
    story = "---",
    destination = "---,\n---,\n---",
    date = "---/---/2056"
}

registercallback("onPlayerStep", function(player)
    if player:countItem(aegis) > 0 then
        local lastHP = player:get("lastHp")
        local hp = player:get("hp")
        local hpDelta = hp - lastHP
        if lastHP ~= hp and hp >= player:get("maxhp") then
            if player:get("barrier") then
                local delta = player:get("maxhp") - hp
                player:set("barrier", player:get("barrier") + (hpDelta * (0.5 * player:countItem(aegis))))
            end
        end
    end
end)

GlobalItem.items[aegis] = {
    step = function(inst, count)
        local lastHP = inst:get("lastHp")
        local hp = inst:get("hp")
        local hpDelta = hp - lastHP
        if lastHP ~= hp and hp >= inst:get("maxhp") then
            if inst:get("barrier") then
                local delta = inst:get("maxhp") - hp
                inst:set("barrier", inst:get("barrier") + (hpDelta * (0.5 * count)))
            end
        end
    end,
}

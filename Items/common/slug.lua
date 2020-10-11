--RoR2 Demake Project
--Made by N4K0
--slug.lua
--File created 2019/04/07

local item = Item("Cautious Slug")
item.pickupText = "Increases health regeneration out of combat."

item.sprite = Sprite.load("Items/common/Graphics/slug.png", 1, 16, 16)

item:setTier("common")
item:setLog{
    group = "common",
    description = "After not being hit for 7 seconds, increase &g&health regen&!& by &g&2.4&!& per second",
    story = "It hatched.",
    destination = "Battle Creek\n49017 Mars",
    date = "12/18/2056"
}

local slugBuff = {}
local initialRegen
local regenDelta

local function reset()
    slugBuff = {}
end

registercallback("onGameStart", reset)
registercallback("onGameEnd", reset)

registercallback("onPlayerInit", function(player)
    slugBuff[player] = false
end)

registercallback("onPlayerStep", function(player)
    local count = player:countItem(item)
    if count > 0 then
        if player:get("combat_timer") == 0 and not slugBuff[player] then
            initialRegen = player:get("hp_regen")
            player:set("hp_regen", player:get("hp_regen") * (1 + 1.5 * count))
            regenDelta = player:get("hp_regen") - initialRegen
            slugBuff[player] = true
        elseif player:get("combat_timer") > 0 and slugBuff[player] then
            player:set("hp_regen", player:get("hp_regen") - regenDelta)
            slugBuff[player] = false
        end
    end
end)


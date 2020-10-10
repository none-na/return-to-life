--RoR2 Demake Project
--Made by Sivelos
--fuelCell.lua
--File created 2019/05/23

local cell = Item("Fuel Cell")
cell.pickupText = "Gain an additional charge to use items. Lowers use item cooldowns."

cell.sprite = Sprite.load("Items/fuelCell.png", 1, 16, 16)

cell:setTier("uncommon")
cell:setLog{
    group = "uncommon",
    description = "Gain an &g&additional charge&!& to use items. Lowers &b&use item&!& cooldowns by &y&15%&!&.",
    story = "FOR: FOREMAN ----- -. \nCC#: ---- ---- - ----\nACCT#: 125610\nFission Reactor Fuel Canister [125 mg]\nWARNING: exposure to volatile reactor environment may result in fuel meltdown, positive void coifficient, or power failures. Use with caution.",
    destination = "Reactor 12,\nRoute 10 Power Plant,\nEarth",
    date = "2/27/2056"
}

cell:addCallback("pickup", function(player)
    player:set("useUseCount", player:get("useUseCount") + 1)
    player:set("use_cooldown", math.clamp(player:get("use_cooldown") - ((player:get("use_cooldown") / 100) * 15), 0.5, player:get("use_cooldown")))
    Abilities.cooldownOverride(player, 5, player:get("use_cooldown") * 60)
end)

IRL.setRemoval(cell, function(player)
    adjust(player, "useUseCount", -1)
    player:set("use_cooldown", player:get("use_cooldown") + ((player:get("use_cooldown") / 100) * 15))
end)

local useDelay = 15

registercallback("onUseItemUse", function(player, item)
    if player:countItem(cell) > 0 then
        print(player:get("use_cooldown"))
        player:set("use_cooldown", math.clamp(item.useCooldown - (((item.useCooldown / 100) * 15) * player:countItem(cell)), 5, item.useCooldown))
        print(player:get("use_cooldown"))
        Abilities.cooldownOverride(player, 5, player:get("use_cooldown") * 60)
    end
end)

registercallback("onPlayerStep", function(player)
    local count = player:countItem(cell) + 1
    if count > 1 then
        --check if we have any uses left
        if player:get("useUseCount") > 1 then
            --check if the player is currently on ability cooldown
            if player:getAlarm(0) > -1 then
                --if they're on cooldown, reset the cooldown to 0 and start counting up internally
                player:set("useUseCount", player:get("useUseCount") - 1)
                player:setAlarm(0, useDelay)
                Abilities.useCurrent = math.round(Abilities.useCooldown)
            end
        end
        --decrement our internal timer, and see if it hits 0 so we can add to the ability uses
        if Abilities.useCurrent > -1 then
            Abilities.useCurrent = Abilities.useCurrent - 1
            if Abilities.useCurrent == -1 then
                player:set("useUseCount", player:get("useUseCount") + 1)
            end
        end

        --see if the internal countdown isn't already going, only for when player has more than 1 backup magazine
        if Abilities.useCurrent == -1 and player:get("useUseCount") < count then
            Abilities.useCurrent = Abilities.useCooldown
        end

        --finally, if both timers are on cooldown, set the vanilla timer to our internal timer
        if Abilities.useCurrent > -1 and player:getAlarm(0) > useDelay then
            player:setAlarm(0, Abilities.useCurrent)
        end
        --if vanilla timer is off cooldown, but useCount is less than it's supposed to be, start counting
        if Abilities.useCurrent == -1 and player:getAlarm(0) <= useDelay and player:get("useUseCount") < count then
            Abilities.useCurrent = Abilities.useCooldown
        end
    end
end)

registercallback("onPlayerHUDDraw", function(player, hudx, hudy)
    if player:countItem(cell) > 0 then
        --graphics.print(tostring(Abilities.useCurrent), hudx + 120, hudy - 14, graphics.FONT_DAMAGE, graphics.ALIGN_RIGHT, graphics.ALIGN_CENTER)
        if player:get("useUseCount") >= 0 then
            graphics.print(player:get("useUseCount"), hudx + 120, hudy + 14, graphics.FONT_DAMAGE, graphics.ALIGN_RIGHT, graphics.ALIGN_CENTER)
        end
    end
end)

--RoR2 Demake Project
--Made by Sivelos
--afterburner.lua
--File created 2019/04/07

require("Libraries.abilitylib")

local afterburner = Item("Hardlight Afterburner")
afterburner.pickupText = "Adds 2 extra uses to your third skill."

afterburner.sprite = Sprite.load("Items/afterburner.png", 1, 16, 16)

afterburner:setTier("rare")
afterburner:setLog{
    group = "rare",
    description = "Gain &y&2 extra uses&!& to your third skill.",
    story = "Here she is. The crown jewel of the Model #23 Raptor spacecraft, nicknamed the Hardlight for the astonishing speeds this thing put out. There's even a rumor that a Hardlight managed to fly from the Sun to the Outer Systems in under a day. A day! This thing better be the premier attraction, cause if it isn't, I don't know what is.",
    destination = "Wright Aeronautics Center,\nMount Enceladus,\nUranus",
    date = "12/31/2056"
}

afterburner:addCallback("pickup", function(player)
    Ability.AddCharge(player, "c", 2)
    Ability.setCooldownReduction(player, "c", Ability.getCooldownReduction(player, "c") / 3)
end)

IRL.setRemoval(afterburner, function(player)
    if Ability.getMaxCharge(player, "c") < 3 then
        Ability.Disable(player, "c")
        Ability.setCooldownReduction(player, "c", 0)
    else
        Ability.AddCharge(player, "c", -2)
        Ability.setCooldownReduction(player, "c", Ability.getCooldownReduction(player, "c") * 3)
    end
end)

GlobalItem.items[afterburner] = {
    apply = function(inst, count)

    end,
}
--RoR2 Demake Project
--Made by N4K0
--shieldgen.lua
--File created 2019/04/07

local shieldgen = Item("Personal Shield Generator")
shieldgen.pickupText = "Gain a small, regenerating shield."

shieldgen.sprite = Sprite.load("Items/shieldgen.png", 1, 16, 16)

shieldgen:setTier("common")
shieldgen:setLog{
    group = "common",
    description = "Gain &b&8% of your Max HP as shield&!&. Regenerates out of combat.",
    story = "HAS THIS EVER HAPPENED TO YOU?\n\n--[INSERT AUDIO TRANSCRIPT OF EMBARASSING EVENT]--\n\nWell, you could use the Personal Shield Generator! For all purpose safety, simply strap the device to the object you wish to protect. Activate the generator, and voila! Your precious object is now protected by a state-of-the-art dynamic force field.\n\nIf you'd like to opt out of our mailing list, reply \'STOP\' to this package.",
    destination = "9102,\nSaint's Boulevard,\nNeptune",
    date = "3/10/2056"
}

shieldgen:addCallback("pickup", function(player)
    player:set("maxshield", player:get("maxshield") + (player:get("maxhp") * 0.08))
end)

IRL.setRemoval(shieldgen, function(player)
    adjust(player, "maxshield", player:get("maxhp") * 0.08)
end)


GlobalItem.items[shieldgen] = {
    apply = function(inst, count)
        inst:set("maxshield", inst:get("maxshield") + (inst:get("maxhp") * (0.08 * count)))
    end
}
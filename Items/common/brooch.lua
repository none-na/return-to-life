--RoR2 Demake Project
--Made by Sivelos
--brooch.lua
--File created 2019/07/1

local brooch = Item("Topaz Brooch")
brooch.pickupText = "Gain a temporary barrier on kill."

brooch.sprite = Sprite.load("Items/common/Graphics/brooch.png", 1, 16, 16)
brooch:setTier("common")

brooch:setLog{
    group = "common",
    description = "Gain a &or&temporary barrier&!& on kill for 15 health.",
    story = "This was worn by the legendary Corporal Adams, one of the rebels' most influential commanders. Urban legends say that the guy survived /twelve assassinations/ thanks to this brooch. The jewelers I've taken this too say it's made of topaz, but there's no way topaz could take a sniper rifle's fire and remain intact. This thing is either super lucky, or has some... power behind it. Whatever the case, it makes for a great exhibit.",
    destination = "Jungle VII,\nMuseum of 2019,\nEarth",
    date = "3/23/2056"
}

registercallback("onNPCDeathProc", function(npc, actor)
    if actor:countItem(brooch) > 0 then
        actor:set("barrier", math.clamp(actor:get("barrier") + (15 * actor:countItem(brooch)), 0, actor:get("maxhp")))
    end
end)

GlobalItem.items[brooch] = {
    kill = function(inst, count, damager, hit, x, y)
        inst:set("barrier", math.clamp(inst:get("barrier") + (15 * count), 0, inst:get("maxhp")))
    end,
}
--RoR2 Demake Project
--Made by Sivelos
--wakeOfVultures.lua
--File created 2019/06/01

local vultures = Item("Wake of Vultures")
vultures.pickupText = "Steal the power of slain elites."

vultures.sprite = Sprite.load("Items/rare/Graphics/wakeOfVultures.png", 1, 16, 16)
vultures:setTier("rare")

vultures:setLog{
    group = "rare",
    description = "Steal the power of &b&slain elites&!& for &b&8 seconds&!&.",
    story = "In each of these vulture skulls (surprisingly hard to obtain, by the way. Can you believe these prices?) is a carefully carved hollow for a spirit of your choosing... Trapping them there will grant you their powers. Don't break it. Keeping a spirit hostage will make them angry. And if you're trying to steal a spirit's power, chances are you won't like that same power being used against you.",
    destination = "House of Voodoo,\nNew Orleans,\nEarth",
    date = "3/5/2056"
}

local affixIcons = Sprite.load("Graphics/vultureIcons", 8, 6, 8)

local BlazingBuff = Buff.new("Blazing Prefix")
BlazingBuff.sprite = affixIcons
BlazingBuff.subimage = 1
BlazingBuff.frameSpeed = 0
BlazingBuff:addCallback("start", function(actor)
    actor:set("fire_trail", actor:get("fire_trail") + 1)
end)
BlazingBuff:addCallback("end", function(actor)
    actor:set("fire_trail", actor:get("fire_trail") - 1)
end)

local FrenziedBuff = Buff.new("Frenzied Prefix")
FrenziedBuff.sprite = affixIcons
FrenziedBuff.subimage = 2
FrenziedBuff.frameSpeed = 0
FrenziedBuff:addCallback("start", function(actor)
    actor:set("attack_speed", actor:get("attack_speed") + 0.3)
    actor:set("pHmax", actor:get("pHmax") + 0.3)
end)
FrenziedBuff:addCallback("end", function(actor)
    actor:set("attack_speed", actor:get("attack_speed") - 0.3)
    actor:set("pHmax", actor:get("pHmax") - 0.3)
end)

local LeechingBuff = Buff.new("Leeching Prefix")
LeechingBuff.sprite = affixIcons
LeechingBuff.subimage = 3
LeechingBuff.frameSpeed = 0
LeechingBuff:addCallback("start", function(actor)
    actor:set("lifesteal", actor:get("lifesteal") + 1)
end)
LeechingBuff:addCallback("end", function(actor)
    actor:set("lifesteal", actor:get("lifesteal") - 1)
end)

local OverloadingBuff = Buff.new("Overloading Prefix")
OverloadingBuff.sprite = affixIcons
OverloadingBuff.subimage = 4
OverloadingBuff.frameSpeed = 0
OverloadingBuff:addCallback("start", function(actor)
    actor:set("lightning", actor:get("lightning") + 1)
end)
OverloadingBuff:addCallback("end", function(actor)
    actor:set("lightning", actor:get("lightning") - 1)
end)

local VolatileBuff = Buff.new("Volatile Prefix")
VolatileBuff.sprite = affixIcons
VolatileBuff.subimage = 5
VolatileBuff.frameSpeed = 0
VolatileBuff:addCallback("start", function(actor)
    actor:set("explosive_shot", actor:get("explosive_shot") + 1)
end)
VolatileBuff:addCallback("end", function(actor)
    actor:set("explosive_shot", actor:get("explosive_shot") - 1)
end)

local GlacialBuff = Buff.new("Glacial Prefix")
GlacialBuff.sprite = affixIcons
GlacialBuff.subimage = 6
GlacialBuff.frameSpeed = 0
GlacialBuff:addCallback("start", function(actor)

end)
GlacialBuff:addCallback("end", function(actor)

end)

local PoisonBuff = Buff.new("Malachite Prefix")
PoisonBuff.sprite = affixIcons
PoisonBuff.subimage = 7
PoisonBuff.frameSpeed = 0
PoisonBuff:addCallback("start", function(actor)

end)
PoisonBuff:addCallback("end", function(actor)

end)

local HauntedBuff = Buff.new("Celestine Prefix")
HauntedBuff.sprite = affixIcons
HauntedBuff.subimage = 8
HauntedBuff.frameSpeed = 0
HauntedBuff:addCallback("start", function(actor)

end)
HauntedBuff:addCallback("end", function(actor)

end)

EliteAffixBuffs = {
    [EliteType.find("Blazing", "vanilla")] = BlazingBuff,
    [EliteType.find("Frenzied", "vanilla")] = FrenziedBuff,
    [EliteType.find("Leeching", "vanilla")] = LeechingBuff,
    [EliteType.find("Overloading", "vanilla")] = OverloadingBuff,
    [EliteType.find("Volatile", "vanilla")] = VolatileBuff,
    --[[[EliteType.find("Glacial", "RoR2Demake")] = GlacialBuff,
    [EliteType.find("Malachite", "RoR2Demake")] = PoisonBuff,
    [EliteType.find("Celestine", "RoR2Demake")] = HauntedBuff,]]
}


registercallback("onNPCDeathProc", function(npc, actor)
    if actor:countItem(vultures) > 0 then
        if npc:get("prefix_type") == 1 then
            actor:applyBuff(EliteAffixBuffs[npc:getElite()], (8*60) + (4 * (actor:countItem(vultures) - 1)))
        end
    end
end)

GlobalItem.items[vultures] = {
    kill = function(inst, count, damager, hit, x, y)
        if hit:get("prefix_type") == 1 then
            inst:applyBuff(EliteAffixBuffs[hit:getElite()], (8*60) + (4 * (count - 1)))
        end
    end
}

export("EliteAffixBuffs")

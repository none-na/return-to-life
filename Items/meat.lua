--RoR2 Demake Project
--Made by Sivelos
--meathook.lua
--File created 2020/01/5

local meat = Item("Fresh Meat")
meat.pickupText = "Regenerate health after killing an enemy."

meat.sprite = Sprite.load("Items/meat.png", 1, 16, 16)

meat:setTier("common")
meat:setLog{
    group = "common",
    description = "Killing an enemy lets you heal 2 HP per second for 3 seconds.",
    story = "FOR: JOESEPH ------. \nCC#: ---- ---- - ----\nACCT#: 102215\nQuality Saturnian Bison Meat [10 lbs]\nTreated with special antibiotics to ensure exceptional growth, shelf life, and texture.",
    destination = "Sloppy Joe's Deli and Catering,\nManhattan,\nNew York",
    date = "10/10/2056"
}

local buffs = Sprite.find("Buffs", "vanilla")

local meatBuff = Buff.new("Meat Regen")
meatBuff.sprite = buffs
meatBuff.subimage = 7
meatBuff.frameSpeed = 0
meatBuff:addCallback("start", function(actor)
    local data = actor:getData()
    data.meat = 0
    Sound.find("Use", "vanilla"):play(0.9 + math.random() * 0.1)
end)
meatBuff:addCallback("step", function(actor)
    local data = actor:getData()
    data.meat = data.meat + 1
    if data.meat % 30 == 0 then
        actor:set("hp", actor:get("hp") + 1)
        misc.damage(1, actor.x, actor.y, false, Color.DAMAGE_HEAL)
    end
end)

callback.register("onNPCDeathProc", function(npc, player)
    if player:countItem(meat) > 0 then
        player:applyBuff(meatBuff, (3*60) * player:countItem(meat))
    end
end)

GlobalItem.items[meat] = {
    kill = function(inst, count)
        inst:applyBuff(meatBuff, (3*60) * count)
    end,
}

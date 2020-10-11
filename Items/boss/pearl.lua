--RoR2 Demake Project
--Made by Sivelos
--pearl.lua
--File created 2020/01/10

local pearl = Item("Pearl")
pearl.pickupText = "Increases maximum health by 10%."

pearl.sprite = Sprite.load("Items/boss/Graphics/pearl.png", 1, 16, 16)
--pearl:setTier("uncommon")

pearl:setLog{
    group = "boss_locked",
    description = "Increases &g&maximum health&!& by &g&+10%&!&.",
    story = "---",
    destination = "---,\n---,\n---",
    date = "--/--/2056"
}

pearl.color = "y"

pearl:addCallback("pickup", function(player)
    player:set("percent_hp", player:get("percent_hp") + 0.1)
end)

GlobalItem.items[pearl] = {
    apply = function(inst, count)
        inst:set("percent_hp", (inst:get("percent_hp") or 1) + (0.1 * count))
    end
}

local superPearl = Item("Irradiant Pearl")
superPearl.pickupText = "Increases ALL stats by 10%."

superPearl.sprite = Sprite.load("Items/boss/Graphics/pearl2.png", 1, 16, 16)
--pearl:setTier("uncommon")

superPearl:setLog{
    group = "boss_locked",
    description = "Increases &b&ALL stats&!& by &b&+10%&!&.",
    story = "---",
    destination = "---,\n---,\n---",
    date = "--/--/2056"
}

superPearl.color = "y"

superPearl:addCallback("pickup", function(player)
    player:set("percent_hp", player:get("percent_hp") + 0.1)
    player:set("hp_regen", player:get("hp_regen") * 1.1)
    player:set("pHmax", player:get("pHmax") * 1.1)
    player:set("pVmax", player:get("pVmax") * 1.1)
    player:set("damage", player:get("damage") * 1.1)
    player:set("attack_speed", player:get("attack_speed") * 1.1)
    player:set("critical_chance", player:get("critical_chance") * 1.1)
    player:set("armor", player:get("armor") * 1.1)
end)


GlobalItem.items[superPearl] = {
    apply = function(inst, count)
        inst:set("percent_hp", inst:get("percent_hp") + (0.1 * count))
        inst:set("hp_regen", inst:get("hp_regen") * (1.1 * count))
        inst:set("pHmax", inst:get("pHmax") * (1.1 * count))
        inst:set("pVmax", inst:get("pVmax") * (1.1 * count))
        inst:set("damage", inst:get("damage") * (1.1 * count))
        inst:set("attack_speed", inst:get("attack_speed") * (1.1 * count))
        inst:set("critical_chance", inst:get("critical_chance") * (1.1 * count))
        inst:set("armor", inst:get("armor") * (1.1 * count))
    end
}
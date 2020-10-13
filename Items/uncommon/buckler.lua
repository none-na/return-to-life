--RoR2 Demake Project
--Made by Sivelos
--buckler.lua
--File created 2019/06/10

local shield = Item("Rose Buckler")
shield.pickupText = "Reduce incoming damage while moving."

shield.sprite = restre.spriteLoad("Graphics/buckler.png", 1, 16, 16)

shield:setTier("uncommon")
shield:setLog{
    group = "uncommon",
    description = "Increase armor by 30 while moving.",
    story = "BTW Mama should have sent over another package as well. Let me know when you get it.",
    destination = "Research Center,\nPolarity Zone,\nNeptune",
    date = "5/22/2056"
}

local armorBuff = Buff.new("shield2")
armorBuff.sprite = Sprite.find("Buffs", "vanilla")
armorBuff.subimage = 9
armorBuff.frameSpeed = 0

armorBuff:addCallback("start", function(actor)
    if isa(actor, "PlayerInstance") then
        actor:set("armor", actor:get("armor") + (30 * actor:countItem(shield)))
    elseif isa(actor, "ActorInstance") and GlobalItem.actorIsInit(actor) then
        actor:set("armor", actor:get("armor") + (30 * GlobalItem.countItem(actor, shield)))
    end
end)
armorBuff:addCallback("end", function(actor)
    if isa(actor, "PlayerInstance") then
        actor:set("armor", actor:get("armor") - (30 * actor:countItem(shield)))
    elseif isa(actor, "ActorInstance") and GlobalItem.actorIsInit(actor) then
        actor:set("armor", actor:get("armor") - (30 * GlobalItem.countItem(actor, shield)))
    end
end)

registercallback("onPlayerStep", function(player)
    if player:countItem(shield) > 0 then
        if math.abs(player:get("pHspeed")) > 0 then
            player:applyBuff(armorBuff, 5) 
        end
    end
end)

IRL.setRemoval(shield, function(player)
    if player:hasBuff(armorBuff) then
        player:removeBuff(armorBuff)
    end
end)

GlobalItem.items[shield] = {
    step = function(inst, count)
        if math.abs(inst:get("pHspeed")) > 0 then
            inst:applyBuff(armorBuff, 5) 
        end
    end,
}
--RoR2 Demake Project
--Made by Sivelos
--fireRing.lua
--File created 2019/05/13

local energyDrink = Item("Energy Drink")
energyDrink.pickupText = "Increases movement speed after moving for 1.5 seconds."

energyDrink.sprite = restre.spriteLoad("Graphics/energyDrink.png", 1, 16, 16)
energyDrink:setTier("common")

energyDrink:setLog{
    group = "common",
    description = "Increases movement speed after moving for 1.5 seconds.",
    story = "This is the first and last time I'm ordering from you guys. When I ran out of the soda we normally use, I looked at your product and thought it was just a harmless off-brand soda. What could go wrong?\n\nApparently, what I wasn't told was what you idiots put in these things. Seriously? Sugar is one thing, but how am I supposed to explain to the superintendent that I stocked the high school prom with soda filled with heroin and amphetamines, just to name a few?\n\nConsider this can my refusal of your services from here on out. Never ever buying from you hooligans again.",
    destination = "NRG Production Facility #4,\nUnderhive,\nEarth",
    date = "3/04/2056"
}

local moveTime = 90 --time required, in frames, for speed buff to kick in
local particle = ParticleType.find("Speed", "vanilla")

local energyBuff = Buff.new("energyDrink")
--energyBuff.sprite = restre.spriteLoad("nrgBuff", "Graphics/empty", 1, 0, 0)

energyBuff:addCallback("start", function(player)
    if type(player) == "PlayerInstance" then
        player:set("pHmax", player:get("pHmax") + (0.2 * player:countItem(energyDrink)))
    elseif type(player) == "ActorInstance" and GlobalItem.actorIsInit(player) then
        player:set("pHmax", player:get("pHmax") + (0.2 * GlobalItem.countItem(player, energyDrink)))
    end
end)
energyBuff:addCallback("end", function(player)
    if type(player) == "PlayerInstance" then
        player:set("pHmax", player:get("pHmax") - (0.2 * player:countItem(energyDrink)))
    elseif type(player) == "ActorInstance" and GlobalItem.actorIsInit(player) then
        player:set("pHmax", player:get("pHmax") - (0.2 * GlobalItem.countItem(player, energyDrink)))
    end
end)

registercallback("onPlayerInit", function(player)
    player:set("drink", 0)
end)

registercallback("onPlayerStep", function(player)
    if player:countItem(energyDrink) > 0 then
        if player:get("drink") >= moveTime and player:get("drink") % 10 == 0 then
            particle:burst("middle", player.x, player.y + math.random(-player.sprite.height / 2, player.sprite.height / 2), 1)
        end
        if (player:get("moveLeft") == 1 or player:get("moveRight") == 1) and math.abs(player:get("pHspeed")) > 0 then
            player:set("drink", player:get("drink") + 1)
        else
            player:set("drink", 0)
        end
        if player:get("drink") >= moveTime then
            player:applyBuff(energyBuff, 5)
        end
    end
end)

GlobalItem.items[energyDrink] = {
    apply = function(inst, count)
        inst:set("drink", 0)
    end,
    step = function(inst, count)
        if inst:get("drink") >= moveTime and inst:get("drink") % 10 == 0 then
            particle:burst("middle", inst.x, inst.y + math.random(-inst.sprite.height / 2, inst.sprite.height / 2), 1)
        end
        if (inst:get("moveLeft") == 1 or inst:get("moveRight") == 1) and math.abs(inst:get("pHspeed")) > 0 then
            inst:set("drink", (inst:get("drink") or 0) + 1)
        else
            inst:set("drink", 0)
        end
        if inst:get("drink") >= moveTime then
            inst:applyBuff(energyBuff, 5)
        end
    end,
}

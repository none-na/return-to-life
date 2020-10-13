--RoR2 Demake Project
--Made by Sivelos
--pauldron.lua
--File created 2019/05/13

local pauldron = Item("Bezerker's Pauldron")
pauldron.pickupText = "Sends you into a frenzy after killing 3 enemies within 1 second."

pauldron.sprite = restre.spriteLoad("Graphics/pauldron.png", 1, 16, 16)
pauldron:setTier("uncommon")

pauldron:setLog{
    group = "uncommon",
    description = "Sends you into a &b&frenzy&!& after killing 3 enemies within 1 second.",
    story = "Another antique for the collection.\n\nThis bad boy was found on the battlefield where much of the War was fought. The excavation site was littered with bones, all surrounding the remains of one rebel soldier, who was carrying this artifact. According to hearsay and rumors, rebel soldiers wearing pauldrons much like this one would enter... trances on the battlefield. Time would slow down, and all they could see was the enemy.\n\nOf course, it's just speculation, but... There were a lot of bodies surrounding this thing's old owner. Be careful, OK?",
    destination = "Jungle VII,\nMuseum of 2019,\nEarth",
    date = "5/18/2056"
}

local frenzyParticle = ParticleType.new("Bezerker Frenzy FX")
frenzyParticle:shape("Square")
frenzyParticle:color(Color.RED)
frenzyParticle:alpha(1,0)
frenzyParticle:additive(true)
frenzyParticle:size(0.01, 0.01, 0, 0)
frenzyParticle:life(5, 15)
frenzyParticle:speed(0.3, 0.5, 0, 0)
frenzyParticle:direction(0, 360, 0, 1)


local frenzy = Buff.new("Bezerker Frenzy")
frenzy.sprite = restre.spriteLoad("frenzyIcon", "Graphics/frenzyBuff", 1, 8, 8)

frenzy:addCallback("start", function(player)
    player:set("pHmax", player:get("pHmax") + 1)
    player:set("attack_speed", player:get("attack_speed") + 0.5)
end)
frenzy:addCallback("step", function(player)
    frenzyParticle:burst("middle", player.x, player.y, 15)
end)
frenzy:addCallback("end", function(player)
    player:set("pHmax", player:get("pHmax") - 1)
    player:set("attack_speed", player:get("attack_speed") - 0.5)
end)

registercallback("onActorInit", function(actor)
    if isa(actor, "PlayerInstance") then
        actor:set("killstreak", 0)
        actor:set("pauldron_timer", 60)
    end
end)

registercallback("onNPCDeathProc", function(npc, player)
    if player:isValid() then
        player:set("killstreak", player:get("killstreak") + 1)
    end
end)

registercallback("onPlayerStep", function(player)
    if player:get("killstreak") > 0 then
        if player:get("killstreak") >= 3 and player:countItem(pauldron) > 0 then
            player:applyBuff(frenzy, (6*60) + ((4*60)*(player:countItem(pauldron) - 1)))
        end
        if player:get("pauldron_timer") <= 0 then
            player:set("killstreak", 0)
            player:set("pauldron_timer", 60)
        else
            player:set("pauldron_timer", player:get("pauldron_timer") - 1)
        end
    end
    
end)

GlobalItem.items[pauldron] = {
    apply = function(inst, count)
        inst:set("killstreak", 0)
        inst:set("pauldron_timer", 60)
    end,
    kill = function(inst, count, damager, hit, x, y)
        inst:set("killstreak", inst:get("killstreak") + 1)
    end,
    step = function(inst, count)
        if inst:get("killstreak") > 0 then
            if inst:get("killstreak") >= 3 then
                inst:applyBuff(frenzy, (6*60) + ((4*60)*(inst:countItem(pauldron) - 1)))
            end
            if inst:get("pauldron_timer") <= 0 then
                inst:set("killstreak", 0)
                inst:set("pauldron_timer", 60)
            else
                inst:set("pauldron_timer", inst:get("pauldron_timer") - 1)
            end
        end
    end
}
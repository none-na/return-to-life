--RoR2 Demake Project
--Made by Sivelos
--brainstalks.lua
--File created 2019/05/23

local brainstalks = Item("Brainstalks")
brainstalks.pickupText = "Skills have NO cooldowns for a short period after killing an elite monster."

brainstalks.sprite = restre.spriteLoad("Graphics/brainstalks.png", 1, 16, 16)
brainstalks:setTier("rare")

brainstalks:setLog{
    group = "rare_locked",
    description = "Killing an elite sends you into a frenzy that removes all skill cooldowns.",
    story = "Exceptional work as always. This should put me ahead of the other lab team... I'll send you payment shortly, just give me a few days to scrounge up the money.",
    destination = "5012,\nFrazux Colony,\nMars",
    date = "4/23/2056"
}

local brainFrenzy = Buff.new("Brainstalks")
brainFrenzy.sprite = restre.spriteLoad("Graphics/brainstalksBuff", 1, 6, 7)

brainFrenzy:addCallback("step", function(actor)
    for i = 2, 5 do
        if actor:getAlarm(i) > -1 then
            actor:setAlarm(i, -1)
        end
    end
end)

registercallback("onNPCDeathProc", function(npc, actor)
    if actor:isValid() then
        if actor:countItem(brainstalks) > 0 then
            if npc:get("prefix_type") > 0 then
                actor:applyBuff(brainFrenzy, (3*60) + ((2*60) * (actor:countItem(brainstalks) - 1)))
            end
        end
    end
end)

GlobalItem.items[brainstalks] = {
    kill = function(inst, count, damager, hit, x, y)
        if hit:get("prefix_type") > 0 then
            inst:applyBuff(brainFrenzy, (3*60) + ((2*60) * (count - 1)))
        end
    end,
}

local deicide = Achievement.new("Deicide")
deicide.requirement = 1
deicide.deathReset = false
deicide.description = "Kill an Elite Boss on Monsoon difficulty."
deicide.highscoreText = "\'Brainstalks\' Unlocked"
deicide:assignUnlockable(brainstalks)

registercallback("onNPCDeath", function(npc)
    if npc:isValid() and npc:isBoss() and npc:get("prefix_type") > 0 then
        if Difficulty.getActive() == Difficulty.find("Monsoon", "vanilla") then
            deicide:increment(1)
        end
    end
end)
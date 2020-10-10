--RoR2 Demake Project
--Made by Sivelos
--goldseed.lua
--File created 2019/07/1

local goldseed = Item("Halcyon Seed")
goldseed.pickupText = "Summons Aurelionite during the teleporter event."

goldseed.sprite = Sprite.load("Items/goldSeed.png", 1, 16, 16)
--goldseed:setTier("use")

goldseed.color = "y"

goldseed:setLog{
    group = "boss",
    description = "Summons &y&Aurelionite&!& during the teleporter event. &b&+50% damage&!& and &b&+100% HP&!& per stack.",
    story = "This gold seed is my only comfort now. Studying the nooks and crannies of its surface... Admiring its luster when light strikes it at just the right angle... Perhaps the hell I've endured so far was a trial, a trial to obtain this seed. Yes, I believe it is... The countless bodies I've stepped over to get this far, they all died for this! And... I'm sure they wouldn't mind a few more... Just for another glimpse of this beautiful little seed.",
    destination = "The Hidden Vault,\nUnknown",
    date = "05/03/2056"
}

local teleporter = Object.find("Teleporter", "vanilla")
local aurelionite = Object.find("TitanGold", "RoR2Demake")

local summon = nil

callback.register("onStep", function()
    for _, tpInst in ipairs(teleporter:findAll()) do
        local tp = tpInst:getAccessor()
        if tp.active == 1 then
            if not summon then
                local seedCount = 0
                for _, playerInst in ipairs(misc.players) do
                    seedCount = seedCount + playerInst:countItem(goldseed)
                end
                if seedCount > 0 then
                    if not summon then
                        debugPrint("Halcyon Seed: Creating new Aurelionite...")
                        summon = aurelionite:create(tpInst.x, tpInst.y - 2)
                        local goldInst = summon:getAccessor()
                        goldInst.show_boss_health = 0
                        goldInst.team = "player"
                        goldInst.maxhp = (2100 * Difficulty.getScaling("hp")) + (2100 * (seedCount - 1))
                        goldInst.hp = goldInst.maxhp
                        goldInst.hp_regen = goldInst.maxhp / 1000
                        goldInst.damage = (40 * Difficulty.getScaling("damage")) + (20 * (seedCount - 1))
                        misc.director:set("ghost_count", misc.director:get("ghost_count") + 1)
                    end
                end
            end        
        else
            if summon then
                if summon:isValid() then
                    summon:kill()
                    misc.director:set("ghost_count", misc.director:get("ghost_count") - 1)
                    summon = nil
                end
            end
        end
    end
end)
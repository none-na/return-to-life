--RoR2 Demake Project
--Made by N4K0 and Gamu
--stealthkit.lua
--File created 2019/04/09

local stealthkit = Item("Old War Stealthkit")
stealthkit.pickupText = "Chance on hit to turn invisible."

stealthkit.sprite = restre.spriteLoad("Graphics/stealthkit.png", 1, 16, 16)

stealthkit:setTier("uncommon")
stealthkit:setLog{
    group = "uncommon",
    description = "Chance on hit to turn invisible and gain 40% movement speed.",
    story = "This baby is a relic from a war on Earth long, long ago. It outputs some kind of signal that affects the perception of others... Makes 'em completely incapable of knowing you're even there. Fascinating neurological science. The thing's old though, doesn't always work. You might want to give it a good smack now and again to wake the thing up.",
    destination = "1023-B,\nRoguefort,\nNeptune",
    date = "1/4/2056"
}

local invisibilitySound = Sound.find("MinerShoot2", "vanilla")
local customParticles = ParticleType.new("Smokey Aura")
customParticles:shape("pixel")
customParticles:color(Color.fromRGB(130, 130, 130))
customParticles:alpha(0.6)
customParticles:additive(true)
customParticles:size(0.35, 1, 0, 0.25)
customParticles:speed(0.35, 0.55, -0.01, 0.01)
customParticles:direction(85, 95, 0, 8)
customParticles:life(60 * 0.55, 60 * 0.15)

local buff = Buff.new("Stealthkit")

buff:addCallback("start", function(player)
    player:set("stealthKitSpeedIncrease", player:get("pHmax") * 0.4)
    player:set("pHmax", player:get("pHmax") + player:get("stealthKitSpeedIncrease"))

    if type(player) == "PlayerInstance" then    
        local playerPoi = Object.findInstance(player:get("child_poi"))
        if playerPoi then
            playerPoi:destroy()
        end
        player.alpha = 0.5
    else
        player.alpha = 0
    end
    invisibilitySound:play(1.5, 2)
end)

buff:addCallback("step", function(player)
    if type(player) == "PlayerInstance" then
        local playerPoi = Object.findInstance(player:get("child_poi"))
        if playerPoi then
            playerPoi:destroy()
        end
    
        local playerSprite = player.sprite
        local xrandomizerBound = math.floor(playerSprite.boundingBoxRight / 2)
        local xrandomizer = math.round(math.random(-1 * xrandomizerBound, xrandomizerBound))
    
        customParticles:gravity(0.01 * (playerSprite.height / 12), 90)
        customParticles:burst("middle", player.x + xrandomizer, player.y + math.round(playerSprite.height - playerSprite.yorigin), math.random(2, 3), Color.fromRGB(100, 100, 100))
        player.alpha = 0.5
    end
end)

buff:addCallback("end", function(player)
    if type(player) == "PlayerInstance" then
        local playerPoi = Object.findInstance(player:get("child_poi"))
        if not playerPoi then
            playerPoi = Object.find("POI", "vanilla"):create(player.x, player.y)
            playerPoi:set("parent", player.id)
            player:set("child_poi", playerPoi.id)
        end
    end

    player:set("pHmax", player:get("pHmax") - player:get("stealthKitSpeedIncrease"))
    player:set("stealthKitSpeedIncrease", nil)
    player.alpha = 1
end)

registercallback("onPlayerStep", function(player)
    local count = player:countItem(stealthkit)
    if count > 0 then
        if not player:hasBuff(buff) then
            if player:get("lastHp") > player:get("hp") then
                local damageTaken = player:get("lastHp") - player:get("hp")
                local chanceToProc = damageTaken / player:get("hp")
                if math.chance((chanceToProc * 100) + count) then
                    player:applyBuff(buff, 60 * (1.5 + 0.5 * count))
                end
            end
        end
    end
end)

IRL.setRemoval(stealthkit, function(player)
    if player:hasBuff(buff) then
        player:removeBuff(buff)
    end
end)

GlobalItem.items[stealthkit] = {
    damage = function(inst, count, damage)
        local damageTaken = damage
        local chanceToProc = damageTaken / inst:get("hp")
        if math.chance((chanceToProc * 100) + count) then
            inst:applyBuff(buff, 60 * (1.5 + 0.5 * count))
        end
    end,
    remove = function(inst, count, hardRemove)
        if inst:hasBuff(buff) then
            inst:removeBuff(buff)
        end
    end
}

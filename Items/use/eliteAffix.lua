--RoR2 Demake Project
--Made by Sivelos
--eliteAffix.lua
--File created 2019/05/14

local useSound = Sound.find("Pickup", "vanilla")

affixRed = Item("Ifrit's Distinction")
affixRed.pickupText = "Become an Aspect of Fire."
affixRed.sprite = Sprite.load("Items/use/GraphicsaffixRed", 2, 16, 16)
affixRed.isUseItem = true
affixRed.useCooldown = 0
affixRed:addCallback("pickup", function(player)
    player.blendColor = Color.fromRGB(186,61,29)
    player:set("fire_trail", player:get("fire_trail") + 1)
end)
affixRed:addCallback("drop", function(player)
    player.blendColor = Color.fromRGB(255,255,255)
    player:set("fire_trail", player:get("fire_trail") - 1)
end)
export("affixRed")

affixBlue = Item("Silence Between Two Strikes")
affixBlue.pickupText = "Become an Aspect of Lightning."
affixBlue.sprite = Sprite.load("Items/use/GraphicsaffixBlue", 2, 16, 16)
affixBlue.isUseItem = true
affixBlue.useCooldown = 0
affixBlue:addCallback("pickup", function(player)
    player.blendColor = Color.fromRGB(119,255,238)
    player:set("lightning", player:get("lightning") + 1)
end)
affixBlue:addCallback("drop", function(player)
    player.blendColor = Color.fromRGB(255,255,255)
    player:set("lightning", player:get("lightning") - 1)
end)
export("affixBlue")

affixYellow = Item("In The Blink Of An Eye")
affixYellow.pickupText = "Become an Aspect of Speed."
affixYellow.sprite = Sprite.load("Items/use/GraphicsaffixYellow", 2, 16, 16)
affixYellow.isUseItem = true
affixYellow.useCooldown = 0
affixYellow:addCallback("pickup", function(player)
    player.blendColor = Color.fromRGB(231,241,37)
    local level = player:get("level")
    player:set("pHmax", player:get("pHmax") + 0.5)
    player:set("attack_speed", player:get("attack_speed") + 0.5)
end)
affixYellow:addCallback("drop", function(player)
    player.blendColor = Color.fromRGB(255,255,255)
    local level = player:get("level")
    player:set("pHmax", player:get("pHmax") - 0.5)
    player:set("attack_speed", player:get("attack_speed") - 0.5)
end)
export("affixYellow")

affixOrange = Item("Hairpin Trigger")
affixOrange.pickupText = "Become an Aspect of Destruction."
affixOrange.sprite = Sprite.load("Items/use/GraphicsaffixOrange", 2, 16, 16)
affixOrange.isUseItem = true
affixOrange.useCooldown = 0
affixOrange:addCallback("pickup", function(player)
    player.blendColor = Color.fromRGB(205,136,69)
    player:set("explosive_shot", player:get("explosive_shot") + 1)
end)
affixOrange:addCallback("drop", function(player)
    player.blendColor = Color.fromRGB(255,255,255)
    player:set("explosive_shot", player:get("explosive_shot") - 1)
end)
export("affixOrange")

affixGreen = Item("Parasitic Relations")
affixGreen.pickupText = "Become an Aspect of Life."
affixGreen.sprite = Sprite.load("Items/use/GraphicsaffixGreen", 2, 16, 16)
affixGreen.isUseItem = true
affixGreen.useCooldown = 0
affixGreen:addCallback("pickup", function(player)
    player.blendColor = Color.fromRGB(70,209,35)
    player:set("lifesteal", player:get("lifesteal") + 1)
end)
affixGreen:addCallback("drop", function(player)
    player.blendColor = Color.fromRGB(255,255,255)
    player:set("lifesteal", player:get("lifesteal") - 1)
end)
export("affixGreen")


affixWhite = Item("Her Biting Embrace")
affixWhite.pickupText = "Become an Aspect of Ice."
affixWhite.sprite = Sprite.load("Items/use/GraphicsaffixWhite", 2, 16, 16)
affixWhite.isUseItem = true
affixWhite.useCooldown = 0
affixWhite:addCallback("pickup", function(player)
    player.blendColor = Color.fromRGB(255,255,255)
end)
affixWhite:addCallback("drop", function(player)
    player.blendColor = Color.fromRGB(255,255,255)
end)
export("affixWhite")

affixPoison = Item("N'Kuhana's Retort")
affixPoison.pickupText = "Become an Aspect of Corruption."
affixPoison.sprite = Sprite.load("Items/use/GraphicsaffixPoison", 2, 16, 16)
affixPoison.isUseItem = true
affixPoison.useCooldown = 0
affixPoison:addCallback("pickup", function(player)
    player.blendColor = Color.fromRGB(255,255,255)
end)
affixPoison:addCallback("drop", function(player)
    player.blendColor = Color.fromRGB(255,255,255)
end)
export("affixPoison")

affixHaunted = Item("Spectral Circlet")
affixHaunted.pickupText = "Become an Aspect of Incorporeality."
affixHaunted.sprite = Sprite.load("Items/use/GraphicsaffixHaunted", 2, 16, 16)
affixHaunted.isUseItem = true
affixHaunted.useCooldown = 0
affixHaunted:addCallback("pickup", function(player)
    player.blendColor = Color.fromRGB(255,255,255)
end)
affixHaunted:addCallback("drop", function(player)
    player.blendColor = Color.fromRGB(255,255,255)
end)
export("affixHaunted")

affixGold = Item("Coven of Gold")
affixGold.pickupText = "Become an Aspect of Fortune."
affixGold.sprite = Sprite.load("Items/use/GraphicsaffixGold", 2, 16, 16)
affixGold.isUseItem = true
affixGold.useCooldown = 0
affixGold:addCallback("pickup", function(player)
    player.blendColor = Color.fromRGB(255,255,255)
end)
affixGold:addCallback("drop", function(player)
    player.blendColor = Color.fromRGB(255,255,255)
end)
export("affixGold")



local affixItems = {
    [0] = affixRed,
    [1] = affixYellow,
    [2] = affixGreen,
    [3] = affixBlue,
    [4] = affixOrange,
    [5] = affixWhite,
    [6] = affixPoison,
    [7] = affixHaunted,
    [8] = affixGold
}

for i=0, 7 do
    local affix = affixItems[i]
    if affix then
        affix.color = "y"
        affix:addCallback("use", function(player)
            player:setAlarm(0, -1)
            if useSound:isPlaying() then
                useSound:stop()
            end
        end)
    end
end

local CreateEliteAffix = net.Packet.new("Create Affix Item", function(player, eliteType, x, y)
    local affix = affixItems[eliteType]
    if affix then
        affix:create(x, y)
    end
end)

registercallback("onNPCDeath", function(npc)
    if npc:isValid() and npc:get("prefix_type") == 1 then
        if net.host then
            if affixItems[npc:get("elite_type")] then
                if net.host then
                    if math.random(0, 1000) <= 1 then
                        affixItems[npc:get("elite_type")]:create(npc.x, npc.y)
                        if net.online then
                            CreateEliteAffix:sendAsHost(net.ALL, nil, npc:get("elite_type"), npc.x, npc.y)
                        end
                    end
                end
            end
        end
    end
end)
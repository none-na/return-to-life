--RoR2 Demake Project
--Made by Sivelos
--capacitor.lua
--File created 2019/04/09

local capacitor = Item("Royal Capacitor")
capacitor.pickupText = "Strikes most recently hit enemy with lightning."

capacitor.sprite = Sprite.load("Items/capacitor.png", 2, 13, 14)

capacitor.isUseItem = true
capacitor.useCooldown = 20

local reticule = Sprite.load("Graphics/capacitorTarget", 1, 16, 16)
local lightningFX = Sprite.load("lightning", "Graphics/lightning", 13, 24, 153)
local lightningSound = Sound.find("Lightning", "vanilla")

local useSound = Sound.find("Pickup", "vanilla")

capacitor:setTier("use")
capacitor:setLog{
    group = "use",
    description = "Strikes &b&most recently hit enemy&!& with lightning for &y&3000%&!&.",
    story = "Here's the replacement for your damaged capacitor. Be careful, though... This thing has an emergency discharge button, to prevent damaging any hardware. Unfortunately, this damage-prevention button doesn't prevent damage to any passersby. Yeah, we had a big problem with lawsuits after several bystanders were struck by the lightning bolts this thing spewed.",
    destination = "Nikola Research Lab,\nHungary,\nEarth",
    date = "2/18/2056"
}


local enemies = ParentObject.find("enemies", "vanilla")

capacitor:addCallback("use", function(player, embryo)
    local playerA = player:getAccessor()
	local count = 1
	-- Increase spawn count if embryo is procced
	if embryo then
		count = 2
	end
	local successful = false
    for i = 1, count do
        for _, inst in ipairs(enemies:findMatching("id", playerA.lastHit)) do
            local target = inst
            if playerA.lastHit ~= nil and target:isValid() then
                lightningSound:play(0.8 + math.random() * 0.2)
                misc.shakeScreen(5)
                local bolt = player:fireExplosion(target.x, target.y, lightningFX.width/19, 8/4, 30, lightningFX, nil)
                bolt:set("stun", 1)
                successful = true
            end
        end
    end
    if not successful then
        player:setAlarm(0, -1)
        if useSound:isPlaying() then
            useSound:stop()
        end
    end
end)

registercallback("onPlayerStep", function(player)
    if player.useItem == capacitor and player:getAlarm(0) <= 0 then
        local playerA = player:getAccessor()
        for _, inst in ipairs(enemies:findMatching("id", playerA.lastHit)) do
            local target = inst
        end
    end
end)

registercallback("onHit", function(damager, hit, x, y)
    if damager:getParent() ~= nil then
        if damager:getParent():isValid() then
            if damager:getParent():get("team") == "player" and isa(damager:getParent(), "PlayerInstance") then
                local player = damager:getParent()
                if player.useItem == capacitor and player:getAlarm(0) <= 0 then
                    local playerA = player:getAccessor()
                    playerA.lastHit = hit.id
                end
            end
        end
    end
end)

registercallback("onPlayerDraw", function(player, x, y)
    if player.useItem == capacitor and player:getAlarm(0) <= 0 then
        local playerA = player:getAccessor()
        for _, inst in ipairs(enemies:findMatching("id", playerA.lastHit)) do
            local target = inst
            if playerA.lastHit ~= nil and target:isValid() then
                graphics.drawImage({
                    reticule,
                    target.x,
                    target.y
                })
            end
        end
    end
end)

GlobalItem.items[capacitor] = {
    use = function(inst, embryo)
        local data = inst:getModData(GlobalItem.namespace)
        local c = 1
        -- Increase spawn count if embryo is procced
        if embryo then
            c = 2
        end
        local successful = false
        for i = 1, c do
            if data.lastHit and data.lastHit:isValid() then
                lightningSound:play(0.8 + math.random() * 0.2)
                misc.shakeScreen(5)
                local bolt = inst:fireExplosion(data.lastHit.x, data.lastHit.y, lightningFX.width/19, 8/4, 30, lightningFX, nil)
                bolt:set("stun", 1)
                successful = true
            end
        end
        if not successful then
            data.equipmentCooldown = -1
            if useSound:isPlaying() then
                useSound:stop()
            end
        end
    end,
    hit = function(inst, count, damager, hit, x, y)
        local data = inst:getModData(GlobalItem.namespace)
        if data.equipmentCooldown == -1 then
            data.lastHit = hit
        end
    end,
    draw = function(inst, count)
        local data = inst:getModData(GlobalItem.namespace)
        if data.equipmentCooldown <= -1 then
            if data.lastHit and data.lastHit:isValid() then
                graphics.drawImage({
                    reticule,
                    data.lastHit.x,
                    data.lastHit.y
                })
            end
        end
    end,
}
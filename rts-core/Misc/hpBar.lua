local hpBoxX = 0
local hpBoxY = 0
local hpBoxH = 0
local hpBoxW = 0

local actors = ParentObject.find("actors", "vanilla")

local sprites = {
    immune = Sprite.find("Immune", "vanilla"),
    hudbarHP = Sprite.find("HUDBarHP", "vanilla")
}

local hpColors = {
    hp = Color.fromRGB(136, 211, 103),
    hurt = Color.fromRGB(255, 0, 0),
    infusion = Color.fromRGB(169, 63, 66),
    shield = Color.fromRGB(72, 183, 183),
    exp = Color.fromRGB(168, 223, 218),
    glass = Color.fromRGB(175, 116, 201),
    barrier = Color.fromRGB(221, 182, 47),
    immune = Color.fromRGB(226, 191, 139),
    invincible = Color.fromRGB(239, 191, 139),
    empty = Color.fromRGB(26, 26, 26)
}

local npcHPColors = {
    tier1 = Color.fromRGB(201, 52, 52),
    tier2 = Color.fromRGB(220, 164, 46),
    tier3 = Color.fromRGB(230, 218, 72),
}

local hpBarElements = {
    [1] = {
        [1] = {current = "hp", max = "maxhp", color = hpColors.hp, contributeToCurrentHP = true, contributeToMaxHP = true},
        [2] = {current = "shield", max = "maxshield", color = hpColors.shield, contributeToCurrentHP = true, contributeToMaxHP = false}
    },
    [2] = {
        [1] = {current = "barrier", max = "maxhp", color = hpColors.barrier, contributeToCurrentHP = true, contributeToMaxHP = false}
    }
}

local DrawHPBar = function(player, x, y, w, h)
    --Draw hp
    local hpX = x--x -35
    local hpY = y--y + 29
    local hpW = w--160
    local hpH = h--7
    -- Draw bg
    graphics.color(hpColors.empty)
    graphics.alpha(1)
    graphics.rectangle(hpX, hpY, hpX + hpW, hpY + hpH)
    --Calculate shit
    local maxHP = 0
    local currentHP = 0
    for _, layer in ipairs(hpBarElements) do
        local currentTotal = 0
        local maxTotal = 0
        local currentX = 0
        --Get currents and maxes for each stat
        for _, stat in ipairs(layer) do
            currentTotal = currentTotal + (player:get(stat.current) or 0)
            maxTotal = maxTotal + (player:get(stat.max) or 0)
            if stat.contributeToCurrentHP then
                currentHP = currentHP + player:get(stat.current) --If stat contributes to current HP, add it to current HP text value
            end
            if stat.contributeToMaxHP then
                maxHP = maxHP + player:get(stat.max) --If stat contributes to max HP, add it to max HP text value
            end
        end
        local length = 0
        for _, stat in ipairs(layer) do
            if player:get(stat.current) > 0 then
                length = (player:get(stat.current) / maxTotal) * (hpW * math.clamp(player:get("percent_hp"), 0, 1))
                if stat.current == "hp" then
                    if Artifact.find("Glass", "vanilla") and Artifact.find("Glass", "vanilla").active then
                        graphics.color(hpColors.glass)
                    else
                        graphics.color(hpColors.hp)
                    end
                    if player:countItem(Item.find("Infusion", "vanilla")) > 0 then
                        graphics.color(hpColors.infusion)
                    end
                else
                    graphics.color(stat.color)
                end
                graphics.alpha(1)
                graphics.rectangle(hpX + currentX, hpY, hpX + currentX + length, hpY + hpH)
                currentX = currentX + length
            end
        end
        if player:get("percent_hp") < 1 then --Draw Curse (if percent_hp is less than one, draw something to fill empty part of HP bar)
            graphics.color(Color.WHITE)
            graphics.alpha(0.5)
            local curseW = hpW - (hpW * math.clamp(player:get("percent_hp"), 0, 1))
            local curseX = hpX + (hpW * math.clamp(player:get("percent_hp"), 0, 1))
            graphics.rectangle(curseX, hpY, curseX + curseW, hpY + hpH, true)
        end
        
    end
    graphics.color(Color.WHITE)
    graphics.alpha(1)
    if player:get("invincible") > 0 and player:get("scarfed") == 0 then --Invincibility handler
        local subimage = 1
        graphics.color(hpColors.immune)
        if player:get("invincible") > 1000 then
            subimage = 2    
            graphics.color(hpColors.invincible)
        end
        graphics.rectangle(hpX, hpY, hpX + hpW, hpY + hpH)
        graphics.drawImage{
            image = sprites.immune,
            subimage = subimage,
            x = hpX + (hpW/2),
            y = hpY + (hpH/2) + 1
        }
    else
        --Draw Text
        graphics.print(math.ceil(currentHP).."/"..maxHP, hpX + (hpW/2), hpY + (hpH/2) + 0.5, NewDamageFont, graphics.ALIGN_MIDDLE, graphics.ALIGN_CENTER)
    end

end

DrawBossHP = function(boss, x, y)
    --Draw hp
    local hpX = x--x -35
    local hpY = y--y + 29
    local hpW = 627
    local hpH = 9
    -- Draw bg
    graphics.color(hpColors.empty)
    graphics.alpha(1)
    graphics.rectangle(hpX, hpY, hpX + hpW, hpY + hpH)
    --Calculate shit
    local maxHP = 0
    local currentHP = 0
    for _, layer in ipairs(hpBarElements) do
        local currentTotal = 0
        local maxTotal = 0
        local currentX = 0
        --Get currents and maxes for each stat
        for _, stat in ipairs(layer) do
            currentTotal = currentTotal + (boss:get(stat.current) or 0)
            maxTotal = maxTotal + (boss:get(stat.max) or 0)
            if stat.contributeToCurrentHP then
                currentHP = currentHP + boss:get(stat.current) --If stat contributes to current HP, add it to current HP text value
            end
            if stat.contributeToMaxHP then
                maxHP = maxHP + boss:get(stat.max) --If stat contributes to max HP, add it to max HP text value
            end
        end
        local length = 0
        for _, stat in ipairs(layer) do
            if boss:get(stat.current) > 0 then
                length = (boss:get(stat.current) / maxTotal) * (hpW)
                if stat.current == "hp" then
                    graphics.color(Color.fromGML(misc.hud:get("boss_hp_color")))
                else
                    graphics.color(stat.color)
                end
                graphics.alpha(1)
                graphics.rectangle(hpX + currentX, hpY, hpX + currentX + length, hpY + hpH)
                graphics.color(Color.WHITE)
                graphics.alpha(0.4)
                graphics.rectangle(hpX + currentX, hpY + 1, hpX + currentX + length, hpY + 1 + (hpH/3))
                currentX = currentX + length
            end
        end
    end
    graphics.color(Color.WHITE)
    graphics.alpha(1)
    --Draw Text
    graphics.print(math.ceil(currentHP).."/"..math.ceil(maxHP), hpX + (hpW/2), hpY + (hpH/2) + 1, graphics.FONT_DEFAULT, graphics.ALIGN_MIDDLE, graphics.ALIGN_CENTER)
end

--Don't draw over the boss HP bar if it's these enemies
local noBossDraw = {
    [Object.find("WormHead", "vanilla")] = true,
    [Object.find("WormBody", "vanilla")] = true,
    [Object.find("WurmHead", "vanilla")] = true,
    [Object.find("WurmBody", "vanilla")] = true,
    [Object.find("WurmController", "vanilla")] = true,
    [Object.find("Boss1", "vanilla")] = true,
    [Object.find("Boss3", "vanilla")] = true,
}

-- Don't draw HP bars if it's these enemies
local noNPCDraw = {
    [Object.find("WormHead", "vanilla")] = true,
    [Object.find("WormBody", "vanilla")] = true,
    [Object.find("WurmHead", "vanilla")] = true,
    [Object.find("WurmBody", "vanilla")] = true,
}

callback.register("onPlayerHUDDraw", function(player, x, y)
    DrawHPBar(player, x - 35, y + 29, 160, 7)

    local boss = Object.findInstance(misc.hud:get("boss_id"))
    if boss and misc.hud:get("show_boss") == 1 then
        if noBossDraw[boss:getObject()] then
            return
        end
        DrawBossHP(boss, 6, 5)
    end
end)

local DrawNPCHP = function(actor)
    if (misc.hud:get("show_boss") == 1 and misc.hud:get("boss_id") == actor.id) then return end
    if noNPCDraw[actor:getObject()] then return end
    if actor:getBlighted() and actor:getAlarm(6) <= 60 * 2.5 then return end

    local a = actor:getAccessor()
    local isBoss = actor:isBoss()
    local quality = 0 + misc.getOption("video.quality")
    local hud = misc.hud
    local honor = Artifact.find("Honor", "vanilla").active
    if ((actor:getAlarm(6) ~= -1 and hud:get("hp_bar_count") <= 10 * quality) or isBoss or (a.prefix_type > 0 and not honor)) and a.ghost == 0 then
        graphics.alpha(1)
        local x = actor.x
        local y = actor.y
        local currentHP = 0
        local maxHP = 0
        local tiers, rx10min, rysid, t202min, mhp, rysoff, mhp13, fmhpt
        mhp13 = a.maxhp / 3
        tiers = math.min(math.max(1, a.maxhp / 3000), 3)
        rysoff = math.round(y) - (actor:getAnimation("idle").yorigin)
        mhp = math.max(a.hp, 0)
        fmhpt = math.floor(a.maxhp / tiers * 0.005)
        t202min = (20 + 2 * math.min(100, fmhpt))
        rysid = rysoff - 6
        rx10min = math.round(x) - 10 - math.min(100, fmhpt)



        if isBoss or (a.prefix_type > 0 and not honor) and quality >= 2 then
            graphics.drawImage{
                image = sprites.hudbarHP,
                x = math.round(x) - 12 - math.min(100, fmhpt),
                y = rysoff - 8,
                width = 24 + 2 * math.min(100, fmhpt),
                height = 7,
                color = Color.LIGHT_GRAY,
                alpha = 1
            }
        end
        if a.maxhp <= 9000 then
            if quality >= 2 then
                graphics.drawImage{
                    image = sprites.hudbarHP,
                    x = math.round(x) - 11 - math.min(100, fmhpt),
                    y = rysoff - 7,
                    width = 22 + 2 * math.min(100, fmhpt),
                    height = 5,
                    color = Color.DARK_GRAY,
                    alpha = 1
                }
                graphics.drawImage{
                    image = sprites.hudbarHP,
                    x = rx10min,
                    y = rysid,
                    width = 20 + 2 * math.min(100, fmhpt),
                    height = 3,
                    color = Color.BLACK,
                    alpha = 1
                }
            end
            local hpX, hpY, hpW, hpH
            hpX = 0
            hpY = 0
            hpW = 22 + 2 * math.min(100, fmhpt)
            hpH = 0
            for _, layer in ipairs(hpBarElements) do
                local currentTotal = 0
                local maxTotal = 0
                local currentX = 0
                --Get currents and maxes for each stat
                for _, stat in ipairs(layer) do
                    if actor:get(stat.current) then
                        currentTotal = currentTotal + (actor:get(stat.current) or 0)
                        maxTotal = maxTotal + (actor:get(stat.max) or 0)
                        if stat.contributeToCurrentHP then
                            currentHP = currentHP + actor:get(stat.current) --If stat contributes to current HP, add it to current HP text value
                        end
                        if stat.contributeToMaxHP then
                            maxHP = maxHP + actor:get(stat.max) --If stat contributes to max HP, add it to max HP text value
                        end
                    end
                end
                local length = 0
                for _, stat in ipairs(layer) do
                    if actor:get(stat.current) and actor:get(stat.current) > 0 then
                        hpX = rx10min
                        hpY = rysid
                        hpH = 2
                        if stat.current == "hp" then
                            if a.hp < 6000 then
                                hpW = t202min * (math.min(3000, mhp) / math.min(3000, a.maxhp))
                                graphics.color(npcHPColors.tier1)
                            end
                            if a.hp > 3000 then
                                graphics.alpha(1)
                                graphics.color(npcHPColors.tier1)
                                graphics.rectangle(hpX + currentX, hpY, hpX + currentX + (hpW - currentX - 1), hpY + hpH)
                                hpW = t202min * (math.min(3000, mhp - 3000) / 3000)
                                graphics.color(npcHPColors.tier2)
                            end
                            if a.hp > 6000 then
                                graphics.alpha(1)
                                graphics.color(npcHPColors.tier2)
                                graphics.rectangle(hpX + currentX, hpY, hpX + currentX + (hpW - currentX - 1), hpY + hpH)
                                hpW = t202min * (math.min(3000, mhp - 6000) / 3000)
                                graphics.color(npcHPColors.tier3)
                            end
                        else
                            graphics.color(stat.color)
                        end
                        length = (actor:get(stat.current) / maxTotal) * (hpW * math.clamp(actor:get("percent_hp") or 1, 0, 1))
                        graphics.alpha(1)
                        graphics.rectangle(hpX + currentX, hpY, hpX + currentX + length, hpY + hpH)
                        currentX = currentX + length
                    end
                end
                if actor:get("percent_hp") and actor:get("percent_hp") < 1 then --Draw Curse (if percent_hp is less than one, draw something to fill empty part of HP bar)
                    graphics.color(Color.WHITE)
                    graphics.alpha(0.5)
                    local curseW = hpW - (hpW * math.clamp(actor:get("percent_hp"), 0, 1))
                    local curseX = hpX + (hpW * math.clamp(actor:get("percent_hp"), 0, 1))
                    graphics.rectangle(curseX, hpY, curseX + curseW, hpY + hpH, true)
                end
            end
        else
            if quality >= 2 then
                graphics.drawImage{
                    image = sprites.hudbarHP,
                    x = math.round(x) - 11 - math.min(100, fmhpt),
                    y = rysoff - 7,
                    width = 22 + 2 * math.min(100, fmhpt),
                    height = 5,
                    color = Color.DARK_GRAY,
                    alpha = 1
                }
                graphics.drawImage{
                    image = sprites.hudbarHP,
                    x = rx10min,
                    y = rysid,
                    width = 20 + 2 * math.min(100, fmhpt),
                    height = 3,
                    color = Color.BLACK,
                    alpha = 1
                }
            end
            local hpX, hpY, hpW, hpH
            hpX = 0
            hpY = 0
            hpW = 22 + 2 * math.min(100, fmhpt)
            hpH = 0
            for _, layer in ipairs(hpBarElements) do
                local currentTotal = 0
                local maxTotal = 0
                local currentX = 0
                --Get currents and maxes for each stat
                for _, stat in ipairs(layer) do
                    if actor:get(stat.current) then
                        currentTotal = currentTotal + (actor:get(stat.current) or 0)
                        maxTotal = maxTotal + (actor:get(stat.max) or 0)
                        if stat.contributeToCurrentHP then
                            currentHP = currentHP + actor:get(stat.current) --If stat contributes to current HP, add it to current HP text value
                        end
                        if stat.contributeToMaxHP then
                            maxHP = maxHP + actor:get(stat.max) --If stat contributes to max HP, add it to max HP text value
                        end
                    end
                end
                local length = 0
                
                for _, stat in ipairs(layer) do
                    if actor:get(stat.current) and actor:get(stat.current) > 0 then
                        hpX = rx10min
                        hpY = rysid
                        hpH = 2
                        if stat.current == "hp" then
                            if a.hp < (a.maxhp * (2/3)) then
                                hpW = t202min * (math.min(mhp13, mhp) / math.min(mhp13, a.maxhp))
                                graphics.color(npcHPColors.tier1)
                            end
                            if a.hp > (mhp13) then
                                graphics.alpha(1)
                                graphics.color(npcHPColors.tier1)
                                graphics.rectangle(hpX + currentX, hpY, hpX + currentX + (currentX - hpW), hpY + hpH)
                                hpW = t202min * (math.min(mhp13, mhp - mhp13) / mhp13)
                                graphics.color(npcHPColors.tier2)
                            end
                            if a.hp > (a.maxhp*(2/3)) then
                                graphics.alpha(1)
                                graphics.color(npcHPColors.tier2)
                                graphics.rectangle(hpX + currentX, hpY, hpX + currentX + (currentX - hpW), hpY + hpH)
                                hpW = t202min * (math.min(mhp13, mhp - (a.maxhp * (2/3))) / mhp13)
                                graphics.color(npcHPColors.tier3)
                            end
                        else
                            graphics.color(stat.color)
                        end
                        length = (actor:get(stat.current) / maxTotal) * (hpW * math.clamp((actor:get("percent_hp") or 1), 0, 1))
                        graphics.alpha(1)
                        graphics.rectangle(hpX + currentX, hpY, hpX + currentX + length, hpY + hpH)
                        currentX = currentX + length
                        
                    end
                end
                if actor:get("percent_hp") and actor:get("percent_hp") < 1 then --Draw Curse (if percent_hp is less than one, draw something to fill empty part of HP bar)
                    graphics.color(Color.WHITE)
                    graphics.alpha(0.5)
                    local curseW = hpW - (hpW * math.clamp(actor:get("percent_hp"), 0, 1))
                    local curseX = hpX + (hpW * math.clamp(actor:get("percent_hp"), 0, 1))
                    graphics.rectangle(curseX, hpY, curseX + curseW, hpY + hpH, true)
                end
            end
        end
    end
end

callback.register("onDraw", function()
    for _, actor in ipairs(actors:findAll()) do
        if actor and actor:isValid() and type(actor) ~= "PlayerInstance" then
            DrawNPCHP(actor)
        end
    end
end)

--Make it so that if an enemy gets hit while, for example, it has a shield, its HP bar will still display.
callback.register("onHit", function(damager, hit, x, y)
    if hit and hit:isValid() then
        if hit:getAlarm(6) == -1 then
            hit:setAlarm(6, 6*60)
        end
    end
end)
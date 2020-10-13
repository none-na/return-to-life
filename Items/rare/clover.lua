local OnHitItemFunctions = {
    --{item, value to set on damager, value to check on parent, chance (0 to 1), bonus proc chance per stack (0 to 1)}
    missile1 = {item = Item.find("AtG Missile Mk. 1", "vanilla"), damagerVar = "missile", parentVar = "missile", chance = 0.1, chanceBonus = 0.1},
    missile2 = {item = Item.find("AtG Missile Mk. 2", "vanilla"), damagerVar = "missile_tri", parentVar = "missile_tri", chance = 0.07, chanceBonus = 0.07},
    gloves = {item = Item.find("Boxing Gloves", "vanilla"), damagerVar = "knockback_glove", parentVar = "knockback", chance = 0.06, chanceBonus = 0.05},
    ifrit = {item = Item.find("Ifrit's Horn", "vanilla"), damagerVar = "horn", parentVar = "horn", chance = 0.08, chanceBonus = 0},
    spark = {item = Item.find("Legendary Spark", "vanilla"), damagerVar = "spark", parentVar = "spark", chance = 0.08, chanceBonus = 0},
    mortar = {item = Item.find("Mortar Tube", "vanilla"), damagerVar = "mortar", parentVar = "mortar", chance = 0.09, chanceBonus = 0},
    plasma = {item = Item.find("Plasma Chain", "vanilla"), damagerVar = "plasma", parentVar = "plasma", chance = 0.05, chanceBonus = 0}, 
    knife = {item = Item.find("Rusty Knife", "vanilla"), damagerVar = "bleed", parentVar = "bleed", chance = 0.15, chanceBonus = 0.15},
    sticky = {item = Item.find("Sticky Bomb", "vanilla"), damagerVar = "sticky", parentVar = "sticky", chance = 0.08, chanceBonus = 0},
    instakill = {item = Item.find("Telescopic Sight", "vanilla"), damagerVar = "scope", parentVar = "scope", chance = 0.01, chanceBonus = 0.005},
    thallium = {item = Item.find("Thallium", "vanilla"), damagerVar = "thallium", parentVar = "thallium", chance = 0.1, chanceBonus = 0},
    ukulele = {item = Item.find("Ukulele", "vanilla"), damagerVar = "lightning", parentVar = "lightning", chance = 0.2, chanceBonus = 0}, 
    nug = {item = Item.find("Meat Nugget", "vanilla"), damagerVar = "nugget", parentVar = "nugget", chance = 0.08, chanceBonus = 0},
    grenade = {item = Item.find("Concussion Grenade", "vanilla"), damagerVar = "stun_ef", parentVar = "", chance = 0.06, chanceBonus = 0.06},
    icecube = {item = Item.find("Permafrost", "vanilla"), damagerVar = "freeze", parentVar = "freeze", chance = 0.06, chanceBonus = 0.06},
    taser = {item = Item.find("Taser", "vanilla"), damagerVar = "taser", parentVar = "taser", chance = 0.07, chanceBonus = 0},
    fireRing = {item = Item.find("Kjaro's Band", "RoR2Demake"), damagerVar = "elementalRing", parentVar = "fireRing", chance = 0.08, chanceBonus = 0},
    iceRing = {item = Item.find("Runald's Band", "RoR2Demake"), damagerVar = "elementalRing", parentVar = "iceRing", chance = 0.08, chanceBonus = 0},
    meathook = {item = Item.find("Sentient Meat Hook", "RoR2Demake"), damagerVar = "meathook", parentVar = "meathook", chance = 0.2, chanceBonus = 0},
}

local onDeathItemFunctions = {
    --{item, the chance for the item to proc (0 to 1), the chance bonus per item (0 to 1), function to run upon proccing (passes in the player, the npc dying, and the coordinates of the npc on death)}
    willOwisp = {item = Item.find("Will-o'-the-wisp", "vanilla"), chance = 0.33, chanceBonus = 0, func = function(player, npc, x, y)
        local sound = Sound.find("BoarExplosion","vanilla")
        local pillarSpr = Sprite.find("EfPillar", "vanilla")
        sound:play()
        misc.shakeScreen(5)
        local count = player:countItem(Item.find("Will-o'-the-wisp", "vanilla"))
        local damage = 5 + (1 * ((count or 1) - 1))
        local lavaPillar = player:fireExplosion(x, y + (npc.sprite.height / 2), 1, 1, damage, pillarSpr, nil, DAMAGER_NO_PROC)
        lavaPillar:set("knockup", 5)
    end},
    otherClover = {item = Item.find("56 Leaf Clover", "vanilla"), chance = 0.04, chanceBonus = 0.015, func = function(player, npc, x, y)
        if npc:get("prefix_type") > 0 then
            local items = {ItemPool.find("common", "vanilla"), ItemPool.find("uncommon", "vanilla"), ItemPool.find("rare", "vanilla")}
            local command = Artifact.find("Command", "vanilla")
            local itemTier = table.random(items)
            if command.active ~= true then
                local itemToSpawn = itemTier:roll():getObject():create(x, y - (npc.sprite.height / 2))
            else
                local crateToSpawn = itemTier:getCrate():create(x, y)
            end
        end
    end}
}

-- NOTE: any items in miscItemFunctions MUST be coded separately from onDeath and onHitItemFunctions - they will NOT be triggered automatically.
local miscItemFunctions = {
    --{item, the chance for the item to proc (0 to 1), the chance bonus per item (0 to 1), function to run upon proccing (must pass in the player)}
    armsRace = {item = Item.find("Arms Race", "vanilla"), chance = 0.09, chanceBonus = 0.1, func = function(player, drone, x, y)
        local missile = Object.find("EfMissile", "vanilla")
        local mortar = Object.find("EfMortar", "vanilla")
        if math.random() <= 0.3 then
            local mortInst = mortar:create(x, y)
            mortInst:set("team", "playerproc")
            mortInst:set("damage", drone:get("damage") or 10)
        else
            for i=0, 1 do
                local missileInst = missile:create(x, y)
                missileInst:set("team", "playerproc")
                missileInst:set("damage", drone:get("damage") or 10)
            end
        end
    end},
    embryo = {item = Item.find("Beating Embryo", "vanilla"), chance = 0.3, chanceBonus = 0.3, func = function(player)
        
    end}
}


Clover = Item("57 Leaf Clover")
Clover.pickupText = "Luck is on your side."

Clover.sprite = restre.spriteLoad("Graphics/clover.png", 1, 16, 16)

local cloverSound = restre.soundLoad("clover","Sounds/SFX/clover.ogg")--Sound.find("Use", "vanilla")
local shamrock = ParticleType.new("shamrock")
shamrock:sprite(restre.spriteLoad("Graphics/shamrock", 1, 5, 5), false, false, false)
shamrock:angle(0, 360, 1, 0, true)
shamrock:direction(0, 360, 0, 0)
shamrock:speed(0.2, 0.2, 0, 0)
shamrock:alpha(0,1,0)
shamrock:life(60, 60)

Clover:setTier("rare")
Clover:setLog{
    group = "rare",
    description = "All random effects are rolled &g&+1 times&!& for a better outcome.",
    story = "DUDE. HOLY ****",
    destination = "777,\nLucky Drop,\nEarth",
    date = "7/7/2056"
}

local cloverVolume = 0.1

registercallback("onPlayerInit", function(player)
    player:set("luck", 0)
end)

Clover:addCallback("pickup", function(player)
    player:set("luck", player:get("luck") + 1)
end)

GlobalItem.items[Clover] = {
    apply = function(inst, count)
        inst:set("luck", (inst:get("luck") or 0) + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("luck", inst:get("luck") - count)
    end
}

IRL.setRemoval(Clover, function(player)
    adjust(player, "luck", -1)
end)

local CloverCheck = function(actor)
    local hasClover = false
    if actor ~= nil then
        if isa(actor, "PlayerInstance") then
            if actor:countItem(Clover) > 0 then
                hasClover = true
            end
        elseif isa(actor, "ActorInstance") then
            if GlobalItem.countItem(actor, Clover) then
                hasClover = true
            end
        end
    end
    return hasClover
end

local CloverFormula = function(procChance, cloverCount)
    return (1 - math.pow((1-procChance), (cloverCount + 1)))

end

local onHitReRoll = function(damager, damagerVar, parentVar, chance, chanceBonus, itemCount)
    local parent = damager:getParent()
    if CloverCheck(parent) then
        if type(parent) == "PlayerInstance" then
            if math.random() <= CloverFormula(chance + (chanceBonus * (itemCount - 1)), parent:countItem(Clover)) then
                cloverSound:play(0.8 + math.random()*0.2,cloverVolume)
                shamrock:burst("above", parent.x, parent.y, 1)
                damager:set(damagerVar, parent:get(parentVar) or 0)
            end

        elseif type(parent) == "ActorInstance" then
            if math.random() <= CloverFormula(chance + (chanceBonus * (itemCount - 1)),GlobalItem.countItem(parent, Clover)) then
                cloverSound:play(0.8 + math.random()*0.2, cloverVolume)
                shamrock:burst("above", parent.x, parent.y, 1)
                damager:set(damagerVar, parent:get(parentVar) or 0)
            end

        end
    end
end


registercallback("preHit", function(damager)
    local parent = damager:getParent()
    if parent then
        if damager:isValid() then
            if CloverCheck(parent) == true then
                if damager:get("critical") ~= 1 then
                    for i = 0, parent:get("luck") or 0 do
                        if (type(parent) == "PlayerInstance" and math.random() <= CloverFormula(parent:get("critical_chance")/100, parent:countItem(Clover))) or (type(parent) == "ActorInstance" and math.random() <= CloverFormula(parent:get("critical_chance")/100, GlobalItem.countItem(parent, Clover))) then
                            shamrock:burst("above", parent.x, parent.y, 1)
                            cloverSound:play(0.8 + math.random()*0.2, cloverVolume)
                            damager:set("critical", 1)
                            damager:set("damage", damager:get("damage") * 2)
                            damager:set("damage_fake", damager:get("damage_fake") * 2)
                            i = parent:get("luck")
                            break
                        end
                    end
                end
                --On Hit Items--
                for _, itemCheck in pairs(OnHitItemFunctions) do
                    if itemCheck.item ~= nil then
                        if (type(parent) == "PlayerInstance" and parent:countItem(itemCheck.item) > 0) or (type(parent) == "ActorInstance" and GlobalItem.countItem(parent, Clover) > 0) then
                            for i = 0, parent:get("luck") or 1 do
                                if damager:get(itemCheck.damagerVar) ~= itemCheck.parentVar then
                                    if type(parent) == "PlayerInstance" then
                                        onHitReRoll(damager, itemCheck.damagerVar, itemCheck.parentVar, itemCheck.chance, itemCheck.chanceBonus, parent:countItem(itemCheck.item))
                                    elseif type(parent) == "ActorInstance" then
                                        onHitReRoll(damager, itemCheck.damagerVar, itemCheck.parentVar, itemCheck.chance, itemCheck.chanceBonus, GlobalItem.countItem(parent, itemCheck))
                                    end
                                    i = parent:get("luck")
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)
-- On Death Items --
registercallback("onNPCDeathProc", function(npc, player)
    for _, itemCheck in pairs(onDeathItemFunctions) do
        if itemCheck.item ~= nil then
            if player:countItem(itemCheck.item) > 0 then
                for i = 0, player:get("luck") or 1 do
                    if CloverCheck(player) then
                        if (type(player) == "PlayerInstance" and math.random() <= CloverFormula((itemCheck.chance + (itemCheck.chanceBonus * (player:countItem(itemCheck.item) - 1))), player:countItem(Clover))) then
                            cloverSound:play(0.8 + math.random()*0.2,cloverVolume)
                            shamrock:burst("above", player.x, player.y, 1)
                            itemCheck.func(player, npc, npc.x, npc.y)
                            i = player:get("luck")
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- Arms Race --
local drones = { --Drones affected by Arms Race
    Object.find("Drone1", "vanilla"),
    Object.find("Drone2", "vanilla"),
    Object.find("Drone3", "vanilla"),
    Object.find("Drone5", "vanilla"),
    Object.find("Drone6", "vanilla"),
    Object.find("DroneDisp", "vanilla")
}

local findDroneMaster = function(droneInst)
    local master = nil
    for _, playerInst in ipairs(misc.players) do
        if playerInst.id == droneInst:get("master") then
            master = playerInst
        end
    end
    return master
end

registercallback("onStep", function()
    for _, droneType in ipairs(drones) do
        for _, droneInst in ipairs(droneType:findAll()) do
            local master = findDroneMaster(droneInst)
            local currentState = droneInst:get("state")
            if master:countItem(miscItemFunctions.armsRace.item) > 0 then
                if currentState ~= "idle" and math.round(droneInst.subimage) == 1 then
                    if math.random() <= CloverFormula(miscItemFunctions.armsRace.chance + (miscItemFunctions.armsRace.chanceBonus * (master:countItem(miscItemFunctions.armsRace.item) - 1)), master:countItem(Clover)) then
                        cloverSound:play(0.8 + math.random()*0.2, cloverVolume)
                        shamrock:burst("above", master.x, master.y, 1)
                        miscItemFunctions.armsRace.func(master, droneInst, droneInst.x, droneInst.y)
                    end
                end
            end
        end
    end
end)


export("Clover")
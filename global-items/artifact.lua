-- Enemies with Items artifact

local actors = ParentObject.find("actors", "vanilla")
local items = ParentObject.find("items", "vanilla")

local sprites = {
    artifact = Sprite.load("graphics/artifactSelect", 2, 18, 18),
    questionMark = Sprite.find("Random", "vanilla")
}

local tiers = {
    [0] = "common",
    [1] = "uncommon",
    [2] = "rare",
    [3] = "use",
}

local pools = {
    ["common"] = ItemPool.find("common"),
    ["uncommon"] = ItemPool.find("uncommon"),
    ["rare"] = ItemPool.find("rare"),
    ["use"] = ItemPool.find("use"),
}

local tierCosts = {
    ["common"] = 10,
    ["uncommon"] = 195,
    ["rare"] = 1000,
    ["use"] = 750,
}

local bannedEnemies = {
    [Object.find("WormBody", "vanilla")] = true,
    [Object.find("WormHead", "vanilla")] = true,
    [Object.find("WurmBody", "vanilla")] = true,
    [Object.find("WurmHead", "vanilla")] = true,
}

local bannedItems = {
    [Item.find("Barbed Wire", "vanilla")] = true,
    [Item.find("Bundle of Fireworks", "vanilla")] = true,
    [Item.find("Time Keeper's Secret", "vanilla")] = true,
}

local enigma = Artifact.find("Enigma", "vanilla")
local enigmaItem = Item.find("Artifact of Enigma", "vanilla")

local enemiesHaveItems = Artifact.new("Distribution")
enemiesHaveItems.displayName = "Distribution"
enemiesHaveItems.loadoutSprite = sprites.artifact
enemiesHaveItems.loadoutText = "Enemies can spawn with items."
enemiesHaveItems.unlocked = true
enemiesHaveItems.disabled = false

local SyncInventory = net.Packet.new("Sync Enemy Inventories", function(id, items, gold)
    local actor = Object.findInstance(id)
    if actor then
        local inventory = table.unpack(items)
        for _, item in ipairs(inventory) do
            local i = Item.find(item)
            if i then
                GlobalItem.addItem(actor, i, 1)
            end
        end
        actor:set("gold", gold)
    end
end)

callback.register("onActorInit", function(actor)
    if enemiesHaveItems.active then
        if actor:get("team") == "enemy" then
            if bannedEnemies[actor:getObject()] then return end
            if not GlobalItem.actorIsInit(actor) then
                GlobalItem.initActor(actor)
            end
            if net.host then
                local points = math.round(actor:get("point_value") * Difficulty.getScaling("cost"))
                local items = {}
                for i = 0, points do
                    local tier = tiers[math.random(0, 3)]
                    if actor:getData().equipment then
                        tier = tiers[math.random(0, 2)]
                    end
                    if points >= tierCosts[tier] then
                        local item = pools[tier]:roll()
                        if enigma.active and tier == 3 then item = enigmaItem end
                        GlobalItem.addItem(actor, item, 1)
                        items[#items] = item:getName()
                        points = math.max(points - tierCosts[tier], 0)
                        if #items >= misc.director:get("stages_passed") then break end
                        i = i + tierCosts[tier]
                    end
                end
                actor:set("gold", actor:get("gold") + (points * Difficulty.getScaling("cost")))
                if net.online then
                    SyncInventory:sendAsHost(net.ALL, nil, actor.id, table.pack(items), actor:get("gold"))
                end
            end
        end
    end
end)

---------------------------------------------------------------------


local enemiesPickupItems = Artifact.new("Equality")
enemiesPickupItems.displayName = "Equality"
enemiesPickupItems.loadoutSprite = sprites.artifact
enemiesPickupItems.loadoutText = "Enemies will attempt to pick up items and chests."
enemiesPickupItems.unlocked = true
enemiesPickupItems.disabled = false

local poi = Object.find("POI", "vanilla")

callback.register("onActorInit", function(actor)
    if enemiesHaveItems.active then
        if actor:get("team") == "enemy" then
            if bannedEnemies[actor:getObject()] then return end
            if not GlobalItem.actorIsInit(actor) then
                GlobalItem.initActor(actor)
            end
            actor:getData().pickupCooldown = -1
        end
    end
end)

callback.register("onStep", function()
    if enemiesPickupItems.active then
        for _, actor in pairs(actors:findAll()) do
            if actor and actor:isValid() then
                if actor:get("team") == "enemy" then
                    if GlobalItem.actorIsInit(actor) then
                        local data = actor:getData()
                        if data.pickupCooldown > -1 then
                            data.pickupCooldown = data.pickupCooldown - 1
                        end
                        -- Look for stray items
                        local nearest = items:findNearest(actor.x, actor.y)
                        if nearest and nearest:isValid() then
                            -- Find target
                            if actor:isClassic() and data.pickupCooldown <= -1 then
                                if Distance(actor.x, actor.y, nearest.x, nearest.y) <= 300 then 
                                    if nearest:get("used") ~= 1 and nearest:getAlarm(0) <= -1 then
                                        actor:set("target", nearest.id)
                                        actor:set("state", "chase")
                                        if Distance(actor.x, actor.y, nearest.x, nearest.y) <= 30 then
                                            if actor.x > nearest.x then
                                                actor:set("moveLeft", 1)
                                                actor:set("moveRight", 0)
                                            else
                                                actor:set("moveLeft", 0)
                                                actor:set("moveRight", 1)
                                            end

                                        end
                                    else
                                        local target = Object.findInstance(actor:get("target"))
                                        if type(target) ~= "PlayerInstance" then
                                            local p = poi:findNearest(actor.x, actor.y)
                                            if p then
                                                actor:set("target", p.id)
                                            end
                                        end
                                    end
                                end
                            end

                            -------------------------------------------------------------
                            if actor:collidesWith(nearest, actor.x, actor.y) then
                                if data.pickupCooldown <= -1 or data.forcePickup then
                                    if nearest:getAlarm(0) <= -1 and nearest:get("used") ~= 1 then
                                        nearest:set("used", 1)
                                        nearest:set("force_pickup", 1)
                                        nearest:set("owner", actor.id)
                                        if actor:get("target") == nearest.id then
                                            local p = poi:findNearest(actor.x, actor.y)
                                            if p then
                                                actor:set("target", p.id)
                                            end
                                        end
                                        local item = Item.fromObject(nearest:getObject())
                                        if item then
                                            if item.isUseItem then
                                                if data.equipment then
                                                    local e = data.equipment:create(actor.x, actor.y - (actor:getAnimation("idle").yorigin))
                                                    e:setAlarm(0, 2*60)
                                                end
                                            end
                                            GlobalItem.addItem(actor, item, 1)
                                        end
                                        data.pickupCooldown = 5*60
                                        data.forcePickup = false
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)


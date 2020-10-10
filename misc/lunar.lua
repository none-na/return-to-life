-- Lunar Items

---------------------------------------------------------------------------------------------------
-- Variable Command Center --

-- Lunar API --
LunarCoins = 0
local AddedItemPools = {}
LunarColor = Color.fromRGB(128, 142, 225)

-- Lunar Coins --
local coinUI = Sprite.load("Graphics/coinUI", 1, 2, 11)
local LunarCoinDropChance = 50 --The lower this value, the more likely enemies are to drop lunar coins.
local dropSound = Sound.find("Revive", "vanilla") -- The sound played when an enemy drops a Lunar Coin.

-- Lunar Pods --
local maximumBuds = 5 --The maximum amount of Lunar Pods that are able to be spawned on a stage.
local budChance = 5 --The lower this value, the more likely a Lunar Pod is going to spawn.
local budMessage = "&w&Press &y&'A'&w& to open the Lunar Pod."

-- Shrine of Order
local maximumShrines = 5 --The maximum amount of Shrines of Order that are able to be spawned on a stage.
local shrineChance = 30 --The lower this value, the more likely a Shrine of Order is going to spawn.
local shrineMessage = "&w&Press &y&'A'&w& to be sequenced."
local shrineUseText = "You have been... sequenced." --The text that appears upon using a Shrine of Order.
local vanillaItemPoolsToCheck = {
    ItemPool.find("common", "vanilla"),
    ItemPool.find("uncommon", "vanilla"),
    ItemPool.find("rare", "vanilla"),
    ItemPool.find("medcab", "vanilla"),
    ItemPool.find("gunchest", "vanilla"),

} --All Vanilla Item Pools affected by the shrine of order.


--Newt Altar / Blue Orb--
local orbTravelRadius = 10
local orbMovementDelay = 5
local maximumNewts = 3 --The maximum amount of Newt Altars that are able to be spawned on a stage.
local newtChance = 30 --The lower this value, the more likely a Shrine of Order is going to spawn.
local newtMessage = "&w&Press &y&'A'&w& to activate Newt Altar."
local newtAltarUseText = "A blue orb appears..." --The text that appears upon using a Newt Altar.

---------------------------------------------------------------------------------------------------

-- Load Lunar Coins on Game Start --
registercallback("onGameStart", function()
    LunarCoins = save.read("lunar_coins")
    for _, player in ipairs(misc.players) do
        Lunar.SetLunarCoins(player, LunarCoins)
    end
end, 10000)
registercallback("onStep", function()
    for _, player in ipairs(misc.players) do
        if player:isValid() then
            LunarCoins = player:get("lunar_coins")
        end
    end
end, 10000)


-- Debug Printing --
local debugSet = modloader.checkFlag("lunar_debug")
function debugPrint(...)
    if debugSet then print(...) end
end

-- Define Lunar Item Pool--
local lunar = ItemPool.new("Lunar")
lunar.ignoreEnigma = false

-- API Functions --
local lunar_items = {}
Lunar = {}

Lunar.register = function(item)
    lunar_items[item] = true
    lunar:add(item)
end

Lunar.register = function(item, notAddingToPool)
    lunar_items[item] = true
    if notAddingToPool ~= true then
        lunar:add(item)
    end
end

Lunar.GetLunarCoins = function(player)
    return player:get("lunar_coins") or 0
end

Lunar.SetLunarCoins = function(player, coins)
    player:set("lunar_coins", coins)
    if net.host == true then
        debugPrint("Lunar Items: Writing Lunar Coins to player's Save File.")
        save.write("lunar_coins", player:get("lunar_coins"))
        debugPrint("Lunar Items: Writing complete. "..player:get("lunar_coins").." Coin(s) saved.")
    end
end

Lunar.addItemPoolToOrder = function(itemPool, namespace)
    if isa(itemPool, "ItemPool") then
        if isa(namespace, "string") then
            --require(namespace)
            local newPool = ItemPool.find(itemPool:getName(), namespace)
            if newPool ~= nil then
                local poolTest = newPool:roll()
                if poolTest ~= nil then
                    if AddedItemPools[newPool] == nil then
                        local i = 0
                        for _, item in ipairs(newPool:toList()) do
                            i = i + 1
                        end
                        AddedItemPools[newPool] = newPool
                        print("Lunar Items: Successfully loaded ItemPool "..AddedItemPools[newPool]:getName().." from namespace "..namespace..". ("..i.." item(s) found)")
                    else
                        print("Lunar Items: ItemPool " .. newPool:getName() .. " has already been added.")
                    end
                end
            else
                print("Lunar Items: Could not find ItemPool "..itemPool:getName().." from namespace "..namespace..".")
            end
        else
            error("Lunar Items: Value namespace is not a string.")
        end
    else
        error("Lunar Items: Value itemPool is not an ItemPool.")
    end
end


-- Draw Lunar Coin count to HUD --
registercallback("onPlayerHUDDraw", function(playerInstance, x, y)
    if misc.hud:get("show_gold") == 1 then
        local x1, y1 = graphics.getGameResolution()
        local coins = Lunar.GetLunarCoins(playerInstance) or 0
        graphics.drawImage({
            coinUI,
            13,
            (Sprite.find("Money", "vanilla").height * 2) + 5
        })
        graphics.color(Color.WHITE)
        graphics.printColor(tostring(coins), 13 + coinUI.width, ((Sprite.find("Money", "vanilla").height * 2) - 1), graphics.FONT_MONEY)
        end
    
end)


-- Lunar Coin (item) --
local lunarCoin = Item.new("Lunar Coin")
lunarCoin.displayName = "Lunar Coin"
lunarCoin.pickupText = "A strange currency. Maybe you can use it somewhere...?"
lunarCoin.sprite = Sprite.load("coinTexture", "Items/lunarCoin", 1, 10, 10)
lunarCoin.color = LunarColor

lunarCoin:addCallback("pickup", function(player)
    Lunar.SetLunarCoins(player, Lunar.GetLunarCoins(player) + 1)
    player:removeItem(lunarCoin)
    LunarCoins = Lunar.GetLunarCoins(player)
end)

if not save.read("lunar_coins") then
    debugPrint("Lunar Items: Lunar Coin count has not been found on player's save file.")
    save.write("lunar_coins", 0)
end

registercallback("onPlayerInit", function(player)
    if net.host == true then
        debugPrint("Lunar Items: Reading player's Save File for Lunar Coins...")
        if save.read("lunar_coins") then
            Lunar.SetLunarCoins(player, save.read("lunar_coins"))
        end
    end
end)

registercallback("onMinuteChange", function()
    debugPrint("Lunar Items: Saving players' Lunar Coins to file...")
    for _, player in ipairs(misc.players) do
        if net.host then
            save.write("lunar_coins", Lunar.GetLunarCoins(player))
        end
    end
    debugPrint("Lunar Items: Save complete.")
end)

local CreateLunarCoin = net.Packet.new("Sync Lunar Coins", function(player, x, y)
    dropSound:play(1)
    lunarCoin:create(x, y)
end)

registercallback("onNPCDeath", function(actorInstance)
    if net.host then
        if math.random(0, LunarCoinDropChance) == 0 then
            dropSound:play(1)
            lunarCoin:create(actorInstance.x, actorInstance.y)
            if net.online then
                local x = actorInstance.x
                local y = actorInstance.y
                CreateLunarCoin:sendAsHost(net.ALL, nil, x, y)
            end
        end
    end
end)

--require("Libraries.mapObjectLib")
local MapObject = MapObject

-- Lunar Buds --
local lunarBudSmoke = ParticleType.find("Dust2", "vanilla")

local lunarBud = MapObject.new({
    name = "Lunar Bud",
    sprite = Sprite.load("budSprite", "Graphics/lunarBud", 5, 10, 8),
    baseCost = 1,
    currency = "lunar_coins",
    costIncrease = 1,
    affectedByDirector = false,
    affectPurchases = true,
    mask = Sprite.load("budMask", "Graphics/budMask", 4, 3, 11),
    useText = budMessage.." &y&(&$& Lunar)&!&",
    activeText = "&y&&$& LUNAR&!&",
    maxUses = 1,
    triggerFireworks = true,
})
local command = Artifact.find("Command", "vanilla")
local commandSprite = Sprite.load("commandCrate", "Graphics/commandCrate", 1, 8, 16)
lunarBud:addCallback("step", function(self)
    if self:isValid() and self:get("dead") ~= 1 then
        lunarBudSmoke:burst("below", self.x + math.random(-self.sprite.width / 4, self.sprite.width / 4), self.y, 1)
    end
end)

registercallback("onObjectActivated", function(objectInstance, frame, player, x, y)
    if objectInstance:getObject() == lunarBud then
        if frame == 1 then
            misc.shakeScreen(5)
            Sound.find("Chest0", "vanilla"):play(1)
            if command ~= nil and command.active == true then
                local crate = lunar:getCrate()
                crate.sprite = commandSprite
                crate:create(objectInstance.x, objectInstance.y)
            else
                local item = lunar:roll():getObject()
                item:create(objectInstance.x, objectInstance.y - 20)
            end
        end
        
    end
end)
registercallback("onObjectFailure", function(objectInstance, player)
    if objectInstance:getObject() == lunarBud then
        Sound.find("Error", "vanilla"):play(1)
    end
end)

-- Shop Buds --

local shopBud = MapObject.new({
    name = "Shop Bud",
    sprite = Sprite.load("budSprite2", "Graphics/shopBud", 5, 7, 4),
    baseCost = 2,
    currency = "lunar_coins",
    costIncrease = 1,
    affectedByDirector = false,
    affectPurchases = true,
    useYOff = -32,
    mask = Sprite.load("budMask2", "Graphics/shopBudMask", 1, 7, 16),
    useText = budMessage.." &y&(&$& Lunar)&!&",
    activeText = "&y&&$& LUNAR&!&",
    maxUses = 1,
    triggerFireworks = true,
})

shopBud:addCallback("create", function(self)
    if not command.active then
        self:set("f", 0)
        local data = self:getData()
        data.item = lunar:roll()
        self:set("useText", ("&w&Press &y&'A'&w& to purchase "..data.item:getName().."&y&(&$& Lunar)"))
    end
end)
shopBud:addCallback("draw", function(self)
    local data = self:getData()
    self:set("f", (self:get("f") + 0.05) % (2*math.pi))
    if self:get("dead") ~= 1 then
        if data.item then
            graphics.drawImage{
                image = data.item.sprite,
                scale = 1,
                alpha = 0.75,
                x = self.x,
                y = self.y - (self.sprite.height + (math.cos(self:get("f"))) + 16)
            }
        end
    end
end)

registercallback("onObjectActivated", function(objectInstance, frame, player, x, y)
    if objectInstance:getObject() == shopBud then
        if frame == 1 then
            misc.shakeScreen(5)
            Sound.find("Chest0", "vanilla"):play(1)
            if command ~= nil and command.active == true then
                local crate = lunar:getCrate()
                crate.sprite = commandSprite
                crate:create(objectInstance.x, objectInstance.y)
            else
                local data = objectInstance:getData()
                local item = data.item
                item:create(objectInstance.x, objectInstance.y - 20)
            end
        end
    end
end)
registercallback("onObjectFailure", function(objectInstance, player)
    if objectInstance:getObject() == shopBud then
        Sound.find("Error", "vanilla"):play(1)
    end
end)

-- Shrine of Order --

local orderShrine = MapObject.new({
    name = "Shrine of Order",
    sprite = Sprite.load("orderShrine", "Graphics/orderShrine", 6, 10, 22),
    baseCost = 1,
    currency = "lunar_coins",
    costIncrease = 1,
    affectedByDirector = false,
    mask = Sprite.load("shrineMask", "Graphics/shrineMask", 1, 10, 22),
    useText = shrineMessage.." &y&(&$& Lunar)&!&",
    activeText = "&y&&$& LUNAR&!&",
    maxUses = 1,
    triggerFireworks = true,
})
local shrineActivationSound = Sound.find("Shrine1", "vanilla")
local function ActivateShrineOfOrder(player)
    debugPrint("==============================================")
    local allItemPools = {}

    --Add Vanilla Items to the items the Shrine can affect--
    for _, itemPool in ipairs(vanillaItemPoolsToCheck) do
        allItemPools[itemPool] = itemPool
        debugPrint("Added ItemPool "..itemPool:getName().." to list.")
    end
    --Add Custom Item Pools to the items the shrine can affect--
    for _, itemPool in ipairs(AddedItemPools) do
        allItemPools[itemPool] = itemPool
        debugPrint("Added ItemPool "..itemPool:getName().." to list.")
    end
    local tierCounts = {}
    --Prepare itemPool counts--
    for _, pool in pairs(allItemPools) do
        tierCounts[pool] = 0
        debugPrint("Prepared tierCounts slot for ItemPool "..pool:getName()..".")
    end
    -- Vanilla Items --
    for _, tier in pairs(allItemPools) do
        local playerItems = {}
        debugPrint("Beginning check of ".. tier:getName() .. " ItemPool.")
        local items = {}
        for _, item in pairs(tier:toList()) do
            if player:countItem(item) > 0 then
                debugPrint("Found "..player:countItem(item) .. " of ".. item.displayName .. "!")
                if playerItems[item] == nil then
                    playerItems[item] = item
                    tierCounts[tier] = tierCounts[tier] + player:countItem(item)
                    debugPrint(tier:getName().." Tier Count is now at ".. tierCounts[tier] ..".")
                    local removalFunc = itemremover.getRemoval(item)
                    if removalFunc then
                        for i = 1, player:countItem(item) do
                            itemremover.removeItem(player, item, true)
                        end
                    end
                else
                    debugPrint("Item "..item.displayName .. " has been detected in one or more Item Pools, and has already been checked, counted, and added to item selection pool. Ignoring current instance.")
                end
                
            end
        end
        debugPrint("Completed looking through player items. Now adding to item pool for random selecting.")    
        for _, item in pairs(playerItems) do
            items[item] = item
            debugPrint(item.displayName .. " added to pool for selecting.")
        end
        local itemToGive = table.random(items)
        if itemToGive ~= nil then
            debugPrint("Returning item "..itemToGive.displayName.." ()")
            player:giveItem(itemToGive, tierCounts[tier])
        else
            debugPrint("Item returned nil. Sad.")
        end
    end
    debugPrint("Shrine of Order process complete!")
end
registercallback("onObjectActivated", function(objectInstance, frame, player, x, y)
    if objectInstance:getObject() == orderShrine then
        if frame == 1 then
            shrineActivationSound:play(1 + math.random() * 0.01)
            ActivateShrineOfOrder(player)
            misc.shakeScreen(5)
        end
    end
end)
registercallback("onObjectFailure", function(objectInstance, player)
    if objectInstance:getObject() == orderShrine then
        Sound.find("Error", "vanilla"):play(1 + math.random() * 0.2)
    end
end)

local players = ParentObject.find("actors", "vanilla")

-- Newt Altar --

local altarSprites = {
    idle = Sprite.load("newtAltar", "Graphics/newtAltar", 6, 10, 8),
    make = Sprite.load("newtAltarMask", "Graphics/newtMask", 1, 10, 8),
}


local teleporter = Object.find("Teleporter", "vanilla")
local newtAltar = Object.base("mapobject", "Newt Altar")
newtAltar.sprite = altarSprites.idle

newtAltar:addCallback("create", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    self.active = 0
    self.cost = 1
    this.spriteSpeed = 0
    data.orbMessageAlpha = 0
    data.orbMessage = newtAltarUseText
    data.prompt = newtMessage
    data.showText = false


end)
newtAltar:addCallback("step", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    --------------------------
    local tp = teleporter:find(1)
    if self.active ~= 2 and (tp and tp:isValid()) then
        if tp:get("active") > 0 then
            self.active = 2
            return
        end
    end
    --------------------------
    if data.orbMessageAlpha > 0 then
        data.orbMessageAlpha = data.orbMessageAlpha - 0.01
    end
    --------------------------
    if self.active == 0 then --awaiting input
        this.subimage = 1
        local nearest = players:findNearest(this.x, this.y)
        if nearest and nearest:isValid() then
            if this:collidesWith(nearest, this.x, this.y) then
                data.showText = true
                if input.checkControl("enter", nearest) == input.PRESSED then
                    if nearest:get("lunar_coins") and nearest:get("lunar_coins") >= self.cost then
                        shrineActivationSound:play()
                        Lunar.SetLunarCoins(nearest, Lunar.GetLunarCoins(nearest) - self.cost)
                        self.active = 1
                        misc.shakeScreen(5)
                        local o, p = MakeOrb("blue")
                        this.spriteSpeed = 0.2
                        data.orbMessageAlpha = 3
                    else
                        Sound.find("Error", "vanilla"):play()

                    end
                end
            else
                data.showText = false
            end
        end
    elseif self.active == 1 then --doing shit
        if math.floor(this.subimage) >= 6 then
            self.active = 2
            this.spriteSpeed = 0
        end

    elseif self.active == 2 then --inactive / used
        this.subimage = 6

    end
end)
newtAltar:addCallback("draw", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    if self.active == 0 then --awaiting input
        if data.showText then
            graphics.alpha(1)
            graphics.printColor("&w&"..data.prompt.."&!&", this.x - (graphics.textWidth(data.prompt, graphics.FONT_DEFAULT) / 2), this.y - 32, graphics.FONT_DEFAULT)
        end
        graphics.alpha(0.7+(math.random()*0.15))
        graphics.color(LunarColor)
        graphics.print(self.cost .." LUNAR", this.x, this.y + 16, NewDamageFont, graphics.ALIGN_MIDDLE, graphics.ALIGN_CENTER)
    end
    graphics.alpha(math.clamp(data.orbMessageAlpha, 0, 1))
    graphics.printColor("&w&"..data.orbMessage.."&!&", this.x - (graphics.textWidth(data.orbMessage, graphics.FONT_DEFAULT) / 2), this.y - 32, graphics.FONT_DEFAULT)
end)

-- Spawn Spawnable Objects --
if not modloader.checkFlag("disable_lunar_pods") then 
    local pod = Interactable.new(lunarBud, "lunar_pod")
    pod.spawnCost = 100
    for _, stage in ipairs(Stage.findAll("vanilla")) do
        stage.interactables:add(pod)
    end
end
if not modloader.checkFlag("disable_shrine_of_order") then 
    local order = Interactable.new(orderShrine, "shrine_order")
    order.spawnCost = 500
    for _, stage in ipairs(Stage.findAll("vanilla")) do
        stage.interactables:add(order)
    end
end
-- Lunar Item Registry / Handler --

registercallback("onItemInit", function(instance)
    if lunar_items[instance:getItem()] == true then
        instance:set("lunar", 1)
        instance:set("pickupTimer", 10)
    end
end)

local itemPO = ParentObject.find("items")

local touching = {}

registercallback("onStep", function()
    for _, inst in ipairs(itemPO:findMatching("lunar", 1)) do
        -- Disables normal pickups
        inst:setAlarm(0, 10)
        if inst:get("pickupTimer") > 0 then
            inst:set("pickupTimer", inst:get("pickupTimer") - 1)
        end
        -- Track if the item is being touched
        touching[inst] = nil
        if inst:get("used") == 0 then -- Don't allow pickups if already picked up
            for _, player in ipairs(misc.players) do
                if inst:collidesWith(player, inst.x, inst.y) and inst:get("pickupTimer") <= 0 then
                    if input.checkControl("enter", player) == input.PRESSED then
                        if inst:get("is_use") == 1 then
                            if player.useItem ~= nil then
                                local item = player.useItem
                                item:create(inst.x, inst.y)
                            end
                            player.useItem = inst:getItem()

                        else
                            player:giveItem(inst:getItem())
                        end
                        inst:set("used", 1)
                        break
                    else
                        -- This makes sure the correct button for pickup is displayed in the pickup text
                        touching[inst] = player
                    end
                end
            end
        end
    end
end)

--------------------------------------


local MakeBlueOrb = function()
    local orb, portal = MakeOrb("blue")
    for _, altar in ipairs(newtAltar:findAll()) do
        altar:set("active", 2)
    end
end

local SyncRandomOrb = net.Packet.new("Sync RNG Orb", MakeBlueOrb)


callback.register("onStageEntry", function()
    if net.host then
        if math.random() < 0.25 then
            MakeBlueOrb()
            if net.online then
                SyncRandomOrb:sendAsHost(net.ALL, nil)
            end
        end
    end
end)



--------------------------------------

local obliterate = Sound.load("Obliterate", "Sounds/SFX/eradicate.ogg")
local obliterationFX = ParticleType.new("eradication")
obliterationFX:shape("square")
obliterationFX:color(Color.WHITE, Color.AQUA)
obliterationFX:additive(true)
obliterationFX:scale(0.1, 0.1)
obliterationFX:size(1, 1, -0.01, 0)
obliterationFX:angle(0, 360, 0, 0, false)
obliterationFX:direction(0, 360, 0, 0)
obliterationFX:speed(0.4, 0.9, -0.01, 0)

local corpse = Object.find("EfPlayerDead", "vanilla")
local messages = 23
local obliterationMessages = {
    [0] = "FATE UNKNOWN.",
    [1] = "FATE UNKNOWN.",
    [2] = "FATE UNKNOWN.",
    [3] = "FATE UNKNOWN.",
    [4] = "FATE UNKNOWN.",
    [5] = "FATE UNKNOWN.",
    [6] = "FATE UNKNOWN.",
    [7] = "FATE UNKNOWN.",
    [8] = "FATE UNKNOWN.",
    [9] = "FATE UNKNOWN.",
    [10] = "FATE UNKNOWN.",
    [11] = "YOU NO LONGER EXIST.",
    [12] = "OBLITERATED.",
    [13] = "...",
    [14] = "YOUR FAMILY WILL HAVE NEVER KNOWN YOU EXISTED.",
    [15] = "QUICK AND PAINLESS.",
    [16] = "F",
    [17] = "NOT A HAIR NOR HIDE TO BE FOUND.",
    [18] = "FAREWELL.",
    [19] = "YOU WILL NOT BE MISSED.",
    [20] = "F**K MAN, FU-",
    [21] = "YOU'LL NEVER PAY OFF THAT MORTGAGE.",
    [22] = "YOU BECOME ONE WITH THE VOID.",
    [23] = "YOU ARE OVERWHELMED BY THE WEIGHT OF YOUR SINS.",
}


callback.register("onStep", function()
    for _, body in ipairs(corpse:findAll()) do
        local b = body:getAccessor()
        local nearest = Object.find("P", "vanilla"):findNearest(b.x, b.y)
        if nearest and nearest:get("eradicate") and nearest:get("eradicate") > 0 then
            if not b.obliterated then
                b.vspeed = 0
                b.hspeed = 0
                body.sprite = Sprite.find("Empty")
                obliterate:play(0.9 + math.random() * 0.1)
                for i = 0, math.random(10, 30) do
                    obliterationFX:burst("above", body.x, body.y, 1)
                end
                b.death_message = obliterationMessages[math.random(messages)]
                b.obliterated = 1
            end
        end
    end
end)

callback.register("onPlayerStep", function(player)
    if input.checkKeyboard("q") == input.PRESSED then
        player:set("eradicate", 1)
    end
end)

registercallback("onDraw", function()
    for _, inst in ipairs(itemPO:findMatching("lunar", 1)) do
        if touching[inst] then
            graphics.color(Color.WHITE)
            graphics.printColor("Press &y&'A'&!& to pick up.", math.floor(inst.x + 0.5 - 56), math.floor(inst.y + 0.5) + 40)
        end
    end
end)


-- Items --
require("Items.lunarItems")

--Add Lunar Pool to Shrine of Order--
registercallback("postLoad", function()
    Lunar.addItemPoolToOrder(lunar, "RoR2Demake")
end)

--Exports
export("LunarCoins")
export("LunarColor")
export("Lunar")

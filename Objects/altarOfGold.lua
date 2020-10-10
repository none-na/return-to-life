--altarOfGold.lua

local sprites = {
    idle = Sprite.load("goldShrine", "Graphics/shrineGold", 6, 22, 59),
    mask = Sprite.load("goldMask", "Graphics/mountainMask", 1, 16, 26),
    portal = Sprite.load("Graphics/goldPortal", 4, 5, 27),
    orb = Sprite.load("Graphics/goldOrb", 1, 1.5, 1.5)
}
local MapObject = require("Libraries.mapObjectLib")
local PopUpText = require("Misc.popupText")
local Portal = require("Misc.portal")
local teleporter = Object.find("Teleporter", "vanilla")


local goldShrine = MapObject.new({
    name = "Altar of Gold",
    sprite = sprites.idle,
    baseCost = 100,
    currency = "gold",
    costIncrease = 0,
    affectedByDirector = true,
    mask = sprites.mask,
    useText = "&w&Press &y&'A'&w& to offer to the Altar of Gold &y&($&$&)&!&",
    activeText = "&y& $&$& &!&",
    maxUses = 1,
    triggerFireworks = true,
})

local goldOrb, goldPortal = Portal.new({
    prefix = "Gold",
    portalSprite = sprites.portal,
    orbSprite = sprites.orb
})


goldShrine:addCallback("step", function(self)
    local data = self:getData()
end)

local goldText = PopUpText.new("A gold orb appears...", 60*3, 5)

registercallback("onObjectActivated", function(objectInstance, frame, player, x, y)
    if objectInstance:getObject() == goldShrine then
        if frame == 1 then
            local findTeleporter = teleporter:findNearest(objectInstance.x, objectInstance.y)
            Sound.find("Shrine1","vanilla"):play(1 + math.random() * 0.01)
            misc.shakeScreen(5)
            if findTeleporter ~= nil then
                goldOrb:create(findTeleporter.x, findTeleporter.y - (findTeleporter.sprite.height) / 2)
            end
            PopUpText.create(goldText, x, y)
        end
    end
end)
registercallback("onObjectFailure", function(objectInstance, player)
    if objectInstance:getObject() == goldShrine then
        Sound.find("Error", "vanilla"):play(1)
    end
end)

MapObject.SpawnNaturally(goldShrine, {
    spawnChance = 25,
    maxAmount = 1
})
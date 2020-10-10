--RoR2 Demake Project
--Made by Sivelos
--combatShrine.lua
--File created 2019/08/12

require("Libraries.mapObjectLib")
local MapObject = MapObject
require("Misc.popupText")
local PopUpText = PopUpText

local enemies = {
    vagrant = {object = Object.find("GiantJelly", "vanilla"), prefix = {0, 1}, elite = {0, 1, 2, 3, 4}},
    colossus = {object = Object.find("GolemG", "vanilla"), prefix = {0, 1}, elite = {0, 1, 2, 3, 4}},
    worm = {object = Object.find("Worm", "vanilla"), prefix = {0, 1}, elite = {3}},
    wisp = {object = Object.find("WispB", "vanilla"), prefix = {0, 1}, elite = {0, 1, 2, 3, 4}},
    boar = {object = Object.find("Boar", "vanilla"), prefix = {0, 1}, elite = {0, 1, 2, 3, 4}},
    impG = {object = Object.find("ImpG", "vanilla"), prefix = {0, 1, 2}, elite = {0, 1, 2, 3, 4}},
    cremator = {object = Object.find("Turtle", "vanilla"), prefix = {0}, elite = {0}},
    ifrit = {object = Object.find("Ifrit", "vanilla"), prefix = {0, 1}, elite = {0, 1, 2, 3, 4}},
    scavenger = {object = Object.find("Scavenger", "vanilla"), prefix = {0, 1, 2}, elite = {0, 1, 2, 3, 4}},
}

local enemiesByStage = {
    ["Dried Lake"] = {enemies.vagrant, enemies.colossus, enemies.worm, enemies.scavenger},
    ["Ancient Valley"] = {enemies.impG, enemies.colossus, enemies.ifrit, enemies.scavenger},
    ["Desolate Forest"] = {enemies.vagrant, enemies.colossus, enemies.worm, enemies.scavenger},
    ["Damp Caverns"] = {enemies.wisp, enemies.worm, enemies.scavenger},
    ["Hive Cluster"] = {enemies.boar, enemies.impG, enemies.scavenger},
    ["Sky Meadow"] = {enemies.vagrant, enemies.colossus, enemies.worm, enemies.wisp, enemies.scavenger},
    ["Sunken Tomb"] = {enemies.vagrant, enemies.colossus, enemies.impG, enemies.scavenger},
    ["Magma Barracks"] = {enemies.boar, enemies.cremator, enemies.scavenger},
    ["Temple of the Elders"] = {enemies.boar, enemies.impG, enemies.scavenger},
}

local sprites = {
    idle = Sprite.load("combatShrine", "Graphics/combatShrine", 7, 16, 26),
    mask = Sprite.load("combatMask", "Graphics/combatShrineMask", 1, 16, 26),
}


registercallback("onStageEntry", function()
    local director = misc.director
    local data = director:getData()
    data.mountainActivated = 0
    data.extraBossesSpawned = false
end)

local combatShrine = MapObject.new({
    name = "Shrine of Combat",
    sprite = sprites.idle,
    baseCost = 0,
    currency = "gold",
    costIncrease = 0,
    affectedByDirector = false,
    mask = sprites.mask,
    useText = "&w&Press &y&'A'&w& to pray to the Shrine of Combat&!&",
    activeText = "",
    maxUses = 1,
    triggerFireworks = true,
})
registercallback("onObjectActivated", function(objectInstance, frame, player, x, y)
    if objectInstance:getObject() == combatShrine then
        if frame == 1 then
            Sound.find("Shrine1", "vanilla"):play(1 + math.random() * 0.01)
            misc.shakeScreen(5)
        end
    end
end)

-- Bazaar Between Time

local sprites = {
    tileset = Sprite.load("TileBazaar", "Graphics/tiles/bazaar between time", 1, 0, 0)
}

local bazaar = require("Stages.rooms.bazaar")
bazaar.displayName = "Bazaar Between Time"
bazaar.subname = "Hidden Realm"
bazaar.music = Music.Parjanya

------------------------------------

local room = bazaar.rooms[1]

local objects = {
    newt = Object.find("Newt", "RoR2Demake"),
    shopBud = Object.find("Shop Bud", "RTSCore"),
    artificer = Object.find("mageLocked", "RoR2Demake"),
    teleporter = Object.find("Teleporter", "vanilla"),
    teleporterFake = Object.find("TeleporterFake", "vanilla")
}

local artiAchieve = Achievement.find("Pause", "RoR2Demake")

local spark = ParticleType.find("Sparks", "RTSCore")

local bazaarManager = Object.new("BazaarManager")

bazaarManager:addCallback("create", function(this)
    local data = this:getData()
    data.initBazaar = false
    data.newt = objects.newt:create(78.5 * 16, 23*16)
    data.newt.y = FindGround(data.newt.x, data.newt.y)
    data.exit = MakePortal("blue", 12*16, 13*16)
    data.exit:getData().destination = nil
    for i = 1, 4 do
        local xx = 909
        local yy = 384
        local s = objects.shopBud:create(xx + (48 * (i-1)), yy)
    end
    data.exit:getData().rate = 1
    if not artiAchieve:isComplete() then
        local a = objects.artificer:create(75*16, 23*16)
    end
    local null = MakePortal("null", 49*16, 64*16)
end)

bazaarManager:addCallback("step", function(this)
    local data = this:getData()
    if math.random(100) < 5 then
        spark:burst("middle", math.random(0, 745), math.random(0, 410), 1, Color.AQUA)
    end
    if not data.initBazaar then
        for _, p in ipairs(misc.players) do
            p.x = 15*16
            p.y = 12.5*16
            p:set("ghost_x", p.x)
            p:set("ghost_y", p.y)
        end
        for _, t in ipairs(objects.teleporter:findAll()) do
            t:destroy()
        end
        for _, t in ipairs(objects.teleporterFake:findAll()) do
            t:destroy()
        end
        data.initBazaar = true
    end
end)

callback.register("globalRoomStart", function(r)
    if r == room then
        local m = bazaarManager:create(0, 0)
    end
end)



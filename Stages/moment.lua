

local sprites = {
    fractureTiles = Sprite.load("TileEmpty1", "Graphics/tiles/A Moment Fractured", 1, 0, 0),
    wholeTiles = Sprite.load("TileEmpty2", "Graphics/tiles/A Moment Whole", 1, 0, 0),
    wholeBG = Sprite.load("WhiteNoise", "Graphics/backgrounds/aMomentWhole", 1, 0, 0),
}

-- A Moment, Fractured

local fractured = require("Stages.rooms.fractured")
fractured.displayName = "A Moment, Fractured"
fractured.music = Music.PetrichorV

--------------------------------

-- A Moment, Whole

local whole = require("Stages.rooms.whole")
whole.displayName = "A Moment, Whole"
whole.music = Music.PetrichorV


--------------------------------


local objects = {
    teleporter = Object.find("Teleporter", "vanilla"),
    teleporterFake = Object.find("TeleporterFake", "vanilla"),
    twistedScav = Object.find("ScavengerLunar", "RoR2Demake"),
    whiteFlash = Object.find("WhiteFlash", "vanilla")
}

local momentManager = Object.new("MomentManager")

momentManager:addCallback("create", function(this)
    local data = this:getData()
    data.init = false
    data.scav = false
end)

momentManager:addCallback("step", function(this)
    local data = this:getData()
    local stage = 0
    if Stage.getCurrentStage() == whole then
        stage = 1
    end
    if not data.init then
        for _, p in ipairs(misc.players) do
            if stage == 1 then
                p.x = 454
                p.y = 586
            else
                p.x = 377
                p.y = 426
            end
            p:set("ghost_x", p.x)
            p:set("ghost_y", p.y)
        end
        for _, t in ipairs(objects.teleporter:findAll()) do
            t:destroy()
        end
        for _, t in ipairs(objects.teleporterFake:findAll()) do
            t:destroy()
        end
        data.init = true
    end
    if stage == 0 then
        this:destroy()
        return
    else
        if not data.scav then
            for _, p in ipairs(misc.players) do
                if p.x > 800 then
                    local s = objects.twistedScav:create(1200, 586)
                    local f = objects.whiteFlash:create(p.x, p.y)
                    data.scav = true
                    break
                end
            end
        end

    end
end)

callback.register("onStageEntry", function()
    if Stage.getCurrentStage() == whole or Stage.getCurrentStage() == fractured then
        local m = momentManager:create(0, 0)
    else
        if misc.director:get("stages_passed") % 7 == 0 and misc.director:get("stages_passed") > 0 then
            local o, p = MakeOrb("celestial")
        end
    end
end)
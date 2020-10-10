-- Siren's Call

local sprites = {
    tileset = Sprite.load("TileWisp", "Graphics/tiles/scorched acres", 1, 0, 0),
}

local acres = require("Stages.rooms.acres")
acres.displayName = "Scorched Acres"
acres.subname = "Wisp Instillation"
acres.music = Music.Disdrometer
acres.teleporterIndex = 5

Stage.progression[3]:add(acres)

------------------------------------
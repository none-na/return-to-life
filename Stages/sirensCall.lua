-- Siren's Call

local sprites = {
    tileset = Sprite.load("TileShip", "Graphics/tiles/Sirens Call", 1, 0, 0),
    tileset2 = Sprite.load("TileShip2", "Graphics/tiles/Sirens Call 2", 1, 0, 0),
    tileset3 = Sprite.load("TileShipBG", "Graphics/tiles/shipBG", 1, 0, 0),
    tileset4 = Sprite.load("TileShip3", "Graphics/tiles/Sirens Call 3", 1, 0, 0),
}

local sirensCall = require("Stages.rooms.sirensCall")
sirensCall.displayName = "Siren's Call"
sirensCall.subname = "Ship Graveyard"
sirensCall.music = Music.RaindropThatFellToTheSky
sirensCall.teleporterIndex = 6

Stage.progression[5]:add(sirensCall)

------------------------------------

sirensCall.enemies:add(MonsterCard.find("Solus Control Unit", "RoR2Demake"))
sirensCall.enemies:add(MonsterCard.find("Brass Contraption", "RoR2Demake"))
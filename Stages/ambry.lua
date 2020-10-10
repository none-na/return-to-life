-- Bulwark's Ambry

local sprites = {
    tileset = Sprite.load("TileEmpyrean", "Graphics/tiles/empyrean", 1, 0, 0),
}

local ambry = require("Stages.rooms.ambry")
ambry.displayName = "Bulwark's Ambry"
ambry.subname = "Hidden Realm"
ambry.music = Music.IntoTheDoldrums

------------------------------------

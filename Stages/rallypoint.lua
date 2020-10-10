-- Rallypoint Delta

local sprites = {
    tileset = Sprite.load("TileBase", "Graphics/tiles/rallypoint delta", 1, 0, 0),
    bg1 = Sprite.load("snowBG", "Graphics/backgrounds/snowBG", 1, 0, 0),
    bg2 = Sprite.load("snowRuins", "Graphics/backgrounds/snowRuins", 1, 0, 0),
}

local rallypoint = require("Stages.rooms.rallypoint")
rallypoint.displayName = "Rallypoint Delta"
rallypoint.subname = "UES Contact Light Survivor Camp"
rallypoint.music = Music.IntoTheDoldrums

Stage.progression[3]:add(rallypoint)

------------------------------------
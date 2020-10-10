-- Abandoned Aqueduct

local sprites = {
    tileset = Sprite.load("TileAqueduct", "Graphics/tiles/Abandoned Aqueduct", 1, 0, 0),
    pin1 = Sprite.load("AqueductPin1", "Graphics/backgrounds/aqueductBGA", 1, 0, 0),
    pin2 = Sprite.load("AqueductPin2", "Graphics/backgrounds/aqueductBGB", 1, 0, 0),
    pin3 = Sprite.load("AqueductPin3", "Graphics/backgrounds/aqueductBGC", 1, 0, 0),
    dunes = Sprite.load("AqueductDunes", "Graphics/backgrounds/aqueductBGD", 1, 0, 0),
    sun = Sprite.load("AqueductSun", "Graphics/backgrounds/aqueductBGE", 1, 0, 0),
    sky = Sprite.load("AqueductSky", "Graphics/backgrounds/aqueductBGF", 1, 0, 0),
    
}

local aqueduct = require("Stages.rooms.aqueduct")
aqueduct.displayName = "Abandoned Aqueduct"
aqueduct.subname = "Origin of Tar"
aqueduct.music = Music.TerraPluviam

------------------------------------
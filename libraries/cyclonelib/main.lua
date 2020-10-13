-- CycloneLib - main.lua

-- Dependencies:
---- Nothing

local restre_key
if (not restre) or (not restre.valid()) then
    restre_key = require("cyclonelib/libraries/restre")()
    restre.cd("cyclonelib/", "main")
end

restre.require("contents/table")
restre.require("contents/collision/collision")
restre.require("contents/misc")
restre.require("contents/modloader")
restre.require("contents/font")
restre.require("contents/player")
restre.require("contents/list")
restre.require("contents/string")
restre.require("contents/net")
restre.require("contents/graphics")

restre.require("contents/Projectile")
restre.require("contents/MapObject")

restre.require("contents/classes/Class")
restre.require("contents/classes/Rectangle")
restre.require("contents/classes/Vector2")

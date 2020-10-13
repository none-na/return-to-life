-- CycloneLib - main.lua

-- Dependencies:
---- Nothing

local restre_key
if (not restre) or (not restre.valid()) then
    restre_key = require("cyclonelib/libraries/restre")()
    restre.cd("cyclonelib/", "main")
end

restre_require("contents/table")
restre_require("contents/collision/collision")
restre_require("contents/misc")
restre_require("contents/modloader")
restre_require("contents/font")
restre_require("contents/player")
restre_require("contents/list")
restre_require("contents/string")
restre_require("contents/net")

restre_require("contents/Projectile")

restre_require("contents/classes/Class")
restre_require("contents/classes/Rectangle")
restre_require("contents/classes/Vector2")

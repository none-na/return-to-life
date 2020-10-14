-- Return to Life

local restre_key
if (not restre) or (not restre.valid()) then
    restre_key = require("restre")()
    restre.cd(nil, "main")
end

restre.require("libraries/cyclonelib/main")
restre.require("libraries/util")

restre.require("misc/title_screen/title_screen")
restre.require("misc/teleporter_effects/teleporter_effects")
restre.require("misc/flight_manager")
restre.require("misc/lunar/lunar")

restre.require("global-items/main")
restre.require("Items/itemLoader")

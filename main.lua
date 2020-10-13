-- Return to Life

local restre_key
if (not restre) or (not restre.valid()) then
    restre_key = require("restre")()
    restre.cd(nil, "main")
end

restre_require("misc/title_screen/title_screen")
restre_require("misc/teleporter_effects/teleporter_effects")
restre_require("misc/flight_manager")
restre_require("misc/lunar/lunar")

restre_require("global-items/main")
restre_require("Items/itemLoader")

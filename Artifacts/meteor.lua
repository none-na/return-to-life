local summonMeteors = Artifact.new("Radiance")
-- Make the artifact be unlocked by default
summonMeteors.unlocked = true


-- Set the artifact's loadout info
summonMeteors.loadoutSprite = Sprite.load("Artifacts/meteor", 2, 18, 18)
summonMeteors.loadoutText = "Meteor showers bombard the planet every 30 seconds."

local meteor = Object.find("EfMeteorShower", "vanilla")
local count = 0

callback.register("postStep", function()
    if summonMeteors.active then
        if misc.getTimeStop() <= 0 then
            count = count + 1
            if count % 1800 == 0 then
                meteor:create(0, 0)
            end
        end
    end
end)
local Wisp = Object.find("Wisp", "vanilla")

local oldSprites = {
    "WispIdle",
    "WispSpawn",
    "WispShoot1",
    "WispDeath",
    "WispPalette",
}

local newSprites = {
    idle = Sprite.load("wispNewIdle", "Actors/wisp/idle", 4, 4, 1),
    shoot1 = Sprite.load("wispNewShoot1","Actors/wisp/shoot1", 11, 5, 8),
    spawn = Sprite.load("wispNewSpawn", "Actors/wisp/spawn", 5, 12, 11),
    death = Sprite.load("wispNewDeath", "Actors/wisp/death", 9, 12, 12)
}

local wispFlame = ParticleType.new("Yellow Fire")
wispFlame:shape("Disc")
wispFlame:color(Color.fromRGB(255, 255, 255))
wispFlame:alpha(1, 0)
if not modloader.checkFlag("ror2_disable_wisp_glow") then
    wispFlame:additive(true)
end
wispFlame:size(0.1, 0.1, -0.0065, 0.0001)
wispFlame:angle(0, 360, 0.1, 0, true)
wispFlame:speed(0.1, 1, 0.005, 0)
wispFlame:direction(88, 92, 0, 0)
wispFlame:life(15, 30)

for _, sprite in ipairs(oldSprites) do
    local spriteToReplace = Sprite.find(sprite, "vanilla")
    if spriteToReplace ~= nil then
        if sprite == "WispIdle" then
            spriteToReplace:replace(newSprites.idle)
        elseif sprite == "WispSpawn" then
            spriteToReplace:replace(newSprites.spawn)
        elseif sprite == "WispShoot1" then
            spriteToReplace:replace(newSprites.shoot1)
        elseif sprite == "WispDeath" then
            spriteToReplace:replace(newSprites.death)
        elseif sprite == "WispPalette" then
            --spriteToReplace:replace(newSprites.palette)
        end
    end
end

registercallback("onStep", function()
    for _, wisp in ipairs(Wisp:findAll()) do
        if wisp:get("ghost") == 1 then
            wispFlame:alpha(0.75, 0)
        end
        local color = Color.fromRGB(211, 209, 105)
        if wisp:get("elite") ~= 0 then
            if (wisp:get("elite_tier") == 0 or wisp:get("elite_tier") == 9) then --Blazing
                color = Color.fromRGB(186, 61, 29)
            elseif (wisp:get("elite_tier") == 1 or wisp:get("elite_tier") == 8) then --Frenzied
                color = Color.fromRGB(231, 241, 37)
            elseif (wisp:get("elite_tier") == 2 or wisp:get("elite_tier") == 7) then --Leeching
                color =  Color.fromRGB(70, 209, 35)
            elseif (wisp:get("elite_tier") == 3 or wisp:get("elite_tier") == 6) then --Overloading
                color = Color.fromRGB(119, 255, 238)
            elseif (wisp:get("elite_tier") == 4 or wisp:get("elite_tier") == 5) then --Volatile
                color = Color.fromRGB(255, 249, 170)
            end
        end
        wispFlame:burst("middle", wisp.x + (math.random(-2, 2) + (-1 * wisp.xscale)), wisp.y - math.random(-4, 1), 1, color)
    end
end)

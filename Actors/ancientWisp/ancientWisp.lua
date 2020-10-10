local WispB = Object.find("WispB", "vanilla")

local oldSprites = {
    "WispBIdle",
    "WispBIdleBook",
    "WispBShoot1",
    "WispBShoot2",
    "WispBDeath",
    "WispBPalette",
}

local newSprites = {
    idle = Sprite.load("wispBNewIdle", "Actors/ancientWisp/idle", 4, 21, 51),
}

local wispBFlame = ParticleType.new("Purple Fire")
wispBFlame:shape("Disc")
wispBFlame:color(Color.fromRGB(255, 255, 255))
wispBFlame:alpha(1, 0)
if not modloader.checkFlag("ror2_disable_wisp_glow") then
    wispBFlame:additive(true)
end
wispBFlame:size(0.1, 0.1, -0.0025, 0.0001)
wispBFlame:angle(0, 360, 0.1, 0, true)
wispBFlame:speed(0.1, 1, 0.1, 0)
wispBFlame:direction(85, 95, 0, 0)
wispBFlame:life(30, 120)

for _, sprite in ipairs(oldSprites) do
    local spriteToReplace = Sprite.find(sprite, "vanilla")
    if spriteToReplace ~= nil then
        if sprite == "WispBIdle" then
            spriteToReplace:replace(newSprites.idle)
        elseif sprite == "WispBIdleBook" then
            spriteToReplace:replace(newSprites.idle)
        elseif sprite == "WispBShoot1" then
            spriteToReplace:replace(newSprites.idle)
        elseif sprite == "WispBShoot2" then
            spriteToReplace:replace(newSprites.idle)
        elseif sprite == "WispBDeath" then
            --spriteToReplace:replace(newSprites.palette)
        elseif sprite == "WispBPalette" then
            --spriteToReplace:replace(newSprites.palette)
        end
    end
end

registercallback("onStep", function()
    for _, wispB in ipairs(WispB:findAll()) do
        if wispB:get("ghost") == 1 then
            wispBFlame:alpha(0.75, 0)
        end
        local color = Color.fromRGB(156, 106, 210)
        if wispB:get("elite") ~= 0 then
            if (wispB:get("elite_tier") == 0 or wispB:get("elite_tier") == 9) then --Blazing
                color = Color.fromRGB(186, 61, 29)
            elseif (wispB:get("elite_tier") == 1 or wispB:get("elite_tier") == 8) then --Frenzied
                color = Color.fromRGB(231, 241, 37)
            elseif (wispB:get("elite_tier") == 2 or wispB:get("elite_tier") == 7) then --Leeching
                color =  Color.fromRGB(70, 209, 35)
            elseif (wispB:get("elite_tier") == 3 or wispB:get("elite_tier") == 6) then --Overloading
                color = Color.fromRGB(119, 255, 238)
            elseif (wispB:get("elite_tier") == 4 or wispB:get("elite_tier") == 5) then --Volatile
                color = Color.fromRGB(255, 249, 170)
            end
        end
        local i = math.random(15, 35)
        for x = 0, i do 
            wispBFlame:burst("middle", wispB.x + (math.random(-20, 23) + (-4 * wispB.xscale)), wispB.y - math.random(-13, 30), 1, color)
        end
    end
end)

local actors = ParentObject.find("actors", "vanilla")

local sound = Sound.find("Shield", "vanilla")

-- Shield Graphic --

callback.register("onDraw", function()
    for _, inst in ipairs(actors:findAll()) do
        if inst:isValid() then
            if inst:get("shield") > 0 then
                graphics.setBlendMode("additive")
                graphics.drawImage{
                    image = inst.sprite,
                    x = inst.x,
                    y = inst.y,
                    subimage = inst.subimage,
                    color = Color.fromRGB(0, 184, 198),
                    alpha = 0.7 + math.random() * 0.3,
                    angle = inst.angle,
                    xscale = inst.xscale,
                    yscale = inst.yscale,
                    width = inst.sprite.width + 2,
                    height = inst.sprite.height + 2
                }
                graphics.setBlendMode("normal")
            end
        end
    end
end)

callback.register("onStep", function()
    for _, actor in ipairs(actors:findAll()) do
        if type(actor) ~= "PlayerInstance" then
            local a = actor:getAccessor()
            if a.shield_cooldown > -1 then
                a.shield_cooldown = a.shield_cooldown - 1
            else
                if a.shield < a.maxshield then
                    sound:play()
                    a.shield = a.maxshield
                end
            end
        end
    end
end)

--[[registercallback("onHit", function(damager, hit, x, y)
    if type(hit) ~= "PlayerInstance" then
        if hit:get("shield") then
            if hit:get("shield") > 0 then
                hit:set("hp", hit:get("hp") + damager:get("damage"))
                hit:set("shield", math.clamp(hit:get("barrier") - damager:get("damage"), 0, hit:get("maxhp")))
            end
        end

    end
end)]]
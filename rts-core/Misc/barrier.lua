--barrier.lua
-- Adds Barrier into the game.

local actors = ParentObject.find("actors", "vanilla")

local gague = Sprite.load("EfBarrierGague", "Graphics/barrierGague", 1, 18, 6)
local barrierColor = Color.fromRGB(232, 185, 85)
local shield = Sprite.load("EfBarrier", "Graphics/barrierEffect", 83, 20, 24)

local gagueWidth = 29

local barrierDegradeRate = 0.01

registercallback("onActorInit", function(actor)
    actor:set("barrier", 0)
end)

registercallback("onStep", function()
    for _, actor in ipairs(actors:findAll()) do
        if actor:get("barrier") then
            if actor:get("barrier") > 0 then
                actor:set("barrier", math.clamp(actor:get("barrier") - (((actor:get("maxhp") + actor:get("maxshield")) / 30) / 60), 0, actor:get("maxhp") + actor:get("maxshield")))
                if actor:get("barrier") > actor:get("maxhp") then
                    actor:set("barrier", actor:get("maxhp"))
                end
                if actor:get("barrier") < 0 then
                    actor:set("barrier")
                end
            end
        end
    end
end)

registercallback("onHit", function(damager, hit, x, y)
    if hit:get("barrier") then
        if hit:get("barrier") > 0 then
            hit:set("hp", hit:get("hp") + damager:get("damage"))
            hit:set("barrier", math.clamp(hit:get("barrier") - damager:get("damage"), 0, hit:get("maxhp")))
        end

    end
end)

registercallback("onDraw", function()
    for _, actor in ipairs(actors:findAll()) do
        if actor:get("barrier") then
            if actor:get("barrier") > 0 then
                --[[graphics.drawImage{
                    image = gague,
                    x = actor.x,
                    y = actor.y + (actor.sprite.height + 10)
                }
                graphics.color(barrierColor)
                graphics.rectangle((actor.x - (gagueWidth / 2)), actor.y + (actor.sprite.height + 10) -2, math.clamp(((actor.x - (gagueWidth / 2)) + (gagueWidth * (actor:get("barrier") / actor:get("maxhp")))) - 2, (actor.x - (gagueWidth / 2)), (actor.x - (gagueWidth / 2)) + gagueWidth), actor.y + (actor.sprite.height + 10) + 1)]]
                graphics.setBlendMode("additive")
                graphics.drawImage{
                    image = shield,
                    x = actor.x,
                    y = actor.y - (actor.sprite.height/4),
                    alpha = math.clamp(actor:get("barrier") / (actor:get("maxhp") * 0.1), 0, 0.35),
                    subimage = ((actor:get("barrier")) % 83) + 1,
                    scale = ((actor.sprite.height+5) / shield.height)
                }
            end
        end
    end
end)

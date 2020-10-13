--RoR2 Demake Project
--Made by Sivelos
--razorwire.lua
--File created 2020/01/22

local razorwire = Item("Razorwire")
razorwire.pickupText = "Retaliate in a burst of razors on taking damage."

razorwire.sprite = restre.spriteLoad("Graphics/razorwire.png", 1, 16, 16)
razorwire:setTier("uncommon")

razorwire:setLog{
    group = "uncommon",
    description = "Getting hit causes you to explode in a burst of razors, dealing &y&160% damage&!&. Hits up to &y&5&!& targets in a &y&25m&!& radius.",
    story = "You were right to come to me for this PREMIUM barbed wire. The other retail models won't get the job done like I do. Just cutting up invaders isn't enough, no, I built in a secret defense mechanism!\n\nBy cramming as many razors, exacto knives, and any other blade I could find into this thing, this beauty is a powder keg waiting to burst! Just brushing up against it will turn anything nearby into thin strips! This is my greatest work yet. If I don't get any replies telling me how good this thing is, I'll be sending my lawyers after you!",
    destination = "PO Box 23-5B,\nFort Blondershire,\nColony of Man",
    date = "2/1/2056"
}
local meters = 5

local actors = ParentObject.find("actors", "vanilla")

local sprites = {
    thorns = restre.spriteLoad("RazorThorns", "Graphics/thorns",1, 18, 18),
    proc = Sprite.find("EfSlash2", "vanilla"),
    hit = Sprite.find("Bite1", "vanilla")
}
local sound = {
    proc = Sound.find("SamuraiShoot1", "vanilla")
}
local objects = {
    sparks = Object.find("EfSparks", "vanilla")
}

local WireStep = function(actor, count)
    local data = actor:getData()
    data.razorAlpha = (data.razorAlpha or 0) + 0.05
    if actor:get("lastHp") > actor:get("hp") then
        -------------------------------
        local amount = 5 + (2 * (count-1))
        local radius = 25 + (10 * (count - 1))
        local hit = 0
        for _, inst in ipairs(actors:findAllEllipse(actor.x - (radius * meters), actor.y - (radius * meters), actor.x + (radius * meters), actor.y + (radius*meters))) do
            if inst and inst:isValid() then
                if inst:get("team") ~= actor:get("team") then
                    if hit == 0 then                
                        sound.proc:play(1.4 + math.random() * 0.2, 0.5)
                        local s = objects.sparks:create(actor.x, actor.y)
                        s.sprite = sprites.proc
                    end
                    local b = actor:fireBullet(actor.x, actor.y, GetAngleTowards(inst.x, inst.y, actor.x, actor.y), Distance(actor.x, actor.y, inst.x, inst.y), 1.6, sprites.hit)
                    b:set("specific_target", inst.id)
                    hit = hit + 1
                    if hit >= amount then
                        break
                    end
                end
            end
        end
    end
end

local WireDraw = function(actor, count)
    local data = actor:getData()
    graphics.drawImage{
        image = sprites.thorns,
        x = actor.x,
        y = actor.y,
        alpha = 0.4 + (math.sin(data.razorAlpha)) * 0.1
    }
    local radius = 25 + (10 * (count - 1))
    graphics.color(Color.fromRGB(111, 144, 135))
    graphics.alpha(0.3 + (math.sin(data.razorAlpha)) * 0.1)
    graphics.circle(actor.x, actor.y, radius*meters, true)
    graphics.alpha(1)
end

registercallback("onPlayerStep", function(player)
    local count = player:countItem(razorwire)
    if count > 0 then
        WireStep(player, count)
    end
end)
registercallback("onPlayerDrawAbove", function(player)
    local count = player:countItem(razorwire)
    if count > 0 then
        WireDraw(player, count)
    end
end)


GlobalItem.items[razorwire] = {
    step = function(inst, count)
        WireStep(inst, count)
    end,
    draw = function(inst, count)
        WireDraw(inst, count)
    end
}
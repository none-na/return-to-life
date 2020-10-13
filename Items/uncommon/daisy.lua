--RoR2 Demake Project
--Made by Sivelos
--daisy.lua
--File created 2019/09/29

local daisy = Item("Lepton Daisy")
daisy.pickupText = "Creates healing novas during the teleporter event."

daisy.sprite = restre.spriteLoad("Graphics/daisy.png", 1, 16, 16)
daisy:setTier("uncommon")

daisy:setLog{
    group = "uncommon",
    description = "Creates healing novas for +50% max HP during the teleporter event. Fires +1 time per stack.",
    story = "---",
    destination = "---,\n---,\n---",
    date = "--/--/2056"
}

local teleporter = Object.find("Teleporter", "vanilla")
local actors = ParentObject.find("actors", "vanilla")
local flash = Object.find("EfFlash", "vanilla")
local circle = Object.find("EfCircle", "vanilla")

local sounds = {
    pulse = restre.soundLoad("daisy", "Sounds/daisy.ogg")
}

local daisyRadius = 300

daisy:addCallback("pickup", function(player)
    local tp = teleporter:findNearest(player.x, player.y)
    local data = tp:getData()
    if data.daisy then
        data.daisy = data.daisy + 1
    else
        data.daisy = 1
    end
end)

callback.register("onStep", function()
    local daisyCount = 0
    for _, playerInst in ipairs(misc.players) do
        daisyCount = daisyCount + playerInst:countItem(daisy)
    end
    for _, tpInst in ipairs(teleporter:findAll()) do
        local data = tpInst:getData()
        local tp = tpInst:getAccessor()
        if data.daisy then
            if tp.active == 1 then
                local daisyIncrement = math.round(tp.maxtime / (daisyCount + 1))
                if tp.time % daisyIncrement == 0 then
                    local flashInst = flash:create(tpInst.x, tpInst.y)
                    flashInst:set("parent", tpInst.id)
                    flashInst:set("image_blend", Color.DAMAGE_HEAL.gml)
                    local circleInst = circle:create(tpInst.x, tpInst.y)
                    circleInst:set("image_blend", Color.DAMAGE_HEAL.gml)
                    circleInst:set("rate", 50)
                    sounds.pulse:play(1 + math.random() * 0.05, 1)
                    for _, inst in ipairs(actors:findAll()) do
                        if inst:get("team") == "player" then
                            local actorInst = inst:getAccessor()
                            local heal = actorInst.maxhp * 0.5
                            local flashInst = flash:create(inst.x, inst.y)
                            flashInst:set("parent", inst.id)
                            flashInst:set("image_blend", Color.DAMAGE_HEAL.gml)
                            actorInst.hp = actorInst.hp + heal
                            misc.damage(math.round(heal), inst.x, inst.y - (inst.sprite.height), false, Color.DAMAGE_HEAL)
                            for i = 0, math.random(2, 5) do
                                ParticleType.find("Heal", "vanilla"):burst("middle", inst.x, inst.y, 1)
                            end
                        end
                    end
                end
            end
        end
    end
end)

GlobalItem.items[daisy] = {
    apply = function(inst, count)
        local tp = teleporter:findNearest(inst.x, inst.y)
        local data = tp:getData()
        if data.daisy then
            data.daisy = data.daisy + count
        else
            data.daisy = count
        end
    end,
}
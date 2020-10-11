--RoR2 Demake Project
--Made by Sivelos
--radar.lua
--File created 2019/06/13

local radar = Item("Radar Scanner")
radar.pickupText = "Reveal nearby interactibles."

radar.sprite = Sprite.load("Items/use/Graphics/radar.png", 2, 14, 16)

radar.isUseItem = true
radar.useCooldown = 45

radar:setTier("use")
radar:setLog{
    group = "use",
    description = "Reveals all interactibles within 1000 meters for 10 seconds.",
    story = "Pretty ballsy of you to request this through UES. Some spy! This should help you though with your work. Thing can put out anything from radio waves to UV, and detect anything from a lead car to a molecule in said car. Maybe it'll let you know when the enforcers are knocking down your door! Ha!",
    destination = "PO Box 203-451,\nArrowhead Complex",
    date = "2/2/2056"
}

local pulse = Object.find("EfCircle", "vanilla")

local radarBuff = Buff.new("radarBuff")
radarBuff.sprite = Sprite.load("radarBuff","Graphics/radar", 1, 9, 7)

radarBuff:addCallback("start", function(actor)
    actor:set("radarPulse", 0)
end)

radarBuff:addCallback("step", function(actor)
    actor:set("radarPulse", actor:get("radarPulse") + 1)
    if actor:get("radarPulse") >= 60 then
        local inst = pulse:create(actor.x, actor.y)
        inst:set("rate", 9)
        inst:set("radius", 20)
        actor:set("radarPulse", 0)
    end
end)

local radarRange = 750
local arrowSpr = Sprite.load("Graphics/arrow", 1, 4, -15)
local mapObjects = {ParentObject.find("mapObjects", "vanilla"), ParentObject.find("droneItems", "vanilla"), ParentObject.find("chests", "vanilla"), }

local getAngleTowardsObject = function(player, object)
    return math.deg(math.atan2(object.x-player.x,object.y-player.y))
end

local shouldMark = function(object)
    if string.find(object:getObject():getName(), "Chest") then
        if object:get("active") == 2 then
            return false
        else
            return true
        end
    elseif string.find(object:getObject():getName(), "Barrel") then
        if object:get("active") == 2 then
            return false
        else
            return true
        end
    elseif string.find(object:getObject():getName(), "Shrine") then
        if object:get("active") == 2 then
            return false
        else
            return true
        end
    elseif string.find(object:getObject():getName(), "Geyser") or string.find(object:getObject():getName(), "TeleporterFake") then
        return false
    else
        return true
    end
end

local getColor = function(object)
    if string.find(object:getObject():getName(), "Chest") then
        return Color.ROR_YELLOW
    elseif string.find(object:getObject():getName(), "Barrel") then
        return Color.ROR_BLUE
    elseif string.find(object:getObject():getName(), "Shrine") then
        return Color.GREEN
    elseif string.find(object:getObject():getName(), "Drone") then
        return Color.ORANGE
    elseif string.find(object:getObject():getName(), "Teleporter") and not string.find(object:getObject():getName(), "TeleporterFake")  then
        return Color.RED
    else
        return Color.WHITE
    end
end

registercallback("onPlayerDraw", function(player)
    if player:hasBuff(radarBuff) then
        local objCount = {
            chest = 0,
            shrine = 0,
            drone = 0,
            barrel = 0,
        }
        for _, objGroup in ipairs(mapObjects) do
            for _, objInst in ipairs(objGroup:findAllEllipse(player.x - radarRange, player.y - radarRange, player.x + radarRange, player.y + radarRange)) do
                if shouldMark(objInst) then
                    if string.find(objInst:getObject():getName(), "Chest") then
                        objCount.chest = objCount.chest + 1
                    elseif string.find(objInst:getObject():getName(), "Shrine") then
                        objCount.shrine = objCount.shrine + 1
                    elseif string.find(objInst:getObject():getName(), "Drone") then
                        objCount.drone = objCount.drone + 1
                    elseif string.find(objInst:getObject():getName(), "Barrel") then
                        objCount.barrel = objCount.barrel + 1
                    end
                    if IsOnScreen(player, objInst) then
                        graphics.drawImage{
                            image = arrowSpr,
                            x = objInst.x,
                            y = objInst.y - ((15 + objInst.sprite.height) + 20),
                            color = getColor(objInst)
                        }
                    else
                        graphics.drawImage{
                            image = arrowSpr,
                            x = player.x,
                            y = player.y,
                            angle = getAngleTowardsObject(player, objInst),
                            color = getColor(objInst)
                        }
                    end
                end
            end
        end
        graphics.color(Color.ROR_YELLOW)
        graphics.print("Chests Nearby: "..objCount.chest, player.x, player.y - ((player.sprite.height) + ((graphics.textHeight("E", graphics.FONT_DEFAULT) + 3) * 4)), graphics.FONT_DEFAULT, graphics.ALIGN_MIDDLE, graphics.ALIGN_CENTER)
        graphics.color(Color.ROR_BLUE)
        graphics.print("Barrels Nearby: "..objCount.barrel, player.x, player.y - ((player.sprite.height) + ((graphics.textHeight("E", graphics.FONT_DEFAULT) + 3) * 3)), graphics.FONT_DEFAULT, graphics.ALIGN_MIDDLE, graphics.ALIGN_CENTER)
        graphics.color(Color.GREEN)
        graphics.print("Shrines Nearby: "..objCount.shrine, player.x, player.y - ((player.sprite.height) + ((graphics.textHeight("E", graphics.FONT_DEFAULT) + 3) * 2)), graphics.FONT_DEFAULT, graphics.ALIGN_MIDDLE, graphics.ALIGN_CENTER)
        graphics.color(Color.ORANGE)
        graphics.print("Drones Nearby: "..objCount.drone, player.x, player.y - ((player.sprite.height) + ((graphics.textHeight("E", graphics.FONT_DEFAULT) + 3) * 1)), graphics.FONT_DEFAULT, graphics.ALIGN_MIDDLE, graphics.ALIGN_CENTER)
    end
end)


radar:addCallback("use", function(player, embryo)
    local count = 1
    if embryo then
        count = 2
    end
    local inst = pulse:create(player.x, player.y)
    inst:set("rate", 9)
    inst:set("radius", 20)
    player:applyBuff(radarBuff, (10*60) * count)
end)
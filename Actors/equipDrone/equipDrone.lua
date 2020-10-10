--equipdrone.lua

local sprites = {
    idle = Sprite.load("equipDroneIdle", "Actors/equipDrone/idle", 4, 4, 6),
    damaged = Sprite.load("equipDroneIdleDamaged", "Actors/equipDrone/idleBroken", 4, 4, 6),
    item = Sprite.load("equipDroneItem", "Actors/equipDrone/item", 1, 9, 20),
}

local equipDrone = Object.base("drone", "equipDrone")
equipDrone.sprite = sprites.idle


local equipDroneItem = Object.base("mapobject", "equipDroneItem")
equipDroneItem.sprite = sprites.item

local player = Object.find("P", "vanilla")
local useText = "&w&Press &y&'"..input.getControlString("enter").."'&w& to repair Equipment Drone. &y&(1 Equipment)&!&"
local activeText = "1 EQUIPMENT"

equipDroneItem:addCallback("create", function(drone)
    local data = drone:getData()
    local self = drone:getAccessor()
    self.name = "Broken Equipment Drone"
    drone.y = Object.find("B", "vanilla"):findLine(drone.x, drone.y, drone.x, drone.y + 100).y or drone.y
end)
equipDroneItem:addCallback("step", function(drone)
    local data = drone:getData()
    local self = drone:getAccessor()
    if drone:collidesWith(player:findNearest(drone.x, drone.y), drone.x, drone.y) then
        local target = player:findNearest(drone.x, drone.y)
        if input.checkControl("enter", target) == input.PRESSED then
            if target.useItem then
                local newDrone = equipDrone:create(drone.x, drone.y)
                print(modloader.getActiveNamespace())
                newDrone:set("master", target.id)
                newDrone:getData().equipment = target.useItem
                target.useItem = nil
                drone:destroy()
                return
            else
                Sound.find("Error", "vanilla"):play(1)
            end
        end
    end
end)
equipDroneItem:addCallback("draw", function(drone)
    local data = drone:getData()
    local self = drone:getAccessor()
    graphics.alpha(0.7+(math.random()*0.15))
    graphics.printColor("&y&"..activeText.."&!&", drone.x - (graphics.textWidth(activeText, NewDamageFont) / 2), drone.y + (graphics.textHeight(activeText, NewDamageFont)), NewDamageFont)
    if drone:collidesWith(player:findNearest(drone.x, drone.y), drone.x, drone.y) then
        graphics.alpha(1)
        local useFormatted = useText:gsub("&[%a]&", "")
        graphics.printColor(useText, (drone.x - (graphics.textWidth(useFormatted, graphics.FONT_DEFAULT) / 2)), (drone.y - (drone.sprite.height + (graphics.textHeight(useText, graphics.FONT_DEFAULT) + 5))), graphics.FONT_DEFAULT) 
    end
end)


equipDrone:addCallback("create", function(drone)
    local data = drone:getData()
    local self = drone:getAccessor()
    self.name = "Equipment Drone"
    self.sprite_idle=sprites.idle.id
    self.sprite_idle_broken = sprites.damaged.id
    self.x_range = 0
    self.y_range = 0
    self.maxhp = 150 * Difficulty.getScaling("hp")
    self.hp = self.maxhp
    self.child = equipDroneItem.id
    self.damage = 12 * Difficulty.getScaling("damage")
end)


equipDrone:addCallback("step", function(drone)
    local data = drone:getData()
    local self = drone:getAccessor()
    if data.equipment then
        print("Equipment: ".. data.equipment:getName())
    end
end)
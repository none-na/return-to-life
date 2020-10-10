--flyingEnemy.lua

local actors = ParentObject.find("actors", "vanilla")
local enemies = ParentObject.find("enemies", "vanilla")
local players = Object.find("P", "vanilla")

local flightManager = Object.new("FlightManager")

FlightProperties = {
    MOVEMENT_FORCE = 0, --velocity applied over time - uses momentum
    MOVEMENT_IMPULSE = 1, --instant starts and stops
}

-- This does have one callback...
local onFlightManagerInit = createcallback("onFlightManagerInit") --Called when an instance's flight manager is created. 
    -- Use this to customize the flight manager to your liking.
    -- Parameters:
        -- instance: The parent actor of the flight manager.
        -- manager: The instance of the flight manager.
        -- data: The flight manager's instance data. Just so you don't have to grab it yourself. <3

flightManager:addCallback("create", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    data.parent = -1 --id of the flight manager's parent. if it doesn't have one, it'll self-destruct
    data.vx = 0 --Current horizontal speed
    data.vy = 0 --Current vertical speed
    data.mVx = 1.5 --Maximum horizontal speed
    data.mVy = 1.5 --Maximum vertical speed
    data.ax = 0.1 --Added to vx when accelerating
    data.ay = 0.1 --Added to vy when accelerating
    data.dirX = 1 -- 1 = right, -1 = left
    data.dirY = 1 -- 1 = down, -1 = up
    data.gravity = 0 --Added to vy every frame
    data.rate = 1 --Added to f each frame
    data.f = 0 --Incrementing value. Use for various purposes
    data.overrideMax = false --If true, the enemy's base maximum speeds will not be used, and you can substitute your own
    data.easingRange = 10 --Used to help slow down the enemy if their target is within this range on the y axis
    data.noGroundRange = 10 --Used to help slow down the enemy if there is ground within this range on the y axis
    data.hover = false --Does the enemy bob up and down? Probably shouldn't use for enemies that have hitscan attacks, it may cause them to miss
    data.hoverSpeed = 1 --How fast the enemy bobs up and down
    data.hoverHeight = 1 --How far the enemy bobs up and down
    data.collide = true --Should the enemy collide with the map?
    data.flightType = FlightProperties.MOVEMENT_FORCE --What kind of movement system the enemy should use. See FlightProperties for more info
end)
flightManager:addCallback("step", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    local parent = Object.findInstance(data.parent)
    if parent and parent:isValid() then
        if misc.getTimeStop() > 0 or parent:get("disable_ai") == 1 then
            return
        end
        data.f = data.f + data.rate
        parent.x = this.x
        if data.hover then
            parent.y = this.y + (data.hoverHeight * math.sin(data.f*math.clamp(data.hoverSpeed, 0.00000001, math.huge)))
        else
            parent.y = this.y
        end
        local pData = parent:getData()
        local pSelf = parent:getAccessor()
        ------------------------
        if not pSelf.moveDown then
            pSelf.moveDown = 0
        end
        if not data.overrideMax then
            data.mVx = pSelf.pHmax
            data.mVy = pSelf.pVmax
        end
        ------------------------
        if not (pSelf.stunned == 1 or pSelf.force_knockback == 1 or pSelf.frozen == 1) then
            if pSelf.team == "enemy" then --Help enemies move up and down
                local target = Object.findInstance(pSelf.target)
                if target and target:isValid() then
                    if not Object.find("B", "vanilla"):findLine(parent.x, parent.y, target.x, target.y) and not Object.find("B", "vanilla"):findLine(parent.x, parent.y - data.noGroundRange, parent.x, parent.y + data.noGroundRange) then
                        if target.y - data.easingRange > parent.y then
                            pSelf.moveUp = 1
                            pSelf.moveDown = 0
                        elseif target.y + data.easingRange < parent.y then
                            pSelf.moveUp = 0
                            pSelf.moveDown = 1
                        end
    
                    end
                end
            end
            if pSelf.moveLeft == 1 then
                data.dirX = -1
            elseif pSelf.moveRight == 1 then
                data.dirX = 1
            else
                data.dirX = 0
            end
            if pSelf.moveUp == 1 or pSelf.moveUpHold == 1 then
                data.dirY = 1
            elseif pSelf.moveDown == 1 then
                data.dirY = -1
            else
                data.dirY = 0
            end
        end
        data.vy = data.vy + data.gravity
        if data.flightType == FlightProperties.MOVEMENT_FORCE then
            data.vx = math.approach(data.vx, data.mVx * data.dirX, data.ax)
            data.vy = math.approach(data.vy, data.mVy * data.dirY, data.ay)
        elseif data.flightType == FlightProperties.MOVEMENT_IMPULSE then
            data.vx = data.mVx * data.dirX
            data.vy = data.mVy * data.dirY
        end
        if data.collide then
            if parent:collidesMap(this.x + data.vx, this.y) then
                data.vx = 0
            end
            if parent:collidesMap(this.x, this.y + data.vy) then
                data.vy = 0
            end
        end
        this.x = this.x + data.vx
        this.y = this.y + data.vy
    else
        this:destroy()
    end
end)

callback.register("onHit", function(damager, hit, x, y)
    if hit:get("flying") then
        local manager = Object.findInstance(hit:get("flightManager"))
        if manager then
            if damager:get("damage") >= hit:get("knockback_cap") or hit:get("knockback_value") > 3 then
                --manager:getData().vx = manager:getData().vx + (hit:get("knockback_value"))
            end
        end
    end
end)



callback.register("onStep", function()
    for _, inst in ipairs(actors:findAll()) do
        if inst:get("flying") then
            if not inst:get("flightManager") then
                local manager = flightManager:create(inst.x, inst.y)
                manager:getData().parent = inst.id
                inst:set("flightManager", manager.id)
                onFlightManagerInit(inst, manager, manager:getData())
            end
        end
    end
end)

GetManager = function(instance)
    return Object.findInstance(instance:get("flightManager"))
end
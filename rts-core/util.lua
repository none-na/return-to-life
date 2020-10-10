--------------------------------------------

--Performs basic physics on the object when called.
--Parameters:
    -- object (instance): The object to act on.
--Soft Parameters:
    -- These parameters don't need to be passed in to the function, but should be set on the instance prior to calling this.
    -- vx: Object's current horizontal speed.
    -- vy: Object's current vertical speed.
    -- ax: Object's horizontal acceleration. Added to vx each frame.
    -- ay: Object's vertical acceleration. Added to vy each frame.
    -- rotate: How much the object rotates when moving, in degrees.
    -- direction: Direction the object is currently moving in. If it's moving left, it is set to -1. 1 otherwise.
    -- bounce: How much the object bounces off walls, value of 0-1. 1 means that object bounces and loses no speed; 0.5 means the object bounces and loses 50% of its speed.
PhysicsStep = function(object)
    object.x = object.x + (object:get("vx") or 0)
    object.y = object.y + (object:get("vy") or 0)	
    object:set("vx", (object:get("vx") or 0) + (object:get("ax") or 0))
    object:set("vy", (object:get("vy") or 0) + (object:get("ay") or 0))
    if object:get("vx") > 0 then object:set("direction", 1)
    elseif object:get("vx") < 0 then object:set("direction", -1)
    else object:set("direction", 0) end
    if object:get("rotate") ~= nil then
        object.yscale = 1
        object.xscale = 1
        local _pvx = object:get("vx") or 0
        local _pvy = -(object:get("vy") or 0)
        local _angle = math.atan(_pvy/_pvx)*(180/math.pi)
        if _pvx < 0 then _angle = _angle + 180 end
        object.angle = (object:get("rotate") + _angle)%360
    end
    if object:get("bounce") then
        if object:collidesMap(object.x,object.y) then
            local _vx = (object:get("vx") or 0)
            local _vy = (object:get("vy") or 0)
            object.x = object.x - _vx
            object.y = object.y - _vy
            local _vcollision = object:collidesMap(object.x, object.y + _vy)
            local _hcollision = object:collidesMap(object.x + _vx, object.y)
            if (not _hcollision) and (not _vcollision) then
                object:set("vx", - _vx * (object:get("bounce") or 0))
                object:set("vy", - _vy * (object:get("bounce") or 0))
            elseif _vcollision then
                object:set("vy", - _vy * (object:get("bounce") or 0))
            elseif _hcollision then
                object:set("vx", - _vx * (object:get("bounce") or 0))
            end
        end
    end
end
export("PhysicsStep", PhysicsStep)

-- Returns an incriment towards the target angle from the current angle, at a rate of step.
    -- current: The current angle to work from.
    -- target: The target angle to work towards.
    -- step: The amount of degrees to move each time this function is called.
DirectionStep = function(current, target, step)
    local t2 = target
    if math.abs(current - target) > 180 then 
        t2 = target + 180
    else
        t2 = target
    end
    return math.approach(current, t2, step)
end
export("DirectionStep", DirectionStep)

-- Returns true if an object is onscreen, relative to a player. Returns false otherwise.
-- Parameters:
    -- object (instance): The object to check for.
    -- leeway (number): Checks for an additional area outside the screen.
IsOnScreen = function(object, leeway)
    local w, h = graphics.getGameResolution()
    if not leeway then leeway = 0 end
    if object.x < camera.x + w + leeway and object.x > camera.x - leeway and object.y < camera.y + h + leeway and object.y > camera.y - leeway then
        return true
    else
        return false
    end
end
export("IsOnScreen", IsOnScreen)

-- Spawns an enemy based on the supplied arguments. Returns the created spawn object's m_id.
-- "args" can support the following parameters:
-- Required Parameters:
    -- enemy (object): The enemy object to spawn.
    -- x (number): The x coordinate to spawn the enemy at.
    -- y (number): The y coordinate to spawn the enemy at.
-- Non-required Parameters:
    -- Parameters marked with a "*" will be automatically filled under the following conditions: 
        -- You pass in a vanilla enemy object, and you don't pass anything in for the argument.
        -- If you really want to be sure though, please pass in something for the argument.
    -- palette* (sprite): The enemy's palette sprite.
    -- sound* (sound): The enemy's spawn sound.
    -- sprite* (sprite): The enemy's spawn sprite.
    -- prefix (number): The enemy's prefix type.
    -- elite (number): The enemy's elite type. Only passed in to the enemy if prefix is set to 1. 
        -- Setting this to values greater than 4 may cause problems.
    -- blight (number): The enemy's blight type. Only passed in to the enemy if prefix is set to 2.
SpawnEnemy = function(args)
    local spawn = Object.find("Spawn", "vanilla")
    local inst = spawn:create(args.x, args.y)
    inst:set("child", args.enemy.id)
    if args.palette then
        inst:set("sprite_palette", args.palette.id)
    else
        local pal = Sprite.find(args.enemy:getName().."Pal")
        if pal then
            inst:set("sprite_palette", pal.id)
        end
    end
    if args.sound then
        inst:set("sound_spawn", args.sound.id)
    else
        local snd = Sound.find(args.enemy:getName().."Spawn")
        if snd then
            inst:set("sound_spawn", snd.id)
        end
    end
    if args.sprite then
        inst:set("sprite_index",args.sprite.id)
    else
        local spr = Sprite.find(args.enemy:getName().."Spawn")
        if spr then
            inst:set("sprite_index", spr.id)
        end
    end
    if args.prefix and args.prefix > 0 then
        inst:set("prefix_type", args.prefix)
        if args.elite and args.elite > -1 then
            if args.elite > 4 then
                local spawnAc = inst:getAccessor()
                spawnAc.elite_type = args.elite % 4
                spawnAc.newEliteType = args.elite
                local manager = Object.find("EliteManager", "RoR2Demake"):create(inst.x, inst.y)
                -- Giving variables to the custom object
                manager:set("elite_type", spawnAc.newEliteType)
                local palette = Sprite.find(args.enemy:getName().."Pal_newB")
                spawnAc.newPalette = palette.id
                manager:set("palette", palette.id)
                if spawnAc.newPalette then
                    --this just makes really sure the palette is applied to the spawn object, otherwise it sometimes shows the default
                    --spawnAc.elite_type = spawnAc.newEliteType - 5
                    spawnAc.sprite_palette = spawnAc.newPalette
                end
            else
                inst:set("elite_type", args.elite)
            end
        end
    else
        inst:set("elite_type", -1)
        inst:set("prefix_type", -1)
        inst:set("blight_type", -1)
    end
    return inst:getAccessor().m_id
end
export("SpawnEnemy", SpawnEnemy)

-- Returns true if the mouse is hovering over a box defined by the specified coordinates. Returns false otherwise.
-- Parameters:
    -- x1 (number): The x coordinate of the top-left corner of the box to check for.
    -- y1 (number): The y coordinate of the top-left corner of the box to check for.
    -- x2 (number): The x coordinate of the bottom-right corner of the box to check for.
    -- y2 (number): The y coordinate of the bottom-right corner of the box to check for.
MouseHoveringOver = function(x1, y1, x2, y2)
    local result = false
    local mx, my = input.getMousePos(true)
    if (mx > x1 and mx < x2) and (my > y1 and my < y2) then
        result = true
    end
    return result
end
export("MouseHoveringOver", MouseHoveringOver)

-- Returns an angle pointing from Point B to Point A, in degrees.
-- Parameters:
    -- x1 (number): The x coordinate of Point B.
    -- y1 (number): The y coordinate of Point B.
    -- x2 (number): The x coordinate of Point A.
    -- y2 (number): The y coordinate of Point A.
GetAngleTowards = function(x1, y1, x2, y2)
    return math.deg(math.atan2(x2-x1,y2-y1)) + 90
end
export("GetAngleTowards", GetAngleTowards)

-- Returns an angle pointing from Point B to Point A, in radians.
-- Parameters:
    -- x1 (number): The x coordinate of Point B.
    -- y1 (number): The y coordinate of Point B.
    -- x2 (number): The x coordinate of Point A.
    -- y2 (number): The y coordinate of Point A.
GetAngleTowardsRad = function(x1, y1, x2, y2)
    return math.rad(math.deg(math.atan2(x2-x1,y2-y1)) + 90)
end
export("GetAngleTowardsRad", GetAngleTowardsRad)

--Returns the distance between two points.
-- Parameters:
    -- x1 (number): The x coordinate of Point A.
    -- y1 (number): The y coordinate of Point A.
    -- x2 (number): The x coordinate of Point B.
    -- y2 (number): The y coordinate of Point B.
Distance = function(x1, y1, x2, y2)
    return math.abs(math.sqrt(math.pow(x2-x1, 2) + math.pow(y2-y1, 2)))
end
export("Distance", Distance)

--Returns true if there is any collision between Point A and Point B.
-- Parameters:
    -- x1 (number): The x coordinate of Point A.
    -- y1 (number): The y coordinate of Point A.
    -- x2 (number): The x coordinate of Point B.
    -- y2 (number): The y coordinate of Point B.
GroundBetween = function(x1, y1, x2, y2)
    local dist = (math.sqrt(math.pow(x2-x1, 2) + math.pow(y2-y1, 2)))
    local xx = x2 - x1
    local yy = y2 - y1
    for i = 0, dist do
        if Stage.collidesPoint(x1 + (xx * (i/dist)), y1 + (yy * (i/dist))) then
            return true
        end
    end
    return false
end
export("GroundBetween", GroundBetween)

-- Drags an enemy towards the specified coordinates.
-- Parameters:
    -- target (instance): The instance to drag.
    -- x (number): The x coordinate to drag the target to.
    -- y (number): The y coordinate to drag the target to.
    -- strength (number): How strongly the target is dragged.
    -- ignoreWalls (boolean): Whether or not the target should be dragged through walls. Defaults to false.
DragTowards = function(target, x, y, strength, ignoreWalls)
    if target and target:isValid() then
        local angle = GetAngleTowards(target.x, target.y, x, y)
        local xx = math.cos(angle) * strength
        local yy = math.sin(angle) * strength
        if not ignoreWalls then
            if target:collidesMap(target.x, target.y) then
                return
            end
            for i = 0, strength do
                local x1 = math.floor(math.cos(angle) * i)
                local y1 = math.floor(math.sin(angle) * i)
                if target:collidesMap(target.x + x1, target.y + y1) then
                    break
                end
                xx = x1
                yy = y1
            end
        end
        target.x = math.approach(target.x, x, xx)
        target:set("ghost_x", target.x)
        target.y = math.approach(target.y, y, yy)
        target:set("ghost_y", target.y)

    end
end
export("DragTowards", DragTowards)

-- Returns the y coordinate of the ground relative to the specified coordinates and direction.
-- Parameters:
    -- x: The x coordinate to search from.
    -- y: The y coordinate to search from.
    -- dir: Which direction to search; positive values search downwards, negative values search upwards. Defaults to searching downwards.
FindGround = function(x, y, dir)
    local dy = y
    local step = 1
    if dir then
        if dir < 0 then
            dir = -1
        elseif dir > 0 then
            dir = 1
        else
            dir = 1
        end
        step = dir
    end
    local sX, sY = Stage.getDimensions()
    while dy ~= (sY*step) do
        if Stage.collidesPoint(x, dy) then
            break
        else
            dy = dy + step
        end
    end
    return dy
end
export("FindGround", FindGround)

-- Creates one of multiple portals found in Risk of Rain 2. Returns the newly created Portal.
-- NOTE: If you want to make a custom portal, please just use the "Portal" object.
-- Parameters:
    -- variant: The type of portal to spawn. Variants are listed below. Passing in a value not listed below will return a randomized Portal.
        -- gold: Creates a portal to Gilded Coast.
        -- celestial: Creates a portal to A Moment, Fractured.
        -- blue: Creates a portal to Bazaar Between Time.
        -- null / void: Creates a portal to Void Fields.
    -- x: The x coordinate to spawn the portal at.
    -- y: The y coordinate to spawn the portal at.
MakePortal = function(variant, x, y)
    variant = string.lower(variant)
    local portal = Object.find("Portal", "RTSCore"):create(x,y)
    local data = portal:getData()
    if variant == "gold" then
        portal.blendColor = Color.fromRGB(155, 150, 50)
        data.destination = nil
    elseif variant == "celestial" then
        portal.blendColor = Color.fromRGB(128, 142, 225)
        data.destination = Stage.find("A Moment, Fractured", "RoR2Demake")
    elseif variant == "blue" then
        portal.blendColor = Color.AQUA
        data.destination = Stage.find("Bazaar Between Time", "RoR2Demake")
    elseif variant == "null" or variant == "void" then
        portal.blendColor = Color.fromRGB(50, 0, 50)
        data.destination = Stage.find("Void Fields", "RoR2Demake")
    end
    return portal
end
export("MakePortal", MakePortal)

-- Creates one of multiple "orbs," which will create their respective Portal once the Teleporter is fully charged. Returns the newly created Orb, and its Portal.
-- NOTE: If you want to make a custom orb, please just use the "Orb" object.
-- Parameters:
    -- variant: The type of portal to spawn. Variants are listed below. Passing in a value not listed below will return a randomized Orb and Portal.
        -- gold: Creates a gold Orb, and a portal to Gilded Coast.
        -- celestial: Creates a celestial Orb, and a portal to A Moment, Fractured.
        -- blue: Creates a blue Orb, and a portal to Bazaar Between Time.
MakeOrb = function(variant)
    variant = string.lower(variant)
    local tp = Object.find("Teleporter", "vanilla"):findNearest(0, 0)
    if tp then
        local orb = Object.find("Orb", "RTSCore"):create(tp.x,tp.y)
        local data = orb:getData()
        local xx, yy
        xx = tp.x + math.random(-200, 200)
        yy = tp.y + math.random(-200, -20)
        if variant == "gold" then
            orb.blendColor = Color.fromRGB(255, 200, 100)
        elseif variant == "celestial" then
            orb.blendColor = Color.fromRGB(128, 142, 225)
        elseif variant == "blue" then
            orb.blendColor = Color.AQUA
        end
        data.portal = MakePortal(variant, xx, FindGround(xx, yy) - 20)
        data.portal:getData().activity = -1
        return orb, data.portal
    end
end
export("MakeOrb", MakeOrb)

local lightning = Object.new("LightningEffect")
lightning:addCallback("create", function(this)
    local data = this:getData()
    data.rate = 0.1
    data.targetX = this.x + math.random(-50, 50)
    data.targetY = this.y + math.random(-50, 50)
    this.blendColor = Color.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0,255))
    
end)
lightning:addCallback("step", function(this)
    local data = this:getData()
    this.alpha = this.alpha - data.rate
    if this.alpha <= 0 then
        this:destroy()
        return
    end
end)
lightning:addCallback("draw", function(this)
    local data = this:getData()
    if misc.getOption("video.quality") >= 2 then
        local xx = this.x
        local yy = this.y
        local x2 = data.targetX
        local y2 = data.targetY
        local alpha = this.alpha
        local angleTo = GetAngleTowards(xx, yy, x2, y2)

        for i = 0, math.floor(Distance(xx, yy, x2, y2) / 30) do
            local xo = -(math.cos(math.rad(angleTo + math.random(-15, 15))) * 20) 
            local yo = (math.sin(math.rad(angleTo + math.random(-15, 15))) * 20) 
            if misc.getOption("video.quality") == 3 then
                graphics.alpha(alpha - 0.4)
                graphics.color(this.blendColor)
                graphics.line(xx, yy, xx + xo, yy + yo, 4)
            end
            graphics.alpha(alpha)
            graphics.color(Color.WHITE)
            graphics.line(xx, yy, xx + xo, yy + yo, 1)
            if misc.getOption("video.quality") >= 2 then
                graphics.circle(xx, yy, math.random(2, 4), false)
                graphics.circle(xx + xo, yy+yo, math.random(2, 4), false)
            end
            xx = xx + xo
            yy = yy + yo
        end

        if misc.getOption("video.quality") == 3 then
            graphics.alpha(alpha - 0.4)
            graphics.color(this.blendColor)
            graphics.line(xx, yy, x2, y2, 4)
            graphics.alpha(alpha)
        end
        graphics.alpha(alpha)
        graphics.color(Color.WHITE)
        graphics.line(xx, yy, x2, y2, 1)
        graphics.circle(x2, y2, math.random(2, 4), false)
        -------------------------------------------------
    end
    
end)

-- Creates an object that draws lightning from (x1, y1) to (x2, y2). Fades with a rate of decay. Returns the created object for your use.
DrawLightning = function(x1, y1, x2, y2, decay)
    local inst = lightning:create(x1, y1)
    inst:getData().targetX = x2
    inst:getData().targetY = y2
    if decay then
        inst:getData().rate = decay
    end
    return inst
end
export("DrawLightning", DrawLightning)

NewDamageFont = graphics.fontFromSprite(Sprite.load("Graphics/font.png", 81, 0, 1), [[ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ0123456789/!”#¤%&()=?+-§@£$€{[]}\’*.,_<>^~¨ÜÏËŸ¿¡:;|]], -1, false)

export("NewDamageFont")

---------------------------------------------------------------------------------------------
-- CycloneLib - contents/collision/collision.lua

-- Dependencies:
---- CycloneLib.resources

if not restre.depends("CycloneLib.resources") then return nil end

local MAP_OBJECTS = {
	Object.find("B"),
	Object.find("BNoSpawn"),
	Object.find("BNoSpawn2"),
	Object.find("BNoSpawn3"),
}
local collision_object = Object.new("CycloneLibCollider")
local collision_instance = nil
local function refreshCollisionInstance()
	collision_instance = collision_object:create(0,0):set("persistent", 1)
	collision_instance.visible = false
	collision_instance.mask = CycloneLib.resources.white2x2
end
callback.register("onGameStart", refreshCollisionInstance)
--callback.register("onStageEntry", refreshCollisionInstance)

local collision = {}

-- Checks collision with an instance and a rectangle
collision.intersectsInstanceRectangle = function(i,x,y,w,h)
	if not collision_instance:isValid() then refreshCollisionInstance() end
	if not i:isValid() then return false end
	collision_instance.xscale = w/collision_instance.mask.width
	collision_instance.yscale = h/collision_instance.mask.height
	return collision_instance:collidesWith(i,x,y)
end
collision.intersectsWith = collision.intersectsInstanceRectangle

-- Checks collision with the map and a rectangle
collision.intersectsRectangleMap = function(x,y,w,h)
	if not collision_instance:isValid() then refreshCollisionInstance() end
	collision_instance.xscale = w/collision_instance.mask.width
	collision_instance.yscale = h/collision_instance.mask.height
	return collision_instance:collidesMap(x,y)
end

-- Checks collision between a rectangle and given objects
-- Objects is a table with GMObjectBase values
collision.intersectsRectangleObjects = function(x, y, w, h, objects)
	for _,object in pairs(objects) do
		if object:findRectangle(x, y, x+w, y+h) ~= nil then return true end
	end
	return false
end

-- Checks collision with a point and the map
collision.intersectsPointMap = function(x,y)
	if not collision_instance:isValid() then refreshCollisionInstance() end
	return collision.intersectsRectangleMap(x,y,0,0)
end

-- Checks collision with a line and given objects
-- <dx,dy> is in the game's coordinate system
-- Objects is a table with GMObjectBase values
collision.intersectsLineObjects = function(x, y, dx, dy, objects)
	for _,object in pairs(objects) do
		if object:findLine(x, y, x+dx, y+dy) ~= nil then return true end
	end
	return false
end

-- Checks collision with the map and a line.
-- <dx,dy> is in the game's coordinate system
collision.intersectsLineMap = function(x,y,dx,dy)
	return collision.intersectsLineObjects(x,y,dx,dy, MAP_OBJECTS)
end

-- Checks collision with the map and a line. Uses two points instead of dx and dy.
collision.intersectsPLineMap = function(x1,y1,x2,y2)
	return collision.intersectsLineMap(x1,y1,x2-x1,-(y2-y1))
end

-- Returns the first ground y coordinate under the given position.
collision.getGround = function(x,y,precision)
	if collision.intersectsRectangleMap(x,y,0,0) then return y end
	local _maxW, _maxH = Stage.getDimensions()
	local _bottom, _top = _maxH, y
	local precision = precision or 0.5
	while (math.abs(_bottom - _top) > precision) do
		local __top, __bottom = math.floor(_top), math.ceil(_bottom)
		if collision.intersectsRectangleMap(x,__top,0,(__bottom-__top)/2)
		then _bottom = _bottom - (_bottom - _top)/2
		else _top = _top + (_bottom - _top)/2
		end
	end
	return _top
end

-- Returns the first ceiling y coordinate above the given position.
collision.getCeiling = function(x,y,precision)
	if collision.intersectsRectangleMap(x,y,0,0) then return y end
	local _maxW, _maxH = Stage.getDimensions()
	local _bottom, _top = y, -_maxH
	local precision = precision or 0.5
	while (math.abs(_bottom - _top) > precision) do
		local __top, __bottom = math.floor(_top), math.ceil(_bottom)
		if collision.intersectsRectangleMap(x,__bottom-(__bottom-__top)/2,0,(__bottom-__top)/2)
		then _top = _top + (__bottom-__top)/2
		else _bottom = _bottom - (_bottom - _top)/2
		end
	end
	return _top
end

-- Casts a ray from the given position towards the <dx,dy> vector (in physics coordinate system).
-- Note that precision below 0.5 will probably not work due to the rounding
-- Don't give or give nil for objects if you want collision with the map
collision.raycast = function(x, y, dx, dy, objects, precision)
	local objects = objects or MAP_OBJECTS
	if collision.intersectsRectangleObjects(x, y, 0, 0, objects) then return x,y end
	local _x,_y = x,y
	local _maxW, _maxH = Stage.getDimensions()
	local _maxD = math.sqrt(_maxW^2 + _maxH^2) * 2
	local _angle = math.atan2(-dy, dx)
	local _fx, _fy = _x + _maxD * math.cos(_angle), _y + _maxD * math.sin(_angle)
	local precision = precision or 0.5
	local _sx, _sy = dx > 0, dy > 0
	while math.sqrt((_fx - _x)^2 + (_fy - _y)^2) > precision do
		local __x, __y, __fx, __fy = 0,0,0,0
		if _sx then __x = math.floor(_x) ; __fx = math.ceil(_fx)
		else __x = math.ceil(_x) ; __fx = math.floor(_fx) end
		if _sy then __y = math.floor(_y) ; __fy = math.ceil(_fy)
		else __y = math.ceil(_y) ; __fy = math.floor(_fy) end
		if collision.intersectsLineObjects(__x,__y,(__fx-__x)/2,(__fy-__y)/2, objects)
		then _fx = _fx - (_fx-_x)/2 ; _fy = _fy - (_fy-_y)/2
		else _x = _x + (_fx-_x)/2 ; _y = _y + (_fy-_y)/2
		end
	end
	return _x,_y
end


--#########--
-- Exports --
--#########--

export("CycloneLib.collision", collision)

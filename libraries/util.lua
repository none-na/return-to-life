local util = {}

-- Length of vector (dx, dy)
util.length = function(dx, dy)
	return math.sqrt(dx^2 + dy^2)
end

assert(util.length(3, 4) == 5)

-- Distance between two points (x1, y1) and (x2, y2)
util.distance = function(x1, y1, x2, y2)
	return util.length(x2 - x1, y2 - y1)
end

assert(util.distance(0, 0, 3, 4) == 5)

-- Angle of vector (dx, dy)
-- util.angle(x_end - x_start, y_end - y_start)
util.angle = function(dx, dy)
	if dx == 0 and dy == 0 then error("No angle") end
	return math.deg(math.atan2(dy, dx)) % 360
end

assert(not pcall(util.angle, 0, 0))
assert(util.angle(1, 0) == 0)
assert(util.angle(1, 1) == 45)
assert(util.angle(0, 1) == 90)
assert(util.angle(-1, 1) == 135)
assert(util.angle(-1, 0) == 180)
assert(util.angle(-1, -1) == 225)
assert(util.angle(0, -1) == 270)
assert(util.angle(1, -1) == 315)

export("util", util)

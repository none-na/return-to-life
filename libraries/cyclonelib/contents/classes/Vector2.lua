-- CycloneLib - contents/classes/Vector2.lua

-- Dependencies:
---- CycloneLib.Class
---- CycloneLib.collision

local DEFAULT_COLOR = Color.WHITE


--#############--
-- Constructor --
--#############--

local Vector2, var, def, metatable = CycloneLib.Class.new("Vector2", function(self, i,j)
	if isa(i, "Instance") then
		self:fromInstance(i)
	else
		if i then self.i = i end
		if j then self.j = j end
	end
end)


--###########--
-- Variables --
--###########--

var.i = "number"
var.j = "number"

def.i = 0
def.j = 0

var.x = {
	get = function(self) return self.i end,
	set = function(self, value) self.i = value end,
}

var.y = {
	get = function(self) return self.j end,
	set = function(self, value) self.j = value end,
}

var.angle = {
	get = function(self) return self:getAngle() end,
	set = function(self, value)
		local length = self:getLength()
		if length == 0 then return nil end
		self.i = length * math.cos(math.rad(value))
		self.j = length * math.sin(math.rad(value))
	end,
}

var.length = {
	get = function(self) return self:getLength() end,
}


--#############--
-- MetaMethods --
--#############--

metatable.__unm = function(self)
	return Vector2.new(-self.i, -self.j)
end

metatable.__add = function(left, right)
	if tostring(left) ~= tostring(right) then
		error("Vector2: Adding with non-vector and vector")
		return nil
	end
	return Vector2.new(left.i + right.i, left.j + right.j)
end

metatable.__sub = function(left, right)
	if tostring(left) ~= tostring(right) then
		error("Vector2: Subtracting with non-vector and vector")
		return nil
	end
	return left + (-right)
end

metatable.__mul = function(left, right)
	if tostring(left) == "Vector2" then
		if tostring(right) == "Vector2" then
			return left.i * right.i + left.j * right.j
		elseif type(right) == "number" then
			return Vector2.new(left.i * right, left.j * right)
		end
	elseif type(left) == "number" then
		return Vector2.new(left * right.i, left * right.j)
	end
end

metatable.__div = function(left, right)
	if type(right) ~= "number" then
		error("Vector2: Division by non-number")
		return nil
	end
	if right == 0 then
		error("Vector2: Division by 0")
		return nil
	end
	return Vector2.new(left.i / right, left.j / right)
end

metatable.__pow = function(left, right)
	if tostring(left) ~= "Vector2" then
		error("Vector2: Can't raise to vector")
		return nil
	end
	if type(right) == "number" then
		return Vector2.new(left.i ^ right, left.j ^ right)
	elseif tostring(right) == "Vector2" then
		return Vector2.new(left.i ^ right.i, left.j ^ right.j)
	else
		error("Vector2: Can't raise vector to '" .. type(right) .. "'")
		return nil
	end
end


--#########--
-- Methods --
--#########--

-- Returns the angle of the vector in degrees (counterclockwise).
function def:getAngle()
	return math.deg(math.atan2(self.j, self.i)) % 360
end

-- Returns the length of the vecor.
function def:getLength()
	return math.sqrt(self.i^2 + self.j^2)
end

-- Takes the dot product with the given vector.
function def:dot(vector2)
	return self * vector2
end

-- Returns a new unit vector with the same direction.
function def:unit()
	local length = self:getLength()
	if length ~= 0 then return self / self:getLength()
	else return Vector2.new(0,0) end
end

-- Returns the vector as two values.
function def:unpack()
	return self.i, self.j
end

-- Interpolates between two vectors.
function def:lerp(vector2, t)
	local t = t or 0.5
	return self + (vector2 - self) * t
end

--###########--
-- Modloader --
--###########--

-- Returns if the point represented by the vector collides with the map.
function def:intersectsMap()
	return CycloneLib.collision.intersectsPointMap(self.i, self.j)
end

-- Draws a line at the location using the vector.
-- Note that the coordinate is negative for the j variable.
function def:draw(x,y)
	graphics.color(DEFAULT_COLOR) ; graphics.alpha(1)
	graphics.line(x,y,x+self.i,y-self.j)
end

-- Adjusts the variables of the vector to match the position of the instance.
function def:fromInstance(instance)
	if instance:isValid() then
		self.i = instance.x
		self.j = instance.y
	end
	return self
end


--#########--
-- Exports --
--#########--

export("CycloneLib.Vector2", Vector2)
return Vector2
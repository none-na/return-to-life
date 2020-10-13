-- CycloneLib - contents/classes/Rectangle.lua

-- Dependencies:
---- CycloneLib.Class
---- CycloneLib.collision

local DEFAULT_COLOR = Color.WHITE


--#############--
-- Constructor --
--#############--

local Rectangle, var, def = CycloneLib.Class.new("Rectangle", function(self, x, y, w, h)
	if type(x) == "number" then
		self.x, self.y, self.w, self.h = x, y, w, h
	elseif isa(x, "Instance") then
		self:fromInstance(x, y)
	end
end)


--###########--
-- Variables --
--###########--

var.x = "number"
var.y = "number"
var.w = "number"
var.h = "number"
var.alpha = "number"
var.color = "Color?"

def.x = 0
def.y = 0
def.w = 0
def.h = 0
def.alpha = 1

var.top = {
	get = function(self) return self.y end,
	set = function(self, value) self.y = value end,
}

var.bottom = {
	get = function(self) return self.y + self.h end,
	set = function(self, value) self.h = value - self.y end,
}

var.left = {
	get = function(self) return self.x end,
	set = function(self, value) self.x = value end,
}

var.right = {
	get = function(self) return self.x + self.w end,
	set = function(self, value) self.w = value - self.x end,
}

var.centerx = {
	get = function(self) return self.x + self.w/2 end,
	set = function(self, value) self.x = value - self.w/2 end,
}

var.centery = {
	get = function(self) return self.y + self.h/2 end,
	set = function(self, value) self.y = value - self.h/2 end,
}


--#########--
-- Methods --
--#########--

-- Returns a corrected version of the rectangle if it has negative width or height
def.correct = function(self)
	local nw, nh = self.w < 0, self.h < 0
	local rectangle = Rectangle.new(self.x, self.y, self.w, self.h)
	if nw then
		rectangle.x = rectangle.x + rectangle.w
		rectangle.w = -rectangle.w
	end
	if nh then
		rectangle.y = rectangle.y + rectangle.h
		rectangle.h = -rectangle.h
	end
	return rectangle
end

-- Moves the rectangle to the given position.
-- Translates it relative to its current position if relative is true.
function def:move(x, y, relative)
	local relative = relative or false
	if relative then
		self.x = self.x + x
		self.y = self.y + y
	else
		self.x = x
		self.y = y
	end
end

-- Checks if it intersects another rectangle.
function def:intersectsRectangle(rectangle)
	return
	self.x < rectangle.right and
	self.right > rectangle.x and
	self.y < rectangle.bottom and
	self.bottom > rectangle.y
end

-- Checks if a rectangle has all the points in the other rectangle
def.containsRectangle = function(self, rectangle)
	return
	self.right >= rectangle.right and
	self.left <= rectangle.left and
	self.top <= rectangle.top and
	self.bottom >= rectangle.bottom
end

-- Checks if it intersects the given point.
function def:intersectsPoint(x,y)
	return
	x > self.x and
	x < self.x + self.w and
	y > self.y and
	y < self.y + self.h
end

-- Checks if it intersects with the given circle
function def:intersectsCircle(x,y,r)
	return self:intersectsPoint(x,y) or
	   ((self.left  - x)^2 + (self.top    - y)^2 <= r^2) or
	   ((self.left  - x)^2 + (self.bottom - y)^2 <= r^2) or
	   ((self.right - x)^2 + (self.top    - y)^2 <= r^2) or
	   ((self.right - x)^2 + (self.bottom - y)^2 <= r^2)
end

-- Enlarges the rectangle without moving its center.
function def:extrude(w,h)
	self.x = self.x - w/2
	self.y = self.y - h/2
	self.w = w
	self.h = h
end

-- Returns x, y, w, h
-- Returns x1, y1, x2, y2 when point is given
function def:unpack(point)
	if point == nil then return self.x, self.y, self.w, self.h
	else return self.x,self.y,self.right,self.bottom end
end


--###########--
-- Modloader --
--###########--

-- Matches the rectangle to the position and size of the given instance.
-- Uses the sprite if set with fromsprite or mask is not found.
function def:fromInstance(i, fromsprite)
	if not i:isValid() then return nil end
	local sprite = (fromsprite ~= nil and fromsprite ~= false) and (i.sprite or i.mask) or (i.mask or i.sprite)
	if not sprite then
		self.x = i.x ; self.y = i.y
		self.w = 0 ; self.h = 0
		return nil
	end
	self.w = math.abs(sprite.width * i.xscale)
	self.h = math.abs(sprite.height * i.yscale)
	self.x = i.x - (i.xscale > 0 and sprite.xorigin * i.xscale or -(sprite.width  - sprite.xorigin)*i.xscale)
	self.y = i.y - (i.yscale > 0 and sprite.yorigin * i.yscale or -(sprite.height - sprite.yorigin)*i.yscale)
end

-- Checks if the rectangle intersects the given instance.
function def:intersectsInstance(i)
	return CycloneLib.collision.intersectsInstanceRectangle(
		i,
		self.x,
		self.y,
		self.w,
		self.h
	)
end

-- Checks if the rectangle intersects with the map.
function def:intersectsMap()
	return CycloneLib.collision.intersectsRectangleMap(
		self.x,
		self.y,
		self.w,
		self.h
	)
end

-- Draws the rectangle
function def:draw(color, alpha, outline)
	local old_color, old_alpha = graphics.getColor(), graphics.getAlpha()
	graphics.color(color or self.color) ; graphics.alpha(alpha or self.alpha)
	graphics.rectangle(self.left, self.top, self.right - 1, self.bottom - 1, outline)
	graphics.color(old_color) ; graphics.alpha(old_alpha)
end


--#########--
-- Exports --
--#########--

export("CycloneLib.Rectangle", Rectangle)
return Rectangle
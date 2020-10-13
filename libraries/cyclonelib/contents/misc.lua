-- CycloneLib - contents/misc.lua

-- Dependencies:
---- Nothing

local mOnSx, mOnSy, mOnWx, mOnWy, sOnWx, sOnWy = 0,0,0,0,0,0
registercallback("preStep", function()
	mOnSx, mOnSy = input.getMousePos(true) ; mOnWx, mOnWy = input.getMousePos(false)
	sOnWx = mOnWx - mOnSx ; sOnWy = mOnWy - mOnSy
end)

local misc = {}

-- Converts the world or screen coordinates to the other.
misc.screenToWorld = function(x,y) return (x + sOnWx), (y + sOnWy) end
misc.worldToScreen = function(x,y) return (x - sOnWx), (y - sOnWy) end


--#########--
-- Exports --
--#########--

export("CycloneLib.misc", misc)
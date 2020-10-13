-- CycloneLib - contents/list.lua

-- Dependencies:
---- Nothing

local list = {}

-- Removes all entries in a list
list.removeAll = function(list)
	for _,value in ipairs(list:toTable()) do
		list:remove(value)
	end
end

-- Removes the entry at index
list.removeAt = function(list, index)
	list:remove(list[index])
end

--#########--
-- Exports --
--#########--

export("CycloneLib.list", list)
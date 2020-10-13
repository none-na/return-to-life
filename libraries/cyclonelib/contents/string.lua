-- CycloneLib - contents/string.lua

-- Dependencies:
---- Nothing

local SEPERATOR = ":"
local ESCAPE = "\\"

local _string = {}

-- Gives the levenshtein distance between the string s and t
-- Lua version of https://en.wikipedia.org/wiki/Levenshtein_distance
_string.levenshtein = function(s, t)
	local matrix = {}
	
	matrix[0] = 0
	
	for i=1,#s do
		matrix[i] = i
	end
	
	for j=1,#t do
		matrix[(#s + 1)*j] = j
	end
	
	local sub_cost
	for j=1,#t do
		for i=1,#s do
			sub_cost = (s:sub(i, i) == t:sub(j, j)) and 0 or 1
			matrix[(#s + 1)*j + i] = math.min(
				matrix[(#s + 1)*j + (i - 1)] + 1,
				matrix[(#s + 1)*(j - 1) + i] + 1,
				matrix[(#s + 1)*(j - 1) + (i - 1)] + sub_cost
			)
		end
	end
	
	return matrix[(#s + 1)*#t + #s]
end

-- Returns a unique string with the given strings
_string.join = function(...)
	local args = {...}
	local combined
	for i,s in ipairs(args) do
		local s = tostring(s):gsub(SEPERATOR, ESCAPE .. SEPERATOR)
		combined = (combined and (combined .. SEPERATOR) or "") .. s
	end
	return combined
end

-- Returns the strings used in the join function
_string.disjoin = function(s)
	if type(s) ~= "string" then
		error("Not a string")
	end
	
	local strings = {}
	local current, previous
	local part = ""
	for i=1,#s do
		local current = s:sub(i, i)
		if current == SEPERATOR then
			if previous ~= ESCAPE then
				part = part:gsub(ESCAPE .. SEPERATOR, SEPERATOR)
				table.insert(strings, part)
				part = ""
			else
				part = part .. current
			end
		else
			part = part .. current
		end
		previous = current
	end
	part = part:gsub(ESCAPE .. SEPERATOR, SEPERATOR)
	table.insert(strings, part)
	return strings
end


--#########--
-- Exports --
--#########--

export("CycloneLib.string", _string)
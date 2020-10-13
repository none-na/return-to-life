-- CycloneLib - contents/table.lua

-- Dependencies:
---- Nothing

local _table = {}

-- Removes an item from an i-indexed table.
-- Should be faster than table.remove on long tables.
_table.iremove = function(t,i)
	t[i] = t[#t]
	t[#t] = nil
end

-- Tries to make a string out of a table.
-- Should work for basic tables.
_table.tostring = function(t,l,r)
	local _s = ""
	local _l = l or ""
	local _r = r or {}
	for k,v in pairs(t) do
		_s = _s .. _l .. "Key=<<" .. tostring(k) .. ">>/Value=<<" .. tostring(v) .. ">>" .. "\n"
		if (type(v) == "table") and not _r[v] then
			_r[v] = true
			local __s, __r = _table.tostring(v,_l .. "    ",_r)
			_s = _s .. __s
			for __k,__v in pairs(__r) do _r[__k] = true end
		end
	end
	if _l == "" then return _s
	else return _s, _r end
end

-- Returns a string of seperator-seperated names from a table of (hopefully) strings
-- Uses only i-indexed values if i is true
-- Example: table.listString({ "a", "b", "c" }, ", ") -> "a, b, c"
_table.listString = function(t, seperator, i)
	local seperator = seperator or ""
	local table_string
	local for_generator = i and ipairs or pairs
	for _,s in for_generator(t) do
		local _s = tostring(s)
		table_string = table_string and (table_string .. seperator .. _s) or _s
	end
	return table_string
end

-- Swaps the keys and values of the table
_table.swap = function(t)
	local new_table = {}
	for key,value in pairs(t) do
		new_table[value] = key
	end
	return new_table
end

-- Gets the key the given value is at
_table.key = function(t, value)
	return _table.swap(t)[value]
end

-- Returns whether the table contains the given value
_table.contains = function(t, value)
	return _table.key(t, value) ~= nil
end

-- table.clone from http://lua-users.org/wiki/CopyTable
_table.clone = function(org)
	return {table.unpack(org)}
end

-- shallowcopy from http://lua-users.org/wiki/CopyTable
_table.shallowcopy = function(orig)
	local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else
        copy = orig
    end
    return copy
end

-- deepcopy from http://lua-users.org/wiki/CopyTable
_table.deepcopy = function(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

-- Combines two tables (overrides with the second table if there is conflict)
_table.combine = function(t, o)
	local new_table = {}
	for key,value in pairs(t) do
		new_table[key] = value
	end
	for key,value in pairs(o) do
		new_table[key] = value
	end
	return new_table
end

-- Reverses the table (for i-indexed tables)
_table.reverse = function(t)
	local new_table = {}
	for i=1,#t do
		new_table[#t - (i - 1)] = t[i]
	end
	return new_table
end

-- Deprecated setn function alternative (Shouldn't be used)
-- Doesn't seem to work either
-- http://lua-users.org/lists/lua-l/2011-05/msg00014.html
_table.setn = function(t, n)
	local mt = getmetatable(t)
	if mt == nil then
		mt = {}
		setmetatable(t, {})
	end
	mt.__len = function()
		return n
	end
end


--#########--
-- Exports --
--#########--

export("CycloneLib.table", _table)
-- CycloneLib - contents/classes/Class.lua

-- Dependencies:
---- Nothing

local Class = {}
local classes = {}

Class.new = function(name, constructor)
	local name = name

	if classes[name] then
		error(string.format("Class: A class with name '%s' already exists", name))
		return nil
	end
	
	classes[name] = {}
	local new_class = classes[name]
	local var, def = {}, {}
	setmetatable(var, var)
	setmetatable(def, def)
	
	local metatable = {}
	local def_val, val, get, set = {}, {}, {}, {}

	metatable.__index = function(self, key)
		if get[key] == nil then return nil end
		return get[key](self)
	end
	metatable.__newindex = function(self, key, value)
		if set[key] == nil then return nil end
		return set[key](self, value)
	end
	metatable.__tostring = function()
		return name
	end
	metatable.__type = function()
		return name
	end
	
	var.__newindex = function(self, key, var_type)
		if type(var_type) == "string" then
			local nillable = var_type:sub(#var_type, #var_type) == "?"
			if nillable then var_type = var_type:sub(1,-2) end
			get[key] = function(self)
				return val[self][key]
			end
			set[key] = function(self, value)
				if (type(value) == var_type) or (nillable and (value == nil)) then
					val[self][key] = value
				else
					error(string.format("Class: %s: Type mismatch setting '%s', expected '%s' got '%s'", name, key, var_type, type(value)))
				end
			end
		elseif type(var_type) == "table" then
			if type(var_type.get) == "function" then
				local f_get = var_type.get
				get[key] = function(self)
					return f_get(self)
				end
			end
			if type(var_type.set) == "function" then
				local f_set = var_type.set
				set[key] = function(self, value)
					return f_set(self, value)
				end
			end
		end
	end
	
	def.__newindex = function(self, key, value)
		if type(value) == "function" then
			var[key] = "function"
		end
		def_val[key] = value
	end
	
	new_class.new = function(...)
		local object = {}
		setmetatable(object, metatable)
		val[object] = {}
		
		for k,v in pairs(def_val) do
			object[k] = v
		end
		
		if constructor then
			constructor(object, ...)
		end
		
		return object
	end
	
	return new_class, var, def, metatable
end


--#########--
-- Exports --
--#########--

local _type = type
local type = function(variable)
	if (_type(variable) == "table") then
		local metatable = getmetatable(variable)
		if metatable and _type(metatable.__type) == "function" then
			return metatable.__type()
		end
	end
	return _type(variable)
end
_G.type = type

export("CycloneLib.Class", Class)
return Class
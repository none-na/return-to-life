-- CycloneLib - contents/modloader.lua

-- Dependencies:
---- Nothing

local _modloader = {}

--Returns a list of namespaces (mods) and indexes vanilla as the first.
_modloader.getNamespaces = function()
	local namespaces = modloader.getMods()
	namespaces[#namespaces+1] = namespaces[1]
	namespaces[1] = "vanilla"
	return namespaces
end

--Returns a list of namespaces (mods) and indexes vanilla as the first.
--Keeps the rest of the mods in modloader order. (Probably slower)
_modloader.getOrderedNamespaces = function()
	local namespaces = { [1] = "vanilla" }
	for i,v in ipairs(modloader.getMods()) do
		namespaces[i+1] = v
	end
	return namespaces
end

-- Checks whether or not the namespace exists
_modloader.checkNamespace = function(namespace)
	return namespace and ((modloader.checkMod(namespace)) or (namespace == "vanilla"))
end


--#########--
-- Exports --
--#########--

export("CycloneLib.modloader", _modloader)
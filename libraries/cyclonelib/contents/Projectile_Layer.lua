-- This the only file not modified from Cyclone 0.2.4 except this section
-- This is a compatibility layer for the built-in projectiles and the old Projectile Library
-- Since there are no built-in projectiles at this point this file is useless

--CycloneLib-Projectile

--Dependencies :
--  Nothing

--[=[

Projectile Library

-   The prefix is used when setting the variables on the projectile. Every projectile variable is accessed through it.

-   The dead variable becomes becomes positive on the first frame of the projectiles death and is negative afterwards.
	The absolute value indicates the death cause. If dead is 0 it means that the projectile is alive.
	The death causes are:
		-- 1 : Ran out of life.
		-- 2 : Hit a solid map object.
		-- 3 : Collided with an enemy (pierce set to false).

-   The life variable indicates how much life the projectile has left over in frames.
	If life is negative that means the projectile is dead and is playing the animation that corresponds to the death cause.
	
-   The vx and ax values change direction depending on the parent xscale.
	You shouldn't account for the direction while entering these values.
	You can specify a direction while calling fire to override this behaviour.

--]=]

--General variables
local ProjectileML = {}
local prefix = "Projectile_"
local projectileIndex = 0

--Storage variables
local projectileProperties = {}
local projectileCallbacks = {}
local projectileHits = {}
local projectileSprites = {}
local projectileDamagerVariables = {}

--Storage cleanup
local function resetStorage()
	for k,v in pairs(projectileHits) do
		local _projectileInstance = Object.findInstance(k)
		if (not _projectileInstance) or not (_projectileInstance:isValid()) then projectileHits[k] = nil ; projectileDamagerVariables[k] = nil end 
	end
end
registercallback("onMinuteChange", resetStorage)

local variables = {
-- Mandatory Variables
["sprite"] = "Sprite",                -- The normal sprite of the projectile
["life"] = "number",                  -- The maximum life of the projectile in frames (Note that while this isn't mandatory it should be set in case something goes wrong)

-- Optional Variables
["vx"] = "number",                    -- The horizontal speed of the projectile
["vy"] = "number",                    -- The vertical speed of the projectile
["ax"] = "number",                    -- The magnitude of horizontal acceleration affecting the projectile
["ay"] = "number",                    -- The magnitude of vertical acceleration affecting the projectile
["damage"] = "number",                -- The damage scale of the projectile (1 is %100)
["pierce"] = "boolean",               -- Whether the projectile pierces or not
["hitsprite"] = "Sprite",             -- Note that this sprite should only be used when multihit and pierce are true. Used by fireExplosion/fireBullet.
["deathsprite_life"] = "Sprite",      -- The sprite that will be used when the projectile runs out of life
["deathsprite_collision"] = "Sprite", -- The sprite that will be used when the projectile collides with solid map objects
["deathsprite_hit"] = "Sprite",       -- The sprite that will be used when the projectile hits an enemy while pierce is false
["explosion"] = "boolean",            -- Whether the projectile will create and explosion on hit
["damager_properties"] = "number",    -- The damager properties used in ML
["ghost"] = "boolean",                -- Whether the projectile will pass through walls
["multihit"] = "boolean",             -- Whether the projectile should hit enemies continuously as long as there is contact. Almost never true.
["explosionw"] = "number",            -- Explosion width if explosion is true
["explosionh"] = "number",            -- Explosion height if explosion is true
["rotate"] = "number",                -- Whether the sprite should rotate according to the motion of the projectile (Note that collisions are affected by this) (The number is the normal rotation of the sprite)
["impact_explosion"] = "boolean",     -- Whether the projectile should explode if it hits a solid map object
["mask"] = "Sprite",                  -- The mask sprite used for collisions
["damager_variables"] = "table",      -- The variables to be set to the damager that will be spawned when the projectile hits
["bounce"] = "number",                -- Setting this makes the projectile bounce when it hits the ground. The number is how much of it's impact speed the projectile will keep. (0.5 is half)

--Other variables
--["name"] = "string"                 -- The name that will be given to the projectile. Used for the GMObject creation.

--Variables that are set by the library for getting (Should not be set outside or from Projectile functions).
--These can be read with <projectileInstance>:get(<prefix> .. <variable_name>).
--Example for the default prefix : projectileInstance:get("Projectile_dead")
--["direction"] = "number"            -- Similiar to xscale. Shows the direction the projectile is going towards currently. Affected by speed. Set to 0 if not moving horizontally.
--["fire_direction"] = "number"       -- The direction used when initially firing the projectile. Not affected by speed.
--["hit_number"] = "number"           -- The amount of actors hit on the current frame.
--["total_hit_number"] = "number"     -- The total amount of actors hit.
--["dead"] = "number"                 -- The death status of the projectile. See the above comments. Can be changed manually in object callbacks.
--["parent"] = "number"               -- The parent instance ID of the projectile.
--["active"] = "number"               -- Is 0 if the projectile logic is not being run. Should be 1 otherwise. Can be changed manually.
--["team"] == "string"                -- The team the projectile belongs to. Inherited from the parent on Projectile.fire(). Can be changed manually.
}

--Gets the parent of the projectile.
function ProjectileML.getParent(projectileInstance) return projectileInstance:getParent() end

--Starts and stops the projectile logic. Stopping also stops the life countdown.
function ProjectileML.start(projectileInstance) if projectileInstance:get("dead") ~= 0 then projectileInstance:set(prefix .. "active", 1) end end
function ProjectileML.stop(projectileInstance)  if projectileInstance:get("dead") ~= 0 then projectileInstance:set(prefix .. "active", 0) end end

--Adds a projectile callback to the projectile object.
--The function f will be called with the parameters of the callback.
--onCollide : Runs when there is a collision with an actor regardless of team or damage. Passes the instance and actor in order.
--preHit : Runs before doing damage to an actor. Passes the instance and actor in order.
function ProjectileML.addCallback(projectileObject, callbackname, f)
	if not projectileCallbacks[projectileObject] then projectileCallbacks[projectileObject] = {} end
	if not projectileCallbacks[projectileObject][callbackname] then projectileCallbacks[projectileObject][callbackname] = {} end
	table.insert(projectileCallbacks[projectileObject][callbackname], f)
end

--Triggers the given callback. Might have problems when used outside the correct places.
function ProjectileML.triggerCallback(projectileObject, callbackname, ...)
	if (projectileCallbacks[projectileObject]) and (projectileCallbacks[projectileObject][callbackname]) then
		for k,v in ipairs(projectileCallbacks[projectileObject][callbackname]) do
			v(...)
		end
	end
end

local function generalFire(projectileInstance, enemyInstance)
	local _hitsprite = projectileSprites[projectileInstance:get(prefix .. "hitsprite")]
	ProjectileML.triggerCallback(_projectileObject, "preHit", projectileInstance, enemyInstance)
	if (projectileInstance:get(prefix .. "explosion") ~= 1) and isa(enemyInstance, "Instance") then
		local _damager = projectileInstance:fireBullet(
			enemyInstance.x - (enemyInstance.x - projectileInstance.x) * 16,
			enemyInstance.y,
			90 * (1 - math.sign(enemyInstance.x - projectileInstance.x)),
			16,
			projectileInstance:get(prefix .. "damage") or 0,
			_hitsprite,
			projectileInstance:get(prefix .. "damager_properties")
		)
		_damager:set("specific_target", enemyInstance.id)
		if projectileDamagerVariables[projectileInstance.id] then for _k,_v in pairs(projectileDamagerVariables[projectileInstance.id]) do _damager:set(_k,_v) end end
	else
		local _damager = projectileInstance:fireExplosion(
			projectileInstance.x,
			projectileInstance.y,
			(projectileInstance:get(prefix .. "explosionw") or 0)/(19*2),
			(projectileInstance:get(prefix .. "explosionh") or 0)/(4*2),
			projectileInstance:get(prefix .. "damage") or 0,
			_hitsprite,
			nil,
			projectileInstance:get(prefix .. "damager_properties")
		)
		if projectileDamagerVariables[projectileInstance.id] then for _k,_v in pairs(projectileDamagerVariables[projectileInstance.id]) do _damager:set(_k,_v) end end
	end
	projectileInstance:set(prefix .. "hit_number", projectileInstance:get(prefix .. "hit_number") + 1)
	projectileInstance:kill(projectileSprites[projectileInstance:get(prefix .. "deathsprite_hit")] or projectileSprites[projectileInstance:get(prefix .. "deathsprite_collision")], 3)
end

function ProjectileML.new(properties)
	local _projectileObject = nil
	if (not properties) or (not properties.name) then projectileIndex = projectileIndex + 1 ; _projectileObject =  Object.new(prefix .. tostring(projectileIndex))
	else _projectileObject = Projectile.new(tostring(properties.name)) end
	projectileProperties[_projectileObject] = {}
	for k,v in pairs(variables) do
		if (v ~= "boolean" and properties[k] and type(properties[k]) == v) or (v == "boolean" and (properties[k] == false or properties[k] == true)) then
			if v == "Sprite" then
				if k == "sprite" then _projectileObject.sprite = properties[k] end
				projectileProperties[_projectileObject][k] = properties[k]:getName()
				projectileSprites[properties[k]:getName()] = properties[k]
			elseif v == "boolean" then
				if (properties[k] == true) then projectileProperties[_projectileObject][k] = 1
				else projectileProperties[_projectileObject][k] = 0 end
			elseif v == "table" then
				if k == "damager_variables" then projectileProperties[_projectileObject][k] = properties[k] end
			else projectileProperties[_projectileObject][k] = properties[k]	end
		end
	end
	_projectileObject:addCallback("create", function(projectileInstance) if projectileInstance:isValid() then
		for k,v in pairs(projectileProperties[Projectile.fromObject(projectileInstance:getObject())]) do
			if type(v) ~= "table" then projectileInstance:set(prefix .. k, v) end
		end
		projectileInstance:set("life", projectileInstance:get(prefix .. "life"))
		projectileInstance:set(prefix .. "dead", 0)
	end end)
	_projectileObject:addCollisionCallback("collide", "actors", function(projectileInstance, enemyInstance)
		ProjectileML.triggerCallback(_projectileObject, "onCollide", projectileInstance, enemyInstance)
		if enemyInstance:get("team") ~= projectileInstance:get("team") and (projectileInstance:get(prefix .. "multihit") == 1) then
			generalFire(projectileInstance, enemyInstance)
		end
	end)
	_projectileObject:addCollisionCallback("entry", "actors", function(projectileInstance, enemyInstance)
		if enemyInstance:get("team") ~= projectileInstance:get("team") and (projectileInstance:get(prefix .. "multihit") ~= 1) then
			generalFire(projectileInstance, enemyInstance)
		end
	end)
	_projectileObject:addCollisionCallback("entry", "map", function(projectileInstance)
		if projectileInstance:get(prefix .. "ghost") ~= 1 then
			if (projectileInstance:get(prefix .. "impact_explosion") or 0) == 1 then
				generalFire(projectileInstance, 1)
			end
			projectileInstance:kill(projectileSprites[projectileInstance:get(prefix .. "deathsprite_collision")] or projectileSprites[projectileInstance:get(prefix .. "deathsprite_hit")], 2)
			if projectileInstance:get(prefix .. "bounce") then
				local _vx, _vy = projectileInstance:get(prefix .. "vx") or 0, projectileInstance:get(prefix .. "vy") or 0
				local _vcollision = projectileInstance:collidesMap(projectileInstance.x - _vx, projectileInstance.y)
				local _hcollision = projectileInstance:collidesMap(projectileInstance.x, projectileInstance.y - _vy)
				if (not _hcollision) and (not _vcollision) then
					projectileInstance:set(prefix .. "vx", - _vx * projectileInstance:get(prefix .. "bounce"))
					projectileInstance:set(prefix .. "vy", - _vy * projectileInstance:get(prefix .. "bounce"))
				elseif _vcollision then
					projectileInstance:set(prefix .. "vy", - _vy * projectileInstance:get(prefix .. "bounce"))
				elseif _hcollision then
					projectileInstance:set(prefix .. "vx", - _vx * projectileInstance:get(prefix .. "bounce"))
				end
			end
		end
	end)
	_projectileObject:addCallback("step", function(projectileInstance)
		projectileInstance:set(prefix .. "total_hit_number", (projectileInstance:get(prefix .. "total_hit_number") or 0) + (projectileInstance:get(prefix .. "hit_number") or 0))
		projectileInstance:set(prefix .. "hit_number", 0)
		
		if (projectileInstance:get(prefix .. "active") or 1) == 0 then return nil end
		
		projectileInstance:set(prefix .. "vx", (projectileInstance:get(prefix .. "vx") or 0) + projectileInstance:get("haccel"))
		projectileInstance:set(prefix .. "vy", (projectileInstance:get(prefix .. "vy") or 0) + projectileInstance:get("vaccel"))
	
		projectileInstance:set("hspeed", projectileInstance:get(prefix .. "vx") or 0)
		projectileInstance:set("vspeed", projectileInstance:get(prefix .. "vy") or 0)
		projectileInstance:set("haccel", projectileInstance:get(prefix .. "ax") or 0)
		projectileInstance:set("vaccel", projectileInstance:get(prefix .. "ay") or 0)
		
		projectileInstance:set(prefix .. "direction", math.sign(projectileInstance:get(prefix .. "vx") or 0))
		
		if projectileInstance:get(prefix .. "rotate") ~= nil then
			projectileInstance.yscale = 1
			projectileInstance.xscale = 1
			projectileInstance.angle = (projectileInstance:get(prefix .. "rotate") + math.atan2(-projectileInstance:get(prefix .. "vy") or 0, projectileInstance:get(prefix .. "vx") or 0))%360
		end
	end)
	_projectileObject:getObject():addCallback("step", function(projectileInstance)
		if projectileInstance:get(prefix .. "dead_first") == 1 then
			projectileInstance:set(prefix .. "dead_first", 0)
		elseif projectileInstance:get(prefix .. "dead_first") == 0 then
			projectileInstance:set(prefix .. "dead_first", nil)
			projectileInstance:set(prefix .. "dead", -projectileInstance:get("dead"))
		end
	end)
	_projectileObject:addCallback("death", function(projectileInstance)
		projectileInstance:set(prefix .. "dead", projectileInstance:get("dead") or 0)
		projectileInstance:set(prefix .. "dead_first", 1)
	end)
	
	return _projectileObject:getObject()
end

--This function fires a given projectile object and returns the instance that has been fired.
function ProjectileML.fire(projectileObject, x, y, parent, direction)
	local projectileObject = Projectile.fromObject(projectileObject)
	local _direction = direction or parent.xscale
	local _projectileInstance = projectileObject:fire(x, y, parent, direction)
	_projectileInstance.xscale = _direction
	_projectileInstance:set(prefix .. "vx", (_projectileInstance:get(prefix .. "vx") or 0) * _direction)
	_projectileInstance.mask = projectileSprites[projectileProperties[projectileObject].mask]
	projectileDamagerVariables[_projectileInstance.id] = projectileProperties[projectileObject].damager_variables
	_projectileInstance:set(prefix .. "vx", _projectileInstance:get(prefix .. "vx") or 0)
	_projectileInstance:set(prefix .. "vy", _projectileInstance:get(prefix .. "vy") or 0)
	_projectileInstance:set(prefix .. "ax", _projectileInstance:get(prefix .. "ax") or 0)
	_projectileInstance:set(prefix .. "ay", _projectileInstance:get(prefix .. "ay") or 0)
	_projectileInstance:set("hspeed", _projectileInstance:get(prefix .. "vx") or 0)
	_projectileInstance:set("vspeed", _projectileInstance:get(prefix .. "vy") or 0)
	_projectileInstance:set("haccel", _projectileInstance:get(prefix .. "ax") or 0)
	_projectileInstance:set("vaccel", _projectileInstance:get(prefix .. "ay") or 0)
	return _projectileInstance
end

--Changes the variables of a given projectile instance.
--Use with GMObject callbacks with the given projectile object from Projectile.new().
function ProjectileML.configure(projectileInstance, properties)
	if projectileInstance:get("dead") ~= 0 then
		for k,v in pairs(variables) do
			if (v ~= "boolean" and properties[k] and type(properties[k]) == v) or (properties[k] == false or properties[k] == true) then
				if v == "Sprite" then
					if k == "sprite" then projectileInstance.sprite = properties[k] end
					projectileInstance:set(prefix .. k, properties[k]:getName())
					projectileSprites[properties[k]:getName()] = properties[k]
				elseif v == "boolean" then
					if properties[k] == true then projectileInstance:set(prefix .. k, 1)
					else projectileInstance:set(prefix .. k, 0) end
				elseif v == "table" then
					if k == "damager_variables" then
						projectileDamagerVariables[projectileInstance.id] = properties[k]
					end
				else projectileInstance:set(prefix .. k, properties[k])	end
			end
		end
	end
end

--Aims projectiles that have standard projectile motion. (No horizontal acceleration)
--Target can be an instance or table with x and y keys.
--Bidirectional ignores the horizontal direction of the projectile.
--Speed dictates the magnitude of speed of the projectile. If not given it's current speed is used.
function ProjectileML.aim(projectileInstance, target, bidirectional, speed)
	if projectileInstance:get("dead") ~= 0 then
		if (target and isa(target, "Instance") and target:isValid()) or (target and (type(target) == "table") and target.x and target.y) then
			local _pvx = (projectileInstance:get(prefix .. "vx") or 0)
			local _pvy = (projectileInstance:get(prefix .. "vy") or 0)
			local speed = speed or math.sqrt((_pvx)^2 + (_pvy)^2)
			local _a = target.x - projectileInstance.x
			local _b = (projectileInstance:get("vaccel") or 0)/2
			local _c = speed
			local _d = target.y - projectileInstance.y
			
			if (not bidirectional) and ( ((_a < 0) and (_pvx > 0)) or ((_a > 0) and (_pvx < 0)) ) then return end
			
			local _n =(-(_a^4))*(4*(_a^2)*(_b^2) - 4*_b*_d*(_c^2) - (_c^4))
			if _n > 0 then
				_n = math.sqrt(_n)
				local _m = (2*(_a^2)*_b*_d + (_a^2)*(_c^2) + _n)/((_a^2) + (_d^2))
				if _m <= 0 then _m = (2*(_a^2)*_b*_d + (_a^2)*(_c^2) - _n)/((_a^2) + (_d^2)) end
				if _m > 0 then
					_m = math.sqrt(_m)
					local _vx = _m / math.sqrt(2)
					if _a < 0 then _vx = -_vx end
					local _edy = _b*((_a/_vx)^2)
					_vy = math.sqrt((_c^2) - (_vx^2))
					if _d < _edy then _vy = -_vy end
					ProjectileML.configure(projectileInstance, { vx = _vx, vy = _vy })
				end
			end
		end
	end
end


--#########--
-- Exports --
--#########--

export("CycloneLib.Projectile", ProjectileML)
return ProjectileML
-- CycloneLib - contents/Projectile.lua

-- Dependencies :
---- Nothing

--[=[
If there is ANYTHING here that can be done better please let me know

Projectile Library for quickly making projectiles
Should be capable of most projectiles but it might be better to make custom projectiles for advanced stuff

Changes:

- The direction, fire_direction variables are removed
	direction can be derived from vx
	fire_direction can be derived from xscale as long as it's not overriden
	
- While team can be read, setting it doesn't change projectile behaviour since now the parent team is used

Notes:

- After the dead variable is set the projectile enters a state in which it doesn't do anything other than wait for the death animation to end.
	Because of this make sure to check if the projectile is dead (dead == 0 means alive) if you're going to change one or more of the following:
	life, sprite, active, dead, spriteSpeed
	
- The following variables are not fully available in the create callback
	vx, ax, parent, team

- The variables set in the defaults table are assumed to always exist and will most likely to error when set to nil

- While vx, vy, ax, ay still work (for compatibility reasons) new projectiles should make use of the built-in variables.
	These are hspeed (vx), vspeed (vy), gravity (acceleration intensity), gravity_direction (acceleration direction)

- getData isn't used to maintain compatibility

- The PREFIX is used when setting the variables on the projectile.
	Projectile variables are accessed through it.
	This was to prevent mod conflicts.
	getData would solve that but isn't used to keep compatibility.
	
- The dead variable becomes becomes positive on the first frame of the projectiles death and is negative afterwards.
	The absolute value indicates the death cause. If dead is 0 it means that the projectile is alive.
	The death cause corresponding to the variable can be seen in the table 'death_causes' below
	
- The life variable indicates how much life the projectile has left over in frames.
	If life is negative that means the projectile is dead and is playing the animation that corresponds to the death cause.
	
- The vx and ax values change direction depending on the parent xscale.
	You shouldn't account for the direction while entering these values.
	You can specify a direction while calling fire to override this behaviour.
--]=]

local death_causes = {
	[1] = "life",
	[2] = "collision",
	[3] = "hit",
}

local variables = {
"sprite",                -- Sprite  -- The normal sprite of the projectile
"hitsprite",             -- Sprite  -- Note that this sprite should only be used when multihit and pierce are true. Used by fireExplosion/fireBullet.
"deathsprite_life",      -- Sprite  -- The sprite that will be used when the projectile runs out of life
"deathsprite_collision", -- Sprite  -- The sprite that will be used when the projectile collides with solid map objects
"deathsprite_hit",       -- Sprite  -- The sprite that will be used when the projectile hits an enemy while pierce is false
"mask",                  -- Sprite  -- The mask sprite used for collisions
"life",                  -- number  -- The maximum life of the projectile in frames (Note that while this isn't mandatory it should be set in case something goes wrong)
"vx",                    -- number  -- The horizontal speed of the projectile
"vy",                    -- number  -- The vertical speed of the projectile
"ax",                    -- number  -- The magnitude of horizontal acceleration affecting the projectile
"ay",                    -- number  -- The magnitude of vertical acceleration affecting the projectile
"damage",                -- number  -- The damage scale of the projectile (1 is %100)
"pierce",                -- boolean -- Whether the projectile pierces or not
"explosion",             -- boolean -- Whether the projectile will create and explosion on hit
"explosionw",            -- number  -- Explosion width if explosion is true
"explosionh",            -- number  -- Explosion height if explosion is true
"damager_properties",    -- number  -- The damager properties used in ML
"damager_variables",     -- table   -- The variables to be set to the damager that will be spawned when the projectile hits
"ghost",                 -- boolean -- Whether the projectile will pass through walls
"multihit",              -- boolean -- Whether the projectile should hit enemies continuously as long as there is contact. Almost never true.
"impact_explosion",      -- boolean -- Whether the projectile should explode if it hits a solid map object
"bounce",                -- number  -- Setting this makes the projectile bounce when it hits the ground. The number is how much of it's impact speed the projectile will keep. (0.5 is half)
"rotate",                -- number  -- Whether the sprite should rotate according to the motion of the projectile (Note that collisions are affected by this) (The number is the normal rotation of the sprite)
"name",                  -- string  -- The name that will be given to the projectile. Used for the GMObject creation.

-- Below are the variables that are set by the library for getting (Should not be set outside or using library functions).
-- These can be read with <projectileInstance>:get("Projectile_<variable_name>")
-- Example: projectileInstance:get("Projectile_dead")

--"hit_number"           -- number  -- The amount of actors hit on the current frame.
--"total_hit_number"     -- number  -- The total amount of actors hit.
--"dead"                 -- number  -- The death status of the projectile. See the above comments. Can be changed manually in object callbacks.
--"parent"               -- number  -- The parent instance ID of the projectile.
--"active"               -- number  -- Is 0 if the projectile logic is not being run. Should be 1 otherwise. Can be changed manually.
--"team"                 -- string  -- The team the projectile belongs to. Inherited from the parent on Projectile.fire().
}

local defaults = {
-- ["sprite"]
-- ["hitsprite"]
-- ["deathsprite_life"]
-- ["deathsprite_collision"]
-- ["deathsprite_hit"]
-- ["mask"]

-- ["damager_variables"]

-- ["life"]
-- ["rotate"]
-- ["bounce"]

["vx"]                 = 0,
["vy"]                 = 0,
["ax"]                 = 0,
["ay"]                 = 0,
["damage"]             = 0,
["pierce"]             = 0,
["explosion"]          = 0,
["damager_properties"] = 0,
["ghost"]              = 0,
["multihit"]           = 0,
["explosionw"]         = 0,
["explosionh"]         = 0,
["impact_explosion"]   = 0,
}

local p_actors = ParentObject.find("actors")

local PREFIX = "Projectile_"
local Projectile = {}

local sprite_cache = {}

local projectileCallbacks = {}


--####################--
-- Utilitiy Functions --
--####################--

-- This section can't be used in outside code

-- Triggers the given callback
function triggerCallback(o_projectile, callbackname, ...)
	local callbacks = projectileCallbacks[o_projectile]
	if not callbacks then return nil end
	callbacks = callbacks[callbackname]
	if callbacks then
		for k,v in ipairs(callbacks) do
			v(...)
		end
	end
end

-- Gets the sprite of the projectile from its variable name
local function getSprite(i_projectile, name)
	local name = name or ""
	local sprite = sprite_cache[i_projectile:get(PREFIX..name)]
	--## COMPAT ##--
	if (not sprite) and name:find("deathsprite_") then
		local i = #death_causes
		repeat
			local sprite_name = i_projectile:get(PREFIX.."deathsprite_"..death_causes[i])
			sprite = sprite_cache[sprite_name]
			i = i - 1
		until ((sprite ~= nil) or (i <= 0))
	end
	--## COMPAT ##--
	return sprite
end

-- Mirrors the table's variables to the instance
local function tableToInstance(t, i)
	for k,v in pairs(t) do i:set(k, v) end
end

-- Fires and returns an explosion with the projectile
local function projectileExplosion(i_projectile, hitsprite, damager_variables)
	local parent = Projectile.getParent(i_projectile)
	if not parent then return nil end
	local damager = parent:fireExplosion(
		i_projectile.x,
		i_projectile.y,
		i_projectile:get(PREFIX.."explosionw")/(19*2),
		i_projectile:get(PREFIX.."explosionh")/(4*2),
		i_projectile:get(PREFIX.."damage"),
		hitsprite,
		nil,
		i_projectile:get(PREFIX.."damager_properties")
	)
	tableToInstance(damager_variables, damager)
	return damager
end

-- Fires and returns a bullet with the projectile
local function projectileBullet(i_projectile, hitsprite, damager_variables, i_target)
	local parent = Projectile.getParent(i_projectile)
	if not parent then return nil end
	local direction = math.sign(i_target.x - i_projectile.x)
	local damager = parent:fireBullet(
		i_target.x - direction * 16,
		i_target.y,
		90 * (1 - direction),
		16,
		i_projectile:get(PREFIX.."damage"),
		hitsprite,
		i_projectile:get(PREFIX.."damager_properties")
	):set("specific_target", i_target.id)
	tableToInstance(damager_variables, damager)
	return damager
end

-- Used since getData isn't being used
local function cleanProperties(properties)
	for k,v in pairs(variables) do
		local value = properties[v]
		if value ~= nil then
			if type(value) == "Sprite" then
				sprite_cache[value:getName()] = value
				properties[v] = value:getName()
			end
			
			--## COMPAT ##--
			if type(value) == "boolean" then
				properties[v] = (value == true) and 1 or 0
			end
			--## COMPAT ##--
		end
	end
end


--###################--
-- Library Functions --
--###################--

-- Starts and stops the projectile logic. Stopping also stops the life countdown
function Projectile.start(i_projectile) if i_projectile:get(PREFIX.."dead") == 0 then i_projectile:set(PREFIX.."active", 1) end end
function Projectile.stop(i_projectile)  if i_projectile:get(PREFIX.."dead") == 0 then i_projectile:set(PREFIX.."active", 0) end end

-- Gets the parent of the projectile
function Projectile.getParent(i_projectile)
	if not i_projectile:isValid() then return nil end
	local parent = Object.findInstance(i_projectile:get(PREFIX.."parent") or -1)
	if parent and parent:isValid() and isa(parent, "ActorInstance") then
		return parent
	end
end

-- Adds a projectile callback to the projectile object
-- The function f will be called with the parameters of the callback
-- onCollide : Runs when there is a collision with an actor regardless of team or damage (passes the instance, actor, hit table in order)
-- preHit : Runs before doing damage to an actor (passes the instance, actor, hit table in order)
function Projectile.addCallback(o_projectile, callbackname, f)
	if not projectileCallbacks[o_projectile] then projectileCallbacks[o_projectile] = {} end
	if not projectileCallbacks[o_projectile][callbackname] then projectileCallbacks[o_projectile][callbackname] = {} end
	table.insert(projectileCallbacks[o_projectile][callbackname], f)
end

-- Makes a new projectile out of the given property table
-- Returns the GMObject of the projectile
-- Use Projectile.fire() to fire the object
function Projectile.new(properties)
	local o_projectile = Object.new(properties.name)
	
	if properties.sprite then
		o_projectile.sprite = properties.sprite
	end
	
	cleanProperties(properties)
	
	o_projectile:addCallback("create", function(i_projectile)
		i_projectile:set(PREFIX.."dead", 0)
		local data = i_projectile:getData()
		data.hits = {}
		data.damager_variables = {}
		for k,v in pairs(variables) do
			local value = properties[v]
			if type(value) == "table" then
				data[v] = value
			elseif (i_projectile:get(PREFIX..v) == nil) or (value ~= nil) then
				i_projectile:set(PREFIX..v, value or defaults[v])
			end
		end
		local sprite = getSprite(i_projectile, "sprite")
		if sprite then i_projectile.sprite = sprite end
		local mask = getSprite(i_projectile, "mask")
		if mask then i_projectile.mask = getSprite(i_projectile, "mask") end
	end)
	
	o_projectile:addCallback("step", function(i_projectile)
		i_projectile:set(PREFIX.."hit_number", 0)
		
		if i_projectile:get(PREFIX.."active") == 0 then
			return nil
		end
		
		local life = i_projectile:get(PREFIX.."life")
		local dead = i_projectile:get(PREFIX.."dead")
		
		if life then
			i_projectile:set(PREFIX.."life", life - 1)
			life = life - 1
			if (life <= 0) and (dead == 0) then
				i_projectile:set(PREFIX.."dead", 1)
				return nil
			end
		end
		
		if dead and (dead ~= 0) then
			if dead > 0 then
				local sprite = getSprite(i_projectile, "deathsprite_"..death_causes[dead])
				if sprite then i_projectile.sprite = sprite end
				i_projectile.subimage = 1
				
				dead = -math.abs(dead)
				i_projectile:set(PREFIX.."dead", dead)
				
				life = -1
				i_projectile:set(PREFIX.."life", life)
			end
			
			local frames = 1
			local sprite = i_projectile.sprite
			if sprite then frames = sprite.frames end
			local sprite_speed = i_projectile.spriteSpeed or 1
			if math.abs(life) >= (frames/sprite_speed + 1) then
				-- Don't know if this is needed
				local data = i_projectile:getData()
				data.hits = nil
				data.damager_variables = nil
				
				i_projectile:destroy()
			end
			
			return nil
		end
		
		local parent = Projectile.getParent(i_projectile)
		local data = i_projectile:getData()
		local hits = data.hits
		local damager_variables = data.damager_variables
		local hitsprite = getSprite(i_projectile, "hitsprite")
		if parent then
			for _,i_actor in ipairs(p_actors:findAll()) do
				local collides = i_actor:collidesWith(i_projectile, i_actor.x, i_actor.y)
				if collides then
					triggerCallback(o_projectile, "onCollide", i_projectile, i_actor, hits)
					local different_team = i_actor:get("team") ~= parent:get("team")
					if different_team and (not hits[i_actor]) then
						triggerCallback(o_projectile, "preHit", i_projectile, i_actor, hits)
						if i_projectile:get(PREFIX.."explosion") == 1 then
							projectileExplosion(i_projectile, hitsprite, damager_variables)
						else
							projectileBullet(i_projectile, hitsprite ,damager_variables, i_actor)
						end
						i_projectile:set(PREFIX.."hit_number", i_projectile:get(PREFIX.."hit_number") + 1)
						if i_projectile:get(PREFIX.."multihit") ~= 1 then
							hits[i_actor] = true
						end
						if i_projectile:get(PREFIX .."pierce") == 0 then
							i_projectile:set(PREFIX.."dead", 3)
							return nil
						end
					end
				end
			end
		end
		
		-- See Notes
		--## COMPAT ##--
		local vx = i_projectile:get(PREFIX.."vx")
		local ax = i_projectile:get(PREFIX.."ax")
		local vy = i_projectile:get(PREFIX.."vy")
		local ay = i_projectile:get(PREFIX.."ay")
		i_projectile.x = i_projectile.x + vx
		i_projectile.y = i_projectile.y + vy
		i_projectile:set(PREFIX.."vx", vx + ax)
		i_projectile:set(PREFIX.."vy", vy + ay)
		--## COMPAT ##--
		
		local rotate = i_projectile:get(PREFIX.."rotate")
		if rotate ~= nil then
			i_projectile.xscale = 1
			local angle = math.deg(math.atan2(-vy,vx))
			i_projectile.angle = (i_projectile:get(PREFIX .. "rotate") + angle) % 360
		end
		
		local xprevious, yprevious = i_projectile.x - vx, i_projectile.y - vy
		local collides = i_projectile:collidesMap(i_projectile.x, i_projectile.y)
		local prev_collides = i_projectile:collidesMap(xprevious, yprevious)
		if collides then
			if (not prev_collides) and (i_projectile:get(PREFIX.."impact_explosion") == 1) then
				projectileExplosion(i_projectile, hitsprite, damager_variables)
			end

			local bounce = i_projectile:get(PREFIX.."bounce")
			if bounce then
				local hcollision = i_projectile:collidesMap(xprevious, i_projectile.y)
				if not hcollision then
					i_projectile:set(PREFIX.."vx", -vx * bounce)
					i_projectile.x = xprevious
				end
				
				local vcollision = i_projectile:collidesMap(i_projectile.x, yprevious)
				if not vcollision then
					i_projectile:set(PREFIX.."vy", -vy * bounce)
					i_projectile.y = yprevious
				end
			elseif i_projectile:get(PREFIX.."ghost") ~= 1 then
				i_projectile:set(PREFIX.."dead", 2)
				return nil
			end
		end
	end)
	
	return o_projectile
end

-- This function fires a given projectile object and returns the instance that has been fired
function Projectile.fire(o_projectile, x, y, parent, direction)
	local direction = direction or parent.xscale
	
	local i_projectile = o_projectile:create(x,y)
	
	i_projectile
	:set(PREFIX.."vx", i_projectile:get(PREFIX.."vx") * direction)
	:set(PREFIX.."ax", i_projectile:get(PREFIX.."ax") * direction)
	:set(PREFIX.."parent", parent.id)
	:set(PREFIX.."team", parent:get("team"))
	
	i_projectile.xscale = direction
	
	return i_projectile
end

-- Changes the variables of a given projectile instance
-- Use with GMObject callbacks with the given projectile object from Projectile.new()
function Projectile.configure(i_projectile, properties)
	if i_projectile:get(PREFIX.."dead") ~= 0 then return nil end
	cleanProperties(properties)
	local data = i_projectile:getData()
	for k,v in pairs(variables) do
		local value = properties[v]
		if type(value) == "table" then
			data[v] = value
		elseif value ~= nil then
			i_projectile:set(PREFIX..v, value)
		end
	end
	local sprite = getSprite(i_projectile, "sprite")
	if sprite then i_projectile.sprite = sprite end
	local mask = getSprite(i_projectile, "mask")
	if mask then i_projectile.mask = getSprite(i_projectile, "mask") end
end

-- Aims projectiles that have standard projectile motion (Only having horizontal acceleration)
-- Shouldn't be used for projectiles without acceleration
-- Target can be an instance or table with x and y keys
-- Bidirectional ignores the horizontal direction of the projectile (Can aim backwards changing the direction that the projectile was moving)
-- Speed dictates the magnitude of speed of the projectile. If not given it's current speed is used.
function Projectile.aim(i_projectile, target, bidirectional, speed)
	if not target then return nil end
	if i_projectile:get(PREFIX .. "dead") ~= 0 then return nil end
	local target_instance = isa(target, "Instance") and target:isValid()
	local target_table = (type(target) == "table") and target.x and target.y
	if target_instance or target_table then
		local _pvx = i_projectile:get(PREFIX.."vx")
		local _pvy = i_projectile:get(PREFIX.."vy")
		local speed = speed or math.sqrt((_pvx)^2 + (_pvy)^2)
		local _a = target.x - i_projectile.x
		local _b = i_projectile:get(PREFIX.."ay")/2
		local _c = speed
		local _d = target.y - i_projectile.y
		
		if (not bidirectional) and ( ((_a < 0) and (_pvx > 0)) or ((_a > 0) and (_pvx < 0)) ) then
			return nil
		end
		
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
				Projectile.configure(i_projectile, { vx = _vx, vy = _vy })
			end
		end
	end
end


--#########--
-- Exports --
--#########--

export("CycloneLib.Projectile", Projectile)
return Projectile
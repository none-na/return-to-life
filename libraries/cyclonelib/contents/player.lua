-- CycloneLib - contents/player.lua

-- Dependencies:
---- Nothing

local player = {}

--[[
This block somewhat works for vanilla survivors but of course causes skills to be activated which have side effects
Modded survivors have only a single skill forced
--]]

--[[
local SKILL_COOLDOWNS = {}

local gather_cooldown = 0
callback.register("onGameStart", function() gather_cooldown = 1 end)
callback.register("onGameEnd", function() gather_cooldown = 0 end)

local function setForceSkill(player, value)
	for _,skill in ipairs({"z","x","c","v"}) do
		player:set("force_"..skill, value)
	end
end

callback.register("onStep", function()
	for _,player in ipairs(misc.players) do
		local survivor = player:getSurvivor()
		if gather_cooldown == 1 then
			if not SKILL_COOLDOWNS[survivor] then
				setForceSkill(player, 1)
			end
			gather_cooldown = 2
		elseif gather_cooldown == 2 then
			local cooldowns = {}
			for i=1,4 do
				cooldowns[i] = player:getAlarm(i + 1) + 1
				player:set("activity", 0)
				-- The default for activity_type is 2 but 0 resets the skill activity for some reason
				player:set("activity_type", 0)
				player:set("activity_var1", 0)
				player:set("activity_var2", 0)
				setForceSkill(player, 0)
				player:setAlarm(i + 1, 0)
			end
			SKILL_COOLDOWNS[survivor] = cooldowns
			gather_cooldown = 0
		end
	end
end)
--]]

-- For index 1-4 this returns the time until skill is off cooldown in frames, nil and the cooldown reduction
-- (It can't return base cooldown or cooldown reduction because of RoRML limitations)
-- For index 5 it returns the time until the item is off cooldown in frames, the base cooldown in frames and the cooldown reduction
-- Cooldown reduction ranges from 0 to 1 (0 being base cooldown, 1 being no cooldown)
player.getCooldown = function(player, index)
	if not isa(player, "PlayerInstance") then return nil end
	local cooldown, base_cooldown, cooldown_reduction
	if index == 1 then
		cooldown = player:getAlarm(index + 1) + 1
		cooldown_reduction = 1 - 1/player:get("attack_speed")
	elseif index == 5 then
		cooldown = player:getAlarm(0) + 1
		cooldown_reduction = 1 - player:get("use_cooldown")/45
		local item = player.useItem
		if item then
			base_cooldown = item.useCooldown * 60
		end
	else
		index = math.floor(math.clamp(index, 2, 4))
		cooldown = player:getAlarm(index + 1) + 1
		cooldown_reduction = player:get("cdr")
	end
	return cooldown, base_cooldown, cooldown_reduction
end

-- Returns the index of the player in misc.players
player.index = function(player)
	if (not isa(player, "PlayerInstance")) or (not player:isValid()) then return nil end
	for i,_player in ipairs(misc.players) do
		if _player == player then
			return i
		end
	end
end


--#########--
-- Exports --
--#########--

export("CycloneLib.player", player)
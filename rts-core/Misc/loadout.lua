--loadout.lua

require("Libraries.skill.main")

local empty = Sprite.load("Graphics/empty", 1, 0, 0)

Loadout = {}


SurvivorToIDs = {}
IDsToSurvivor = {}
local ids = 0


SkillSlots = {
    Passive = 0,
    Primary = 1,
    Secondary = 2,
    Utility = 3,
    Special = 4,
    Skin = 5,
}

SlotToName = {
    [0] = "Passive",
    [1] = "Primary",
    [2] = "Secondary",
    [3] = "Utility",
    [4] = "Special",
    [5] = "Skin",
}

SlotToSkill = {
    ["Primary"] = 1,
    ["Secondary"] = 2,
    ["Utility"] = 3,
    ["Special"] = 4,
}

local localLoadouts = {}

local playerLoadouts = {}

Loadout.findFromSurvivor = function(survivor)
    for _, loadout in pairs(localLoadouts) do
        if loadout.survivor == survivor then
            return loadout
        end
    end
    return nil
end

Loadout.findAll = function()
    return localLoadouts
end

local mobSkills = Sprite.find("MobSkills", "vanilla")

----------------------------------------------------------------


local noPassive = Skill.new()

noPassive.displayName = "Disable Passive"
noPassive.icon = mobSkills
noPassive.iconIndex = 3
noPassive.cooldown = -1

local underConstruction = Skill.new()

underConstruction.displayName = "Under Construction"
underConstruction.description = "This is under construction and will be added in in a future update."
underConstruction.icon = Sprite.load("Graphics/underconstruction", 1, 0, 0)
underConstruction.iconIndex = 1
underConstruction.cooldown = -1


Loadout.PresetSkills = {
    NoPassive = noPassive,
    Unfinished = underConstruction,
}



---------------------------------------------------------------

-- Adds a new loadout to the Loadout system.
Loadout.new, loadout_mt = newtype("Loadout")

function loadout_mt:__init()
    localLoadouts[self] = {}
    localLoadouts[self].survivor = nil
    localLoadouts[self].description = "Information Unset"
    localLoadouts[self].slotCount = 0
    localLoadouts[self].iteration = {}
    localLoadouts[self].iteration.start = 0
    -- Prepare skills slots
    localLoadouts[self].skillSlots = {}
    for i = 0, 5 do
        localLoadouts[self].skillSlots[SlotToName[i]] = {}
        localLoadouts[self].skillSlots[SlotToName[i]].name = SlotToName[i]
        localLoadouts[self].skillSlots[SlotToName[i]].index = localLoadouts[self].slotCount
        localLoadouts[self].skillSlots[SlotToName[i]].displayOrder = localLoadouts[self].slotCount
        localLoadouts[self].skillSlots[SlotToName[i]].count = 0
        localLoadouts[self].skillSlots[SlotToName[i]].current = nil
        localLoadouts[self].skillSlots[SlotToName[i]].showInLoadoutMenu = true
        localLoadouts[self].skillSlots[SlotToName[i]].showInCharSelect = true
        localLoadouts[self].skillSlots[SlotToName[i]].skills = {}
        if SlotToName[i] == "Skin" then
            localLoadouts[self].skillSlots[SlotToName[i]].showInCharSelect = false
        elseif SlotToName[i] == "Passive" then
            localLoadouts[self].skillSlots[SlotToName[i]].showInCharSelect = false
            localLoadouts[self].skillSlots[SlotToName[i]].displayOrder = -1
            localLoadouts[self].skillSlots[SlotToName[i]].showInLoadoutMenu = false
        end
        localLoadouts[self].iteration.last = localLoadouts[self].slotCount
        localLoadouts[self].slotCount = localLoadouts[self].slotCount + 1
    end
    localLoadouts[self].icons = {}
    localLoadouts[self].iconCount = 0
end

-- Updates the character select screen to reflect the passed in loadout.
Loadout.Update = function(loadout)
    local ldData = loadout
    if localLoadouts[loadout] then ldData = localLoadouts[loadout] end
    for i = 1, 4 do
        loadout.survivor:setLoadoutSkill(i, "", "")
    end
    if ldData.skillSlots["Skin"] and ldData.skillSlots["Skin"].current then
        for key, sprite in pairs(ldData.skillSlots["Skin"].current.sprites) do
            if sprite then
                if key == "loadout" then
                    loadout.survivor.loadoutSprite = sprite
                elseif key == "walk" then
                    loadout.survivor.titleSprite = sprite
                elseif key == "idle" then
                    loadout.survivor.idleSprite = sprite
                end
            end
        end
    end
    loadout.survivor:setLoadoutInfo(ldData.description, empty)
end

--Applies the loadout to a player instance.
-- Parameters:
    -- loadout: The loadout to apply.
    -- player: The player instance to apply to. The player's survivor must match the loadout's survivor.
    -- targetSlot: Optional. The name of a slot you wish to apply to. Only applies to the given slot.
Loadout.Apply = function(loadout, player, targetSlot)
    if type(player) == "PlayerInstance" then
        local l = loadout
        if localLoadouts[loadout] then l = localLoadouts[loadout] end
        if player:getSurvivor() == l.survivor then
            local data = player:getData()
            data.Loadout = {}
            if targetSlot then
                if l.skillSlots[targetSlot] then
                    local slot = l.skillSlots[targetSlot]
                    --...then apply the current effects
                    if slot.current.apply then
                        slot.current.apply(player)
                    end
                    
                    data.Loadout[slot.name] = slot.current
                    if SlotToSkill[targetSlot] then
                        Skill.set(player, SlotToSkill[targetSlot], l.skillSlots[targetSlot].current.obj)
                    end
                    if targetSlot == "Skin" and l.skillSlots["Skin"] and l.skillSlots["Skin"].current then
                        for key, sprite in pairs(l.skillSlots["Skin"].current.sprites) do
                            if sprite then
                                if key == "loadout" then
                                    loadout.survivor.loadoutSprite = sprite
                                elseif key == "walk" then
                                    loadout.survivor.titleSprite = sprite
                                    player:setAnimation(key, sprite)
                                elseif key == "idle" then
                                    loadout.survivor.idleSprite = sprite
                                    player:setAnimation(key, sprite)
        
                                else
                                    player:setAnimation(key, sprite)
                                end
                            end
                        end
                    end
                else
                    error("Invalid slot.")
                end
            else
                for _, slot in pairs(l.skillSlots) do
                    data.Loadout[slot.name] = slot.current
                    if slot.name ~= "Skin" then
                        if slot.current then
                            if slot.current.apply then
                                slot.current.apply(player)
                            end
                        end
    
                    end
                end
                -- Set player's Z, X, C, and V skills
                for i = 1, 4 do
                    Skill.set(player, i, l.skillSlots[SlotToName[i]].current.obj)
                end
                -- Set player's skin
                if l.skillSlots["Skin"] and l.skillSlots["Skin"].current then
                    for key, sprite in pairs(l.skillSlots["Skin"].current.sprites) do
                        if sprite then
                            if key == "loadout" then
                                if not net.online then loadout.survivor.loadoutSprite = sprite end
                            elseif key == "walk" then
                                if not net.online then loadout.survivor.titleSprite = sprite end
                                player:setAnimation(key, sprite)
                            elseif key == "idle" then
                                if not net.online then loadout.survivor.idleSprite = sprite end
                                player:setAnimation(key, sprite)
                            else
                                player:setAnimation(key, sprite)
                            end
                        end
                    end
                end
            end
            playerLoadouts[player] = loadout
            
        else
            error("Incorrect survivor.")
        end
    else
        error("Invalid type for loadout:apply player - player must be a PlayerInstance")
    end
end


local SyncLoadoutChange = net.Packet.new("Sync Loadout Change", function(playerIndex, netPlayer, slotName, itemName)
    local player = misc.players[netPlayer:resolve().playerIndex]
    if player and player:isValid() then
        local loadout = Loadout.findFromSurvivor(player:getSurvivor())
        if loadout and loadout.skillSlots[slotName] then
            local slot = loadout.skillSlots[slotName]
            local skill = nil
            for _, s in pairs(slot.skills) do
                if s.displayName == itemName then
                    skill = s
                    break
                end
            end
            if skill then
                if slotName == "Skin" then
                    -- Set player's skin
                    if skill.sprites then
                        for key, sprite in pairs(skill.sprites) do
                            if sprite then
                                if key == "loadout" then
                                    if not net.online then loadout.survivor.loadoutSprite = sprite end
                                elseif key == "walk" then
                                    if not net.online then loadout.survivor.titleSprite = sprite end
                                    player:setAnimation(key, sprite)
                                elseif key == "idle" then
                                    if not net.online then loadout.survivor.idleSprite = sprite end
                                    player:setAnimation(key, sprite)
                                else
                                    player:setAnimation(key, sprite)
                                end
                            end
                        end
                    end
                else
                    if skill.apply then
                        skill.apply(player)
                    end
                    if SlotToSkill[slotName] then
                        Skill.set(player, SlotToSkill[slotName], skill.obj)
                    end
                end
            end
        end
    end
end)

local SyncClientLoadoutChange = net.Packet.new("Sync Client-side Loadout Change", function(playerIndex, netPlayer, slotName, itemName)
    local player = misc.players[netPlayer:resolve().playerIndex]
    if player and player:isValid() then
        local loadout = Loadout.findFromSurvivor(player:getSurvivor())
        if loadout and loadout.skillSlots[slotName] then
            local slot = loadout.skillSlots[slotName]
            local skill = nil
            for _, s in pairs(slot.skills) do
                if s.displayName == itemName then
                    skill = s
                    break
                end
            end
            if skill then
                if slotName == "Skin" then
                    -- Set player's skin
                    if skill.sprites then
                        for key, sprite in pairs(skill.sprites) do
                            if sprite then
                                if key == "loadout" then
                                    if not net.online then loadout.survivor.loadoutSprite = sprite end
                                elseif key == "walk" then
                                    if not net.online then loadout.survivor.titleSprite = sprite end
                                    player:setAnimation(key, sprite)
                                elseif key == "idle" then
                                    if not net.online then loadout.survivor.idleSprite = sprite end
                                    player:setAnimation(key, sprite)
                                else
                                    player:setAnimation(key, sprite)
                                end
                            end
                        end
                    end
                else
                    if skill.apply then
                        skill.apply(player)
                    end
                    if SlotToSkill[slotName] then
                        Skill.set(player, SlotToSkill[slotName], skill.obj)
                    end
                end
                SyncLoadoutChange:sendAsHost(net.EXCLUDE, player, player:getNetIdentity(), slotName, itemName)
            end
        end
    end
end)

--Applies the loadout to a player instance. Finds the loadout Only for use in online multiplayer.
-- Parameters:
    -- loadout: The loadout to apply.
    -- player: The player instance to apply to. The player's survivor must match the loadout's survivor.
    -- targetSlot: Optional. The name of a slot you wish to apply to. Only applies to the given slot.
Loadout.ApplyMult = function(playerID, targetSlot)
    if net.online then
        local player = misc.players[playerID]
        if player and player:isValid() and player == net.localPlayer then
            local loadout = playerLoadouts[playerID]
            if loadout and loadout.survivor == player:getSurvivor() then
                if targetSlot then
                    Loadout.Apply(loadout, player, targetSlot)
                else
                    Loadout.Apply(loadout, player)
                end
                for _, slot in pairs(loadout.skillSlots) do
                    if slot.current then
                        if net.host then
                            SyncLoadoutChange:sendAsHost("all", nil, player:getNetIdentity(), slot.name, slot.current.displayName)
                        else
                            SyncClientLoadoutChange:sendAsClient(player:getNetIdentity(), slot.name, slot.current.displayName)
                        end
                    end
                end
            end
        end
    else
        error("Loadout.ApplyMult() is only for use in online multiplayer.")
    end
end


-- Applies player loadouts at the start of every run.
callback.register("onPlayerInit", function(player)
    if Loadout.findFromSurvivor(player:getSurvivor()) then
        if not net.online then
            Loadout.Apply(Loadout.findFromSurvivor(player:getSurvivor()), player)            
        end
    end
end)
callback.register("onPlayerStep", function(player)
    if net.online then
        if Loadout.findFromSurvivor(player:getSurvivor()) then
            local data = player:getData()
            if not data.initLoadout then
                Loadout.ApplyMult(player.playerIndex)
                data.initLoadout = true
            end
        end
    end
end)

-- Runs the remove function for the current skill in a player's given slot.
-- Hard-remove is ran upon applying the loadout to a player.
Loadout.Remove = function(loadout, player, slot, hardRemove)
    if loadout.skillSlots[slot].current.remove then
        loadout.skillSlots[slot].current.remove(player, hardRemove)
    end
end


local loadout_lookup = {
    survivor = {
        get = function(self)
            return localLoadouts[self].survivor
        end,
        set = function(self, var)
            if not type(var) == "Survivor" then error("Invalid type for loadout.survivor, must be a Survivor.") end
            localLoadouts[self].survivor = var
        end
    },
    description = {
        get = function(self)
            return localLoadouts[self].description
        end,
        set = function(self, var)
            if not type(var) == "string" then error("Invalid type for loadout.description, must be a string.") end
            localLoadouts[self].description = var
        end
    },
    -- Adds a new slot to the loadout.
    -- Returns the newly created slot.
    -- Parameters:
        -- name: The new name of the slot.
    addSlot = function(s, name)
        localLoadouts[s].skillSlots[name] = {}
        localLoadouts[s].skillSlots[name].name = name
        localLoadouts[s].skillSlots[name].index = localLoadouts[s].slotCount + 1
        localLoadouts[s].skillSlots[name].displayOrder = localLoadouts[s].slotCount + 1
        localLoadouts[s].iteration.last = localLoadouts[s].iteration.last + 1
        localLoadouts[s].slotCount = localLoadouts[s].slotCount + 1
        localLoadouts[s].skillSlots[name].count = 0
        localLoadouts[s].skillSlots[name].current = nil
        localLoadouts[s].skillSlots[name].showInLoadoutMenu = true
        localLoadouts[s].skillSlots[name].showInCharSelect = true
        localLoadouts[s].skillSlots[name].skills = {}
        return localLoadouts[s].skillSlots[name]
    end,
    -- Returns a skill slot based on the passed in slot parameter. Returns nil if nothing is found.
    -- Parameters:
        -- slot: The slot to return. Can either be a number or a string:
            -- passing in a string will search based on the slot's name.
            -- passing in an int will search based on two variables, controlled by the parameter searchBy (see below).
        -- searchBy: Optional. Pass in to specify which variable you want to use when looking for a slot.
            -- 0: Searches by the slot's index. Defaults to this if not specified.
            -- 1: Searches by the slot's displayOrder.
    getSlot = function(s, slot, searchBy)
        if type(slot) == "string" then
            return localLoadouts[s].skillSlots[slot]
        elseif type(slot) == "number" then
            local var = "index"
            if searchBy and searchBy == 1 then
                var = "displayOrder"
            end
            local result = nil
            for _, s in pairs(localLoadouts[s].skillSlots) do
                for v, k in pairs(s) do
                    if k == var then
                        if v == slot then
                            return s
                        end
                    end
                end
            end
        end
        return nil
    end,
    -- Returns all the skill slots for the loadout.
    getAllSlots = function(s)
        return localLoadouts[s].skillSlots
    end,
    --Adds a skill to the specified slot. 
    -- If the slot doesn't have a current skill, then the added skill will be set as the slot's currently selected skill.
    -- Returns the newly created skill entry.
    -- Parameters:
        -- slot: The slot to add the skill to.
        -- obj: The skill object to add.
        -- info: A table of variables. Used for things like menus and visual feedback.
            -- Not passing anything in to this will use the skill's matching info instead.
            -- displayName: The name displayed for the skill.
            -- icon: The sprite used for the skill's icon.
            -- subimage: The subimage of the skill's icon.
            -- hudDescription: The description of the skill shown when the player hovers over it in the game's HUD.
            -- loadoutDescription: The description of the skill shown in the character select screen and loadout menu. Supports colored text.
            -- hidden: Whether or not the skill should be hidden on the loadout menu. Defaults to false.
            -- locked: Whether or not the skill should start off locked. Defaults to false.
            -- apply: A function that takes in a player instance. Ran when the skill is applied to the player. Useful for initializing variables.
            -- remove: A function that takes in a player instance, and an optional bool. Ran if the skill is removed from a player. 
                --The optional bool determines if the function should hard-remove the effects. This is useful if you want to set a variable to a specific
                --value without worrying about its current value.
                --Useful for cleaning up any variables set by the skill.
            -- upgrade: A skill entry that the skill "upgrades" to - i.e, Ancient Scepter.
            -- unlockText: Text displayed on the loadout menu - typically the requirements to unlock a locked skill.
    addSkill = function(s, slot, skill, info)
        if localLoadouts[s].skillSlots[slot] then
            local s = localLoadouts[s].skillSlots[slot]
            local skillEntry = {}
            skillEntry.obj = skill
            skillEntry.index = s.count
            skillEntry.locked = false
            skillEntry.hidden = false
            skillEntry.displayName = skill.displayName
            skillEntry.icon = skill.icon
            skillEntry.subimage = skill.iconIndex
            skillEntry.loadoutDescription = skill.description
            skillEntry.hudDescription = skill.description
            if info then
                if info.displayName then skillEntry.displayName = info.displayName end
                if info.icon then skillEntry.icon = info.icon end
                if info.subimage then skillEntry.subimage = info.subimage end
                if info.hudDescription then skillEntry.hudDescription = info.hudDescription end
                if info.loadoutDescription then skillEntry.loadoutDescription = info.loadoutDescription end
                if info.locked then skillEntry.locked = info.locked end
                if info.hidden then skillEntry.hidden = info.hidden end
                if info.apply then skillEntry.apply = info.apply end
                if info.remove then skillEntry.remove = info.remove end
                if info.upgrade then skillEntry.upgrade = info.upgrade end
                if info.unlockText then skillEntry.unlockText = info.unlockText end
            end
            table.insert(s.skills, s.count, skillEntry)
            s.count = s.count + 1
            if not s.current and not skillEntry.hidden and not skillEntry.locked then
                s.current = skillEntry
            end
            return skillEntry
        else
            error("Loadout slot is invalid.")
        end
    end,
    --Adds a skin to the loadout.
    --Behaves similarly to loadout:addSkill(), but doesn't return anything.
    -- Parameters:
        -- Uses similar parameters to loadout:addSkill(), but with some changes.
        -- No slot.
        -- sprites: An array of sprites for the skin to use.
            -- Make sure these sprites are keyed based on the actor's animation keys!
        -- info: A table of variables. Takes the same arguments as loadout:addSkill()'s info.
    addSkin = function(s, obj, sprites, info)
        if localLoadouts[s].skillSlots["Skin"] then
            local slot = localLoadouts[s].skillSlots["Skin"]
            local skinEntry = {}
            skinEntry.obj = obj
            skinEntry.locked = false
            skinEntry.sprites = sprites
            skinEntry.displayName = obj.displayName
            skinEntry.icon = obj.icon
            skinEntry.subimage = obj.iconIndex
            skinEntry.loadoutDescription = obj.description
            skinEntry.hudDescription = obj.description
            if info then
                if info.displayName then skinEntry.displayName = info.displayName end
                if info.icon then skinEntry.icon = info.icon end
                if info.subimage then skinEntry.subimage = info.subimage end
                if info.hudDescription then skinEntry.hudDescription = info.hudDescription end
                if info.loadoutDescription then skinEntry.loadoutDescription = info.loadoutDescription end
                if info.locked then skinEntry.locked = info.locked end
                if info.hidden then skinEntry.hidden = info.hidden end
                if info.apply then skinEntry.apply = info.apply end
                if info.remove then skinEntry.remove = info.remove end
                if info.upgrade then skinEntry.upgrade = info.upgrade end
                if info.unlockText then skinEntry.unlockText = info.unlockText end
            end
            table.insert(slot.skills, slot.count, skinEntry)
            slot.count = slot.count + 1
            if not slot.current then
                slot.current = skinEntry
            end
        else
            error("Loadout slot \"Skin\" is invalid.")
        end
    end,
    -- Returns a Skill Entry based on the passed in skill. Returns nil otherwise.
    getSkillEntry = function(s, skill)
        for _, slot in pairs(localLoadouts[s].skillSlots) do
            for _, skillEntry in ipairs(slot.skills) do
                if skillEntry.obj and skillEntry.obj == skill then
                    return skillEntry
                end
            end
        end
        return nil
    end,
    -- Returns all Skill Entries for a given slot.
    getAllSkillEntries = function(s, slot)
        return localLoadouts[s].skillSlots[slot].skills
    end,
    -- Returns a Skill Entry based on the passed in skill name. Searches by checking the skills' Display Names. Returns nil otherwise.
    searchSkill = function(s, skillName)
        for _, slot in pairs(localLoadouts[s].skillSlots) do
            for _, skillEntry in ipairs(slot.skills) do
                if skillEntry.displayName and skillEntry.displayName == skillName then
                    return skillEntry
                end
            end
        end
        return nil
    end,
    -- Sets the current skill entry for a slot.
    -- Parameters:
        -- slot: The slot to set.
        -- skill: The skill to set to.
    setCurrentSkill = function(s, slot, skill)
        localLoadouts[s].skillSlots[slot].current = s:getSkillEntry(s, skill)
    end,
    -- Returns the current skill entry of the passed in slot.
    getCurrentSkill = function(s, slot)
        return localLoadouts[s].skillSlots[slot].current
    end,
}

loadout_mt.__index = function(t, k)
	local s = loadout_lookup[k]
	if s then
		if type(s) == "table" then
			return s.get(t)
		else
			return s
		end
	else
		error(string.format("Loadout does not contain a field '%s'", tostring(k)), 2)
	end
end

loadout_mt.__newindex = function(t, k, v)
	local s = loadout_lookup[k]
	if type(s) == "table" then
		s.set(t, v)
	else
		error(string.format("Loadout does not contain a field '%s'", tostring(k)), 2)
	end
end


--Saves the loadout to the player's file.
Loadout.Save = function(loadout)
    if localLoadouts[loadout] then loadout = localLoadouts[loadout] end
    --debugPrint("Saving loadout for survivor "..loadout.survivor:getName().." ("..loadout.survivor:getOrigin()..")")
    for _, slot in pairs(loadout.skillSlots) do
        if slot.current then
            save.write(loadout.survivor:getName().."_Loadout_"..slot.name, slot.current.displayName or "")
            --debugPrint(" - Successfully saved Slot "..slot.name.." ("..slot.current.displayName..") at \'"..loadout.survivor:getName().."_Loadout_"..slot.name.."\'.")
        end
        for _, skill in pairs(slot.skills) do
            save.write(loadout.survivor:getName().."_Loadout_"..skill.displayName.."_Locked", skill.locked)
            --debugPrint("    - Successfully saved unlock status of Skill "..skill.displayName.." at \'"..loadout.survivor:getName().."_Loadout_"..skill.displayName.."_Locked".."\'")
        end
    end
    
end
--Loads the loadout from the player's file.
-- Returns the newly loaded loadout.
Loadout.Load = function(loadout)
    local ldData = localLoadouts[loadout]
    --debugPrint("Loading loadout for survivor "..loadout.survivor:getName().." ("..loadout.survivor:getOrigin()..")")
    for _, slot in pairs(loadout.skillSlots) do
        local saveData = save.read(loadout.survivor:getName().."_Loadout_"..slot.name)
        if saveData then
            for _, skill in pairs(slot.skills) do
                if skill.displayName == saveData then
                    slot.current = skill
                    --debugPrint(" - Successfully loaded Slot "..slot.name..": "..slot.current.displayName)
                end
            end
        end
        for _, skill in pairs(slot.skills) do
            local locked = save.read(loadout.survivor:getName().."_Loadout_"..skill.displayName.."_Locked")
            if locked ~= nil then
                if locked == "true" then
                    skill.locked = true
                else
                    skill.locked = false
                end
            end
            --debugPrint("    - Successfully loaded unlock status of "..skill.displayName..": "..tostring(skill.locked))
        end
    end
    Loadout.Update(loadout)
    return loadout
end

-- Sets the skill of a given slot to its "upgraded" variant for the given player. Does nothing if no upgrade is defined (see loadout:addSkill()).
Loadout.Upgrade = function(loadout, player, slot)
    if localLoadouts[loadout] then loadout = localLoadouts[loadout] end
    if loadout.skillSlots[slot].current.upgrade then
        loadout.skillSlots[slot].current = loadout.skillSlots[slot].current.upgrade
        Loadout.Apply(loadout, player, slot)
    else
        return
    end
end

-- Automatically registers a Survivor's ID so the Loadout Menu can properly identify what each survivor is on the Character Select Screen.
-- This function is automatically called for all loaded survivors, regardless of whether or not they are supported by the Loadout system, in postLoad.
-- You probably won't need to call this unless you want to be ABSOLUTELY sure.
-- Returns the ID.
Loadout.RegisterSurvivorID = function(survivor)
    local i = ids --Find latest ID registered (may just be initial value)
    for id, s in pairs(IDsToSurvivor) do
        if id > i then i = id end -- Find latest ID registered
        if s == survivor then return id end --Survivor is already registered, return ID
    end
    i = i + 1
    SurvivorToIDs[survivor] = i
    IDsToSurvivor[i] = survivor
    ids = i
    return ids
end

--------------------------------------------------



-- Prepare Loadouts
-- Go through already loaded survivors
for _, survivor in ipairs(Survivor.findAll("vanilla")) do
    if survivor then
        if not SurvivorToIDs[survivor] then --Register unregistered survivors, just in case
            Loadout.RegisterSurvivorID(survivor)
        end
    end
end
for _, namespace in ipairs(modloader.getMods()) do
    for _, survivor in ipairs(Survivor.findAll(namespace)) do
        if survivor then
            if not SurvivorToIDs[survivor] then --Register unregistered survivors, just in case
                Loadout.RegisterSurvivorID(survivor)
            end
        end
    end
end
callback.register("postLoad", function()
    for i = 0, #modloader.getMods() - 1 do
        local mod = modloader.getMods()[i]
        for x, char in ipairs(Survivor.findAll(mod)) do
            if char then
                if not SurvivorToIDs[char] then --Register unregistered survivors, just in case
                    Loadout.RegisterSurvivorID(char)
                end
            end
        end
    end
    
    for _, loadout in pairs(Loadout.findAll()) do
        --print("Found Loadout for Survivor "..loadout.survivor:getName().." ("..loadout.survivor:getOrigin()..").")
        Skill.init(loadout.survivor)
        loadout = Loadout.Load(loadout)
        if modloader.checkFlag("ror2_debug") then
            for _, slot in pairs(loadout.skillSlots) do
                for _, skill in pairs(slot.skills) do
                    skill.locked = false
                end
            end
            Loadout.Save(loadout)
        end
    end
end, 999999999)

--------------------------------------------------

local selectScreen = Room.find("Select", "vanilla")
local selectCoOpScreen = Room.find("SelectMult", "vanilla")
local selectObj = Object.find("Select", "vanilla")
local prePlayer = Object.find("PrePlayer", "vanilla")

local menu = Object.new("LoadoutMenu")
local menuCoop = Object.new("LoadoutMenuCoop")

local menuButton = Sprite.load("LoadoutCollpase", "Graphics/menuButton", 4, 0, 0)

local constants = {
    tabsX = 16,
    tabsY = 100,
    tabsW = 352,
    tabsH = graphics.textHeight("A", graphics.FONT_DEFAULT) * 2,
    menuX = 16,
    menuY = 112,
    menuW = 352,
    menuH = 20,
}

local tabs = 2
local tabSelectThickness = 3

local tabNames = {
    [0] = "Skills",
    [1] = "Loadout",
}



local DrawSelectionBox = function(data, slot, index)
    local xx = constants.menuX
    local yy = (constants.menuY) + (constants.menuH * 1.2) * index
    graphics.color(Color.BLACK)
    graphics.alpha(0.5)
    graphics.rectangle(xx, yy, xx + constants.menuW, yy + constants.menuH)
    graphics.alpha(1)
    graphics.color(Color.fromRGB(30, 17, 17))
    graphics.rectangle(xx, yy, xx + constants.menuW, yy + constants.menuH, true)
    graphics.color(data.color)
    graphics.rectangle(xx, yy, xx + (graphics.textWidth("Secondary", graphics.FONT_DEFAULT) + 4), yy + constants.menuH)
    graphics.color(Color.WHITE)
    graphics.print(slot.name or "Information Unset", xx + 6, yy + (constants.menuH / 2), graphics.FONT_DEFAULT, graphics.ALIGN_LEFT, graphics.ALIGN_CENTER)
    local loadout = data.loadout
    local skills = {}
    if loadout then
        local i = 0
        for _, skill in pairs(slot.skills) do
            if not skill.hidden then
                local sX = xx + (graphics.textWidth("Secondary", graphics.FONT_DEFAULT) * 1.25) + (22 * (i))
                local sY = yy + 3
                local image = mobSkills
                local subimage = 1
                if skill.icon and skill.subimage then
                    if skill.locked == false then
                        image = skill.icon
                        subimage = skill.subimage
                    else
                        subimage = 2
                    end
                else
                    subimage = 3
                end
                graphics.drawImage{
                    image = image,
                    x = sX,
                    y = sY,
                    subimage = subimage,
                }
                i = i + 1
            end
        end
    end
end

local DrawToolTip = function(data, skill, x, y)
    local yy = y + 10
    local desc = skill.loadoutDescription
    if not skill.loadoutDescription then
        desc = "Information Unset"
    end
    if skill.locked then
        desc = skill.unlockText or "This item is locked."
    end
    local descriptionFormatted = desc:gsub("&[%a%p%C]&", "")
    local tooltipW = math.clamp(graphics.textWidth(descriptionFormatted, graphics.FONT_DEFAULT) + 2, graphics.textWidth(skill.displayName, graphics.FONT_DEFAULT) + 2, graphics.textWidth(descriptionFormatted, graphics.FONT_DEFAULT) + 2)
    local tooltipH = (graphics.textHeight(skill.displayName or "Information Unset", graphics.FONT_DEFAULT) + 4) + math.clamp(graphics.textHeight(descriptionFormatted, graphics.FONT_DEFAULT) + 2, graphics.textHeight(skill.displayName, graphics.FONT_DEFAULT) + 2, graphics.textHeight(descriptionFormatted, graphics.FONT_DEFAULT) + 2)
    graphics.color(Color.BLACK)
    graphics.alpha(0.5)
    graphics.rectangle(x, yy, x + tooltipW, yy + tooltipH)
    if skill.obj == Loadout.PresetSkills.Unfinished then
        graphics.color(Color.ORANGE)
    else
        if skill.locked then
            graphics.color(Color.GRAY)

        else
            graphics.color(data.color)
        end
    end
    graphics.alpha(1)
    graphics.rectangle(x, yy, x + tooltipW, yy + graphics.textHeight(skill.displayName or "Information Unset", graphics.FONT_DEFAULT) + 2)
    graphics.color(Color.WHITE)
    local name = skill.displayName or "Information Unset"
    if skill.locked then
        name = "???"
    end
    graphics.print(name, x + 5, yy + 4, graphics.FONT_DEFAULT, graphics.ALIGN_LEFT, graphics.ALIGN_TOP)
    if not skill.locked then
        local cooldown = ((skill.obj.cooldown or 0) / 60)
        if math.floor(cooldown) > 0 then
            graphics.print(math.round(cooldown) .. " sec. cooldown", x + tooltipW, yy + 4, graphics.FONT_DEFAULT, graphics.ALIGN_RIGHT, graphics.ALIGN_TOP)
        end
    end
    graphics.print(descriptionFormatted, x + 5, yy + ((graphics.textHeight(skill.displayName or "Information Unset", graphics.FONT_DEFAULT) + 2) * 1.5), graphics.FONT_DEFAULT, graphics.ALIGN_LEFT, graphics.ALIGN_TOP)
end

local DrawSkillSummary = function(data, slots)
    local yOffset = constants.menuY + 24
    for _, slot in pairs(slots) do
        local skill = slot.current
        if not skill then return end
        --------------------------------------------------
        local desc = skill.loadoutDescription
        local boxH = constants.menuH 
        if desc then
            boxH = (graphics.textHeight("A\n"..desc, graphics.FONT_DEFAULT)) + ((graphics.textHeight("A", graphics.FONT_DEFAULT)) - 9)
        end
        --------------------------------------------------
        local x = constants.menuX
        local y = yOffset
        graphics.color(Color.BLACK)
        graphics.alpha(0.5)
        graphics.rectangle(x, y, x + constants.menuW, y + boxH)
        graphics.alpha(1)
        graphics.color(Color.fromRGB(30, 17, 17))
        graphics.rectangle(x, y, x + constants.menuW, y + boxH, true)
        local iconOffset = ((graphics.textHeight("A", graphics.FONT_DEFAULT)) - 9)
        graphics.drawImage{
            image = skill.icon,
            x = x + iconOffset,
            y = y + iconOffset,
            subimage = skill.subimage
        }
        local tX = x + (iconOffset*3) + 18
        local tY = y + iconOffset
        graphics.color(data.color)
        graphics.print(skill.displayName..":", tX, tY, graphics.FONT_DEFAULT, graphics.ALIGN_LEFT, graphics.ALIGN_TOP)
        if desc then
            graphics.color(Color.WHITE)
            graphics.printColor(desc, tX, tY + graphics.textHeight("A", graphics.FONT_DEFAULT) + 2, graphics.FONT_DEFAULT)
        end
        
        yOffset = yOffset + boxH + 2
    end
    
end

local DrawTab = {
    [0] = function(menu)
        --Skill Display
        local data = menu:getData()
        local loadout = data.loadout
        local slots = {}
        local count = 0
        for _, slot in pairs(loadout.skillSlots) do
            if slot.showInCharSelect then
                if not (slot.name == "Passive" and slot.current == noPassive) then
                    table.insert(slots, slot)
                    count = count + 1
                end
            end
        end
        table.sort(slots, function(a, b)
        if a.displayOrder < b.displayOrder then
                return true
            else
                return false
            end
        end)
        DrawSkillSummary(data, slots)
        
    end,
    [1] = function(menu)
        --Loadout
        local data = menu:getData()
        local loadout = data.loadout
        local slots = {}
        local count = 0
        for _, slot in pairs(loadout.skillSlots) do
            if slot.showInLoadoutMenu then
                table.insert(slots, slot)
                count = count + 1
            end
        end
        table.sort(slots, function(a, b)
        if a.displayOrder < b.displayOrder then
                return true
            else
                return false
            end
        end)
        local i = 1
        for _, slot in pairs(slots) do
            graphics.alpha(1)
            DrawSelectionBox(data, slot, i)
            local z = 1
            for _, skill in pairs(slot.skills) do
                if not skill.hidden then
                    local sX = constants.menuX + (graphics.textWidth("Secondary", graphics.FONT_DEFAULT) * 1.25) + (22 * (z-1))
                    local sY = (constants.menuY + (constants.menuH * 1.2) * i) + 3
                    if slot.current ~= skill and not MouseHoveringOver(sX, sY, sX + 18, sY + 18) then
                        graphics.color(Color.BLACK)
                        graphics.alpha(0.5)
                        graphics.rectangle(sX, sY, sX+18, sY+18)
                    end
                    z = z + 1

                end
            end
            i = i + 1
        end
        -----------------------------------------------------------
        i = 1
        for _, slot in pairs(slots) do -- Draw tooltips / take input for skills
            local z = 0
            for _, skill in pairs(slot.skills) do
                if not skill.hidden then
                    local sX = constants.menuX + (graphics.textWidth("Secondary", graphics.FONT_DEFAULT) * 1.25) + (22 * (z))
                    local sY = (constants.menuY + (constants.menuH * 1.2) * i) + 3
                    if MouseHoveringOver(sX, sY, sX + 18, sY + 18) then
                        local mx, my = input.getMousePos(true)
                        DrawToolTip(data, skill, mx, my)
                    end
                    z = z + 1
                end
            end
            i = i + 1
        end
    end,
}

local TakeTabInput = {
    [0] = function(menu) 
        --I do nothing lol
    end,
    [1] = function(menu)
        local i = 1
        local data = menu:getData()
        local loadout = data.loadout
        if not loadout then return end
        local slots = {}
        local count = 0
        for _, slot in pairs(loadout.skillSlots) do
            if slot.showInLoadoutMenu then
                table.insert(slots, slot)
                count = count + 1
            end
        end
        table.sort(slots, function(a, b)
        if a.displayOrder < b.displayOrder then
                return true
            else
                return false
            end
        end)
        for _, slot in pairs(slots) do -- Draw tooltips / take input for skills
            local z = 0
            for _, skill in pairs(slot.skills) do
                if not skill.hidden then
                    local sX = constants.menuX + (graphics.textWidth("Secondary", graphics.FONT_DEFAULT) * 1.25) + (22 * (z))
                    local sY = (constants.menuY + (constants.menuH * 1.2) * i) + 3
                    if MouseHoveringOver(sX, sY, sX + 18, sY + 18) then
                        local mx, my = input.getMousePos(true)
                        DrawToolTip(data, skill, mx, my)
                        if input.checkMouse("left") == input.PRESSED then
                            if not skill.locked and skill.obj ~= underConstruction then
                                slot.current = skill
                                if net.online then
                                    if net.host then
                                        SyncLoadoutChange:sendAsHost("all", nil, data.localPlayer:get("my_player"), slot.name, skill.displayName)
                                    else
                                        SyncClientLoadoutChange:sendAsClient(data.localPlayer:get("my_player"), slot.name, skill.displayName)
                                    end
                                end
                                if slot.name == "Skin" then
                                    if data.select then
                                        data.select:getAccessor().chosen_index = 1
                                    end
                                    if skill.sprites["loadout"] then
                                        data.survivor.loadoutSprite = skill.sprites["loadout"]
                                    end
                                    if skill.sprites["idle"] then
                                        data.survivor.idleSprite = skill.sprites["idle"]
                                    end
                                    if skill.sprites["walk"] then
                                        data.survivor.titleSprite = skill.sprites["walk"]
                                    end
                                end
                                Loadout.Save(data.loadout)
                            end
                        end
                    end
                    z = z + 1
                end
            end
            i = i + 1
        end
    end,
}

local DrawTabSelection = function(selected, hovering, color)
    for i = 0, tabs - 1 do
        if selected == i then
            if not color then
                graphics.color(Color.fromRGB(91, 88, 88))
            else
                graphics.color(color)
            end
            graphics.rectangle(constants.tabsX + ((constants.tabsW/tabs) * (i)), constants.tabsY, constants.tabsX + ((constants.tabsW/tabs) * (i+1)), constants.tabsY + constants.tabsH)
        end
    end
    graphics.color(Color.fromRGB(58, 44, 44))
    for i = 0, tabSelectThickness-1 do
        graphics.rectangle(constants.tabsX-i, constants.tabsY-i, constants.tabsX + constants.tabsW + i, constants.tabsY + constants.tabsH + i, true)
    end
    for i = 1, tabs - 1 do
        graphics.line(constants.tabsX + ((constants.tabsW/tabs) * (i)), constants.tabsY + 1, constants.tabsX + ((constants.tabsW/tabs) * (i)), constants.tabsY + 1 + constants.tabsH, tabSelectThickness)
    end
    for i = 0, tabs - 1 do
        graphics.color(Color.fromRGB(91, 88, 88))
        if selected == i then
            graphics.color(Color.WHITE)
        else
            if hovering == i then
                graphics.color(Color.WHITE)
            end
        end
        graphics.print(tabNames[i] or "???", constants.tabsX + ((constants.tabsW/2) * (i+1/tabs)), constants.tabsY + (constants.tabsH / 2), graphics.FONT_LARGE, graphics.ALIGN_CENTER, graphics.ALIGN_MIDDLE)
    end
end

local TabInput = function(menu)
    local data = menu:getData()
    for i = 0, tabs - 1 do
        if MouseHoveringOver(constants.tabsX + ((constants.tabsW/tabs) * (i)), constants.tabsY, constants.tabsX + ((constants.tabsW/tabs) * (i+1)), constants.tabsY + constants.tabsH) then
            data.tabHovering = i
            if input.checkMouse("left") == input.PRESSED then
                data.tab = i
            end
        else
            data.tabHovering = -1
        end
    end
end

local DrawMenu = function(handler)
    local menuObj = handler:getData().menu
    local data = menuObj:getData()
    if data.select then
        local select = data.select:getAccessor()
    else
        data.select = selectObj:find(1)
    end
    -------------------------------------------------
    if data.survivor and Loadout.findFromSurvivor(data.survivor) then
        graphics.color(Color.fromRGB(10, 5, 5))
        graphics.rectangle(0, 100, 150, 300)
        DrawTabSelection(data.tab, data.tabHovering or data.tab, data.color)
        DrawTab[data.tab](menuObj)
    end
end

local DrawMenuCoop = function(handler)
    local menuObj = handler:getData().menu
    local data = menuObj:getData()
    -------------------------------------------------
    if data.survivor and Loadout.findFromSurvivor(data.survivor) then
        graphics.drawImage{
            image = menuButton,
            x = constants.tabsX,
            y = constants.tabsY - (menuButton.height + 2),
            subimage = data.buttonFrame,
        }
        if data.collapsed then return end
        graphics.color(Color.fromRGB(10, 5, 5))
        graphics.rectangle(0, 100, 150, 300)
        DrawTabSelection(data.tab, data.tabHovering or data.tab, data.color)
        DrawTab[data.tab](menuObj)
    end
end

local StepMenu = function(menu)
    local data = menu:getData()
    if not selectObj then error("Please make sure to read and follow the instructions in the README.txt included with Risk of Rain 2: Return to Sender before playing.") return end
    if data.select then
        local select = data.select:getAccessor()
        if IDsToSurvivor[(select.choice + 1)] then
            data.survivor = IDsToSurvivor[(select.choice + 1)]
        else
            data.survivor = nil
        end
        --------------------------------
        if data.survivor and Loadout.findFromSurvivor(data.survivor) then
            data.loadout = Loadout.findFromSurvivor(data.survivor)
            data.color = data.survivor.loadoutColor
            ---------------------------------------
            TabInput(menu)
            TakeTabInput[data.tab](menu)
        end
    else
        data.select = selectObj:find(1)
    end
end

local StepMenuCoop = function(menu)
    local data = menu:getData()
    if not selectObj then error("Please make sure to read and follow the instructions in the README.txt included with Risk of Rain 2: Return to Sender before playing.") return end
    if data.init then
        if prePlayer:find(1) then
            data.localPlayer = prePlayer:find(1)
            data.localIndex = data.localPlayer:get("m_id")
            ----------------------------------------------------------------
            for _, player in ipairs(prePlayer:findAll()) do
                local index = player:get("m_id")
                if Loadout.findFromSurvivor(IDsToSurvivor[player:get("class")+1]) then
                    playerLoadouts[index] = Loadout.findFromSurvivor(IDsToSurvivor[player:get("class")+1])
                end
            end
            ----------------------------------------------------------------
            data.survivor = IDsToSurvivor[data.localPlayer:get("class") + 1]
            data.loadout = Loadout.findFromSurvivor(data.survivor)
            if data.loadout then
                if MouseHoveringOver(constants.tabsX, constants.tabsY - (menuButton.height + 2), constants.tabsX + menuButton.width, constants.tabsY - 2) then
                    if input.checkMouse("left") == input.HELD then
                        if data.collapsed then
                            data.buttonFrame = 1
                        else
                            data.buttonFrame = 3
                        end
                    elseif input.checkMouse("left") == input.RELEASED then
                        data.collapsed = not data.collapsed
                    else
                        if data.collapsed then
                            data.buttonFrame = 2
                        else
                            data.buttonFrame = 4
                        end
                    end
                end
                data.color = data.survivor.loadoutColor
            end
            --------------------------------------------
            if not data.collasped then
                if data.localPlayer:get("locked") ~= 1 then
                    TabInput(menu)
                    TakeTabInput[data.tab](menu)
                end
            end
        end
    else
        data.selecting = -1
        data.playerCount = -1
        data.players = {}
        data.playerIndexes = {}
        data.init = true
    end
end


menu:addCallback("create", function(this)
    local data = this:getData()
    data.tab = 0
    data.collapsed = false

end)
menu:addCallback("step", function(this)
    StepMenu(this)
end)

menuCoop:addCallback("create", function(this)
    local data = this:getData()
    data.init = false
    data.playerCount = 0
    data.tab = 0
    data.buttonFrame = 4

end)
menuCoop:addCallback("step", function(this)
    StepMenuCoop(this)
end)

callback.register("globalRoomStart", function(room)
    if selectObj then
        if room == selectScreen then
            playerLoadouts = {}
            local menuInst = menu:create(0, 0)
            local handler = graphics.bindDepth(-1, DrawMenu)
            handler:getData().menu = menuInst
        elseif room == selectCoOpScreen then
            playerLoadouts = {}
            local menuInst = menuCoop:create(0, 0)
            local handler = graphics.bindDepth(-1, DrawMenuCoop)
            handler:getData().menu = menuInst
        end

    end
end)

--------------------------------------------------

callback.register("postLoad", function()
    if not selectObj then
        for _, survivor in pairs(IDsToSurvivor) do
            if survivor then
                if Loadout.findFromSurvivor(survivor) then survivor.disabled = true end
            end
        end
        error("RTS Core: It seems like you haven't followed the instructions inside the enclosed README.txt.\nPlease go to your installation of RTS Core and follow the instructions provided before playing.")
    end
end)
--------------------------------------------------

export("Loadout", Loadout)
export("IDsToSurvivor", IDsToSurvivor)
export("SurvivorToIDs", SurvivorToIDs)
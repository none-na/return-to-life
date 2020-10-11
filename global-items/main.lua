
GlobalItem = {}

GlobalItem.namespace = "GlobalItems" --for your ease of use. <3


GlobalItem.items = {}

local actors = ParentObject.find("actors", "vanilla")
local AffectedActors = {}


local events = {
    ["apply"] = true,-- Takes in an instance and stack count. Applies the item to the instance.
                     -- If the actor obtains a use item, this function is called.
    ["step"] = true,--Takes in an instance and stack count. Runs in postStep.
    ["remove"] = true,--Takes in an instance, a stack count, and a boolean. Removes a stack of the effects of the item from the instance.
                      -- If the boolean is true, completely removes all stacks of effects from the instance.
                      -- If the actor loses its use item, then this function is called.
    ["use"] = true, --Takes in an instance, and whether or not Beating Embryo procced. Used for the effects of equipment.
    ["activation"] = true, -- Takes in an instance and stack count. Runs if the instance activates its equipment.
                           -- NOTE: Please use "use" for the effects of equipment.
                           -- This is for items that have an effect if ANY equipment is activated.
    ["draw"] = true,--Takes in an instance and stack count. Runs in onDraw.
    ["hit"] = true,--Takes in an instance, stack count, and the arguments for the onHit callback. Run when the instance hits something.
    ["kill"] = true,--Takes in an instance, stack count, and the arguments for the onHit callback. Run when the instance kills an actor.
    ["damage"] = true,--Takes in an instance, stack count, and how much damage the instance took. Run when the instance takes damage.
    ["death"] = true, --Takes in an instance and stack count. Ran right before the actor dies.
    ["destroy"] = true, --Takes in an instance and stack count. Ran when the actor ACTUALLY dies.
}


local inventoryDisplayRowLength = 5
local tagFormat = "hotkey_display_inventory_"

-- profile tags:
    -- hotkey_display_inventory_[?]: The last character can be replaced with whatever key you wish. Holding down the key will display an
    -- actor's inventory below them.


-- Registers an item to the Global Items system, allowing you to set events for the item.
-- Returns the newly created Global Item entry.
-- (Have I ever actually used this?)
GlobalItem.new = function(item)
    local newEntry = GlobalItem.items[item]
    newEntry = {}
    for event, e in pairs(events) do
        newEntry[event] = nil
    end
    return newEntry
end

GlobalItem.setEvent = function(item, event, func)
    local entry = GlobalItem.items[item]
    if entry then
        if events[event] then
            entry[event] = func
        else
            error("Global Items: \""..event.."\" is not a valid event type.")
        end
    else
        error("Global Items: item not registered. Have you called GlobalItem.new for this item?")
    end
end

-- Prepares the actor so it can use items. If an actor has not been run through this function, it cannot use items.
-- The function will do nothing if you pass a player into it, since they can already use items.
GlobalItem.initActor = function(instance)
    if type(instance) == "PlayerInstance" then
        print("Global Items: Players can already use items. Did you mean to call this function on a PlayerInstance?")
        return
    elseif type(instance) == "ActorInstance" then
        table.insert(AffectedActors, instance)
        local data = instance:getData()
        data.items = {}
        data.equipment = nil
        data.equipmentCooldown = -1
        data.drops = {}
        instance:set("use_equipment", 0)
        instance:set("use_cooldown", 45)
        instance:set("gold", 0)
        instance:set("gold_cooldown", 0)
        instance:set("maxhp_base", instance:get("maxhp"))
        instance:set("percent_hp", 1)
        local items = data.items
        local drops = data.drops
        for _, item in ipairs(Item.findAll("vanilla")) do
            items[item] = 0
            drops[item] = 0
        end
        for _, namespace in ipairs(modloader.getMods()) do
            for _, item in ipairs(Item.findAll(namespace)) do
                items[item] = 0
                drops[item] = 0
            end
        end
        data.init = true
    end
end

-- Checks if the passed in actor instance has been initialized or not.
-- Returns true if so, false otherwise.
GlobalItem.actorIsInit = function(instance)
    if type(instance) == "PlayerInstance" then
        print("Global Items: Players can already use items. Did you mean to call this function on an ActorInstance?")
        return false
    elseif type(instance) == "ActorInstance" then
        local data = instance:getData()
        return data.init
    end
end

-- Gives an actor instance an item.
-- If the passed in item is a Use Item, the "count" variable is ignored, and considered 1.
-- Parameters:
    -- instance (ActorInstance): The actor instance to give the item to. If not initialized with GlobalItem.initActor, then this function will do nothing.
    -- item (Item): The item to give the actor. The item must be registered as a Global Item, or else this function will do nothing.
    -- count (Number): The stack of the item to give the actor. Positive values will grant the item, negative values will remove the item.
GlobalItem.addItem = function(instance, item, count)
    if not GlobalItem.items[item] then --[[print("Global Items: Item "..item:getName().." ("..item:getOrigin()..") is not registered as a Global Item.")]] return end
    if instance:getData().items then
        if item.isUseItem then --if the item is a use item
            if instance:getData().equipment then --actor already has a use item, remove current
                local current = instance:getData().equipment
                if GlobalItem.items[current] then
                    if GlobalItem.items[current].remove then
                        GlobalItem.items[current].remove(instance, count, true)
                    end
                    instance:getData().items[current] = 0
                else
                    error("Global Items: Couldn't give Instance #"..instance.id.." equipment "..item:getName()..", Instance's current equipment is not registered.")
                    return
                end
            end
            instance:getData().equipment = item
            instance:getData().items[item] = 1
            if GlobalItem.items[item].apply then
                GlobalItem.items[item].apply(instance, 1)
            end
            return
        end
        if not count then count = 1 end
        local items = instance:getData().items
        if count > 0 then
            if GlobalItem.items[item].apply then
                GlobalItem.items[item].apply(instance, count)
            end
        elseif count < 0 then
            if GlobalItem.items[item].remove then
                GlobalItem.items[item].remove(instance, count, false)
            end
        end
        items[item] = items[item] + count
        if items[item] < 0 then
            items[item] = 0
        end
    end
end

-- Completely removes an item from the actor.
-- If the item has a remove event, the "hardRemove" bool will be passed in as true.
-- This indicates that the remove event should clean up ALL effects of the item, regardless of stack count.
-- Make sure your items take "hardRemove" into account!
GlobalItem.remove = function(instance, item)
    if not GlobalItem.items[item] then return end
    if instance:getData().items then
        local items = instance:getData().items
        if GlobalItem.items[item].remove then
            GlobalItem.items[item].remove(instance, items[item], true)
        end
        items[item] = 0
    end
end

-- Sets the amount of a passed in item on an ActorInstance.
-- This function will not call any events, so when you use this function, please keep that in mind.
GlobalItem.setItem = function(instance, item, count)
    if instance:getData().items then
        local items = instance:getData().items
        items[item] = count
        if items[item] < 0 then
            items[item] = 0
        end
    end
end

-- Returns the stack count of an item on the passed in Instance. Equivalent to PlayerInstance:countItem().
GlobalItem.countItem = function(instance, item)
    if instance:getData().items then
        local items = instance:getData().items
        return items[item] or 0
    end
end

-- Sets the drop chance of an item for the passed in Instance, from 0 to 1.
-- 0 means the item will never drop, and 1 means the item is guaranteed to drop.
GlobalItem.setDropChance = function(instance, item, chance)
    if instance:getData().drops then
        local drops = instance:getData().drops
        drops[item] = math.clamp(chance, 0, 1) or 0
    end
end

----------------------------------------------------------------------------------------------------------
-- Editing below this line is inadvisable.                                                              --
----------------------------------------------------------------------------------------------------------


local sounds = {
    shield = Sound.find("Shield", "vanilla"),
}

local draw = false

local GetKeyFromTag = function()
    for _, tag in pairs(modloader.getFlags()) do
        if string.find(tag, tagFormat) then
            local s, e = string.find(tag, tagFormat)
            return string.sub(tag, e+1, string.len(tag))
        end
    end
    return nil
end

local DrawInventory = function(actor)
    local data = actor:getData()
    if draw then
        local rowLength = 1
        local xx = math.round(actor.x) - (32 * (rowLength / 2))
        local yy = math.round(actor.y) + (actor.sprite.height - actor.sprite.yorigin) + 10
        local index = 0
        local rows = 0
        for item, count in pairs(data.items) do
            if item and count > 0 then
                if rowLength < inventoryDisplayRowLength then
                    rowLength = rowLength + 1
                end
                index = index + 1
                if index % inventoryDisplayRowLength == 0 then
                    rows = rows + 1
                end
            end
        end
        if index == 0 then return end
        graphics.color(Color.BLACK)
        graphics.alpha(0.3)
        graphics.triangle(actor.x, actor.y + (actor.sprite.height - actor.sprite.yorigin), actor.x - 9, yy, actor.x + 9, yy)
        graphics.rectangle(xx - 18, yy, xx + (36 * (rowLength - 1)) + 28, yy + (40 * (rows + 1)))
        graphics.color(Color.WHITE)
        graphics.rectangle(xx - 18, yy, xx + (36 * (rowLength - 1)) + 28, yy + (40 * (rows + 1)), true)
        graphics.alpha(1)
        graphics.print(actor:get("name").."'s Inventory:", xx - 16, yy, graphics.FONT_SMALL, graphics.ALIGN_LEFT, graphics.ALIGN_TOP)
        graphics.print("$"..math.floor(actor:get("gold") or 0), xx + (32 * (rowLength)), yy, graphics.FONT_SMALL, graphics.ALIGN_RIGHT, graphics.ALIGN_TOP)
        index = 0
        rows = 0
        yy = yy + 20
        for item, count in pairs(data.items) do
            if item and count > 0 then
                local isEquip = false
                if item == data.equipment then
                    isEquip = true
                end
                if isEquip then
                    local a = 1
                    if data.equipmentCooldown > -1 then
                        a = 0.5
                    end
                    graphics.drawImage{
                        image = item.sprite,
                        x = xx + (36 * (index % rowLength)),
                        y = yy + (40 * rows),
                        subimage = item.sprite.frames,
                        alpha = a
                    }
                    graphics.color(Color.WHITE)
                    if data.equipmentCooldown > -1 then
                        graphics.alpha(1)
                        graphics.print(math.round(data.equipmentCooldown / 60), xx + (36 * (index % rowLength)), yy + (40 * rows), graphics.FONT_LARGE, graphics.ALIGN_MIDDLE, graphics.ALIGN_CENTER)
                    end
                else
                    graphics.drawImage{
                        image = item.sprite,
                        x = xx + (36 * (index % rowLength)),
                        y = yy + (40 * rows),
                        subimage = item.sprite.frames,
                        alpha = 1
                    }
                    graphics.color(Color.WHITE)
                    if count > 1 then
                        graphics.alpha(1)
                        graphics.print(count, xx + 16 + (36 * (index % rowLength)), yy + 16 + (40 * rows), graphics.FONT_DAMAGE, graphics.ALIGN_RIGHT, graphics.ALIGN_BOTTOM)
                    end

                end
                index = index + 1
                if index % 5 == 0 then
                    rows = rows + 1
                end
            end
        end
    end
end

---------------------------

--Shields behave properly on Enemies, and non-classic Enemies invincibility counts down properly

callback.register("onStep", function()
    for _, actor in ipairs(actors:findAll()) do
        if type(actor) ~= "PlayerInstance" then
            local a = actor:getAccessor()
            if not actor:isClassic() then
                if a.invincible > -1 then
                    a.invincible = a.invincible - 1
                end
            end
            if a.shield_cooldown > -1 then
                a.shield_cooldown = a.shield_cooldown - 1
            else
                if a.shield < a.maxshield then
                    sounds.shield:play()
                    a.shield = a.maxshield
                end
            end
        end
    end
end)

---------------------------

callback.register("postStep", function()
    if GetKeyFromTag() and input.checkKeyboard(GetKeyFromTag()) == input.PRESSED then
        draw = not draw
        --print("Toggled inventory display to "..tostring(draw))
    end
    for _, actor in ipairs(AffectedActors) do
        if actor and actor:isValid() then
            if not actor:isClassic() then
                if actor:get("invincible") > -1 then
                    actor:set("invincible", actor:get("invincible") - 1)
                end
                if actor:get("gold_cooldown") > 0 then
                    actor:set("gold_cooldown", actor:get("gold_cooldown") - 1)
                end
            end
            if actor:getData().items then
                actor:set("maxhp", math.round(actor:get("maxhp_base") * actor:get("percent_hp")))
                actor:set("hp", actor:get("hp") + math.clamp((actor:get("hp_regen") or 0), 0, math.huge))
                if actor:getData().equipment then
                    local equipment = actor:getData().equipment
                    --------------------------
                    if equipment then
                        local target = Object.findInstance(actor:get("target") or -1)
                        if target then
                            local xx = actor.x - target.x
                            local yy = actor.y - target.y
                            local distance = math.sqrt(math.pow(xx, 2) + math.pow(yy, 2))
                            if distance <= (actor:get("equipment_range") or 0) then
                                actor:set("use_equipment", 1)
                            else
                                actor:set("use_equipment", 0)
                            end
                        end
                    end
                    --------------------------
                    if actor:get("use_equipment") == 1 then
                        if actor:getData().equipmentCooldown == -1 then
                            if GlobalItem.items[equipment] then
                                if GlobalItem.items[equipment].use then
                                    local t = math.random(100) < (30 * (actor:get("embryo") or 0))
                                    if t then
                                        Sound.find("Embryo", "vanilla"):play()
                                        Sound.find("Crit", "vanilla"):play()
                                    end
                                    actor:getData().equipmentCooldown = (60 * actor:get("use_cooldown") * (equipment.useCooldown / 45))
                                    GlobalItem.items[equipment].use(actor, t)

                                    for item, count in pairs(actor:getData().items) do
                                        if GlobalItem.items[item] then
                                            if item and count > 0 then
                                                if GlobalItem.items[item].activation then
                                                    GlobalItem.items[item].activation(actor, count)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            actor:set("use_equipment", 0)
                        end
                    end
                    if actor:getData().equipmentCooldown > -1 then
                        actor:getData().equipmentCooldown = actor:getData().equipmentCooldown - 1
                    end
                end
                for item, count in pairs(actor:getData().items) do
                    if GlobalItem.items[item] then
                        if item and count > 0 then
                            if GlobalItem.items[item].step then
                                GlobalItem.items[item].step(actor, count)
                            end
                        end
                    end
                end
            end
        end
    end
end)

callback.register("onDraw", function()
    for _, actor in ipairs(AffectedActors) do
        if actor and actor:isValid() then
            if actor:getData().items then
                DrawInventory(actor)
                for item, count in pairs(actor:getData().items) do
                    if GlobalItem.items[item] then
                        if item and count > 0 then
                            if GlobalItem.items[item].draw then
                                GlobalItem.items[item].draw(actor, count)
                            end
                        end
                    end
                end
            end
        end
    end
end)

local CreateDrop = net.Packet.new("Sync Global Items Drop", function(x, y, item)
    local i = Item.find(item)
    if i then
        i:create(x, y)
    end
end)

callback.register("onHit", function(damager, hit, x, y)
    local parent = damager:getParent()
    if parent and parent:isValid() then
        for _, actor in ipairs(AffectedActors) do
            if actor and actor:isValid() and actor == parent then
                for item, count in pairs(actor:getData().items) do
                    if GlobalItem.items[item] then
                        if item and count > 0 then
                            if GlobalItem.items[item].hit then
                                GlobalItem.items[item].hit(actor, count, damager, hit, x, y)
                            end
                            if hit:get("hp") - damager:get("damage") < 0 then
                                if GlobalItem.items[item].kill then
                                    GlobalItem.items[item].kill(actor, count, damager, hit, x, y)
                                end
                            end
                        end
                    end
                end
            elseif actor == hit then
                for item, count in pairs(actor:getData().items) do
                    if GlobalItem.items[item] then
                        if item and count > 0 then
                            if GlobalItem.items[item].damage then
                                GlobalItem.items[item].damage(actor, count, damager:get("damage"))
                            end
                            if actor:get("hp") - damager:get("damage") <= 0 then
                                if GlobalItem.items[item].death then
                                    GlobalItem.items[item].death(actor, count)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

callback.register("onNPCDeath", function(npc)
    for _, actor in ipairs(AffectedActors) do
        if actor and actor:isValid() then
            if npc == actor then
                for item, count in pairs(actor:getData().items) do
                    if item and count > 0 then
                        if GlobalItem.items[item].destroy then
                            GlobalItem.items[item].destroy(actor, count)
                        end
                        if actor:getData().drops[item] then
                            if net.host then
                                local rng = math.random()
                                if rng < actor:getData().drops[item] then
                                    item:create(actor.x, actor.y)
                                    if net.online then
                                        CreateDrop:sendAsHost(net.ALL, nil, actor.x, actor.y, item:getName())
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

---------------------------

restre_require("util")
restre_require("vanilla")

export("GlobalItem", GlobalItem)

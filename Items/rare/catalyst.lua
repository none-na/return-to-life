--RoR2 Demake Project
--Made by Sivelos
--catalyst.lua
--File created 2019/06/04

local catalyst = Item("Soulbound Catalyst")
catalyst.pickupText = "Kills reduce use item cooldown by 4s."

catalyst.sprite = restre.spriteLoad("Graphics/catalyst.png", 1, 16, 16)
catalyst:setTier("rare")

catalyst:setLog{
    group = "rare",
    description = "Kills reduce &b&use item cooldowns&!& by 4 seconds.",
    story = "Isn't necromancy lovely? I whipped this baby up for you. It eats souls for you, and converts them into energy. You can use this energy however you want. To power things, to make you stronger, or to grow plants. Just in time for NecronomiCon 2056! I hope you like it!",
    destination = "Javitz Convention Center,\nManhattan,\nEarth",
    date = "6/6/2056"
}

registercallback("onNPCDeathProc", function(npc, actor)
    if actor:isValid() then
        if actor:countItem(catalyst) > 0 then
            if actor:getAlarm(0) > -1 then
                actor:setAlarm(0, math.clamp(actor:getAlarm(0) - ((4*60) + ((2*60) * (actor:countItem(catalyst) - 1))), -1, actor:get("use_cooldown") * 60))
            end
        end
    end
end)

local sprites = {
    idle = restre.spriteLoad("catalystIdle", "Graphics/catalyst", 4, 5, 4),
}

local players = ParentObject.find("actors", "vanilla")

local catalystFollower = Object.new("catalyst")
catalystFollower.sprite = sprites.idle

registercallback("onActorInit", function(actor)
    if actor:isValid() and isa(actor,"PlayerInstance") then
        actor:set("catalyst", -1)
    end
end)

catalystFollower:addCallback("create", function(self)
    self.sprite = sprites.idle
    self.mask = sprites.idle
    self.spriteSpeed = 0.25
    self:set("id", self.id)
    self:set("state", 0)
    self:set("hMax", 5)
    self:set("vMax", 0.1)
    self:set("f", 0)
    self:set("hSpeed", 0)
    self:set("vSpeed", 0)
    self:set("bobHeight", 5)
    
end)
catalystFollower:addCallback("step", function(self)
    local target = nil
    for _, player in ipairs(players:findMatching("id", self:get("parent"))) do
        target = player
    end
    if not target then
        self:destroy()
        return
    end
    self.xscale = target.xscale
    self.x = target.x + ((self:get("xOff") or 0))
    
    self:set("f", (self:get("f") + 0.05) % 360)
    self.y = (target.y + (self:get("yOff") or 0)) - (math.cos(self:get("f")) * self:get("bobHeight"))
end)

catalyst:addCallback("pickup", function(player)
    if not Object.findInstance(player:get("catalyst")) then
        local newCatalyst = catalystFollower:create(player.x, player.y)
        newCatalyst:set("parent", player.id)
        newCatalyst:set("xOff", math.random(-player.sprite.width, player.sprite.width/3))
        newCatalyst:set("yOff", -math.random(player.sprite.height, player.sprite.height*1.5))
        newCatalyst:set("persistent", 1)
        player:set("catalyst", newCatalyst:get("id") or newCatalyst.id)
    end
end)

catalyst:addCallback("drop", function(player)
    local catalystObj = Object.findInstance(player:get("catalyst"))
    catalystObj:destroy()
end)

GlobalItem.items[catalyst] = {
    apply = function(inst, count)
        local newCatalyst = catalystFollower:create(inst.x, inst.y)
        newCatalyst:set("parent", inst.id)
        newCatalyst:set("xOff", math.random(-inst.sprite.width, inst.sprite.width/3))
        newCatalyst:set("yOff", -math.random(inst.sprite.height, inst.sprite.height*1.5))
        newCatalyst:set("persistent", 1)
        inst:set("catalyst", newCatalyst.id)
    end,
    kill = function(inst, count, damager, hit, x, y)
        local data = inst:getModData(GlobalItem.namespace)
        if data.equipmentCooldown > -1 then
            data.equipmentCooldown = math.max(data.equipmentCooldown - ((4*60) + ((2*60) * (count - 1))), -1)
        end
    end,
    destroy = function(inst, count)
        local c = Object.findInstance(inst:get("catalyst"))
        if c then c:destroy() end
    end,
}
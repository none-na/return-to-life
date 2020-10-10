--RoR2 Demake Project
--Made by Sivelos
--crowdfunder.lua
--File created 2019/05/15

local woodsprite = Item("Gnarled Woodsprite")
woodsprite.pickupText = "Heal over time. Activate to send to closest ally."

woodsprite.sprite = Sprite.load("Items/woodsprite.png", 2, 10, 14)

woodsprite.isUseItem = true
woodsprite.useCooldown = 15

woodsprite:setTier("use")
woodsprite:setLog{
    group = "use",
    description = "Gain a Woodsprite that &b&heals you for 1.5% maximum HP&!& per second. Can be &b&sent to an ally&!&.",
    story = "This little buddy of mine should help out your mother's illness. His woodland magics seem to accelerate the body's healing process, but I never really questioned how they work. He's a ****ing pixie, or something.\n\nAnyway, write me back, and send your mother my regards.",
    destination = "Woodland Shire,\nFernGully,\nEarth",
    date = "4/10/2056"
}

local allyDetectionRange = 200
local allyDetectionFilter = 10

local reticule = Sprite.load("Graphics/woodspriteTarget", 1, 16, 16)

local actors = ParentObject.find("actors", "vanilla")
local players = Object.find("P", "vanilla")

local sprites = {
    idle = Sprite.load("woodspriteIdle", "Graphics/spriteIdle", 6, 3, 3),
    healing = Sprite.load("woodspriteShoot1", "Graphics/spriteHeal", 4, 8, 9),
}

local healSnd = Sound.find("Use", "vanilla")

local sprite_follower = Object.new("woodsprite")
sprite_follower.sprite = sprites.idle

registercallback("onActorInit", function(actor)
    if actor:isValid() and isa(actor,"PlayerInstance") then
        actor:set("woodsprite", -1)
    end
end)

sprite_follower:addCallback("create", function(self)
    local data = self:getData()
    self.sprite = sprites.idle
    self.mask = sprites.idle
    self.spriteSpeed = 0.25
    self:set("id", self.id)
    self:set("potentialTarget", -1)
    self:set("state", 0)
    self:set("hMax", 5)
    self:set("vMax", 0.1)
    self:set("hSpeed", 0)
    self:set("vSpeed", 0)
    self:set("f", 0)
    self:set("bobHeight", 5)
    self:set("target", self:get("parent"))
    self:set("timeBetweenHeals", 30)
    self:set("healCooldown", self:get("timeBetweenHeals"))
    if not data.parent then
        data.parent = players:findNearest(self.x, self.y)
    end
    data.subimage = -1
    data.lastSubimage = -1
    
end)

local woodspriteTrail = ParticleType.new("Healing Trail")
woodspriteTrail:shape("Square")
woodspriteTrail:color(Color.fromRGB(134, 197, 122))
woodspriteTrail:alpha(1,0)
woodspriteTrail:additive(true)
woodspriteTrail:size(0.02, 0.04, 0, 0)
woodspriteTrail:angle(0, 360, 10, 0, true)
woodspriteTrail:life(30, 30)

sprite_follower:addCallback("create", function(self)
    local data = self:getData()
    if not data.parent then
        data.parent = players:findNearest(self.x, self.y)
    end
end)

sprite_follower:addCallback("step", function(self)
    local data = self:getData()
    data.subimage = math.round(self.subimage)
    if data.target then
        self.xscale = data.target.xscale
        self.x =  data.target.x + ((self:get("xOff") or 0))
        self:set("f", (self:get("f") + 0.05) % 360)
        self.y = ( data.target.y + (self:get("yOff") or 0)) - (math.cos(self:get("f")) * self:get("bobHeight"))
        self:set("healCooldown", self:get("healCooldown") - 1)
        if self:get("state") == 1 then
            --healing on use
            self.sprite = sprites.healing
            if (data.subimage ~= data.lastSubimage) and math.round(self.subimage) == 1 then
                for i=0, math.random(5, 10) do
                    woodspriteTrail:burst("above",  data.target.x + math.random(- data.target.sprite.width/2,  data.target.sprite.width/2),  data.target.y + math.random(- data.target.sprite.height/2,  data.target.sprite.height/2), 1)
                end
                healSnd:play(0.8 + math.random() * 0.4)
                misc.damage(data.target:get("maxhp") / 10,  data.target.x,  data.target.y - ( data.target.sprite.height / 2), false, Color.DAMAGE_HEAL)
                data.target:set("hp",  data.target:get("hp") + ( data.target:get("maxhp") / 10))
            elseif math.round(self.subimage) >= 4 then
                self:set("state", 0)
            end
        else
            --idle
            self.sprite = sprites.idle
        end
        if self:get("healCooldown") <= 0 then
            for i=0, math.random(1, 5) do
                woodspriteTrail:burst("above",  data.target.x + math.random(- data.target.sprite.width/2,  data.target.sprite.width/2),  data.target.y + math.random(- data.target.sprite.height/2,  data.target.sprite.height/2), 1)
            end
            misc.damage(((data.target:get("maxhp") / 100) * 1.5),  data.target.x,  data.target.y - ( data.target.sprite.height / 2), false, Color.DAMAGE_HEAL)
            data.target:set("hp",  data.target:get("hp") + ((( data.target:get("maxhp") / 100) * 1.5) / (30/self:get("timeBetweenHeals"))))
            self:set("healCooldown", self:get("timeBetweenHeals"))
        end
    else
        local tg = data.parent
        if tg then
            data.target = tg
        end
    end
    woodspriteTrail:burst("middle", self.x, self.y, 1)
    data.lastSubimage = math.round(self.subimage)
end)
sprite_follower:addCallback("draw", function(self)
    local target = nil
    local parent = nil
    for _, player in ipairs(actors:findMatching("id", self:get("target"))) do
        target = player
    end
    for _, player in ipairs(actors:findMatching("id", self:get("parent"))) do    
        if target == nil then
            target = player
        end
        parent = player
    end
    for _, actorInst in ipairs(actors:findAllEllipse(parent.x - allyDetectionRange, parent.y - allyDetectionRange, parent.x + allyDetectionRange, parent.y + allyDetectionRange)) do
        if actorInst:get("team") == parent:get("team") and actorInst ~= parent then
            if actorInst.x <= parent.x - allyDetectionFilter and actorInst.y <= parent.y - allyDetectionFilter and actorInst.x >= parent.x + allyDetectionFilter and actorInst.y >=  parent.y + allyDetectionFilter then
                if actorInst.id ~= target.id and target.id == parent.id then
                    if parent:getAlarm(0) <= -1 then                
                        self:set("potentialTarget", actorInst.id)
                        graphics.drawImage{
                            image = reticule,
                            x = actorInst.x,
                            y = actorInst.y
                        }
                    end
                end
            end
        end
    end
end)


woodsprite:addCallback("pickup", function(player)
    local newPixie = sprite_follower:create(player.x, player.y)
    newPixie:set("parent", player.id)
    local data = newPixie:getData()
    data.parent = player
    data.target = player
    newPixie:set("xOff", math.random(-player.sprite.width, player.sprite.width/3))
    newPixie:set("yOff", -math.random(player.sprite.height, player.sprite.height*1.5))
    newPixie:set("persistent", 1)
    player:set("woodsprite", newPixie:get("id") or newPixie.id)
end)
woodsprite:addCallback("use", function(player, embryo)
    local pixie = Object.findInstance(player:get("woodsprite"))
    local data = pixie:getData()
    local target = data.target
    local parent = data.parent
    for _, player in ipairs(actors:findMatching("id", pixie:get("target"))) do
        target = player
    end
    if target == nil then
        for _, player in ipairs(actors:findMatching("id", pixie:get("parent"))) do
            target = player
            parent = player
        end
    end
    if data.target == data.parent then
        if Object.findInstance(pixie:get("potentialTarget")) then
            data.target = Object.findInstance(pixie:get("potentialTarget"))
        end
    else
        data.target = data.parent
    end
    pixie:set("state", 1)
    pixie.subimage = 1
end)
woodsprite:addCallback("drop", function(player)
    local pixie = Object.findInstance(player:get("woodsprite"))
    pixie:destroy()
end)

GlobalItem.items[woodsprite] = {
    apply = function(inst, count)
        local newPixie = sprite_follower:create(inst.x, inst.y)
        newPixie:set("parent", inst.id)
        local data = newPixie:getData()
        data.parent = inst
        data.target = inst
        newPixie:set("xOff", math.random(-inst.sprite.width, inst.sprite.width/3))
        newPixie:set("yOff", -math.random(inst.sprite.height, inst.sprite.height*1.5))
        newPixie:set("persistent", 1)
        inst:set("woodsprite", newPixie:get("id") or newPixie.id)
    end,
    use = function(inst, embryo)
        local pixie = Object.findInstance(inst:get("woodsprite"))
        local data = pixie:getData()
        local target = data.target
        local parent = data.parent
        for _, i in ipairs(actors:findMatching("id", pixie:get("target"))) do
            target = i
        end
        if target == nil then
            for _, e in ipairs(actors:findMatching("id", pixie:get("parent"))) do
                target = e
                parent = e
            end
        end
        if data.target == data.parent then
            if Object.findInstance(pixie:get("potentialTarget")) then
                data.target = Object.findInstance(pixie:get("potentialTarget"))
            end
        else
            data.target = data.parent
        end
        pixie:set("state", 1)
        pixie.subimage = 1
    end,
    remove = function(inst, count)
        local pixie = Object.findInstance(inst:get("woodsprite"))
        if pixie then pixie:destroy() end
    end,
    destroy = function(inst, count)
        local pixie = Object.findInstance(inst:get("woodsprite"))
        if pixie then pixie:destroy() end
    end
}
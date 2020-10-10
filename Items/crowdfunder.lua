--RoR2 Demake Project
--Made by Sivelos
--crowdfunder.lua
--File created 2019/05/15

local crowdfunder = Item("The Crowdfunder")
crowdfunder.pickupText = "Toggle to rapid-fire. Costs gold per bullet."

crowdfunder.sprite = Sprite.load("Items/crowdfunder.png", 2, 14, 16)

crowdfunder.isUseItem = true
crowdfunder.useCooldown = 0.2

crowdfunder:setTier("use")
crowdfunder:setLog{
    group = "use",
    description = "Toggle to &b&fire a barrage&!& for &y&100%&!& per second. Costs &b&$1 per bullet&!&.",
    story = "I can't think of a better way to stick it to the 1%... A gun that shoots money. Isn't the dramatic irony amazing? 'Fight fire with fire', they say. Well, let's have a fire fight. You know when and where to meet me.",
    destination = "Crimson Square,\nSpace Colony #23-B,\nMars",
    date = "3/8/2056"
}


local players = ParentObject.find("actors", "vanilla")

local sprites = {
    idle = Sprite.load("goldGatIdle", "Graphics/crowdfunderOff", 8, 4, 4),
    firing = Sprite.load("goldGatShoot1", "Graphics/crowdfunderOn", 8, 4, 6),
    mask = Sprite.load("goldGatMask", "Graphics/crowdfunderMask", 1, 4, 4),
    impact = Sprite.find("Sparks5", "vanilla")
}

local fireSnd = Sound.find("Bullet1", "vanilla")
local goldSnd = Sound.find("Coins", "vanilla")

local goldGat = Object.new("goldGat")
goldGat.sprite = sprites.idle

registercallback("onActorInit", function(actor)
    if actor:isValid() and isa(actor,"PlayerInstance") then
        actor:set("goldGat", 0)
    end
end)

goldGat:addCallback("create", function(self)
    self.sprite = sprites.idle
    self.mask = sprites.mask
    self.spriteSpeed = 0
    self:set("id", self.id)
    self:set("state", 0)
end)

goldGat:addCallback("step", function(self)
    local parent = nil
    for _, player in ipairs(players:findMatching("id", self:get("parent"))) do
        parent = player
    end
    self.xscale = parent.xscale
    self.x = parent.x + ((self:get("xOff") or 0) * parent.xscale)
    self.y = parent.y + ((self:get("yOff") or 0))
    self:set("cost", math.clamp(math.round(parent:get("level") / 3), 1, parent:get("level")))
    if (self:get("state") == 1 and misc.getGold() >= self:get("cost")) then
        --firing state
        self.sprite = sprites.firing
        self.spriteSpeed = 0.25
        if math.round(self.subimage) == 1 or math.round(self.subimage) == 3 or math.round(self.subimage) == 5 or math.round(self.subimage) == 7 then
            fireSnd:play(0.8 + math.random() * 0.2, 0.8)
            local goldGatbullet = parent:fireBullet(self.x, self.y, parent:getFacingDirection(), 300, 0.25, sprites.impact)
            misc.setGold(misc.getGold() - self:get("cost"))
            if misc.getGold() <= 0 then
                self:set("state", 0)
            end
        end
    else
        --idle state
        self.sprite = sprites.idle
        if self.spriteSpeed > 0 then
            self.spriteSpeed = math.clamp(self.spriteSpeed - 0.005, 0, 0.25)
        end
    end
end)


crowdfunder:addCallback("pickup", function(player)
    local newGoldGat = goldGat:create(player.x, player.y)
    newGoldGat:set("parent", player.id)
    newGoldGat:set("xOff", 0)
    newGoldGat:set("yOff", -math.round(((player.sprite.height / 2) - (sprites.idle.height / 2))))
    newGoldGat:set("persistent", 1)
    player:set("goldGat", newGoldGat:get("id") or newGoldGat.id)
end)
crowdfunder:addCallback("use", function(player, embryo)
    local goldGat = Object.findInstance(player:get("goldGat"))
    if goldGat:get("state") == 0 then
        goldGat:set("state", 1)
    else
        goldGat:set("state", 0)
    end
    player:setAlarm(0, 10)
end)
crowdfunder:addCallback("drop", function(player)
    local goldGat = Object.findInstance(player:get("goldGat"))
    goldGat:destroy()
end)

GlobalItem.items[crowdfunder] = {
    use = function(inst, embryo)

    end,
}
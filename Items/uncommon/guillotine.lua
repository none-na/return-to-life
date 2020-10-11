--RoR2 Demake Project
--Made by Sivelos
--guillotine.lua
--File created 2019/07/1

local guillotine = Item("Old Guillotine")
guillotine.pickupText = "Instantly kill low health Elite monsters."

guillotine.sprite = Sprite.load("Items/uncommon/Graphics/guillotine.png", 1, 16, 16)
guillotine:setTier("uncommon")

guillotine:setLog{
    group = "uncommon",
    description = "Instantly kill Elite monsters below 20% health.",
    story = "The very same that was used back in France to kill the elites oppressing the common folk. This thing holds a lot of weight (and not jut because it's heavy!), so using this will send a message across the stars. I can't wait to show those bastards what happens when you treat people like tools. Let me know when you recieve the 'gold gat'... We can meet up once you do.",
    destination = "Office Block #20-F,\nSpace Colony #23-B,\nMars",
    date = "9/10/2056"
}

local procEffect = Sprite.load("EfGuillotine", "Graphics/guillotine", 7, 12, 31)
local procSound = Sound.find("ClayShoot1", "vanilla")
local procMessages = Sprite.load("EfExecute", "Graphics/executeMessage", 4, 29, 4)
local message = Object.new("EfExecute")
local mesLife = 60
local mesSpeed = 0.2
local mesAlpha = 0.5
message:addCallback("create", function(self)
    self:set("life", mesLife)
    self.sprite = procMessages
    self.spriteSpeed = 0
    self.subimage = math.random(1, 4)
end)
message:addCallback("step", function(self)
    if self:get("life") > 0 then
        self.y = self.y - mesSpeed
        self:set("life", self:get("life") - 1)
        if self:get("life") <= mesLife * mesAlpha then
            self.alpha = self.alpha - 0.1
        end
    else
        self:destroy()
    end
end)

local efGuillotine = Object.new("EfGuillotine")
efGuillotine.sprite = procEffect
efGuillotine:addCallback("create", function(self)
    self.spriteSpeed = 0.25
end)

efGuillotine:addCallback("step", function(self)
    if math.floor(self.subimage) >= procEffect.frames then
        self:destroy()
    end
end)

local healthThreshold = function(count)
    return (1-(1/( 1 + 0.2 * count )))
end

registercallback("onHit", function(damager, hit, x, y)
    local parent = damager:getParent()
    if parent then
        if isa(parent, "PlayerInstance") then
            if parent:countItem(guillotine) > 0 then
                if hit:get("prefix_type") > 0 and (hit:get("hp") / hit:get("maxhp")) <= healthThreshold(parent:countItem(guillotine)) then
                    --misc.fireExplosion(hit.x, hit.y, 0, 0, 0, "player", procEffect, nil)
                    local guillotine = efGuillotine:create(hit.x, hit.y)
                    misc.shakeScreen(5)
                    procSound:play(0.7 + math.random() * 0.1)
                    local messageInst = message:create(hit.x, hit.y)
                    hit:kill()
                end
            end
        end
    end
end)

GlobalItem.items[guillotine] = {
    hit = function(inst, count, damager, hit, x, y)
        if hit:get("prefix_type") > 0 and (hit:get("hp") / hit:get("maxhp")) <= healthThreshold(count) then
            --misc.fireExplosion(hit.x, hit.y, 0, 0, 0, "player", procEffect, nil)
            local g = efGuillotine:create(hit.x, hit.y)
            misc.shakeScreen(5)
            procSound:play(0.7 + math.random() * 0.1)
            local messageInst = message:create(hit.x, hit.y)
            hit:kill()
        end
    end,
}
--RoR2 Demake Project
--Made by Sivelos
--meathook.lua
--File created 2019/06/11

local meathook = Item("Sentient Meat Hook")
meathook.pickupText = "Chance to hook all nearby enemies."

meathook.sprite = Sprite.load("Items/rare/Graphics/meathook.png", 1, 16, 16)

meathook:setTier("rare")
meathook:setLog{
    group = "rare",
    description = "20% chance on hit to fire homing hooks at up to 10 enemies for 100% damage.",
    story = "Man, now THIS is an antique. This baby is a relic of a bygone era... When, for whatever reason, everyone thought \"smart devices\" were the way of the future. Everything had an artifical intelligence... Phones, computers, clocks, toys, backpacks, you name it. Even things that were better off not having sentience. I mean really, who thought it would be a good idea to make a meat hook think? It's not like they lead exciting lives or anything. They just hang there. With meat.",
    destination = "Sloppy Joe's Deli and Catering,\nManhattan,\nNew York",
    date = "11/23/2056"
}

local hook = Object.new("meatHookObj")
local hookRange = 25
local enemies = ParentObject.find("enemies", "vanilla")

local hookHitSpr = Sprite.find("Sparks10r", "vanilla")
local hookSound = Sound.find("SamuraiShoot2", "vanilla")

local hookChance = function(hookCount)
    return ((1.0 - 100.0 / (100.0 + 20.0 * hookCount)) * 100.0)
end



hook:addCallback("create", function(self)
    self:getData().targets = {}
    self:set("life", 60)
    local targets = self:getData().targets
    local count = self:get("hooks") or 10
    for _, enemy in ipairs(enemies:findAllEllipse(self.x - hookRange, self.y - hookRange, self.x + hookRange, self.y + hookRange)) do
        if count > 0 and enemy ~= self:getData().bound then
            if enemy:isValid() then
                if enemy:getObject() ~= Object.find("WormBody", "vanilla") or enemy:getObject() ~= Object.find("WurmBody", "vanilla") then
                    table.insert(targets, enemy)
                    hookSound:play(1 + math.random() * 0.2)
                    local hit = misc.fireBullet(enemy.x, enemy.y, 0, 1, self:get("damage") or 14, "playerproc", hookHitSpr)
                    hit:set("specific_target", enemy.id)
                    count = count - 1
                end
            end
        end
    end
end)
hook:addCallback("step", function(self)
    local bound = self:getData().bound
    if bound then
        if bound:isValid() then
            bound:set("pHspeed", 0)
            local hookX = self:getData().bound.x or nil
            local hookY = self:getData().bound.y or nil
            self.x = bound.x or hookX or 0
            self.y = bound.y or hookY or 0
        end
        local hookCount = 0
        for _, enemy in ipairs(self:getData().targets) do
            if hookCount <= self:get("hooks") then
                if enemy:isValid() then
                    if enemy:getObject() ~= Object.find("WormBody", "vanilla") or enemy:getObject() ~= Object.find("WurmBody", "vanilla") then
                        local xx = self.x - enemy.x
                        local yy = self.y - enemy.y
                        if math.round(xx) ~= 0 then
                            if math.abs(xx) > 10 then
                                local moveDistance = enemy:get("pHmax") * 2
                                for i = 0, moveDistance do
                                    if enemy:collidesMap(enemy.x + i,enemy.y) then
                                        moveDistance = i
                                        break
                                    end
                                end
                                if xx > 1 then
                                    enemy.x = enemy.x + moveDistance
                                else
                                    enemy.x = enemy.x - moveDistance
                                end
                            end
                        end
                        if math.round(yy) ~= 0 then
                            if math.abs(yy) > 10 then    
                                local moveDistance = enemy:get("pHmax") * 2
                                for i = 0, moveDistance do
                                    if enemy:collidesMap(enemy.x,enemy.y + (enemy.sprite.height/2) + i) then
                                        moveDistance = i
                                        break
                                    end
                                end
                                if yy > 1 then
                                    enemy.y = enemy.y + moveDistance
                                else
                                    enemy.y = enemy.y - moveDistance
                                end
                            end
                        end
                        hookCount = hookCount + 1
                    end    
                end
            end
        end
        self:set("life", self:get("life") - 1)
        if self:get("life") <= 0 then
            self:destroy()
        end
    else
        self:destroy()
    end
    
end)
hook:addCallback("draw", function(self)
    for _, enemy in ipairs(self:getData().targets) do
        if enemy:isValid() then
            graphics.alpha(0.3)
            graphics.color(Color.fromRGB(255, 255, 255))
            graphics.line(self.x, self.y, enemy.x, enemy.y, 3)
        end
    end
end)

registercallback("onPlayerStep", function(player)
    player:set("meathook", player:countItem(meathook))
end)

IRL.setRemoval(meathook, function(player)
    adjust(player, "meathook", -1)
end)

GlobalItem.items[hook] = {
    apply = function(inst, count)
        inst:set("meathook", (inst:get("meathook") or 0) + count)
    end,
    remove = function(inst, count)
        inst:set("meathook", (inst:get("meathook") or 0) - count)
    end,
}

registercallback("preHit", function(damager)
    if damager:isValid() then
        local parent = damager:getParent()
        if parent then
            if parent:isValid() then
                if parent:get("meathook")  then
                    if math.random()*100 <= hookChance(parent:get("meathook") or 0) then
                        damager:set("meathook", parent:get("meathook") or 0)
                    else
                        damager:set("meathook", 0)
                    end
                end
            end
        end
    end
end)

registercallback("onHit", function(damager, hit, x, y)
    local parent = damager:getParent()
    if parent ~= nil then
        if damager:get("meathook") then
            if damager:get("meathook") > 0 then
                local nearbyEnemies = enemies:findAllEllipse(hit.x - hookRange, hit.y - hookRange, hit.x + hookRange, hit.y + hookRange)
                local count = 0
                for _, enemyInst in ipairs(nearbyEnemies) do
                    if enemyInst:isValid() then
                        if enemyInst ~= hit then
                            count = count + 1
                        end
                    end
                end
                if count > 0 then
                    local hookInst = hook:create(hit.x, hit.y)
                    hookInst:set("hooks", 10 + (5 * (damager:get("meathook") - 1)))
                    hookInst:set("damage", damager:get("damage") or 14 )
                    hookInst:getData().bound = hit
                end
            end
        end
    end
end)
-- Golem.lua

local elder = Object.find("LizardG", "vanilla")

local actors = ParentObject.find("actors", "vanilla")

local sprites = {
    shoot2 = Sprite.load("LizardGShoot2", "Actors/elderLemurian/shoot2", 17, 46, 27),
    fireball = Sprite.find("WormBody", "vanilla"),
}

local sounds = {
    charge = Sound.find("LizardShoot1", "vanilla"),
    impact = Sound.find("GiantJellyExplosion", "vanilla")
}
local fireImpact = Sprite.find("EfFireshield", "vanilla")
local fireFX = ParticleType.find("Fire3", "vanilla")
local fireTrail = Object.find("EfFireTrail", "vanilla")

local fireball = Object.new("LizardGFireball")
fireball.sprite = sprites.fireball
fireball:addCallback("create", function(self)
    local data = self:getData()
    data.f = 0
    data.x = 0
    self:getAccessor().speed = 4
    data.y = 0
    data.life = 60
    
end)
fireball:addCallback("step", function(self)
    local data = self:getData()
    data.f = data.f + 1
    self.xscale = 0.5
    self.yscale = 0.5
    data.life = data.life - self:getAccessor().speed
    fireFX:burst("above",self.x + (math.random(-1, 1)),self.y + (math.random(-1, 1)), 1)
    self:getAccessor().direction = GetAngleTowards(data.x, data.y, self.x, self.y)
    self.angle = self:get("direction")
    if data.life <= -1 or self:collidesMap(self.x, self.y) then
        sounds.impact:play(0.9 + math.random() * 0.2)
        if data.parent and data.parent:isValid() then
            local exp = data.parent:fireExplosion(self.x, self.y, 1, 2, 2, fireImpact, nil, nil)
        else
            local exp = misc.fireExplosion(self.x, self.y, 1, 2, 24, "enemy", fireImpact, nil, nil)
        end
        --local f = fireTrail:create(self.x, self.y)
        self:destroy()
        return
    end
end)
fireball:addCallback("draw", function(self)
    local data = self:getData()
    local d = Difficulty.getActive()
    if d.enableMissileIndicators then
        graphics.color(Color.WHITE)
        graphics.alpha(1)
        graphics.circle(data.x, data.y, 4*(math.abs(math.sin(data.f))), true)
    end
end)

elder:addCallback("create", function(self)
    self:set("x_range", 300)
end)

local FireFireBall = function(inst)
    local f = fireball:create(inst.x, inst.y)
    f.depth = inst.depth - 1
    local t = Object.findInstance(inst:get("target"))
    f:getData().parent = inst
    local d = Distance(inst.x, inst.y, f:getData().x, f:getData().y)
    f:getData().life = d
    if t and t:isValid() then
        local a = GetAngleTowards(t.x, t.y, inst.x, inst.y)
        f:getData().x = inst.x + (math.cos(math.rad(a)) * d)
        f:getData().y = inst.y + (math.sin(math.rad(a)) * d)
    else
        f:getData().x = inst.x + (350 * inst.xscale)
        f:getData().y = inst.y
    end
    f:getAccessor().direction = GetAngleTowards(f:getData().x, f:getData().y, inst.x, inst.y)
end

callback.register("onStep", function()
    for _, inst in ipairs(elder:findAll()) do
        if inst:isValid() then
            local data = inst:getData()
            if inst:get("disable_ai") ~= 1 and misc.getTimeStop() == 0 then
                if inst:get("activity") == 2 then
                    inst:set("x_skill", 0)
                    if inst:get("free") ~= 1 then
                        inst:set("pHspeed", 0)
                    end
                    if math.floor(inst.subimage) == 7 or math.floor(inst.subimage) == 11 or math.floor(inst.subimage) == 15 then
                        if inst:get("activity_var1") == 0 then
                            FireFireBall(inst)
                            inst:set("activity_var1", 1)
                        end
                    elseif math.floor(inst.subimage) == 9 or math.floor(inst.subimage) == 13 then
                        if inst:get("activity_var1") == 1 then
                            FireFireBall(inst)
                            inst:set("activity_var1", 0)
                        end
                    end
                    inst:set("activity_type", 1)
                    inst.sprite = sprites.shoot2
                    inst.spriteSpeed = inst:get("attack_speed") * 0.2
                    if math.floor(inst.subimage) == sprites.shoot2.frames - 1 then
                        inst:set("state", "chase")
                        inst:set("activity", 0)
                        inst:set("activity_type", 0)
                        inst.spriteSpeed = 0
                        return
                    end
                end
                if inst:get("x_skill") == 1 and inst:getAlarm(3) == -1 and misc.getTimeStop() == 0 then
                    sounds.charge:play((1.15 * inst:get("attack_speed")) + math.random() * 0.05)
                    inst:set("x_skill", 0)
                    inst:set("activity", 2)
                    inst:set("activity_var1", 0)
                    inst:setAlarm(3, (5*60) * (1-inst:get("cdr")))
                    inst.subimage = 1                    
                else
                    local poi = Object.findInstance(inst:get("target"))
                    if poi and poi:isValid() and poi:get("team") ~= inst:get("team") then
                        local distance = math.abs(inst.x - poi.x)
                        if inst:get("activity") == 0 and (inst:get("x_range") and distance <= inst:get("x_range")) and not (Object.find("B", "vanilla"):findLine(inst.x, inst.y, poi.x, poi.y)) then
                            inst:set("x_skill", 1)
                        else
                            inst:set("x_skill", 0)
                        end
                    end
                end
            end
        end
    end
end)

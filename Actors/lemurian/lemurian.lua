-- Golem.lua

local lemurian = Object.find("Lizard", "vanilla")

local actors = ParentObject.find("actors", "vanilla")

local sprites = {
    shoot2 = Sprite.load("LizardShoot2", "Actors/lemurian/firebreath", 8, 10, 10),
    fireball = Sprite.load("LizardFireball", "Actors/lemurian/fireball", 1, 3, 3),
}

local sounds = {
    charge = Sound.find("LizardShoot1", "vanilla"),
}
local fireImpact = Sprite.find("Sparks12", "vanilla")
local fireFX = ParticleType.find("Fire3", "vanilla")

local fireball = Object.new("LizardFireball")
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
    data.life = data.life - self:getAccessor().speed
    fireFX:burst("above",self.x + (math.random(-1, 1)),self.y + (math.random(-1, 1)), 1)
    self:getAccessor().direction = GetAngleTowards(data.x, data.y, self.x, self.y)
    if data.life <= -1 then
        if data.parent and data.parent:isValid() then
            local exp = data.parent:fireExplosion(self.x, self.y, 1, 2, 1, fireImpact, nil, nil)
        else
            local exp = misc.fireExplosion(self.x, self.y, 1, 2, 12, "enemy", fireImpact, nil, nil)
        end
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

lemurian:addCallback("create", function(self)
    self:set("x_range", 150)
end)

callback.register("onStep", function()
    for _, inst in ipairs(lemurian:findAll()) do
        if inst:isValid() then
            local data = inst:getData()
            if inst:get("disable_ai") ~= 1 and misc.getTimeStop() == 0 then
                if inst:get("activity") == 2 then
                    inst:set("x_skill", 0)
                    if inst:get("free") ~= 1 then
                        inst:set("pHspeed", 0)
                    end
                    if inst:get("activity_var1") == 0 and math.floor(inst.subimage) == 4 then
                        local f = fireball:create(inst.x, inst.y)
                        f.depth = inst.depth - 1
                        local t = Object.findInstance(inst:get("target"))
                        f:getData().parent = inst
                        if t and t:isValid() then
                            f:getData().x = t.x
                            f:getData().y = t.y
                        else
                            f:getData().x = inst.x + (150 * inst.xscale)
                            f:getData().y = inst.y
                        end
                        f:getData().life = Distance(inst.x, inst.y, f:getData().x, f:getData().y)
                        f:getAccessor().direction = GetAngleTowards(f:getData().x, f:getData().y, inst.x, inst.y)
                        inst:set("activity_var1", 1)
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
                    inst:setAlarm(3, (2*60) * (1-inst:get("cdr")))
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

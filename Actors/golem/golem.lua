-- Golem.lua

local golem = Object.find("Golem", "vanilla")
local golemS = Object.find("GolemS", "vanilla")

local blast = Sprite.load("GolemImpact", "Actors/golem/laser", 5, 12, 13)
local blast2 = Sprite.load("GolemSImpact", "Actors/golem/laser2", 5, 12, 13)
local chargeTime = 3*60
local stopAimingAt = 10 --The laser will stop tracking its target when its life falls equal to or below this value.
local sounds = {
    charge = Sound.load("GolemLaserCharge", "Sounds/SFX/golem/golemLaserCharge.ogg"),--Sound.find("CutscenePass", "vanilla"),
    fire = Sound.load("GolemLaserFire", "Sounds/SFX/golem/golemLaserFire.ogg"),--Sound.find("GuardDeath", "vanilla")
}

local golemLaser = Object.new("GolemLaser")
golemLaser:addCallback("create", function(self)
    local data = self:getData()
    if data.parent then
        data.target = Object.findInstance(data.parent:get("target"))
        data.x = self.x + (40 + data.parent.xscale)
        data.y = self.y
        if data.parent:getObject() == golemS then
            data.snow = true
        else
            data.snow = false
        end
    end
    sounds.charge:play(1)
    data.life = chargeTime
    data.disable = false
    data.x = 0
    data.y = 0
end)
golemLaser:addCallback("step", function(self)
    local data = self:getData()
    if data.parent and data.parent:isValid() then
        if misc.getTimeStop() == 0 then
            if data.parent:getObject() == golemS then
                data.snow = true
            else
                data.snow = false
            end
            if data.parent:get("stunned") > 0 or data.parent:get("state") == "feared" then
                if sounds.charge:isPlaying() then
                    sounds.charge:stop()
                end
                data.disable = true
            end
            if data.life <= -1 then
                data.life = data.life - 1
            else
                data.life = math.clamp(data.life - math.round(data.parent:get("attack_speed")), -1, chargeTime)
            end
            if data.disable then
                self:destroy()
            else
                if data.life == -1 then
                    sounds.fire:play(1 + math.random() * 0.05)
                    local hit = nil
                    if data.snow then
                        hit = data.parent:fireExplosion(data.x, data.y, 0.5, 1, 2.5, blast2, nil)
                    else
                        hit = data.parent:fireExplosion(data.x, data.y, 0.5, 1, 2.5, blast, nil)
                    end
                    hit:set("knockback", 2)
                    if data.parent:get("elite_type") == 0 then
                        hit:set("burn", 0.1)
                    end
                elseif data.life < -4 then
                    if sounds.charge:isPlaying() then
                        sounds.charge:stop()
                    end
                    self:destroy()
                else
                    self.x = data.parent.x + data.parent.xscale
                    self.y = data.parent.y - 11
                    data.target = Object.findInstance(data.parent:get("target"))
                    
                    if data.target and data.life > stopAimingAt then
                        data.x = data.target.x
                        data.y = data.target.y
                        local length = math.sqrt(math.pow(self.x - data.target.x,2) + math.pow(self.y - data.target.y,2))
                        for i = 0, length do
                            if data.target:collidesMap(self.x + ((data.target.x - self.x) * (i / length)),self.y + ((data.target.y - self.y) * (i / length))) then
                                data.x = self.x + (( data.target.x - self.x) * (i / length))
                                data.y = self.y + (( data.target.y - self.y) * (i / length))
                                i = length
                                break
                            end
                        end
                    end
                end
                
            end
        end
    else
        if sounds.charge:isPlaying() then
            sounds.charge:stop()
        end
        self:destroy()
    end

end)
golemLaser:addCallback("draw", function(self)
    local data = self:getData()
    if data.parent  and data.parent:isValid() then
        if not data.disable then
            if data.life < 0 then
                if data.snow then
                    graphics.color(Color.fromRGB(174, 166, 0))
                else 
                    graphics.color(Color.fromRGB(186, 84, 86))
                end
                graphics.alpha(0.5)
                graphics.line(self.x, self.y, data.x, data.y, math.clamp(4 - data.life, 0, 4))
                if data.snow then
                    graphics.color(Color.fromRGB(255, 242, 0))
                else 
                    graphics.color(Color.fromRGB(208, 138, 140))
                end
                graphics.line(self.x, self.y, data.x, data.y, math.clamp(4 - (data.life/2), 0, 4))
                graphics.color(Color.WHITE)
                graphics.line(self.x, self.y, data.x, data.y, 1)
            else
                if data.snow then
                    graphics.color(Color.fromRGB(255, 242, 0))
                else 
                    graphics.color(Color.fromRGB(186, 84, 86))
                end
                graphics.alpha(math.clamp(1-(data.life/chargeTime), 0, 0.75))
                graphics.line(self.x, self.y, data.x, data.y, 1)
                graphics.circle(data.x, data.y, 2, false)
                graphics.circle(data.x, data.y, 5, true)
                graphics.circle(data.parent.x + data.parent.xscale, data.parent.y-12, (data.life % 3)+1, true)
            end
        end
    end
end)

golem:addCallback("create", function(self)
    self:set("x_range", 150)
end)
golemS:addCallback("create", function(self)
    self:set("x_range", 150)
end)

callback.register("onStep", function()
    for _, inst in ipairs(golem:findAll()) do
        if inst:isValid() then
            local data = inst:getData()
            if inst:get("disable_ai") ~= 1 then
                if inst:get("x_skill") == 1 and inst:getAlarm(3) == -1 and misc.getTimeStop() == 0 then
                    local laserInst = golemLaser:create(inst.x, inst.y)
                    local instData = laserInst:getData()
                    instData.parent = inst
                    inst:setAlarm(3, 8*60)
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
    for _, inst in ipairs(golemS:findAll()) do
        if inst:isValid() then
            local data = inst:getData()
            if inst:get("disable_ai") ~= 1 then
                if inst:get("x_skill") == 1 and inst:getAlarm(3) == -1 and misc.getTimeStop() == 0 then
                    local laserInst = golemLaser:create(inst.x, inst.y)
                    local instData = laserInst:getData()
                    instData.parent = inst
                    inst:setAlarm(3, 8*60)
                else
                    local poi = Object.findInstance(inst:get("target"))
                    if poi then
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

local sprites = {
    explosion = Sprite.find("JellyMissile", "vanilla")
}

local sounds = {
    spawn = Sound.load("VagrantSpawn", "Sounds/SFX/vagrant/vagrantspawn.ogg"),
    novaCharge = Sound.load("VagrantCharge", "Sounds/SFX/vagrant/vagrantCharge.ogg"),
    superNova = Sound.load("VagrantBlast", "Sounds/SFX/vagrant/vagrantNova.ogg"),
}


local actors = ParentObject.find("actors", "vanilla")
local flash = Object.find("WhiteFlash")

local nova = Object.new("VagrantNova")
nova:addCallback("create", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    data.maxLife = 60*4.25
    data.life = data.maxLife
    data.rate = 1
    data.team = "enemy"
    data.damage = 6.5
    data.radius = 3000
    data.sound = false

end)
nova:addCallback("step", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    if data.parent then
        if data.parent:isValid() then
            this.x = data.parent.x
            this.y = data.parent.y
            data.damage = data.parent:get("damage")
            data.team = data.parent:get("team")
            data.rate = data.parent:get("attack_speed")
        else
            this:destroy()
            return
        end
    end
    if not data.sound then
        sounds.novaCharge:play(data.rate)
        data.sound = true
    end
    if data.life > -1 then
        data.life = data.life - data.rate
    else
        if sounds.novaCharge:isPlaying() then
            sounds.novaCharge:stop()
        end
        sounds.superNova:play()
        for i = 0, math.random(3, 5) do
            local l = DrawLightning(this.x + math.random(-100, 100), this.y + math.random(-100, 100), this.x + math.random(-100, 100),this.y + math.random(-100, 100), 0.01)
            l.blendColor = Color.ROR_BLUE
        end
        for _, inst in ipairs(actors:findAllEllipse(this.x - data.radius, this.y - data.radius, this.x + data.radius, this.y + data.radius)) do
            if inst and inst:isValid() then
                if inst:get("team") ~= data.team then
                    local b = nil
                    if data.parent then
                        b = data.parent:fireBullet(this.x, this.y, GetAngleTowards(inst.x, inst.y, this.x, this.y), data.radius, 20, sprites.explosion, DAMAGER_BULLET_PIERCE)
                    else
                        b = misc.fireBullet(this.x, this.y, GetAngleTowards(inst.x, inst.y, this.x, this.y), data.radius, 20 * data.damage, data.team, sprites.explosion, DAMAGER_BULLET_PIERCE)
                    end
                end
            end
        end
        local f = flash:create(this.x, this.y)
        f:set("rate", 0.01)
        this:destroy()
    end
end)
nova:addCallback("draw", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    graphics.setBlendModeAdvanced("sourceAlpha", "sourceColour")
    graphics.alpha(0.5)
    graphics.color(Color.ROR_BLUE)
    graphics.circle(this.x, this.y, data.radius * (data.maxLife - data.life) / data.maxLife, false)
    graphics.setBlendMode("normal")
    ------------------------------------------------------
    graphics.color(Color.ROR_BLUE)
    graphics.alpha(1)
    graphics.circle(this.x, this.y, (data.radius) * (data.maxLife - data.life) / data.maxLife, true)
    graphics.alpha(0.3)
    graphics.circle(this.x, this.y, (50 + math.sin(data.life)) * (data.maxLife - data.life) / data.maxLife, false)
    graphics.circle(this.x, this.y, (30 + math.sin(data.life)) * (data.maxLife - data.life) / data.maxLife, false)
    graphics.color(Color.WHITE)
    graphics.circle(this.x, this.y, (10 + math.sin(data.life)) * (data.maxLife - data.life) / data.maxLife, false)
    
end)

local spark = ParticleType.find("Sparks", "RTSCore")

local vagrant = Object.find("GiantJelly", "vanilla")
vagrant:addCallback("create", function(self)
    sounds.spawn:play()
end)


callback.register("onStep", function()
    for _, inst in ipairs(vagrant:findAll()) do
        if inst and inst:isValid() then
            if misc.getTimeStop() == 0 then
                local data = inst:getData()
                
                if data.init then
                    data.f = data.f + 1
                    if data.f % 15 == 0 then
                        spark:burst("middle", inst.x + math.random(-inst.sprite.width, inst.sprite.width), inst.y + math.random(-inst.sprite.height, inst.sprite.height), 1, Color.AQUA)
                    end
                    if data.slowdownTimer > -1 then
                        data.slowdownTimer = data.slowdownTimer - 1
                        inst:set("speed", math.approach(inst:get("speed"), 0, 0.1))
                    else
                        if data.novaAnimation then
                            inst:set("speed", data.speed)
                            data.novaAnimation = not data.novaAnimation
                        end
                    end
                    if inst:get("hp") <= inst:get("maxhp") / 4 then
                        if inst:getAlarm(4) <= -1 then
                            data.slowdownTimer = (4.25*60)/inst:get("attack_speed")
                            data.novaAnimation = true
                            local n = nova:create(inst.x, inst.y)
                            n:getData().parent = inst
                            inst:setAlarm(4, 15*60)
                            return
                        else
                            inst:setAlarm(4, inst:getAlarm(4) - 1)
                        end
                    end
                else
                    inst:set("c_range", 0)
                    data.slowdownTimer = -1
                    data.novaAnimation = false
                    data.rage = false
                    data.f = 0
                    data.speed = inst:get("max_speed")
                    data.init = true
                    return
                end
            end
        end
    end
end)


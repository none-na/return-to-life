
local sprites = {
    idle = Sprite.load("RoboBallIdle", "Actors/roboball/idle", 1, 25, 25),
    idleS = Sprite.load("RoboBallSIdle", "Actors/roboball/superIdle", 1, 29, 41),
    turn = Sprite.load("RoboBallTurn", "Actors/roboball/turn", 7, 25, 25),
    turnS = Sprite.load("RoboBallSTurn", "Actors/roboball/turnSuper", 7, 25, 25),
    shoot1 = Sprite.load("RoboBallShoot1", "Actors/roboball/shoot1", 7, 25, 25),
    death = Sprite.load("RoboBallDeath", "Actors/roboball/death", 2, 25, 25),
    deathS = Sprite.load("RoboBallSDeath", "Actors/roboball/deathSuper", 2, 25, 25),
    spawn = Sprite.load("RoboBallSpawn", "actors/roboball/spawn", 11, 25, 25),
    spawnS = Sprite.load("RoboBallSSpawn", "actors/roboball/spawnSuper", 11, 25, 25),
    mask = Sprite.load("RoboBallMask", "Actors/roboball/mask", 1, 25, 25),
    charge = Sprite.load("RoboBallReticule", "Actors/roboball/reticule", 2, 16, 16),
    ---------------------------------
    idleP = Sprite.load("RoboBallPIdle", "Actors/roboball/probeIdle", 1, 5, 5),
    maskP = Sprite.load("RoboBallPMask", "Actors/roboball/probeMask", 1, 16, 15),
    glowP = Sprite.load("RoboBallPGlow", "Actors/roboball/probeFlash", 1, 5, 5),
    deathP = Sprite.load("RoboBallPDeath", "Actors/roboball/probeDeath", 7, 15, 17),
    ---------------------------------
    palette = Sprite.load("RoboBallPal", "Actors/roboball/palette", 1, 0,0),
    sparks = Sprite.find("Sparks2", "vanilla"),
    sparks1 = Sprite.load("RoboBallSparks1", "Actors/roboball/Sparks1", 5, 21, 20),
    sparks2 = Sprite.load("RoboBallSparks2", "Actors/roboball/sparks2", 7, 56, 42),
    sparks3 = Sprite.load("RoboBallSparks3", "Actors/roboball/sparks3", 5, 15, 16),
}

local sounds = {
    death = Sound.load("RoboBallDeath", "Sounds/SFX/roboball/death.ogg"),
    deployProbe = Sound.load("RoboBallMSpawn", "Sounds/SFX/roboball/deployProbe.ogg"),
    hit = Sound.load("RoboBallHit", "Sounds/SFX/roboball/hit.ogg"),
    bulletImpact = Sound.load("RoboBallBulletImpact", "Sounds/SFX/roboball/impact.ogg"),
    probeDeath = Sound.load("RoboBallMDeath", "Sounds/SFX/roboball/probeDeath.ogg"),
    shoot1_1 = Sound.load("RoboBallShoot1_1", "Sounds/SFX/roboball/windup.ogg"),
    shoot1_2 = Sound.load("RoboBallShoot1_2", "Sounds/SFX/roboball/shoot1.ogg"),
    shoot2 = Sound.load("RoboBallShoot2", "Sounds/SFX/roboball/shoot2.ogg"),
    shoot3_1 = Sound.load("RoboBallShoot3_1", "Sounds/SFX/roboball/ultCharge.ogg"),
    shoot3_2 = Sound.load("RoboBallShoot3_2", "Sounds/SFX/roboball/shoot3.ogg"),
    spawn = Sound.load("RoboBallSSpawn", "Sounds/SFX/roboball/superRoboballSpawn.ogg"),
}

local objects = {
    fireTrail = Object.find("FireTrail", "vanilla"),
    whiteFlash = Object.find("WhiteFlash", "vanilla")
}

local actors = ParentObject.find("actors", "vanilla")

local RoboBallPInit = function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    self.name = "Solus Probe"
    self.maxhp = 220 * Difficulty.getScaling("hp")
    self.hp = self.maxhp
    self.damage = 15 * Difficulty.getScaling("damage")
    self.armor = 10
    self.pHmax = 0.5
    self.pGravity1 = 0
    self.pGravity2 = 0
    self.yy = 0
    actor.mask = sprites.maskP
    actor:setAnimations{
        idle = sprites.idleP,
        walk = sprites.idleP,
        jump = sprites.idleP,
        death = sprites.deathP
    }
    self.sound_hit = sounds.hit.id
    self.hit_pitch = 2
    self.sound_death = sounds.probeDeath.id
    self.health_tier_threshold = 3
    self.knockback_cap = self.maxhp
    self.facing = 1
    self.rotating = 0
    self.direction = 0
    self.targetDirection = 0
    self.targetAngle = 0
    actor:set("sprite_palette", sprites.palette.id)
    self.z_range = 100
    self.shake_frame = -1
    self.can_drop = 1
    self.can_jump = 1
    self.z_charge = 0
    self.z_target_x = 0
    self.z_target_y = 0
    self.beam_x = 0
    self.beam_y = 0
    self.moveDown = 0
end

local RoboBallPStep = function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    local target = Object.findInstance(self.target)
    if misc.getTimeStop() > 0 then
        self.speed = 0
        return
    end
    ------------------------------------------
    if self.state == "chase" or self.state == "attack1" then
        local zz = self.z_range
		for u = 0, zz do
            local xorigin = math.cos(math.rad(actor.angle)) * 4
            local yorigin = math.sin(math.rad(actor.angle)) * 4
			local angle = GetAngleTowardsRad(target.x, target.y, actor.x + xorigin, actor.y + yorigin)
			self.z_target_x = actor.x + ((math.cos(angle) * zz) * (u / zz))
			self.z_target_y = actor.y - ((math.sin(angle) * zz) * (u / zz))
			if target:getObject():findLine(actor.x + xorigin, actor.y + yorigin, self.z_target_x, self.z_target_y) or Stage.collidesPoint(self.z_target_x, self.z_target_y) then
				break
			end
		end
        if (target.y < actor.y) then
            self.moveUp = 1
        elseif target.y > actor.y then
            self.moveDown = 1
        else
            self.moveUp = 0
            self.moveDown = 0
        end    
    else
        self.z_target_x = actor.x + ((math.cos(actor.angle) * self.z_range))
        self.z_target_y = actor.y - ((math.sin(actor.angle) * self.z_range))
    end
    actor.xscale = 1
    self.yy = self.yy + (self.pHmax / 10)
    if self.moveUp == 1 then
        self.pVspeed = -math.abs((math.sin(self.yy) / 5))
    elseif self.moveDown == 1 then
        self.pVspeed = math.abs((math.sin(self.yy) / 5))
    else
        self.pVspeed = (math.sin(self.yy) / 5)
    end
    ------------------------------------------
    if self.activity == 0 and self.state ~= "set up" then
        if target and target:isValid() then
            if Distance(target.x, target.y, actor.x, actor.y) < self.z_range then
                self.z_skill = 1
            else
                self.z_skill = 0
            end
        end
        ----------------------------------------------------
        if self.z_skill == 1 and actor:getAlarm(2) == -1 and self.z_charge == 0 then
            self.z_charge = 5*60
            actor:setAlarm(2, 10*60)
            self.z_skill = 0
            self.beam_x = actor.x + ((math.cos(actor.angle) * self.z_range))
            self.beam_y = actor.y + ((math.sin(actor.angle) * self.z_range))
            self.state = "attack1"
            return
        end
    end
    ------------------------------------------
    if self.state == "idle" then

    elseif self.state == "chase" then

    elseif self.state == "attack1" then
        if target and target:isValid() then
            --Strafe
            local dist = Distance(actor.x, actor.y, target.x, target.y)
            if dist > self.z_range then
                if actor.x > target.x then
                    self.moveLeft = 1
                    self.moveRight = 0
                else
                    self.moveLeft = 0
                    self.moveRight = 1
                end
                
            else
                if actor.x > target.x then
                    self.moveLeft = 0
                    self.moveRight = 1
                else
                    self.moveLeft = 1
                    self.moveRight = 0
                end
            end

        end
        if self.z_charge > 0 then
            self.z_charge = self.z_charge - 1
            self.beam_x = math.approach(self.beam_x, self.z_target_x, self.pHmax)
            self.beam_y = math.approach(self.beam_y, self.z_target_y, self.pHmax)
            if self.z_charge % 15 == 0 then
                actor:fireExplosion(self.beam_x, self.beam_y, 0.1, 0.5, 0.3, sprites.sparks3, nil)
            end
        else
            self.state = "chase"
            return
        end
        
    elseif self.state == "set up" then

    end
end

local RoboBallPDraw = function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    local target = Object.findInstance(self.target)
    if misc.getTimeStop() == 0 then
        if self.moveDown == 1 then
            self.targetAngle = 270
        end
        if self.moveLeft == 1 then
            self.targetAngle = 180
        end
        if self.moveRight == 1 then
            self.targetAngle = 0
        end
        if self.moveUp == 1 then
            self.targetAngle = 90
        end
        if (target and target:isValid()) and (self.state == "chase" or self.state == "attack1") then
            self.targetAngle = GetAngleTowards(target.x, target.y, actor.x, actor.y)
        end
        actor.angle = math.approach(actor.angle, self.targetAngle, self.pHmax * 5)
    end
    --------------------------------
    self.yy = self.yy + 1
    --------------------------------
    --Draw glow effect
    if self.state == "chase" or self.state == "attack1" then
        graphics.setBlendMode("additive")
        graphics.drawImage{
            image = sprites.glowP,
            x = actor.x,
            y = actor.y,
            alpha = math.sin(self.yy * 0.1),
            angle = actor.angle,
        }
        graphics.setBlendMode("normal")
    end
    --------------------------------
    --Draw beam
    if self.z_charge > 0 then
        local xorigin = math.cos(math.rad(actor.angle)) * -4
        local yorigin = math.sin(math.rad(actor.angle)) * -4
        if self.z_charge % 2 == 0 then
            graphics.color(Color.fromRGB(204, 255, 250))
        else
            graphics.color(Color.fromRGB(255, 255, 201))
        end
        graphics.alpha(0.5)
        graphics.line(actor.x + xorigin, actor.y + yorigin, self.beam_x, self.beam_y, 3 + math.sin(self.yy))
        graphics.alpha(1)
        if self.z_charge % 2 == 0 then
            graphics.color(Color.fromRGB(255, 255, 201))
        else
            graphics.color(Color.fromRGB(204, 255, 250))
        end
        graphics.circle(actor.x + xorigin, actor.y + yorigin, 5+ math.sin(self.yy), true)
        graphics.line(actor.x + xorigin, actor.y + yorigin, self.beam_x, self.beam_y, 1)
    end
end

local roboballp = Object.base("EnemyClassic", "RoboBallP")
roboballp.sprite = sprites.idleP

roboballp:addCallback("create", function(actor)
    RoboBallPInit(actor)
end)

roboballp:addCallback("step", function(actor)
    RoboBallPStep(actor)
end)

roboballp:addCallback("draw", function(actor)
    RoboBallPDraw(actor)
end)

local probeLog = MonsterLog.new("Solus Probe")
MonsterLog.map[roboballp] = probeLog

probeLog.displayName = "Solus Probe"
probeLog.story = "These Solus probes attract just as much attention from the other creatures on this planet as I do. The Probes are mining drones by nature, and from a distance I've observed them using their laser tools to chip away at cliffsides, gathering stone and dirt for some unknown purpse. The probes are controlled by an external control unit, and yet I haven't encountered a single one so far. Could these probes have gone beyond their programming, or is the control unit back at the ship, stuck in some rubble?\n\nWhatever the case, the probes are also capable of defending themselves. They must be running on a high-alert protocol, as they zap anyone and anything that approaches... including me."
probeLog.statHP = 220
probeLog.statDamage = 15
probeLog.statSpeed = 0.5
probeLog.sprite = sprites.idleP
probeLog.portrait = sprites.idleP
probeLog.portraitSubimage = 1

local roboBullet = Object.new("RoboBallBullet")
roboBullet:addCallback("create", function(self)
    local s = self:getAccessor()
    local data = self:getData()
    s.f = 0
    s.team = "enemy"
    s.damage = 12
    s.direction = 0
    s.speed2 = 5
end)
roboBullet:addCallback("step", function(self)
    local s = self:getAccessor()
    local data = self:getData()
    if misc.getTimeStop() > 0 then
        s.speed = 0
    else
        s.f = s.f + 1
        s.speed = s.speed2
    end
    local nearest = actors:findNearest(self.x, self.y)
    if Stage.collidesPoint(self.x, self.y) or ((Distance(self.x, self.y, nearest.x, nearest.y) < 5) and nearest:get("team") ~= s.team) or s.f > 2*60 then
        self:destroy()
    end
end)
roboBullet:addCallback("destroy", function(self)
    local s = self:getAccessor()
    local data = self:getData()
    local parent = data.parent
    sounds.bulletImpact:play(0.9 + math.random() * 0.1)
    misc.shakeScreen(5)
    if parent and parent:isValid() then
        parent:fireExplosion(self.x, self.y, 1, 1, 1, sprites.sparks3, nil)
        
        if parent:get("elite_type") == 0 then
            local f = objects.fireTrail:create(self.x, self.y)
            f:set("damage", parent:get("damage") * 0.5)
            f:set("team", parent:get("team"))
            f:set("parent", parent.id)
        end
    else
        misc.fireExplosion(self.x, self.y, 1, 1, 10, s.team, sprites.sparks3, nil)
    end
end)
roboBullet:addCallback("draw", function(self)
    local s = self:getAccessor()
    local data = self:getData()
    
    graphics.alpha(0.75)
    if s.f % 2 == 0 then
        graphics.color(Color.fromRGB(255, 255, 201))
    else
        graphics.color(Color.fromRGB(204, 255, 250))
    end
    graphics.circle(self.x, self.y, 5 + math.sin(s.f), false)
    if s.f % 2 == 0 then
        graphics.color(Color.fromRGB(204, 255, 250))
    else
        graphics.color(Color.fromRGB(255, 255, 201))
    end
    graphics.alpha(1)
    graphics.circle(self.x, self.y, 2.5 + math.cos(s.f), false)
    graphics.alpha(0.75)
    graphics.circle(self.x, self.y, 7.5, true)

end)

local ultAOE = 32 --Radius of the Unit's blast.

local roboBlast = Object.new("RoboBallUlt")
roboBlast:addCallback("create", function(self)
    local s = self:getAccessor()
    local data = self:getData()
    s.f = 0
    s.size = ultAOE
    s.phase = 0
    s.detonate = 5*60
    s.a = 1
    self.y = FindGround(self.x, self.y)
end)
roboBlast:addCallback("step", function(self)
    local s = self:getAccessor()
    local data = self:getData()
    local parent = data.parent
    s.f = s.f + 1
    if s.phase == 0 then
        if s.f > s.detonate then
            misc.shakeScreen(10)
            if not objects.whiteFlash:find(1) then
                objects.whiteFlash:create(self.x, self.y)
            end
            if not sounds.shoot3_2:isPlaying() then
                sounds.shoot3_2:play(0.9 + math.random() * 0.1)
            end
            if parent then
                local exp = parent:fireExplosion(self.x, self.y, s.size / 19, 1, 1, sprites.sparks2, nil)
                exp:set("knockup", 5)
            end
            s.phase = 1
        end
    elseif s.phase == 1 then
        if s.a > 0 then
            s.a = s.a - 0.01
        else
            self:destroy()
            return
        end
    end
    
end)
roboBlast:addCallback("draw", function(self)
    local s = self:getAccessor()
    local data = self:getData()
    if s.phase == 0 then
        if s.f % 2 == 0 then
            graphics.color(Color.fromRGB(255, 255, 201))
        else
            graphics.color(Color.fromRGB(204, 255, 250))
        end
        graphics.alpha(0.5)
        graphics.line(self.x - s.size, self.y, self.x - s.size, self.y - 9999, 1)
        graphics.line(self.x + s.size, self.y, self.x + s.size, self.y - 9999, 1)
        graphics.alpha(math.abs(math.sin((math.pi / s.size) * s.f)))
        for i = -s.size/2, s.size/2 do
            if i % (s.size / 4) == 0 then
                graphics.rectangle((self.x - (((s.size/10) * i))), self.y - ((s.f % s.size) * 0.5), (self.x - ((s.size/10) * i)) + ((s.size/4) * ((s.size - math.abs(i)) / s.size)), self.y - (s.size/2) - ((s.f % s.size) * 0.5))
            end
        end
        if s.f % 2 == 0 then
            graphics.color(Color.fromRGB(204, 255, 250))
        else
            graphics.color(Color.fromRGB(255, 255, 201))
        end
        for i = -ultAOE/2, ultAOE/2 do
            if i % (ultAOE / 4) == 0 then
                graphics.rectangle((self.x - ((s.size/10) * i)), self.y - ((s.f % s.size) * 0.5), (self.x - ((s.size/10) * i)) + ((s.size/4) * ((s.size - math.abs(i)) / s.size)), self.y - (s.size/2) - ((s.f % s.size) * 0.5), true)
            end
        end
    elseif s.phase == 1 then
        if s.f % 2 == 0 then
            graphics.color(Color.fromRGB(255, 255, 201))
        else
            graphics.color(Color.fromRGB(204, 255, 250))
        end
        graphics.alpha(s.a)
        for i = -ultAOE/2, ultAOE/2 do
            if i % (ultAOE / 4) == 0 then
                graphics.rectangle((self.x - (((s.size/10) * i))), self.y - (s.size * (1-s.a)), (self.x - ((s.size/10) * i)) + ((s.size/4) * ((s.size - math.abs(i)) / s.size)), self.y - (s.size/2) - (s.size * (1-s.a)))
            end
        end
        if s.f % 2 == 0 then
            graphics.color(Color.fromRGB(204, 255, 250))
        else
            graphics.color(Color.fromRGB(255, 255, 201))
        end
        for i = -ultAOE/2, ultAOE/2 do
            if i % (ultAOE / 4) == 0 then
                graphics.rectangle((self.x - ((s.size/10) * i)), self.y - (s.size * (1-s.a)), (self.x - ((s.size/10) * i)) + ((s.size/4) * ((s.size - math.abs(i)) / s.size)), self.y - (s.size/2) - (s.size * (1-s.a)), true)
            end
        end
    end
    
end)

local RoboBallTurn = function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    if (self.moveLeft == 1 and self.facing ~= -1) or (self.moveRight == 1 and self.facing ~= 1) then
        self.state = "turn"
        return
    end
end

local bullets = 7 --How many bullets the Units will fire in their barrage attack.
local barrageIncrement = 15 --How quickly it takes the Unit to charge up one stock of their barrage.
local groundEasing = 25 --How close to the ground the Unit will descend.

local RoboBallInit = function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    self.name = "Solus Control Unit"
    self.name2 = "Corrupt AI"
    self.maxhp = 2500 * Difficulty.getScaling("hp")
    self.hp = self.maxhp
    self.damage = 15 * Difficulty.getScaling("damage")
    self.armor = 20
    self.pHmax = 0.6
    self.pGravity1 = 0
    self.pGravity2 = 0
    self.yy = 0
    actor.mask = sprites.mask
    actor:setAnimations{
        idle = sprites.idle,
        walk = sprites.idle,
        jump = sprites.idle,
        death = sprites.death
    }
    self.sound_hit = sounds.hit.id
    self.sound_death = sounds.death.id
    self.show_boss_health = 1
    self.health_tier_threshold = 1
    self.knockback_cap = self.maxhp
    self.facing = 1
    self.rotating = 0
    actor:set("sprite_palette", sprites.palette.id)
    self.z_range = 200
    self.x_range = 0
    self.c_range = 300
    self.v_range = 0
    self.shake_frame = 0
    self.can_drop = 1
    self.can_jump = 1
    self.z_charge = 0
    self.z_stock = 0
    self.z_target_x = 0
    self.z_target_y = 0
    self.chargeAngle = 0
    self.reticuleAlpha = 0
    self.moveDown = 0
    data.rage = false
end

local SuperRoboBallInit = function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    self.name = "Alloy Worship Unit"
    self.name2 = "Friend of Vultures"
    self.maxhp = 2500 * (Difficulty.getScaling("hp") * 1.5)
    self.hp = self.maxhp
    self.damage = 15 * Difficulty.getScaling("damage")
    self.armor = 20
    self.pHmax = 0.6
    self.pGravity1 = 0
    self.pGravity2 = 0
    self.yy = 0
    actor.mask = sprites.mask
    actor:setAnimations{
        idle = sprites.idleS,
        walk = sprites.idleS,
        jump = sprites.idleS,
        death = sprites.deathS
    }
    self.sound_hit = sounds.hit.id
    self.sound_death = sounds.death.id
    self.show_boss_health = 1
    self.health_tier_threshold = 1
    self.knockback_cap = self.maxhp
    self.facing = 1
    self.rotating = 0
    self.z_range = 400
    self.x_range = 0
    self.c_range = 400
    self.v_range = 0
    self.shake_frame = 0
    self.can_drop = 1
    self.can_jump = 1
    self.z_charge = 0
    self.z_stock = 0
    self.z_target_x = 0
    self.z_target_y = 0
    self.c_charge = 0
    self.chargeAngle = 0
    self.reticuleAlpha = 0
    self.moveDown = 0
    data.rage = false
end

local RoboBallStep = function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    local target = Object.findInstance(self.target)
    if misc.getTimeStop() > 0 then
        return
    end
    ------------------------------------------
    if target then
        if (target.y < actor.y) or (Stage.collidesRectangle(target.x, target.y, actor.x, actor.y)) then
            self.moveUp = 1
        elseif target.y > actor.y + groundEasing and self.free == 1 then
            self.moveDown = 1
        else
            self.moveUp = 0
            self.moveDown = 0
        end
    end
    self.yy = self.yy + (self.pHmax / 10)
    if self.moveUp == 1 then
        self.pVspeed = -math.abs((math.sin(self.yy) / 5))
    elseif self.moveDown == 1 then
        self.pVspeed = math.abs((math.sin(self.yy) / 5))
    else
        self.pVspeed = (math.sin(self.yy) / 5)
    end
    ------------------------------------------
    if self.facing and actor.xscale ~= self.facing then
        actor.xscale = self.facing
    end
    ------------------------------------------
    if self.activity == 0 and self.state ~= "turn" then
        if target and target:isValid() then
            if Distance(target.x, target.y, actor.x, actor.y) < self.c_range then
                self.c_skill = 1
            else
                self.c_skill = 0
            end
            if Distance(target.x, target.y, actor.x, actor.y) < self.z_range then
                self.z_skill = 1
            else
                self.z_skill = 0
            end
        end
        ----------------------------------------------------
        if self.z_skill == 1 and actor:getAlarm(2) == -1 then
            self.z_skill = 0
            self.state = "attack1"
            actor.sprite = sprites.shoot1
            sounds.shoot1_1:play(self.attack_speed)
            self.z_charge = 0
            self.activity = 1
            self.activity_type = 2
            self.moveLeft = 0
            self.moveRight = 0
            self.moveUp = 0
            self.moveDown = 0
            self.activity_var1 = 0
            self.activity_var2 = 0
            return
        elseif self.x_skill == 1 and actor:getAlarm(3) == -1 then
    
        elseif self.c_skill == 1 and actor:getAlarm(4) == -1 then
            self.c_skill = 0
            self.state = "attack3"
            self.stun_immune = 1
            actor.sprite = sprites.shoot1
            sounds.shoot3_1:play(self.attack_speed)
            self.c_charge = 0
            self.activity = 1
            self.activity_type = 1
            self.moveLeft = 0
            self.moveRight = 0
            self.moveUp = 0
            self.moveDown = 0
            self.activity_var1 = 0
            self.activity_var2 = 0
            return
    
        end

    end
    if self.state == "idle" then
        RoboBallTurn(actor)
        self.reticuleAlpha = 0
    elseif self.state == "chase" then
        RoboBallTurn(actor)
    elseif self.state == "attack1" then
        if self.stunned > 0 then
            actor:setAlarm(2, 5*60)
            self.activity = 0
            self.activity_type = 0
            self.reticuleAlpha = 0
            actor.sprite = sprites.idle
            self.activity_var1 = 0
            self.activity_var2 = 0
            self.z_charge = -1
            self.z_stock = 0
            self.state = "chase"
            return
        end
        actor.spriteSpeed = (self.attack_speed * self.reticuleAlpha) / 2
        if self.activity_var1 == 0 then
            if sounds.shoot1_1:isPlaying() then
                self.reticuleAlpha = math.approach(self.reticuleAlpha, 1, self.attack_speed * 0.1)
                self.z_charge = self.z_charge + 1
                if self.z_charge % barrageIncrement == 0 then
                    if self.z_stock < bullets then
                        self.z_stock = self.z_stock + 1
                    end
                end
            else
                self.z_target_x = target.x
                self.z_target_y = target.y
                self.activity_var1 = 1
                return
            end
        elseif self.activity_var1 == 1 then
            if self.z_stock > 0 then
                self.z_charge = self.z_charge - 1
                if self.z_charge % math.floor(math.round((barrageIncrement*0.5)) / self.attack_speed) == 0 then
                    sounds.shoot1_2:play(self.attack_speed + ((9 - self.z_stock) * 0.05))
                    local i = roboBullet:create(actor.x + (9 * actor.xscale), actor.y + 6)
                    i:getData().parent = actor
                    i:getAccessor().direction = GetAngleTowards(self.z_target_x + (20 * (3.5 - self.z_stock)), self.z_target_y, actor.x + (9 * actor.xscale), actor.y + 6)
                    i.depth = actor.depth - 1
                    self.z_stock = self.z_stock - 1
                end
            else
                if self.reticuleAlpha > 0 then
                    self.reticuleAlpha = math.approach(self.reticuleAlpha, 0, 0.1)
                else
                    actor:setAlarm(2, 5*60)
                    self.activity = 0
                    self.reticuleAlpha = 0
                    self.activity_type = 0
                    self.activity_var1 = 0
                    self.activity_var2 = 0
                    actor.sprite = sprites.idle
                    self.z_charge = -1
                    self.z_stock = 0
                    self.state = "chase"

                end
            end
        end
    elseif self.state == "attack3" then
        self.stunned = -1
        actor.spriteSpeed = self.attack_speed / 2
        if sounds.shoot3_1:isPlaying() then
            self.c_charge = self.c_charge + 1
        else
            if self.activity_var1 == 1 then
                self.c_charge = self.c_charge - 1
                for _, inst in ipairs(roboBlast:findAll()) do
                    if inst:getData().parent == actor then
                        inst:set("detonate", -1)
                    end
                end
                if self.c_charge < 0 then    
                    self.stun_immune = 0
                    actor:setAlarm(4, 30*60)
                    self.activity = 0
                    self.activity_type = 0
                    self.reticuleAlpha = 0
                    actor.sprite = sprites.idle
                    self.activity_var1 = 0
                    self.activity_var2 = 0
                    self.c_charge = -1
                    self.state = "chase"
                    return
                end
            end
        end
        if self.activity_var1 == 0 then
            for i = 0, 2 do
                local tg = misc.players[math.random(1, #misc.players)]
                if tg and Distance(actor.x, actor.y, tg.x, tg.y) < self.c_range then
                    local boom = roboBlast:create(tg.x + math.random(-ultAOE, ultAOE), tg.y)
                    boom:getData().parent = actor
                end
            end
            self.activity_var1 = 1
        end
    elseif self.state == "turn" then
        self.reticuleAlpha = 0
        if self.rotating == 0 then
            actor.spriteSpeed = self.pHmax * 0.5
            actor.sprite = sprites.turn
            self.activity = 50
            self.activity_type = 2
            self.rotating = 1
        elseif self.rotating == 1 then
            if math.floor(actor.subimage) >= sprites.turn.frames - 1 then
                actor.sprite = sprites.idle
                self.spriteSpeed = 0
                self.facing = -self.facing
                self.state = "idle"
                self.activity = 0
                self.activity_type = 0
                self.rotating = 0
                return
            end
        end

    end
end

local SuperRoboBallStep = function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    local target = Object.findInstance(self.target)
    if misc.getTimeStop() > 0 then
        return
    end
    ------------------------------------------
    if self.shield > 0 then
        self.shield_cooldown = 60
    end
    ------------------------------------------
    if target then
        if (target.y < actor.y) or (Stage.collidesRectangle(target.x, target.y, actor.x, actor.y)) then
            self.moveUp = 1
        elseif target.y > actor.y + groundEasing and self.free == 1 then
            self.moveDown = 1
        else
            self.moveUp = 0
            self.moveDown = 0
        end
    end
    self.yy = self.yy + (self.pHmax / 10)
    if self.moveUp == 1 then
        self.pVspeed = -math.abs((math.sin(self.yy) / 5))
    elseif self.moveDown == 1 then
        self.pVspeed = math.abs((math.sin(self.yy) / 5))
    else
        self.pVspeed = (math.sin(self.yy) / 5)
    end
    ------------------------------------------
    if self.facing and actor.xscale ~= self.facing then
        actor.xscale = self.facing
    end
    ------------------------------------------
    if self.activity == 0 and self.state ~= "turn" then
        if target and target:isValid() then
            if Distance(target.x, target.y, actor.x, actor.y) < self.c_range then
                self.c_skill = 1
            else
                self.c_skill = 0
            end
            if Distance(target.x, target.y, actor.x, actor.y) < self.z_range then
                self.z_skill = 1
            else
                self.z_skill = 0
            end
        end
        ----------------------------------------------------
        if self.z_skill == 1 and actor:getAlarm(2) == -1 then
            self.z_skill = 0
            self.state = "attack1"
            actor.sprite = sprites.idleS
            sounds.shoot1_1:play(self.attack_speed)
            self.z_charge = 0
            self.activity = 1
            self.activity_type = 2
            self.moveLeft = 0
            self.moveRight = 0
            self.moveUp = 0
            self.moveDown = 0
            self.activity_var1 = 0
            self.activity_var2 = 0
            return
        elseif self.x_skill == 1 and actor:getAlarm(3) == -1 then
    
        elseif self.c_skill == 1 and actor:getAlarm(4) == -1 then
            self.c_skill = 0
            self.state = "attack3"
            self.stun_immune = 1
            actor.sprite = sprites.idleS
            sounds.shoot3_1:play(self.attack_speed)
            self.c_charge = 0
            self.maxshield = self.maxshield + self.maxhp
            self.shield = self.shield + self.maxhp
            self.activity = 1
            self.activity_type = 1
            self.moveLeft = 0
            self.moveRight = 0
            self.moveUp = 0
            self.moveDown = 0
            self.activity_var1 = 0
            self.activity_var2 = 0
            return
    
        end

    end
    if self.state == "idle" then
        RoboBallTurn(actor)
        self.reticuleAlpha = 0
    elseif self.state == "chase" then
        RoboBallTurn(actor)
    elseif self.state == "attack1" then
        self.knockback_value = 0
        self.force_knockback = 0
        actor.spriteSpeed = (self.attack_speed * self.reticuleAlpha) / 2
        if self.activity_var1 == 0 then
            if sounds.shoot1_1:isPlaying() then
                self.reticuleAlpha = math.approach(self.reticuleAlpha, 1, self.attack_speed * 0.1)
                self.z_charge = self.z_charge + 1
                if self.z_charge % barrageIncrement == 0 then
                    if self.z_stock < bullets then
                        self.z_stock = self.z_stock + 1
                    end
                end
            else
                self.z_target_x = target.x
                self.z_target_y = target.y
                self.activity_var1 = 1
                return
            end
        elseif self.activity_var1 == 1 then
            if self.z_stock > 0 then
                self.z_charge = self.z_charge - 1
                if self.z_charge % math.floor(math.round((barrageIncrement*0.5)) / self.attack_speed) == 0 then
                    sounds.shoot1_2:play(self.attack_speed + ((9 - self.z_stock) * 0.05))
                    local i = roboBullet:create(actor.x + (9 * actor.xscale), actor.y + 6)
                    i:getData().parent = actor
                    i:getAccessor().direction = GetAngleTowards(self.z_target_x + (35 * (3.5 - self.z_stock)), self.z_target_y, actor.x + (9 * actor.xscale), actor.y + 6)
                    i.depth = actor.depth - 1
                    self.z_stock = self.z_stock - 1
                end
            else
                if self.reticuleAlpha > 0 then
                    self.reticuleAlpha = math.approach(self.reticuleAlpha, 0, 0.1)
                else
                    actor:setAlarm(2, 4*60)
                    self.activity = 0
                    self.reticuleAlpha = 0
                    self.activity_type = 0
                    self.activity_var1 = 0
                    self.activity_var2 = 0
                    actor.sprite = sprites.idleS
                    self.z_charge = -1
                    self.z_stock = 0
                    self.state = "chase"

                end
            end
        end
    elseif self.state == "attack3" then
        actor:setAlarm(4, 30*60)
        self.knockback_value = 0
        self.force_knockback = 0
        actor.spriteSpeed = self.attack_speed / 2
        if sounds.shoot3_1:isPlaying() then
            self.c_charge = self.c_charge + 2
        else
            if self.activity_var1 == 1 then
                self.c_charge = self.c_charge - 1
                for _, inst in ipairs(roboBlast:findAll()) do
                    if inst:getData().parent == actor then
                        inst:set("detonate", -1)
                    end
                end
                if self.c_charge < 0 then    
                    self.stun_immune = 0
                    self.activity = 0
                    self.activity_type = 0
                    self.reticuleAlpha = 0
                    self.maxshield = self.maxshield - self.maxhp
                    self.shield = self.shield - self.maxhp
                    actor.sprite = sprites.idleS
                    self.activity_var1 = 0
                    self.activity_var2 = 0
                    self.c_charge = -1
                    self.state = "chase"
                    return
                end
            end
        end
        if self.activity_var1 == 0 then
            for i = 0, 3 do
                local tg = misc.players[math.random(1, #misc.players)]
                if tg and Distance(actor.x, actor.y, tg.x, tg.y) < self.c_range then
                    local boom = roboBlast:create(tg.x + math.random(-ultAOE, ultAOE), tg.y)
                    boom:getData().parent = actor
                end
            end
            self.activity_var1 = 1
        end
    elseif self.state == "turn" then
        self.reticuleAlpha = 0
        if self.rotating == 0 then
            actor.spriteSpeed = self.pHmax * 0.5
            actor.sprite = sprites.turnS
            self.activity = 50
            self.activity_type = 2
            self.rotating = 1
        elseif self.rotating == 1 then
            if math.floor(actor.subimage) >= sprites.turn.frames - 1 then
                actor.sprite = sprites.idleS
                self.spriteSpeed = 0
                self.facing = -self.facing
                self.state = "idle"
                self.activity = 0
                self.activity_type = 0
                self.rotating = 0
                return
            end
        end

    end
end

local RoboBallDraw = function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    if self.reticuleAlpha > 0 then
        self.chargeAngle = self.chargeAngle + 5
        graphics.drawImage{
            image = sprites.charge,
            x = actor.x + (9 * actor.xscale),
            y = actor.y + 6,
            subimage = actor.subimage,
            angle = self.chargeAngle,
            alpha = (self.reticuleAlpha * (0.7 + (math.random() * 0.15)))
        }
    end
end

local roboCorpse = Object.new("RoboBallBody")
roboCorpse.sprite = sprites.death
roboCorpse:addCallback("create", function(self)
    local s = self:getAccessor()
    local data = self:getData()
    self.mask = sprites.mask
    self.spriteSpeed = 0
    s.direction = math.random(360)
    s.speed = 0
    s.f = 0
end)

roboCorpse:addCallback("step", function(self)
    local s = self:getAccessor()
    local data = self:getData()
    s.f = s.f + 1
    s.speed = s.speed + 0.1
    self.angle = self.angle + (self.xscale * s.speed)
    s.direction = s.direction + math.random(math.sin(s.f * 0.1) * 5, math.cos(s.f * 0.1) * 5)
    if s.f % 5 == 0 then
        if math.random() < 0.5 then
            misc.fireExplosion(self.x + math.random(-25, 25), self.y + math.random(-25, 25), 0, 0, 0, "neutral", sprites.sparks1)
        else
            misc.fireExplosion(self.x + math.random(-25, 25), self.y + math.random(-25, 25), 0, 0, 0, "neutral", sprites.sparks3)
        end
    end
    if Stage.collidesPoint(self.x, self.y) then
        sounds.shoot3_2:play(0.8, 1)
        local flash = objects.whiteFlash:create(self.x, self.y)
        flash:set("rate", 0.01)
        misc.shakeScreen(30)
        misc.fireExplosion(self.x, self.y, 0, 0, 0, "neutral", sprites.sparks2)
        self:destroy()
        return
    end
end)

local roboball = Object.base("BossClassic", "RoboBall")
roboball.sprite = sprites.idle

roboball:addCallback("create", function(actor)
    RoboBallInit(actor)
end)

roboball:addCallback("step", function(actor)
    RoboBallStep(actor)
end)

roboball:addCallback("draw", function(actor)
    RoboBallDraw(actor)
end)

roboball:addCallback("destroy", function(actor)
    for _, inst in ipairs(roboBlast:findAll()) do
        if inst:getData().parent == actor then
            inst:set("detonate", -1)
        end
    end
    local body = roboCorpse:create(actor.x, actor.y)
    body.xscale = actor.xscale
end)

local superroboball = Object.base("BossClassic", "RoboBallS")
superroboball.sprite = sprites.idleS

superroboball:addCallback("create", function(actor)
    SuperRoboBallInit(actor)
end)

superroboball:addCallback("step", function(actor)
    SuperRoboBallStep(actor)
end)

superroboball:addCallback("draw", function(actor)
    RoboBallDraw(actor)
end)

superroboball:addCallback("destroy", function(actor)
    for _, inst in ipairs(roboBlast:findAll()) do
        if inst:getData().parent == actor then
            inst:set("detonate", -1)
        end
    end
    local body = roboCorpse:create(actor.x, actor.y)
    body.sprite = sprites.deathS
    body.xscale = actor.xscale
end)

local roboBallCard = MonsterCard.new("Solus Control Unit", roboball)
roboBallCard.sprite = sprites.spawn
roboBallCard.sound = sounds.spawn
roboBallCard.canBlight = false
roboBallCard.isBoss = true
roboBallCard.type = "offscreen"
roboBallCard.cost = 1000
for _, elite in ipairs(EliteType.findAll("vanilla")) do
    roboBallCard.eliteTypes:add(elite)
end
for _, elite in ipairs(EliteType.findAll("RoR2Demake")) do
    roboBallCard.eliteTypes:add(elite)
end

local monsLog1 = MonsterLog.new("Solus Control Unit")
MonsterLog.map[roboball] = monsLog1

monsLog1.displayName = "Solus Control Unit"
monsLog1.story = "This must be the mother computer of the Solus Probes I encountered earlier. The crash must have triggered its awakening, and the hostility of the planet's fauna must have forced it into a self-defense mode. A part of me wishes it had been destroyed, as it views anything that moves as a threat, including me. I don't blame it, but I would have loved to repair it and use it as a potential ally.\n\nThe Control Unit's self-defense systems weren't damage at all in the crash... Lucky me. As a swarm of Probes tailed behind it, it launched volley after volley of energy rounds at me, scorching the landscape."
monsLog1.statHP = 2500
monsLog1.statDamage = 15
monsLog1.statSpeed = 0.6
monsLog1.sprite = sprites.spawn
monsLog1.portrait = sprites.idle
monsLog1.portraitSubimage = 1

local monsLog2 = MonsterLog.new("Alloy Worship Unit")
MonsterLog.map[superroboball] = monsLog2

monsLog2.displayName = "Alloy Worship Unit"
monsLog2.story = "I shouldn't have had eggs for breakfast. After raiding some more vulture nests, I heard machines whirring to life. Turning around, I saw a Solus Control Unit rising from the ground behind me, covered in dirt and fauna. It must have been resting there for ages... I haven't been on this planet THAT long, have I?\n\nThe Alloy Worship Unit, as I have come to call it, differs from a standard Solus unit as it appears to have befriended the vultures that peck at and harass me. Tarnishing their nests has enraged the machine, and now its primary objective appears to be staining the ground black with my ashes."
monsLog2.statHP = 5000
monsLog2.statDamage = 15
monsLog2.statSpeed = 0.6
monsLog2.sprite = sprites.idleS
monsLog2.portrait = sprites.idleS
monsLog2.portraitSubimage = 1
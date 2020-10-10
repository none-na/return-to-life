--playerbots

local survivors = {
    commando = 1,
}

local sprites = {
    commando = {
    	idle = Sprite.find("GManIdle", "vanilla"),
    	walk = Sprite.find("GManWalk", "vanilla"),
	    jump = Sprite.find("GManJump", "vanilla"),
    	climb = Sprite.find("GManClimb", "vanilla"),
        death = Sprite.find("GManDeath", "vanilla"),
	    shoot1 = Sprite.find("GManShoot1", "vanilla"),
	    shoot2 = Sprite.find("GManShoot2", "vanilla"),
    	shoot3 = Sprite.find("GManShoot3", "vanilla"),
	    shoot4_1 = Sprite.find("GManShoot4_1", "vanilla"),
    	shoot4_2 = Sprite.find("GManShoot4_2", "vanilla"),
	    shoot5_1 = Sprite.find("GManShoot5_1", "vanilla"),
    	shoot5_2 = Sprite.find("GManShoot5_2", "vanilla"),
	    sparks1 = Sprite.find("Sparks1", "vanilla"),
	    sparks2 = Sprite.find("Sparks2", "vanilla")
    }
}

local sounds = {
    commando = {
	    bullet1 = Sound.find("bullet1", "vanilla"),
    	bullet2 = Sound.find("bullet2", "vanilla"),
	    bullet3 = Sound.find("bullet3", "vanilla"),
	    guardDeath = Sound.find("GuardDeath", "vanilla")
    }
}

local Bots = {
    commando = {},
}

local survivorFunctions = {
    [1] = { --Commando
        init = function(player)
            local data = player:getData()
            local self = player:getAccessor()
            self.name = "Commando"
            self.maxhp = 110 
            data.level = 1
            self.hp = self.maxhp
            self.damage = 12
            self.pHmax = 1.3
            player:setAnimations{
                idle = sprites.commando.idle,
                walk = sprites.commando.walk,
                jump = sprites.commando.jump,
                shoot1 = sprites.commando.shoot1,
                shoot2 = sprites.commando.shoot2,
                shoot3 = sprites.commando.shoot3,
                shoot4 = sprites.commando.shoot4,
                death = sprites.commando.death
            }
            player.mask = sprites.mask
            self.health_tier_threshold = 1
            self.knockback_cap = self.maxhp
            self.exp_worth = 0
            self.z_range = 700
            self.can_drop = 1
            self.can_jump = 1
        end,
        step = function(player)
            local data = player:getData()
            local self = player:getAccessor()
            if self.state == "attack1" then --double tap
                if player:getAlarm(2) <= -1 then
                    if self.free ~= 1 then
                        self.pHspeed = 0
                    end
                    if player.sprite == sprites.shoot1 then
                        local frame = math.floor(player.subimage)
                        if data.lastSubimage ~= frame then
                            if frame >= sprites.shoot1.frames or self.state == "feared" or self.state ~= "attack1" or self.stunned > 0 then
                                self.activity = 0
                                self.activity_type = 0
                                player.spriteSpeed = 0.25
                                self.state = "idle"
                                player:setAlarm(2, (0.2*60))
                                self.activity_var1 = 0
                                self.activity_var2 = 0
                                return
                            end
                            if frame == 1 then
                                sounds.bullet1:play(self.attack_speed + math.random() * 0.01)
                                player:fireBullet(player.x, player.y, player:getFacingDirection(), 700, 0.9, sprites.commando.sparks1)
                            elseif frame == 3 then
                                player:fireBullet(player.x, player.y, player:getFacingDirection(), 700, 0.9, sprites.commando.sparks1)
                            end
                        end
                    else
                        player.subimage = 1
                        self.z_skill = 0
                        player.spriteSpeed = self.attack_speed * 0.20
                        self.activity = 2
                        self.activity_type = 1
                    end
                end
                data.lastSubimage = math.floor(player.subimage)
            end
        end,
        destroy = function(player)

        end,
        draw = function(player)

        end
    }
}

local playerbot = Object.base("EnemyClassic", "PlayerBot")
playerbot.sprite = sprites.commando.idle

playerbot:addCallback("create", function(player)
    local data = player:getData()
    local self = player:getAccessor()
    data.survivor = 1
    data.lastSubimage = 0
    self.team = "player"
    survivorFunctions[data.survivor].init(player)
end)

playerbot:addCallback("step", function(player)
    local data = player:getData()
    local self = player:getAccessor()
end)

playerbot:addCallback("destroy", function(player)
    local data = player:getData()
    local self = player:getAccessor()
end)

playerbot:addCallback("draw", function(player)
    local data = player:getData()
    local self = player:getAccessor()
end)

callback.register("onGameEnd", function()
    Bots = {}
end)
--require("Misc.loadout")
--require("Libraries.skill.main")

---------------
-- Resources --
---------------

local baseSprites = {
	idle = Sprite.find("EngiIdle", "vanilla"),
	walk = Sprite.find("EngiWalk", "vanilla"),
	jump = Sprite.find("EngiJump", "vanilla"),
	climb = Sprite.find("EngiClimb", "vanilla"),
	death = Sprite.find("EngiDeath", "vanilla"),
}

local sprites = {
	shoot1 = Sprite.find("EngiShoot1", "vanilla"),
	shoot3 = Sprite.find("EngiShoot3", "vanilla"),
	icons = Sprite.load("EngiSkills", "Actors/engi/skills", 9, 0, 0),
	palettes = Sprite.load("EngiPalettes", "Actors/engi/palettes", 1, 0, 0),
    loadout = Sprite.find("SelectEngi", "vanilla"),
    mine = Sprite.find("EngiMine", "vanilla"),
    mineIdle = Sprite.find("EngieMineIdle", "vanilla"),
    mineJump = Sprite.find("EngiMineJump", "vanilla"),
    mineArmedIdle = Sprite.load("EngiArmedMineIdle", "Actors/engi/pressureMineArmed", Sprite.find("EngieMineIdle", "vanilla").frames, Sprite.find("EngieMineIdle", "vanilla").xorigin, Sprite.find("EngieMineIdle", "vanilla").yorigin),
    mineArmedJump = Sprite.load("EngiArmedMineJump", "Actors/engi/pressureMineJump", Sprite.find("EngiMineJump", "vanilla").frames, Sprite.find("EngiMineJump", "vanilla").xorigin, Sprite.find("EngiMineJump", "vanilla").yorigin),
    stunner = Sprite.find("EngieStunner", "vanilla"),
    grenade = Sprite.find("EngiGrenade", "vanilla"),
    grenadeExplosion = Sprite.find("EngiGrenadeExplosion", "vanilla"),
	harpoon = Sprite.find("EngiHarpoon", "vanilla"),
	missileExplosion = Sprite.find("EfMissileExplosion", "vanilla"),
    turretBase = Sprite.find("EngiTurret1Base", "vanilla"),
    turretRotate = Sprite.find("EngiTurret1HeadRotate", "vanilla"),
    turretShoot = Sprite.find("EngiTurret1HeadShoot1", "vanilla"),
	turretSpawn = Sprite.find("EngiTurret1Spawn", "vanilla"),
	mobileBaseIdle = Sprite.load("EngiMobileTurretIdle", "Actors/engi/mobileTurretBaseIdle", 1, 9, 14),
	mobileBaseWalk = Sprite.load("EngiMobileTurretWalk", "Actors/engi/mobileTurretWalk", 4, 9, 14),
	mobileBaseJump = Sprite.load("EngiMobileTurretJump", "Actors/engi/mobileTurretJump", 1, 9, 16),
	mobileRotate = Sprite.load("EngiMobileTurretHeadRotate", "Actors/engi/mobileTurretHeadRotate", 7, 9, 14),
	mobileShoot1 = Sprite.load("EngiMobileTurretHeadShoot1", "Actors/engi/mobileTurretHeadShoot1", 6, 12, 16),
    superTurretBase = Sprite.find("EngiTurret2Base", "vanilla"),
    superTurretRotate = Sprite.find("EngiTurret2HeadRotate", "vanilla"),
    superTurretShoot = Sprite.find("EngiTurret2HeadShoot1", "vanilla"),
	superTurretSpawn = Sprite.find("EngiTurret2Spawn", "vanilla"),
	sparks1 = Sprite.find("Sparks1", "vanilla")

}

local sounds = {
	JanitorShoot1_1 = Sound.find("JanitorShoot1_1", "vanilla"),
	GiantJellyExplosion = Sound.find("GiantJellyExplosion", "vanilla"),
	CowboyShoot2 = Sound.find("CowboyShoot2", "vanilla"),
	Click = Sound.find("Click", "vanilla"),
	Mine = Sound.find("Mine", "vanilla"),
	Smite = Sound.find("Smite", "vanilla"),
	MissileLaunch = Sound.find("MissileLaunch", "vanilla"),
	Bullet3 = Sound.find("Bullet3", "vanilla"),
	DroneDeath = Sound.find("DroneDeath", "vanilla")
}

local objects = {
	flash = Object.find("EfFlash", "vanilla"),
	sparks = Object.find("EfSparks", "vanilla")
}

local particles = {
	harpoon = ParticleType.find("EngiHarpoon", "vanilla"),
	sparks = ParticleType.find("Spark", "vanilla")
}

local actors = ParentObject.find("actors", "vanilla")
local enemies = ParentObject.find("enemies", "vanilla")

---------------
--Projectiles--
---------------

-- Grenades

local engiNade = Object.new("Engineer Grenade")
engiNade.sprite = sprites.grenade

engiNade:addCallback("create", function(self)
	self.spriteSpeed = 0.3
	self.mask = sprites.grenade
	self.subimage = math.random(sprites.grenade.frames)
	self:set("ay", 0.15)
	self:set("team", "player")
	self.angle = math.random(360)
	self:set("rotate", 3)
	self:set("phase", 0)
	self:set("bounces", 0)
	self:set("bounce", 0.5)
end)

engiNade:addCallback("step", function(self)
	local data = self:getData()
	if self:get("phase") ~= 0 then
		if math.round(self.subimage) >= sprites.grenadeExplosion.frames then
			self:destroy()
		end
	else
		self.x = self.x + (self:get("vx") or 0)
		self.y = self.y + (self:get("vy") or 0)	
		self:set("vx", (self:get("vx") or 0) + (self:get("ax") or 0))
		self:set("vy", (self:get("vy") or 0) + (self:get("ay") or 0))
		if self:get("vx") > 0 then self:set("direction", 1)
		elseif self:get("vx") < 0 then self:set("direction", -1)
		else self:set("direction", 0) end
		if self:get("rotate") ~= nil then
			self.yscale = 1
			self.xscale = 1
			local _pvx = self:get("vx") or 0
			local _pvy = -(self:get("vy") or 0)
			local _angle = math.atan(_pvy/_pvx)*(180/math.pi)
			if _pvx < 0 then _angle = _angle + 180 end
			self.angle = (self:get("rotate") + _angle)%360
		end
		if self:collidesMap(self.x,self.y) then
			local _vx = (self:get("vx") or 0)
			local _vy = (self:get("vy") or 0)
			self.x = self.x - _vx
			self.y = self.y - _vy
			local _vcollision = self:collidesMap(self.x, self.y + _vy)
			local _hcollision = self:collidesMap(self.x + _vx, self.y)
			if (not _hcollision) and (not _vcollision) then
				self:set("vx", - _vx * self:get("bounce"))
				self:set("vy", - _vy * self:get("bounce"))
			elseif _vcollision then
				self:set("vy", - _vy * self:get("bounce"))
			elseif _hcollision then
				self:set("vx", - _vx * self:get("bounce"))
			end
			self:set("bounces", self:get("bounces") + 1)
			if self:get("bounces") > 3 then
				self:set("phase", 1)
			end
		end
		for _, actor in ipairs(actors:findAll()) do
			if self:isValid() and self:collidesWith(actor, self.x, self.y) then
				if actor:get("team") ~= self:get("team") then
					self:set("phase", 1)
				end
			end
		end
		if self:get("phase") ~= 0 then
			self.sprite = sprites.grenadeExplosion
			sounds.GiantJellyExplosion:play(0.8 + math.random() * 0.8)
			if data.parent then
				data.parent:fireExplosion(self.x, self.y, 0.8, 1.3, 1, sprites.sparks1, nil)
			else
				misc.fireExplosion(self.x, self.y, 0.8, 1.3, (self:get("damage") or 12), self:get("team") or "player", sprites.sparks1, nil)
			end
			self.subimage = 1
		end
	end
end)

local maxNades = 8
local grenadeIncrement = 30

local chargeSmoke = ParticleType.new("EngiGrenadeCharge")
chargeSmoke:shape("Square")
chargeSmoke:color(Color.GREEN)
chargeSmoke:alpha(0.1)
chargeSmoke:scale(0.05, 0.07)
chargeSmoke:size(0.9, 1, -0.005, 0.0025)
chargeSmoke:angle(0, 360, 1, 0.5, true)
chargeSmoke:life(60, 85)
chargeSmoke:direction(90, 90, 0, 0)
chargeSmoke:speed(0.1, 0.1, 0, 0)

local fireNade = ParticleType.new("EngiGrenadeLaunch")
fireNade:sprite(Sprite.load("Actors/engi/fireGrenade", 3, 4, 3), true, true, false)
fireNade:life(15, 15)


local ChargeGrenade = function(player)
	local p = player:getAccessor()
	if p.grenade_charge then
		if p.grenade_phase == 1 then
			p.grenade_charge = p.grenade_charge + 1
			if math.floor(p.grenade_charge) % math.round(grenadeIncrement / player:get("attack_speed")) == 0 then
				sounds.Click:play(1 + ((p.grenade_count) * 0.1))
				p.grenade_count = p.grenade_count + 1
			end
			if p.grenade_charge / (maxNades * grenadeIncrement) >= math.random() then
				local xOffset = 6
				local yOffset = 5
				if math.random() < 0.5 then
					xOffset = -xOffset
				end
				chargeSmoke:burst("middle", player.x + xOffset +math.random(-2, 2), player.y - yOffset, 1)
			end
			if p.grenade_count >= maxNades then
				p.grenade_phase = 2
			end
		elseif p.grenade_phase == 2 then
			if p.grenade_charge > -1 then
				p.grenade_charge = p.grenade_charge - 1
				if p.grenade_charge % math.round(math.round(grenadeIncrement / player:get("attack_speed")) / 5) == 0 then
					local xOffset = 6
					local yOffset = 6
					local pitch = 1
					if p.grenade_count % 2 == 0 then
						xOffset = -xOffset
						pitch = 0.8
					end
					sounds.CowboyShoot2:play(pitch + math.random() * 0.1)
					fireNade:burst("above", player.x + (xOffset * player.xscale), player.y - yOffset, 1)
					local nade = engiNade:create(player.x + (xOffset * player.xscale), player.y - yOffset)
					nade:set("vx", (math.max(p.pHmax, math.abs(p.pHspeed) * 1.6)) * player.xscale)
					nade:set("vy", -p.pVmax / 4)
					p.grenade_count = p.grenade_count - 1
					if p.grenade_count < 1 then
						p.grenade_charge = -1
					end
				end
			else
				player:activateSkillCooldown(1)
				p.grenade_phase = 0
			end
		end
	else
		p.grenade_phase = 0
		p.grenade_charge = -1
		p.grenade_count = 0
	end
end

-- Harpoons

local harpoon = Object.new("EngiHarpoon")
harpoon.sprite = sprites.harpoon
harpoon:addCallback("create", function(this)
	local self = this:getAccessor()
	local data = this:getData()
	self.f = 0
	self.yy = 0
	self.width = 1
	self.speed = 6
	this.spriteSpeed = 0.3
	self.team = "player"
	self.hit = 0
	self.target = -1
	self.direction = 90
end)
harpoon:addCallback("step", function(this)
	local self = this:getAccessor()
	local data = this:getData()
	self.width = math.min(self.width + 0.1, 5)
	local parent = data.parent
	self.f = self.f + 1
	this.angle = self.direction
	if parent then
		local target = Object.findInstance(self.target)
		if self.f >= 30 and not target then
			local nearest = enemies:findNearest(parent.x, parent.y)
			if nearest and nearest:get("team") ~= self.team then
				if Distance(this.x, this.y, nearest.x, nearest.y) > 600 then this:destroy() return end
				self.target = nearest.id
			end
		end
		if misc.getOption("video.quality") >= 2 then
			particles.harpoon:color(Color.YELLOW, Color.ORANGE)
			particles.harpoon:angle(self.direction, self.direction, 0, 0, true)
			particles.harpoon:burst("above", this.x, this.y, 1)
		end
		if target then
			if Distance(this.x, this.y, target.x, target.y) < 40 then
				self.direction = GetAngleTowards(target.x, target.y, this.x, this.y)
			else
				local angdiff = ((((self.direction - GetAngleTowards(target.x, target.y, this.x, this.y)) % 360) + 540) % 360)
				self.direction = math.approach(self.direction, GetAngleTowards(target.x, target.y, this.x, this.y), (angdiff/10))
			end
			if this:collidesWith(target, this.x, this.y) then
				if target:get("team") ~= self.team and target:get("team") .. "proc" ~= self.team and self.hit == 0 then
					if parent then
						parent:fireBullet(target.x, target.y,self.direction, 1, 2.5, sprites.missileExplosion, nil)
						this:destroy()
						return
					end
				end
			end
		end
	end
	if self.f > 60*5 then
		this:destroy()
		return
	end

end)
harpoon:addCallback("draw", function(this)
	local self = this:getAccessor()
	local data = this:getData()
	graphics.alpha(0.5)
	graphics.color(Color.fromRGB(37, 222, 112))
	graphics.circle(this.x, this.y, 7, true)
	graphics.circle(this.x, this.y, 4, false)
	graphics.alpha(1)
end)

------------
-- Mines  --
------------

local StepMines = function(player)
	local data = player:getData()
	local count = 0
	for _, mine in ipairs(data.mines) do
		if mine:isValid() and mine:getAccessor().active < 2 then
			count = count + 1
		end
	end
	if count >= Ability.getMaxCharge(player, "x") + 1 then
		for _, inst in ipairs(data.mines) do
			if inst:isValid() then
				inst:destroy()
				break
			end
		end
	end
end

local mine = Object.new("EngiMineBasic")
mine.sprite = sprites.mineIdle

mine:addCallback("create", function(this)
	local self = this:getAccessor()
	local data = this:getData()
	this.mask = sprites.stunner
	this.spriteSpeed = 0.3
	this.y = FindGround(this.x, this.y)
	self.life = 60*60*2
	self.arm = 30
	self.active = 0
	self.fired = 0
	sounds.Mine:play(1.5)
end)

mine:addCallback("step", function(this)
	local self = this:getAccessor()
	local data = this:getData()
	local parent = data.parent
	if self.life > -1 then
		self.life = self.life - 1
	else
		this:destroy()
		return
	end
	if self.arm > -1 then
		self.arm = self.arm - 1
	else
		if self.active == 0 then
			self.active = 1
		end
	end
	if self.active == 1 then
		local nearest = actors:findNearest(this.x, this.y)
		if nearest and nearest:isValid() then
			if this:collidesWith(nearest,this.x, this.y) and parent and nearest:get("team") ~= parent:get("team") then
				sounds.GiantJellyExplosion:play(3)
				this.sprite = sprites.mineJump
				this.subimage = 1
				this.spriteSpeed = 0.3
				self.active = 2
				return
			end
		end
	elseif self.active == 2 then
		if math.floor(this.subimage) >= 6 and self.fired == 0 and parent then
			misc.shakeScreen(5)
			sounds.Smite:play(1.5)
			parent:fireExplosion(this.x, this.y, 1.2, 1, 3, nil, sprites.sparks1)
			self.fired = 1
		end
		if this.sprite == sprites.mineJump and math.floor(this.subimage) >= sprites.mineJump.frames - 1 then
			this:destroy()
			return
		end
	end
end)

mine:addCallback("draw", function(this)
	local self = this:getAccessor()
	local data = this:getData()
end)

local mineArm = Object.new("EngiMineArmed")
mineArm.sprite = sprites.mineIdle

mineArm:addCallback("create", function(this)
	local self = this:getAccessor()
	local data = this:getData()
	this.mask = sprites.stunner
	this.spriteSpeed = 0.3
	this.y = FindGround(this.x, this.y)
	self.life = 60*60*2
	self.arm = 2*60
	self.active = 0
	self.fired = 0
	self.radius = 10
	self.r = 0
	sounds.Mine:play(1.5)
end)

mineArm:addCallback("step", function(this)
	local self = this:getAccessor()
	local data = this:getData()
	local parent = data.parent
	self.r = math.approach(self.r, self.radius, 1)
	if self.life > -1 then
		self.life = self.life - 1
	else
		this:destroy()
		return
	end
	if self.arm > -1 then
		self.arm = self.arm - 1
	else
		if self.active == 0 then
			self.active = 1
			this.sprite = sprites.mineArmedIdle
			self.radius = 30
			sounds.Mine:play(1)
		end
	end
	local nearest = actors:findNearest(this.x, this.y)
	if nearest and nearest:isValid() then
		if (this:collidesWith(nearest,this.x, this.y) or Distance(nearest.x, nearest.y, this.x, this.y) <= self.radius) and parent and nearest:get("team") ~= parent:get("team") then
			if self.active == 0 then
				sounds.GiantJellyExplosion:play(3)
				this.sprite = sprites.mineJump
				this.subimage = 1
				this.spriteSpeed = 0.3
				self.active = 2
				return
			elseif self.active == 1 then
				sounds.GiantJellyExplosion:play(3)
				this.sprite = sprites.mineArmedJump
				this.subimage = 1
				this.spriteSpeed = 0.3
				self.active = 2
				return
			end
		end
	end
	if self.active == 2 then
		if math.floor(this.subimage) >= 6 and self.fired == 0 and parent then
			if this.sprite == sprites.mineJump then
				misc.shakeScreen(5)
				sounds.Smite:play(1.5)
				parent:fireExplosion(this.x, this.y, 1.2, 1, 3, nil, sprites.sparks1)
				self.fired = 1
			else
				misc.shakeScreen(10)
				sounds.Smite:play(1)
				parent:fireExplosion(this.x, this.y, 1.5, 1.3, 9, nil, sprites.sparks1)
				self.fired = 1
			end
		end
		if (this.sprite == sprites.mineJump or this.sprite == sprites.mineArmedJump) and math.floor(this.subimage) >= this.sprite.frames - 1 then
			this:destroy()
			return
		end
	end
end)

mineArm:addCallback("draw", function(this)
	local self = this:getAccessor()
	local data = this:getData()
	if self.active == 0 then
		graphics.alpha(0.5)
		graphics.color(Color.GREEN)
		graphics.circle(this.x, this.y, self.r, true)

	elseif self.active == 1 then
		
		graphics.alpha(0.5)
		graphics.color(Color.ROR_RED)
		graphics.circle(this.x, this.y, self.r, true)
	end
end)


------------
--Turrets --
------------

local followDistance = 50

local StepTurrets = function(player)
	local data = player:getData()
	local count = 0
	for _, turret in ipairs(data.turrets) do
		if turret:isValid() then
			count = count + 1
		end
	end
	if count >= Ability.getMaxCharge(player, "v") + 1 then
		for _, inst in ipairs(data.turrets) do
			if inst:isValid() then
				inst:destroy()
				break
			end
		end
	end
end

SetTurretSprite = function(turret, sprite)
	turret:setAnimations{
		idle = sprite,
		walk = sprite,
		death = sprite,
	}
end

local FindTarget = function(turret, direction, distance)
	return enemies:findLine(turret.x, turret.y, turret.x + (distance * direction), turret.y)
end

local TurretStates = {
	["idle"] = true,
	["set up"] = true,
	["chase"] = true,
	["head rotate"] = true,
	["firing1"] = true
}

local turret = Object.base("EnemyClassic","EngiTurret")
turret.sprite = sprites.turretBase

local mobileTurret = Object.base("EnemyClassic","EngiMobileTurret")
mobileTurret.sprite = sprites.turretBase

local InitTurret = function(inst, level, super)
	local i = inst:getAccessor()
	local data = inst:getData()
	if not level then level = 1 end
	if super then
		i.maxhp_base = 320 + (50 * (level - 1))
		i.hp = 320 + (50 * (level - 1))
		i.hp_regen = 0.003 + (0.003 * (level - 1))
		i.armor = 30 + (2 * (level - 1))
		i.damage = 16 + (5 * (level - 1))
		i.attack_speed = i.attack_speed + 0.2
		inst:setAnimations{
			base = sprites.superTurretBase,
			spawn = sprites.superTurretSpawn,
			attack = sprites.superTurretShoot,
			rotate = sprites.superTurretRotate,
		}
	else
		i.maxhp_base = 160 + (39 * (level - 1))
		i.hp = 160 + (39 * (level - 1))
		i.hp_regen = 0.002 + (0.0025 * (level - 1))
		i.armor = 30 + (2 * (level - 1))
		i.damage = 14 + (3 * (level - 1))
		inst:setAnimations{
			base = sprites.turretBase,
			spawn = sprites.turretSpawn,
			attack = sprites.turretShoot,
			rotate = sprites.turretRotate,
			jump = sprites.turretBase,
			idle = sprites.turretBase,
		}

	end
	i.percent_hp = 1
	i.maxhp = i.maxhp_base * i.percent_hp
	i.state = "set up"
	inst.spriteSpeed = 0.2
	inst.y = FindGround(inst.x, inst.y) - ((sprites.turretSpawn.height / 2) + 2)
	i.head_active=0
	i.head_rotate=0
	i.head_sprite = inst:getAnimation("rotate").id
	i.head_spritespeed = 0
	i.head_subimage = 1
	i.head_scale = 1
	SetTurretSprite(inst, inst:getAnimation("spawn"))
	local poi = Object.find("POI", "vanilla"):create(inst.x, inst.y)
	poi:getAccessor().parent = inst.id
	i.exp_worth = 0
	i.health_tier_threshold = 0.01
	i.knockback_cap = 999999
	--i.target = -1
	i.pHmax = 0
	i.disable_ai = 1
	i.can_jump = 0
	i.can_drop = 0
	i.dot_immune=60
	i.weather_immune=60
	i.team="player"
	i.z_range = 700
	sounds.JanitorShoot1_1:play(1.2)
end

local InitMobileTurret = function(inst, level, super)
	local i = inst:getAccessor()
	local data = inst:getData()
	if not level then level = 1 end
	if super then
		i.maxhp_base = 320 + (50 * (level - 1))
		i.hp = 320 + (50 * (level - 1))
		i.hp_regen = 0.003 + (0.003 * (level - 1))
		i.armor = 30 + (2 * (level - 1))
		i.damage = 16 + (5 * (level - 1))
		i.attack_speed = i.attack_speed + 0.2
		inst:setAnimations{
			spawn = sprites.turretSpawn,
			attack = sprites.mobileShoot1,
			rotate = sprites.mobileRotate,
			jump = sprites.mobileBaseJump,
			idle = sprites.mobileBaseIdle,
		}
	else
		i.maxhp_base = 160 + (39 * (level - 1))
		i.hp = 160 + (39 * (level - 1))
		i.hp_regen = 0.002 + (0.0025 * (level - 1))
		i.armor = 30 + (2 * (level - 1))
		i.damage = 14 + (3 * (level - 1))
		inst:setAnimations{
			spawn = sprites.turretSpawn,
			attack = sprites.mobileShoot1,
			rotate = sprites.mobileRotate,
			jump = sprites.mobileBaseJump,
			idle = sprites.mobileBaseIdle,
		}

	end
	i.percent_hp = 1
	i.turret_beam = 0
	i.maxhp = i.maxhp_base * i.percent_hp
	i.state = "set up"
	inst.spriteSpeed = 0.2
	inst.y = FindGround(inst.x, inst.y) - ((sprites.turretSpawn.height / 2) + 2)
	i.head_active=0
	i.head_rotate=0
	i.head_sprite = inst:getAnimation("rotate").id
	i.head_spritespeed = 0
	i.head_subimage = 1
	i.head_scale = 1
	SetTurretSprite(inst, inst:getAnimation("spawn"))
	local poi = Object.find("POI", "vanilla"):create(inst.x, inst.y)
	poi:getAccessor().parent = inst.id
	i.exp_worth = 0
	i.health_tier_threshold = 0.01
	i.knockback_cap = 999999
	--i.target = -1
	i.pHmax = 1.3
	i.disable_ai = 1
	i.can_jump = 1
	i.can_drop = 1
	i.dot_immune=60
	i.weather_immune=60
	i.team="player"
	i.z_range = 100
	i.beam_x = 0
	i.beam_y = 0
	i.beam_length = 100
	sounds.JanitorShoot1_1:play(1.2)
end

local InheritItems = function(inst, player)
	GlobalItem.initActor(inst)
	for _, item in ipairs(Item.findAll("vanilla")) do
		GlobalItem.addItem(inst, item, player:countItem(item))
	end
	for _, mod in ipairs(modloader.getMods()) do
		for _, item in ipairs(Item.findAll(mod)) do
			GlobalItem.addItem(inst, item, player:countItem(item))
		end
	end
	if player.useItem then
		GlobalItem.addItem(inst, player.useItem, 1)
	else
		inst:getModData(GlobalItem.namespace).equipment = nil
	end
end

local StepTurret = function(inst)
	local i = inst:getAccessor()
	local data = inst:getData()
	local parent = data.parent
	if not parent then
		inst:destroy()
		return
	end
	if i.free == 1 then
		inst.y = FindGround(inst.x, inst.y)- ((inst.sprite.height / 2) + 2)
		i.y = inst.y
	end
	inst.xscale = 1
	i.maxhp = i.maxhp_base * i.percent_hp
	i.disable_ai = 1
	i.moveLeft = 0
	i.moveRight = 0
	i.moveUp = 0
	i.knockback_value = 0
	if i.hp > i.maxhp then
		i.hp = i.maxhp
	end
	if i.hp_regen and i.hp < i.maxhp then
		i.hp = i.hp + i.hp_regen
	end
	local head_sprite = Sprite.fromID(i.head_sprite)
	if i.state == "set up" then
		if math.floor(inst.subimage) >= sprites.turretSpawn.frames - 1 then
			SetTurretSprite(inst, inst:getAnimation("base"))
			inst.spriteSpeed = 0
			i.head_active = 1
			i.state = "idle"
			return
		end
	elseif i.state == "idle" then
		local target = enemies:findLine(inst.x - i.z_range, inst.y, inst.x + i.z_range, inst.y)
		if target and target:isValid() and target:get("team") ~= i.team then
			i.target = target.id
		end
		if Object.findInstance(i.target) then
			i.state = "chase"
			return
		end
		if math.random() * 100 < 0.3 then
			i.state = "head rotate"
			return
		end
	elseif i.state == "chase" then
		local target = Object.findInstance(i.target)
		if target and target:isValid() and not GroundBetween(inst.x, inst.y, target.x, target.y) then
			local shouldBeFacing = 1
			if target.x < inst.x then
				shouldBeFacing = -1
			end
			if i.head_scale ~= shouldBeFacing then
				i.state = "head rotate"
				return
			end
			if Distance(inst.x, inst.y, target.x, target.y) < i.z_range and inst:getAlarm(1) < 0 then
				i.state = "firing1"
				return
			end
		else
			i.state = "idle"
			return
		end

	elseif i.state == "firing1" then
		if head_sprite ~= inst:getAnimation("attack") then
			i.head_sprite = inst:getAnimation("attack").id
			i.head_subimage = 0
			i.activity = 1
			i.head_spritespeed = 0.25 * inst:get("attack_speed")
		else
			if math.floor(i.head_subimage) == 1 and inst:getAlarm(1) == -1 then
				sounds.Bullet3:play(1.5)
				inst:fireBullet(inst.x, inst.y, 90 - (90 * i.head_scale), i.z_range, 1, sprites.sparks1, nil)
				inst:setAlarm(1, 30 / inst:get("attack_speed"))
			elseif math.floor(i.head_subimage) >= inst:getAnimation("attack").frames then
				i.head_subimage = 1
				i.activity = 0
				i.head_spritespeed = 0
				i.head_sprite = inst:getAnimation("rotate").id
				i.state = "chase"
				return
			end
		end
	elseif i.state == "head rotate" then
		if i.head_rotate == 0 then
			i.head_sprite = inst:getAnimation("rotate").id
			i.head_spritespeed = 0.28
			sounds.JanitorShoot1_1:play(1.5)
			i.head_rotate = 1
			i.head_subimage = 1
		elseif i.head_rotate == 1 then
			if i.head_subimage >= head_sprite.frames - 1 then
				i.head_scale = -i.head_scale
				i.head_subimage = 1
				i.head_spritespeed = 0
				i.state = "idle"
				i.head_rotate = 0
			end
		end
	else
		i.state = "idle"
		return
	end
end

local StepMobileTurret = function(inst)
	local i = inst:getAccessor()
	local data = inst:getData()
	local parent = data.parent
	if not parent then
		inst:destroy()
		return
	end
	i.maxhp = i.maxhp_base * i.percent_hp
	i.knockback_value = 0
	if i.hp > i.maxhp then
		i.hp = i.maxhp
	end
	if i.hp_regen and i.hp < i.maxhp then
		i.hp = i.hp + i.hp_regen
	end
	local head_sprite = Sprite.fromID(i.head_sprite)
	local target = Object.findInstance(i.target)
	if target then
		if i.turret_beam > -1 then
			if Distance(target.x, target.y, inst.x, inst.y) > i.z_range * 0.8 then
				if target.x < inst.x then
					i.moveLeft = 1
					i.moveRight = 0
				else
					i.moveLeft = 0
					i.moveRight = 1
				end
			elseif Distance(target.x, target.y, inst.x, inst.y) < i.z_range * 0.4 then
				if target.x < inst.x then
					i.moveLeft = 0
					i.moveRight = 1
				else
					i.moveLeft = 1
					i.moveRight = 0
				end
			end
		end
		local zz = i.beam_length
		for u = 0, zz do
			local angle = GetAngleTowardsRad(target.x, target.y - (target.sprite.height/2), inst.x, inst.y - 16)
			i.beam_x = inst.x + ((math.cos(angle) * zz) * (u / zz))
			i.beam_y = inst.y + ((math.sin(angle) * zz) * (u / zz))
			if Stage.collidesPoint(i.beam_x,i.beam_y) or target:getObject():findLine(inst.x, inst.y,i.beam_x,i.beam_y) then
				break
			end
		end
	else
		i.turret_beam = -1
		i.beam_x = inst.x + (i.beam_length * i.head_scale)
		i.beam_y = inst.y
	end
	if i.state == "set up" then
		i.disable_ai = 1
		i.moveLeft = 0
		i.moveRight = 0
		i.moveUp = 0
		if math.floor(inst.subimage) >= sprites.turretSpawn.frames - 1 then
			inst:setAnimations{
				idle = sprites.mobileBaseIdle,
				walk = sprites.mobileBaseWalk,
				jump = sprites.mobileBaseJump,
				death = sprites.mobileBaseIdle
			}
			i.head_active = 1
			i.state = "idle"
			i.disable_ai = 0
			return
		end
	elseif i.state == "idle" then
		local target = enemies:findLine(inst.x - i.z_range, inst.y, inst.x + i.z_range, inst.y)
		if target and target:isValid() and target:get("team") ~= i.team then
			i.target = target.id
		end
		if not target and Distance(parent.x, parent.y, inst.x, inst.y) > 50 then
			i.target = parent.id
		end
		if Object.findInstance(i.target) then
			i.state = "chase"
			return
		end
		if math.random() * 100 < 0.3 then
			i.state = "head rotate"
			return
		end
	elseif i.state == "chase" then
		local target = Object.findInstance(i.target)
		if target and target:isValid() and not GroundBetween(inst.x, inst.y, target.x, target.y) then
			local shouldBeFacing = -1
			if target.x < inst.x then
				shouldBeFacing = 1
			end
			if i.head_scale ~= shouldBeFacing then
				i.state = "head rotate"
				return
			end
			---------------------------------------------------------------------------------
			if target:get("team") ~= i.team then
				if Distance(inst.x, inst.y, target.x, target.y) < i.z_range / 4 and inst:getAlarm(1) < 0 then
					i.state = "firing1"
					if i.turret_beam == -1 then
						i.turret_beam = 8*60
					end
					return
				end
			end
		else
			i.state = "idle"
			return
		end

	elseif i.state == "firing1" then
		if head_sprite ~= inst:getAnimation("attack") then
			i.head_sprite = inst:getAnimation("attack").id
			i.head_subimage = 1
			i.activity = 1
			i.head_spritespeed = 0.25 * inst:get("attack_speed")
		else
			if target and target:isValid() then
				local shouldBeFacing = -1
				if target.x < inst.x then
					shouldBeFacing = 1
				end
				if i.head_scale ~= shouldBeFacing then
					i.state = "head rotate"
					return
				end
			end
			if i.turret_beam > -1 and (target and target:isValid()) then
				i.turret_beam = i.turret_beam - inst:get("attack_speed")
				if math.ceil(i.turret_beam) % 10 == 0 then
					particles.sparks:burst("above", i.beam_x, i.beam_y, 1)
					local tick = inst:fireBullet(inst.x - (7 * i.head_scale), inst.y - 12, GetAngleTowards(target.x, target.y - (target.sprite.height/2), inst.x, inst.y - 16), i.beam_length, 0.3, sprites.sparks1, nil)
					tick:set("slow_on_hit", tick:get("slow_on_hit") + 1)
				end
				return
			else
				i.turret_beam = -1
				i.head_subimage = 1
				i.activity = 0
				i.head_spritespeed = 0
				inst:setAlarm(1, 2*60 / inst:get("attack_speed"))
				i.head_sprite = inst:getAnimation("rotate").id
				i.state = "chase"
				return
			end
		end
	elseif i.state == "head rotate" then
		if i.head_rotate == 0 then
			i.head_sprite = inst:getAnimation("rotate").id
			i.head_spritespeed = 0.28
			sounds.JanitorShoot1_1:play(1.5)
			i.head_rotate = 1
			i.head_subimage = 1
		elseif i.head_rotate == 1 then
			if i.head_subimage >= head_sprite.frames - 1 then
				i.head_scale = -i.head_scale
				i.head_subimage = 1
				i.head_spritespeed = 0
				i.state = "idle"
				i.head_rotate = 0
			end
		end
	else
		i.state = "idle"
		return
	end
end

local DrawTurret = function(inst)
	local i = inst:getAccessor()
	local data = inst:getData()
	if i.head_active > 0 then
		local sprite = Sprite.fromID(i.head_sprite)
		if sprite then
			i.head_subimage = i.head_subimage + i.head_spritespeed
			if math.floor(i.head_subimage) > sprite.frames then i.head_subimage = 1 end
			graphics.drawImage{
				image = sprite,
				subimage = i.head_subimage,
				x = inst.x,
				y = inst.y,
				xscale = i.head_scale,
				alpha = inst.alpha,
			}
		end
		local target = Object.findInstance(i.target)
		if i.turret_beam and i.turret_beam > -1 and (target and target:isValid()) and i.state == "firing1" then
			graphics.alpha(0.5)
			local xx = math.random(-3, 3)
			local yy = math.random(-3, 3)
			graphics.color(Color.fromRGB(103, 173, 56))
			graphics.line(inst.x - (7 * i.head_scale), inst.y - 12, i.beam_x + xx, i.beam_y + yy, 2 + math.random())
			graphics.color(Color.WHITE)
			graphics.line(inst.x - (7 * i.head_scale), inst.y - 12, i.beam_x + xx, i.beam_y + yy, 1)
		end
	end
end

local DestroyTurret = function(inst)
	misc.shakeScreen(5)
	local obj = objects.sparks:create(inst.x, inst.y)
	obj.sprite = sprites.grenadeExplosion
	sounds.DroneDeath:play(1.5)
end

turret:addCallback("step", function(self)
	StepTurret(self)
end)
turret:addCallback("draw", function(self)
	DrawTurret(self)
end)
turret:addCallback("destroy", function(self)
	DestroyTurret(self)
end)

mobileTurret:addCallback("step", function(self)
	StepMobileTurret(self)
end)
mobileTurret:addCallback("draw", function(self)
	DrawTurret(self)
end)
mobileTurret:addCallback("destroy", function(self)
	DestroyTurret(self)
end)

-------------
--Callbacks--
-------------

local GrenadeStep = function(player)
	local p = player:getAccessor()
	if p.grenade_phase then
		if p.activity == 0 and player:getAlarm(2) == -1 then
			if p.grenade_phase == 0 and input.checkControl("ability1", player) == input.HELD then
				p.grenade_phase = 1
			elseif p.grenade_phase == 1 and input.checkControl("ability1", player) ~= input.HELD then
				p.grenade_phase = 2
			end
			if p.grenade_count >= maxNades then
				p.grenade_phase = 2
			end
			ChargeGrenade(player)
		end
	end
end

callback.register("postStep", function()
	for _, player in ipairs(misc.players) do
		GrenadeStep(player)
		if player:getData().mines then
			StepMines(player)
		end
		if player:getData().turrets then
			StepTurrets(player)
		end
	end
end)

------------
-- Skills --
------------

local function initActivity(player, index, sprite, speed, scaleSpeed, resetHSpeed)
	if player:get("activity") == 0 then
		player:survivorActivityState(index, sprite, speed, scaleSpeed, resetHSpeed)
		player:activateSkillCooldown(index)
		return true
	end
	return false
end

-- Bouncing Grenades

local trinade = Skill.new()

trinade.displayName = "Bouncing Grenades"
trinade.description = "Charge up to 8 grenades that deal 100% damage each."
trinade.icon = sprites.icons
trinade.iconIndex = 1
trinade.cooldown = 50



-- Bounding Mine

local boundingMine = Skill.new()

boundingMine.displayName = "Bounding Mine"
boundingMine.description = "Drop a trap that explodes for 300% damage. Hold up to 15."
boundingMine.icon = sprites.icons
boundingMine.iconIndex = 2
boundingMine.cooldown = 3 * 60

boundingMine:setEvent("init", function(player, index)
	if player:get("activity") == 0 then
		local inst = mine:create(player.x, player.y)
		inst:getData().parent = player
		table.insert(player:getData().mines, inst)
		player:activateSkillCooldown(index)
		return true
	end
	return false
end)

-- Pressure Mine

local pressureMine = Skill.new()

pressureMine.displayName = "Pressure Mines"
pressureMine.description = "Place a two-stage mine that deals 300% damage when an enemy walks nearby, or 900% damage if allowed to fully arm. Can place up to 4."
pressureMine.icon = sprites.icons
pressureMine.iconIndex = 3
pressureMine.cooldown = 8 * 60

pressureMine:setEvent("init", function(player, index)
	if player:get("activity") == 0 then
		local inst = mineArm:create(player.x, player.y)
		inst:getData().parent = player
		table.insert(player:getData().mines, inst)
		player:activateSkillCooldown(index)
		return true
	end
	return false
end)

-- Spider Mine

local spiderMine = Skill.new()

spiderMine.displayName = "Spider Mines"
spiderMine.description = "Place a robot mine that deals 600% damage when an enemy walks nearby. Can place up to 4."
spiderMine.icon = sprites.icons
spiderMine.iconIndex = 4
spiderMine.cooldown = 8 * 60



-- Thermal Harpoons

local harpoons = Skill.new()

harpoons.displayName = "Thermal Harpoons"
harpoons.description = "Launch four heat-seeking harpoons for 4x250% damage."
harpoons.icon = sprites.icons
harpoons.iconIndex = 5
harpoons.cooldown = 4 * 60

harpoons:setEvent("init", function(player, index)
	if initActivity(player, index, player:getAnimation("shoot3"), 0.25, true, true) then
		player:setAlarm(index + 1, harpoons.cooldown)
		return true
	end
	return false
end)

local FireHarpoon = function(player, frame)
	sounds.MissileLaunch:play(0.6 + math.random() * 0.1)
	misc.shakeScreen(5)
	for i = 0, player:get("sp") do
		local inst = harpoon:create(player.x + (-(player:getAnimation("shoot3").width + 4)+(3*frame) - (6*i)) * player.xscale, player.y-4)
		inst.xscale = player.xscale
		inst:getData().parent = player
	end
end

for i = 0, 3 do
	harpoons:setEvent(5 + (i*3), function(player)
		FireHarpoon(player, (5+i*3))
	end)
end

-- Bubble Shield

local shield = Skill.new()

shield.displayName = "Bubble Shield"
shield.description = "Place an impenetrable shield that blocks all incoming damage."
shield.icon = sprites.icons
shield.iconIndex = 6
shield.cooldown = 10 * 60

-- Auto-Turret

local placeTurret = Skill.new()

placeTurret.displayName = "TR-55 Gauss Auto-Turret"
placeTurret.description = "Drop a turret that inherits all your items. Fires a cannon for 100% damage. Can hold up to 2."
placeTurret.icon = sprites.icons
placeTurret.iconIndex = 7
placeTurret.cooldown = 5 * 60

placeTurret:setEvent("init", function(player, index)
	if player:get("activity") == 0 then
		local inst = turret:create(player.x, player.y)
		InitTurret(inst, player:get("level"), false)
		inst:getData().parent = player
		table.insert(player:getData().turrets, inst)
		InheritItems(inst, player)
		player:activateSkillCooldown(index)
		return true
	end
	return false
end)


-- Mobile Turret

local placeMobileTurret = Skill.new()

placeMobileTurret.displayName = "TR-58 Carbonizer Turret"
placeMobileTurret.description = "Place a mobile turret that inherits all your items. Fires a laser for 200% damage per second that slows enemies. Can place up to 2."
placeMobileTurret.icon = sprites.icons
placeMobileTurret.iconIndex = 8
placeMobileTurret.cooldown = 5 * 60

placeMobileTurret:setEvent("init", function(player, index)
	if player:get("activity") == 0 then
		local inst = mobileTurret:create(player.x, player.y)
		InitMobileTurret(inst, player:get("level"), false)
		inst:getData().parent = player
		table.insert(player:getData().turrets, inst)
		InheritItems(inst, player)
		player:activateSkillCooldown(index)
		return true
	end
	return false
end)



-- Super Auto-Turret

local placeSuperTurret = Skill.new()

placeSuperTurret.displayName = "TR-55 Gauss Auto-Turret Mk. 2"
placeSuperTurret.description = "Drop a turret that shoots for 3x100% damage for 30 seconds. Hold up to 2."
placeSuperTurret.icon = sprites.icons
placeSuperTurret.iconIndex = 9
placeSuperTurret.cooldown = 5 * 60

placeSuperTurret:setEvent("init", function(player, index)
	if player:get("activity") == 0 then
		local inst = turret:create(player.x, player.y)
		InitTurret(inst, player:get("level"), true)
		inst:getData().parent = player
		table.insert(player:getData().turrets, inst)
		InheritItems(inst, player)
		player:activateSkillCooldown(index)
		return true
	end
	return false
end)


--------------
--  Skins   --
--------------

local s_default = Skill.new()

s_default.displayName = "Default"
s_default.description = ""
s_default.icon = sprites.palettes
s_default.iconIndex = 1
s_default.cooldown = -1

local defaultSprites = {
	["loadout"] = sprites.loadout,
	["idle"] = baseSprites.idle,
	["walk"] = baseSprites.walk,
	["jump"] = baseSprites.jump,
	["climb"] = baseSprites.climb,
	["death"] = baseSprites.death,
	["shoot1"] = sprites.shoot1,
    ["shoot3"] = sprites.shoot3,
    ["turretBase"] = sprites.turretBase,
    ["turretRotate"] = sprites.turretRotate,
    ["turretShoot"] = sprites.turretShoot,
    ["turretSpawn"] = sprites.turretSpawn,
    ["superTurretBase"] = sprites.superTurretBase,
    ["superTurretRotate"] = sprites.superTurretRotate,
    ["superTurretShoot"] = sprites.superTurretShoot,
    ["superTurretSpawn"] = sprites.superTurretSpawn,
}

--------------
-- Survivor --
--------------

local engi = Survivor.new("Engineer 2.0")
local vanilla = Survivor.find("Engineer")

local loadout = Loadout.new()
loadout.survivor = engi
loadout.description = [[The &y&Engineer&!& relies on &y&proper placement&!& of &y&Mines and Turrets&!&.
Use &y&Tri-nade&!& and &y&Thermal Harpoons&!& to hit enemies from safe areas.
Always place all your mines and turrets before activating the teleporter!]]

loadout:addSkill("Primary", trinade, {
	loadoutDescription = [[Charge up to &y&8&!& grenades that deal &y&100% damage&!& each.]]
})
loadout:addSkill("Secondary", boundingMine, {
	loadoutDescription = [[Drop a trap that explodes for &y&300% damage&!&. &b&Hold up to 15&!&.]],
	apply = function(player)
		player:getData().mines = {}
		Ability.AddCharge(player, "x", 14, false)
		Ability.setCharge(player, "x", 7)
		player:set("x_stop", 30)
	end,
	remove = function(player, hardRemove)
		Ability.Disable(player, "x")
		player:set("x_stop", -1)
	end,
})
loadout:addSkill("Secondary", pressureMine, {
	loadoutDescription = [[Place a two-stage mine that deals &y&300% damage&!& when an enemy walks nearby,
or &y&900% damage if allowed to fully arm.&!& &b&Can place up to 4&!&.]],
	apply = function(player)
		player:getData().mines = {}
		Ability.AddCharge(player, "x", 3, true)
		player:set("x_stop", 30)
	end,
	remove = function(player, hardRemove)
		Ability.Disable(player, "x")
		player:set("x_stop", -1)
	end,
})
loadout:addSkill("Secondary", spiderMine, {
	loadoutDescription = [[Place a robot mine that deals &y&600% damage&!& when an enemy walks nearby. 
&b&Can place up to 4&!&.]],
apply = function(player)
	player:getData().mines = {}
	Ability.AddCharge(player, "x", 3, true)
	player:set("x_stop", 30)
end,
remove = function(player, hardRemove)
	Ability.Disable(player, "x")
	player:set("x_stop", -1)
end,
locked = true,
})
loadout:addSkill("Utility", harpoons,{
	loadoutDescription = [[Launch four &y&heat-seeking harpoons&!& for &y&4x250% damage&!&.]]
})
loadout:addSkill("Utility", shield, {
	loadoutDescription = [[Place an &b&impenetrable shield&!& that blocks all incoming damage.]],
	locked = true,
})
loadout:addSkill("Special", placeTurret,{
	loadoutDescription = [[Drop a turret that &b&inherits all your items&!&. Fires a cannon 
for &y&100% damage&!&. Can hold up to 2.]],
apply = function(player)
	player:getData().turrets = {}
	Ability.AddCharge(player, "v", 1, true)
	player:set("v_stop", 30)
end,
upgrade = loadout:addSkill("Special", placeSuperTurret, {hidden = true}),
remove = function(player, hardRemove)
	Ability.Disable(player, "v")
	player:set("v_stop", -1)
end,
}) 
loadout:addSkill("Special", placeMobileTurret, {
	loadoutDescription = [[Place a mobile turret that &b&inherits all your items&!&. Fires a laser 
for &y&200% damage per second&!& that slows enemies. Can place up to 2.]],
apply = function(player)
	player:getData().turrets = {}
	Ability.AddCharge(player, "v", 1, true)
	player:set("v_stop", 30)
end,
remove = function(player, hardRemove)
	Ability.Disable(player, "v")
	player:set("v_stop", -1)
end,
locked = true,
})
loadout:addSkin(s_default, defaultSprites)


engi.titleSprite = baseSprites.walk
engi.loadoutColor = Color.fromRGB(141, 115, 166)
engi.loadoutSprite = sprites.loadout
engi.endingQuote = "..and so he left, more steel and circuit than man."

engi:addCallback("init", function(player)
	local p = player:getAccessor()
	player:setAnimations(baseSprites)
	player:survivorSetInitialStats(120, 12, 0.015)
	p.grenade_phase = 0
	p.grenade_charge = -1
	p.grenade_count = 0
end)

engi:addCallback("levelUp", function(player)
	player:survivorLevelUpStats(34, 3, 0.003, 2)
end)

engi:addCallback("scepter", function(player)
    Loadout.Upgrade(loadout, player, "Special")
end)

Loadout.RegisterSurvivorID(engi)

return engi
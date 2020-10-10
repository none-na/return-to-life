--require("Misc.loadout")
--require("Libraries.skill.main")

---------------
-- Resources --
---------------

local baseSprites = {
	idle = Sprite.find("Huntress1Idle", "vanilla"),
	walk = Sprite.find("Huntress1Walk", "vanilla"),
	jump = Sprite.find("Huntress1Jump", "vanilla"),
	climb = Sprite.find("Huntress1Climb", "vanilla"),
	death = Sprite.find("Huntress1Death", "vanilla"),
}

local sprites = {
	idle = Sprite.find("Huntress1IdleHalf", "vanilla"),
	walk = Sprite.find("Huntress1WalkHalf", "vanilla"),
	jump = Sprite.find("Huntress1JumpHalf", "vanilla"),
	shoot1 = Sprite.find("Huntress1Shoot1", "vanilla"),
	shoot2 = Sprite.find("Huntress1Shoot2", "vanilla"),
	shoot3 = Sprite.find("Huntress1Shoot3", "vanilla"),
	shoot4 = Sprite.find("Huntress1Shoot4", "vanilla"),
	shoot4b_1 = Sprite.load("HuntressShoot4b_1", "Actors/huntress/shoot4b_1", 2, 7, 6),
	shoot5 = Sprite.find("Huntress1Shoot5", "vanilla"),
	palettes = Sprite.load("HuntressPalettes", "Actors/huntress/palettes", 2, 0, 0),
	mine1exp = Sprite.find("HuntressMine1Explosion", "vanilla"),
	mine2exp = Sprite.find("HuntressMine2Explosion", "vanilla"),
	bolt2exp = Sprite.find("HuntressBolt2Explosion", "vanilla"),
	arrowRain = Sprite.load("HuntressArrow", "Actors/huntress/arrow", 6, 3.5, 63),
	bolt3 = Sprite.find("HuntressBolt3", "vanilla"),
	icons = Sprite.load("HuntressSkills", "Actors/huntress/skills", 8, 0, 0),
	loadout = Sprite.find("SelectHuntress", "vanilla"),
	sparks1 = Sprite.find("Sparks1", "vanilla"),
	sparks2 = Sprite.find("Sparks2", "vanilla")
}

local sounds = {
	shoot1 = Sound.find("HuntressShoot1", "vanilla"),
	shoot3 = Sound.find("HuntressShoot3", "vanilla"),
	reflect = Sound.find("Reflect", "vanilla"),
	explosion = Sound.find("ExplosiveShot", "vanilla"),
	arrowRain = Sound.load("ArrowRainLoop", "Sounds/SFX/huntress/arrowRain.ogg"),
}

callback.register("onGameEnd", function()
	sounds.arrowRain:stop()
end)

local objects = {
	efSparks = Object.find("EfSparks", "vanilla"),
}

local particles = {
	bolt = ParticleType.find("HuntressBolt1", "vanilla"),
	glaive = ParticleType.find("HuntressBolt2", "vanilla"),
}

local enemies = ParentObject.find("enemies", "vanilla")

-----------------
-- Projectiles --
-----------------

-- Bolt

local boltProj = Object()
boltProj.sprite = Sprite.find("HuntressBolt1", "vanilla")

boltProj:addCallback("create", function(self)
	self.spriteSpeed = 0.3
	self:set("speed", 9)
	self:set("damage", 1.2)
	self:set("life", 60 * 2)
	self:set("team", "playerproc")
end)

local function boltStep(self)
	-- Visual
	if misc.getOption("video.quality") > 1 then
		particles.bolt:angle(0, 0, 0, 0, false)
		particles.bolt:burst("below", self.x, self.y, 1)
	end
	
	-- Cleanup
	local player = Object.findInstance(self:get("parent"))
	if not player or not player:isValid() or self:collidesMap(self.x, self.y) or self:get("life") <= 0 or util.outsideRoom(self) then
		self:destroy()
		return
	end
	self.angle = self:get("direction")
	
	-- Collision
	local team = player:get("team")
	local enemy = util.collidesEnemy(self, self.x, self.y, team)
	if enemy then
		local facing = math.sign(enemy.x - self:get("xprevious"))
		local bullet = player:fireBullet(self.x - facing * 9, enemy.y, 90 - 90 * facing, 18, self:get("damage"), sprites.sparks1)
		bullet:set("specific_target", enemy.id)
		bullet:set("climb", self:get("climb") or 0)
		self:destroy()
	end
end

-- Glaive

local glaiveProj = Object.find("HuntressBoomerang", "vanilla")--Object()
--[[glaiveProj.sprite = Sprite.find("HuntressBoomerang", "vanilla")
local targets_hit = {}

glaiveProj:addCallback("create", function(self)
	self:set("speed", 8)
	self:set("target", -1)
	self:set("yoff", 0)
	self:set("damage", 3)
	self:set("active", 1)
	self:set("hit_count", 0)
	self:set("charges", 4)
	self:set("damage_coeff", 0)
	self:set("team", "playerproc")
	targets_hit[self] = {}
end)

local function glaiveStep(self)
	local s = self:getAccessor()
	-- Visual
	if misc.getOption("video.quality") >= 2 then
		particles.glaive:angle(self.angle, self.angle, 0, 0, false)
		particles.glaive:burst("above", self.x, self.y, 1)
	end
	self.angle = self.angle + 30
	
	-- Cleanup
	local player = Object.findInstance(s.parent)
	if not player or not player:isValid() or util.outsideRoom(self) then
		self:destroy()
		return
	end
	
	if s.active == 1 then
		-- Steer
		local target = Object.findInstance(s.target)
		if s.hit_count > 0 and target and target:isValid() then
			local mx, my = input.getMousePos(false)
			s.direction = util.pointDirection(self.x, self.y, target.x, target.y)
		end
	
		-- Collision
		local team = player:get("team")
		local allEnemies = enemies:findMatchingOp("team", "~=", team)
		local hit = false
		for _, enemy in ipairs(allEnemies) do
			if enemy:get("team") ~= team and not targets_hit[self][enemy] and self:collidesWith(enemy, self.x, self.y) then
				targets_hit[self][enemy] = true
				hit = true
				s.hit_count = s.hit_count + 1
				local facing = math.sign(enemy.x - self:get("xprevious"))
				local bullet = player:fireBullet(self.x - facing * 9, enemy.y, 90 - 90 * facing, 18, s.damage, sprites.sparks1)
				bullet:set("specific_target", enemy.id)
				bullet:set("climb", s.climb)
				
				if s.hit_count >= s.charges then
					self:destroy()
					return
				end
				s.speed = s.speed + 1
				s.yoff = -4 + math.random() * 8
				s.direction = s.direction - 20 + math.random() * 40
				s.active = 0
				sounds.reflect:play(0.8 + 0.1 * math.random(), 0.7)
				break
			end
		end
		
		-- Find new target
		if hit then
			local mindist, closest = nil, nil
			for _, enemy in ipairs(allEnemies) do
				if not targets_hit[self][enemy] then
					local dist = util.distance(self.x, self.y, enemy.x, enemy.y)
					if dist < 200 and (not mindist or dist < mindist) then
						mindist = dist
						closest = enemy
					end
				end
			end
			s.target = closest and closest.id or -5
		end
	else
		s.active = 1
	end
end

glaiveProj:addCallback("destroy", function(self)
	targets_hit[self] = nil
end)]]

-- Grenade

local grenade = Object()
grenade.sprite = Sprite.find("HuntressMine1", "vanilla")

grenade:addCallback("create", function(self)
	self.subimage = math.random(8)
	self.angle = math.random() * 360
	self.spriteSpeed = 0.3
	self:set("direction", 45 + math.random() * 90)
	self:set("speed", 1 + math.random() * 2)
	self:set("gravity", 0.15)
	self:set("scepter", 0)
	self:set("damage", 0.8)
	self:set("team", "playerproc")
end)

local function grenadeStep(self)
	self.angle = self.angle + 3
	
	local player = Object.findInstance(self:get("parent"))
	if not player or not player:isValid() or util.outsideRoom(self) then
		self:destroy()
		return
	end
	
	if self:collidesMap(self.x, self.y) then 
		-- util.moveDown(self, 5)
		local sc = self:get("scepter")
		local dmg = self:get("damage") + (sc ~= 0 and 0.05 * (sc - 1) or 0)
		local spr = sc == 0 and sprites.mine1exp or sprites.mine2exp
		local bull = player:fireExplosion(self.x, self.y + 2, 0.8, 1.3, dmg, spr, nil, DAMAGER_NO_PROC)
		bull:set("team", "playerproc")
		sounds.explosion:play(1.3 + math.random() * 0.15)
		self:destroy()
	end
end

-- Cluster

local clusterProj = Object()
clusterProj.sprite = Sprite.find("HuntressBolt2", "vanilla")

clusterProj:addCallback("create", function(self)
	self.spriteSpeed = 0.3
	self:set("speed", 15)
	
	self:set("scepter", 0)
	self:set("damage", 3.2)
	self:set("team", "playerproc")
end)

local function detonateCluster(self, player, x, y)
	local dmg = self:get("damage")
	local spr = sprites.bolt2exp
	player:fireExplosion(x, y, 3, 3, dmg, spr)
	local sc = self:get("scepter")
	for i = 1, sc == 0 and 6 or 12 do
		local inst = grenade:create(x, y)
		inst:set("parent", self:get("parent"))
		if sc ~= 0 then
			inst.blendColor = Color.RED
			inst:set("scepter", sc)
		end
	end
	self:destroy()
end

local function clusterStep(self)
	-- Visual
	particles.bolt:burst("below", self.x, self.y, 1)
	
	-- Cleanup
	local player = Object.findInstance(self:get("parent"))
	if not player or not player:isValid() or util.outsideRoom(self) then
		self:destroy()
		return
	end
	self.angle = self:get("direction")
	
	-- Collision
	if self:collidesMap(self.x, self.y) then
		detonateCluster(self, player, self.x, self.y)
		return
	end
	
	local team = player:get("team")
	local enemy = util.collidesEnemy(self, self.x, self.y, team)
	if enemy then
		detonateCluster(self, player, enemy.x, enemy.y)
	end
end

-- Rockeye is the same with a different sprite

-- Arrow Rain

local arrowRainRadius = 50

local arrow = Object.new("HuntressArrowRain")
arrow.sprite = sprites.arrowRain

arrow:addCallback("create", function(self)
	local data = self:getData()
	self.spriteSpeed = 0.25
	data.damage = 12
	data.team = "player"
	data.parent = nil
	self.y = FindGround(self.x, self.y)
	if math.random() < 0.5 then
		self.xscale = -1
	end
end)
arrow:addCallback("step", function(self)
	local data = self:getData()
	if math.floor(self.subimage) == self.sprite.frames then
		self:destroy()
	end
end)
local arrowbox = Object.new("HuntressArrowBox")


arrowbox:addCallback("create", function(self)
	local data = self:getData()
	self.spriteSpeed = 0.25
	data.life = 6*60
	sounds.arrowRain:loop()
	data.team = "player"
	data.parent = nil
	if math.random() < 0.5 then
		self.xscale = -1
	end
end)

arrowbox:addCallback("step", function(self)
	local data = self:getData()
	data.life = data.life - 1
	if data.life % 5 == 0 then
		local exp = nil
		if data.parent then
			exp = data.parent:fireExplosion(self.x, self.y, arrowRainRadius/19, 1, 0.8, nil, nil)
		else
			exp = misc.fireExplosion(self.x, self.y, arrowRainRadius/19, 1, 1.1 * data.damage, data.team, nil, nil)
		end
		exp:set("slow_on_hit", 5)
		local x = self.x + math.random(-arrowRainRadius, arrowRainRadius)
		local y = self.y - arrowRainRadius
		local aInst = arrow:create(x, y)
		aInst.angle = self.angle
		aInst:getData().parent = data.parent
		aInst:getData().team = data.team
	end
	if data.life <= 0 then
		self:destroy()
	end
end)
arrowbox:addCallback("destroy", function(self)
	sounds.arrowRain:stop()
end)


arrowbox:addCallback("draw", function(self)
	local data = self:getData()
	graphics.alpha(0.5)
	graphics.color(Color.fromRGB(182, 230, 245))
	graphics.circle(self.x, self.y, arrowRainRadius, true)
end)


local arrowReach = 300

local ballistaSmoke = ParticleType.new("HuntressBallista")
ballistaSmoke:shape("Square")
ballistaSmoke:color(Color.fromRGB(182, 230, 245))
ballistaSmoke:alpha(0.5)
ballistaSmoke:additive(true)
ballistaSmoke:scale(0.05, 0.07)
ballistaSmoke:size(0.9, 1, -0.05, 0.0025)
ballistaSmoke:angle(0, 360, 1, 0.5, true)
ballistaSmoke:life(60, 85)
ballistaSmoke:direction(0, 360, 0, 0)
ballistaSmoke:speed(1, 1, -0.01, 0)

local HuntressUltStep = function(player, index)
	local p = player:getAccessor()
	if p.ult_phase then
		if p.ult_timer > -1 then
			p.ult_timer = p.ult_timer - 1
		end
		if p.ult_phase == 1 then
			if input.checkControl("ability4", player) == input.HELD then
				if p.activity ~= 4 then
					p.activity = 4
				end
				player.sprite = player:getAnimation("shoot4b_1")
				if input.checkControl("left", player) == input.HELD then
					p.ult_angle = p.ult_angle - 0.05
				elseif input.checkControl("right", player) == input.HELD then
					p.ult_angle = p.ult_angle + 0.05
				end
				if p.ult_angle > 90 and p.ult_angle < 270 then
					player.xscale = -1
				else
					player.xscale = 1
				end
				local angle = p.ult_angle
				for i = 0, arrowReach do
					local xx = math.cos(angle) * i
					local yy = math.sin(angle) * i
					if Stage.collidesPoint(player.x + xx, player.y + yy) then
						p.ult_target_x = player.x + xx
						p.ult_target_y = player.y + yy
						break
					end
				end
				if p.ult_x and p.ult_y then
					player.x = p.ult_x
					player.y = p.ult_y
					p.ghost_x = p.ult_x
					p.ghost_y = p.ult_y
				end
			elseif input.checkControl("ability4", player) == input.RELEASED then
				local box = arrowbox:create(p.ult_target_x, p.ult_target_y)
				box:getData().parent = player
				player:activateSkillCooldown(index)
				p.activity = 0
				p.pHspeed = -p.pHmax
				p.pVspeed = 0
				p.ghost_x = player.x
				p.ghost_y = player.y
				p.ult_phase = 0
			end
		elseif p.ult_phase == 2 then
			if p.ult_charges > 0 then
				if p.ballistaCD > -1 then
					p.ballistaCD = p.ballistaCD - 1
				end
				if p.activity ~= 4 then
					p.activity = 4
				end
				player.sprite = player:getAnimation("shoot1")
				if p.ult_angle > 90 and p.ult_angle < 270 then
					player.xscale = -1
				else
					player.xscale = 1
				end
				if input.checkControl("left", player) == input.HELD then
					p.ult_angle = p.ult_angle - 0.05
				elseif input.checkControl("right", player) == input.HELD then
					p.ult_angle = p.ult_angle + 0.05
				end
				local angle = p.ult_angle
				for i = 0, arrowReach do
					local xx = math.cos(angle) * i
					local yy = math.sin(angle) * i
					p.ult_target_x = player.x + xx
					p.ult_target_y = player.y + yy
					if Stage.collidesPoint(player.x + xx, player.y + yy) then
						p.ult_target_x = player.x + xx
						p.ult_target_y = player.y + yy
						break
					end
				end
				if p.ult_x and p.ult_y then
					player.x = p.ult_x
					player.y = p.ult_y
					p.ghost_x = p.ult_x
					p.ghost_y = p.ult_y
				end
				if p.ballistaCD <= -1 and (input.checkControl("ability4", player) == input.PRESSED or p.ult_timer == -1) then
					misc.shakeScreen(2)
					sounds.shoot1:play(0.8 * p.attack_speed)
					local zz = arrowReach
					for i = 0, zz do
						local xx = ((math.cos(angle) * zz) * (i / zz))
						local yy = ((math.sin(angle) * zz) * (i / zz))
						particles.bolt:angle(angle, angle, 0, 0, false)
						particles.bolt:burst("above", player.x + xx, player.y + yy, 1)
						if math.random(100) < 20 then
							ballistaSmoke:burst("above", player.x + xx, player.y + yy, 1)
						end
						if Stage.collidesPoint(player.x + xx,player.y + yy) then
							break
						end
					end
					for _, enemy in ipairs(enemies:findAllLine(player.x, player.y, p.ult_target_x, p.ult_target_y)) do
						if enemy and enemy:isValid() then
							local b = player:fireBullet(enemy.x, enemy.y, 0, 1, 5, sprites.sparks2, nil)
							b:set("specific_target", enemy.id)

						end
					end
					p.ult_charges = p.ult_charges - 1
					if p.ult_timer == -1 then
						p.ult_timer = (5*60) / (3-p.ult_charges)
					else
						p.ult_timer = 5*60
					end
					return
				end
			else
				player:activateSkillCooldown(index)
				p.activity = 0
				p.pHspeed = -p.pHmax
				p.pVspeed = 0
				p.ghost_x = player.x
				p.ghost_y = player.y
				p.ult_phase = 0
			end
		end
	end
end

callback.register("onPlayerDrawAbove", function(player)
	local p = player:getAccessor()
	if p.ult_phase then
		if p.ult_phase == 1 then
			graphics.alpha(1)
			graphics.color(Color.WHITE)
			graphics.line(p.ult_x, p.ult_y, p.ult_target_x, p.ult_target_y, 1)
			graphics.circle(p.ult_target_x, p.ult_target_y, arrowRainRadius / 5, true)
			graphics.line(p.ult_target_x - (arrowRainRadius/10), p.ult_target_y, p.ult_target_x - (arrowRainRadius / 3), p.ult_target_y, 2)
			graphics.line(p.ult_target_x + (arrowRainRadius/10), p.ult_target_y, p.ult_target_x + (arrowRainRadius / 3), p.ult_target_y, 2)
			graphics.line(p.ult_target_x, p.ult_target_y - (arrowRainRadius/10), p.ult_target_x, p.ult_target_y - (arrowRainRadius / 3), 2)
			graphics.line(p.ult_target_x, p.ult_target_y + (arrowRainRadius/10), p.ult_target_x, p.ult_target_y + (arrowRainRadius / 3), 2)
		elseif p.ult_phase == 2 then
			graphics.alpha(1)
			graphics.color(Color.WHITE)
			graphics.line(p.ult_x, p.ult_y, p.ult_target_x, p.ult_target_y, 1)
			graphics.circle(p.ult_target_x, p.ult_target_y, arrowRainRadius / 5, true)
			graphics.line(p.ult_target_x - (arrowRainRadius/10), p.ult_target_y, p.ult_target_x - (arrowRainRadius / 3), p.ult_target_y, 2)
			graphics.line(p.ult_target_x + (arrowRainRadius/10), p.ult_target_y, p.ult_target_x + (arrowRainRadius / 3), p.ult_target_y, 2)
			graphics.line(p.ult_target_x, p.ult_target_y - (arrowRainRadius/10), p.ult_target_x, p.ult_target_y - (arrowRainRadius / 3), 2)
			graphics.line(p.ult_target_x, p.ult_target_y + (arrowRainRadius/10), p.ult_target_x, p.ult_target_y + (arrowRainRadius / 3), 2)
		end
	end
end)

-- Step

registercallback("postStep", function()
	for _, inst in ipairs(boltProj:findAll()) do
		boltStep(inst)
	end
	for _, inst in ipairs(grenade:findAll()) do
		grenadeStep(inst)
	end
	for _, inst in ipairs(clusterProj:findAll()) do
		clusterStep(inst)
	end
end)

------------
-- Skills --
------------

local upper_sprite = {}
local stored_sprites = {}
local anims = {"idle", "jump", "walk"}

registercallback("onPlayerInit", function(player)
	player:set("upper_half_xscale", 1)
	player:set("upper_half_subimage", 1)
	player:set("upper_half_visible", 0)
	player:set("upper_half_adjust", -1)
	player:set("anims_stored", 0)
	player:set("strafe_active", 0)
	player:set("glaive_active", 0)
	player:set("cluster_active", 0)
	player:set("rockeye_active", 0)
	upper_sprite[player] = sprites.shoot1
	stored_sprites[player] = {idle = player:getAnimation("idle"), walk = player:getAnimation("walk"), jump = player:getAnimation("jump")}
end)

local function setLegs(player)
	if player:get("anims_stored") == 0 then 
		for _, anim in ipairs(anims) do
			stored_sprites[player][anim] = player:getAnimation(anim)
			player:setAnimation(anim, player:getAnimation(anim.."half"))
		end
		player:set("anims_stored", 1)
	end
end

local function resetLegs(player)
	if player:get("anims_stored") == 1 then
		for _, anim in ipairs(anims) do
			player:setAnimation(anim, stored_sprites[player][anim])
		end
		player:set("anims_stored", 0)
	end
end

local function faceEnemy(player)
	if util.checkLine(player, 0, 300 * player.xscale) then
		player:set("upper_half_xscale", player.xscale)
	elseif util.checkLine(player, 180, 300 * player.xscale) then
		player:set("upper_half_xscale", player.xscale * -1)
	else
		player:set("upper_half_xscale", player.xscale)
	end
end

local function initSkill(player, index, sprite, skill)
	if player:get("activity") == 0 then
		player:set("activity", index)
		player:set("activity_var1", 0)
		player:set("upper_half_subimage", 1)
		setLegs(player)
		player:set("upper_half_visible", 1)
		player:set(skill.."_active", 1)
		faceEnemy(player)
		upper_sprite[player] = sprite
		player:activateSkillCooldown(index)
	end
	return false
end

local function endSkill(player, skill)
	player:set("activity", 0)
	player:set(skill.."_active", 0)
	resetLegs(player)
	player:set("upper_half_visible", 0)
end

local function skillStep(player, p, animspeed, shootFrame, shootFunction, skill)
	local ii = math.floor(player.subimage)
	if player.sprite == sprites.walk and (ii == 1 or ii == 3 or ii == 5 or ii == 6) then
		p.upper_half_adjust = -1
	else
		p.upper_half_adjust = 0
	end
	p.upper_half_subimage = p.upper_half_subimage + animspeed * p.attack_speed
	
	if p.activity_var1 == 0 and math.floor(p.upper_half_subimage) >= shootFrame then
		p.activity_var1 = 1
		shootFunction(player)
	end
	
	if math.floor(p.upper_half_subimage) >= upper_sprite[player].frames then
		endSkill(player, skill)
	end
end

-- Strafe

local strafe = Skill.new()

strafe.displayName = "Strafe"
strafe.description = "Fire an arrow for 120% damage. You can shoot all skills while moving."
strafe.icon = sprites.icons
strafe.iconIndex = 1
strafe.cooldown = 12

strafe:setEvent("init", function(player, index)
	if initSkill(player, index, player:getAnimation("shoot1"), "strafe") then
		player:setAlarm(index + 1, strafe.cooldown / player:get("attack_speed"))
		return true
	end
	return false
end)

local function strafeFire(player)
	if not player:survivorFireHeavenCracker(1) then
		for i = 0, player:get("sp") do
			local bolt = boltProj:create(player.x + 9 * player:get("upper_half_xscale"), player.y - 10 * i)
			bolt:set("parent", player.id)
			bolt:set("team", player:get("team"))
			bolt:set("direction", 90 - 90 * player:get("upper_half_xscale"))
		end
		sounds.shoot1:play(0.85 + math.random() * 0.15)
	end
end

-- Laser Glaive

local glaive = Skill.new()

glaive.displayName = "Laser Glaive"
glaive.description = "Throw a glaive that bounces to up to 4 enemies for 300% damage. Increases by 30% per bounce."
glaive.icon = sprites.icons
glaive.iconIndex = 2
glaive.cooldown = 3 * 60

glaive:setEvent("init", function(player, index)
	return initSkill(player, index, player:getAnimation("shoot2"), "glaive")
end)

local function glaiveFire(player)
	for i = 0, player:get("sp") do
		local gl = glaiveProj:create(player.x, player.y - 10 * i)
		gl:set("parent", player.id)
		gl:set("team", player:get("team"))
		gl:set("direction", 90 - 90 * player:get("upper_half_xscale"))
	end
	sounds.shoot1:play(1.35 + math.random() * 0.05)
end

-- Blink

local blink = Skill.new()

blink.displayName = "Blink"
blink.description = "Teleport forward a small distance."
blink.icon = sprites.icons
blink.iconIndex = 3
blink.cooldown = 3.5 * 60

local function makeTeleffect(x, y)
	local ef = objects.efSparks:create(x, y)
	ef.sprite = sprites.shoot3
end

local function setPlayerX(player, x)
	player.x = x
	player:set("ghost_x", x)
end

local function setPlayerY(player, y)
	player.y = y
	player:set("ghost_y", y)
end

local stepwidth = 6

local function blinkMoveHorizontal(player, maxdist, facing)	
	if player:collidesMap(player.x, player.y) then
		return
	end
	
	local dist = 0
	local x, y = player.x, player.y
	
	while true do
		dist = math.min(dist + stepwidth, maxdist)
		local tx = x + dist * facing
		if player:collidesMap(tx, y) then
			break
		elseif dist == maxdist then
			setPlayerX(player, tx)
			return
		end
	end
	for i = 1, stepwidth do
		dist = dist - 1
		local tx = x + dist * facing
		if not player:collidesMap(tx, y) then
			setPlayerX(player, tx)
			return
		end
	end
end

local function blinkMoveVertical(player, maxdist, facing)	
	if player:collidesMap(player.x, player.y) then
		return
	end
	local dist = 0
	local x, y = player.x, player.y
	while true do
		dist = math.min(dist + stepwidth, maxdist)
		local ty = y + dist * facing
		if player:collidesMap(x, ty) then
			break
		elseif dist == maxdist then
			setPlayerY(player, ty)
			return
		end
	end
	for i = 1, stepwidth do
		dist = dist - 1
		local ty = y + dist * facing
		if not player:collidesMap(x, ty) then
			setPlayerY(player, ty)
			return
		end
	end
end


blink:setEvent("init", function(player, index)
	if player:get("activity") ~= 30 and player:get("ult_phase") ~= 1 then
		player:activateSkillCooldown(index)
		sounds.shoot3:play(0.9 + math.random() * 0.2)
		makeTeleffect(player.x, player.y)
		blinkMoveHorizontal(player, 30 * player:get("pHmax"), player.xscale)
		makeTeleffect(player.x, player.y)
		faceEnemy(player)
	end
end)


-- Phase Blink

local pBlink = Skill.new()

pBlink.displayName = "Phase Blink"
pBlink.description = "Disappear and teleport a short distance. Can hold up to 3 charges."
pBlink.icon = sprites.icons
pBlink.iconIndex = 6
pBlink.cooldown = 2 * 60

pBlink:setEvent("init", function(player, index)
	if player:get("activity") ~= 30 and player:get("ult_phase") ~= 1 then
		player:activateSkillCooldown(index)
		sounds.shoot3:play(1.5 + math.random() * 0.3)
		makeTeleffect(player.x, player.y)
		blinkMoveHorizontal(player, 10 * player:get("pHmax"), player.xscale)
		makeTeleffect(player.x, player.y)
		faceEnemy(player)
		player:set("c_skill", 0)
	end
end)

-- Cluster Bomb

local cluster = Skill.new()

cluster.displayName = "Cluster Bomb"
cluster.description = "Fire an explosive arrow for 320% damage. The arrow drops bomblets that detonate for 6x80%."
cluster.icon = sprites.icons
cluster.iconIndex = 4
cluster.cooldown = 7 * 60

cluster:setEvent("init", function(player, index)
	return initSkill(player, index, player:getAnimation("shoot4"), "cluster")
end)

local function clusterFire(player)
	for i = 0, player:get("sp") do
		local bolt = clusterProj:create(player.x + 9 * player:get("upper_half_xscale"), player.y - 10 * i)
		bolt:set("parent", player.id)
		bolt:set("team", player:get("team"))
		bolt:set("direction", 90 - 90 * player:get("upper_half_xscale"))
	end
	sounds.shoot1:play(0.6 + math.random() * 0.05)
end

-- Mk7 Rockeye

local rockeye = Skill.new()

rockeye.displayName = "Mk7 Rockeye"
rockeye.description = "Fire an explosive arrow for 320% damage. The arrow drops bomblets that detonate for 12x80%."
rockeye.icon = sprites.icons
rockeye.iconIndex = 5
rockeye.cooldown = 7 * 60

rockeye:setEvent("init", function(player, index)
	return initSkill(player, index, player:getAnimation("shoot5"), "rockeye")
end)

local function rockeyeFire(player)
	for i = 0, player:get("sp") do
		local bolt = clusterProj:create(player.x + 9 * player:get("upper_half_xscale"), player.y - 10 * i)
		bolt:set("parent", player.id)
		bolt:set("team", player:get("team"))
		bolt:set("direction", 90 - 90 * player:get("upper_half_xscale"))
		bolt:set("scepter", math.max(player:get("scepter"), 1))
		bolt.sprite = sprites.bolt3
	end
	sounds.shoot1:play(0.6 + math.random() * 0.05)
end

-- Arrow Rain

local arrowRainSkill = Skill.new()

arrowRainSkill.displayName = "Arrow Rain"
arrowRainSkill.description = "Teleport into the sky. Target an area using "..input.getControlString("left").." and "..input.getControlString("right") .." to rain down arrows, slowing all enemies and dealing 110% damage per second."
arrowRainSkill.icon = sprites.icons
arrowRainSkill.iconIndex = 7
arrowRainSkill.cooldown = 7 * 60

arrowRainSkill:setEvent("init", function(player, index)
	local p = player:getAccessor()
	if p.ult_phase == 0 then
		resetLegs(player)
		sounds.shoot3:play(0.9 + math.random() * 0.2)
		makeTeleffect(player.x, player.y)
		blinkMoveVertical(player, 10 * player:get("pVmax"), -1)
		player.sprite = player:getAnimation("shoot4b_1")
		player.subimage = 1
		player:set("upper_half_visible", 0)
		player:set("upper_half_adjust", -1)
		makeTeleffect(player.x, player.y)
		p.ult_target_x = player.x
		p.ult_target_y = player.y
		p.ult_x = player.x
		p.ult_y = player.y
		p.ult_timer = 5*60
		p.ult_angle = 90
		p.ult_phase = 1
	end
end)

-- Ballista
local ballista = Skill.new()

ballista.displayName = "Ballista"
ballista.description = "Teleport backwards into the sky. Fire up to 3 energy bolts, dealing 3x900% damage. Aim using using "..input.getControlString("left").." and "..input.getControlString("right") .."."
ballista.icon = sprites.icons
ballista.iconIndex = 8
ballista.cooldown = 7*60
ballista:setEvent("init", function(player, index)
	local p = player:getAccessor()
	if p.ult_phase == 0 then
		resetLegs(player)
		sounds.shoot3:play(0.9 + math.random() * 0.2)
		makeTeleffect(player.x, player.y)
		blinkMoveHorizontal(player, 10 * player:get("pHmax"), -1)
		blinkMoveVertical(player, 5 * player:get("pVmax"), -1)
		player.sprite = player:getAnimation("shoot4b_1")
		player.subimage = 1
		player:set("upper_half_visible", 0)
		player:set("upper_half_adjust", -1)
		makeTeleffect(player.x, player.y)
		p.ult_target_x = player.x
		p.ult_target_y = player.y
		p.ult_x = player.x
		p.ult_y = player.y
		p.ult_charges = 3
		p.ult_angle = 90
		p.ult_timer = 5*60
		p.ballistaCD = 30
		p.ult_phase = 2
	end
end)


------------
-- OnStep --
------------

registercallback("postStep", function()
	for _, player in ipairs(misc.players) do
		local p = player:getAccessor()
		if p.ult_phase then
			HuntressUltStep(player, p.activity)
		end
		if p.strafe_active == 1 then 
			skillStep(player, p, 0.29, 4, strafeFire, "strafe")
		elseif p.glaive_active == 1 then
			skillStep(player, p, 0.22, 5, glaiveFire, "glaive")
		elseif p.cluster_active == 1 then
			skillStep(player, p, 0.22, 5, clusterFire, "cluster")
		elseif p.rockeye_active == 1 then
			skillStep(player, p, 0.22, 5, rockeyeFire, "rockeye")
		end
	end
end)

registercallback("onPlayerDraw", function(player)
	if player:get("upper_half_visible") == 1 then
		graphics.drawImage{upper_sprite[player], math.round(player.x), math.round(player.y + player:get("upper_half_adjust")), 
		player:get("upper_half_subimage"), xscale = player:get("upper_half_xscale")}
	end
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
	["idlehalf"] = sprites.idle,
	["walkhalf"] = sprites.walk,
	["jumphalf"] = sprites.jump,
	["climb"] = baseSprites.climb,
	["death"] = baseSprites.death,
	["shoot1"] = sprites.shoot1,
	["shoot2"] = sprites.shoot2,
	["shoot3"] = sprites.shoot3,
	["shoot4"] = sprites.shoot4,
	["shoot4b_1"] = sprites.shoot4b_1,
	["shoot5"] = sprites.shoot5,
}

local s_artic = Skill.new()

s_artic.displayName = "Arctic"
s_artic.description = ""
s_artic.icon = sprites.palettes
s_artic.iconIndex = 2
s_artic.cooldown = -1

local articSprites = {
	["loadout"] = Sprite.load("HuntressSelectSkin1", "Actors/huntress/arctic/select", sprites.loadout.frames, sprites.loadout.xorigin, sprites.loadout.yorigin),
	["idle"] = Sprite.load("HuntressIdleSkin1", "Actors/huntress/arctic/idle", baseSprites.idle.frames, baseSprites.idle.xorigin, baseSprites.idle.yorigin),
	["walk"] = Sprite.load("HuntressWalkSkin1", "Actors/huntress/arctic/walk", baseSprites.walk.frames, baseSprites.walk.xorigin, baseSprites.walk.yorigin),
	["jump"] = Sprite.load("HuntressJumpSkin1", "Actors/huntress/arctic/jump", baseSprites.jump.frames, baseSprites.jump.xorigin, baseSprites.jump.yorigin),
	["idlehalf"] = Sprite.load("HuntressIdleHalfSkin1", "Actors/huntress/arctic/idlehalf", sprites.idle.frames, sprites.idle.xorigin, sprites.idle.yorigin),
	["walkhalf"] = Sprite.load("HuntressWalkHalfSkin1", "Actors/huntress/arctic/walkhalf", sprites.walk.frames, sprites.walk.xorigin, sprites.walk.yorigin),
	["jumphalf"] = Sprite.load("HuntressJumpHalfSkin1", "Actors/huntress/arctic/jumphalf", sprites.jump.frames, sprites.jump.xorigin, sprites.jump.yorigin),
	["climb"] = Sprite.load("HuntressClimbSkin1", "Actors/huntress/arctic/climb", baseSprites.climb.frames, baseSprites.climb.xorigin, baseSprites.climb.yorigin),
	["death"] = Sprite.load("HuntressDeathSkin1", "Actors/huntress/arctic/death", baseSprites.death.frames, baseSprites.death.xorigin, baseSprites.death.yorigin),
	["shoot1"] = Sprite.load("HuntressShoot1Skin1", "Actors/huntress/arctic/shoot1", sprites.shoot1.frames, sprites.shoot1.xorigin, sprites.shoot1.yorigin),
	["shoot2"] = Sprite.load("HuntressShoot2Skin1", "Actors/huntress/arctic/shoot2", sprites.shoot2.frames, sprites.shoot2.xorigin, sprites.shoot2.yorigin),
	["shoot4"] = Sprite.load("HuntressShoot4Skin1", "Actors/huntress/arctic/shoot4", sprites.shoot4.frames, sprites.shoot4.xorigin, sprites.shoot4.yorigin),
	["shoot5"] = Sprite.load("HuntressShoot5Skin1", "Actors/huntress/arctic/shoot5", sprites.shoot5.frames, sprites.shoot5.xorigin, sprites.shoot5.yorigin),
}

--------------
-- Survivor --
--------------

local huntress = Survivor("Huntress 2.0")
local vanilla = Survivor.find("Huntress")

local loadout = Loadout.new()
loadout.survivor = huntress
loadout.description = [[The &y&Huntress&!& is extremely proficient at &y&'kiting'&!& (running and firing while remaining unhurt).
Remember that &y&Laser Glaive&!& does the &y&highest damage on the last bounce&!&!
&y&Blink&!& can be used to &y&reposition or re-aim abilities&!&, and 
&y&Cluster Bomb&!& can take out grouped up enemies at range.]]

loadout:addSkill("Primary", strafe, {
	loadoutDescription = [[Fire an arrow for &y&140% damage&!&. &b&
You can shoot all skills while moving.&!&]]
})
loadout:addSkill("Secondary", glaive, {
	loadoutDescription = [[Throw a glaive that &y&bounces&!& to up to 4 enemies 
for &y&300% damage&!&. Increases by &y&30% per bounce.&!&]]
})
loadout:addSkill("Utility", blink,{
	loadoutDescription = [[Teleport &y&forward a small distance.&!&]],
	apply = function(player)
		player:set("c_stop", 30)
	end,
	remove = function(player, hardRemove)
		player:set("c_stop", -1)
	end,
})
loadout:addSkill("Utility", pBlink,{
	loadoutDescription = [[Disappear and teleport &y&a short distance&!&. 
&b&Can hold up to 3 charges&!&.]],
	apply = function(player)
		Ability.AddCharge(player, "c", 2, true)
		player:set("c_stop", 30)
	end,
	remove = function(player, hardRemove)
		Ability.Disable(player, "c")
		player:set("c_stop", -1)
	end,
	locked = true,
})
loadout:addSkill("Special", cluster,{
	loadoutDescription = [[Fire an &y&explosive arrow&!& for &y&320% damage&!&. 
The arrow drops bomblets that detonate for &y&6x80%.&!&]],
	upgrade = loadout:addSkill("Special", rockeye, {hidden = true}) 
}) 
loadout:addSkill("Special", arrowRainSkill,{
	loadoutDescription = [[Teleport into the sky. Target an area using 
]]..input.getControlString("left")..[[ and ]]..input.getControlString("right") ..[[ to &y&rain down arrows&!&, 
&y&slowing all enemies&!& and dealing &y&110% damage per second&!&.]],
locked = true,
})
loadout:addSkill("Special", ballista,{
	loadoutDescription = [[Teleport backwards into the sky. Fire up to &y&3 energy bolts&!&, 
dealing &y&3x900% damage&!&. Aim using using ]]..input.getControlString("left")..[[ and ]]..input.getControlString("right") ..[[.]],
locked = true,
})

loadout:addSkin(s_default, defaultSprites)
loadout:addSkin(s_artic, articSprites, {
	locked = true
})

huntress.titleSprite = baseSprites.walk
huntress.loadoutColor = Color.RED
huntress.loadoutSprite = sprites.loadout
huntress.endingQuote = "..and so she left, her soul still remaining on the planet." 

huntress:addCallback("init", function(player)
	local p = player:getAccessor()
	player:setAnimations(baseSprites)
	player:survivorSetInitialStats(90, 12, 0.01)
	p.ult_phase = 0
	p.ult_timer = -1
	p.ballistaCD = 30
	p.ult_charges = 3
end)

huntress:addCallback("levelUp", function(player)
	player:survivorLevelUpStats(32, 3, 0.002, 2)
	player:set("attack_speed", player:get("attack_speed") + 0.025)
end)

huntress:addCallback("scepter", function(player)
	Loadout.Upgrade(loadout, player, "Special")
end)

----------------------------------------------------------------

local vanillaUnlock = Achievement.find("unlock_mercenary", "vanilla")

local huntressUnlock = Achievement.new("unlock_huntress_ror2")
huntressUnlock:assignUnlockable(huntress)
huntressUnlock.requirement = 3
huntressUnlock.description = "Reach and complete the 3rd Teleporter event without dying."
huntressUnlock.deathReset = true

local teleporter = Object.find("Teleporter", "vanilla")

callback.register("postStep", function()
	local tpInst = teleporter:find(1)
	if tpInst then
		local tp = tpInst:getAccessor()
		if tp.huntressVar then
			if tp.active == 5 or tp.active == 7 then
				if tp.huntressVar == 0 then
					huntressUnlock:increment(1)
					tp.huntressVar = 1
				end
			end

		else
			tp.huntressVar = 0
		end
	end
end)

local ManageHuntressUnlock = function()
	if vanillaUnlock:isComplete() and not huntressUnlock:isComplete() then
		huntressUnlock:increment(3)
	end
end

ManageHuntressUnlock()

callback.register("postStep", function()
	ManageHuntressUnlock()
end)

local arcticUnlock = Achievement.new("unlock_huntress_skin1")
arcticUnlock.requirement = 1
arcticUnlock.sprite = MakeAchievementIcon(sprites.palettes, 2)
arcticUnlock.unlockText = "New skin: \'Arctic\' unlocked."
arcticUnlock.highscoreText = "Huntress: \'Arctic\' Unlocked"
arcticUnlock.description = "As Huntress, Obliterate yourself at the Obelisk on Monsoon."
arcticUnlock.deathReset = false
arcticUnlock:addCallback("onComplete", function()
	loadout:getSkillEntry(s_artic).locked = false
	Loadout.Save(loadout)
end)

Loadout.RegisterSurvivorID(huntress)

return huntress
--require("Misc.loadout")
--require("Libraries.skill.main")

---------------
-- Resources --
---------------

local baseSprites = {
	idle = Sprite.load("LoaderIdle", "Actors/loader/idle", 1, 7,8),
	idle_nofist = Sprite.load("LoaderIdleNoFist", "Actors/loader/idle2", 1, 7,8),
	walk = Sprite.load("LoaderWalk", "Actors/loader/walk", 8, 9,8),
	walk_nofist = Sprite.load("LoaderWalkNoFist", "Actors/loader/walk2", 8, 9,8),
	jump = Sprite.load("LoaderJump", "Actors/loader/jump",1, 8,8),
	jump_nofist = Sprite.load("LoaderJumpNoFist", "Actors/loader/jump2",1, 8,8),
	climb = Sprite.load("LoaderClimb", "Actors/loader/climb", 2, 5, 8),
    death = Sprite.load("LoaderDeath", "Actors/loader/death", 6, 11, 26),
}

local sprites = {
	shoot1_1 = Sprite.load("LoaderShoot1_1", "Actors/loader/shoot1_1", 9, 9, 9),
	shoot1_2 = Sprite.load("LoaderShoot1_2", "Actors/loader/shoot1_2", 9, 9, 9),
	shoot2 = Sprite.find("GManShoot2", "vanilla"),
	shoot3_idle = Sprite.load("LoaderShoot3_1_1", "Actors/loader/punchIdle",3, 12, 7),
	shoot3_walk = Sprite.load("LoaderShoot3_1_2", "Actors/loader/punchForward",8, 12, 10),
	shoot3 = Sprite.load("LoaderShoot3_2", "Actors/loader/shoot3",13, 12, 10),
	shoot4 = Sprite.find("GManShoot4_1", "vanilla"),
	shoot5 = Sprite.find("GManShoot5_1", "vanilla"),
	icons = Sprite.load("LoaderSkills", "Actors/loader/icons", 7, 0, 0),
	palettes = Sprite.load("LoaderPalettes", "Actors/loader/palettes", 2, 0, 0),
	loadout = Sprite.find("SelectLoader", "vanilla"),
	fist = Sprite.load("LoaderFist", "Actors/loader/fist", 1, 4, 2),
	fistMask = Sprite.load("LoaderFistMask", "Actors/loader/fistMask", 1, 4, 2),
	punch = Sprite.load("LoaderPunch", "Actors/loader/sparks", 4, 15, 14),
	sparks2 = Sprite.find("Sparks2", "vanilla"),
}

local sounds = {
	SamuraiShoot1 = Sound.find("SamuraiShoot1", "vanilla"),
	JanitorShoot1_2 = Sound.find("JanitorShoot1_2", "vanilla"),
	FistShoot = Sound.find("Drill", "vanilla"),
	Pickup = Sound.find("Pickup", "vanilla"),
}

local objects = {
	dust = Object.find("MinerDust", "vanilla"),
}

-------------
--Resources--
-------------

local enemies = ParentObject.find("enemies", "vanilla")	

------------
-- onStep --
------------

local zAgainTime = 45 --How much time, in frames, the player has to input Knuckleboom again

local knuckleBoomStep = function(player)
	local p = player:getAccessor()
	if p.z_again then
		if p.z_again > -1 then
			p.z_again = p.z_again - 1
			if input.checkControl("ability1", player) == input.HELD then
				p.z_count = (p.z_count + 1) % 2
				Skill.activate(player, 1)
			end
		else
			p.z_count = 0
		end

	end
end

callback.register("postStep", function()
	for _, player in ipairs(misc.players) do
		if player:getAccessor().z_count then
			knuckleBoomStep(player)
		end
	end
end)

------------
--Objects --
------------

local fist = Object.new("LoaderFist")
fist.sprite = sprites.fist

local smoke = ParticleType.new("LoaderSmoke") --weed haha
smoke:shape("Disc")
smoke:scale(0.1, 0.1)
smoke:size(1, 1, -0.08, 0)
smoke:direction(0, 360, 0, 0)
smoke:speed(1, 1, -0.01, 0)

local maxDistance = 250
local hookStep = 3
local detectionRadius = 10

local heavyEnemies = {
	Object.find("Golem", "vanilla"),
	Object.find("GolemS", "vanilla"),
	Object.find("JellyG2", "vanilla"),
	Object.find("LizardG", "vanilla"),
	Object.find("LizardGS", "vanilla"),
	Object.find("Crab", "vanilla"),
	Object.find("WispG", "vanilla"),
	Object.find("WispG2", "vanilla"),
	Object.find("ChildG", "vanilla"),
	Object.find("Bison", "vanilla"),
	Object.find("Slime", "vanilla"),
	Object.find("Guard", "vanilla"),
	Object.find("GuardG", "vanilla"),
	Object.find("Boss1", "vanilla"),
	Object.find("Boss2", "vanilla"),
	Object.find("Boss3", "vanilla"),
	Object.find("WormHead", "vanilla"),
	Object.find("WormBody", "vanilla"),
	Object.find("WurmHead", "vanilla"),
	Object.find("WurmBody", "vanilla"),
	---
	Object.find("BeetleG", "RoR2Demake"),
}

local CreateFist = function(parent, spiked)
	local inst = fist:create(parent.x + (sprites.fist.width * parent.xscale), parent.y - 3)
	local i = inst:getData()
	i.parent = parent
	i.spiked = spiked or false
	inst.xscale = parent.xscale
	i.vx = (parent:get("pHmax") * parent:get("attack_speed")) * 8.5
	i.dist = 0
	i.phase = 0
	i.targetWeight = 0
	inst.depth = parent.depth - 1
	parent:getAccessor().fist = inst.id
	return inst
end

local InitFist = function(this)
	local data = this:getData()
	local self = this:getAccessor()
	this.mask = sprites.fistMask
	self.stuckTo = -1
end

local StepFist = function(this)
	local data = this:getData()
	local self = this:getAccessor()
	local parent = data.parent
	if parent then
		if data.phase == 0 then --Firing forward
			data.dist = math.approach(data.dist, maxDistance, data.vx)
			if data.dist < maxDistance then
				this.x = this.x + (data.vx * this.xscale)
				local target = enemies:findNearest(this.x, this.y)
				if this:collidesMap(this.x, this.y) or (target and this:collidesWith(target, this.x, this.y)) then
					misc.shakeScreen(5)
					local dir = 180
					if parent.xscale == -1 then
						dir = 0
					end
					smoke:direction(dir - 45, dir + 45, 0, 0)
					for i = 0, 30 do
						smoke:burst("above", this.x, this.y, 1, Color.fromRGB(123,141,169))
					end
					if target and target:isValid() then
						data.stuckTo = target.id
						if data.spiked then
							for i = 0, parent:get("sp") do
								local bullet = parent:fireExplosion(target.x, target.y, 1.1, 1, 3.2, nil, sprites.punch)
								bullet:set("specific_target", target.id)
								bullet:set("stun", 1)
								bullet:set("climb", (0 + i * 8))
							end
							for _, enemy in ipairs(heavyEnemies) do
								if target:getObject() == enemy or target:isBoss() then
									-- bosses are automatically marked as heavy enemies
									data.targetWeight = 1 --If enemy is heavy, mark it as such
									break
								end
							end
						end
					end
					data.parentDist = Distance(this.x, this.y, parent.x, parent.y)
					data.phase = 1
				end
			else
				data.phase = 2
			end
		elseif data.phase == 1 then --Stuck in wall / enemy
			parent:activateSkillCooldown(2)
			if input.checkControl("ability2", parent) ~= input.HELD then
				data.phase = 2
			else
				-----------------------------------------
				local p = parent:getAccessor()
				if data.spiked and data.stuckTo then
					-- spiked behavior
					if data.targetWeight == 1 then
						-- target is heavy
						if p.free ~= 0 then
							local z = 0
							local angle = GetAngleTowards(parent.x, parent.y, this.x, this.y)
							for i = 0, hookStep do
								if parent:collidesMap(parent.x, parent.y) then break end
								local xx = (math.cos(math.rad(angle)) * i)
								local yy = math.sin(math.rad(angle)) * i
								if p.activity ~= 30 and not Stage.collidesRectangle(parent.x, parent.y, parent.x + (((parent.sprite.width/2) + math.ceil(xx)) * math.sign(this.x - parent.x)), parent.y + math.ceil(yy)) then
									parent.x = parent.x - xx
									parent.y = parent.y + yy
								end
								z = z + 1
							end
							data.dist = data.dist - z
						end
						if data.stuckTo and data.stuckTo > -1 then
							local target = Object.findInstance(data.stuckTo)
							if target and target:isValid() then
								this.x = target.x
								this.y = target.y
							end
						end
					else	
						--target is not heavy, drag the target to the parent
						if data.stuckTo then
							local target = Object.findInstance(data.stuckTo)
							if (target and target:isValid()) and data.spiked then
								local angle = GetAngleTowards(parent.x, parent.y, this.x, this.y)
								local xx = math.cos(angle) * (hookStep * 1.5)
								local yy = math.sin(angle) * (hookStep * 1.5)
								if not Stage.collidesRectangle(target.x, target.y, target.x + (((target.sprite.width/2) + math.ceil(xx)) * math.sign(this.x - target.x)), target.y + math.ceil(yy)) then
									this.x = math.approach(this.x, parent.x, xx)
									this.y = math.approach(this.y, parent.y, yy)
									target.x = this.x
									target.y = this.y
								end
							end
						end
					end
					if this:collidesWith(parent, this.x, this.y) or Distance(this.x, this.y, parent.x, parent.y) > maxDistance * 1.5 or Distance(this.x, this.y, parent.x, parent.y) < detectionRadius*hookStep then --(parent.x - (detectionRadius*hookStep) <= this.x and parent.y - (detectionRadius*hookStep) <= this.y and parent.x + (detectionRadius*hookStep) >= this.x and parent.y + (detectionRadius*hookStep) >= this.y) then
						data.phase = 2
					end
					-----------------------------------------
				else
					-- normal behavior
					if p.free ~= 0 then
						local z = 0
						local angle = GetAngleTowards(parent.x, parent.y, this.x, this.y)
						for i = 0, hookStep do
							if parent:collidesMap(parent.x, parent.y) then break end
							local xx = (math.cos(math.rad(angle)) * i)
							local yy = math.sin(math.rad(angle)) * i
							if p.activity ~= 30 and not Stage.collidesRectangle(parent.x, parent.y, parent.x + (((parent.sprite.width/2) + math.ceil(xx)) * math.sign(this.x - parent.x)), parent.y + math.ceil(yy)) then
								parent.x = parent.x - xx
								parent.y = parent.y + yy
							end
							z = z + 1
						end
						data.dist = data.dist - z
					end
					if this:collidesWith(parent, this.x, this.y) or Distance(this.x, this.y, parent.x, parent.y) > maxDistance * 1.5 or Distance(this.x, this.y, parent.x, parent.y) < detectionRadius*hookStep then --(parent.x - (detectionRadius*hookStep) <= this.x and parent.y - (detectionRadius*hookStep) <= this.y and parent.x + (detectionRadius*hookStep) >= this.x and parent.y + (detectionRadius*hookStep) >= this.y) then
						data.phase = 2
					end
				end
				
			end
		elseif data.phase == 2 then --Pulling back towards parent / Retracting
			local angle = GetAngleTowards(parent.x, parent.y, this.x, this.y)
			local xx = math.cos(angle) * (hookStep * 3)
			local yy = math.sin(angle) * (hookStep * 3)
			this.x = math.approach(this.x, parent.x, xx)
			this.y = math.approach(this.y, parent.y, yy)
			if this:collidesWith(parent, this.x, this.y) then
				sounds.Pickup:play(0.5)
				parent:getData().fist = -1
				if parent:getAlarm(3) == -1 then
					parent:setAlarm(3, 30)
				end
				this:destroy()
				return
			end
		end
	else
		this:destroy()
		return
	end
	
end

local DrawFist = function(handler)
	local parent = handler:getData().parent
	if parent:get("fist") then
		local fistInst = Object.findInstance(parent:get("fist"))
		if fistInst then
			graphics.color(Color.BLACK)
			graphics.alpha(1)
			graphics.line(parent.x, parent.y, fistInst.x, fistInst.y, 2)
		end
	end
end

fist:addCallback("create", function(this)
	InitFist(this)
end)

fist:addCallback("step", function(this)
	local data = this:getData()
	local self = this:getAccessor()
	StepFist(this)
end)


------------
-- onStep --
------------

local FistStep = function(player)
	local p = player:getAccessor()
	local data = player:getData()
	if player and data.fist then
		local inst = Object.findInstance(data.fist)
		if data.fist > -1 and (inst and inst:isValid() and (inst:getData().parent and inst:getData().parent == player)) then
			p.z_count = 1
			player:setAnimations{
				idle = player:getAnimation("idle_nofist"),
				walk = player:getAnimation("walk_nofist"),
				jump = player:getAnimation("jump_nofist"),
			}
		else
			player:setAnimations{
				idle = player:getAnimation("idle_fist"),
				walk = player:getAnimation("walk_fist"),
				jump = player:getAnimation("jump_fist"),
			}
		end
	end
end

local maxPunchCharge = 60
local punchSpeedMult = 4

local TrackVelocity = function(player)
	local data = player:getData()
	local p = player:getAccessor()
	if player:isValid() then
		if data.lastX then
			data.currentX = player.x
			data.currentY = player.y
			-------------------------
			local deltaX = math.abs(data.currentX - data.lastX)
			local deltaY = math.abs(data.currentY - data.lastY)
			data.velocity = math.sqrt(math.pow(deltaX, 2) + math.pow(deltaY, 2))
			-------------------------
			data.lastX = player.x
			data.lastY = player.y
		else
			data.lastX = player.x
			data.lastY = player.y
			data.currentX = player.x
			data.currentY = player.y
			data.velocity = 0
		end
	end
end

local SuperPunchStep = function(player, thunder)
	local data = player:getData()
	local p = player:getAccessor()
	if data.superPunchPhase then
		if thunder then
			if data.superPunchPhase == 0 then
				data.superPunchHits = {}
				data.superPunchDamage = 6
				if player:getFacingDirection() == 180 then
					data.superPunchDir = -1
				else
					data.superPunchDir = 1
				end
			elseif data.superPunchPhase == 1 then
				if player.xscale ~= data.superPunchDir then
					player.xscale = data.superPunchDir
				end
				if data.superPunchCharge < maxPunchCharge then
					data.superPunchCharge = data.superPunchCharge + 5
					p.activity = 3
					p.activity_type = 1
					data.superPunchDamage = math.clamp(6 + (21 * (data.superPunchCharge / maxPunchCharge)), 6, 27)
					data.superPunchMovementBonus = math.clamp(data.velocity, 1, math.huge)
					player:activateSkillCooldown(3)
					if p.moveLeft == 0 and p.moveRight == 1 then
						player.sprite = sprites.shoot3_walk
						if data.superPunchDir == -1 then
							player.spriteSpeed = -0.2 * p.pHmax
							p.pHspeed = p.pHmax * 0.5
						else
							player.spriteSpeed = 0.2 * p.pHmax
							p.pHspeed = p.pHmax * 0.5
						end
					elseif p.moveLeft == 1 and p.moveRight == 0 then
						player.sprite = sprites.shoot3_walk
						if data.superPunchDir == -1 then
							player.spriteSpeed = 0.2 * p.pHmax
							p.pHspeed = -p.pHmax * 0.5
						else
							player.spriteSpeed = -0.2 * p.pHmax
							p.pHspeed = -p.pHmax * 0.5
						end
					else
						p.pHspeed = 0
						player.sprite = sprites.shoot3_idle
						player.spriteSpeed = 0.2 * p.pHmax
					end
				else
					data.superPunchPhase = 2
					player.subimage = 1
					return
				end
				
			elseif data.superPunchPhase == 2 then
				if data.superPunchCharge > 0 then
					p.activity = 3
					---------------------------
					local nearestEnemy = enemies:findNearest(player.x, player.y)
					if nearestEnemy and nearestEnemy:isValid() then
						if player:collidesWith(nearestEnemy, player.x, player.y) then
							if nearestEnemy:get("team") ~= player:get("team") and not data.superPunchHits[nearestEnemy] then
								misc.shakeScreen(15)
								local hit = player:fireBullet(nearestEnemy.x, nearestEnemy.y, 0, 1, 21, sprites.punch, nil)
								hit:set("specific_target", nearestEnemy.id)
								data.superPunchHits[nearestEnemy] = true
								data.superPunchCharge = 0
								p.pHspeed = (p.pHmax * -data.superPunchDir) * (punchSpeedMult)
								p.pVspeed = -(p.pVmax)
								return
							end
						end
					end
					---------------------------
					if p.activity_var1 == 0 then
						sounds.JanitorShoot1_2:play()
						misc.shakeScreen(10)
						p.activity_var1 = 1
					end
					player.sprite = player:getAnimation("shoot3")
					player.spriteSpeed = (p.attack_speed * 0.2)
					if data.superPunchCharge > (5*(p.attack_speed * 0.2)) then
						if math.floor(player.subimage) == 8 then
							player.subimage = 7
						end
					end
					if p.free == 0 then
						if data.superPunchCharge % 15 == 0 then
							local dust = objects.dust:create(player.x, player.y)
							dust.xscale = data.superPunchDir
						end
					end
					p.activity_type = 1
					p.pHspeed = ((p.pHmax * data.superPunchDir) * (0.75 * punchSpeedMult)) * (data.superPunchCharge / maxPunchCharge)
					if player.xscale ~= data.superPunchDir then
						player.xscale = data.superPunchDir
					end
					data.superPunchCharge = data.superPunchCharge - 1
				else
					player.sprite = player:getAnimation("idle")
					p.activity_type = 0
					p.activity_var1 = 0
					p.activity = 0
					data.superPunchPhase = 0
					return
				end
			end
		else
			if data.superPunchPhase == 0 then
				data.superPunchHits = {}
				data.superPunchDamage = 6
				if player:getFacingDirection() == 180 then
					data.superPunchDir = -1
				else
					data.superPunchDir = 1
				end
			elseif data.superPunchPhase == 1 then
				if player.xscale ~= data.superPunchDir then
					player.xscale = data.superPunchDir
				end
				if data.superPunchCharge < maxPunchCharge then
					data.superPunchCharge = data.superPunchCharge + 1
				end
				p.activity = 3
				p.activity_type = 1
				data.superPunchDamage = math.clamp(6 + (21 * (data.superPunchCharge / maxPunchCharge)), 6, 27)
				data.superPunchMovementBonus = math.clamp(data.velocity, 1, math.huge)
				player:activateSkillCooldown(3)
				if p.moveLeft == 0 and p.moveRight == 1 then
					player.sprite = sprites.shoot3_walk
					if data.superPunchDir == -1 then
						player.spriteSpeed = -0.2 * p.pHmax
						p.pHspeed = p.pHmax * 0.5
					else
						player.spriteSpeed = 0.2 * p.pHmax
						p.pHspeed = p.pHmax * 0.5
					end
				elseif p.moveLeft == 1 and p.moveRight == 0 then
					player.sprite = sprites.shoot3_walk
					if data.superPunchDir == -1 then
						player.spriteSpeed = 0.2 * p.pHmax
						p.pHspeed = -p.pHmax * 0.5
					else
						player.spriteSpeed = -0.2 * p.pHmax
						p.pHspeed = -p.pHmax * 0.5
					end
				else
					p.pHspeed = 0
					player.sprite = sprites.shoot3_idle
					player.spriteSpeed = 0.2 * p.pHmax
				end
			elseif data.superPunchPhase == 2 then
				if data.superPunchCharge > 0 then
					p.activity = 3
					---------------------------
					local nearestEnemy = enemies:findNearest(player.x, player.y)
					if nearestEnemy and nearestEnemy:isValid() then
						if player:collidesWith(nearestEnemy, player.x, player.y) then
							if nearestEnemy:get("team") ~= player:get("team") and not data.superPunchHits[nearestEnemy] then
								local hit = player:fireBullet(nearestEnemy.x, nearestEnemy.y, 0, 1, data.superPunchDamage * data.superPunchMovementBonus, sprites.punch, nil)
								hit:set("specific_target", nearestEnemy.id)
								data.superPunchHits[nearestEnemy] = true
							end
						end
					end
					---------------------------
					if p.activity_var1 == 0 then
						print("Damage: "..data.superPunchDamage*100 .."%")
						print("Movement Bonus: "..data.superPunchMovementBonus)
						print("Total: "..(data.superPunchDamage*data.superPunchMovementBonus)*100 .."%")
						sounds.JanitorShoot1_2:play()
						misc.shakeScreen(10)
						p.activity_var1 = 1
					end
					player.sprite = player:getAnimation("shoot3")
					player.spriteSpeed = (p.attack_speed * 0.2)
					if data.superPunchCharge > (5*(p.attack_speed * 0.2)) then
						if math.floor(player.subimage) == 8 then
							player.subimage = 7
						end
					end
					if p.free == 0 then
						if data.superPunchCharge % 15 == 0 then
							local dust = objects.dust:create(player.x, player.y)
							dust.xscale = data.superPunchDir
						end
					end
					p.activity_type = 1
					p.pHspeed = ((p.pHmax * data.superPunchDir) * punchSpeedMult) * (data.superPunchCharge / maxPunchCharge)
					if player.xscale ~= data.superPunchDir then
						player.xscale = data.superPunchDir
					end
					data.superPunchCharge = data.superPunchCharge - 1
				else
					player.sprite = player:getAnimation("idle")
					p.activity_type = 0
					p.activity_var1 = 0
					p.activity = 0
					data.superPunchPhase = 0
					return
				end
			end
		end
		
	else
		data.superPunchPhase = 0
	end
end

local SuperPunchDraw = function(handler)
	local player = handler:getData().parent
	local data = player:getData()
	if data.superPunchPhase == 1 then
		local arrowX = player.x + ((data.superPunchCharge * (0.6)) * data.superPunchDir)
		graphics.alpha(1)
		graphics.color(Color.WHITE)
		graphics.line(player.x, player.y, arrowX, player.y, 3)
		graphics.line(arrowX, player.y, arrowX + (5 * -data.superPunchDir), player.y - 5, 3)
		graphics.line(arrowX, player.y, arrowX + (5 * -data.superPunchDir), player.y + 5, 3)
	end
end

local SuperPunchInputStep = function(player, thunder)
	local data = player:getData()
	local p = player:getAccessor()
	if thunder then
		if input.checkControl("ability3") == input.PRESSED then
			if p.activity == 0 and player:getAlarm(4) == -1 then
				data.superPunchPhase = 1
			end
		end

	else
		if input.checkControl("ability3") == input.HELD then
			if p.activity == 0 and player:getAlarm(4) == -1 then
				data.superPunchPhase = 1
			end
		elseif input.checkControl("ability3") ~= input.HELD and data.superPunchPhase == 1 then
			data.superPunchPhase = 2
			player.subimage = 1
		end
	end
end

------------
-- Skills --
------------

-- Scrap Barrier

local barrier = Skill.new()

barrier.displayName = "Scrap Barrier"
barrier.description = "The Loader is immune to fall damage. Striking enemies with the Loader's gauntlets grants a temporary barrier."
barrier.icon = sprites.icons
barrier.iconIndex = 1
barrier.cooldown = -1

callback.register("onHit", function(damager, hit, x, y)
	local parent = damager:getParent()
	if parent and parent:isValid() then
		if parent:get("barrierOnHit") and damager:get("barrierOnHit") and damager:get("barrierOnHit") > 0 then
			parent:set("barrier", parent:get("barrier") + ((parent:get("maxhp") + parent:get("maxshield")) * damager:get("barrierOnHit")))
		end
	end
end)

--No fall damage
callback.register("onPlayerStep", function(player)
	local p = player:getAccessor()
	if p.fallDamage then
		if p.fallDamage > 0 then
			if p.free == 1 then
				for i = player.y, player.y + (p.pVspeed * 2) do
					if Stage.collidesPoint(player.x, i) then
						p.pVspeed = p.pVmax
						break
					end
				end
			end
		end
	else
		p.fallDamage = 0
	end
end)


local function initActivity(player, index, sprite, speed, scaleSpeed, resetHSpeed)
	if player:get("activity") == 0 then
		player:survivorActivityState(index, sprite, speed, scaleSpeed, resetHSpeed)
		player:activateSkillCooldown(index)
		return true
	end
	return false
end

-- Knuckleboom


local knuckleboom = Skill.new()

knuckleboom.displayName = "Knuckleboom"
knuckleboom.description = "Swing at nearby enemies for 320% damage."
knuckleboom.icon = sprites.icons
knuckleboom.iconIndex = 2
knuckleboom.cooldown = 30


knuckleboom:setEvent("init", function(player, index)
	local p = player:getAccessor()
	if initActivity(player, index, player:getAnimation("shoot1_"..(p.z_count+1)), 0.25, true, true) then
		player:setAlarm(index + 1, knuckleboom.cooldown / player:get("attack_speed"))
		sounds.SamuraiShoot1:play(player:get("attack_speed") * 0.85, misc.getOption("general.volume"))
		return true
	end
	return false
end)
knuckleboom:setEvent(3, function(player)
	local p = player:getAccessor()
	sounds.JanitorShoot1_2:play(0.9 + math.random() * 0.2)
	misc.shakeScreen(1)
	for i = 0, player:get("sp") do
		local bullet = player:fireExplosion(player.x + (8 * player.xscale), player.y, 1.1, 1, 3.2, nil, sprites.punch)
		bullet:set("knockback", 5)
		bullet:set("climb", climb or (0 + i * 8))
		bullet:set("barrierOnHit", player:get("barrierOnHit") or 0)
	end
	if player:get("free") == 0 then
		player:set("pHspeed", player:get("pHmax") * player.xscale)
	end
end)
knuckleboom:setEvent("last", function(player)
	local p = player:getAccessor()
	p.z_again = zAgainTime
end)

-- Grapple Fist

local grapple = Skill.new()

grapple.displayName = "Grapple Fist"
grapple.description = "Fire your gauntlet forward, pulling you to the target."
grapple.icon = sprites.icons
grapple.iconIndex = 3
grapple.cooldown = 5 * 60

grapple:setEvent("init", function(player, index)
	local p = player:getAccessor()
	local data = player:getData()
	if (p.activity ~= 30 and p.activity ~= 95 and p.activity ~= 99) and not (data.fist and data.fist > -1) then
		sounds.SamuraiShoot1:play(0.85)
		sounds.FistShoot:play(player:get("attack_speed"))
		local fInst = CreateFist(player, false)
		data.fist = fInst.id
		return true
	end
	return false
end)


-- Spiked Fist

local spikeFist = Skill.new()

spikeFist.displayName = "Spiked Fist"
spikeFist.description = "Fire your gauntlet forward, dealing 320% damage and stunning. Pulls you to heavy targets. Light targets are pulled to YOU instead."
spikeFist.icon = sprites.icons
spikeFist.iconIndex = 4
spikeFist.cooldown = 5 * 60

spikeFist:setEvent("init", function(player, index)
	local p = player:getAccessor()
	local data = player:getData()
	if (p.activity ~= 30 and p.activity ~= 95 and p.activity ~= 99) and not (data.fist and data.fist > -1) then
		local fInst = CreateFist(player, true)
		data.fist = fInst.id
		return true
	end
	return false
end)

-- Charged Gauntlet

local superPunch = Skill.new()

superPunch.displayName = "Charged Gauntlet"
superPunch.description = "Charge up a massive punch for 600%-2700% damage that sends you flying forward. Deals significantly more damage the faster you are moving."
superPunch.icon = sprites.icons
superPunch.iconIndex = 5
superPunch.cooldown = 5 * 60

-- Thunder Gauntlet

local instantPunch = Skill.new()

instantPunch.displayName = "Thunder Gauntlet"
instantPunch.description = "Charge up a single punch for 2100% damage that also shocks all enemies in a cone for 1000% damage. Deals significantly more damage the faster you are moving."
instantPunch.icon = sprites.icons
instantPunch.iconIndex = 6
instantPunch.cooldown = 5 * 60

-- Pylon

local deployPylon = Skill.new()

deployPylon.displayName = "M551 Pylon"
deployPylon.description = "Throw a floating pylon that zaps up to 6 nearby enemies for 100% damage. Can be grappled."
deployPylon.icon = sprites.icons
deployPylon.iconIndex = 7
deployPylon.cooldown = 20 * 60

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
	------------------------
	["idle_fist"] = baseSprites.idle,
	["idle_nofist"] = baseSprites.idle_nofist,
	["walk_fist"] = baseSprites.walk,
	["walk_nofist"] = baseSprites.walk_nofist,
	["jump_fist"] = baseSprites.jump,
	["jump_nofist"] = baseSprites.jump_nofist,
	------------------------
	["climb"] = baseSprites.climb,
	["death"] = baseSprites.death,
	["shoot1_1"] = sprites.shoot1_1,
	["shoot1_2"] = sprites.shoot1_2,
	["shoot2"] = sprites.shoot2,
	["shoot3_idle"] = sprites.shoot3_idle,
	["shoot3_walk"] = sprites.shoot3_walk,
	["shoot3"] = sprites.shoot3,
	["shoot4_1"] = sprites.shoot4,
	["shoot5_1"] = sprites.shoot5,
}

local s_classic = Skill.new()

s_classic.displayName = "Classic"
s_classic.description = ""
s_classic.icon = sprites.palettes
s_classic.iconIndex = 2
s_classic.cooldown = -1

local classicSprites = {
	["loadout"] = sprites.loadout,
	["idle"] = baseSprites.idle,
	["walk"] = baseSprites.walk,
	["jump"] = baseSprites.jump,
	------------------------
	["idle_fist"] = baseSprites.idle,
	["idle_nofist"] = baseSprites.idle_nofist,
	["walk_fist"] = baseSprites.walk,
	["walk_nofist"] = baseSprites.walk_nofist,
	["jump_fist"] = baseSprites.jump,
	["jump_nofist"] = baseSprites.jump_nofist,
	------------------------
	["climb"] = baseSprites.climb,
	["death"] = baseSprites.death,
	["shoot1_1"] = sprites.shoot1_1,
	["shoot1_2"] = sprites.shoot1_2,
	["shoot2"] = sprites.shoot2,
	["shoot3"] = sprites.shoot3,
	["shoot4_1"] = sprites.shoot4,
	["shoot5_1"] = sprites.shoot5,
}

--------------
-- Survivor --
--------------

local loader = Survivor.new("Loader 2.0")

local loadout = Loadout.new()
loadout.survivor = loader
loadout.description = [[The &y&Commando&!& is characterized by long range and mobility.
Effective use of his &y&Tactical Dive&!& will grant increased survivability,
while &y&suppressive fire&!& deals massive damage.
&y&FMJ&!& can then be used to dispose of large mobs.]]

local passive = loadout:getSlot("Passive")
passive.showInLoadoutMenu = true
passive.showInCharSelect = true
loadout:addSkill("Passive", barrier, {
	loadoutDescription = [[The Loader is &b&immune&!& to fall damage. Striking enemies with the
Loader's gauntlets grants a &g&temporary barrier&!&.]],
	apply = function(player) 
		player:set("fallDamage", 1) 
		player:set("barrierOnHit", 0.05) 
	end,
	remove = function(player, hardRemove)
		player:set("fallDamage", 0) 
		player:set("barrierOnHit", 0)
	end,
})
loadout:addSkill("Passive", Loadout.PresetSkills.NoPassive, {
	displayName = "Disable the Loader's Passive abilities."
})

loadout:addSkill("Primary", knuckleboom, {
	loadoutDescription = [[Swing at nearby enemies for &y&320% damage&!&.]]
})
loadout:addSkill("Secondary", grapple, {
	loadoutDescription = [[Fire your gauntlet forward, pulling you to the target.]]
})
loadout:addSkill("Secondary", spikeFist,{
	loadoutDescription = [[Fire your gauntlet forward, dealing 320% damage and stunning. 
Pulls you to heavy targets. Light targets are pulled to YOU instead.]]
})
loadout:addSkill("Utility", superPunch,{
	loadoutDescription = [[Charge up a massive punch for &y&600%-2700% damage&!& that sends you
&b&flying forward&!&. Deals &y&significantly more damage&!& the &y&faster&!& you are moving.]]
})
loadout:addSkill("Utility", instantPunch,{
	loadoutDescription = [[Charge up a single punch for &y&2100% damage&!& that also &y&shocks&!& all enemies
in a cone for &y&1000% damage&!&. &b&Deals significantly more damage the faster you are moving&!&.]]
})
loadout:addSkill("Special", deployPylon,{
	loadoutDescription = [[Fire rapidly, &y&stunning&!& and hitting nearby enemies
for &y&6x60% damage&!&.]]
})
loadout:addSkin(s_default, defaultSprites)
loadout:addSkin(s_classic, classicSprites, {
	locked = true,
	unlockText = "Loader: Obliterate yourself at the Obelisk on Monsoon difficulty."}
)

loader.titleSprite = baseSprites.walk
loader.loadoutColor = Color.fromRGB(79, 99, 189)
loader.loadoutSprite = sprites.loadout
loader.endingQuote = "..and so she left, ready to rebuild her life, brick by brick."

loader:addCallback("init", function(player)
	local p = player:getAccessor()
	local data = player:getData()
	player:setAnimations(baseSprites)
    player:survivorSetInitialStats(160, 12, 0.02)
	player:set("armor", 20)
	p.z_again = -1
	p.z_count = 0
	data.fist = -1
	data.superPunchPhase = 0
	data.superPunchCharge = 0
	local fistController = graphics.bindDepth(player.depth + 1, DrawFist)
	fistController:getData().parent = player
end)

loader:addCallback("levelUp", function(player)
	player:survivorLevelUpStats(48, 3, 0.005, 2)
end)

loader:addCallback("scepter", function(player)
	Loadout.Upgrade(loadout, player, "Special")
end)

callback.register("onPlayerStep", function(player)
	if player:getSurvivor() == loader then
		TrackVelocity(player)
		if loadout:getCurrentSkill("Secondary").obj == grapple or loadout:getCurrentSkill("Secondary").obj == spikeFist then
			FistStep(player)
		end
		if loadout:getCurrentSkill("Utility").obj == superPunch then
			SuperPunchStep(player, false)
			SuperPunchInputStep(player, false)
			if not player:getData().punchHandler then
				player:getData().punchHandler = graphics.bindDepth(player.depth + 1, SuperPunchDraw)
				player:getData().punchHandler:getData().parent = player
			end
		end
		if loadout:getCurrentSkill("Utility").obj == instantPunch then
			SuperPunchStep(player, true)
			SuperPunchInputStep(player, true)
			if not player:getData().punchHandler then
				player:getData().punchHandler = graphics.bindDepth(player.depth + 1, SuperPunchDraw)
				player:getData().punchHandler:getData().parent = player
			end
		end
	end
end)

Loadout.RegisterSurvivorID(loader)


---------------------------------------------

local classicUnlock = Achievement.new("unlock_loader_skin1")
classicUnlock.requirement = 1
classicUnlock.sprite = MakeAchievementIcon(sprites.palettes, 2)
classicUnlock.unlockText = "New skin: \'Classic\' unlocked."
classicUnlock.highscoreText = "Commando: \'Classic\' unlocked"
classicUnlock.description = "Loader: Obliterate yourself at the Obelisk on Monsoon difficulty."
classicUnlock.deathReset = false
classicUnlock:addCallback("onComplete", function()
	loadout:getSkillEntry(s_classic).locked = false
	Loadout.Save(loadout)
end)


return loader
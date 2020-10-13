--RoR2 Demake Project
--Made by Sivelos
--novaOnHeal.lua
--File created 2019/05/13

local novaOnHeal = Item("N'Kuhana's Opinion")
novaOnHeal.pickupText = "Fire haunting skulls when healed."


novaOnHeal.sprite = restre.spriteLoad("Graphics/novaOnHeal", 1, 16, 16)


novaOnHeal:setTier("rare")
novaOnHeal:setLog{
	group = "rare",
	description = "Store healing as &g&Soul Energy&!&. When Soul Energy hits &y&10% of your HP&!&, fire &p&Soul Bullets&!& for &y&100%&!& of your Soul Energy.",
	story = "We've done it. It was only for an instant, but she was with us. If we can bring her back, we may be able to extend the time she has in our world. Her Concepts... Her divine embrace will spread throughout space. The future is looking bright.\n\nWeshan.",
	destination = "Tomb 1661,\nBurial Site,\nVenus",
	date = "10/2/2056"
}
local players = ParentObject.find("actors", "vanilla")
local enemies = ParentObject.find("enemies", "vanilla")

local Projectile = require("Libraries.Projectile")

local skullSprites = {
	idle = Sprite.load("Graphics/skull", 1, 7, 3),
	impact = Sprite.load("Graphics/novaImpact", 4, 9, 9)
}

local skullProjectile = Projectile.new({
	sprite = skullSprites.idle,
	vx = 0,
	vy = -2,
	life = 30*60,
	damage = 1,
	deathsprite_life = skullSprites.idle,
	deathsprite_hit = skullSprites.impact,
	deathsprite_collision = skullSprites.idle,
	ghost = true,
	rotate = 5,
	multihit = false,
	pierce = false,
})

local skullSounds = {
	fire = Sound.find("JarSouls", "vanilla"),
	impact = Sound.find("GiantJellyExplosion", "vanilla"),
}

local skullFire = ParticleType.new("Soul Fire")
skullFire:shape("Disc")
skullFire:color(Color.WHITE, Color.fromRGB(0, 255, 0))
skullFire:alpha(1, 0)
skullFire:additive(true)
skullFire:size(0.1, 0.1, -0.005, 0.0001)
skullFire:angle(0, 360, 0.1, 0, true)
skullFire:life(30, 30)

skullProjectile:addCallback("step", function(self)
	if self:isValid() then
		if self:get("Projectile_dead") <= 0 then
			skullFire:burst("middle", self.x, self.y, 1)
			local parent = nil
			for _, player in ipairs(players:findMatching("id", self:get("Projectile_parent"))) do
				parent = player
			end
			local closestEnemy = enemies:findNearest(self.x, self.y) or nil
			if closestEnemy ~= nil then
				if closestEnemy:isValid() then
					Projectile.aim(self, enemies:findNearest(parent.x or self.x, parent.y or self.y), true)
				end
			end
		else
			skullSounds.impact:play(0.8 + math.random() * 0.2)
		end
	end
end)

registercallback("onPlayerInit", function(player)
	player:set("soulEnergy", 0)
end)

registercallback("onPlayerStep", function(player)
	local playerA = player:getAccessor()
	if player:countItem(novaOnHeal) > 0 then	
		local playerMaxHP = playerA.maxhp
		local hpDifference = (playerA.hp - playerA.lastHp)
		if hpDifference > 0 then
			playerA.soulEnergy = playerA.soulEnergy + ((hpDifference - playerA.hp_regen) * player:countItem(novaOnHeal))
		end
		if playerA.soulEnergy >= (playerMaxHP / 10) then
			
			skullSounds.fire:play(0.8 + math.random() * 0.2)
			local proj = Projectile.fire(skullProjectile, player.x, player.y, player, 1)
			Projectile.configure(proj,
		 {
			 damage = playerA.soulEnergy / playerA.damage
		 })
		 	playerA.soulEnergy = 0
		end
	end
end)
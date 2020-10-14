local p_actors = ParentObject.find("actors", "Vanilla")

local constants = {
	color = Color.fromRGB(0, 184, 198),
	alpha_base = 0.7,
	alpha_random = 0.3,
}

local sounds = {
	shield = Sound.find("Shield", "Vanilla"),
}

callback.register("onStep", function()
	for _,i_actor in ipairs(p_actors:findAll()) do
		if not isa(i_actor, "PlayerInstance") then
			local ac = i_actor:getAccessor()
			if ac.shield_cooldown >= 0 then
				ac.shield_cooldown = ac.shield_cooldown - 1
			elseif ac.shield < ac.maxshield then
				sounds.shield:play(1, 1)
				ac.shield = ac.maxshield
			end
		end
	end
end)

callback.register("onDraw", function()
	for _,i_actor in ipairs(p_actors:findAll()) do
		if i_actor:get("shield") > 0 then
			graphics.setBlendMode("additive")
			graphics.drawImage{
				image = i_actor.sprite,
				x = i_actor.x,
				y = i_actor.y,
				subimage = i_actor.subimage,
				color = constants.color,
				alpha = constants.alpha_base + constants.alpha_random * math.random(),
				angle = i_actor.angle,
				--xscale = i_actor.xscale,
				--yscale = i_actor.yscale,
				width = i_actor.sprite.width + 2,
				height = i_actor.sprite.height + 2,
			}
			graphics.setBlendMode("normal")
		end
	end
end)

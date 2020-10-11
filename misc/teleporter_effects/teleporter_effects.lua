local o_teleporter = Object.find("Teleporter", "Vanilla")
local o_player = Object.find("P", "Vanilla")
local o_flash = Object.find("WhiteFlash", "Vanilla")

local constants = {
	alpha_rate = 0.01,
	alpha_max = 0.5,
	volume_random = 0.05,
}

local sprites = {
	sparks = restre_spriteLoad("tpSparks", 8, 6, 4),
}

local sounds = {
	tp       = Sound.find("Teleporter", "Vanilla"),

	complete = restre_soundLoad("tpActivate.ogg"),
	activate = restre_soundLoad("tpCharge.ogg"),
}

local sparks = ParticleType.new("TeleporterSparks")
sparks:sprite(sprites.sparks, true, true, false)
sparks:additive(true)
sparks:life(15, 15)
sparks:angle(0, 360, 0, 0, false)

callback.register("onStep", function()
	for _,i_teleporter in ipairs(o_teleporter:findAll()) do
		local data = i_teleporter:getData()

		local prev_active, active = data.prev_active, i_teleporter:get("active")
		if prev_active ~= active then
			if active == 1 then
				data.time = 0
				data.alpha = 0
				data.target = constants.alpha_max
				data.beam = false
				data.init = true
				sounds.activate:play(1 + math.random() * constants.volume_random)
			elseif active == 2 or active == 3 then
				if data.alpha > 0 then
					o_flash:create(i_teleporter.x, i_teleporter.y)
					sounds.tp:play(1 + math.random() * constants.volume_random)
					data.target = 0
				end
			elseif active == 4 then
				sounds.complete:play(1 + math.random() * constants.volume_random)
			end
		end
		data.prev_active = active

		if data.target then
			local remain = data.target - data.alpha
			local step = math.sign(remain) * constants.alpha_rate
			if math.abs(step) >= math.abs(remain) then
				data.alpha = data.target
				if step > 0 then
					data.beam = true
					o_flash:create(i_teleporter.x, i_teleporter.y)
					sounds.tp:play(1 + math.random() * constants.volume_random)
				end
				data.target = nil
			else
				data.alpha = data.alpha + step
			end
		end

		if data.time then
			data.time = data.time + 1
		end
	end
end)

callback.register("onDraw", function()
	for _,i_teleporter in ipairs(o_teleporter:findAll()) do
		local data = i_teleporter:getData()
		if data.init and data.alpha > 0 then
			local active = i_teleporter:get("active")

			if data.time % 15 == 0 then
				sparks:burst(
					"above",
					i_teleporter.x + (math.random() - 1/2) * i_teleporter.sprite.width,
					i_teleporter.y + (math.random() - 1/2) * i_teleporter.sprite.height,
					1,
					Color.RED
				)
			end

			graphics.setBlendMode("additive")
			graphics.alpha(data.alpha)

			local inner_r, outer_r, wave = 3, 5, 3
			if data.beam then
				inner_r, outer_r, wave = 4, 6, 10
			end

			local x, y, o = i_teleporter.x, i_teleporter.y - i_teleporter.sprite.height * (2/5), 1.5

			graphics.color(Color.RED)
			graphics.circle(x - o, y, outer_r + math.sin(data.time) / wave)

			graphics.color(Color.ROR_RED)
			graphics.circle(x - o, y, inner_r + math.cos(data.time) / wave)

			if data.beam then
				graphics.color(Color.RED)
				graphics.line(x, y, x, 0, 3)

				graphics.color(Color.ROR_RED)
				graphics.line(x, y, x, 0, 1)
			end

			graphics.setBlendMode("normal")
		end
	end
end)

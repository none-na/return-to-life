--RoR2 Demake Project
--Made by Sivelos
--hud.lua
--File created 2019/05/14

local hud = Item("Ocular HUD")
hud.pickupText = "Gain 100% Critical Strike chance for 8 seconds."

hud.sprite = Sprite.load("Items/use/Graphics/hud.png", 2, 14, 16)

hud.isUseItem = true
hud.useCooldown = 60

hud:setTier("use")
hud:setLog{
    group = "use",
    description = "Gain &y&100% Critical Strike&!& chance for &y&8 seconds&!&.",
    story = "You're trying my patience now. I had to smuggle this out of a military research lab, and I'm pretty sure I was followed. This thing is state of the art, and you're going to use it for... What again? Online videos? Fine, whatever. Make sure to credit me for getting you this when I'm rotting in prison.",
    destination = "Royal Drive,\nBubble Station,\nMars",
    date = "4/20/2056"
}

local hudActivationSnd = Sound.find("Drone1Spawn", "vanilla")

local critBuff = Buff.new("Ocular HUD")
critBuff.sprite = Sprite.load("hudBuffSpr", "Graphics/hudBuff", 1, 5, 3)

local hudFX = ParticleType.new("Ocular HUD FX")
hudFX:life(5,5)
hudFX:alpha(0.25)
hudFX:additive(true)

critBuff:addCallback("start", function(player)
    player:set("critical_chance", player:get("critical_chance") + 100)
end)

critBuff:addCallback("step", function(player)
    hudFX:sprite(player.sprite, false, false, true)
    hudFX:scale(math.random(0.8, 1.2) * player.xscale, math.random(0.8, 1.2) * player.yscale)
    hudFX:burst("above", player.x, player.y, 1, Color.RED)
end)

critBuff:addCallback("end", function(player)
    player:set("critical_chance", player:get("critical_chance") - 100)
end)

hud:addCallback("use", function(player, embryo)
    hudActivationSnd:play(1 + math.random() * 0.3)
    local playerA = player:getAccessor()
	local count = 1
	if embryo then
		count = 2
	end
    player:applyBuff(critBuff, 8*60*count)
end)

GlobalItem.items[hud] = {
    use = function(inst, embryo)
        hudActivationSnd:play(1 + math.random() * 0.3)
        local count = 1
        if embryo then
            count = 2
        end
        inst:applyBuff(critBuff, 8*60*count)
    end,
}
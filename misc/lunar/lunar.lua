local constants = {
	color = Color.fromRGB(128, 142, 255),
	coin_chance = 0.5/100,  -- 0.5%
	max_buds = 5,
	bud_chance = 5,
	max_shrine = 5,
	shrine_chance = 30,
}

local sprites = {
	money   = Sprite.find("Money", "Vanilla"),

	coin = restre_spriteLoad("lunarCoin", 1, 10, 10),
	coin_ui = restre_spriteLoad("coinUI", 1, 2, 11),
}

local sounds = {
	drop = Sound.find("Revive", "Vanilla")
}

-- Lunar Coin API
local Lunar = {}
do
	local lunar_coins = save.read("lunar_coins") or 0

	Lunar.isLocal = function(player)
		return not net.online or player == net.localPlayer
	end

	Lunar.get = function(player)
		if not player then return lunar_coins end
		--return player:getData().lunar_coins or 0
	end

	Lunar.set = function(coins, player)
		-- It should be able to take nil as player but it's safer this way
		if not Lunar.isLocal(player) then
			error("Modification of non-local coins")
		end
		lunar_coins = coins
		save.write("lunar_coins", lunar_coins)
	end

	Lunar.shift = function(coins, player)
		Lunar.set(Lunar.get(player) + coins, player)
	end
	Lunar.give = function(coins, player)
		Lunar.shift(coins, player)
	end
	Lunar.remove = function(coins, player)
		Lunar.shift(-coins, player)
	end
end

registercallback("onHUDDraw", function()
	if misc.hud:get("show_gold") == 1 then
		local w, h = graphics.getGameResolution()
		local coins = Lunar.get()
		graphics.drawImage{
			image = sprites.coin_ui,
			x = 13,
			y = (sprites.money.height * 2) + 5,
		}
		graphics.color(Color.WHITE)
		graphics.printColor(
			tostring(coins),
			13 + sprites.coin_ui.width,
			(sprites.money.height * 2) - 1,
			graphics.FONT_MONEY
		)
	end
end)

local lunar_pool = ItemPool.new("Lunar")
lunar_pool.ignoreEnigma = false

-- Lunar Item API
local LunarItem = {}
do
	local is_lunar = {}

	LunarItem.register = function(item, skip_pool)
		is_lunar[item] = true
		if not skip_pool then
			lunar_pool:add(item)
		end
	end
end

-- TODO register pool

local lunarcoin = Item.new("LunarCoin")
lunarcoin.displayName = "Lunar Coin"
lunarcoin.pickupText = "A strange currency. Maybe you can use it somewhere...?"
lunarcoin.sprite = sprites.coin
lunarcoin.color = constants.color

lunarcoin:addCallback("pickup", function(player)
	if Lunar.isLocal(player) then
		Lunar.give(1)
		player:removeItem(lunarcoin)
	end
end)

callback.register("onNPCDeath", function(i_actor)
	if net.host then
		if math.chance(constants.coin_chance * 100) then
			sounds.drop:play(1)
			lunarcoin:create(i_actor.x, i_actor.y)
		end
	end
end)

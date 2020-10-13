local constants = {
	color = Color.fromRGB(128, 142, 255),

	coin_chance = 0.5/100,  -- 0.5%

	bud_base = 1,
	bud_spawncost = 100,

	shrine_base = 1,
	shrine_spawncost = 320,
}

local sprites = {
	money   = Sprite.find("Money", "Vanilla"),

	coin    = restre_spriteLoad("lunarCoin", 1, 10, 10),
	coin_ui = restre_spriteLoad("coinUI", 1, 2, 11),
	bud     = restre_spriteLoad("lunarBud", 5, 10, 14),
	shrine  = restre_spriteLoad("orderShrine", 6, 10, 28),
}

local sounds = {
	drop   = Sound.find("Revive", "Vanilla"),
	bud    = Sound.find("Chest0", "Vanilla"),
	shrine = Sound.find("Shrine1", "Vanilla"),

	obliterate = restre_soundLoad("eradicate")
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

local lunar_pool = ItemPool.new("lunar")
lunar_pool.ignoreEnigma = false


-- Lunar Item API

local LunarItem = {}
local order_pools = {}
do
	local is_lunar = {}

	LunarItem.register = function(item, skip_pool)
		is_lunar[item] = true
		if not skip_pool then
			lunar_pool:add(item)
		end
	end

	callback.register("onItemInit", function(i_item)
		if is_lunar[i_item:getItem()] then
			i_item:getData().lunar = true
		end
	end)

	local function giveItem(player, item)
		if item.isUseItem then
			local old_item = player.useItem
			player.useItem = item
			if old_item then
				old_item:create(player.x, player.y - player.mask.height)
			end
		else
			player:giveItem(item)
		end
	end

	local function syncGiveItem(player, item)
		if not net.online then
			giveItem(player, item)
		else
		end
	end

	local p_item = ParentObject.find("items")
	local o_player = Object.find("P", "Vanilla")
	callback.register("onStep", function()
		for _,i_item in ipairs(p_item:findAll()) do
			local data = i_item:getData()
			if data.lunar then
				i_item:setAlarm(0, i_item:getAlarm(0) + 1)
				local player = o_player:findNearest(i_item.x, i_item.y)
				if player:collidesWith(i_item, player.x, player.y) then
					if player:control("enter") == input.PRESSED then
						syncGiveItem(player, i_item:getItem())
						i_item:destroy()
					end
				end
			end
		end
	end)

	LunarItem.orderPool = function(pool)
		table.insert(order_pools, pool)
	end

	local boss_pool = ItemPool.new("ShrineOfOrderBossPool")
	local items = {
		"Burning Witness",
		"Colossal Knurl",
		"Ifrit's Horn",
		"Imp Overlord's Tentacle",
		"Legendary Spark",
		"Nematocyst Nozzle",
	}
	for _,name in ipairs(items) do
		local item = Item.find(name, "Vanilla")
		boss_pool:add(item)
	end

	local pools = {
		"common",
		"uncommon",
		"rare",
	}
	for _,name in ipairs(pools) do
		local pool = ItemPool.find(name, "Vanilla")
		LunarItem.orderPool(pool)
	end
	LunarItem.orderPool(boss_pool)
	LunarItem.orderPool(lunar_pool)
end

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


-- Lunar Bud

local lunarbud_smoke = ParticleType.find("Dust2", "Vanilla")
local command = Artifact.find("Command", "Vanilla")

local lunarbud = Object.base("Chest", "LunarBud")
lunarbud.sprite = sprites.bud

lunarbud:addCallback("create", function(i_lunarbud)
	i_lunarbud:set("cost", constants.bud_base)
	i_lunarbud:set("text", "to open the Lunar Pod")
	i_lunarbud:set("sound", sounds.bud.id)
end)

lunarbud:addCallback("step", function(i_lunarbud)
	if net.host then
		if i_lunarbud:getAlarm(0) == 1 then
			local object = command.active and lunar_pool:getCrate() or lunar_pool:roll()
			object:create(i_lunarbud.x, i_lunarbud.y - i_lunarbud.sprite.height)
		end
	end
end)

lunarbud:addCallback("draw", function(i_lunarbud)
	if i_lunarbud:get("active") > 1 then return nil end
	lunarbud_smoke:burst(
		"below",
		i_lunarbud.x + (math.random() - 1/2) * i_lunarbud.sprite.width / 2,
		i_lunarbud.y,
		1
	)
end)

local lunarbud_interactable = Interactable.new(lunarbud, "LunarBudInteractable")
lunarbud_interactable.spawnCost = constants.bud_spawncost

for _,stage in ipairs(Stage.findAll("Vanilla")) do
	stage.interactables:add(lunarbud_interactable)
end


-- Shrine of Order

local function sequence(player)
	for _,pool in ipairs(order_pools) do
		local items = {}
		local counts = {}
		for _,item in ipairs(pool:toList()) do
			if not item.isUseItem then
				local count = player:countItem(item)
				if count > 0 then
					table.insert(items, item)
					table.insert(counts, count)
				end
			end
		end

		local item = table.irandom(items)

		if item then
			local total = 0
			for i,item in ipairs(items) do
				local count = counts[i]
				total = total + count
				player:removeItem(item, count)
			end

			player:giveItem(item, total)
		end
	end
end

local shrineorder = Object.base("Chest", "ShrineOfOrder")
shrineorder.sprite = sprites.shrine

shrineorder:addCallback("create", function(i_shrineorder)
	i_shrineorder:set("cost", constants.shrine_base)
	i_shrineorder:set("text", "to be sequenced")
	i_shrineorder:set("sound", sounds.shrine.id)
end)

shrineorder:addCallback("step", function(i_shrineorder)
	if i_shrineorder:getAlarm(0) == 1 then
		local player = Object.findInstance(i_shrineorder:get("activator"))
		if isa(player, "PlayerInstance") then
			sequence(player)
		end
	end
end)

local shrineorder_interactable = Interactable.new(shrineorder, "ShrineOfOrderInteractable")
shrineorder_interactable.spawnCost = constants.shrine_spawncost

for _,stage in ipairs(Stage.findAll("Vanilla")) do
	stage.interactables:add(shrineorder_interactable)
end


-- Export

export("Lunar", LunarItem)
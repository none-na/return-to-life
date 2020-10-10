if (modloader.checkMod("Starstorm") or modloader.checkMod("rorsd")) then
	return nil
end

local TITLE_GROUND = 254
local OFFSET = 264 - 250

local sprites = {
	sos        = Sprite.find("SOS", "Vanilla"),
	teleporter = Sprite.find("Teleporter", "Vanilla"),
	acrid      = Sprite.find("FeralCage", "Vanilla"),
	prov       = Sprite.find("Boss1Idle", "Vanilla"),
	lizard     = Sprite.find("LizardIdle", "Vanilla"),
	scavenger  = Sprite.find("ScavengerIdle", "Vanilla"),
	golem      = Sprite.find("GolemIdle", "Vanilla"),
	wisp       = Sprite.find("WispIdle", "Vanilla"),
	wispg      = Sprite.find("WispGIdle", "Vanilla"),
	warbanner  = Sprite.find("EfWarbanner", "Vanilla"),
	chest1     = Sprite.find("Chest1", "Vanilla"),
	chest2     = Sprite.find("Chest2", "Vanilla"),
	chest5     = Sprite.find("Chest5", "Vanilla"),
	barrel1    = Sprite.find("Barrel1", "Vanilla"),
	barrel2    = Sprite.find("Barrel2", "Vanilla"),
	dancegolem = Sprite.find("DancingGolem", "Vanilla"),

	title      = restre_spriteLoad("title", 1, 205, 46+10),
	ground     = restre_spriteLoad("groundStrip", 1, 0, 0),
	stars      = restre_spriteLoad("titleScreen", 1, 0, 0),
	level      = restre_spriteLoad("titleLevel", 1, 960, 264 - OFFSET),
	commando   = restre_spriteLoad("commandoPod", 1, 63, 50),
	bandit     = restre_spriteLoad("bandit", 1, 4, 15),
	merc       = restre_spriteLoad("mercenary", 2, 4, 10),
	engi       = restre_spriteLoad("engineer", 12, 15, 23),
	chef       = restre_spriteLoad("chef", 8, 11, 23),
	enforcer   = restre_spriteLoad("enforcer", 1, 5, 13),
	hand       = restre_spriteLoad("hand", 1, 13, 30),
	boulder    = restre_spriteLoad("boulders", 3, 15, 15),
}

local props = {
	-- Boulder A
	{
		chance = 1,
		sprite = sprites.boulder,
		animated = false,
		xscales = { 1, -1 },
		consistentScale = true,
		subimages = { 1, 2, 3 },
		places = {
			{ x = 585 + 280, y = TITLE_GROUND - (2 * 16) }
		}
	},

	-- Boulder B
	{
		chance = 1,
		sprite = sprites.boulder,
		animated = false,
		xscales = { 1, -1 },
		consistentScale = true,
		subimages = { 1, 2, 3 },
		places = {
			{ x = 585 + 436, y = TITLE_GROUND }
		}
	},

	-- Commando Pod
	{
		chance = 1,
		sprite = sprites.commando,
		animated = true,
		xscales = { 1 },
		consistentScale = true,
		places = {
			{ x = 585 + 491, y = TITLE_GROUND }
		}
	},

	-- Enforcer Shield
	{
		chance = 0.5,
		sprite = sprites.enforcer,
		animated = true,
		xscales = { 1 },
		consistentScale = true,
		places = {
			{ x = 585 + 485, y = TITLE_GROUND }
		}
	},

	-- HAN-D
	{
		chance = 0.5,
		sprite = sprites.hand,
		animated = true,
		xscales = { 1 },
		consistentScale = true,
		places = {
			{ x = 585 + 250, y = TITLE_GROUND }
		}
	},

	-- Bandit
	{
		chance = 0.5,
		sprite = sprites.bandit,
		animated = true,
		xscales = { 1 },
		consistentScale = true,
		places = {
			{ x = 585 + 500, y = TITLE_GROUND }
		}
	},

	-- Mercenary
	{
		chance = 0.5,
		sprite = sprites.merc,
		animated = true,
		xscales = { 1 },
		consistentScale = true,
		places = {
			{ x = 585 + 395, y = TITLE_GROUND - (sprites.sos.height - 2) }
		}
	},

	-- Engineer
	{
		chance = 0.5,
		sprite = sprites.engi,
		animated = true,
		xscales = { 1 },
		consistentScale = true,
		places = {
			{ x = 585 + 450, y = TITLE_GROUND }
		}
	},

	-- CHEF
	{
		chance = 0.5,
		sprite = sprites.chef,
		animated = true,
		xscales = { 1 },
		consistentScale = true,
		places = {
			{ x = 585 + 300, y = TITLE_GROUND }
		}
	},

	-- Teleporter
	{
		chance = 1,
		sprite = sprites.teleporter,
		animated = false,
		xscales = { 1, -1 },
		consistentScale = true,
		subimages = { 7, 7, 7, 6, 7 },
		places = {
			{ x = 585 + 324, y = TITLE_GROUND - 32 }
		}
	},

	-- Radio Tower
	{
		chance = 1,
		sprite = sprites.sos,
		animated = true,
		xscales = { 1 },
		consistentScale = true,
		places = {
			{ x = 585 + 395, y = TITLE_GROUND }
		}
	},

	-- Acrid
	{
		chance = 0.5,
		sprite = sprites.acrid,
		animated = false,
		xscales = { 1 },
		subimages = { sprites.acrid.frames, 1, 9, 16 },
		consistentScale = true,
		places = {
			{ x = 585 + 560, y = TITLE_GROUND - (sprites.acrid.height / 2) + 4 }
		}
	},

	-- Providence
	{
		chance = 0.0001,
		sprite = sprites.prov,
		animated = true,
		xscales = { 1 },
		consistentScale = true,
		places = {
			{ x = 585 + 300, y = TITLE_GROUND - 48 }
		}
	},

	-- Lemurian
	{
		chance = 0.1,
		sprite = sprites.lizard,
		animated = true,
		xscales = { 1, -1 },
		consistentScale = false,
		places = {
			{ x = 585 + 137, y = TITLE_GROUND - (sprites.lizard.height / 2) },
			{ x = 585 + 550, y = TITLE_GROUND - (sprites.lizard.height / 2) },
		}
	},

	-- Scav
	{
		chance = 0.01,
		sprite = sprites.scavenger,
		animated = true,
		xscales = { 1, -1 },
		consistentScale = false,
		places = {
			{ x = 585 + 110, y = TITLE_GROUND - (sprites.scavenger.height / 2) }
		}
	},

	-- Golem
	{
		chance = 0.01,
		sprite = sprites.golem,
		animated = true,
		xscales = { 1, -1 },
		consistentScale = false,
		places = {
			{ x = 585 + 224, y = TITLE_GROUND - (sprites.golem.height / 2) },
			{ x = 585 + 592, y = TITLE_GROUND - (sprites.golem.height / 2) - (16 * 5) },
		}
	},

	-- Wisp
	{
		chance = 0.08,
		sprite = sprites.wisp,
		animated = true,
		xscales = { 1, -1 },
		consistentScale = true,
		places = {
			{ x = 585 + 218, y = TITLE_GROUND - (sprites.wisp.height / 2) }
		}
	},

	-- Greater Wisp
	{
		chance = 0.005,
		sprite = sprites.wispg,
		animated = true,
		xscales = { 1, -1 },
		consistentScale = true,
		places = {
			{ x = 585 + 80, y = TITLE_GROUND - (sprites.wispg.height / 2) }
		}
	},

	-- Warbanner
	{
		chance = 0.65,
		sprite = sprites.warbanner,
		animated = false,
		subimages = { 5 },
		xscales = { 1 },
		consistentScale = true,
		places = {
			{ x = 585 + 520, y = TITLE_GROUND }
		}
	},

	-- Chest1 A
	{
		chance = 0.8,
		sprite = sprites.chest1,
		animated = false,
		xscales = { 1, -1 },
		consistentScale = true,
		subimages = { 1, sprites.chest1.frames },
		places = {
			{ x = 585 + 150, y = TITLE_GROUND }
		}
	},

	-- Chest1 B
	{
		chance = 0.7,
		sprite = sprites.chest1,
		animated = false,
		xscales = { 1, -1 },
		consistentScale = true,
		subimages = { 1, sprites.chest1.frames },
		places = {
			{ x = 585 + 471, y = TITLE_GROUND }
		}
	},

	-- Chest1 C
	{
		chance = 0.7,
		sprite = sprites.chest1,
		animated = false,
		xscales = { 1, -1 },
		consistentScale = true,
		subimages = { 1, sprites.chest1.frames },
		places = {
			{ x = 585 + 630, y = TITLE_GROUND }
		}
	},

	-- Chest2 A
	{
		chance = 0.6,
		sprite = sprites.chest2,
		animated = false,
		xscales = { 1, -1 },
		consistentScale = true,
		subimages = { 1, sprites.chest2.frames },
		places = {
			{ x = 585 + 324, y = TITLE_GROUND }
		}
	},

	-- Chest2 B
	{
		chance = 0.5,
		sprite = sprites.chest2,
		animated = false,
		xscales = { 1, -1 },
		consistentScale = true,
		subimages = { 1, sprites.chest2.frames },
		places = {
			{ x = 585 + 165, y = TITLE_GROUND }
		}
	},

	-- Chest5
	{
		chance = 0.3,
		sprite = sprites.chest5,
		animated = false,
		xscales = { 1, -1 },
		consistentScale = true,
		subimages = { 1 },
		places = {
			{ x = 585 + 112, y = TITLE_GROUND - (7 * 16) }
		}
	},

	-- Barrel1
	{
		chance = 0.7,
		sprite = sprites.barrel1,
		animated = false,
		xscales = { 1, -1 },
		consistentScale = true,
		subimages = { 1, sprites.barrel1.frames },
		places = {
			{ x = 585 + 130, y = TITLE_GROUND }
		}
	},

	-- Barrel2
	{
		chance = 0.5,
		sprite = sprites.barrel2,
		animated = false,
		xscales = { 1, -1 },
		consistentScale = true,
		subimages = { 1, sprites.barrel2.frames },
		places = {
			{ x = 585 + 603, y = TITLE_GROUND }
		}
	},

	-- Hit it Son
	{
		chance = 0.0001,
		sprite = sprites.dancegolem,
		animated = true,
		xscales = { 1 },
		consistentScale = true,
		places = {
			{ x = 585 + 528, y = TITLE_GROUND - (sprites.dancegolem.height / 2) }
		}
	},
}

local function GenerateTitle()
	local title = {}
	title.frames = 1
	title.objects = {}
	title.subimages = {}
	title.positions = {}
	title.xscales = {}

	for _, prop in pairs(props) do
		if math.chance(prop.chance * 100) then
			table.insert(title.objects, prop)
			if prop.animated then
				title.frames = title.frames + prop.sprite.frames
			else
				title.subimages[prop] = table.irandom(prop.subimages)
			end
			title.positions[prop] = table.irandom(prop.places)
			if prop.consistentScale then
				title.xscales[prop] = table.irandom(prop.xscales)
			end
		end
	end

	return title
end


local title = nil
local title_surface = nil
local function ValidateTitle()
	if title == nil then
		title = GenerateTitle()
	end

	if Surface.isValid(title_surface) then return nil end
	if title_surface ~= nil then
		title_surface:free()
	end
	title_surface = Surface.new(sprites.level.width, sprites.level.height)
end
local function DrawTitle(title, frame)
	local frame = (frame / 4) % title.frames
	local xoff, yoff = sprites.level.width / 2, sprites.level.height / 2

	sprites.level:draw(xoff, yoff)

	for _, prop in ipairs(title.objects) do
		local subimage = prop.animated and ((frame % prop.sprite.frames) + 1) or title.subimages[prop]
		local pos = title.positions[prop]
		local xscale = 1
		if prop.xscale then
			xscale = title.xscales[prop] or table.random(prop.xscales)
		end
		graphics.drawImage{
			image = prop.sprite,
			subimage = subimage,
			x = pos.x,
			y = pos.y + OFFSET,
			xscale = xscale,
		}
	end

	return surface
end

local time = 0 ; callback.register("globalStep", function() time = time + 1 end)
local painter = nil
local ROOM_START = Room.find("Start", "Vanilla")
local TITLE_MUSIC = restre_soundLoad("main_theme.ogg")
callback.register("globalRoomStart", function(room)
	if room ~= ROOM_START then return nil end
	Sound.setMusic(TITLE_MUSIC)
	if painter == nil or not painter:isValid() then
		painter = graphics.bindDepth(2^32, function()
			ValidateTitle()
			graphics.setTarget(title_surface)
			DrawTitle(title, time)
			graphics.resetTarget()

			local w, h = graphics.getHUDResolution()
			graphics.drawImage{
				image = title_surface,
				x = (w - title_surface.width) / 2, y = h - title_surface.height * (2/3)
			}
		end)
	end
end)

local ORIGINAL_TITLE = Sprite.find("sprTitle", "Vanilla")
--local ORIGINAL_GROUND = Sprite.find("GroundStrip", "Vanilla")
local ORIGINAL_BACKGROUND = Sprite.find("TitleScreen", "Vanilla")
local function ApplyNewTitle()
		ORIGINAL_TITLE:replace(sprites.title)
		--ORIGINAL_GROUND:replace(Sprite.find("Empty"))
		ORIGINAL_BACKGROUND:replace(sprites.stars)
		title = GenerateTitle()
end

callback.register("onGameEnd", function()
	ApplyNewTitle()
end)

callback.register("postLoad", function()
	ApplyNewTitle()
end, -2^32)

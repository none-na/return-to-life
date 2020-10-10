-- Reskin Title
local titleRoom = Room.find("Start", "vanilla")

local titles = {}
local titleSprites = {
    title = Sprite.load("ror2Title", "Graphics/UI/title", 1, 205, 46+10),
    ground = Sprite.load("ror2GroundStrip", "Graphics/UI/groundStrip", 1, 0, 0),
    stars = Sprite.load("ror2TitleScreen", "Graphics/UI/titleScreen", 1, 0, 0),
    level = Sprite.load("ror2TitleLevel", "Graphics/UI/titleLevel", 1, 960, 264),
    commando = Sprite.load("Graphics/ui/vibin", 1, 63, 50),
    bandit = Sprite.load("Graphics/ui/snoozin", 1, 4, 15),
    merc = Sprite.load("Graphics/ui/ontheprowl", 2, 4, 10),
    engi = Sprite.load("Graphics/ui/workin", 12, 15, 23),
    chef = Sprite.load("Graphics/ui/pizzapastaputitinabox", 8, 11, 23),
    enforcer = Sprite.load("Graphics/ui/rip", 1, 5, 13),
    hand = Sprite.load("Graphics/ui/iamhandandihaveabigfuckinghammer", 1, 13, 30),
    boulder = Sprite.load("Graphics/boulders", 3, 15, 15)
}
local titleGround = 254

local titleObjects = {
    {
        -- Boulder
        chance = 0,
        sprite = titleSprites.boulder,
        animated = false,
        xscales = {[1] = 1, [2] = -1},
        consistentScale = true,
        subimages = {[1] = 1, [2] = 2, [3] = 3},
        places = {[1] = {x = 585 + 280, y = titleGround - (2*16)} }
    },
    {
        -- Boulder
        chance = 0,
        sprite = titleSprites.boulder,
        animated = false,
        xscales = {[1] = 1, [2] = -1},
        consistentScale = true,
        subimages = {[1] = 1, [2] = 2, [3] = 3},
        places = {[1] = {x = 585 + 436, y = titleGround} }
    },
    {
        -- Commando
        chance = 0,
        sprite = titleSprites.commando,
        animated = true,
        xscales = {[1] = 1},
        consistentScale = true,
        places = {[1] = {x = 585 + 491, y = titleGround}}
    },
    {
        -- Shield
        chance = 0.5,
        sprite = titleSprites.enforcer,
        animated = true,
        xscales = {[1] = 1},
        consistentScale = true,
        places = {[1] = {x = 585 + 485, y = titleGround}}
    },
    
    {
        -- HAN-D
        chance = 0.5,
        sprite = titleSprites.hand,
        animated = true,
        xscales = {[1] = 1},
        consistentScale = true,
        places = {[1] = {x = 585 + 250, y = titleGround}}
    },
    {
        -- Bandit
        chance = 0.5,
        sprite = titleSprites.bandit,
        animated = true,
        xscales = {[1] = 1},
        consistentScale = true,
        places = {[1] = {x = 585 + 500, y = titleGround}}
    },
    {
        -- Merc
        chance = 0.5,
        sprite = titleSprites.merc,
        animated = true,
        xscales = {[1] = 1},
        consistentScale = true,
        places = {[1] = {x = 585 + 395, y = titleGround - (Sprite.find("SOS", "vanilla").height - 2)}}
    },
    
    {
        -- Engi
        chance = 0.5,
        sprite = titleSprites.engi,
        animated = true,
        xscales = {[1] = 1},
        consistentScale = true,
        places = {[1] = {x = 585 + 450, y = titleGround}}
    },
    
    {
        -- CHEF
        chance = 0.5,
        sprite = titleSprites.chef,
        animated = true,
        xscales = {[1] = 1},
        consistentScale = true,
        places = {[1] = {x = 585 + 300, y = titleGround}}
    },
    
    {
        -- Teleporter
        chance = 0,
        sprite = Sprite.find("Teleporter", "vanilla"),
        animated = false,
        xscales = {[1] = 1, [2] = -1},
        consistentScale = true,
        subimages = {[1] = 7, [2] = 7, [3] = 7, [4] = 6, [5] = 7},
        places = {[1] = {x = 585 + 324, y = titleGround - (32)}}
    },
    {
        -- Radio Tower
        chance = 0,
        sprite = Sprite.find("SOS", "vanilla"),
        animated = true,
        xscales = {[1] = 1},
        consistentScale = true,
        places = {[1] = {x = 585 + 395, y = titleGround}, }
    },
    
    {
        -- Acrid
        chance = 0.5,
        sprite = Sprite.find("FeralCage", "vanilla"),
        animated = false,
        xscales = {[1] = 1},
        subimages = {[1] = Sprite.find("FeralCage", "vanilla").frames, [2] = 1, [3] = 9, [4] = 16},
        consistentScale = true,
        places = {[1] = {x = 585 + 560, y = titleGround - (Sprite.find("FeralCage", "vanilla").height / 2) + 4}, }
    },
    {
        -- Providence
        chance = 0.9999,
        sprite = Sprite.find("Boss1Idle", "vanilla"),
        animated = true,
        xscales = {[1] = 1},
        consistentScale = true,
        places = {[1] = {x = 585 + 300, y = titleGround - 48}, }
    },
    {
        -- Lemurian
        chance = 0.9,
        sprite = Sprite.find("LizardIdle", "vanilla"),
        animated = true,
        xscales = {[1] = 1, [2] = -1},
        consistentScale = false,
        places = {[1] = {x = 585 + 137, y = titleGround - (Sprite.find("LizardIdle", "vanilla").height /2)}, [2] = {x = 585 + 550, y = titleGround - (Sprite.find("LizardIdle", "vanilla").height /2)}}
    },
    
    {
        -- Scav
        chance = 0.99,
        sprite = Sprite.find("ScavengerIdle", "vanilla"),
        animated = true,
        xscales = {[1] = 1, [2] = -1},
        consistentScale = false,
        places = {[1] = {x = 585 + 110, y = titleGround - (Sprite.find("ScavengerIdle", "vanilla").height /2)}}
    },
    {
        -- Golem
        chance = 0.99,
        sprite = Sprite.find("GolemIdle", "vanilla"),
        animated = true,
        xscales = {[1] = 1, [2] = -1},
        consistentScale = false,
        places = {[1] = {x = 585 + 224, y = titleGround - (Sprite.find("GolemIdle", "vanilla").height /2)}, [2] = {x = 585 + 592, y = titleGround - (Sprite.find("GolemIdle", "vanilla").height /2) - (16 * 5)}}
    },
    {
        -- Wisp
        chance = 0.92,
        sprite = Sprite.find("WispIdle", "vanilla"),
        animated = true,
        xscales = {[1] = 1, [2] = -1},
        consistentScale = true,
        places = {[1] = {x = 585 + 218, y = titleGround - (Sprite.find("WispIdle", "vanilla").height /2)}, }
    },
    {
        -- Greater Wisp
        chance = 0.995,
        sprite = Sprite.find("WispGIdle", "vanilla"),
        animated = true,
        xscales = {[1] = 1, [2] = -1},
        consistentScale = true,
        places = {[1] = {x = 585 + 80, y = titleGround - (Sprite.find("WispIdle", "vanilla").height /2)}, }
    },
    {
        -- Warbanner
        chance = 0.35,
        sprite = Sprite.find("EfWarbanner", "vanilla"),
        animated = false,
        subimages = {[1] = 5},
        xscales = {[1] = 1},
        consistentScale = true,
        places = {[1] = {x = 585 + 520, y = titleGround}, }
    },
    {
        -- Chest
        chance = 0.2,
        sprite = Sprite.find("Chest1", "vanilla"),
        animated = false,
        xscales = {[1] = 1, [2] = -1},
        consistentScale = true,
        subimages = {[1] = 1, [2] = Sprite.find("Chest1", "vanilla").frames},
        places = {[1] = {x = 585 + 150, y = titleGround}, }
    },
    {
        -- Chest
        chance = 0.3,
        sprite = Sprite.find("Chest1", "vanilla"),
        animated = false,
        xscales = {[1] = 1, [2] = -1},
        consistentScale = true,
        subimages = {[1] = 1, [2] = Sprite.find("Chest1", "vanilla").frames},
        places = {[1] = {x = 585 + 471, y = titleGround}, }
    },
    {
        -- Chest
        chance = 0.3,
        sprite = Sprite.find("Chest1", "vanilla"),
        animated = false,
        xscales = {[1] = 1, [2] = -1},
        consistentScale = true,
        subimages = {[1] = 1, [2] = Sprite.find("Chest1", "vanilla").frames},
        places = {[1] = {x = 585 + 630, y = titleGround}, }
    },
    {
        -- Chest 2
        chance = 0.4,
        sprite = Sprite.find("Chest2", "vanilla"),
        animated = false,
        xscales = {[1] = 1, [2] = -1},
        consistentScale = true,
        subimages = {[1] = 1, [2] = Sprite.find("Chest2", "vanilla").frames},
        places = {[1] = {x = 585 + 324, y = titleGround}, }
    },
    {
        -- Chest 2
        chance = 0.5,
        sprite = Sprite.find("Chest2", "vanilla"),
        animated = false,
        xscales = {[1] = 1, [2] = -1},
        consistentScale = true,
        subimages = {[1] = 1, [2] = Sprite.find("Chest2", "vanilla").frames},
        places = {[1] = {x = 585 + 165, y = titleGround} }
    },
    {
        -- Legendary Chest
        chance = 0.7,
        sprite = Sprite.find("Chest5", "vanilla"),
        animated = false,
        xscales = {[1] = 1, [2] = -1},
        consistentScale = true,
        subimages = {[1] = 1},
        places = {[1] = {x = 585 + 112, y = titleGround - (7*16)}, }
    },
    {
        -- Barrel
        chance = 0.3,
        sprite = Sprite.find("Barrel1", "vanilla"),
        animated = false,
        xscales = {[1] = 1, [2] = -1},
        consistentScale = true,
        subimages = {[1] = 1, [2] = Sprite.find("Barrel1", "vanilla").frames},
        places = {[1] = {x = 585 + 130, y = titleGround} }
    },
    {
        -- Barrel 2
        chance = 0.5,
        sprite = Sprite.find("Barrel2", "vanilla"),
        animated = false,
        xscales = {[1] = 1, [2] = -1},
        consistentScale = true,
        subimages = {[1] = 1, [2] = Sprite.find("Barrel2", "vanilla").frames},
        places = {[1] = {x = 585 + 603, y = titleGround} }
    },
    {
        -- Hit it Son
        chance = 0.9999,
        sprite = Sprite.find("DancingGolem", "vanilla"),
        animated = true,
        xscales = {[1] = 1},
        consistentScale = true,
        places = {[1] = {x = 585 + 528, y = titleGround - (Sprite.find("DancingGolem", "vanilla").height/2)} }
    },
}
local CreateTitleLevel = function()
    local dSprite = nil
    local frameCount = 1
    local objects = {}
    local subimages = {}
    local positions = {}
    local xscales = {}
    for _, obj in pairs(titleObjects) do
        if math.random() > obj.chance then
            table.insert(objects, obj)
            if obj.animated then
                frameCount = frameCount + obj.sprite.frames
            else
                local subimage = obj.subimages[math.random(1, #obj.subimages)]
                subimages[obj] = subimage
            end
            local pos = obj.places[math.random(1, #obj.places)]
            positions[obj] = pos
            if obj.consistentScale then
                xscales[obj] = obj.xscales[math.random(1, #obj.xscales)]
            end
        end
    end
    for i = 1, frameCount do
        local surface = Surface.new(titleSprites.level.width, titleSprites.level.height)
        graphics.setTarget(surface)
        graphics.drawImage{
            image = titleSprites.level,
            x = titleSprites.level.width/2,
            y = titleSprites.level.height/2,
        }
        for _, obj in pairs(objects) do
            local subimage = 1
            if obj.animated then
                subimage = (i % obj.sprite.frames) + 1
            else
                subimage = subimages[obj]
            end
            local pos = positions[obj]
            local scale = 1
            if obj.xscale and xscales[obj] then
                scale = xscales[obj]
            elseif obj.xscale and not xscales[obj] then
                scale = obj.xscales[math.random(1, #obj.xscales)]
            end
            graphics.drawImage{
                image = obj.sprite,
                subimage = subimage,
                x = pos.x,
                y = pos.y,
                xscale = scale
            }
        end
        if not dSprite then
            dSprite = surface:createSprite(titleSprites.level.xorigin, titleSprites.level.yorigin)
        else
            dSprite:addFrame(surface)
        end
    end
    
    table.insert(titles, dSprite)
    return dSprite:finalize("ror2Title_"..#titles)
end

local UpdateTitle = function()
    local title = Sprite.find("sprTitle", "vanilla")
    title:replace(titleSprites.title)
    local ground = Sprite.find("GroundStrip", "vanilla")
    ground:replace(Sprite.find("Empty"))
    local background = Sprite.find("Titlescreen", "vanilla")
    background:replace(titleSprites.stars)
    ------------------
    if not (modloader.checkMod("Starstorm") or modloader.checkMod("rorsd")) then
        local sprite = CreateTitleLevel()
        for _, survivor in pairs(Survivor.findAll("vanilla")) do
            survivor.titleSprite = sprite
        end
        for _, namespace in ipairs(modloader.getMods()) do
            for _, survivor in pairs(Survivor.findAll(namespace)) do
                survivor.titleSprite = sprite
            end
        end
    end
    
end

callback.register("globalRoomStart", function(room)
    if room == titleRoom then
        Sound.setMusic(Music.MainTheme)
    end
end)

callback.register("onGameEnd", function()
    UpdateTitle()
end)


callback.register("postLoad", function()
    UpdateTitle()
end, -99999)

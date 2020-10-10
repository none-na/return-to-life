--RoR2 Demake Project
--Made by Sivelos
--mountainShrine.lua
--File created 2019/06/02

--require("Libraries.mapObjectLib")
--local MapObject = MapObject

local bosses = {
    vagrant = {object = Object.find("GiantJelly", "vanilla"), prefix = {0, 1}, elite = {0, 1, 2, 3, 4}},
    colossus = {object = Object.find("GolemG", "vanilla"), prefix = {0, 1}, elite = {0, 1, 2, 3, 4}},
    worm = {object = Object.find("Worm", "vanilla"), prefix = {0, 1}, elite = {3}},
    wisp = {object = Object.find("WispB", "vanilla"), prefix = {0, 1}, elite = {0, 1, 2, 3, 4}},
    boar = {object = Object.find("Boar", "vanilla"), prefix = {0, 1}, elite = {0, 1, 2, 3, 4}},
    impG = {object = Object.find("ImpG", "vanilla"), prefix = {0, 1, 2}, elite = {0, 1, 2, 3, 4}},
    cremator = {object = Object.find("Turtle", "vanilla"), prefix = {0}, elite = {0}},
    ifrit = {object = Object.find("Ifrit", "vanilla"), prefix = {0, 1}, elite = {0, 1, 2, 3, 4}},
    scavenger = {object = Object.find("Scavenger", "vanilla"), prefix = {0, 1, 2}, elite = {0, 1, 2, 3, 4}},
}

local bossesByStage = {
    ["Dried Lake"] = {bosses.vagrant, bosses.colossus, bosses.worm, bosses.scavenger},
    ["Ancient Valley"] = {bosses.impG, bosses.colossus, bosses.ifrit, bosses.scavenger},
    ["Desolate Forest"] = {bosses.vagrant, bosses.colossus, bosses.worm, bosses.scavenger},
    ["Damp Caverns"] = {bosses.wisp, bosses.worm, bosses.scavenger},
    ["Hive Cluster"] = {bosses.boar, bosses.impG, bosses.scavenger},
    ["Sky Meadow"] = {bosses.vagrant, bosses.colossus, bosses.worm, bosses.wisp, bosses.scavenger},
    ["Sunken Tomb"] = {bosses.vagrant, bosses.colossus, bosses.impG, bosses.scavenger},
    ["Magma Barracks"] = {bosses.boar, bosses.cremator, bosses.scavenger},
    ["Temple of the Elders"] = {bosses.boar, bosses.impG, bosses.scavenger},
}

local sprites = {
    idle = Sprite.load("mountainShrine", "Graphics/mountainShrine", 7, 16, 26),
    mask = Sprite.load("mountainMask", "Graphics/mountainMask", 1, 16, 26),
    icon = Sprite.load("Efmountain", "Graphics/mountain", 1, 5, 5)
}

local teleporter = Object.find("Teleporter", "vanilla")

registercallback("onStageEntry", function()
    local director = misc.director
    local data = director:getData()
    data.mountainActivated = 0
    data.extraBossesSpawned = false
end)

local mountainShrine = MapObject.new({
    name = "Shrine of the Mountain",
    sprite = sprites.idle,
    baseCost = 0,
    currency = "gold",
    costIncrease = 0,
    affectedByDirector = false,
    mask = sprites.mask,
    useText = "&w&Press &y&'A'&w& to pray to the Shrine of the Mountain&!&",
    activeText = "",
    maxUses = 1,
    triggerFireworks = true,
})
local mountainController = Object.new("MountainController")
mountainController.sprite = sprites.icon

mountainController:addCallback("create", function(self)
    self:set("life", 0)
    self:set("count", 1)
    self:set("parent", -1)
    self:set("activated", 0)
    local data = self:getData()
    data.bossesSpawned = {}
end)

mountainController:addCallback("step", function(self)
    local data = self:getData()
    self:set("life", (self:get("life") + 0.01) % (2*math.pi))
    self.alpha = (0.5 + (math.sin(self:get("life"))/5))
    local parent = Object.findInstance(self:get("parent"))
    if parent then
        if parent:get("active") == 1 and parent:get("time") < parent:get("maxtime") then
            misc.director:set("boss_drop", 0)
        end
        if parent:get("active") == 1 and self:get("activated") == 0 then
            misc.hud:set("objective_text", "Let the Challenge of the Mountain... begin!")
            local currentStage = Stage.getCurrentStage().displayName
            for _, boss in ipairs(bossesByStage[currentStage]) do
                for _, inst in ipairs(boss.object:findAll()) do
                    if inst:get("show_boss_health") == 1 then
                        table.insert(data.bossesSpawned, inst)
                        for i=1, self:get("count") do
                            local newInst = inst:getObject():create(inst.x, inst.y)
                            newInst:set("prefix_type", inst:get("prefix_type"))
                            newInst:set("elite_type", inst:get("elite_type"))
                            table.insert(data.bossesSpawned, newInst)
                        end
                        self:set("activated", 1)
                        break
                    end
                end
            end
        end
    end
end)

registercallback("onObjectActivated", function(objectInstance, frame, player, x, y)
    if objectInstance:getObject() == mountainShrine then
        if frame == 1 then
            Sound.find("Shrine1", "vanilla"):play(1 + math.random() * 0.01)
            misc.shakeScreen(5)            
            local text = PopUpText.new("You have invited the Challenge of the Mountain...", 60*3, 5, objectInstance.x, objectInstance.y)
            local inst = mountainController:findNearest(x, y)
            if inst then
                inst:set("count", inst:get("count") + 1)
                print(inst:get("count"))
            else
                local tpInst = teleporter:findNearest(x, y)
                if tpInst then
                    inst = mountainController:create(tpInst.x, tpInst.y - (tpInst.sprite.height/2))
                    inst:set("parent", tpInst.id)
                end
            end
        end
    end
end)

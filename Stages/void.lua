

local stageSprites = {
    tileset = Sprite.load("TileVoid", "Graphics/tiles/Void Fields", 1, 0, 0),
    tileset2 = Sprite.load("TileVoid2", "Graphics/tiles/void ring", 1, 0, 0),
    BG1 = Sprite.load("VoidBG1", "Graphics/backgrounds/voidFieldsA", 1, 0, 0),
    BG2 = Sprite.load("VoidBG2", "Graphics/backgrounds/voidFieldsB", 1, 0, 0),
}

local voidFields

local voidfieldMissionController = Object.new("VoidFieldsMissionController")
------------------------------------


local cards = {}

callback.register("postLoad", function()
    for _, mons in ipairs(MonsterCard.findAll("vanilla")) do
        --[[local c = MonsterCard.new(mons:getName().."_VoidFields", mons.object)
        c.cost = mons.cost
        c.isBoss = mons.isBoss
        for i = 1, mons.eliteTypes:len() do
            c.eliteTypes:add(mons.eliteTypes[i])
        end
        c.sprite = mons.sprite
        c.sound = mons.sound
        c.canBlight = mons.canBlight
        c.type = mons.type]]
        table.insert(cards, #cards or 0, mons)
    end
end)

local baseCost = 25

local GetEnemy = function()
    local cost = math.ceil(baseCost * Difficulty.getScaling("cost"))
    local choices = {}
    for _, mons in ipairs(cards) do
        if mons.cost <= cost * 1.5 then
            table.insert(choices, mons)
        end
    end
    return choices[math.random(#choices - 1)]
end

------------------------------------

local vignette = Object.find("vignette", "RoR2Demake")

local maxCells = 9

local Messages = {
    cellPrompt = "&w&Press &y&'"..input.getControlString("enter").."'&w& to stabalize the Void Cell.",
    cellWarningEnemy = function(monsCard) 
        local s = string.gsub(monsCard:getName(), "_VoidFields", "")
        return (s.." has been released from the Cell!") 
    end,
    cellWarningItem = function(item) 
        if type(item.color) == "string" then
            return "&"..item.color.."&"..item:getName().."&w& has been integrated into the Cell!"
        else
            return "&y&"..item:getName().."&w& has been integrated into the Cell!"
        end
    end,
    objectiveNormal = function(progress) return "Stabilize the Cell. ("..progress.."/"..maxCells..")" end,
    objectiveGauntlet = function(progress) return "Survive!" end,
}

local sprites = {
    cell = Sprite.load("voidCell", "Graphics/voidCell", 2, 9, 15),
    cellMask = Sprite.load("cellMask", "Graphics/cellMask", 1, 9, 15),
    voidBurst = Sprite.load("voidSparks", "Graphics/voidBlast", 6, 9, 12),
    arrow = Sprite.find("arrow", "RoR2Demake"),
    voidBuffs = Sprite.find("VoidBuffs", "RoR2Demake")
}

local objects = {
    teleporter = Object.find("Teleporter", "vanilla"),
    teleporterFake = Object.find("TeleporterFake", "vanilla"),
    players = Object.find("P", "vanilla"),
    sparks = Object.find("EfSparks", "vanilla"),
    whiteFlash = Object.find("WhiteFlash", "vanilla"),
    enemies = ParentObject.find("enemies", "vanilla"),
    actors = ParentObject.find("actors", "vanilla")
}

local pools = {
    common = ItemPool.find("common", "vanilla"),
    uncommon = ItemPool.find("uncommon", "vanilla"),
    rare = ItemPool.find("rare", "vanilla"),
}

local safety = Buff.new("Safety")
safety.sprite = sprites.voidBuffs
safety.subimage = 3

local voidCell = Object.base("MapObject", "VoidCell")
voidCell.sprite = sprites.cell

local VoidCellInteraction = function(cell)
    local data = cell:getData()
    local self = cell:getAccessor()
    local manager = voidfieldMissionController:find(1)
    local info = manager:getData()
    if info.phase == 0 then
        if info.cellsComplete % 2 == 0 then
            local e = GetEnemy()
            table.insert(info.enemies, e)
            voidFields.enemies:add(e)
            data.message = Messages.cellWarningEnemy(e)
        else
            local tier = nil
            if info.cellsComplete >= info.cells - 1 then
                tier = pools.rare
            elseif info.cellsComplete >= math.ceil(info.cells / 2) then
                tier = pools.uncommon
            else
                tier = pools.common
            end
            local item = tier:roll()
            table.insert(info.items, item)
            data.message = Messages.cellWarningItem(item)
        end
        info.spawning = true
        info.phase = 1
    end
    self.active = 1
    data.rate = 100
    data.range = 100
    
end

voidCell:addCallback("create", function(this)
    local self = this:getAccessor()
    local data = this:getData()
    -------------------------------
    this.spriteSpeed = 0
    self.active = -1
    self.time = 0
    self.maxtime = 60*60
    this.mask = sprites.cellMask
    data.showText = false
    data.f = 0
    data.range = 50
    data.currentRange = 0
    data.rate = 0.1
    data.beamAlpha = 1
    -------------------------------
end)
voidCell:addCallback("step", function(this)
    local self = this:getAccessor()
    local data = this:getData()
    data.f = data.f + 0.01
    --------------------------------
    local manager = voidfieldMissionController:find(1)
    --------------------------------
    for _, inst in ipairs(objects.actors:findAllEllipse(this.x - data.currentRange, this.y - data.currentRange, this.x + data.currentRange, this.y + data.currentRange)) do
        if inst and inst:isValid() then
            if inst:get("team") == "player" or inst:get("team") == "playerproc" then
                inst:applyBuff(safety, 20)
            end
        end
    end
    --------------------------------
    if self.active > -1 then
        data.currentRange = math.approach(data.currentRange, data.range, data.rate)
    end
    if self.active == -1 then
        this.subimage = 2
    elseif self.active == 0 then
        this.subimage = 1
        local nearest = objects.players:findNearest(this.x, this.y)
        if nearest and this:collidesWith(nearest, this.x, this.y) then
            data.showText = true
            if input.checkControl("enter", nearest) == input.PRESSED then
                VoidCellInteraction(this)
            end
        else
            data.showText = false
        end
    elseif self.active == 1 then
        this.subimage = 1
        self.time = self.time + 1
        if self.time >= self.maxtime then
            objects.whiteFlash:create(this.x, this.y)
            if manager then
                local d = manager:getData()        
                for _, inst in ipairs(objects.actors:findAll()) do
                    if inst and inst:isValid() then
                        if inst:get("team") == "enemy" then
                            if math.random() < 0.1 then
                                local s = Sound.find(inst:get("sound_death"))
                                if s then s:play(0.95 + math.random() * 0.1) end
                            end
                            inst:destroy()
                        end
                    end
                end
                d.cellsComplete = d.cellsComplete + 1
                local tier = nil
                if d.cellsComplete >= d.cells then
                    tier = pools.rare
                elseif d.cellsComplete >= math.ceil(d.cells / 2) then
                    tier = pools.uncommon
                else
                    tier = pools.common
                end
                local item = tier:roll()
                for i = 1, #misc.players do
                    item:create((this.x - (36 * (#misc.players/2))) + (36 * (i-1)), this.y - 36)
                end
                data.beamAlpha = 0
                data.range = 0
                d.spawning = false
                if d.cellsComplete >= d.cells then
                    d.phase = 2
                else
                    data.rate = 0.1
                    local cells = voidCell:findAll()
                    for _, c in ipairs(cells) do
                        if c:get("active") <= -1 then
                            d.nextCell = c
                            break
                        end
                    end
                    d.nextCell:set("active", 0)
                    d.phase = 0
                end
            end
            self.active = 2
        end
    elseif self.active == 2 then
        this.subimage = 2

    elseif self.active == 3 then

    end
    
end)
voidCell:addCallback("draw", function(this)
    local self = this:getAccessor()
    local data = this:getData()
    if self.active > -1 then
        if self.active == 0 then
            if data.showText then
                graphics.printColor(Messages.cellPrompt, this.x - (graphics.textWidth(Messages.cellPrompt, graphics.FONT_DEFAULT) / 4), this.y - (32), graphics.FONT_DEFAULT)
            end
        end
        -------------------------------------------------------------------
        graphics.color(Color.fromRGB(150, 50, 150))
        graphics.alpha(data.beamAlpha * 0.3)
        graphics.line(this.x, this.y - 8, this.x, 0, 5 + (4*(math.sin(data.f))))
        graphics.color(Color.fromRGB(255, 200, 255))
        graphics.alpha(data.beamAlpha * 0.6)
        graphics.line(this.x, this.y - 8, this.x, 0, 3)
        -------------------------------------------------------------------
        graphics.alpha(0.5 + (math.sin(data.f) * 0.2))
        graphics.color(Color.fromRGB(150, 50, 150))
        graphics.circle(this.x, this.y, data.currentRange, true)
        -------------------------------------------------------------------
        if self.active == 1 then
            graphics.color(Color.WHITE)
            graphics.alpha(1)
            if data.message then
                graphics.printColor(data.message, this.x - (graphics.textWidth(data.message, graphics.FONT_DEFAULT)/2), this.y - 32, graphics.FONT_DEFAULT)
            end
            local player = misc.players[1]
            if net.online then player = net.localPlayer end
            graphics.print(math.ceil(self.time/60).."/"..math.ceil(self.maxtime/60).." seconds", player.x, player.y - 32, graphics.FONT_DEFAULT, graphics.ALIGN_CENTER, graphics.ALIGN_BOTTOM)
        end
    end
end)

----------------------------------------------------------------------------------------

voidFields = require("Stages.rooms.void")
voidFields.displayName = "Void Fields"
voidFields.subname = "Cosmic Prison"
voidFields.music = Music.AGlacierEventuallyFarts


local room = voidFields.rooms[1]

callback.register("globalRoomStart", function(r)
    if r == room then
        local m = voidfieldMissionController:create(0, 0)
    end
end)


voidfieldMissionController:addCallback("create", function(this)
    local data = this:getData()
    data.init = false
    data.phase = 0
    data.cellsComplete = 0
    data.cells = maxCells
    data.items = {}
    data.activeEnemies = {}
    data.spawning = false
    data.director = misc.director
    data.enemies = {}
    data.first = -1
    data.vignette = vignette:create(0, 0)
    data.vignette.depth = -1000
    data.vignette.blendColor = Color.BLACK
    data.overlayAlpha = 1
    data.alpha = 1
    data.hurtCD = -1
    data.nextCell = nil
end)

voidfieldMissionController:addCallback("step", function(this)
    local data = this:getData()
    if not data.init then
        local p = MakePortal("null", 1851, 464)
        p:getData().destination = nil
        for _, t in ipairs(objects.teleporter:findAll()) do
            t:destroy()
        end
        for _, t in ipairs(objects.teleporterFake:findAll()) do
            t:destroy()
        end
        local cells = voidCell:findAll()
        data.first = cells[math.random(#cells-1)].id
        local c = Object.findInstance(data.first)
        c:set("active", 0)
        c:getData().currentRange = c:getData().range
        data.nextCell = c
        for _, player in ipairs(misc.players) do
            player:applyBuff(safety, 20)
            local r = c:getData().currentRange
            player.x = c.x + math.random(-r, r)
            player.y = c.y - player:getAnimation("idle").yorigin
            player:set("ghost_x", player.x):set("ghost_y", player.y)
        end
        data.init = true
    end
    ---------------------------------------------------------------------------
    if data.cellsComplete < data.cells - 1 then
        if data.hurtCD <= -1 then
            for _, inst in ipairs(objects.actors:findAll()) do
                if inst and inst:isValid() then
                    if inst:get("team") == "player" or inst:get("team") == "playerproc" then
                        if not inst:hasBuff(safety) then
                            local m = misc.fireBullet(inst.x, inst.y, 0, 1, inst:get("hp") / 200, "voidial", nil, nil)
                            m:set("specific_target", inst.id)
                        end
                    end
                end
            end
            data.hurtCD = 10
        else
            data.hurtCD = data.hurtCD - 1
        end
    end
    if not data.spawning then
        data.director:set("points", 0)
    end
    ---------------------------------------------------------------------------
    if data.phase == 0 then --Look for new cell
        misc.hud:set("objective_text", Messages.objectiveNormal(data.cellsComplete))

    elseif data.phase == 1 then --Cell is active

    elseif data.phase == 2 then --Event complete, proceed to next stage

    end
    if input.checkKeyboard("u") == input.PRESSED then
        data.spawning = true
        voidFields.enemies:add(cards[math.random(#cards)])
    end
end)

voidfieldMissionController:addCallback("draw", function(this)
    local data = this:getData()
    local player = misc.players[1]
    if net.online then
        player = net.localPlayer
    end
    if data.phase == 0 then
        graphics.drawImage{
            image = sprites.arrow,
            x = player.x,
            y = player.y,
            angle = 90 + GetAngleTowards( data.nextCell.x, data.nextCell.y, player.x, player.y),
            color = Color.PURPLE
        }
    end
    data.overlayAlpha = math.approach(data.overlayAlpha, data.alpha, 0.01)
    if data.phase < 2 then
        data.vignette.alpha = 1
        
        if player then
            if not player:hasBuff(safety) then
                data.alpha = 1
            else
                data.alpha = 0.5
            end
        end
        local xx = camera.x
        local yy = camera.y
        local w, h = graphics.getGameResolution()
        graphics.color(Color.fromRGB(50, 50, 50))
        graphics.alpha(data.overlayAlpha)
        graphics.setBlendModeAdvanced("sourceAlphaInv", "destColor")
        graphics.rectangle(xx, yy, xx + w, yy + h)
        graphics.setBlendMode("normal")
    else
        data.vignette:getData().rate = 0.1
    end
    
end)

---------------------------------------





local sprites = {
    idle = Sprite.load("printerIdle", "Graphics/printerIdle", 5, 12, 16),
    activate = Sprite.load("printerActive", "Graphics/printerActive", 14, 19, 16),
    mask = Sprite.load("printerMask", "Graphics/printerMask", 1, 12, 16)
}

local lunarSprites = {
    idle = Sprite.load("cauldronIdle", "Graphics/printerIdle", 1, 4, 11),
    pool = Sprite.load("poolIdle", "Graphics/printerActive", 1, 4, 11),
    mask = Sprite.load("cauldronMask", "Graphics/cauldronMask", 1, 4, 11)
}

local sound = Sound.load("3dprinter", "Sounds/SFX/3dprinter.ogg")

local players = Object.find("P", "vanilla")

local spentItem = Object.new("SpentItemVisual")
spentItem:addCallback("create", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    self.direction = math.random(45, 135)
    self.speed = 2
    data.accel = 2/60
    data.phase = 0
    data.f = 0
    data.item = nil
    data.target = -1
end)
spentItem:addCallback("step", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    if data.item then
        if data.phase == 0 then
            self.speed = math.approach(self.speed, 0, data.accel)
            if self.speed == 0 then
                data.phase = 1
            end
        elseif data.phase == 1 then
            data.f = data.f + 1
            if data.f >= 60 then
                data.phase = 2
            end
        elseif data.phase == 2 then
            local target = Object.findInstance(data.target)
            if target and target:isValid() then
                self.direction = GetAngleTowards(target.x, target.y, this.x, this.y)
                self.speed = math.approach(self.speed, 3, data.accel * 10)
                if this.x >= target.x - (target.sprite.width/2) and this.x <= target.x + (target.sprite.width/2) and this.y >= target.y - (target.sprite.height/2) and this.y <= target.y + (target.sprite.height/2) then
                    local info = target:getData()
                    if info.consumed then
                        info.consumed = info.consumed + 1
                    end
                    this:destroy()
                    return
                end
            else
                this:destroy()
                return
            end
        end
    end
end)
spentItem:addCallback("draw", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    if data.item then
        graphics.drawImage{
            image = data.item.sprite,
            x = this.x,
            y = this.y,
        }
    end
end)


local CanAffordPrinter = function(player, tier, cost)
    local pool
    local currency = 0
    if type(tier) == "string" then
        pool = ItemPool.find(tier or "common")
    elseif type(tier) == "table" then
        pool = tier
    end
    if pool then
        local items = pool:toList()
        for _, item in ipairs(items) do
            currency = currency + player:countItem(item)
        end
        if currency >= cost then
            return true
        end
    end
    return false
end

local ChooseDeduction = function(player, tier, avoid)
    local pool
    local currency = 0
    if type(tier) == "string" then
        pool = ItemPool.find(tier or "common")
    elseif type(tier) == "table" then
        pool = tier
    end
    if pool then
        local playerHas = {}
        if type(tier) == "string" then
            local items = pool:toList()
            for _, item in ipairs(items) do
                if player:countItem(item) > 0 then
                    table.insert(playerHas, item)
                end
            end
        elseif type(tier) == "table" then
            for _, item in ipairs(tier) do
                if player:countItem(item) > 0 then
                    table.insert(playerHas, item)
                end
            end
        end
        -----------------
        if avoid then
            local hasOtherItems = false
            local i = 0
            for _, item in ipairs(playerHas) do
                if item ~= avoid then
                    hasOtherItems = true
                    break
                end
                i = i + 1
            end
            if hasOtherItems then
                table.remove(playerHas, i)
            end
        end
        return table.random(playerHas)
    end
    return false
end

local PrinterInit = function(this, tier, tierName)
    local data = this:getData()
    local self = this:getAccessor()
    this.spriteSpeed = 0.25
    this.mask = sprites.mask
    -----------------
    if type(tier) == "string" then
        data.tier = tier or "common"
        if ItemPool.find(data.tier) then
            data.item = ItemPool.find(data.tier):roll()
        end
    elseif type(tier) == "table" then
        data.tier = tierName or "common"
        data.item = tier[math.random(#tier)]
    end
    data.phase = 0
    data.cost = 1
    data.color = data.item.color or "w"
    data.consumed = 0
    -----------------
    data.showText = 0
    data.activator = -1
    data.displayX = 0
    data.displayY = -32
    data.f = 0
    data.bob = 0
    -----------------
    data.text = "&w&Press &y&'".. input.getControlString("enter").."'&w& to activate 3D Printer ("..data.item.displayName.."). &"..data.color.."&(1 Item(s))&!&"
    -----------------
    this.y = FindGround(this.x, this.y)
end

local PrinterStep = function(this)
    local data = this:getData()
    local self = this:getAccessor()
    -------------------------------
    data.bob = data.bob + 0.1
    data.text = "&w&Press &y&'".. input.getControlString("enter").."'&w& to activate "..data.name.." ("..data.item.displayName.."). &"..data.color.."&(1 Item(s))&!&"
    if data.item and data.item.color then
        data.color = data.item.color
    end
    if data.phase == 0 then
        local nearest = players:findNearest(this.x, this.y)
        if nearest and nearest:isValid() then
            if this:collidesWith(nearest, this.x, this.y) then
                data.activator = nearest.id
                data.showText = 1
                -----------------------
                if input.checkControl("enter", nearest) == input.PRESSED then
                    if CanAffordPrinter(nearest, data.tier, data.cost) then
                        for i = 1, data.cost do
                            -----------------
                            local deduction = ChooseDeduction(nearest, data.tier, data.item)
                            if deduction then
                                IRL.removeItem(nearest, deduction, true)
                                local visual = spentItem:create(nearest.x, nearest.y)
                                visual:getData().item = deduction
                                visual:getData().target = this.id
                            end
                            -----------------
                        end
                        data.showText = 0
                        data.phase = 1
                    else
                        Sound.find("Error"):play()
                    end
                end
            else
                data.activator = -1
                data.showText = 0
            end
        end
    elseif data.phase == 1 then
        if data.consumed >= data.cost then
            sound:play(0.95 + math.random() * 0.1)
            this.sprite = data.activeSprite
            data.phase = 2
            data.f = 0
        end
    elseif data.phase == 2 then
        data.f = data.f + 1
        if data.f <= 60 then
            if this.sprite == data.activeSprite then
                if math.floor(this.subimage) == 10 then
                    this.subimage = 5
                end
            end
        else
            data.item:create(this.x, this.y - (this.sprite.height * 3))
            misc.shakeScreen(5)
            this.subimage = 11
            data.phase = 3
            return
        end
    elseif data.phase == 3 then
        if math.floor(this.subimage) >= data.activeSprite.frames then
            data.phase = 0
            data.consumed = 0
            this.sprite = data.idleSprite
            return
        end
    end
    
end

local PrinterDraw = function(this)
    local data = this:getData()
    local self = this:getAccessor()
    -------------------------------
    if data.item then
        graphics.drawImage{
            image = data.item.sprite,
            x = this.x + data.displayX,
            y = this.y + data.displayY + math.sin(data.bob),
            alpha = 0.5,
        }
        graphics.alpha(0.7+(math.random()*0.15))
        graphics.printColor("&"..data.color.."&"..data.cost.." ITEMS&!&", this.x - (graphics.textWidth(data.cost.." ITEMS", NewDamageFont)/2), this.y + this.sprite.height, NewDamageFont)
        graphics.alpha(1)
        if data.showText == 1 then
            graphics.printColor(data.text, this.x - (graphics.textWidth(data.text, graphics.FONT_DEFAULT) / 2), this.y - (this.sprite.height * 2) + data.displayY, graphics.FONT_DEFAULT)
        end
    end
end


----------------------------------------------------
local commonPrinter = Object.base("MapObject", "itemPrinter1")
commonPrinter.sprite = sprites.idle

commonPrinter:addCallback("create", function(self)
    local data = self:getData()
    data.idleSprite = sprites.idle
    data.activeSprite = sprites.activate
    self.mask = sprites.mask
    data.name = "3D Printer"
    --------------------
    PrinterInit(self, "common")
end)
commonPrinter:addCallback("step", function(self)
    PrinterStep(self)
end)
commonPrinter:addCallback("draw", function(self)
    PrinterDraw(self)
end)
----------------------------------------------------
local uncommonPrinter = Object.base("MapObject", "itemPrinter2")
uncommonPrinter.sprite = sprites.idle

uncommonPrinter:addCallback("create", function(self)
    local data = self:getData()
    data.idleSprite = sprites.idle
    data.activeSprite = sprites.activate
    self.mask = sprites.mask
    data.name = "3D Printer"
    --------------------
    PrinterInit(self, "uncommon")
end)
uncommonPrinter:addCallback("step", function(self)
    PrinterStep(self)
end)
uncommonPrinter:addCallback("draw", function(self)
    PrinterDraw(self)
end)
----------------------------------------------------
local rarePrinter = Object.base("MapObject", "itemPrinter3")
rarePrinter.sprite = sprites.idle

rarePrinter:addCallback("create", function(self)
    local data = self:getData()
    data.idleSprite = sprites.idle
    data.activeSprite = sprites.activate
    self.mask = sprites.mask
    data.name = "Militech 3D Printer"
    --------------------
    PrinterInit(self, "rare")
end)
rarePrinter:addCallback("step", function(self)
    PrinterStep(self)
end)
rarePrinter:addCallback("draw", function(self)
    PrinterDraw(self)
end)
----------------------------------------------------
local bossPrinter = Object.base("MapObject", "itemPrinter4")
bossPrinter.sprite = sprites.idle

bossPrinter:addCallback("create", function(self)
    local data = self:getData()
    data.idleSprite = sprites.idle
    data.activeSprite = sprites.activate
    self.mask = sprites.mask
    data.name = "Overgrown 3D Printer"
    --------------------
    PrinterInit(self, "boss")
end)
bossPrinter:addCallback("step", function(self)
    PrinterStep(self)
end)
bossPrinter:addCallback("draw", function(self)
    PrinterDraw(self)
end)
----------------------------------------------------
local common = Interactable.new(commonPrinter, "printerCommon")
common.spawnCost = 100

local uncommon = Interactable.new(uncommonPrinter, "printerUncommon")
uncommon.spawnCost = 200

local rare = Interactable.new(rarePrinter, "printerRare")
rare.spawnCost = 400

local boss = Interactable.new(bossPrinter, "printerBoss")
boss.spawnCost = 800

for _, stage in ipairs(Stage.findAll("vanilla")) do
    stage.interactables:add(common)
    stage.interactables:add(uncommon)
    stage.interactables:add(rare)
    stage.interactables:add(boss)
end
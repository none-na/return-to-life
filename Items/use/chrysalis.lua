--RoR2 Demake Project
--Made by Sivelos
--chrysalis.lua
--File created 2019/07/1

local chrysalis = Item("Milky Chrysalis")
chrysalis.pickupText = "Obtain temporary flight."

chrysalis.sprite = Sprite.load("Items/use/Graphicschrysalis.png", 2, 12, 16)
chrysalis:setTier("use")

chrysalis.isUseItem = true
chrysalis.useCooldown = 60

chrysalis:setLog{
    group = "use",
    description = "Sprout wings and fly for &y&15 seconds&!&. Gain &y&+20% movement speed&!& for the duration.",
    story = "I managed to salvage a chrysalis from one of the last Archer Bug colonies in the galaxy. These bugs were hunted to near extinction for their unique genetic codes... A genetic string that would inevitably lead to flight, no matter the species. The 1% would hunt these poor things and have flight written into their genome... 'Cause the rich are ****ing crazy, I guess.\n\nI don't want this falling into the hands of any crazy oil barons. Make sure you keep this thing safe. It may very well be the last of its kind.",
    destination = "Locust Colony,\nArchaea,\nWurst Colony",
    date = "4/28/2056"
}

local sprites = {
    idle = Sprite.load("EfwingsIdle", "Graphics/wingsIdle", 1, 13, 6),
    active = Sprite.load("EfwingsFlapping", "Graphics/wingsFlapping", 3, 13, 6),
}

local players = ParentObject.find("actors", "vanilla")

local wings = Object.new("EfWings")
wings.sprite = sprites.idle

registercallback("onActorInit", function(actor)
    if actor:isValid() and isa(actor,"PlayerInstance") then
        actor:set("goldGat", 0)
    end
end)

local chrysalisHold = {}

wings:addCallback("create", function(self)
    self.sprite = sprites.idle
    self.spriteSpeed = 0
    self:set("id", self.id)
    self:set("state", 0)
end)

wings:addCallback("step", function(self)
    local parent = nil
    for _, player in ipairs(players:findMatching("id", self:get("parent"))) do
        parent = player
    end
    self.xscale = parent.xscale
    self.x = parent.x + ((self:get("xOff") or 0) * parent.xscale)
    self.y = parent.y + ((self:get("yOff") or 0))
    
    if self:get("state") == 1 then
        --firing state
        self.sprite = sprites.active
        self.spriteSpeed = 0.25
    else
        --idle state
        self.sprite = sprites.idle
        self.spriteSpeed = 0
    end
end)

local wingBuff = Buff.new("chrysalisBuff")
wingBuff.sprite = Sprite.load("chrysalisBuffSpr", "Graphics/empty", 1, 0, 0)

wingBuff:addCallback("start", function(player)
    chrysalisHold[player] = 0
    player:set("pHmax", player:get("pHmax") + 0.26)
    local wingInst = wings:create(player.x, player.y)
    wingInst:set("parent", player.id)
    wingInst:set("xOff", 0)
    wingInst:set("yOff", 0)
    wingInst:set("persistent", 1)
    player:set("chrysalis", wingInst:get("id") or wingInst.id)
end)
wingBuff:addCallback("step", function(player)
    if player:get("moveUpHold") == 1 and player:get("free") == 1 then
        chrysalisHold[player] = chrysalisHold[player] + 1
        if chrysalisHold[player] >= 15 then
            player:set("pVspeed", -player:get("pVmax") / 5) 
            if chrysalisHold[player] % 5 == 0 then
                local wingInst = Object.findInstance(player:get("chrysalis"))
                wingInst:set("state", 1)
            end
        end
    else
        local wingInst = Object.findInstance(player:get("chrysalis"))
        wingInst:set("state", 0)
        chrysalisHold[player] = 0
    end
end)
wingBuff:addCallback("end", function(player)
    local wingInst = Object.findInstance(player:get("chrysalis"))
    wingInst:destroy()
    player:set("pHmax", player:get("pHmax") - 0.26)
end)

chrysalis:addCallback("use", function(player, embryo)
    player:applyBuff(wingBuff, 15*60)
end)

GlobalItem.items[chrysalis] = {
    use = function(inst, embryo)

    end,
}
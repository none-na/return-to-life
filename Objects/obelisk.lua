

local obelisk = Object.base("mapobject", "Obelisk")
obelisk.sprite = Sprite.load("Graphics/obelisk", 1, 36, 93)

local spark = ParticleType.find("Sparks", "RTSCore")
local player = Object.find("P", "vanilla")

local sound = Sound.find("VagrantBlast", "RoR2Demake")
local white = Object.find("WhiteFlash", "vanilla")

local useText = "&w&Press &y&\'"..input.getControlString("enter").."\'&w& to eradicate yourself from existence."
local warningText = "&w&Are you sure? &y&(Press "..input.getControlString("enter").." to confirm)"

local achievements = {
    Achievement.find("unlock_merc_ror2", "RoR2Demake"), --Unlock Mercenary 2.0
}
local skinUnlocks = {
    {survivor = Survivor.find("Commando 2.0"), achieve = Achievement.find("unlock_commando_skin1", "RoR2Demake")},
    {survivor = Survivor.find("Huntress 2.0"), achieve = Achievement.find("unlock_huntress_skin1", "RoR2Demake")},
    {survivor = Survivor.find("Loader 2.0"), achieve = Achievement.find("unlock_loader_skin1", "RoR2Demake")},
}


obelisk:addCallback("create", function(self)
    local data = self:getData()
    data.phase = 0
    data.beads = false
    data.transported = 0
    data.f = 0
end)

local ActivateObelisk = function(this)
    local data = this:getData()
    if data.phase == 0 then
        sound:play()
        local flash = white:create(this.x, this.y)
        flash:getAccessor().rate = 0.01
        this:getData().phase = 1
        local portal = MakePortal("celestial", this.x, this.y + this.sprite.height + 16)
    elseif data.phase == 1 then
        for _, achieve in ipairs(achievements) do
            if not achieve:isComplete() then
                achieve:increment(1)
            end
        end
        for _, achieve in ipairs(skinUnlocks) do
            if not achieve.achieve:isComplete() and Difficulty.getActive():getName() == "Monsoon" then
                if net.online then
                    if net.localPlayer:getSurvivor() == achieve.survivor then
                        achieve.achieve:increment(1)
                    end
                else
                    if misc.players[1]:getSurvivor() == achieve.survivor then
                        achieve.achieve:increment(1)
                    end
                end
            end
        end
        data.phase = 2
    end
end

local SyncObelisk = net.Packet.new("Sync Obelisk", function()
    local obl = obelisk:find(1)
    if obl then
        ActivateObelisk(obl)
    end
end)

local orbY = 75

local beads = Item.find("Beads of Fealty", "RoR2Demake")
local obliterate = Sound.find("Obliterate", "RoR2Demake")
local obliterationFX = ParticleType.find("eradication", "RoR2Demake")

obelisk:addCallback("step", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    data.f = data.f + 1
    if not data.beads then
        for _, p in ipairs(misc.players) do
            if p:countItem(beads) > 0 then
                data.beads = true
            end
        end
    end
    data.activator = player:findNearest(this.x, this.y)
    if data.phase > 0 then
        misc.shakeScreen(1)
        if data.f % 7 == 0 then
            spark:burst("above", this.x + math.random(-15, 15), (this.y - orbY) + math.random(-15, 15), 1)
        end
    end
    if this:collidesWith(data.activator, this.x, this.y) then
        if input.checkControl("enter", data.activator) == input.PRESSED then
            if data.phase < 2 then
                if net.host then
                    ActivateObelisk(this)
                    if net.online then
                        SyncObelisk:sendAsHost("all", nil)
                    end
                elseif net.online and not net.host then
                    SyncObelisk:sendAsClient(player.id)
                end
            end
        end
    end
    if data.phase == 2 then
        if data.gaveCoins then
            if data.gaveCoins == 0 then
                local player = misc.players[1]
                if net.online then
                    player = net.localPlayer
                end
                Lunar.SetLunarCoins(player, Lunar.GetLunarCoins(player) + 5)
                data.gaveCoins = 1
            end
        else
            data.gaveCoins = 0
        end
        for _, player in ipairs(misc.players) do
            if data.f % 45 == 0 then
                if not data.beads then
                    if player:get("dead") ~= 1 then
                        player:set("eradicate", 1)
                        player:set("hippo", 0)
                        player:kill()
                    end
                else
                    
                    obliterate:play(0.9 + math.random() * 0.1)
                    player.visible = false
                    player:set("activity", 99)
                    player:set("activity_type", 3)
                    for i = 0, math.random(10, 30) do
                        obliterationFX:burst("above", player.x, player.y, 1)
                    end
                    data.transported = data.transported + 1
                end
            end
        end
        if data.f >= 300 and data.transported >= #misc.players then
            if not data.man then
                local p = Object.find("PortalTransportManager", "RTSCore")
                data.man = p:create(0, 0)
                data.man:set("persistent")
            end
            Stage.transport(Stage.find("A Moment, Whole", "RoR2Demake"))
        end
    end
end)



obelisk:addCallback("draw", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    if this:collidesWith(player:findNearest(this.x, this.y), this.x, this.y) then
        if data.phase == 0 then    
            graphics.alpha(1)
            local useFormatted = useText:gsub("&[%a]&", "")
            graphics.printColor(useText, (this.x - (graphics.textWidth(useFormatted, graphics.FONT_DEFAULT) / 2)), (this.y - (this.sprite.height + (graphics.textHeight(useText, graphics.FONT_DEFAULT) + 5))), graphics.FONT_DEFAULT) 
        elseif data.phase == 1 then
            graphics.alpha(1)
            local useFormatted = warningText:gsub("&[%a]&", "")
            graphics.printColor(warningText, (this.x - (graphics.textWidth(useFormatted, graphics.FONT_DEFAULT) / 2)), (this.y - (this.sprite.height + (graphics.textHeight(useText, graphics.FONT_DEFAULT) + 5))), graphics.FONT_DEFAULT) 
        end
    end
    if data.phase > 0 then
        graphics.setBlendMode("additive")
        graphics.color(Color.AQUA)
        graphics.alpha(math.random(0.5, 0.9))
        graphics.circle(this.x, this.y - (orbY), 10 + math.sin(data.f), false)
        graphics.color(Color.WHITE)
        graphics.alpha(math.random(0.5, 0.9))
        graphics.circle(this.x, this.y - orbY, 5 + math.cos(data.f), false)
    end
end)

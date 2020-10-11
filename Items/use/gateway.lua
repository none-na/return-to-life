--RoR2 Demake Project
--Made by Sivelos
--gateway.lua
--File created 2019/07/1

local gateway = Item("Eccentric Vase")
gateway.pickupText = "Create a quantum tunnel between two locations."

gateway.sprite = Sprite.load("Items/gateway.png", 2, 12, 16)
gateway:setTier("use")

gateway.isUseItem = true
gateway.useCooldown = 100

gateway:setLog{
    group = "use",
    description = "Create a quantum tunnel up to 1000m in length. Lasts 30 seconds.",
    story = "---",
    destination = "---,\n---,\n---",
    date = "---/---/2056"
}
local maxLength = 1000
local players = Object.find("P", "vanilla")
local mask = Sprite.load("Graphics/tunnelMask", 1, 6, 6)
local tunnel = Object.new("EfQuantumTunnel")
local tpSound = Sound.find("ImpShoot2", "vanilla")
local deathSound = Sound.find("Shield", "vanilla")

local entryFX = ParticleType.new("EfTunnelEntry")
entryFX:shape("Ring")
entryFX:color(Color.PURPLE, Color.RED, Color.WHITE)
entryFX:alpha(0, 0.75, 0)
entryFX:additive(true)
entryFX:scale(0.25, 0.25)
entryFX:size(0.9, 1, -0.01, 0.005)
entryFX:angle(0, 360, 1, 0.5, true)
entryFX:life(15, 60)

local quantumFX = ParticleType.new("EfQuantumFX")
quantumFX:shape("Square")
quantumFX:color(Color.PURPLE, Color.RED)
quantumFX:alpha(0.5)
quantumFX:additive(true)
quantumFX:scale(0.05, 0.07)
quantumFX:size(0.9, 1, -0.01, 0.005)
quantumFX:angle(0, 360, 1, 0.5, true)
quantumFX:life(30, 60)

callback.register("onPlayerInit", function(player)
    player:set("gatewayEntered", -1)
end)

tunnel:addCallback("create", function(self)
    self.mask = mask
    self:set("life", 30*60)
    self:set("cooldown", 30)
    local data = self:getData()
    data.passengers = {}
end)
tunnel:addCallback("step", function(self)
    self.mask = mask
    local data = self:getData()
    entryFX:burst("middle", self.x, self.y, 1)
    if self:get("life") > -1 then
        local destination
        if data.child then
            destination = data.child
        else
            destination = data.parent
        end
        for _, player in pairs(data.passengers) do
            if player:get("gatewayEntered") ~= -1 then
                if (input.checkControl("enter", player) == input.PRESSED or player:collidesWith(destination, player.x, player.y)) and player:get("gatewayEntered") == self.id then
                    tpSound:play(0.9 + math.random() * 0.1)
                    player.alpha = 1
                    player:set("pVspeed", -player:get("pVmax"))
                    player:set("gatewayEntered", -1)
                    self:set("cooldown", 30)
                    data.passengers[player] = nil
                else
                    if player:get("gatewayEntered") == self.id then
                        player.alpha = 0
                        player.y = self.y
                        player:set("pVspeed", 0)
                        player:set("moveUp", 0):set("moveUpHold", 0)
                        player:set("z_skill", 0)
                        player:set("x_skill", 0)
                        player:set("c_skill", 0)
                        player:set("v_skill", 0)
                        if self.xscale == 1 then
                            player:set("moveRight", 1):set("moveLeft", 0)
                        else
                            player:set("moveLeft", 1):set("moveRight", 0)
                        end    
                    end
                end
            end 
        end
        if self:get("cooldown") <= -1 then
            local player = players:findNearest(self.x, self.y)
            if input.checkControl("enter", player) == input.PRESSED and self:collidesWith(player, self.x, self.y) then
                if data.passengers[player] == nil then
                    table.insert(data.passengers, player)
                    player.alpha = 0
                    tpSound:play(0.9 + math.random() * 0.1)
                    player:set("gatewayEntered", self.id)
                end
                destination:set("cooldown", 30)
            end
        else
            self:set("cooldown", self:get("cooldown") - 1)
        end
        if self:get("life") % 15 == 0 then
            quantumFX:burst("middle", self.x + math.random(-10, 10), self.y + math.random(-10, 10), 1)
        end
        self:set("life", self:get("life") - 1)
    else
        deathSound:play(0.8 + math.random() * 0.2)
        self:destroy()
    end
end)

tunnel:addCallback("destroy", function(self)
    self.mask = mask
    local data = self:getData()
    for _, player in ipairs(data.passengers) do
        player.alpha = 1
        player:set("gatewayEntered", -1)
    end
    data.passengers = {}
end)


tunnel:addCallback("draw", function(self)
    local data = self:getData()
    local child = data.child
    local actor = players:findNearest(self.x, self.y)
    graphics.alpha(1)
    if actor:isValid() and isa(actor, "PlayerInstance") and self:get("cooldown") <= -1 and data.passengers[actor] == nil then
        if self:collidesWith(actor, self.x, self.y) then
            graphics.printColor("&w&Press &y&'"..input.getControlString("enter", actor).."'&w& to enter Quantum Tunnel.&!&", self.x - (graphics.textWidth("Press 'A' to enter Quantum Tunnel.", graphics.FONT_DEFAULT) / 2), self.y - (mask.height *2))
        end
    end
    if child then
        if self:get("life") % 5 == 0 then
            quantumFX:burst("middle", self.x + math.random(0, data.length * self.xscale), self.y + math.random(-3, 3), 1)
        end
        graphics.color(Color.PURPLE)
        graphics.alpha(0.5)
        graphics.line(self.x, self.y, child.x, child.y, 1)
    end
    for _, player in pairs(data.passengers) do
        if player:get("gatewayEntered") == self.id then
            graphics.alpha(1)
            graphics.printColor("&w&Press &y&'"..input.getControlString("enter", player).."'&w& to exit Quantum Tunnel.&!&", player.x - (graphics.textWidth("Press 'A' to exit Quantum Tunnel.", graphics.FONT_DEFAULT) / 2), player.y - (mask.height *2))
        end
    end
end)

gateway:addCallback("use", function(player, embryo)
    local tunnelInst = tunnel:create(player.x, player.y - 3)
    local dir = 1
    if player:getFacingDirection() == 180 then
        dir = -1
    end
    tunnelInst.xscale = dir
    local nextX = player.x + (maxLength * tunnelInst.xscale)
    for i = 0, maxLength do
        if tunnelInst:collidesMap(player.x + (i*dir), player.y - 3) then
            print("FOUND COLLISION AT x:"..player.x + (i*dir)..", y:"..player.y-3 )
            nextX = player.x +((i - player.sprite.width) * dir)
            i = maxLength
            break 
        end
    end
    local newInst = tunnel:create(nextX, player.y - 3)
    local data = tunnelInst:getData()
    data.child = newInst
    data.length = math.abs(tunnelInst.x - newInst.x)
    newInst.xscale = -tunnelInst.xscale
    data = newInst:getData()
    data.parent = tunnelInst
    if embryo then
        tunnelInst:set("life", 60*60)
        newInst:set("life", 60*60)
    end
end)


                --[[player.x = destination.x
                player.y = destination.y
                tpSound:play(0.8 + math.random() * 0.2)
                for i=0, math.random(3, 10) do
                    quantumFX:burst("middle", destination.x + math.random(-30, 30), destination.y + math.random(-30, 30), 1)
                end]]
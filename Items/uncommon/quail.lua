--RoR2 Demake Project
--Made by Sivelos
--quail.lua
--File created 2019/06/10

local quail = Item("Wax Quail")
quail.pickupText = "Jumping while moving boosts you forwards."

quail.sprite = Sprite.load("Items/uncommon/Graphicsquail.png", 1, 16, 16)

quail:setTier("uncommon")
quail:setLog{
    group = "uncommon",
    description = "Jumping while moving boosts you forwards.",
    story = "Look! My first complete wax sculpture. It's a little bird, see? The beak, the wings... I even added some coloring for the eyes.",
    destination = "Grandma's Art Emporium,\nNewton Parkway,\nMars",
    date = "10/2/2056"
}

local boost = {
    object = Object.new("quail"),
    sprite = Sprite.load("Graphics/quailBoost", 4, 10, 10),
    sound = Sound.find("SamuraiShoot1", "vanilla")
}

boost.object.sprite = boost.sprite

boost.object:addCallback("create", function(self)
    local player = self:getData().parent
    self.spriteSpeed = 0.2
end)

boost.object:addCallback("step", function(self)
    if math.round(self.subimage) >= boost.sprite.frames then
        self:destroy()
    end
end)

local quailActive = {}
local quailDirection = {}

registercallback("onPlayerStep", function(player)
    if player:isValid() then
        if player:countItem(quail) > 0 then
            if quailActive[player] then
                if (player:get("moveLeft") == 1 or player:get("moveRight") == 1) and player:get("moveUp") == 1 and player:get("free") == 0 then
                    player.y = player.y - 0.1
                    boost.sound:play(0.7 + math.random() * 0.2)
                    if player:getFacingDirection() == 180 then
                        quailDirection[player] = -1
                    else
                        quailDirection[player] = 1
                    end
                    
                    quailActive[player] = 30
                    local inst = boost.object:create(player.x, player.y + (player.sprite.height / 2))
                end
                if quailActive[player] > -1 then
                    if player:get("free") == 1 and player:get("activity") ~= 30 and player:get("activity") ~= 95 and player:get("activity") ~= 99 and (Object.find("Geyser","vanilla"):findNearest(player.x, player.y) and not player:collidesWith(Object.find("Geyser","vanilla"):findNearest(player.x, player.y), player.x, player.y)) then
                        local distance = (player:get("pHmax") * player:countItem(quail) * quailDirection[player])
                        for i = 0, distance do
                            if player:collidesMap(player.x + i + (player.sprite.width), player.y) or player:collidesMap(player.x + i, player.y)  then
                                distance = i
                                break
                            end
                        end
                        player.x = player.x + distance
                        quailActive[player] = quailActive[player] - 1
                        if player:collidesMap(player.x, player.y - 3) then
                            player.x = player.x - (player.mask.width * player.xscale)
                        end
                    else
                        if quailActive[player] < 29 then
                            quailActive[player] = -1
                        end
                    end
                end
            else
                quailActive[player] = -1
                quailDirection[player] = 0
            end
        end
    end
end)


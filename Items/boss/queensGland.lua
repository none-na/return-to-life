--RoR2 Demake Project
--Made by Sivelos
--queensGland.lua
--File created 2019/06/5

local gland = Item("Queen's Gland")
gland.pickupText = "Long live the queen."

gland.sprite = Sprite.load("Items/boss/Graphics/queensGland.png", 1, 16, 16)
--gland:setTier("rare")

gland:setLog{
    group = "boss",
    description = "Recruit a Beetle Guard. Revives every 30 seconds.",
    story = "I seem to have made a friend... One of the Beetle Guards has been tailing me from a distance ever since I killed the Queen. At first I suspected it was hostile, but the thing would back off every time I approached. It seemed almost... bashful?\n\nI can only guess its intentions, but the Guard seems to have my best interests at heart. I've got to say, I've grown quite fond of it... I wonder what I should name it?",
    destination = "Brooding Chamber,\nVast Hive,\nUnknown",
    date = "10/1/2056"
}

gland.color = "y"

local beetleGuard = Object.find("BeetleGS", "RoR2Demake")

callback.register("onPlayerStep", function(player)
    if player:get("dead") == 0 then
        if player:countItem(gland) > 0 then
            local data = player:getData()
            if data.guards then
                data.gland = player:countItem(gland)
                data.guards = 0
                for _, g in ipairs(beetleGuard:findAll()) do
                    if g and g:isValid() then
                        if g:getData().parent and g:getData().parent == player then
                            data.guards = data.guards + 1
                        end
                    end
                end
                if data.guards < data.gland then
                    if data.glandCD <= -1 then
                        misc.shakeScreen(5)
                        Sound.find("BeetleGSpawn", "RoR2Demake"):play(0.9 + math.random() * 0.1)
                        local b = beetleGuard:create(player.x, player.y)
                        b:getData().ally = true
                        b:getData().parent = player
                        b:set("state", "spawn")
                        data.glandCD = 5
                    else
                        data.glandCD = data.glandCD - 1
                    end
                end
            else
                data.glandCD = -1
                data.gland = 0
                data.guards = 0
            end
        end
    end
end)
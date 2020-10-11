--RoR2 Demake Project
--Made by Sivelos
--headstompers.lua
--File created 2019/06/12

local headstompers = Item("H3AD-5T v2")
headstompers.pickupText = "Increase jump height. Press '".. input.getControlString("use") .."' to slam down to the ground."

local sprites = {
    active = Sprite.load("Items/rare/Graphicsheadstompers.png", 1, 16, 16),
    inactive = Sprite.load("Items/rare/Graphicsheadstompers2.png", 1, 16, 16)
}

headstompers.sprite = sprites.active
headstompers:setTier("rare")

headstompers:setLog{
    group = "rare",
    description = "Increase jump height. Press &y&'"..input.getControlString("use").."'&!& to &b&slam down to the ground&!& for &b&2300%&!&. Recharges in 10 seconds.",
    story = "Here are the gravity-shifting anklets you ordered a while back. Make sure to calibrate these correctly - otherwise you may wind up with a concussion.\n\nI still think it's bull**** you didn't recieve a pair of these upon working at the factory. Mars doesn't have the same gravitational environment as Earth, and your employer says you have to get your own gravity anklets? You really need to join a union, man.",
    destination = "Apollo Garden,\nOlympus Mons,\nMars",
    date = "11/02/2056"
}

local boomSpr = Sprite.load("Graphics/headstompersBoom", 6, 58, 42)
local boomSnd = Sound.find("Geyser", "vanilla")
local buildUpLimit = 30

headstompers:addCallback("pickup", function(player)
    player:set("headstomperCooldown", 0)
    player:set("headstomperBuildup", 0)
end)



registercallback("onPlayerStep", function(player)
    if player:countItem(headstompers) > 0 then
        if player:get("headstomperCooldown") > 0 then
            player:setItemSprite(headstompers, sprites.inactive)
            player:set("headstomperCooldown", player:get("headstomperCooldown") - 1)
        elseif player:get("headstomperCooldown") == 0 then
            player:set("pVmax", math.clamp(player:get("pVmax") + (2 * (player:countItem(headstompers))), 3, 5))
            player:setItemSprite(headstompers, sprites.active)
            player:set("headstomperCooldown", -1)
        end
        
        print(player:get("headstomperBuildup"))
        if player:get("headstomperBuildup") >= buildUpLimit then
            player:set("headstomperBuildup", player:get("headstomperBuildup") + 1)
            if player:get("free") == 0 then
                misc.shakeScreen(10)
                boomSnd:play(0.9 + math.random() * 0.2)
                player:fireExplosion(player.x, player.y + (player.sprite.height / 2), boomSpr.width/19, boomSpr.height/4, 23 * (player:get("pHmax") / 1.3), boomSpr, nil)
                player:set("pGravity1", 0.25)
                player:set("headstomperCooldown",  (10*60) / player:countItem(headstompers))
                player:set("pVmax", math.clamp(player:get("pVmax") - (2 * (player:countItem(headstompers))), 3, 5))
                player:set("headstomperBuildup", 0)
            else
                player:set("invincible", 5)
                player:set("pGravity1", 3)
            end
        end
        if player:get("free") == 1 and input.checkControl("use",player) == input.PRESSED and player:get("headstomperCooldown") <= 0 then
            if player:get("headstomperBuildup") < buildUpLimit then
                player:set("headstomperBuildup", buildUpLimit + 1)
            end
        end
    end
end)
--RoR2 Demake Project
--Made by Sivelos
--fuelArray.lua
--File created 2019/08/14
local useSound = Sound.find("Pickup", "vanilla")

local fuelArray = Item("Fuel Array")
fuelArray.pickupText = "Looks like it could power something. EXTREMELY unstable..."
fuelArray.sprite = Sprite.load("Items/use/GraphicsfuelArray", 2, 16, 16)
fuelArray.isUseItem = true
fuelArray.color = "or"
fuelArray.useCooldown = 0
fuelArray:addCallback("pickup", function(player)
    player:set("arrayCountdown", 5*60)
    player:set("arrayCounting", 0)
end)
fuelArray:addCallback("use", function(player)
    player:setAlarm(0, -1)
    if useSound:isPlaying() then
        useSound:stop()
    end
end)

local particles = {
    spark = ParticleType.find("Spark", "vanilla"),
    fire = ParticleType.find("Smoke2","vanilla")
}

local explosion = Sprite.find("EfFireshield","vanilla")
local explosionSnd = Sound.find("Smite","vanilla")
local countDownSnd = Sound.find("Click", "vanilla")

callback.register("onPlayerStep", function(player)
    if player.useItem == fuelArray then
        if not player:get("arrayCounting") or not player:get("arrayCountdown") then
            player:set("arrayCountdown", 5*60)
            player:set("arrayCounting", 0)
        end
        if player:get("hp") <= player:get("maxhp") /2 then
            player:set("arrayCounting", 1)
        end
        if player:get("arrayCounting") == 1 then
            if player:get("arrayCountdown") <= -1 then
                explosionSnd:play(1 + math.random() * 0.1)
                misc.shakeScreen(15)
                local explosion = misc.fireExplosion(player.x, player.y, 1, 1, 3*player:get("maxhp"), "neutral", explosion, nil)
                player.useItem = nil
            else            
                player:set("arrayCountdown", player:get("arrayCountdown") - 1)
                if player:get("arrayCountdown")%2 == 0 then
                    particles.spark:burst("middle", player.x, player.y, 1)
                    particles.fire:burst("middle", player.x + math.random(-8, 8), player.y + math.random(-8, 8), 1)
                end
                if player:get("arrayCountdown")%60==0 then
                    countDownSnd:play(1) 
                end
            end
        end
    end
end)

local pod = Object.find("Base", "vanilla")
local player = Object.find("P", "vanilla")

local sprites = {
    open = Sprite.load("BaseOpen", "Graphics/podOpen1", 11, 0, 46),
    fullyOpen = Sprite.load("BaseOpen2", "Graphics/podOpen2", 2, 0, 46),
    mask = Sprite.load("BaseMask", "Graphics/podMask", 1, 0, 46)
}

local openSound = Sound.find("Chest1","vanilla")

pod:addCallback("create", function(self)
    local data = self:getData()
    data.phase = 0
    data.tookArray = false
    --self.mask = sprites.mask
end)

callback.register("onStep", function()
    for _, podInst in ipairs(pod:findAll()) do
        local data = podInst:getData()
        if not data.phase then
            data.phase = 0
        end
        if not data.tookArray then
            data.tookArray = false
        end
        local nearestPlayer = player:findNearest(podInst.x, podInst.y)
        if nearestPlayer:get("activity") < 30 then
            if data.phase == 0 then
                if podInst:collidesWith(nearestPlayer, podInst.x, podInst.y) then
                    if input.checkControl("enter", nearestPlayer) == input.PRESSED then
                        podInst.subimage = 1
                        podInst.sprite = sprites.open
                        podInst.spriteSpeed = 0.25
                        openSound:play(1 + math.random()*0.3)
                        data.phase = 1
                    end
                end
            elseif data.phase == 1 then
                podInst.spriteSpeed = 0.25
                if math.round(podInst.subimage) >= sprites.open.frames then
                    podInst.spriteSpeed = 0
                    podInst.subimage = 0
                    podInst.sprite = sprites.fullyOpen
                    data.phase = 2
                end
    
            elseif data.phase == 2 then
                podInst.spriteSpeed = 0
                if data.tookArray then
                    podInst.subimage = 2
                else
                    podInst.subimage = 1
                    if podInst:collidesWith(nearestPlayer, podInst.x, podInst.y) and input.checkControl("enter", nearestPlayer) == input.PRESSED then
                        local arrayInst = fuelArray:create(podInst.x + (podInst.sprite.width/2), podInst.y - (podInst.sprite.height/2))
                        data.tookArray = true
                    end
                end
            end
        end
    end
end)

callback.register("onDraw", function()
    for _, podInst in ipairs(pod:findAll()) do
        local data = podInst:getData()
        local nearestPlayer = player:findNearest(podInst.x, podInst.y)
        if nearestPlayer:get("activity") < 30 then
            if data.phase == 0 then
                if podInst:collidesWith(nearestPlayer, podInst.x, podInst.y) then
                    graphics.printColor("&w&Press &y&'"..input.getControlString("enter").."'&w& to open panel&!&", podInst.x, podInst.y - podInst.sprite.height, graphics.FONT_DEFAULT)
                end
            elseif data.phase == 2 then
                if podInst:collidesWith(nearestPlayer, podInst.x, podInst.y) then
                    if data.tookArray == false then
                        graphics.printColor("&w&Press &y&'"..input.getControlString("enter").."'&w& to take Fuel Array&!&", podInst.x , podInst.y - podInst.sprite.height, graphics.FONT_DEFAULT)
                    end 
                end
            end
        end
    end
end)
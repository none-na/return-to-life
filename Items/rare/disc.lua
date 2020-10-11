--RoR2 Demake Project
--Made by Sivelos
--disc.lua
--File created 2020/01/22

local disc = Item("Resonance Disc")
disc.pickupText = "Obtain a Resonance Disc charged by killing enemies. Fires automatically when fully charged."

disc.sprite = Sprite.load("Items/rare/Graphicsdisc.png", 1, 16, 16)
disc:setTier("rare")

disc:setLog{
    group = "rare",
    description = "Killing enemies charges the Resonance Disc. The disc launches itself toward a target for &y&300%&!& base damage, piercing all enemies it doesn't kill, and then explodes for &y&1000%&!& base damage. Returns to the user, striking all enemies along the way for &y&300%&!& base damage.",
    story = "---",
    destination = "---,\n---,\n---",
    date = "--/--/2056"
}

local sprites = {
    disc = Sprite.load("DiscIdle", "Graphics/disc", 12, 2.5, 2.5),
    impact1 = Sprite.load("DiscImpact1", "Graphics/discImpact1", 5, 22, 20),
    impact2 = Sprite.load("DiscImpact2", "Graphics/discImpact2", 5, 15, 17),
}

local sounds = {
    fire = Sound.find("Drill", "vanilla"),
    impact = Sound.find("WormExplosion", "vanilla"),
}

local spinPerKill = 2.5
local actors = ParentObject.find("actors", "vanilla")
local players = Object.find("p", "vanilla")

local resonanceDisc = Object.new("ResonanceDisc")
resonanceDisc.sprite = sprites.disc

local DiscInit = function(inst)
    local data = inst:getData()
    data.charge = 0
    data.maxCharge = 100
    data.spin = 0
    data.phase = 0
    data.cooldown = -1
    data.timeSinceLastKill = -1
    data.target = nil
    data.bob = 0
    data.f = 0
    data.fireProj = false
    data.fireExp = false
    data.speed = 2
    data.attackAnim = 0
    data.xOffset = math.random(-25, 25)
    data.yOffset = math.random(-25, -10)
    data.parent = players:findNearest(inst.x, inst.y)

end
local DiscStep = function(inst)
    local data = inst:getData()
    if data.parent and not data.parent:isValid() then
        inst:destroy()
        return
    end
    local count = 1
    if type(data.parent) == "PlayerInstance" then
        count = data.parent:countItem(disc)
    elseif GlobalItem.actorIsInit(data.parent) then
        count = GlobalItem.countItem(data.parent, disc)
    end
    if data.cooldown > -1 then
        data.cooldown = data.cooldown - 1
    end
    data.f = data.f + 1
    if data.phase == 0 then --idle
        inst.spriteSpeed = math.clamp(data.spin * 0.2, 0, 1)
        data.bob = data.bob + 0.1
        inst.x = math.approach(inst.x, data.parent.x + (data.xOffset * data.parent.xscale), data.speed)
        inst.y = math.approach(inst.y, data.parent.y + (data.yOffset + math.sin(data.bob)), data.speed)    
        data.timeSinceLastKill = data.timeSinceLastKill + 1
        data.spin = math.max(0, data.spin - (1.25 * data.timeSinceLastKill % 60))
        data.charge = data.charge + data.spin
        ---------------------------------------
        local nearest = nil
        local d = math.huge
        for _, a in ipairs(actors:findMatchingOp("team", "~=", data.parent:get("team"))) do
            if a and a:isValid() then
                if a ~= data.parent then
                    if a:get("team") ~= "neutral" or a:get("team") ~= "newtral" then
                        local e = Distance(data.parent.x, data.parent.y, a.x, a.y)
                        if e <= d then
                            nearest = a
                        end
                    end
                end
            end
        end
        if nearest and nearest:isValid() then
            if data.charge >= data.maxCharge then
                data.dist = Distance(inst.x, inst.y, nearest.x, nearest.y)
                data.angle = GetAngleTowards(nearest.x, nearest.y, inst.x, inst.y)
                data.attackAnim = 10
                data.cooldown = data.cooldown + 60
                data.charge = data.charge - 100
                data.fireProj = false
                data.fireExp = false
                data.targetX = nearest.x
                data.targetY = nearest.y
                data.initX = inst.x
                data.initY = inst.y
                inst.alpha = 0
                data.phase = 1
                return
            end
        end
    elseif data.phase == 1 or data.phase == 3 then --flying towards target
        if data.attackAnim > 0 then
            data.attackAnim = data.attackAnim - 1
        else
            data.attackAnim = 20
            data.fireExp = false
            data.phase = (data.phase + 1) % 4
            if data.phase == 0 then
                inst.alpha = 1
            end
            return
        end
        if not data.fireProj then
            sounds.fire:play(0.9 + math.random() * 0.2)
            local b = data.parent:fireBullet(data.initX, data.initY, data.angle, data.dist, 3 * count, sprites.impact2, DAMAGER_BULLET_PIERCE)
            data.fireProj = true
        end
    elseif data.phase == 2 then
        if not data.fireExp then
            misc.shakeScreen(30)
            local e = data.parent:fireExplosion(data.targetX, data.targetY, 2, 9.5, 10 * count, sprites.impact1, nil)
            if IsOnScreen(data.parent, {x = data.targetX, y = data.targetY}) then
                sounds.impact:play()
            end
            data.fireExp = true
        end
        if data.attackAnim > 0 then
            data.attackAnim = data.attackAnim - 1
        else
            local xx = data.parent.x + (data.xOffset * data.parent.xscale)
            local yy = data.parent.y + (data.yOffset + math.sin(data.bob))
            data.attackAnim = 10
            data.dist = Distance(data.targetX, data.targetY, xx, yy)
            data.angle = GetAngleTowards(xx, yy, data.targetX, data.targetY)
            data.fireProj = false
            data.initX = data.targetX
            data.initY = data.targetY
            data.targetX = xx
            data.targetY = yy
            data.phase = 3
            return
        end
    end
    ---------------------------------------
    
end
local DiscDraw = function(inst)
    local data = inst:getData()
    local color = Color.fromRGB(255, 81, 255)
    if data.phase == 0 then
        local radius = 10
        ----------------------------------------------------
        graphics.color(color)
        local r2 = ((radius+ math.sin(data.f)) * (math.clamp(data.charge, 0, data.maxCharge) / data.maxCharge))
        graphics.alpha(0.3)
        graphics.circle(inst.x, inst.y, r2, false)
        graphics.circle(inst.x, inst.y, r2 * 0.6, false)
        graphics.color(Color.WHITE)
        graphics.circle(inst.x, inst.y, r2 * 0.3, false)
        ----------------------------------------------------
        graphics.color(color)
        graphics.alpha(0.5)
        graphics.circle(inst.x, inst.y, radius, true)
    elseif data.phase == 1 or data.phase == 3 then
        graphics.color(color)
        graphics.line(data.initX, data.initY, data.targetX, data.targetY, data.attackAnim)
    end
end

resonanceDisc:addCallback("create", function(this)
    DiscInit(this)
end)
resonanceDisc:addCallback("step", function(this)
    DiscStep(this)
end)
resonanceDisc:addCallback("draw", function(this)
    DiscDraw(this)
end)

callback.register("onNPCDeathProc", function(npc, player)
    for _, inst in ipairs(resonanceDisc:findAll()) do
        if inst.id == player:get("disc") then
            local data = inst:getData()
            data.spin = data.spin + spinPerKill
            data.timeSinceLastKill = 0
        end
    end
end)

disc:addCallback("pickup", function(player)
    if not (player:get("disc") and Object.findInstance(player:get("disc"))) then
        local d = resonanceDisc:create(player.x, player.y)
        d:getData().parent = player
        d:set("persistent", 1)
        player:set("disc", d.id)
    end
end)

callback.register("onStageEntry", function()
    for _, d in ipairs(resonanceDisc:findAll()) do
        local data = d:getData()        
        local parent = data.parent
        if parent then
            d.x = parent.x
            d.y = parent.y
        end
        data.charge = 0
        data.spin = 0
        data.phase = 0
        data.cooldown = -1
        data.timeSinceLastKill = -1
        data.fireProj = false
        data.fireExp = false
    end
end)

GlobalItem.items[disc] = {
    apply = function(inst, count)
        if not (inst:get("disc") and Object.findInstance(inst:get("disc"))) then
            local d = resonanceDisc:create(inst.x, inst.y)
            d:getData().parent = inst
            d:set("persistent", 1)
            inst:set("disc", d.id)
        end
    end,
    kill = function(inst, count, damager, hit, x, y)
        for _, d in ipairs(resonanceDisc:findAll()) do
            if d.id == inst:get("disc") then
                local data = d:getData()
                data.spin = data.spin + spinPerKill
                data.timeSinceLastKill = 0
            end
        end
    end,
    destroy = function(inst, count)
        local d = Object.findInstance(inst:get("disc"))
        if d then d:destroy() return end
    end
}
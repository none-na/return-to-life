--RoR2 Demake Project
--Made by Sivelos
--blastShower.lua
--File created 2019/09/29

local cleanse = Item("Blast Shower")
cleanse.pickupText = "Cleanse all negative status ailments."

cleanse.sprite = Sprite.load("Items/use/GraphicsblastShower.png", 2, 14, 16)

cleanse.isUseItem = true
cleanse.useCooldown = 20

cleanse:setTier("use")
cleanse:setLog{
    group = "use",
    description = "Removes all &y&negative status ailments&!&, including damage over time.",
    story = "Everything a would-be wilderness survivor would need, and all in a stylish leather backpack. Thing contains matches, flares, and even a neat chemical bath that'll remove even the toughest poisons out there. But hey, don't go and get bitten by a cobra or something just to test it out, y'here? Things are expensive.",
    destination = "PO Box 12-B,\nFrost Valley,\nEarth",
    date = "2/04/2056"
}

local affectedBuffs = {
    Buff.find("slow", "vanilla"),
    Buff.find("slow2", "vanilla"),
    Buff.find("thallium", "vanilla"),
    Buff.find("snare", "vanilla"),
    Buff.find("sunder1", "vanilla"),
    Buff.find("sunder2", "vanilla"),
    Buff.find("sunder3", "vanilla"),
    Buff.find("sunder4", "vanilla"),
    Buff.find("sunder5", "vanilla"),
    Buff.find("oil", "vanilla"),
    Buff.find("Grieving", "RoR2Demake"),
    Buff.find("iceSlow", "RoR2Demake"),
    Buff.find("treeBotSnare", "RoR2Demake"),
    Buff.find("treebotDebuff", "RoR2Demake"),
}

AddBuffToBlastShower = function(buff)
    table.insert(affectedBuffs, buff)
end

local assets = {
    animation = nil,
    sound = Sound.load("cleanse", "Sounds/SFX/cleanse.ogg")
}

local CleanseProc = function(actor, embryo)
    assets.sound:play(1 + math.random() * 0.05)
    local flash = Object.find("EfFlash", "vanilla"):create(actor.x, actor.y)
    flash:set("parent", actor.id)
    flash:set("image_blend", Color.WHITE.gml)
    flash.depth = actor.depth - 1
    for i = 0, math.random(5, 20) do
        ParticleType.find("PixelDust", "vanilla"):burst("middle", actor.x, actor.y + (actor.sprite.height / 2), 1)
    end
    for _, buff in ipairs(affectedBuffs) do
        if buff then
            actor:removeBuff(buff)
        end
    end
    Burned.Clear(actor)
    local immunity = 15
    if embryo then
        immunity = 30
    end
    actor:getAccessor().invincible = actor:getAccessor().invincible + immunity
end

cleanse:addCallback("use", function(player, embryo)
    CleanseProc(player, embryo)
end)

GlobalItem.items[cleanse] = {
    use = function(actor, embryo)
        CleanseProc(actor, embryo)
    end
}
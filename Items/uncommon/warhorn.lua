--RoR2 Demake Project
--Made by Sivelos
--warhorn.lua
--File created 2019/07/1

local warhorn = Item("War Horn")
warhorn.pickupText = "Activating your Use Item gives you a burst of attack speed."

warhorn.sprite = restre.spriteLoad("Graphics/warhorn.png", 1, 16, 16)
warhorn:setTier("uncommon")

warhorn:setLog{
    group = "uncommon",
    description = "Activating your Use Item gives you &y&+70% attack speed&!& for &y&8s&!&.",
    story = "The War of 2019, while lasting only a brief year, was the bloodiest conflict in human history. As the war got deadlier throughout the year, many rebel groups began to rely on tradition and history for inspiration. The War Horn, pictured above was a favorite of the Northern Fist Rebellion for both its inspirational and tactical uses.",
    destination = "Jungle VII,\nMuseum of 2019,\nEarth",
    date = "4/12/2056"
}

local warhornBuff = Buff.new("burstAttackSpeed")
warhornBuff.sprite = restre.spriteLoad("EfWarhornBuff","Graphics/warhorn", 1, 9, 7.5)

local procSound = restre.soundLoad("Warhorn", "Sounds/SFX/warhorn.ogg")

local circle = Object.find("EfCircle", "vanilla")

local procAnim = {}

warhornBuff:addCallback("start", function(actor)
    actor:set("attack_speed", actor:get("attack_speed") + 0.7)
end)

warhornBuff:addCallback("step", function(actor)
    if procSound:isPlaying() and procAnim[actor] > -1 then
        procAnim[actor] = procAnim[actor] - 1
        if procAnim[actor] % 10 == 0 then
            circle:create(actor.x, actor.y)
        end
        misc.shakeScreen(1)
    end
end)

warhornBuff:addCallback("end", function(actor)
    actor:set("attack_speed", actor:get("attack_speed") - 0.7)
end)

registercallback("onUseItemUse", function(player, item)
    if player:countItem(warhorn) > 0 then
        if player:getAlarm(0) > -1 then
            if not procSound:isPlaying() then
                procSound:play(0.9 + math.random() * 0.1)
                procAnim[player] = 30
            end
            player:applyBuff(warhornBuff, (8*60) + ((4*60) * (player:countItem(warhorn) - 1)))
        end
    end
end)

GlobalItem.items[warhorn] = {
    activation = function(inst, count)
        if not procSound:isPlaying() then
            procSound:play(0.9 + math.random() * 0.1)
            procAnim[inst] = 30
        end
        inst:applyBuff(warhornBuff, (8*60) + ((4*60) * (count - 1)))
    end
}
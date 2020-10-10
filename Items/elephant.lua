--RoR2 Demake Project
--Made by Sivelos
--elephant.lua
--File created 2020/01/10

local elephant = Item("Jade Elephant")
elephant.pickupText = "Gain massive armor for 5 seconds."

elephant.sprite = Sprite.load("Items/elephant.png", 2, 16, 16)
elephant:setTier("use")

elephant.isUseItem = true
elephant.useCooldown = 45

elephant:setLog{
    group = "use",
    description = "Gain &y&500 armor&!& for &b&5 seconds&!&.",
    story = "---",
    destination = "---\n---\n---",
    date = "--/--/2056"
}

local sound = Sound.load("elephant", "Sounds/SFX/elephant.ogg")

local icon = Sprite.load("Graphics/elephantBuff", 1, 9, 4.5)

local buff = Buff.new("Elephant")
buff.sprite = icon

buff:addCallback("start", function(actor)
    actor:set("armor", actor:get("armor") + 500)
end)
buff:addCallback("end", function(actor)
    actor:set("armor", actor:get("armor") - 500)
end)

elephant:addCallback("use", function(player, embryo)
    if sound then
        sound:play(0.9 + math.random() * 0.2, 0.5)
    end
    if embryo then
        player:applyBuff(buff, 7.5*60)
    else
        player:applyBuff(buff, 5*60)
    end
end)
GlobalItem.items[elephant] = {
    use = function(inst, embryo)
        if sound then
            sound:play(0.9 + math.random() * 0.2, 0.5)
        end
        if embryo then
            inst:applyBuff(buff, 7.5*60)
        else
            inst:applyBuff(buff, 5*60)
        end
    end,
}
--RoR2 Demake Project
--Made by Sivelos
--healingRack.lua
--File created 2019/05/15

local rejuvRack = Item("Rejuvination Rack")
rejuvRack.pickupText = "Increases strength of healing."

rejuvRack.sprite = restre.spriteLoad("Graphics/healingRack.png", 1, 16, 16)

rejuvRack:setTier("rare")
rejuvRack:setLog{
    group = "rare",
    description = "Increases &b&potency of healing&!& by &b&100%&!&.",
    story = "This \'god\' of yours wasn't so tough. Took a few bullets and it went down just like that. Its horns seemed to be the source of its life-giving powers... As I'm writing this, I have the horns on the ground next to me. The beast put up a fight, and left a nasty scratch on my arm. And yet, within just a few inches of the horns, that scratch healed up in seconds. I'm sure a few bonds will be enough payment... Don't you agree?",
    destination = "Irontown,\nMononoke Province,\nOuter Rim System",
    date = "3/3/2056"
}

rejuvRack:addCallback("pickup", function(player)
    player:set("hp_regen", player:get("hp_regen") * 2)
end)

IRL.setRemoval(rejuvRack, function(player)
    adjust(player, "hp_regen", -player:get("hp_regen"))
end)


registercallback("onPlayerStep", function(player)
    if player:isValid() then
        if player:countItem(rejuvRack) > 0 then
            local playerA = player:getAccessor()
		    local hpDelta = (playerA.hp - playerA.lastHp) - playerA.hp_regen
		    if hpDelta > 0 then
                playerA.hp = playerA.hp + (hpDelta * player:countItem(rejuvRack))
            end
        end
    end
end)

GlobalItem.items[rejuvRack] = {
    apply = function(inst, count)
        inst:set("hp_regen", math.pow(inst:get("hp_regen"), count+1))
    end,
    step = function(inst, count)
        local playerA = inst:getAccessor()
        local hpDelta = (playerA.hp - playerA.lastHp) - playerA.hp_regen
        if hpDelta > 0 then
            playerA.hp = playerA.hp + (hpDelta * count)
        end
    end,
}
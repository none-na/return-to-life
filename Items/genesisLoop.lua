--RoR2 Demake Project
--Made by Sivelos
--genesisLoop.lua
--File created 2020/01/20

local sprites = {
    active = Sprite.load("Items/genesisLoop", 1, 16, 16),
    cooldown = Sprite.load("Items/genesisLoop2", 1, 16, 16),
}

local loop = Item("Genesis Loop")
loop.pickupText = "Fire an electric nova at low health."

loop.sprite = sprites.active

loop.color = "y"

loop:setLog{
    group = "boss",
    description = "Falling below &r&25% health&!& causes you to explode, dealing &y&6000% base damage&!&. Recharges every &b&30 seconds.&!&",
    story = "---",
    destination = "---,\n---,\n---",
    date = "--/--/2056"
}

local nova = Object.find("VagrantNova", "RoR2Demake")

callback.register("onPlayerStep", function(player)
    local data = player:getData()
    if player:countItem(loop) > 0 then
        if data.loopCooldown then
            if data.loopCooldown > -1 then
                player:setItemSprite(loop, sprites.cooldown)
                -------------------
                data.loopCooldown = data.loopCooldown - 1
    
            else
                player:setItemSprite(loop, sprites.active)
                -------------------
                if player:get("hp") <= math.round(player:get("maxhp")/4) then
                    local n = nova:create(player.x, player.y)
                    n:getData().parent = player
                    data.loopCooldown = ((30*60) / player:countItem(loop))
                end
            end
        else
            data.loopCooldown = -1
        end
    end
end)

GlobalItem.items[loop] = {
    step = function(inst, count)
        local data = inst:getData()
        if inst:countItem(loop) > 0 then
            if data.loopCooldown then
                if data.loopCooldown > -1 then
                    data.loopCooldown = data.loopCooldown - 1
                else
                    if inst:get("hp") <= math.round(inst:get("maxhp")/4) then
                        local n = nova:create(inst.x, inst.y)
                        n:getData().parent = inst
                        data.loopCooldown = ((30*60) / inst:countItem(loop))
                    end
                end
            else
                data.loopCooldown = -1
            end
        end
    end,
}
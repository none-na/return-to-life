--RoR2 Demake Project
--Made by Sivelos
--armorPlate.lua
--File created 2020/04/29

local item = Item("Repulsion Armor Plate")
item.pickupText = "Recieve flat damage reduction from all attacks."

item.sprite = restre.spriteLoad("Graphics/armorPlate.png", 1, 16, 16)

item:setTier("common")
item:setLog{
    group = "common",
    description = "Reduce all &y&incoming damage&!& by &y&5&!&. Cannot be reduced below &y&1.&!&",
    story = "Luckily no one was hurt during the shootout. Just a few rough characters at the bar by the docks. Nothing we couldn’t handle. Jaime took a shot to his shoulder but his armor took all the impact. We’ll need to order him a replacement part before he can go back out in the field.\n\nThe segmented design is nice because I don’t have to shell out the cash for a whole new set. Frankly, the station’s coffers have seen better days. The next time a rookie damages their equipment they might be looking at a desk job for a while.",
    destination = "System Police Station 13,\nPort of Marv,\nGanymede",
    date = "8/15/2056"
}

local dmg = Object.find("EfDamage", "vanilla")
local damageManager = Object.new("DamageManager")

damageManager:addCallback("create", function(self)
    local data = self:getData()
    data.life = 20
    data.stack = 1
    data.max = 1
    data.parent = nil
end)
damageManager:addCallback("step", function(self)
    local data = self:getData()
    data.life = data.life - 1
    local damageInst = dmg:findNearest(self.x, self.y)
    if damageInst then
        damageInst:set("damage_fake", damageInst:get("damage") - math.clamp(5*data.stack, 0, math.abs(data.max-1)))
        data.life = -1
    end
    if data.life <= -1 or not data.parent then self:destroy() return end
end)

callback.register("onPlayerStep", function(player)
    local stack = player:countItem(item)
    local hpDelta = player:get("hp") - player:get("lastHp")
    if hpDelta < 0 then
        player:set("hp", player:get("hp") + math.clamp(5*stack, 0, math.abs(hpDelta) - 1))
        local i = damageManager:create(player.x, player.y)
        i:getData().stack = stack
        i:getData().max = hpDelta
        i:getData().parent = player
    end
end)
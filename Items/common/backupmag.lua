--RoR2 Demake Project
--Made by N4K0
--backupmag.lua
--File created 2019/04/07

require("Libraries.abilitylib")

local backupMag = Item("Backup Magazine")
backupMag.pickupText = "Add an extra use to your second skill."

backupMag.sprite = Sprite.load("Items/common/Graphics/backupmag.png", 1, 16, 16)

backupMag:setTier("common")
backupMag:setLog{
    group = "common",
    description = "Add an &y&extra use&!& to your second skill.",
    story = "It's almost Christmas. Mom, Dad, and I put our money together to get you this... Sorry if it gets to you late. Damn UES Priority costs are way too high, I tell you. I don't know if this ammo matches what you're using down there, but we hope it helps. Love you, and see you soon after everything blows over.",
    destination = "1024-B,\nFort Timothy,\nCeres System",
    date = "12/07/2056"
}

backupMag:addCallback("pickup", function(player)
    Ability.AddCharge(player, "x", 1)
end)

IRL.setRemoval(backupMag, function(player)
    if Ability.getMaxCharge(player, "x") < 2 then
        Ability.Disable(player, "x")
    else
        Ability.AddCharge(player, "x", -1)
    end
end)
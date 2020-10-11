--RoR2 Demake Project
--Made by Sivelos
--key.lua
--File created 2019/05/13

local key = Item("Rusted Key")
key.pickupText = "Gain access to a hidden lockbox containing treasure."

key.sprite = Sprite.load("Items/key.png", 1, 16, 16)
key:setTier("common")

key:setLog{
    group = "common",
    description = "Gain access to a rusted lockbox containing treasure.",
    story = "I don't trust the UESC. Not one bit. Their Security Chests? Full of overrides and backdoors- I've got a cousin working in their factory, and they've got all kinds of weird things going on in those chests. I've seen so many of them at auctions - for the lost and unclaimed ones - and you just pay money, and it springs open on the spot. Are you kidding me?\n\nAnyways, I'm sending you exactly what I said I would - but it's too important to leave the security up to the UESC. So I'm sending the key to you - and the lockbox to Margaret. Like a two-factor authentication. Let me know when you get this.",
    destination = "|||||||,\nDruid Hills,\nEarth",
    date = "1/21/2056"
}


local checkForKeys = function()
    local keys = 0
    for _, player in ipairs(misc.players) do
        keys = keys + player:countItem(key)
    end
    if keys == 0 then
        return true
    else
        return false
    end
end

local openSnd = Sound.find("Chest0", "vanilla")

local common = ItemPool.find("common", "vanilla")
local uncommon = ItemPool.find("uncommon", "vanilla")
local rare = ItemPool.find("rare", "vanilla")

function GetLockBoxItem()
    local item = nil
    local com, unc, rre
    local keys = 0
    for _, player in ipairs(misc.players) do
        keys = keys + player:countItem(key)
    end
    if keys <= 0 then
        keys = 1
    end

    local netRarity = (80 + (20*keys) + (keys*keys))

    com = 80 / netRarity
    unc = (20 * keys) / netRarity
    rre = (keys*keys) / netRarity
    local chance = math.random()
    if chance < rre then
        item = rare:roll()
    elseif chance < unc then
        item = uncommon:roll()
    else
        item = common:roll()
    end

    return item
end
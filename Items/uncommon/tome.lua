--RoR2 Demake Project
--Made by Sivelos
--tome.lua
--File created 2020/01/22

local tome = Item("Ghor's Tome")
tome.pickupText = "Chance on kill to drop a treasure."

tome.sprite = Sprite.load("Items/uncommon/Graphicstome.png", 1, 16, 16)
tome:setTier("uncommon")

tome:setLog{
    group = "uncommon",
    description = "&b&4%&!& chance on kill to drop a treasure worth &b&$25&!&. &b&Scales over time.&!&",
    story = "The very first print of your script! I'm telling you, this thing will sell like hot cakes. You'll be rich!\n\n...And, of course, we'll get the customary 10% of all earnings.",
    destination = "Seattle,\nOld Colony",
    date = "5/5/2056"
}

local sprites = {
    gold = Sprite.find("EfGold6", "vanilla")
}

local sounds = {
    proc = Sound.find("Crit", "vanilla")
}

local objects = {
    p = Object.find("P", "vanilla")
}

local treasure = Object.new("GoldNugget")
treasure.sprite = sprites.gold

treasure:addCallback("create", function(this)
    local data = this:getData()
    data.value = 25 * Difficulty.getScaling("cost")
    data.phase = 0
    this:set("vx", 0)
    this:set("vy", 0)
    this:set("ay", 0.1)
end)
treasure:addCallback("step", function(this)
    local data = this:getData()
    if data.phase == 0 then
        PhysicsStep(this)
        if this:collidesMap(this.x, this.y) then
            data.phase = 1
        end
    elseif data.phase == 1 then
        local nearest = objects.p:findNearest(this.x, this.y)
        if nearest and nearest:isValid() then
            if nearest:collidesWith(this, nearest.x, nearest.y) then
                sounds.proc:play(0.9 + math.random() * 0.2)
                misc.setGold(misc.getGold() + data.value)
                this:destroy()
                return
            end
        end
    end
end)


local SyncAmmoPack = net.Packet.new("Sync Tome Treasure", function(player, x, y, vx, vy)
    local inst = treasure:create(x, y)
    inst:set("vx", vx)
        :set("vy", vy)
end)

registercallback("onNPCDeathProc", function(npc, actor)
    if actor:isValid() then
        if actor:countItem(tome) > 0 then
            if net.host then
                local chance = 0.04 * actor:countItem(tome)
                if math.random() <= chance then
                    local t = treasure:create(npc.x, npc.y - 16)
                    t:set("vx", math.random(-2, 2))
                    t:set("vy", math.random(-2, 0))
                    if net.online then
                        SyncAmmoPack:sendAsHost(net.ALL, nil, npc.x, npc.y, t:get("vx"), t:get("vy"))
                    end
                end
            end
            
        end
    end
end)
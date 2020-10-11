--RoR2 Demake Project
--Made by Sivelos
--bandolier.lua
--File created 2019/05/23

local bandolier = Item("Bandolier")
bandolier.pickupText = "Chance on kill to drop an ammo pack that resets cooldowns."

bandolier.sprite = Sprite.load("Items/uncommon/Graphicsbandolier.png", 1, 16, 16)

bandolier:setTier("uncommon")
bandolier:setLog{
    group = "uncommon",
    description = "8% on kill to drop an &y&ammo pack&!& that &b&resets cooldowns&!&.",
    story = "How's it going? I know you started training to be a hunter recently, so I figured I'd scrounge up some money to buy you a present. Not sure what kind of ammo you guys use - if you use any at all - but here's a place to put it when your hands are full. It even comes with some complimentary ammo packs! I hope you can make good use of them.\n\nSee you soon,\nMark",
    destination = "Hunter's Guild,\nAthena Mons,\nMercury",
    date = "11/11/2056"
}

local sprites = {
    idle = Sprite.load("Graphics/ammo", 1, 3, 4),
    mask = Sprite.load("Graphics/ammoMask", 1, 3, 4),
}

local sounds = {
    pickup = Sound.find("Reload", "vanilla")
}

local actors = ParentObject.find("actors", "vanilla")

local ammoPack = Object.new("ammoPack")
local fx = ParticleType.find("Heal", "vanilla")
ammoPack.sprite = sprites.idle

ammoPack:addCallback("create", function(self)
    self.spriteSpeed = 0.25
    self.mask = sprites.mask
    self:set("vx", math.random(-3, 3))
    self:set("vy", math.random(-4, -2))
    self:set("ay", 0.25)
    self:set("refreshed", 0)
    self:set("rotate", math.random(1, 4))
    self:set("life", 5*60)
end)

ammoPack:addCallback("step", function(self)
    if self:get("life") <= 0 then
        self.alpha = self.alpha - 0.01
        if self.alpha <= 0 then
            self:destroy()
        end
    else
        self.x = self.x + (self:get("vx") or 0)
		self.y = self.y + (self:get("vy") or 0)	
		self:set("vx", (self:get("vx") or 0) + (self:get("ax") or 0))
		self:set("vy", (self:get("vy") or 0) + (self:get("ay") or 0))
		if self:get("vx") > 0 then self:set("direction", 1)
		elseif self:get("vx") < 0 then self:set("direction", -1)
		else self:set("direction", 0) end
		if self:get("rotate") ~= nil then
			self.yscale = 1
			self.xscale = 1
			local _pvx = self:get("vx") or 0
			local _pvy = -(self:get("vy") or 0)
			local _angle = math.atan(_pvy/_pvx)*(180/math.pi)
			if _pvx < 0 then _angle = _angle + 180 end
			self.angle = (self:get("rotate") + _angle)%360
        end
        if self:collidesMap(self.x,self.y + (self.sprite.height/4)) then
            self.angle = 0
            self:set("vx", 0)
            self:set("vy", 0)
            --self:set("ay", 0)
        end
        self:set("life", self:get("life") - 1)
        for _, actor in ipairs(actors:findAll()) do
            if self:isValid() and self:collidesWith(actor, self.x, self.y) and self:get("refreshed") == 0 then
                if isa(actor, "PlayerInstance") then
                    fx:burst("middle", actor.x, actor.y, 4)
                    sounds.pickup:play(0.8 + math.random() * 0.2)
                    for i = 2, 5 do
                        if actor:getAlarm(i) > -1 then
                            actor:setAlarm(i, -1)
                        end
                    end
                    
                    self:set("refreshed", 1)
                    self:destroy()
                end
            end
        end
    end
end)

local SyncAmmoPack = net.Packet.new("Sync Ammo Pack", function(player, x, y, vx, vy, rotate)
    local inst = ammoPack:create(x, y)
    inst:set("vx", vx)
        :set("vy", vy)
        :set("rotate", rotate)
end)

registercallback("onNPCDeathProc", function(npc, actor)
    if actor:isValid() then
        if actor:countItem(bandolier) > 0 then
            if net.host then
                local chance = (1 / (math.pow((actor:countItem(bandolier) + 1), 0.33)))
                if math.random() >= chance then
                    local ammoInst = ammoPack:create(npc.x, npc.y)
                    if net.online then
                        SyncAmmoPack:sendAsHost(net.ALL, nil, npc.x, npc.y, ammoInst:get("vx"), ammoInst:get("vy"), ammoInst:get("rotate"))
                    end
                end
            end
            
        end
    end
end)

GlobalItem.items[bandolier] = {
    kill = function(inst, count, damager, hit, x, y)
        if net.host then
            local chance = (1 / (math.pow((count + 1), 0.33)))
            if math.random() >= chance then
                local ammoInst = ammoPack:create(hit.x, hit.y)
                if net.online then
                    SyncAmmoPack:sendAsHost(net.ALL, nil, hit.x, hit.y, ammoInst:get("vx"), ammoInst:get("vy"), ammoInst:get("rotate"))
                end
            end
        end
    end,
}
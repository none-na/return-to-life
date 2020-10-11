local TELEPORTER = Object.find("Teleporter", "Vanilla")
local PLAYER_OBJECT = Object.find("P", "Vanilla")

local sprites = {
	sparks = restre_spriteLoad("tpSparks", 8, 6, 4),
}

local sounds = {
	tp       = Sound.find("Teleporter", "Vanilla"),

	complete = restre_soundLoad("tpActivate.ogg"),
	activate = restre_soundLoad("tpCharge.ogg"),
}

local tpSpark = ParticleType.find("Sparks", "RTSCore")

local sparks = ParticleType.new("TeleporterSparks")
sparks:sprite(sprites.spark, true, true, false)
sparks:additive(true)
sparks:life(15, 15)
sparks:angle(0, 360, 0, 0, false)

if true then
	return nil
end

local tpFX = Object.new("EfTeleporterAura")
tpFX:addCallback("create", function(self)
    self:set("f", 0)
    self:set("alpha", 0)
    self:set("phase", 0)
    local data = self:getData()
    if not data.parent then
        data.parent = teleporter:findNearest(self.x, self.y)
    end
end)
tpFX:addCallback("step", function(self)
    local data = self:getData()
    if self:get("phase") == 0 then
        self:set("f", (self:get("f") + 1))
        if self:get("f") >= 120 then
            Object.find("WhiteFlash", "vanilla"):create(self.x, self.y)
            sounds.tp:play(1 + math.random() * 0.05)
            self:set("phase", 1)
        end
    elseif self:get("phase") == 1 then
        self:set("f", (self:get("f") + 1))
        if self:get("f") % 15 == 0 then
            tpSpark:burst("above", self.x + math.random(-data.parent.sprite.width/2, data.parent.sprite.width/2), self.y + math.random(-data.parent.sprite.width/2, data.parent.sprite.width/2), 1, Color.RED)
        end
        if self:get("f") > 100 then
            self:set("f", 0)
        end
        if data.parent then
            if data.parent:get("time") >= data.parent:get("maxtime") then
                Object.find("WhiteFlash", "vanilla"):create(self.x, self.y)
                sounds.tp:play(1 + math.random() * 0.05)
                self:set("phase", 2)
            end
        end

    elseif self:get("phase") == 2 then
        self:set("f", (self:get("f") + 1))
        if self:get("f") % 15 == 0 then
            tpSpark:burst("above", self.x + math.random(-data.parent.sprite.width/3, data.parent.sprite.width/3), self.y + math.random(-data.parent.sprite.width/3, data.parent.sprite.width/3), 1, Color.RED)
        end
        if self:get("alpha") <= 0 then
            self:set("phase", 3)
        end
    elseif self:get("phase") == 3 then
        self:set("f", (self:get("f") + 1))
        if self:get("f") % 15 == 0 then
            tpSpark:burst("above", self.x + math.random(-data.parent.sprite.width/3, data.parent.sprite.width/3), self.y + math.random(-data.parent.sprite.width/3, data.parent.sprite.width/3), 1, Color.RED)
        end
    end
end)
tpFX:addCallback("draw", function(self)
    if self:get("phase") == 0 then
        graphics.setBlendMode("additive")
        self:set("alpha", math.clamp(self:get("alpha") + 0.01, 0, 0.5))
        graphics.alpha(self:get("alpha"))
        graphics.color(Color.RED)
        graphics.circle(self.x, self.y, 5 + math.sin(self:get("f")), false)
        graphics.color(Color.ROR_RED)
        graphics.circle(self.x, self.y, 3 + math.cos(self:get("f")), false)
        graphics.setBlendMode("normal")

    elseif self:get("phase") == 1 then
        graphics.setBlendMode("additive")
        graphics.alpha(0.5)
        graphics.color(Color.RED)
        graphics.circle(self.x, self.y, 6 + (math.sin(self:get("f"))/10), false)
        graphics.line(self.x + 1.5, self.y+1, self.x + 1.5, 0, 3)
        graphics.color(Color.ROR_RED)
        graphics.circle(self.x, self.y, 4 + (math.cos(self:get("f"))/7), false)
        graphics.circle(self.x, self.y, 2 + (math.cos(self:get("f"))), false)
        graphics.line(self.x + 1.5, self.y, self.x + 1.5, 0, 1)
        graphics.setBlendMode("normal")
    elseif self:get("phase") == 2 then
        graphics.setBlendMode("additive")
        self:set("alpha", math.clamp(self:get("alpha") - 0.01, 0, 0.5))
        graphics.alpha(self:get("alpha"))
        graphics.color(Color.RED)
        graphics.circle(self.x, self.y, 6 + (math.sin(self:get("f"))/10), false)
        graphics.line(self.x + 1.5, self.y-4, self.x + 1.5, 0, 3)
        graphics.color(Color.ROR_RED)
        graphics.circle(self.x, self.y, 3 + (math.cos(self:get("f"))/13), false)
        graphics.line(self.x + 1.5, self.y-1, self.x + 1.5, 0, 1)
        graphics.setBlendMode("normal")
    end
end)

callback.register("onStep", function()
    for _, tp in ipairs(teleporter:findAll()) do
        local data = tp:getData()
        local closestPlayer = player:findNearest(tp.x, tp.y)
        if tp:collidesWith(closestPlayer, tp.x, tp.y) and (input.checkControl("enter", closestPlayer) == input.PRESSED or (tp:get("epic") == 1 and input.checkControl("swap", closestPlayer) == input.PRESSED)) and closestPlayer:get("activity") ~= 99 then
            if tp:get("active") == 3 and not data.madeNoise then
                if not tp:getData().noEffects then
                    sounds.complete:play(1 + math.random() * 0.05)
                    data.madeNoise = true
                end
            elseif tp:get("time") <= 0 then
                if not tp:getData().noEffects then
                    sounds.activate:play(1 + math.random() * 0.05)
                    local inst = tpFX:create(tp.x - 1, tp.y - (tp.sprite.height/2))
                    inst:getData().parent = tp
                end
            end
        end
    end
end)

--RoR2 Demake Project
--Made by Sivelos
--gunnerTurret.lua
--File created 2019/06/05

--Turret Activities
    -- 0: Idle
    -- 1: Turning
    -- 2: Attacking
    -- 3: Spawning In
    -- 4: Dying (rip)

local sprites = {
    idle = Sprite.load("turretIdle", "Actors/turret/idle", 1, 6, 12),
    shoot1 = Sprite.load("turretShoot1", "Actors/turret/shoot1", 2, 5, 12),
    turn = Sprite.load("turretTurn", "Actors/turret/turn", 5, 9, 12),
    mask = Sprite.load("turretMask", "Actors/turret/mask", 1, 6, 12)
}
local turretData = {
    maxHP = 200,
    hpPerLevel = 60,
    regen = 7.5,
    regenPerLevel = 1.5,
    damage = 18,
    damagePerLevel = 3.6,
    maxWatchTime = 3*60,
    maxBullets = 40
}

local turret = Object.new("Gunner Turret")

turret.sprite = sprites.idle
turret:addCallback("create", function(self)
    self.spriteSpeed = 0.25
    self.mask = sprites.mask
    if self:get("level") == nil then
        self:set("level", 1)
    end
    self:set("maxhp", (turretData.maxHP + (turretData.hpPerLevel * (self:get("level") - 1))))
    self:set("hp", self:get("maxhp"))
    self:set("hp_regen", (turretData.regen + (turretData.regenPerLevel * (self:get("level") - 1))))
    self:set("damage", (turretData.damage + (turretData.damagePerLevel * (self:get("level") - 1))))
    self:set("cooldown", -1)
    self:get("bullets", turretData.maxBullets)
    self:set("activity", 0)
end)

turret:addCallback("step", function(self)
    if self:get("activity") == 0 then --idle

    elseif self:get("activity") == 1 then --turning

    elseif self:get("activity") == 2 then --attacking
        local frame = math.round(self.subimage)
        if frame == 1 then
            local dir = 0
            if self.xscale < 0 then
                dir = 180
            end
            misc.fireBullet(self.x, self.y, dir, 100, (0.3 * self:get("damage")), "player", nil)
        end
    end

end)
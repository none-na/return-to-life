local sprites = {
    idle = Sprite.load("ScavIdle", "Actors/scavenger/idle", 1, 29, 45),
    idleL = Sprite.load("ScavLIdle", "Actors/scavenger/idleLunar", 1, 29, 45),
    walk = Sprite.load("ScavWalk", "Actors/scavenger/walk", 6, 29, 46),
    walkL = Sprite.load("ScavLWalk", "Actors/scavenger/walkLunar", 6, 29, 46),
    jump = Sprite.load("ScavJump", "Actors/scavenger/jump", 1, 29, 45),
    jumpL = Sprite.load("ScavLJump", "Actors/scavenger/jumpLunar", 1, 29, 45),
    death = Sprite.load("ScavDeath", "Actors/scavenger/death", 8, 31, 45),
    deathL = Sprite.load("ScavLDeath", "Actors/scavenger/deathLunar", 8, 31, 45),
    shoot1 = Sprite.load("ScavShoot1", "Actors/scavenger/shoot1", 17, 32, 47),
    shoot1L = Sprite.load("ScavLShoot1", "Actors/scavenger/shoot1Lunar", 17, 32, 47),
    shoot2 = Sprite.load("ScavShoot2", "Actors/scavenger/shoot2", 20, 31, 46),
    shoot3 = Sprite.load("ScavShoot3", "Actors/scavenger/shoot3", 27, 32, 45),
    palette = Sprite.find("ScavengerPal", "vanilla"),
    mask = Sprite.load("ScavMask", "Actors/scavenger/mask", 1, 29, 45),
    ---------------------------------
    thqwib = Sprite.find("EfThqwib", "vanilla"),
    missileExplosion = Sprite.find("EfMissileExplosion", "vanilla"),
}
local sounds = {
    hurt = Sound.find("ScavengerHit", "vanilla"),
    shoot1 = Sound.find("CowboyShoot1", "vanilla"),
    shoot2 = Sound.find("SpitterHit", "vanilla")
}

local actors = ParentObject.find("actors")
local items = ParentObject.find("items")

-----------------------------------------------------------

local thqwib = Object.new("ScavengerThqwib")
thqwib.sprite = sprites.thqwib
thqwib:addCallback("create", function(self)
    local data = self:getData()
    self.spriteSpeed = 0.2
    self:set("vx", 0)
    self:set("vy", 0)
    self:set("ay", 0.25)
end)
thqwib:addCallback("step", function(self)
    local data = self:getData()
    local angle = GetAngleTowards(self.x + self:get("vx"), self.y + self:get("vy"), self.x, self.y)
    self.angle = angle
    PhysicsStep(self)
    if self:collidesMap(self.x, self.y) then
        sounds.shoot2:play(0.8 + math.random() * 0.4)
        if data.parent and data.parent:isValid() then
            local b = data.parent:fireExplosion(self.x, self.y, 0.25, 1, 1, sprites.missileExplosion, nil)
            for item, count in pairs(data.parent:getModData(GlobalItem.namespace).items) do
                if GlobalItem.items[item] then
                    if item and count > 0 then
                        if GlobalItem.items[item].kill then
                            GlobalItem.items[item].kill(data.parent, count, b, self, self.x, self.y)
                        end
                    end
                end
            end
        else
            local b = misc.fireExplosion(self.x, self.y, 0.25, 1, 1, "enemyproc", sprites.missileExplosion, nil)
        end
        self:destroy()
        return

    end

end)


-----------------------------------------------------------
local onInitItemCounts = {
    ["use"] = 1,
    ["common"] = 9,
    ["uncommon"] = 4,
    ["rare"] = 1
}

local onGetItemCounts = {
    ["common"] = 5,
    ["uncommon"] = 2,
    ["rare"] = 1,
    ["misc"] = 1,
}

local twistedNames = {
    [0] = "Kipkip the Gentle",
    [1] = "Wipwip the Wild",
    [2] = "Twiptwip the Devotee",
    [3] = "Guragura the Lucky",
}

local scav = Object.base("BossClassic", "Scavenger2")
scav.sprite = sprites.idle

local scavL = Object.base("BossClassic", "ScavengerLunar")
scavL.sprite = sprites.idleL

local InitScavengerItems = function(actor, debug)
    if debug then print("Initiating Scavenger "..actor.id..":") end
    local use = ItemPool.find("use", "vanilla")
    for i = 1, onInitItemCounts["use"] do
        local item = use:roll()
        if debug then print(" - Giving Scavenger "..actor.id.." "..item:getName()..".") end
        GlobalItem.addItem(actor, item, 1)
    end 
    local common = ItemPool.find("common", "vanilla")
    if debug then print("Giving Scavenger "..actor.id.." "..onInitItemCounts["common"].." common items.") end
    for i = 1, onInitItemCounts["common"] do
        local item = common:roll()
        if debug then print(" - Giving Scavenger "..actor.id.." "..item:getName()..".") end
        GlobalItem.addItem(actor, item, 1)
    end 
    local uncommon = ItemPool.find("uncommon", "vanilla")
    if debug then print("Giving Scavenger "..actor.id.." "..onInitItemCounts["uncommon"].." uncommon items.") end
    for i = 1, onInitItemCounts["uncommon"] do
        local item = uncommon:roll()
        if debug then print(" - Giving Scavenger "..actor.id.." "..item:getName()..".") end
        GlobalItem.addItem(actor, item, 1)
    end 
    local rare = ItemPool.find("rare", "vanilla")
    if debug then print("Giving Scavenger "..actor.id.." "..onInitItemCounts["rare"].." rare items.") end
    for i = 1, onInitItemCounts["rare"] do
        local item = rare:roll()
        if debug then print(" - Giving Scavenger "..actor.id.." "..item:getName()..".") end
        GlobalItem.addItem(actor, item, 1)
    end 
end

local ScavengerInit = function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    self.name = "Scavenger 2.0"
    self.name2 = "Tasting Your Own Medicine"
    self.maxhp = 3800 * Difficulty.getScaling("hp")
    self.hp = self.maxhp
    self.damage = 4 * Difficulty.getScaling("damage")
    self.armor = 20
    self.pHmax = 0.4
    GlobalItem.initActor(actor)
    actor:setAnimations{
        idle = sprites.idle,
        walk = sprites.walk,
        jump = sprites.jump,
        death = sprites.death,
        shoot1 = sprites.shoot1,
        shoot2 = sprites.shoot2,
        shoot3 = sprites.shoot3,
    }
    self.sound_hit = sounds.hurt.id
    self.sound_death = sounds.hurt.id
    actor.mask = sprites.mask
    self.show_boss_health = 1
    self.health_tier_threshold = 1
    self.shake_frame = 5
    self.z_range = 200
    self.x_range = 200
    self.c_range = 0
    self.equipment_range = 200 --equipment
    self.knockback_cap = self.maxhp
    actor:set("sprite_palette", sprites.palette.id)
    self.can_drop = 1
    self.can_jump = 1
    data.pickupCooldown = -1
    data.rage = false
    data.forcePickup = false
    ------------------------------
    InitScavengerItems(actor, true)
end

local ScavengerLunarInit = function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    local index = math.random(0, #twistedNames-1)
    self.name = twistedNames[index]
    self.name2 = "Twisted Scavenger"
    self.maxhp = 3800 * Difficulty.getScaling("hp")
    self.hp = self.maxhp
    self.damage = 4 * Difficulty.getScaling("damage")
    self.armor = 20
    self.pHmax = 0.4
    GlobalItem.initActor(actor)
    actor:setAnimations{
        idle = sprites.idleL,
        walk = sprites.walkL,
        jump = sprites.jumpL,
        death = sprites.deathL,
        shoot1 = sprites.shoot1L,
        shoot2 = sprites.shoot2,
        shoot3 = sprites.shoot3,
    }
    self.sound_hit = sounds.hurt.id
    self.sound_death = sounds.hurt.id
    actor.mask = sprites.mask
    self.show_boss_health = 1
    self.health_tier_threshold = 1
    self.shake_frame = 5
    self.z_range = 200
    self.x_range = 200
    self.c_range = 0
    self.equipment_range = 200 --equipment
    self.knockback_cap = self.maxhp
    self.can_drop = 1
    self.can_jump = 1
    data.rage = false
    data.pickupCooldown = -1
    data.forcePickup = false
    ------------------------------
    if index == 0 then --Kipkip the Gentle
        GlobalItem.addItem(actor, Item.find("The Back-up", "vanilla"), 1)
        GlobalItem.addItem(actor, Item.find("First Aid Kit", "vanilla"), 3)
        GlobalItem.addItem(actor, Item.find("Topaz Brooch", "RoR2Demake"), 5)
        GlobalItem.addItem(actor, Item.find("Monster Tooth", "vanilla"), 10)
        GlobalItem.addItem(actor, Item.find("Infusion", "vanilla"), 2)
        GlobalItem.addItem(actor, Item.find("Queen's Gland", "RoR2Demake"), 4)
        GlobalItem.addItem(actor, Item.find("Genesis Loop", "RoR2Demake"), 3)
        GlobalItem.addItem(actor, Item.find("Rejuvination Rack", "RoR2Demake"), 1)
        GlobalItem.addItem(actor, Item.find("Corpsebloom", "RoR2Demake"), 1)

    elseif index == 1 then --Wipwip the Wild
        self.maxhp_base = 5700 * Difficulty.getScaling("hp")
        self.damage = 2.5 * Difficulty.getScaling("damage")
        GlobalItem.addItem(actor, Item.find("Sticky Bomb", "vanilla"), 3)
        GlobalItem.addItem(actor, Item.find("Focus Crystal", "RoR2Demake"), 3)
        GlobalItem.addItem(actor, Item.find("Backup Magazine", "RoR2Demake"), 3)
        GlobalItem.addItem(actor, Item.find("AtG Missile Mk. 1", "vanilla"), 2)
        GlobalItem.addItem(actor, Item.find("Will-o'-the-wisp", "vanilla"), 2)
        GlobalItem.addItem(actor, Item.find("Brilliant Behemoth", "vanilla"), 1)
        GlobalItem.addItem(actor, Item.find("Shaped Glass", "RoR2Demake"), 1)

    elseif index == 2 then --Twiptwip the Devotee
        GlobalItem.addItem(actor, Item.find("Glowing Meteorite", "vanilla"), 1)
        GlobalItem.addItem(actor, Item.find("Personal Shield Generator", "RoR2Demake"), 3)
        GlobalItem.addItem(actor, Item.find("Crowbar", "vanilla"), 3)
        GlobalItem.addItem(actor, Item.find("Hermit's Scarf", "vanilla"), 3)
        GlobalItem.addItem(actor, Item.find("Fuel Cell", "RoR2Demake"), 2)
        GlobalItem.addItem(actor, Item.find("Soulbound Catalyst", "RoR2Demake"), 1)
        GlobalItem.addItem(actor, Item.find("Transcendence", "RoR2Demake"), 1)

    elseif index == 3 then --Guragura the Lucky
        GlobalItem.addItem(actor, Item.find("Spinel Tonic", "RoR2Demake"), 1)
        GlobalItem.addItem(actor, Item.find("Soldier's Syringe", "vanilla"), 3)
        GlobalItem.addItem(actor, Item.find("Rusty Blade", "vanilla"), 3)
        GlobalItem.addItem(actor, Item.find("Paul's Goat Hoof", "vanilla"), 3)
        GlobalItem.addItem(actor, Item.find("Ukulele", "vanilla"), 2)
        GlobalItem.addItem(actor, Item.find("57 Leaf Clover", "RoR2Demake"), 1)
        GlobalItem.addItem(actor, Item.find("Kjaro's Band", "RoR2Demake"), 1)
        GlobalItem.addItem(actor, Item.find("Runald's Band", "RoR2Demake"), 1)
        GlobalItem.addItem(actor, Item.find("Shattering Justice", "vanilla"), 1)
        GlobalItem.addItem(actor, Item.find("Visions of Heresy", "RoR2Demake"), 1)

    end
end

local ScavengerStep = function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    local itemData = actor:getModData(GlobalItem.namespace)
    ------------------------------------------------
    if self.hp <= (self.maxhp/2) then
        data.rage = true
        self.c_range = 9000
    end
    ------------------------------------------------
    local nearest = items:findNearest(actor.x, actor.y)
    if data.pickupCooldown > -1 then
        data.pickupCooldown = data.pickupCooldown - 1
    end
    if nearest and nearest:isValid() then
        if actor:collidesWith(nearest, actor.x, actor.y) then
            if data.pickupCooldown <= -1 or data.forcePickup then
                if nearest:getAlarm(0) <= -1 and nearest:get("used") ~= 1 then
                    nearest:set("used", 1)
                    nearest:set("force_pickup", 1)
                    nearest:set("owner", actor.id)
                    local item = Item.fromObject(nearest:getObject())
                    if item then
                        if item.isUseItem then
                            if data.equipment then
                                local e = data.equipment:create(actor.x, actor.y - (actor:getAnimation("idle").yorigin))
                                e:setAlarm(0, 2*60)
                            end
                        end
                        GlobalItem.addItem(actor, item, 1)
                    end
                    data.pickupCooldown = 5*60
                    data.forcePickup = false
                end
            end
        end
    end
    ------------------------------------------------
    if self.state == "attack1" then
        local shoot1 = actor:getAnimation("shoot1")
        if actor.sprite == shoot1 then
            self.pHspeed = 0
            if math.floor(actor.subimage) == 8 or math.floor(actor.subimage) == 12 then
                if self.activity_var1 == 0 then
                    misc.shakeScreen(5)
                    sounds.shoot1:play(0.6 + math.random() * 0.3)
                    for i = 0, 2 do
                        local b = actor:fireBullet(actor.x + (22 * actor.xscale), actor.y - 5, actor:getFacingDirection() + math.random(-5, 5), 200, 1, sprites.missileExplosion, nil)
                    end
                    self.activity_var1 = 1
                end
            elseif math.floor(actor.subimage) == 10 then
                if self.activity_var1 == 1 then
                    misc.shakeScreen(5)
                    sounds.shoot1:play(0.6 + math.random() * 0.3)
                    for i = 0, 2 do
                        local b = actor:fireBullet(actor.x + (22 * actor.xscale), actor.y - 5, actor:getFacingDirection() + math.random(-5, 5), 200, 1, sprites.missileExplosion, nil)
                    end
                    self.activity_var1 = 0
                end
            end
            if (math.floor(actor.subimage) >= shoot1.frames) or self.stunned > 0 or self.state ~= "attack1" then
                actor:setAlarm(2, (5*60) * (1-self.cdr))
                actor.sprite = sprites.idle
                self.activity = 0
                self.activity_type = 0
                self.state = "chase"
                return
            end
        else
            actor.sprite = shoot1
            actor.subimage = 1
            self.activity = 1
            self.activity_type = 1
            actor.spriteSpeed = 0.2 * self.attack_speed
        end
    elseif self.state == "attack2" then
        local shoot2 = actor:getAnimation("shoot2")
        if actor.sprite == shoot2 then
            self.pHspeed = 0
            if math.floor(actor.subimage) == 17 then
                if self.activity_var1 == 0 then        
                    local target = Object.findInstance(self.target)
                    if target and target:isValid() then
                        local angle = actor:getFacingDirection()
                        if actor:getFacingDirection() == 180 then
                            angle = angle - 45
                        else
                            angle = angle + 45
                        end
                        local d = (Distance(actor.x, actor.y, target.x, target.y) / 25)
                        local variance = 10
                        for i = 0, 5 do
                            local t = thqwib:create(actor.x, actor.y - 8)
                            t.depth = actor.depth - 1
                            t:set("vx", d * math.cos(math.rad(angle + math.random(-variance, variance))))
                            t:set("vy", -d * math.sin(math.rad(angle + math.random(-variance, variance))))
                            t:getData().parent = actor
                        end

                    end
                    self.activity_var1 = 1
                end
            end
            if (math.floor(actor.subimage) >= shoot2.frames) or self.stunned > 0 or self.state ~= "attack2" then
                actor:setAlarm(3, (5*60) * (1-self.cdr))
                actor.sprite = sprites.idle
                self.activity = 0
                self.activity_var1 = 0
                self.activity_type = 0
                self.state = "chase"
                return
            end
        else
            actor.sprite = shoot2
            actor.subimage = 1
            self.activity = 2
            self.activity_type = 1
            self.activity_var1 = 0
            actor.spriteSpeed = 0.2 * self.attack_speed
        end

    elseif self.state == "attack3" then
        local shoot3 = actor:getAnimation("shoot3")
        self.stun_immune = 1
        if actor.sprite == shoot3 then
            self.pHspeed = 0
            if math.floor(actor.subimage) == 4 then
                misc.shakeScreen(5)
            elseif math.floor(actor.subimage) == 17 then
                if self.activity_var1 == 0 then        
                    local rng = math.random(100)
                    local tier = ""
                    if rng < 5 then
                        tier = "rare"
                    elseif rng < 25 then
                        tier = "uncommon"
                    else
                        tier = "common"
                    end
                    local pool = ItemPool.find(tier, "vanilla")
                    if pool then
                        local item = pool:roll()
                        if item then
                            local i = item:create(actor.x, actor.y - (actor:getAnimation("idle").yorigin))
                            i:set("used", 1)
                            i:set("owner", actor.id)
                            i:set("pGravity", 0)
                            local rarity = "misc"
                            if ItemPool.find("common", "vanilla"):contains(item) then
                                rarity = "common"
                            elseif ItemPool.find("uncommon", "vanilla"):contains(item) then
                                rarity = "uncommon"
                            elseif ItemPool.find("rare", "vanilla"):contains(item) then
                                rarity = "rare"
                            end
                            GlobalItem.addItem(actor, item, onGetItemCounts[rarity])
                        end
                    end
                    self.activity_var1 = 1
                end
            end
            if (math.floor(actor.subimage) >= shoot3.frames) or self.stunned > 0 or self.state ~= "attack3" then
                actor:setAlarm(4, (15*60) * (1-self.cdr))
                actor.sprite = sprites.idle
                self.armor = self.armor - 200
                self.stun_immune = 0
                self.activity = 0
                self.activity_var1 = 0
                self.activity_var2 = 0
                self.activity_type = 0
                self.state = "chase"
                return
            end
        else
            actor.sprite = shoot3
            actor.subimage = 1
            self.armor = self.armor + 200
            self.activity = 3
            self.activity_type = 1
            self.activity_var1 = 0
            self.activity_var2 = 0
            actor.spriteSpeed = 0.2 * self.attack_speed
        end

    elseif self.state == "chase" then
        if itemData.equipmentCooldown <= -1 then
            local target = Object.findInstance(self.target)
            if target and target:isValid() and Distance(actor.x, actor.y, target.x, target.y) <= self.equipment_range then
                self.use_equipment = 1
                return
            else
                self.use_equipment = 0
            end
        else
            self.use_equipment = 0
        end
        if self.z_skill == 1 then
            if actor:getAlarm(2) <= -1 then
                self.state = "attack1"
                self.z_skill = 0
                return
            end
        elseif self.x_skill == 1 then
            if actor:getAlarm(3) <= -1 then
                self.state = "attack2"
                self.x_skill = 0
                return
            end
        elseif self.c_skill == 1 and data.rage then
            if actor:getAlarm(4) <= -1 then
                self.state = "attack3"
                self.c_skill = 0
                return
            end
        end
    end
end

scav:addCallback("create", function(actor)
    ScavengerInit(actor)
end)

scav:addCallback("step", function(actor)
    ScavengerStep(actor)
end)

scavL:addCallback("create", function(actor)
    ScavengerLunarInit(actor)
end)

scavL:addCallback("step", function(actor)
    ScavengerStep(actor)
end)

local monsCard = MonsterCard.new("Scavenger 2.0", scav)
monsCard.type = "classic"
monsCard.sprite = sprites.idle
monsCard.sound = sounds.hurt
monsCard.cost = 1320
monsCard.canBlight = true

local vanilla = MonsterCard.find("Scavenger", "vanilla")

callback.register("postLoad", function()
    for _, s in pairs(Stage.findAll("vanilla")) do
        if s.enemies:contains(vanilla) then
            s.enemies:remove(vanilla)
            s.enemies:add(monsCard)
        end
    end
    for _, namespace in pairs(modloader.getMods()) do
        for _, s in pairs(Stage.findAll(namespace)) do
            if s.enemies:contains(vanilla) then
                s.enemies:remove(vanilla)
                s.enemies:add(monsCard)
            end
        end

    end
end)
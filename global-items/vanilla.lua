local sprites = {
    crosshair = Sprite.find("EfCrosshair", "vanilla"),
    shield = Sprite.find("EfShield", "vanilla"),
    reflector = Sprite.find("EfReflector", "vanilla"),
    reflectorCharge = Sprite.find("ReflectorCharge", "vanilla"),
    medkit = Sprite.find("MedkitBar", "vanilla"),
    wispSpark = Sprite.find("WispSpark", "vanilla"),
    sparks = Sprite.find("Sparks1", "vanilla"),
    fireShield = Sprite.find("EfFireshield", "vanilla"),
    egg = Sprite.find("EfEgg", "vanilla"),
    jetpackFuel = Sprite.find("JetpackFuel", "vanilla"),
    lavaPillar = Sprite.find("EfPillar", "vanilla"),
    fireTrail3 = Sprite.find("EfFireTrail3", "vanilla"),
    missileExplosion = Sprite.find("EfMissileExplosion", "vanilla"),
    revive = Sprite.find("EfRevive", "vanilla"),
    recall = Sprite.find("EfRecall", "vanilla"),
    drill = Sprite.find("EfDrill", "vanilla"),
    gold4 = Sprite.find("EfGold4", "vanilla"),
    jackbox = Sprite.find("EfJackBox", "vanilla"),
    markSuccess = Sprite.find("EfMarkSuccess", "vanilla"),
    doll = Sprite.find("EfDoll", "vanilla"),
    blank = Sprite.find("PBlank", "vanilla"),
    repair = Sprite.find("EfRepair", "vanilla"),
    slash2 = Sprite.find("EfSlash2", "vanilla")
}

local objects = {
    actors = ParentObject.find("actors", "vanilla"),
    enemies = ParentObject.find("enemies", "vanilla"),
    chests = ParentObject.find("chests", "vanilla"),
    drones = ParentObject.find("drones", "vanilla"),
    mushroom = Object.find("EfMushroom", "vanilla"),
    impFriend = Object.find("ImpFriend", "vanilla"),
    jetpack = Object.find("EfJetpack", "vanilla"),
    fly = Object.find("EfFlies", "vanilla"),
    targeting = Object.find("EfTargeting", "vanilla"),
    thorns = Object.find("EfThorns", "vanilla"),
    laserBlast = Object.find("EfLaserBlast", "vanilla"),
    mines = Object.find("EfMine", "vanilla"),
    poisonMine = Object.find("EfPoisonMine", "vanilla"),
    sparks = Object.find("EfSparks", "vanilla"),
    missile = Object.find("EfMissile", "vanilla"),
    missileEnemy = Object.find("EfMissileEnemy", "vanilla"),
    magicMissile = Object.find("EfMissileMagic", "vanilla"),
    fireTrail = Object.find("FireTrail", "vanilla"),
    heal = Object.find("EfHeal", "vanilla"),
    heal2 = Object.find("EfHeal2", "vanilla"),
    flash = Object.find("EfFlash", "vanilla"),
    missileBox = Object.find("EfMissileBox", "vanilla"),
    meteorShower = Object.find("EfMeteorShower", "vanilla"),
    lightningRing = Object.find("EfLightningRing", "vanilla"),
    spikestrip = Object.find("EfSpikestrip", "vanilla"),
    chainLightning = Object.find("ChainLightning", "vanilla"),
    tntStick = Object.find("EfTNTStick", "vanilla"),
    home = Object.find("Home", "vanilla"),
    decoy = Object.find("EfDecoy", "vanilla"),
    gup = Object.find("Slime", "vanilla"),
    thqwib = Object.find("EfThqwib", "vanilla"),
    lantern = Object.find("EfLantern", "vanilla"),
    sucker = Object.find("Sucker", "vanilla"),
    suckerPacket = Object.find("SuckerPacket", "vanilla"),
    poison = Object.find("EfPoison", "vanilla"),
    deskplant = Object.find("EfDeskPlant", "vanilla"),
    gold = Object.find("EfGold", "vanilla"),
    mark = Object.find("EfMark", "vanilla"),
    iceCrystal = Object.find("EfIceCrystal", "vanilla"),
    brain = Object.find("EfBrain", "vanilla"),
    bomb = Object.find("EfBomb", "vanilla"),
    bar = Object.find("CustomBar", "vanilla"),
    buff = Object.find("Buff", "vanilla"),
    bubbleShield = Object.find("EfBubbleShield", "vanilla"),
    droneDisp = Object.find("DroneDisp", "vanilla"),
    circle = Object.find("EfCircle", "vanilla"),
    jellyMissileFriendly = Object.find("JellyMissileFriendly", "vanilla"),
    jellyMissile = Object.find("JellyMissile", "vanilla"),
    sawmerang = Object.find("EfSawmerang", "vanilla"),
    blizzard = Object.find("EfBlizzard", "vanilla"),
    dot = Object.find("Dot", "vanilla"),
    chestRain = Object.find("EfChestRain", "vanilla"),
    warbanner = Object.find("EfWarbanner", "vanilla")
}

local sounds = {
    mushroom = Sound.find("EfMushroom", "vanilla"),
    use = Sound.find("Use", "vanilla"),
    bubbleShield = Sound.find("BubbleShield", "vanilla"),
    reflect = Sound.find("Reflect", "vanilla"),
    guardDeath = Sound.find("GuardDeath", "vanilla"),
    mine = Sound.find("Mine", "vanilla"),
    minerShoot4 = Sound.find("MinerShoot4", "vanilla"),
    wispSpawn = Sound.find("WispSpawn", "vanilla"),
    chainLightning = Sound.find("ChainLightning", "vanilla"),
    pickup = Sound.find("Pickup", "vanilla"),
    revive = Sound.find("Revive", "vanilla"),
    teleporter = Sound.find("Teleporter", "vanilla"),
    jarOfSouls = Sound.find("JarSouls", "vanilla"),
    drill = Sound.find("Drill", "vanilla"),
    hitlist = Sound.find("Hitlist", "vanilla"),
    doll = Sound.find("Doll", "vanilla"),
    coin = Sound.find("Coin", "vanilla"),
    bubbleShield = Sound.find("BubbleShield", "vanilla"),
    drone1Spawn = Sound.find("Drone1Spawn", "vanilla"),
    crit = Sound.find("Crit", "vanilla"),
    levelUpWar = Sound.find("LevelUpWar", "vanilla")
}

local particles ={
    heal = ParticleType.find("Heal", "vanilla"),
    spark = ParticleType.find("Spark", "vanilla"),
    smoke = ParticleType.find("Smoke", "vanilla"),
    dust2 = ParticleType.find("Dust2", "vanilla"),
    leaf = ParticleType.find("Leaf", "vanilla"),
    pixelDust = ParticleType.find("PixelDust", "vanilla"),
    radioactive = ParticleType.find("Radioactive", "vanilla"),
    speed = ParticleType.find("Speed", "vanilla")
}

local buffs = {
    wormEye = Buff.find("wormEye", "vanilla"),
    burstHealth = Buff.find("burstHealth", "vanilla"),
    burstSpeed = Buff.find("burstSpeed", "vanilla"),
    burstAttackSpeed = Buff.find("burstAttackSpeed", "vanilla"),
    warbanner = Buff.find("warbanner", "vanilla"),
}

local itemPools = {
    use = ItemPool.find("use", "vanilla"),
    common = ItemPool.find("common", "vanilla"),
    uncommon = ItemPool.find("uncommon", "vanilla"),
    rare = ItemPool.find("rare", "vanilla"),
}


------------------------------------------------------------

GlobalItem.items[Item.find("Hermit's Scarf", "vanilla")] = {
    apply = function(inst, count)
        inst:set("scarf", inst:get("scarf") + count)
    end,
    step = function(inst, count)
        local i = inst:getAccessor()
        if count > 0 then
            if math.random(100) < math.min(10 + (i.scarf - 1)*3, 25) and i.invincible < 2 then
                i.invincible = 1
                i.scarfed = 1
            else
                i.scarfed = 0
            end
        end
    end,
    remove = function(inst, count, hardRemove)
        if hardRemove then
            inst:set("scarf", 0)
        else
            inst:set("scarf", inst:get("scarf") - 1)
        end
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Bustling Fungus", "vanilla")] = {
    apply = function(inst, count)
        inst:set("shroom_timer", 60)
        inst:set("mushroom", inst:get("mushroom") + count)
    end,
    step = function(inst, count)
        local i = inst:getAccessor()
        if count > 0 then
            if i.hp < i.lastHp then
                i.still_timer = 0
            end
            if i.pHspeed == 0 and i.speed == 0 then
                i.still_timer = i.still_timer + 1
            else
                i.still_timer = 0
            end
            if inst:isClassic() and i.mushroom > 0 and i.still_timer > 2*60 then
                if not inst:collidesWith(objects.mushroom, inst.x, inst.y) then
                    sounds.mushroom:play(0.8 + math.random() * 0.4)
                    local shroom = objects.mushroom:create(inst.x, inst.y + (inst.sprite.height/2) + 2)
                    shroom.depth = inst.depth - 1
                    shroom:set("value", math.ceil(i.maxhp *0.045) * i.mushroom)
                    shroom:set("parent", inst.id)
                    i.shroom_timer = 0 
                end
                if i.shroom_timer then
                    local shroom = objects.mushroom:findNearest(inst.x, inst.y)
                    if i.shroom_timer > -1 then
                        i.shroom_timer = i.shroom_timer - 1
                    else
                        i.hp = math.min(i.hp + shroom:get("value"), i.maxhp)
                        misc.damage(math.ceil(shroom:get("value")), shroom.x + 5, shroom.y -10, false, Color.DAMAGE_HEAL)
                        i.shroom_timer = 60
                    end
                else
                    i.shroom_timer = 0
                end
            end
        end
    end,
    remove = function(inst, count, hardRemove)
        if hardRemove then
            inst:set("mushroom", 0)
        else
            inst:set("mushroom", inst:get("mushroom") - count)
        end
    end,
}

------------------------------------------------------------

callback.register("onStep", function()
    for _, imp in ipairs(objects.impFriend:findAll()) do
        if imp and imp:isValid() then
            local parent = Object.findInstance(imp:get("parent"))
            if not parent then
                imp:destroy()
                return
            end
        end
    end
end)

GlobalItem.items[Item.find("Imp Overlord's Tentacle", "vanilla")] = {
    apply = function(inst, count)
        inst:set("tentacle", inst:get("tentacle") + count)
    end,
    step = function(inst, count)
        local i = inst:getAccessor()
        if i.tentacle > 0 then
            if i.tentacle_cd == 0 and not Object.findInstance(i.tentacle_id) and i.free == 0 then
                local friend = objects.impFriend:create(inst.x, inst.y)
                i.tentacle_id = friend.id
                friend:set("parent", inst.id)
            else
                if i.tentacle_cd > 0 then
                    i.tentacle_cd = i.tentacle_cd - 1
                end
            end
        end
    end,
    remove = function(inst, count, hardRemove)
        if hardRemove then
            inst:set("tentacle", 0)
        else
            inst:set("tentacle", inst:get("tentacle") - 1)
        end
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Soldier's Syringe", "vanilla")] = {
    apply = function(inst, count)
        inst:set("attack_speed", math.clamp(inst:get("attack_speed") + (0.15 * count), 0, 2.8))
    end,
    remove = function(inst, count, hardRemove)
        inst:set("attack_speed", math.clamp(inst:get("attack_speed") - (0.15 * count), 1, 2.8))
    end,
    draw = function(inst, count)
        if count > 0 then
            graphics.drawImage{
                image = inst.sprite,
                x = inst.x,
                y = inst.y,
                subimage = inst.subimage,
                alpha = 0.75,
                xscale = inst.xscale + (math.random(-1, 1) * 0.2),
                yscale = inst.yscale + (math.random(-1, 1) * 0.2),
                color = Color.YELLOW,
            }
            if inst:get("head_active") then
                graphics.drawImage{
                    image = Sprite.fromID(inst:get("head_sprite")),
                    x = inst.x,
                    y = inst.y,
                    subimage = inst:get("head_subimage"),
                    alpha = 0.75,
                    xscale = inst:get("head_scale") + (math.random(-1, 1) * 0.2),
                    yscale = inst.yscale + (math.random(-1, 1) * 0.2),
                    color = Color.YELLOW,
                }
            end
        end
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Lens Maker's Glasses", "vanilla")] = {
    apply = function(inst, count)
        inst:set("critical_chance", (inst:get("critical_chance") or 0) + (7 * count))
    end,
    remove = function(inst, count, hardRemove)
        if hardRemove then
            inst:set("critical_chance", inst:get("critical_chance") - (7 * count))
        else
            inst:set("critical_chance", inst:get("critical_chance") - 7)
        end
    end,
    draw = function(inst, count)
        if count > 0 then
            graphics.drawImage{
                image = sprites.crosshair,
                x = inst.x,
                y = inst.y - 7,
                subimage = 1,
            }
        end
    end
}

GlobalItem.items[Item.find("Harvester's Scythe", "vanilla")] = {
    apply = function(inst, count)
        inst:set("critical_chance", (inst:get("critical_chance") or 0) + (5 * count))
        inst:set("scythe", (inst:get("scythe") or 0) + (count))
    end,
    remove = function(inst, count, hardRemove)
        if hardRemove then
            inst:set("critical_chance", inst:get("critical_chance") - (5 * count))
            inst:set("scythe", inst:get("scythe") - (count))
        else
            inst:set("critical_chance", inst:get("critical_chance") - 5)
            inst:set("scythe", inst:get("scythe") - 1)
        end
    end,
    draw = function(inst, count)
        if count > 0 then
            graphics.drawImage{
                image = sprites.crosshair,
                x = inst.x,
                y = inst.y - 7,
                subimage = 2,
            }
        end
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Mysterious Vial", "vanilla")] = {
    apply = function(inst, count)
        inst:set("hp_regen", inst:get("hp_regen") + (0.014 * count))
    end,
    remove = function(inst, count, hardRemove)
        inst:set("hp_regen", inst:get("hp_regen") - (0.014 * count))
    end,
    draw = function(inst, count)
        local i = inst:getAccessor()
        if count > 0 then
            if (i.hp < i.maxhp and math.random(100) < 25) or (misc.getOption("video.quality") and math.random(100) < 5) then
                particles.heal:burst("below", inst.x, inst.y, 1)

            end
        end
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Crowbar", "vanilla")] = {
    apply = function(inst, count)
        inst:set("crowbar", inst:get("crowbar") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("crowbar", inst:get("crowbar") - count)
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Plasma Chain", "vanilla")] = {
    apply = function(inst, count)
        inst:set("plasma", inst:get("plasma") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("plasma", inst:get("plasma") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Meat Nugget", "vanilla")] = {
    apply = function(inst, count)
        inst:set("nugget", inst:get("nugget") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("nugget", inst:get("nugget") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Leeching Seed", "vanilla")] = {
    apply = function(inst, count)
        inst:set("lifesteal", inst:get("lifesteal") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("lifesteal", inst:get("lifesteal") - count)
    end,
    draw = function(inst, count)
        if count > 0 then
            if misc.getOption("video.quality") >= 3 and math.random(100) < 4 then
                particles.dust2:burst("above", inst.x, inst.y, 1, Color.RED)
            end
        end
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Ukulele", "vanilla")] = {
    apply = function(inst, count)
        inst:set("lightning", inst:get("lightning") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("lightning", inst:get("lightning") - count)
    end,
    draw = function(inst, count)
        if count > 0 then
            if misc.getOption("video.quality") >= 3 and math.random(100) < 4 then
                particles.spark:burst("above", inst.x, inst.y, 1, Color.fromRGB(142,184,196))
            end
        end
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("The Ol' Lopper", "vanilla")] = {
    apply = function(inst, count)
        inst:set("axe", inst:get("axe") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("axe", inst:get("axe") - count)
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Hyper-Threader", "vanilla")] = {
    apply = function(inst, count)
        inst:set("blaster", inst:get("blaster") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("blaster", inst:get("blaster") - count)
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Rusty Blade", "vanilla")] = {
    apply = function(inst, count)
        inst:set("bleed", inst:get("bleed") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("bleed", inst:get("bleed") - count)
    end,
}

------------------------------------------------------------

callback.register("onStep", function()
    for _, missile in ipairs(objects.missile:findAll()) do
        local parent = Object.findInstance(missile:get("parent"))
        if parent and parent:isValid() then
            if string.find(parent:get("team"), "player") then
                if parent and parent:isValid() and parent:getData().items then
                    missile:set("target", parent:get("target"))
                end
                local nearest = objects.actors:findNearest(missile.x, missile.y)
                if missile:collidesWith(nearest, missile.x, missile.y) then
                    if missile:get("team") ~= nearest:get("team") and nearest:get("team").."proc" ~= missile:get("team") and missile:get("hit") == 0 and missile:getAlarm(1) == -1 then
                        if misc.getOption("video.quality") == 3 then
                            local b = misc.fireBullet(nearest.x, nearest.y, 0, 1, missile:get("damage"), missile:get("team"), sprites.missileExplosion, nil)
                        else
                            local b = misc.fireBullet(nearest.x, nearest.y, 0, 1, missile:get("damage"), missile:get("team"), nil, nil)
                        end
                        missile:destroy()
                        return
                    end
                end
            elseif string.find(parent:get("team"), "enemy") then
                local s = objects.missileEnemy:create(missile.x, missile.y)
                if parent and parent:isValid() and parent:getData().items then
                    s:set("target", missile:get("target"))
                end
                s:set("direction", missile:get("direction"))
                    :set("speed", missile:get("speed"))
                    :set("damage", missile:get("damage"))
                    :set("critical", missile:get("critical"))
                    :set("f", missile:get("f"))
                    :set("yy", missile:get("yy"))
                s:setAlarm(0, missile:getAlarm(0))
                s:setAlarm(2, missile:getAlarm(2))
                missile:destroy()
                return
            end
        end
    end
end)

GlobalItem.items[Item.find("AtG Missile Mk. 1", "vanilla")] = {
    apply = function(inst, count)
        if inst:get("missile") <= 0 then
            local tt = objects.targeting:create(inst.x, inst.y)
            tt:getAccessor().image_blend = Color.fromRGB(92, 152, 78).gml
            tt:getAccessor().parent = inst.id
            tt:getAccessor().direction = 45
        end
        inst:set("missile", inst:get("missile") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("missile", inst:get("missile") - count)
    end,
}

GlobalItem.items[Item.find("AtG Missile Mk. 2", "vanilla")] = {
    apply = function(inst, count)
        
        if inst:get("missile_tri") <= 0 then
            local tt = objects.targeting:create(inst.x, inst.y)
            tt:getAccessor().image_blend = Color.ORANGE.gml
            tt:getAccessor().parent = inst.id
            tt:getAccessor().direction = 0
        end
        inst:set("missile_tri", inst:get("missile_tri") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("missile_tri", inst:get("missile_tri") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Ifrit's Horn", "vanilla")] = {
    apply = function(inst, count)
        inst:set("horn", inst:get("horn") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("horn", inst:get("horn") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Taser", "vanilla")] = {
    apply = function(inst, count)
        inst:set("taser", inst:get("taser") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("taser", inst:get("taser") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Thallium", "vanilla")] = {
    apply = function(inst, count)
        inst:set("thallium", inst:get("thallium") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("thallium", inst:get("thallium") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Sticky Bomb", "vanilla")] = {
    apply = function(inst, count)
        inst:set("sticky", inst:get("sticky") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("sticky", inst:get("sticky") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Shattering Justice", "vanilla")] = {
    apply = function(inst, count)
        inst:set("sunder", inst:get("sunder") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("sunder", inst:get("sunder") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Boxing Gloves", "vanilla")] = {
    apply = function(inst, count)
        inst:set("knockback", inst:get("knockback") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("knockback", inst:get("knockback") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Telescopic Sight", "vanilla")] = {
    apply = function(inst, count)
        inst:set("scope", inst:get("scope") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("scope", inst:get("scope") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Brilliant Behemoth", "vanilla")] = {
    apply = function(inst, count)
        inst:set("explosive_shot", inst:get("explosive_shot") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("explosive_shot", inst:get("explosive_shot") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Legendary Spark", "vanilla")] = {
    apply = function(inst, count)
        inst:set("spark", inst:get("spark") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("spark", inst:get("spark") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Wicked Ring", "vanilla")] = {
    apply = function(inst, count)
        inst:set("skull_ring", inst:get("skull_ring") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("skull_ring", inst:get("skull_ring") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Prison Shackles", "vanilla")] = {
    apply = function(inst, count)
        inst:set("slow_on_hit", inst:get("slow_on_hit") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("slow_on_hit", inst:get("slow_on_hit") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Permafrost", "vanilla")] = {
    apply = function(inst, count)
        inst:set("freeze", inst:get("freeze") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("freeze", inst:get("freeze") - count)
    end,
    draw = function(inst, count)
        if count > 0 then
            local w = inst.sprite.width
            local h = inst.sprite.height
            local color = Color.WHITE
            if math.random() < 0.5 then
                color = Color.fromRGB(142,186,193)
            end
            if misc.getOption("video.quality") >= 2 and math.random(100) < 10 then
                particles.pixelDust:burst("above", inst.x - (w/2-math.random(w)) * math.random(1.7) * math.random(1.7),inst.y - (h/2-math.random(h)) * math.random(1.7) * math.random(1.7), 1, color)
            end
        end

    end
}
------------------------------------------------------------

GlobalItem.items[Item.find("Mortar Tube", "vanilla")] = {
    apply = function(inst, count)
        inst:set("mortar", inst:get("mortar") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("mortar", inst:get("mortar") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Alien Head", "vanilla")] = {
    apply = function(inst, count)
        inst:set("cdr", math.min(1 - (1-inst:get("cdr")) * (1-(0.3 * count)), 0.6))
    end,
    remove = function(inst, count, hardRemove)
        inst:set("cdr", math.min(1 - (1-inst:get("cdr")) * (1+(0.3 * count)), 0.6))
    end,
    draw = function(inst, count)
        if count > 0 then
            if misc.getOption("video.quality") > 2 and math.random(100) < 5 then
                local s = objects.fly:create(inst.x + math.random(-5,5), inst.y + math.random(-5,5))
                s:set("target", inst.id)
            end
        end
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Rusty Jetpack", "vanilla")] = {
    apply = function(inst, count)
        inst:set("pVmax", math.min((inst:get("pVmax") or 0) + (0.2 * count), 6))
    end,
    remove = function(inst, count, hardRemove)
        inst:set("pVmax", math.min((inst:get("pVmax") or 0) - (0.2 * count), 6))
    end,
    draw = function(inst, count)
        if count > 0 then
            local i = inst:getAccessor()
            if i.free == 0 and i.activity ~= 30 and i.moveUp == 1 then
                local j = objects.jetpack:create(inst.x, inst.y)
            end
        end
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Concussion Grenade", "vanilla")] = {
    apply = function(inst, count)
        inst:set("stun", 1 - ((1-inst:get("stun")) * (1 - 0.06) * count))
    end,
    remove = function(inst, count, hardRemove)
        inst:set("stun", 1 + ((1-inst:get("stun")) * (1 - 0.06) * count))
    end,
    draw = function(inst, count)
        if count > 0 then
            if math.random(100) < 4 then
                particles.smoke:burst("below", inst.x + math.random(-10, 10), inst.y + math.random(-10, 10), 1)
            end
        end
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Bitter Root", "vanilla")] = {
    apply = function(inst, count)
        inst:set("percent_hp", (inst:get("percent_hp") or 1) + (0.08 * count))
    end,
    remove = function(inst, count, hardRemove)
        inst:set("percent_hp", (inst:get("percent_hp") or 1) - (0.08 * count))
    end,
    draw = function(inst, count)
        if count > 0 then
            if math.random(100) < 5 and misc.getOption("video.quality") >= 2 then
                particles.leaf:burst("below", inst.x, inst.y , 3)
            end
        end
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Dead Man's Foot", "vanilla")] = {
    apply = function(inst, count)
        inst:set("poison_mine", inst:get("poison_mine") + count)
    end,
    damage = function(inst, count, damage)
        if count > 0 then
            local i = inst:getAccessor()
            if i.poison_mine > 0 and math.random(100) * (i.hp / i.maxhp) < 15 and net.host then
                sounds.mine:play()
                for m = 0, i.mine do
                    local s = objects.poisonMine:create(inst.x + (m * 8), inst.y)
                    s:set("team", i.team)
                    s:set("damage", inst:get("damage") * 1.5)
                end
            end
        end
    end,
    remove = function(inst, count, hardRemove)
        inst:set("poison_mine", inst:get("poison_mine") - count)
    end,
    draw = function(inst, count)
        if count > 0 then
            if math.random(100) < 5 and misc.getOption("video.quality") >= 2 then
                particles.radioactive:burst("above", inst.x, inst.y , 3)
            end
        end
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Paul's Goat Hoof", "vanilla")] = {
    apply = function(inst, count)
        inst:set("pHmax", inst:get("pHmax") + (0.08 * count))
    end,
    remove = function(inst, count, hardRemove)
        inst:set("pHmax", inst:get("pHmax") - (0.08 * count))
    end,
    draw = function(inst, count)
        if count > 0 then
            local i = inst:getAccessor()
            if i.pHspeed ~= 0 and math.random(100) < 20 and misc.getOption("video.quality") >= 2 then
                particles.speed:burst("above", inst.x, inst.y + math.random(-5, 5), 1)
            end
        end
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Guardian's Heart", "vanilla")] = {
    apply = function(inst, count)
        inst:set("maxshield", inst:get("maxshield") + (60 * count))
    end,
    remove = function(inst, count, hardRemove)
        inst:set("maxshield", inst:get("maxshield") - (60 * count))
    end,
    draw = function(inst, count)
        if count > 0 then
            if inst:get("shield") > 0 then
                graphics.drawImage{
                    image = sprites.shield,
                    x = inst.x + 11,
                    y = inst.y - 11,
                }
            end
        end
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("First Aid Kit", "vanilla")] = {
    apply = function(inst, count)
        inst:set("medkit", inst:get("medkit") + count)
    end,
    step = function(inst, count)
        if count > 0 then
            local i = inst:getAccessor()
            i.medkit_timer = math.min(14, i.medkit_timer + (0.15 + (i.medkit - 1) * 8.333/60))
            i.medkit_cd = math.max(0, i.medkit_cd - 1)
            if math.floor(i.medkit_timer) == 10 and i.medkit_cd <= 0 then
                sounds.use:play(0.7)
                i.hp = i.hp + (i.medkit * 10)
                misc.damage(i.medkit * 10, inst.x + 5, inst.y - 10, false, Color.DAMAGE_HEAL)
                i.medkit_cd = 30
            end
        end
    end,
    damage = function(inst, count, damage)
        if count > 0 then
            local i = inst:getAccessor()
            if i.medkit > 0 then
                i.medkit_timer = 0
            end
        end
    end,
    remove = function(inst, count, hardRemove)
        inst:set("medkit", inst:get("medkit") - count)
    end,
    draw = function(inst, count)
        if count > 0 then
            local i = inst:getAccessor()
            if i.medkit_timer ~= 14 then
                graphics.drawImage{
                    image = sprites.medkit,
                    x = inst.x + 10,
                    y = inst.y - 10,
                    subimage = i.medkit_timer
                }
            end
        end
    end
}
------------------------------------------------------------

GlobalItem.items[Item.find("Repulsion Armor", "vanilla")] = {
    apply = function(inst, count)
        inst:set("reflector", inst:get("reflector") + count)
    end,
    step = function(inst, count)
        if count > 0 then
            local i = inst:getAccessor()
            if i.reflector > 0 then
                if i.reflecting > 0 then
                    i.reflecting = math.max(0, i.reflecting - 1)
                    local nearest = objects.actors:findNearest(inst.x, inst.y)
                    if i.reflecting_hit == 1 and (nearest and nearest:isValid() and nearest:get("team") ~= inst:get("team")) and Distance(inst.x, inst.y, nearest.x, nearest.y) < 200 then
                        sounds.reflect:play(0.9 + math.random() * 0.25)
                        local bullet = inst:fireBullet(inst.x, inst.y, GetAngleTowards(nearest.x, nearest.y, inst.x, inst.y), 4, sprites.wispSpark, nil)
                        bullet:set("laser", 3)
                        i.reflecting_hit = 0
                    end
                    if i.reflecting == 0 then
                        i.armor = i.armor - 1000
                        i.reflector_charge = 0
                    end
                end
            end
        end
    end,
    damage = function(inst, count, damage)
        local i = inst:getAccessor()
        if i.reflector > 0 then
            if i.reflecting == 0 then
                i.reflector_charge = i.reflector_charge + 1
                if i.reflector_charge >= 6 then
                    i.armor = i.armor + 1000
                    sounds.bubbleShield:play(2)
                    i.reflecting = math.min(60*4+(60*(i.reflector-1)),60*8)
                end
            else
                i.reflecting_hit = 1
            end
        end
    end,
    remove = function(inst, count, hardRemove)
        inst:set("reflector", inst:get("reflector") - count)
    end,
    draw = function(inst, count)
        if count > 0 then
            local i = inst:getAccessor()
            for charge = 0, 5 do
                local subimage = 1
                local angle = 90 + (360/6) * charge
                local xx = math.floor(math.cos(math.rad(angle)) * 20)
                local yy = math.floor(math.sin(math.rad(angle)) * 20)
                if charge < i.reflector_charge then
                    subimage = 2
                end
                graphics.drawImage{
                    image = sprites.reflectorCharge,
                    x = inst.x + xx,
                    y = inst.y + yy,
                    subimage = subimage,
                    alpha = 0.7
                }
            end
            if i.reflecting ~= 0 then
                graphics.drawImage{
                    image = sprites.reflector,
                    x = inst.x,
                    y = inst.y,
                    subimage = (misc.director:get("time_start") + misc.director:getAlarm(0)) / 20 + 10,
                    angle = (misc.director:get("time_start") + misc.director:getAlarm(0)) * 4,
                    alpha = 0.9
                }
            end
        end
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Laser Turbine", "vanilla")] = {
    apply = function(inst, count)
        if not inst:get("laserturbine") then
            inst:set("laserturbine", count)
            inst:set("turbinecharge", 0)
        else
            inst:set("laserturbine", inst:get("laserturbine") + count)
        end
    end,
    step = function(inst, count)
        if count > 0 then
            local i = inst:getAccessor()
            if i.activity ~= 0 and i.activity ~= 30 and i.activity ~= 95 and i.activity ~= 99 then
                i.turbinecharge = math.min(i.turbinecharge + (i.laserturbine*0.13), 100)
                if i.turbinecharge >= 100 then
                    sounds.guardDeath:play(0.7 + math.random() * 0.8)
                    objects.laserBlast:create(inst.x, inst.y)
                    local explosion = inst:fireExplosion(inst.x, inst.y + 8, 1600/39, 64/9, 20, nil, nil, DAMAGER_NO_PROC+DAMAGER_NO_RECALC)
                    explosion:set("team", inst:get("team") .. "proc")
                    i.turbinecharge = 0
                end
            end
        end
    end,
    remove = function(inst, count, hardRemove)
        inst:set("laserturbine", inst:get("laserturbine") + count)
    end,
    draw = function(inst, count)
        if count > 0 then
            local i = inst:getAccessor()
            graphics.color(Color.fromGML(6710991))
            graphics.alpha(0.2)
            graphics.circle(inst.x, inst.y, (24 + math.random(3)) * i.turbinecharge/100, false)
            graphics.circle(inst.x, inst.y, (14 + math.random(2)) * i.turbinecharge/100, false)
            graphics.color(Color.fromGML(16777215))
            graphics.circle(inst.x, inst.y, (6 + math.random(1)) * i.turbinecharge/100, false)
            graphics.alpha(1)
        end
    end
}


------------------------------------------------------------

GlobalItem.items[Item.find("Sprouting Egg", "vanilla")] = {
    apply = function(inst, count)
        inst:set("egg_regen", (inst:get("egg_regen") or 0) + (count * 0.04))
    end,
    step = function(inst, count)
        if inst:get("shield_cooldown") == 0 then
            inst:set("hp", inst:get("hp") + (inst:get("egg_regen") or 0))
        end
    end,
    remove = function(inst, count, hardRemove)
        inst:set("egg_regen", (inst:get("egg_regen") or 0) - (count * 0.04))
    end,
    draw = function(inst, count)
        if count > 0 then
            local i = inst:getAccessor()
            graphics.drawImage{
                image = sprites.egg,
                x = inst.x,
                y = inst.y,
                alpha = 0.3
            }
            if i.shield_cooldown == 0 then
                if math.random(100) < 20 then
                    particles.heal:burst("below", inst.x + math.random(-10, 10), inst.y + math.random(-10, 10) , 1, Color.YELLOW)
                end
            end
        end
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Tough Times", "vanilla")] = {
    apply = function(inst, count)
        inst:set("armor", inst:get("armor") + (14 * count))
    end,
    remove = function(inst, count, hardRemove)
        inst:set("armor", inst:get("armor") - (14 * count))
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Gasoline", "vanilla")] = {
    apply = function(inst, count)
        inst:set("gas", inst:get("gas") + count)
    end,
    kill = function(inst, count, damager, hit, x, y)
        local i = inst:getAccessor()
        if i.gas > 0 then
            local effectiveGas = inst:get("damage") * (0.6 + (0.4 * (i.gas - 1))) * 0.8
            if effectiveGas > 0 then
                for g = -2, 2 do
                    local s= objects.fireTrail:create(x + (g*12), y - hit.sprite.yorigin + hit.sprite.height)
                    s:set("team", inst:get("team"))
                    s.sprite = sprites.fireTrail3
                    s:setAlarm(1, 60 * math.random(2, 2.5))
                    s:set("damage", effectiveGas)
                end
            end
        end
        
    end,
    remove = function(inst, count, hardRemove)
        inst:set("gas", inst:get("gas") - count)
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Burning Witness", "vanilla")] = {
    apply = function(inst, count)
        inst:set("worm_eye", inst:get("worm_eye") + count)
    end,
    kill = function(inst, count, damager, hit, x, y)
        local i = inst:getAccessor()
        if i.worm_eye > 0 then
            inst:applyBuff(buffs.wormEye, 60 * (4+(2*i.worm_eye)))
        end
        
    end,
    remove = function(inst, count, hardRemove)
        inst:set("worm_eye", inst:get("worm_eye") - count)
    end
}
------------------------------------------------------------

GlobalItem.items[Item.find("Infusion", "vanilla")] = {
    apply = function(inst, count)
        if not inst:get("infusion_hp") then
            inst:set("infusion_hp", 0)
        end
        inst:set("hp_after_kill", inst:get("hp_after_kill") + count)
    end,
    step = function(inst, count)
        for _, orb in ipairs(objects.heal:findAll()) do
            if orb:collidesWith(inst, orb.x, orb.y) then
                if orb:get("target") == inst.id then
                    inst:set("infusion_hp", inst:get("infusion_hp") + orb:get("value"))
                    inst:set("maxhp_base", math.min(inst:get("maxhp_base") + orb:get("value"), inst:get("maxhp")))
                    local f = objects.flash:create(inst.x, inst.y)
                    f:set("parent", inst.id)
                    f:set("image_blend", Color.RED.gml)
                    misc.damage(math.floor(orb:get("value")), inst.x, inst.y-20, false, Color.ROR_RED)
                    orb:destroy()
                end
            end
        end
    end,
    kill = function(inst, count, damager, hit, x, y)
        local i = inst:getAccessor()
        if i.hp_after_kill > 0 then
            local s = objects.heal:create(x, y)
            s:set("value", 1 + ((i.hp_after_kill - 1) * 0.5))
            s:set("target", inst.id)
        end
        
    end,
    remove = function(inst, count, hardRemove)
        inst:set("hp_after_kill", inst:get("hp_after_kill") - count)
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Monster Tooth", "vanilla")] = {
    apply = function(inst, count)
        inst:set("heal_after_kill", inst:get("heal_after_kill") + count)
    end,
    step = function(inst, count)
        for _, orb in ipairs(objects.heal2:findAll()) do
            if orb:collidesWith(inst, orb.x, orb.y) then
                if orb:get("target") == inst.id then
                    misc.damage(orb:get("value"), inst.x, inst.y, false, Color.fromRGB(132,215,104))
                    inst:set("hp", math.min(inst:get("hp") + orb:get("value"), inst:get("maxhp")))
                    orb:destroy()
                end
            end
        end
    end,
    kill = function(inst, count, damager, hit, x, y)
        local i = inst:getAccessor()
        if i.heal_after_kill > 0 then
            local s = objects.heal2:create(x, y)
            s:set("value", 10 + ((i.hp_after_kill - 1) * 5))
            s:set("target", inst.id)
        end
        
    end,
    remove = function(inst, count, hardRemove)
        inst:set("heal_after_kill", inst:get("heal_after_kill") - count)
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Ceremonial Dagger", "vanilla")] = {
    apply = function(inst, count)
        inst:set("dagger", inst:get("dagger") + count)
    end,
    step = function(inst, count)
        for _, knife in ipairs(objects.magicMissile:findAll()) do
            local parent = Object.findInstance(knife:get("parent"))
            if parent and parent:isValid() and parent == inst then
                knife:set("target", inst:get("target"))
            end
            local nearest = objects.actors:findNearest(knife.x, knife.y)
            if knife:collidesWith(nearest, knife.x, knife.y) then
                if knife:get("team") ~= nearest:get("team") and nearest:get("team").."proc" ~= knife:get("team") and knife:get("hit") == 0 and knife:getAlarm(1) == -1 then
                    local b = misc.fireBullet(nearest.x, nearest.y, 0, 1, knife:get("damage"), knife:get("team"), nil, nil)
                    knife:destroy()
                    return
                end
            end
        end
    end,
    kill = function(inst, count, damager, hit, x, y)
        local i = inst:getAccessor()
        if i.dagger > 0 then
            for d = 1, 4+(i.dagger-1)*2 do
                local s = objects.magicMissile:create(x, y)
                s:set("parent", inst.id)
                s:set("target", inst:get("target"))
                s:set("damage", inst:get("damage"))
                s:set("team", inst:get("team").."proc")
            end
        end
    end,
    remove = function(inst, count, hardRemove)
        inst:set("dagger", inst:get("dagger") - count)
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Will-o'-the-wisp", "vanilla")] = {
    apply = function(inst, count)
        inst:set("lava_pillar", inst:get("lava_pillar") + count)
    end,
    kill = function(inst, count, damager, hit, x, y)
        local i = inst:getAccessor()
        if (i.lava_pillar and i.lava_pillar > 0) and math.random(100) < 33 and net.host then
            misc.shakeScreen(2)
            sounds.wispSpawn:play(1.3, 0.7)
            local exp = misc.fireExplosion(x, y + inst.sprite.height - inst.sprite.yorigin - 50, 1.4, 12, 2.5 + (1*i.lava_pillar), inst:get("team"), sprites.wispSpark)
            exp:set("knockup", 6)
            exp:set("stun", 1)
            local ff = objects.sparks:create(x, y + inst.sprite.height - inst.sprite.yorigin - 50)
            ff.yscale = 1
            ff.sprite = sprites.lavaPillar
            ff.spriteSpeed = 0.3
        end
    end,
    remove = function(inst, count, hardRemove)
        inst:set("lava_pillar", inst:get("lava_pillar") - count)
    end
}
------------------------------------------------------------

GlobalItem.items[Item.find("Bundle of Fireworks", "vanilla")] = {
    apply = function(inst, count)
        inst:set("fireworks", (inst:get("fireworks") or 0) + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("fireworks", (inst:get("fireworks") or 0) - count)
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Energy Cell", "vanilla")] = {
    apply = function(inst, count)
        local i = inst:getAccessor()
        inst:set("cell", inst:get("cell") + count)
        if not inst:get("cell_bonus_last") then
            inst:set("cell_bonus_last", 0)
        end
    end,
    step = function(inst, count)
        if count > 0 then
            local i = inst:getAccessor()
            local bonus = math.min(0.9, (0.4 + (i.cell - 1) * 0.2)) * (1-(inst:get("hp") / inst:get("maxhp")))
            i.attack_speed = i.attack_speed - i.cell_bonus_last
            i.attack_speed = i.attack_speed + bonus
            i.cell_bonus_last = bonus
        end
    end,
    remove = function(inst, count, hardRemove)
        inst:set("cell", inst:get("cell") - count)
    end
}
------------------------------------------------------------

GlobalItem.items[Item.find("Panic Mines", "vanilla")] = {
    apply = function(inst, count)
        inst:set("mine", inst:get("mine") + count)
    end,
    damage = function(inst, count, damage)
        if count > 0 then
            local i = inst:getAccessor()
            if i.mine > 0 and math.random(100) * (i.hp / i.maxhp) < 15 and net.host then
                sounds.mine:play()
                for m = 0, i.mine do
                    local s = objects.mines:create(inst.x + (m * 8), inst.y)
                    s:set("team", i.team)
                    s:set("damage", inst:get("damage") * 4)
                end
            end
        end
    end,
    remove = function(inst, count, hardRemove)
        inst:set("mine", inst:get("mine") - count)
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Fire Shield", "vanilla")] = {
    apply = function(inst, count)
        inst:set("fireshield", inst:get("fireshield") + count)
    end,
    damage = function(inst, count, damage)
        if count > 0 then
            local i = inst:getAccessor()
            if i.fireshield > 0 and (inst:isBoss() and math.abs(damage) > i.maxhp * (i.health_tier_threshold * 0.01)) or (math.abs(damage) > i.maxhp * 0.1) then
                misc.shakeScreen(8)
                sounds.minerShoot4:play(2)
                local exp = misc.fireExplosion(inst.x, inst.y, 3, 1, 4+(i.fireshield-1)*2, i.team, sprites.fireShield, sprites.sparks)
            end
        end
    end,
    remove = function(inst, count, hardRemove)
        inst:set("fireshield", inst:get("fireshield") - count)
    end
}
------------------------------------------------------------

GlobalItem.items[Item.find("Photon Jetpack", "vanilla")] = {
    apply = function(inst, count)
        if not inst:get("jetpack_fuel") then
            inst:set("jetpack_fuel", 0)
            inst:set("jetpack_cd", 0)
        end
        inst:set("jetpack", inst:get("jetpack") + count)
    end,
    step = function(inst, count)
        if count > 0 then
            local i = inst:getAccessor()
            i.jetpack_cd = math.max(0, i.jetpack_cd - 1)
            if i.jetpack_cd == 0 and i.jetpack > 0 then
                i.jetpack_fuel = math.min((100 + (50 * (i.jetpack - 1))), i.jetpack_fuel + ((100 + (50*(i.jetpack - 1))) * 0.01))
            end
        end
    end,
    remove = function(inst, count, hardRemove)
        inst:set("jetpack", inst:get("jetpack") - count)
    end,
    draw = function(inst, count)
        if count > 0 then
            local i = inst:getAccessor()
            if i.jetpack_fuel and i.jetpack_fuel ~= (100+(50 * (i.jetpack-1))) then
                graphics.drawImage{
                    image = sprites.jetpackFuel,
                    x = inst.x + 11,
                    y = inst.y + 6,
                    subimage = math.floor(sprites.jetpackFuel.id * (i.jetpack_fuel/(100 + (50 * i.jetpack-1))))
                }
            end
        end
    end
}
------------------------------------------------------------

GlobalItem.items[Item.find("Hopoo Feather", "vanilla")] = {
    apply = function(inst, count)
        inst:set("feather", (inst:get("feather") or 0) + count)
    end,
    step = function(inst, count)
        if count > 0 then
            local i = inst:getAccessor()
        end
    end,
    remove = function(inst, count, hardRemove)
        inst:set("feather", inst:get("feather") - count)
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Chargefield Generator", "vanilla")] = {
    apply = function(inst, count)
        inst:set("lightning_ring", (inst:get("lightning_ring") or 0) + count)
    end,
    kill = function(inst, count, damager, hit, x, y)
        local i = inst:getAccessor()
        if i.lightning_ring and i.lightning_ring > 0 then
            local check = objects.lightningRing:findMatchingOp("parent", "==", inst.id)[1]
            if check and check:isValid() then
                sounds.chainLightning:play(0.8)
                check:setAlarm(0, 60*6)
                if check:get("radius") < 300 then
                    check:set("radius", check:get("radius") + 10)
                end
                check:set("image_alpha", 1)
            else
                sounds.chainLightning:play(0.7)
                local s = objects.lightningRing:create(inst.x, inst.y)
                s:set("parent", inst.id)
                s:set("team", inst:get("team").."proc")
                s:set("coeff", 0.4 + inst:get("lightning_ring") * 0.1)
                s:setAlarm(0, 60*6)
            end
        end

    end,
    remove = function(inst, count)
        inst:set("lightning_ring", (inst:get("lightning_ring") or 0) - count)
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Fireman's Boots", "vanilla")] = {
    apply = function(inst, count)
        inst:set("fire_trail", inst:get("fire_trail") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("fire_trail", inst:get("fire_trail") - count)
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Golden Gun", "vanilla")] = {
    apply = function(inst, count)
        inst:set("gold_gun", inst:get("gold_gun") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("gold_gun", inst:get("gold_gun") - count)
    end,
    draw = function(inst, count)
        graphics.alpha(0.6)
        local col = Color.fromRGB(190, 160, 44)
        graphics.color(Color.DARK_GRAY)
        graphics.rectangle(inst.x - 8, inst.y - 20, inst.x - 12, inst.y, false)
        graphics.color(Color.BLACK)
        graphics.rectangle(inst.x - 9, inst.y - 19, inst.x - 11, inst.y - 1, false)
        local g = 18 * math.min((inst:get("gold") * inst:get("gold_gun") / (700 * Difficulty.getScaling("hp"))), 1)
        for i = 0, g do
            local c = Color.mix(Color.WHITE, col, 1-(i/g))
            graphics.color(c)
            graphics.rectangle(inst.x - 9, inst.y - 1 - i, inst.x - 11, inst.y - 1 - (i - 1), false)

        end
        graphics.alpha(1)
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Heaven Cracker", "vanilla")] = {
    apply = function(inst, count)
        local data = inst:getData()
        data.z_used = false
        inst:set("drill", (inst:get("drill") or 0) + count)
        inst:set("z_count", 0)
    end,
    step = function(inst, count)
        local data = inst:getData()
        local i = inst:getAccessor()
        if i.state == "attack1" then
            if not data.z_used then 
                i.z_count = i.z_count + 1 
                data.z_used = true
            end
            if i.drill > 0 and i.z_count >= math.max(1, 5-(i.drill or 0)) then
                sounds.drill:play()
                local s = objects.sparks:create(inst.x, inst.y)
                s.sprite = sprites.drill
                s.xscale = inst.xscale
                local d = inst:fireBullet(inst.x, inst.y, 90 - (90 * inst.xscale), 700, 1, nil, nil, DAMAGER_BULLET_PIERCE)
                i.z_count = 0
            end
        else
            data.z_used = false
        end
    end,
    remove = function(inst, count)
        inst:set("drill", (inst:get("drill") or 0) - count)
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Predatory Instincts", "vanilla")] = {
    apply = function(inst, count)
        inst:set("critical_chance", (inst:get("critical_chance") or 0) + (5*count))
        inst:set("wolfblood", (inst:get("wolfblood") or 0) + count)
    end,
    remove = function(inst, count)
        inst:set("critical_chance", (inst:get("critical_chance") or 0) - (5*count))
        inst:set("wolfblood", (inst:get("wolfblood") or 0) - count)
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Tesla Coil", "vanilla")] = {
    apply = function(inst, count)
        inst:set("tesla", (inst:get("tesla") or 0) + count)
    end,
    step = function(inst, count)
        local i = inst:getAccessor()
        if i.tesla and i.tesla > 0 then
            if math.random(100) < 3 then
                local t = objects.chainLightning:create(inst.x + math.random(-10, 10), inst.y + math.random(-10, 10))
                t:set("team", i.team .. "proc")
                t:set("damage", math.ceil(i.damage * 1.2 * (1 + (i.tesla - 1) * 0.5)))
                t:set("blend", Color.fromRGB(184, 102, 219).gml)
            end
        end
    end,
    remove = function(inst, count)
        inst:set("tesla", (inst:get("tesla") or 0) - count)
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Toxic Centipede", "vanilla")] = {
    apply = function(inst, count)
        if inst:get("mypoison") then
            local p = Object.findInstance(inst:get("mypoison"))
            if p and p:isValid() then p:set("coeff", p:get("coeff") + 0.5) end
        else
            local p = objects.poison:create(inst.x, inst.y)
            inst:set("mypoison", p.id)
            p:set("parent", inst.id)
            p:set("team", inst:get("team").."proc")
            p:set("coeff", 1)
        end
    end,
    remove = function(inst, count)
        local p = Object.findInstance(inst:get("mypoison"))
        if p and p:isValid() then
            if count > 1 then
                p:set("coeff", p:get("coeff") + 0.5)
            else
                p:destroy()
                return
            end

        end
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Colossal Knurl", "vanilla")] = {
    apply = function(inst, count)
        inst:set("maxhp_base", (inst:get("maxhp_base") or inst:get("maxhp")) + (40 * count))
        inst:set("hp_regen", (inst:get("hp_regen") or 0) + (0.02 * count))
        inst:set("armor", (inst:get("armor") or 0) + (5 * count))
    end,
    remove = function(inst, count)
        inst:set("maxhp_base", (inst:get("maxhp_base") or inst:get("maxhp")) - (40 * count))
        inst:set("hp_regen", (inst:get("hp_regen") or 0) - (0.02 * count))
        inst:set("armor", (inst:get("armor") or 0) - (5 * count))
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Dio's Friend", "vanilla")] = {
    apply = function(inst, count)
        inst:set("hippo", (inst:get("hippo") or 0) + count)
    end,
    death = function(inst, count)
        local i = inst:getAccessor()
        i.hippo = 0
        i.invincible = 60*2
        i.hp = i.maxhp * 0.4
        sounds.revive:play()
        local f = objects.flash:create(inst.x, inst.y)
        f:set("parent", inst.id)
        f:set("rate", 0.009)
        local s = objects.sparks:create(inst.x, inst.y - 32)
        s.sprite = sprites.revive
        s.yscale = 1
        s.spriteSpeed = 0.2
        i.force_death = 0
        misc.hud:setAlarm(0, 60)
        GlobalItem.remove(inst, Item.find("Dio's Friend", "vanilla"))
    end,
    remove = function(inst, count)
        inst:set("hippo", (inst:get("hippo") or 0) - count)
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Interstellar Desk Plant", "vanilla")] = {
    apply = function(inst, count)
        inst:set("deskplant", (inst:get("deskplant") or 0) + count)
    end,
    kill = function(inst, count, damager, hit, x, y)
        if inst:get("deskplant") > 0 then
            local s = objects.deskplant:create(x, y)
            s.y = FindGround(s.x, s.y)
            s:set("value", (inst:get("deskplant") * 3) + 5)
        end
    end,
    remove = function(inst, count)
        inst:set("deskplant", (inst:get("deskplant") or 0) - count)
    end,
}
------------------------------------------------------------

local MakeItem = function(x, y)
    local i = math.random(100)
    local item = nil
    if i <= 1 then
        item = itemPools.rare:roll()
    elseif i <= 15 then
        item = itemPools.use:roll()
    elseif i > 15 and i <= 30 then
        item = itemPools.uncommon:roll()
    else
        item = itemPools.common:roll()
    end
    item:create(x, y)
end

local SyncClover = net.Packet.new("Sync Clover Drop", MakeItem)

GlobalItem.items[Item.find("56 Leaf Clover", "vanilla")] = {
    apply = function(inst, count)
        inst:set("clover", (inst:get("clover") or 0) + count)
    end,
    kill = function(inst, count, damager, hit, x, y)
        if inst:get("clover") > 0 then
            if hit:getElite() then
                if net.host and math.random(100) < (4 + ((inst:get("clover") - 1) * 1.5)) then
                    MakeItem(x, y)
                    if net.online then SyncClover:sendAsHost(net.ALL, nil, x, y) end
                end
            end
        end
    end,
    remove = function(inst, count)
        inst:set("clover", (inst:get("clover") or 0) - count)
    end,
    
}

------------------------------------------------------------

GlobalItem.items[Item.find("Ancient Scepter", "vanilla")] = {
    --no
}

------------------------------------------------------------

GlobalItem.items[Item.find("Arms Race", "vanilla")] = {
    apply = function(inst, count)
        inst:set("redwhip", (inst:get("redwhip") or 0) + count)
    end,
    remove = function(inst, count)
        inst:set("redwhip", (inst:get("redwhip") or 0) - count)
    end,
    
}

------------------------------------------------------------

GlobalItem.items[Item.find("Beating Embryo", "vanilla")] = {
    apply = function(inst, count)
        inst:set("embryo", (inst:get("embryo") or 0) + count)
        
    end,
    remove = function(inst, count)
        inst:set("embryo", (inst:get("embryo") or 0) - count)
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Filial Imprinting", "vanilla")] = {
    apply = function(inst, count)
        for i = 1, count do
            local s = objects.sucker:create(inst.x, inst.y-1)
            s:set("master", inst.id)
        end
    end,
    step = function(inst, count)
        local nearest = objects.suckerPacket:findNearest(inst.x, inst.y)
        if nearest and nearest:isValid() then
            -- Actually pick up packet
            if inst:collidesWith(nearest, inst.x, inst.y) then
                sounds.use:play()
                local s = nearest.subimage
                if s == 1 then
                    inst:applyBuff(buffs.burstHealth, 60*3)
                elseif s == 2 then
                    inst:applyBuff(buffs.burstSpeed, 60*3)
                elseif s == 3 then
                    inst:applyBuff(buffs.burstAttackSpeed, 60*3)
                end
                nearest:destroy()
                return
            end
            -- Attempt to pick up packet
            if inst:isClassic() then
                if inst:get("pHmax") > 0 then
                    if Distance(inst.x, inst.y, nearest.x, nearest.y) <= 100 then 
                        inst:set("target", nearest.id)
                        inst:set("state", "chase")
                        if Distance(inst.x, inst.y, nearest.x, nearest.y) <= 30 then
                            if inst.x > nearest.x then
                                inst:set("moveLeft", 1)
                                inst:set("moveRight", 0)
                            else
                                inst:set("moveLeft", 0)
                                inst:set("moveRight", 1)
                            end
                        end
                    end
                end
            end
        end
    end,
    remove = function(inst, count)
        local i = 0
        for _, s in ipairs(objects.sucker:findMatchingOp("master", "==", inst,id)) do
            s:destroy()
            i = i + 1
            if i >= count then break end
        end
    end,
}

------------------------------------------------------------

local MakeGhost = function(actor, team, count, x, y)
    local hit = Object.find(actor)
    local e = hit:getObject():create(x, y)
    e:set("ghost", 1)
    e:set("death_timer", 60 * 15)
    e:set("exp_worth", 0)
    e:set("damage", e:get("damage") * (0.7 + count * 0.3))
    e:set("hp", e:get("hp") * (1 + count * 0.2))
    e:set("team", team)
    e.xscale = hit.xscale
    e.yscale = hit.yscale
    if hit:getObject() == objects.gup then
        local size = hit:get("size_s")
        e:set("size_s", size)
        local p = 0
        if size == 1 then
            p = 0
        elseif size == 0.5 then
            p = 1
            e:set("name", "Gip")
        else
            p = 2
            e:set("name", "Geep")
        end
        if p ~= 0 then
            e:set("damage", e:get("damage") * math.pow(0.4, p))
            e:set("maxhp", e:get("maxhp") * math.pow(0.5, p))
            e:set("hp", e:get("maxhp"))
        end
    end
end

local SyncGhost = net.Packet.new("Sync Ghost Making", MakeGhost)

GlobalItem.items[Item.find("Happiest Mask", "vanilla")] = {
    kill = function(inst, count, damager, hit, x, y)
        if net.host then
            MakeGhost(hit:getObject():getName(), inst:get("team"), count, x, y)
            if net.online then SyncGhost:sendAsHost(net.ALL, nil, hit:getObject():getName(), inst:get("team"), count, x, y) end
        end
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Life Savings", "vanilla")] = {
    apply = function(inst, count)
        inst:set("gp5", inst:get("gp5") + (0.005 * count))
    end,
    step = function(inst, count)
        if inst:get("team") == "player" then
            inst:set("gold", misc.getGold())
            misc.setGold(misc.getGold() + inst:get("gp5"))
        else
            inst:set("gold", inst:get("gold") + inst:get("gp5"))
        end
    end,
    remove = function(inst, count, hardRemove)
        inst:set("gp5", inst:get("gp5") - (0.005 * count))
    end,
}


------------------------------------------------------------

GlobalItem.items[Item.find("Old Box", "vanilla")] = {
    apply = function(inst, count)
        inst:set("jackbox", (inst:get("jackbox") or 0) + count)
    end,
    damage = function(inst, count, damage)
        if inst:get("jackbox") > 0 and math.random(100) * (inst:get("hp") / inst:get("maxhp")) < (10) then
            local s = objects.sparks:create(inst.x, inst.y)
            s.yscale = 1
            s.sprite = sprites.jackbox
            local e = inst:fireExplosion(inst.x, inst.y, 4, 3, 0.1, nil, nil)
            e:set("fear", inst:get("jackbox"))
        end
    end,
    remove = function(inst, count)
        inst:set("jackbox", (inst:get("jackbox") or 0) - count)
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Frost Relic", "vanilla")] = {
    apply = function(inst, count)
        inst:set("icerelic", (inst:get("icerelic") or 0) + count)
    end,
    kill = function(inst, count, damager, hit, x, y)
        local icecount = 0
        local killer = inst
        for _, i in ipairs(objects.iceCrystal:findMatchingOp("parent", "==", inst.id)) do
            icecount = icecount + 1
        end
        if icecount < (inst:get("icerelic") + 2) * 3 then
            local off = 360 / (inst:get("icerelic") + 2)
            for i = 0, inst:get("icerelic") + 2 do
                local c = objects.iceCrystal:create(inst.x, inst.y)
                c:set("parent", inst.id)
                c:set("angle", i * off + 90)
                c:set("angle_offset", c:get("angle"))
            end
        end
    end,
    remove = function(inst, count)
        inst:set("icerelic", (inst:get("icerelic") or 0) - count)
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Rapid Mitosis", "vanilla")] = {
    apply = function(inst, count)
        inst:set("use_cooldown", inst:get("use_cooldown") * (math.pow(1-0.25, count)))
        inst:getData().equipmentCooldown = inst:getData().equipmentCooldown * (math.pow(1-0.25, count))
    end,
    remove = function(inst, count)
        inst:set("use_cooldown", inst:get("use_cooldown") / (math.pow(1-0.25, count)))
        inst:getData().equipmentCooldown = inst:getData().equipmentCooldown / (math.pow(1-0.25, count))
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Red Whip", "vanilla")] = {
    apply = function(inst, count)
        inst:set("redwhip", (inst:get("redwhip") or 0) + count)
    end,
    remove = function(inst, count)
        inst:set("redwhip", (inst:get("redwhip") or 0) - count)
    end,
}

------------------------------------------------------------

callback.register("onStep", function()
    for _, g in ipairs(objects.gold:findAll()) do
        local target = Object.findInstance(g:get("target"))
        if target and target:isValid() then
            if type(target) == "ActorInstance" then
                if g:collidesWith(target, g.x, g.y) then
                    if target:get("gold_cooldown") and target:get("gold_cooldown") == 0 then
                        sounds.coin:play()
                        target:set("gold_cooldown", 6)
                    end
                    if target:get("team") == "player" then
                        misc.setGold(misc.getGold() + g:get("value"))
                    else
                        target:set("gold", target:get("gold") + g:get("value"))
                    end
                    g:destroy()
                    return
                end
            end
        end
    end
end)

GlobalItem.items[Item.find("Smart Shopper", "vanilla")] = {
    apply = function(inst, count)
        inst:set("purse", (inst:get("purse") or 0) + count)
    end,
    kill = function(inst, count, damager, hit, x, y)
        if inst:get("purse") > 0 then
            local f = (hit:get("exp_worth") or 1) * (1.9)
            for i = 1, 25 do
                local g = objects.gold:create(x, y)
                g:set("direction", 180 - math.random(180))
                g:set("speed", math.random(1, 3))
                g.sprite = sprites.gold4
                if f < 1000 then
                    g:set("value", 10)
                else
                    g:set("value", math.floor(f/25) * inst:get("purse"))
                end
            end
        end
    end,
    remove = function(inst, count)
        inst:set("purse", (inst:get("purse") or 0) - count)
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Snake Eyes", "vanilla")] = {
    apply = function(inst, count)
        inst:set("dice", (inst:get("dice") or 0) + count)
    end,
    remove = function(inst, count)
        inst:set("dice", (inst:get("dice") or 0) - count)
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Spikestrip", "vanilla")] = {
    apply = function(inst, count)
        inst:set("spikestrip", inst:get("spikestrip") + count)
    end,
    damage = function(inst, count, damage)
        if inst:get("spikestrip") and inst:get("spikestrip") > 0 then
            sounds.pickup:play(2)
            local s = objects.spikestrip:create(inst.x, inst.y)
            s.y = FindGround(s.x, s.y)
            s:setAlarm(0, 60 * 2 + ((inst:get("spikestrip") -1) * 60))
            s:set("spikestrip", inst:get("spikestrip"))
        end
    end,
    remove = function(inst, count, hardRemove)
        inst:set("spikestrip", inst:get("spikestrip") - count)
    end
}

------------------------------------------------------------

local SyncMark = net.Packet.new("Sync Hit List Mark", function(target, parent)
    local t = Object.findInstance(target)
    local p = Object.findInstance(parent)
    if t and t:isValid() and p and p:isValid() then
        local m = objects.mark:create(t.x, t.y)
        m:set("parent", t.id)
        m:set("parent_2", p.id)
    end
end)

GlobalItem.items[Item.find("The Hit List", "vanilla")] = {
    apply = function(inst, count)
        inst:set("mark", (inst:get("mark") or 0) + count)
        if not inst:get("mark_tally") then inst:set("mark_tally", 0) end
    end,
    step = function(inst, count)
        if net.host then
            local c = #objects.mark:findMatchingOp("parent_2", "==", inst.id)
            if c < inst:get("mark") and inst:get("mark_tally") < 40 and math.random(100) < 0.5 then
                local e = table.random(objects.actors:findMatchingOp("team", "~=", inst:get("team")))
                if e and e:isValid() then
                    local m = objects.mark:create(e.x, e.y)
                    m:set("parent", e.id)
                    m:set("parent_2", inst.id)
                    if net.online then
                        SyncMark:sendAsHost(net.ALL, nil, e.id, inst.id)
                    end
                end
            end
        end
    end,
    kill = function(inst, count, damager, hit, x, y)
        for _, m in ipairs(objects.mark:findMatchingOp("parent", "==", hit.id)) do
            local parent_2 = Object.findInstance(m:get("parent_2"))
            if parent_2 and parent_2:isValid() then
                if parent_2:get("mark_tally") and parent_2:get("mark_tally") < 40 then
                    parent_2:set("mark_tally", parent_2:get("mark_tally") + 1)
                    parent_2:set("damage", parent_2:get("damage") + 0.5)
                end
                sounds.hitlist:play()
                local s = objects.sparks:create(x, y)
                s.sprite = sprites.markSuccess
                s.yscale = 1
                s.xscale = 1
                s.spriteSpeed = 0.2
                m:destroy()
            end
        end
    end,
    remove = function(inst, count)
        inst:set("mark", (inst:get("mark") or 0) - count)
        inst:set("damage", inst:get("damage") - ((0.5) * (inst:get("mark_tally") or 0)))
        inst:set("mark_tally", math.max(0, inst:get("mark_tally") - count))
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Time Keeper's Secret", "vanilla")] = {
    apply = function(inst, count)
        inst:set("hourglass", (inst:get("hourglass") or 0) + count)
        inst:set("hourglass_cd", 0)
    end,
    remove = function(inst, count)
        inst:set("hourglass", (inst:get("hourglass") or 0) - count)
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Headstompers", "vanilla")] = {
    apply = function(inst, count)
        inst:set("stompers", (inst:get("stompers") or 0) + count)
    end,
    remove = function(inst, count)
        inst:set("stompers", (inst:get("stompers") or 0) - count)
    end,
}

------------------------------------------------------------

local currentDifficulty = nil
local lastDifficulty = nil

callback.register("onStep", function()
    local hud = misc.hud
    currentDifficulty = hud:get("difficulty")
    ------------------------------
    for _, w in ipairs(objects.warbanner:findAll()) do
        if not w:get("team") then
            w:set("team", "player")
        end
        if w:getAlarm(0) == -1 then
            for _, a in ipairs(objects.actors:findAllEllipse(w.x - w:get("range"), w.y - w:get("range"), w.x + w:get("range"), w.y + w:get("range"))) do
                if w:get("team") then
                    if a and a:isValid() then
                        if a:get("team") == w:get("team") then
                            a:applyBuff(buffs.warbanner, 60*2)
                        else
                            a:removeBuff(buffs.warbanner)
                        end
                    end
                end
            end
        end
    end
end)

callback.register("postStep", function()
    local hud = misc.hud
    lastDifficulty = hud:get("difficulty")
end, -99999999999)

local CreateBanner = function(parent, x, y)
    local w = parent:get("warbanner")
    if w then
        parent:applyBuff(buffs.warbanner, 60*3 + (60*w))
        sounds.levelUpWar:play(0.8)
        local b = objects.warbanner:create(x, y)
        b:set("range", 50 + (20*w))
        b:set("team", parent:get("team") or "player")
    end
end

GlobalItem.items[Item.find("Warbanner", "vanilla")] = {
    apply = function(inst, count)
        inst:set("warbanner", (inst:get("warbanner") or 0) + count)
    end,
    step = function(inst, count)
        if currentDifficulty and lastDifficulty and currentDifficulty ~= lastDifficulty then
            CreateBanner(inst, inst.x, inst.y)
        end
    end,
    remove = function(inst, count)
        inst:set("warbanner", (inst:get("warbanner") or 0) - count)
    end,
}




------------------------------------------------------------

--Barbed Wire B R O K E
GlobalItem.items[Item.find("Barbed Wire", "vanilla")] = {
    --[[apply = function(inst, count)
        local i = inst:getAccessor()
        if i.thorns and Object.findInstance(i.thorns) then
            if i.thorns_coeff then
                i.thorns_coeff = i.thorns_coeff + (0.2 * (count-1))
            else
                i.thorns_coeff = 1 + ((count) * 0.2)
            end
        end
    end,
    step = function(inst, count)
        if count > 0 then
            local i = inst:getAccessor()
            if i.thorns then
                local thorns = Object.findInstance(i.thorns)
                if not thorns then
                    local t = objects.thorns:create(inst.x, inst.y)
                    t:set("parent", inst.id)
                    t:set("inactive", 0)
                    t:set("team", inst:get("team").."proc")
                    t:set("coeff", i.thorns_coeff)
                    i.thorns = t.id
                end
            else
                i.thorns = -1
            end

        end
    end,
    
    remove = function(inst, count)
        local i = inst:getAccessor()
        if i.thorns and Object.findInstance(i.thorns) then
            if i.thorns_coeff then
                if i.thorns_coeff > 1 then
                    i.thorns_coeff = i.thorns_coeff + (0.2 * count)
                else
                    local t = Object.findInstance(i.thorns)
                    if t then t:destroy() end
                    i.thorns = -1
                end
            end
        end
    end,]]
}

------------------------------------------------------------

GlobalItem.items[Item.find("Foreign Fruit", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 200)
    end,
    use = function(inst, embryo)
        local t = 1
        if embryo then t = 2 end
        sounds.use:play()
        local h = (inst:get("maxhp") * 0.5 * t)
        inst:set("hp", inst:get("hp") + h)
        misc.damage(h, inst.x, inst.y, false, Color.DAMAGE_HEAL)
        particles.heal:burst("below", inst.x, inst.y, 35)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Dynamite Plunger", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 200)
    end,
    hit = function(inst, count, damager, hit, x, y)
        local t = objects.tntStick:create(x, y)
        t:set("parent", inst.id)
    end,
    use = function(inst, embryo)
        for _, tnt in pairs(objects.tntStick:findMatchingOp("parent", "==", inst.id)) do
            tnt:setAlarm(1, math.random(1, 8))
            tnt:set("parent", inst.id)
        end
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Gigantic Amethyst", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 200)
    end,
    use = function(inst, embryo)
        for i = 2, 5 do
            inst:setAlarm(i, -1)
        end
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Thqwib", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 200)
    end,
    use = function(inst, embryo)
        local t = 1
        if embryo then t = 2 end
        local tc = (t + 1) * 30
        for i = 0, 360, (360 / (tc/3)) do
            for x = 0, 2 do
                local t = objects.thqwib:create(inst.x, inst.y)
                t:set("team", inst:get("team"))
                local v = x
                if x == 0 then v = 0.5 end
                t:set("speed", math.random(0.8, 1) * v)
                t:set("direction", i * math.random(0.8, 1))
                t:set("damage", inst:get("damage") * 2)
                t:set("turn_dir", 90 - inst.xscale * 90)
            end
        end
    end,
}
------------------------------------------------------------

local syncBrooch = net.Packet.new("Sync Captain's Brooch", function(x, y)
    local s = objects.chestRain:create(x, y)
    s.x = x
    s.y = y
end)

GlobalItem.items[Item.find("Captain's Brooch", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 200)
    end,
    use = function(inst, embryo)
        local t = 1
        if embryo then t = 2 end
        if net.host then
            for i = 1, t do
                local s = objects.chestRain:create(inst.x, inst.y)
                if net.online then syncBrooch:sendAsHost(net.ALL, nil, s.x, s.y) end
            end
        end
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Carrara Marble", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 400)
    end,
    use = function(inst, embryo)
        local h = objects.home:create(inst.x, inst.y)
        h.y = FindGround(h.x, h.y)
        inst:getData().equipmentCooldown = 60
        h:set("parent", inst.id)
        inst:getData().equipment = Item.find("Active Carrara Marble", "vanilla")
        
    end,
}
GlobalItem.items[Item.find("Active Carrara Marble", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 200)
    end,
    use = function(inst, embryo)
        local h = objects.home:findMatchingOp("parent", "==", inst.id)[1]
        if h and h:isValid() then
            inst:getData().equipmentCooldown = 60 * inst:get("use_cooldown")
            sounds.teleporter:play(1.5)
            local s = objects.sparks:create(inst.x, inst.y)
            s.sprite = sprites.recall
            s.yscale = 1
            inst.x = h.x
            inst.y = h.y-(inst.sprite.height)
            inst:set("ghost_x", inst.x):set("ghost_y", inst.y)
            s = objects.sparks:create(inst.x, inst.y)
            s.sprite = sprites.recall
            s.yscale = 1
            h:setAlarm(0, 1)
        end
        inst:getData().equipment = Item.find("Carrara Marble", "vanilla")
    end,
}

------------------------------------------------------------

callback.register("onPlayerStep", function(player)
    if player and player:isValid() then
        local s = player:get("state")
        if s == "taunted" then
            local target = objects.decoy:findNearest(player.x, player.y)
            if target and target:isValid() then
                if target.y < player.y then
                    player:set("moveUp", 1)
                end
                if target.x > player.x then
                    player:set("moveLeft", 0)
                    player:set("moveRight", 1)
                else
                    player:set("moveLeft", 1)
                    player:set("moveRight", 0)
                end
                local stuff = {
                    [2] = "z",
                    [3] = "x",
                    [4] = "c",
                    [5] = "v",
                }
                if player:get("activity") == 0 then
                    for i = 2, 5 do
                        if Distance(target.x, target.y, player.x, player.y) <= 50 and player:getAlarm(i) <= -1 then
                            player:set(stuff[i].."_skill", 1)
                        else
                            player:set(stuff[i].."_skill", 0)
                        end
                    end
                end
            end
            
        elseif s == "feared" then
            local target = objects.enemies:findNearest(player.x, player.y)
            if target and target:isValid() then
                if player:collidesMap(player.x + (16 * player.xscale), player.y) and not player:collidesMap(player.x + (16 * player.xscale), player.y - 16) then
                    player:set("moveUp", 1)
                else
                    player:set("moveUp", 0)
                end
                
                if target.x > player.x then
                    player:set("moveLeft", 1)
                    player:set("moveRight", 0)
                else
                    player:set("moveLeft", 0)
                    player:set("moveRight", 1)
                end
                local stuff = {
                    [2] = "z",
                    [3] = "x",
                    [4] = "c",
                    [5] = "v",
                }
                if player:get("activity") == 0 then
                    for i = 2, 5 do
                        player:set(stuff[i].."_skill", 0)
                    end
                end
            end
        end
    end
end)

GlobalItem.items[Item.find("Crudely Drawn Buddy", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 200)
    end,
    use = function(inst, embryo)
        local t = 1
        if embryo then t = 2 end
        local s = objects.decoy:create(inst.x, inst.y)
        s:set("team", inst:get("team"))
        s:setAlarm(1, 60 * 8 * (t + 1))
        
    end
}

GlobalItem.items[Item.find("Safeguard Lantern", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 200)
    end,
    use = function(inst, embryo)
        local t = 1
        if embryo then t = 2 end
        local s = objects.lantern:create(inst.x, inst.y)
        s:setAlarm(1, 60*10*(t+1))
        s:set("damage", inst:get("damage"))
        s:set("team", inst:get("team").."proc")
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Disposable Missile Launcher", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 400)
    end,
    use = function(inst, embryo)
        local i = 0
        if embryo then i = 1 end
        local s = objects.missileBox:create(inst.x, inst.y)
        s:set("parent", inst.id)
        s:set("co", 2)
        s:set("bullets", 12 * (i+1))
        s:set("sync", 1)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Drone Repair Kit", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 200)
    end,
    use = function(inst, embryo)
        for _, d in ipairs(objects.drones:findMatchingOp("team", "==", inst:get("team"))) do
            d:set("hp", d:get("maxhp"))
            local c = objects.circle:create(inst.x, inst.y)
            c:set("image_blend", Color.GREEN.gml)
            c:set("radius", 5)
        end
        local s = objects.sparks:create(inst.x, inst.y-10)
        s.sprite = sprites.repair
        s.spriteSpeed = 0.2
        s.yscale = 1
        sounds.drill:play(2)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Glowing Meteorite", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 400)
    end,
    use = function(inst, embryo)
        local i = 0
        if embryo then i = 1 end
        local s = objects.meteorShower:create(inst.x, inst.y)
        s:setAlarm(0, 60 * 8 * (i+1))
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Gold-plated Bomb", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 200)
    end,
    use = function(inst, embryo)
        local t = 1
        if embryo then t = 2 end
        local tbomb = objects.bomb:create(inst.x, inst.y-10)
        tbomb:set("value", math.ceil(inst:get("gold") / 2) * t)
        inst:set("gold", inst:get("gold") / 2)
        if inst:get("team") == "player" then
            misc.setGold(misc.getGold() / 2)
        end
        tbomb:set("team", inst:get("team").."proc")
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Instant Minefield", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 200)
    end,
    use = function(inst, embryo)
        local t = 1
        if embryo then t = 2 end
        sounds.mine:play()
        for i = -3*t, 3*t do
            local s = objects.mine:create(inst.x + (i*10), inst.y)
            s:set("damage", inst:get("damage") * 4)
        end
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Jar of Souls", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 200)
    end,
    use = function(inst, embryo)
        local i = 1
        if embryo then i = 2 end
        sounds.jarOfSouls:play()
        for _, enemy in pairs(objects.actors:findAllEllipse(inst.x - 600, inst.y - 600, inst.x + 600, inst.y + 600)) do
            if enemy and enemy:isValid() then
                if enemy:get("team") == "enemy" then
                    if enemy:isClassic() then
                        for x = 1, i do
                            if net.host then
                                MakeGhost(enemy:getObject():getName(), inst:get("team"), 1, enemy.x, enemy.y)
                                if net.online then SyncGhost:sendAsHost(net.ALL, nil, enemy:getObject():getName(), inst:get("team"), 1, enemy.x, enemy.y) end
                            end
                        end
                    end
                end
            end
        end
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Lost Doll", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 200)
    end,
    use = function(inst, embryo)
        local t = 1
        if embryo then t = 2 end
        sounds.doll:play()
        misc.damage(inst:get("hp")*0.25, inst.x, inst.y, false, Color.DAMAGE_ENEMY)
        inst:set("hp", inst:get("hp") - (inst:get("hp") * 0.25))
        local d = math.huge
        local target = nil
        for _, e in ipairs(objects.actors:findMatchingOp("team", "~=", inst:get("team"))) do
            if e and e:isValid() then
                if e ~= inst then
                    if Distance(inst.x, inst.y, e.x, e.y) < d then
                        d = Distance(inst.x, inst.y, e.x, e.y)
                        target = e
                    end
                end
            end
        end
        if target and target:isValid() then
            local d = math.ceil(math.random(380, 400) * (t*0.5+1)*target:get("maxhp")/100)
            local b = misc.fireBullet(target.x, target.y, 0, 1, d, inst:get("team").."proc", sprites.doll, nil)
            b.yscale = 1
            b.spriteSpeed = 0.2
        end
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Massive Leech", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 200)
    end,
    use = function(inst, embryo)
        local t = 1
        if embryo then t = 2 end
        local time = 60*10
        local b = objects.buff:create(inst.x, inst.y)
        b:set("parent", inst.id)
        b:set("lifesteal", 9*t)
        b.subimage = 2
        b:setAlarm(0, time)
        -------------
        local bar = objects.bar:create(inst.x, inst.y)
        bar:set("parent", inst.id)
        bar:set("time", time)
        bar:set("maxtime", time)
        bar.subimage = 0
    end,
}
------------------------------------------------------------

callback.register("onStep", function()
    for _, j in ipairs(objects.jellyMissileFriendly:findAll()) do
        if j and j:isValid() then
            local parent = Object.findInstance(j:get("parent"))
            if parent and parent:isValid() then
                if parent:get("team") == "enemy" then
                    local e = objects.jellyMissile:create(j.x, j.y)
                    e:set("direction", j:get("direction"))
                    e:set("parent", j:get("parent"))
                    e:set("damage", j:get("damage"))
                    e:set("critical", j:get("critical"))
                    e:set("color", j:get("image_blend"))
                    e:set("speed", j:get("speed"))
                    e:setAlarm(0, j:getAlarm(0))
                    e:set("team", j:get("team"))
                    local t = Object.findInstance(j:get("target"))
                    if not t then t = Object.findInstance(parent:get("target")) end
                    if t and t:isValid() then
                        e:set("targetx", t.x)
                        e:set("targety", t.y)
                    end
                    j:destroy()
                end
            end 
        end
    end
end)

GlobalItem.items[Item.find("Nematocyst Nozzle", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 400)
    end,
    use = function(inst, embryo)
        local i = 0
        if embryo then i = 1 end
        local s = objects.missileBox:create(inst.x, inst.y)
        s:set("parent", inst.id)
        s:set("co", 4)
        s:set("jelly", 1)
        s:set("bullets", 12 * (i+1))
        s:set("sync", 1)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Pillaged Gold", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 200)
    end,
    use = function(inst, embryo)
        local t = 1
        if embryo then t = 2 end
        local time = 60*14
        sounds.coin:play()
        local b = objects.buff:create(inst.x, inst.y)
        b:set("parent", inst.id)
        b:set("gold_on_hit", 1*t)
        b.sprite = sprites.blank
        b:setAlarm(0, time)
        -------------
        local bar = objects.bar:create(inst.x, inst.y)
        bar:set("parent", inst.id)
        bar:set("time", time)
        bar:set("maxtime", time)
        bar.subimage = 3
        bar:set("barColor", Color.fromRGB(234, 230, 147).gml)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Prescriptions", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 200)
    end,
    use = function(inst, embryo)
        local t = 1
        if embryo then t = 2 end
        
        local time = 60*8
        local b = objects.buff:create(inst.x, inst.y)
        b:set("parent", inst.id)
        b:set("attack_speed", 0.4*t)
        b:set("damage", 10)
        b.subimage = 3
        b:setAlarm(0, time)
        -------------
        local bar = objects.bar:create(inst.x, inst.y)
        bar:set("parent", inst.id)
        bar:set("time", time)
        bar:set("maxtime", time)
        bar.subimage = 2
        bar:set("barColor", Color.WHITE.gml)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Rotten Brain", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 200)
    end,
    use = function(inst, embryo)
        local t = 1
        if embryo then t = 2 end
        for i = 1, t do
            local b = objects.brain:create(inst.x, inst.y - 3)
            b:set("direction", 90 - (60 * inst.xscale) - math.random(-6, 6))
            b:set("speed", 2.5)
            b:set("parent", inst.id)
            b:set("team", inst:get("team"))
        end
    end,
}
------------------------------------------------------------

callback.register("onStep", function()
    for _, s in ipairs(objects.sawmerang:findAll()) do
        if s and s:isValid() then
            local nearest = objects.actors:findNearest(s.x, s.y)
            if s:get("team") and s:get("team") ~= nearest:get("team") then
                local data = s:getData()
                if data.hit then
                    if s:get("id_count") < 25 then
                        if not data.hit[nearest] and s:collidesWith(nearest, s.x, s.y) then
                            local g = objects.dot:create(s.x, s.y)
                            g:set("parent", nearest.id)
                            g:set("damage", math.ceil(s:get("true_damage") / 5))
                            g:set("ticks", 4)
                            g:set("team", s:get("team"))
                            sounds.crit:play(0.6 + math.random()*0.2, 0.8)
                            local b = misc.fireBullet(nearest.x, nearest.y, 0, 1, s:get("damage"), s:get("team"), sprites.slash2, nil)
                            b:set("specific_target", nearest.id)
                            s:set("damage", math.ceil(math.max(s:get("damage") - (s:get("true_damage") * 0.2), s:get("true_damage") * 0.1)))
                            -------------
                            data.hit[nearest] = true
                            s:set("id_count", s:get("id_count") + 1)
                        end
                    end
                else
                    data.hit = {}
                end
            end
        end
    end
end)

GlobalItem.items[Item.find("Sawmerang", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 400)
    end,
    use = function(inst, embryo)
        local t = 1
        if embryo then t = 2 end
        for i = 1, t do
            local s = objects.sawmerang:create(inst.x + (i*10), inst.y)
            s:set("direction", 90 - (90 * inst.xscale) + (180 * i))
            s:set("damage", 5*inst:get("damage"))
            s:set("true_damage", 5*inst:get("damage"))
            s:set("parent", inst.id)
            s:set("team", inst:get("team"))
        end
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Shattered Mirror", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 400)
    end,
    use = function(inst, embryo)
        local t = 1
        if embryo then t = 2 end
        inst:set("sp", t)
        inst:set("sp_dur", 15*60)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Shield Generator", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 200)
    end,
    use = function(inst, embryo)
        local t = 1
        if embryo then t = 2 end
        sounds.bubbleShield:play()
        local b = objects.bubbleShield:create(inst.x, inst.y)
        b:set("parent", inst.id)
        b:setAlarm(0, 60 * 8 * t)
        inst:set("invincible", 15000)
    end,
}
------------------------------------------------------------

local OpenChest = function(chest)
    local c = Object.findInstance(chest)
    if c and c:isValid() then
        if c:get("active") == 0 then
            c:set("active", 1)
        end
    end
end

local SyncKey = net.Packet.new("Sync Explorer's Key", OpenChest)

GlobalItem.items[Item.find("Explorer's Key", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 200)
    end,
    use = function(inst, embryo)
        if net.host then
            for _, c in ipairs(objects.chests:findAllEllipse(inst.x - 600, inst.y - 600, inst.x + 600, inst.y + 600)) do
                OpenChest(c.id)
                if net.online then
                    SyncKey:sendAsHost(net.ALL, nil, c.id)
                end
            end
        end
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Snowglobe", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 200)
    end,
    use = function(inst, embryo)
        local t = 1
        if embryo then t = 2 end
        local b = objects.blizzard:create(inst.x, inst.y)
        b:setAlarm(0, 60 * 8 * t)
    end,
}
------------------------------------------------------------


-- By default, Drones will attempt to attack any NPC with the team "enemy."
-- Since The Back-Up assigns the summoned drones the user's team, this code
-- prevents them from targeting their parents or each other.
callback.register("onStep", function()
    for _, d in ipairs(objects.drones:findAll()) do
        if d and d:isValid() then
            if d:get("team") == "enemy" then
                local target = Object.findInstance(d:get("target"))
                if target and target:isValid() then
                    if target:get("team") == "enemy" then
                        local distance = 150
                        local t = nil
                        for _, a in ipairs(objects.actors:findMatchingOp("team", "~=", d:get("team"))) do
                            if Distance(d.x, d.y, a.x, a.y) < distance then
                                distance = Distance(d.x, d.y, a.x, a.y)
                                t = a
                            end
                        end
                        if t then
                            d:set("target", t.id)
                        else
                            d:set("target", -5)
                        end
                    end
                end
            end
        end
    end
end)

local spawnDrones = function(parent, embryo)
    local p = Object.findInstance(parent)
    if p and p:isValid() then
        for i = -1 * embryo, 2*embryo, 2 do
            for j = -1, 1, 2 do
                local d = objects.droneDisp:create(p.x, p.y-800)
                d:set("xx", i*20)
                d:set("yy", j*20)
                d:set("master", p.id)
                d:set("team", p:get("team"))
            end
        end
    end
end

local backUpSync = net.Packet.new("Sync Back Up Drones", spawnDrones)

GlobalItem.items[Item.find("The Back-up", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 200)
    end,
    use = function(inst, embryo)
        local t = 1
        if embryo then t = 2 end
        sounds.drone1Spawn:play()
        if net.host then
            spawnDrones(inst.id, t)
            if net.online then
                backUpSync:sendAsHost(net.ALL, nil, inst.id, t)
            end
        end
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Unstable Watch", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 200)
    end,
    use = function(inst, embryo)
        --??
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Artifact of Enigma", "vanilla")] = {
    apply = function(inst, count)
        inst:set("equipment_range", 200)
    end,
    use = function(inst, embryo)
        local i = itemPools.use:roll()
        GlobalItem.items[i].use(inst, embryo)
    end,
}
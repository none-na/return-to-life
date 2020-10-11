
local actors = ParentObject.find("actors", "vanilla")
local players = Object.find("P", "vanilla")
-- ITEMS --
IRL = itemremover

--local emptySprite = Sprite.load("lunarempty", "Item/lunar/Graphics/empty", 1, 0, 0)

--Shaped Glass--
local LunarColor = Color.PURPLE
local glass = Item.new("Shaped Glass")
glass.displayName = "Shaped Glass"
glass.pickupText = "Doubles base damage, but halves max health."
glass.sprite = Sprite.load("glass", "Items/lunar/Graphics/glass", 1, 16, 16)
glass.color = LunarColor
glass:setLog{
	group = "end",
	description = "Increases damage by &y&+100%&!&, but &r&decreases max HP by 50%.&!&",
    priority = "&b&Unaccounted For&!&",
	story = "Would you believe me if I told you that this glass sculpture was responsible for burning down a museum?\n\nSome artist made this and it was put in a museum. Real pretty on the surface, but it hides a nasty secret. At some point during the day, some light came in through a window and shined directly on the sculpture. 'Cause of the way it was made, the thing hyperfocused the light into a laser so strong it melted through five feet of plaster and sheetrock.\n\nSo yeah, that's why I'm contacting you now. Nobody'll buy this thing, but I think we can make some use out of it. Just keep a hold on it for now, I'll contact you later with further instructions.",
	destination = "Route 421-B,\nMercury,\nSolar System",
	date = "12/12/2056"
}
Lunar.register(glass)
glass:addCallback("pickup", function(player)
    player:set("damage", player:get("damage") * 2)
    player:set("percent_hp", player:get("percent_hp") / 2)
    if player:get("maxshield") > 0 then
        player:set("shield", player:get("shield") / 2)
        player:set("maxshield", player:get("maxshield") / 2)
    end
    if player:get("hp_after_kill") > 0 then
        player:set("hp_after_kill", player:get("hp_after_kill") / 2)
    end
end)
IRL.setRemoval(glass, function(player)
    adjust(player, "damage", -player:get("damage")/2)
    local hpRatio = (player:get("hp") / player:get("maxhp"))
    adjust(player, "percent_hp", player:get("percent_hp"))
    player:set("hp", player:get("maxhp") * hpRatio)
    if player:get("maxshield") > 0 then
        adjust(player, "shield", player:get("shield"))
        adjust(player, "maxshield", player:get("maxshield"))
    end
    if player:get("hp_after_kill") > 0 then
        adjust(player, "hp_after_kill", player:get("hp_after_kill"))
    end
end)
GlobalItem.items[glass] = {
    apply = function(inst, count)
        inst:set("damage", inst:get("damage") * (math.pow(2, count)))
        inst:set("percent_hp", inst:get("percent_hp") / (math.pow(2, count)))
        if inst:get("maxshield") > 0 then
            inst:set("shield", inst:get("shield") / (math.pow(2, count)))
            inst:set("maxshield", inst:get("maxshield") / (math.pow(2, count)))
        end
        if inst:get("hp_after_kill") > 0 then
            inst:set("hp_after_kill", inst:get("hp_after_kill") / (math.pow(2, count)))
        end
    end,
    remove = function(inst, count, hardRemove)
        inst:set("damage", inst:get("damage") / (math.pow(2, count)))
        inst:set("percent_hp", inst:get("percent_hp") * (math.pow(2, count)))
        if inst:get("maxshield") > 0 then
            inst:set("shield", inst:get("shield") * (math.pow(2, count)))
            inst:set("maxshield", inst:get("maxshield") * (math.pow(2, count)))
        end
        if inst:get("hp_after_kill") > 0 then
            inst:set("hp_after_kill", inst:get("hp_after_kill") * (math.pow(2, count)))
        end
    end
}

---------------------------------------------------------------------------------------------------------------------

-- Glowing Meteorite --
local meteorite = Item.find("Glowing Meteorite","vanilla")
meteorite.sprite:replace(Sprite.load("meteoriteSprite", "Items/lunar/Graphics/meteor", 2, 20, 19))
local useItems = ItemPool.find("use", "vanilla")
useItems:remove(meteorite)
meteorite.color = LunarColor
meteorite:setLog{
	group = "end",
    priority = "&b&Unaccounted For&!&"
}
Lunar.register(meteorite)

---------------------------------------------------------------------------------------------------------------------

--Gesture of the Drowned--
local gesture = Item.new("Gesture of the Drowned")
gesture.displayName = "Gesture of the Drowned"
gesture.pickupText = "Sharply reduces use item cooldowns, but forces them to activate."
gesture.sprite = Sprite.load("gesture", "Items/lunar/Graphics/gesture", 1, 16, 16)
gesture.color = LunarColor
gesture:setLog{
	group = "end",
	description = "&y&Halves use item cooldowns&!&, but &r&forcibly activates them&!&.",
    priority = "&b&Unaccounted For&!&",
	story = "Found this lovely shell on the beaches of Europa. Figured you'd want it for your collection of shells. Enjoy!\n\nLove, Mom",
	destination = "Alph Road,\nSurry,\nNew Rhodes",
	date = "10/1/2056"
}
Lunar.register(gesture)

gesture:addCallback("pickup", function(player)
    if player:countItem(gesture) > 1 then
        player:set("use_cooldown", player:get("use_cooldown") * 0.85)
    else
        player:set("use_cooldown", player:get("use_cooldown") / 2)
    end

end)
IRL.setRemoval(gesture, function(player)
    if player:countItem(gesture) > 0 then
        player:set("use_cooldown", player:get("use_cooldown") / 0.85)
    else
        player:set("use_cooldown", player:get("use_cooldown") * 2)
    end
end)

local sound = Sound.find("Pickup", "vanilla")

registercallback("onPlayerStep", function(player)
    if player:countItem(gesture) > 0 then
        if player.useItem ~= nil then
            if player:getAlarm(0) <= -1 then
                player:activateUseItem()
                if modloader.checkFlag("mute_gesture") then
                    if player:get("use_cooldown") <= 5 then
                        if sound:isPlaying() then
                            sound:stop()
                        end
                    end

                end
                if player:getAlarm(0) > 0 then
                    player:setAlarm(0, (((player.useItem.useCooldown * 60) * (player:get("use_cooldown") / 45) )))
                end
            end
        end
    end
end)

---------------------------------------------------------------------------------------------------------------------

--Transcendence--
local transcendence = Item.new("Transcendence")
transcendence.displayName = "Transcendence"
transcendence.pickupText = "Converts all but 1 HP into a regenerating shield. Boosts maximum life."
transcendence.sprite = Sprite.load("fuckinBug", "Items/lunar/Graphics/bug", 1, 16, 18)
transcendence.color = LunarColor
transcendence:setLog{
	group = "end",
	description = "&r&Convert all but 1 HP&!& into a &y&regenerating shield&!&. &g&Boosts life&!&.",
    priority = "&b&Unaccounted For&!&",
	story = "Stories tell of the One who United the Moon. Warring tribes threw everything they had at the Uniter, but to no avail. The Uniter was wiser than them all, and effortlessly shrugged off blow after blow. With the war put to an end, the Moon shined brighter than ever.",
	destination = "???,\nThe Moon,\nMilky Way",
	date = "11/5/2056"
}
Lunar.register(transcendence)

local shieldIcon = Sprite.load("Item/lunar/Graphics/bug", 1, 7, 11)

transcendence:addCallback("pickup", function(player)
    if player:countItem(transcendence) == 1 then
        player:set("percent_hp", player:get("percent_hp") - 0.999999999999999)
    end
    local barrier = (player:get("maxhp_base") * 1.5)
    if player:countItem(transcendence) > 1 then
        barrier = (player:get("maxhp_base") / 4)
    end
    player:set("maxshield", player:get("maxshield") + barrier)
    player:set("shield_cooldown", -1)
    player:set("eradicate", 1)
end)

registercallback("onPlayerLevelUp", function(player)
    if player:countItem(transcendence) > 0 then
        player:set("shield", player:get("shield") + 40)
    end
end)

registercallback("onPlayerDraw", function(player)
    if player:countItem(transcendence) > 0 then
        if player:get("shield") > 0 then
            graphics.drawImage{
                image = shieldIcon,
                x = player.x,
                y = player.y - (player.sprite.height / 2),
                alpha = 0.5,
            }
        end
    end
end)

---------------------------------------------------------------------------------------------------------------------

--Brittle Crown--
local crown = Item.new("Brittle Crown")
local goldSound = Sound.find("Coin", "vanilla")
crown.displayName = "Brittle Crown"
crown.pickupText = "Chance on hit to gain gold, but lose gold on taking damage."
crown.sprite = Sprite.load("crown", "Items/lunar/Graphics/crown", 1, 16, 16)
crown.color = LunarColor
crown:setLog{
	group = "end",
	description = "30% chance on hit to &y&gain 3 gold&!&. &r&Lose gold&!& &r&equal to damage taken&!&.",
    priority = "&b&Unaccounted For&!&",
	story = "We located this artifact on a recent expidition into the tomb of an ancient noble.\n\nVarious inscriptions detailed the story of the richest king in all of Mars.\n\nIt was said that whatever the king would touch turned to gold... Typical Midas story, right? Here's where it gets interesting.\n\nWhen his land was under seige by an enemy country, the king died, and his vast wealth disappeared without a trace. No gold anywhere around his tomb, so the story might hold some water.",
	destination = "A.B. Museum,\nRed City,\nMars",
	date = "12/9/2056"
}
Lunar.register(crown)
registercallback("onHit", function(damager, hit, x, y)
    if damager:get("team") == "enemy" and hit:get("team") == "player" then
        if isa(hit, "PlayerInstance") then
            if hit:countItem(crown) > 0 then
                local goldLoss = damager:get("damage")
                while (misc.getGold() - goldLoss) < 0 do
                    goldLoss = goldLoss - 1
                end
                misc.setGold(misc.getGold() - goldLoss)
            end
        end
    elseif damager:get("team") == "player" and hit:get("team") == "enemy" then
        if math.random(1, 10) <= 3 then
            local parent = damager:getParent()
            if isa(parent, "PlayerInstance") then
                if parent:countItem(crown) > 0 then
                    local goldGain = 3 * parent:countItem(crown)
                    goldSound:play(1 + math.random() * 0.2)
                    misc.setGold(misc.getGold() + goldGain)
                end
            end
        end
    end
end)

---------------------------------------------------------------------------------------------------------------------

--Corpsebloom--
local flower = Item.new("Corpsebloom")
flower.displayName = "Corpsebloom"
flower.pickupText = "Heal 100% more, but all healing is applied over time."
flower.sprite = Sprite.load("corpsebloom", "Items/lunar/Graphics/flower", 1, 16, 16)
flower.color = LunarColor
flower:setLog{
	group = "end",
	description = "&y&Doubles all healing recieved&!&, but all healing is &r&applied over time&!&.",
    priority = "&b&Unaccounted For&!&",
	story = "I planted the seeds in the body as per your instruction. Flowers sprouted out of the skin where I had planted the seeds, and the corpse seemed to regain some vitality. Skin softened, color returned to the face, muscles stretched... But no heartbeat or mental activity.\n\nBack to the drawing board, it seems.",
	destination = "Johnston Drive,\nHarrowbrook,\nJupiter",
	date = "1/12/2056"
}
-- Variables
-- hpDelta: value that tracks the difference between the player's HP on the current frame and the last frame.
-- trackHP: when 1, hpDelta will be updated.
-- hpToRegenerate: When the player is healed, that amount of HP is added to this value and is applied in percentages of the player's max HP every so often.
-- regenTimer: How long, in frames, the game waits before applying more healing.

local regenDelay = 60 --The player's regenTimer will be set to this every time Corpsebloom heals the player.

local healingOverTime = Buff.new("Corpsebloom")
healingOverTime.sprite = Sprite.load("corpseBuff", "Item/lunar/Graphics/flowerBuff", 10, 6, 6)
healingOverTime.frameSpeed = regenDelay / (regenDelay*4)

healingOverTime:addCallback("step", function(actor)
    if isa(actor, "PlayerInstance") then
        actor:set("regenTimer", actor:get("regenTimer") - 1)
        if actor:get("regenTimer") <= 0 then
            if actor:get("hpToRegenerate") > 0 then
                local healing = ((actor:get("maxhp")/10) / ((actor:countItem(flower) + 1)))
                while ((actor:get("hpToRegenerate") - healing) < 0) or ((actor:get("hp") + healing) >= actor:get("maxhp")) do
                    healing = healing - 1
                end
                actor:set("trackHP", 0)
                actor:set("hp", actor:get("hp") + healing)
                misc.damage(healing, actor.x, actor.y - actor.sprite.height, false, Color.DAMAGE_HEAL)
                actor:set("hpToRegenerate", math.clamp(actor:get("hpToRegenerate") - healing, 0, actor:get("hpToRegenerate")))
                if actor:get("hpToRegenerate") <= 0 or actor:get("hp") >= actor:get("maxhp") or healing <= 0 then
                    --actor:set("hpToRegenerate", 0)
                    actor:removeBuff(healingOverTime)
                else
                    actor:applyBuff(healingOverTime, 5 * 60)
                end
                actor:set("trackHP", 1)
                actor:set("regenTimer", regenDelay / actor:countItem(flower))
            end
        end
    end
end)

registercallback("onPlayerInit", function(player)
    player:set("trackHP", 1)
    player:set("hpDelta", 0)
    player:set("regenTimer", regenDelay)
    player:set("hpToRegenerate", 0)

end)

registercallback("onPlayerStep", function(player)
    if player:get("trackHP") == 1 and player:countItem(flower) > 0 then
        player:set("hpDelta", (player:get("hp") - player:get("lastHp")))
        if player:get("hpDelta") > 0 and player:get("hpDelta") > (player:get("hp_regen") + 0.0001) and not player:hasBuff(healingOverTime) then
            player:set("hp", player:get("lastHp"))
            player:set("hpToRegenerate", player:get("hpToRegenerate") + (player:get("hpDelta") * (1+player:countItem(flower))))
            player:applyBuff(healingOverTime, 5*60)
        end
    end
end)

Lunar.register(flower)

---------------------------------------------------------------------------------------------------------------------

--Strides of Heresy--
local strides = Item.new("Strides of Heresy")
strides.displayName = "Strides of Heresy"
strides.pickupText = "Replaces 3rd skill with Shadowfade."
strides.sprite = Sprite.load("Items/lunar/Graphics/lunar/Graphicsstrides", 1, 16, 16)
strides.color = LunarColor
strides:setLog{
	group = "end",
	description = "Replaces your 3rd skill with &y&Shadowfade&!&: Become &b&intangible&!& and restore &g&+25% max HP&!& for 3 seconds.",
    priority = "&b&Unaccounted For&!&",
	story = "I-I thought if I had this, I would be safe... I was so, so ****ing wrong. I was uh... being hunted - the reason why doesn't matter - and was dead to all rights. But this thing... it helped me escape. I watched from the shadows as the enforcers kicked my door down, only to find what they thought was an empty room. Th-the search was called off... after uh... How long has it been now? I was a fugitive for a while. A couple of months at least. It's hard to tell what time it is, when I'm hidden... I walked for so long. I could hide myself in the shadows for so long, maybe a couple of days was my record. When I was hidden, I... I felt safe. I felt comforted. B-But... I didn't feel alone - like I had daggers staring into my back. It was nauseating... I can't bring myself to hide anymore... I was living a lie! A damned lie! Please, just- do whatever you want to me, but don't make me go back to hiding! Take this ****ing thing away from me!!",
	destination = "Donation Box,\nChurch of Rejuvination",
	date = "12/31/2056"
}

local stridesIcon = Sprite.load("Item/lunar/Graphics/shadowfade", 1, 0,0)

local stridesCooldown = 6 * 60

local sounds = {
    start = Sound.load("ShadowfadeEnter", "Sounds/SFX/stridesStart.ogg"),
    loop = Sound.load("ShadowfadeLoop", "Sounds/SFX/stridesLoop.ogg"),
    exit = Sound.load("ShadowfadeExit", "Sounds/SFX/stridesExit.ogg"),
}

local darkness = ParticleType.new("darkness")
darkness:shape("Square")
darkness:color(Color.fromRGB(195, 124, 215), Color.PURPLE, Color.BLACK)
darkness:size(0.1, 0.1, -0.001, 0.005)
darkness:angle(0, 360, 1, 0, true)
darkness:alpha(0,1,0)
darkness:life(60, 60)

local feather = ParticleType.new("feather")
feather:sprite(Sprite.load("Item/lunar/Graphics/feather", 1, 2.5, 5), false, false, false)
feather:angle(0, 360, 1, 0, true)
feather:direction(0, 360, 0, 0)
feather:speed(0.2, 0.2, 0, 0)
feather:alpha(0,1,0)
feather:life(60, 60)

local shadowfade = Buff.new("Shadowfade")
shadowfade.sprite = Sprite.find("Empty", "RoR2Demake")
shadowfade:addCallback("start", function(actor)
    local data = actor:getData()
    local self = actor:getAccessor()
    if Object.findInstance(actor:getAccessor().rope_parent) then
        actor:set("moveUp", 1)
    end
    sounds.start:play()
    data.healLimit = 0.25 * self.maxhp
    if actor:countItem(strides) > 0 then
        data.healLimit = (0.25 * actor:countItem(strides)) * self.maxhp
    end
    data.tickRate = ((3*60)*actor:countItem(strides))/self.maxhp
    data.f = 0
    actor.alpha = 0
    self.pHmax = self.pHmax + 0.3
    --self.pGravity1 = self.pGravity1 - 0.08
    self.pGravity2 = self.pGravity2 - 0.23
    misc.shakeScreen(5)
    for i = 0, math.random(4, 5) do
        feather:burst("middle", actor.x + math.random(-20, 20), actor.y + math.random(-20, 20), 1)
    end

    if isa(actor, "PlayerInstance") and Object.findInstance(actor:get("child_poi")) then
        Object.findInstance(actor:get("child_poi")):destroy()
    end
end)

shadowfade:addCallback("step", function(actor)
    local data = actor:getData()
    local self = actor:getAccessor()
    self.invincible = 1
    data.f = data.f + 1
    if not sounds.loop:isPlaying() then
        sounds.loop:loop()
    end
    self.activity = 6
    if data.f % 25 == 0 then
        local heal = ((self.maxhp / 25)/4) * actor:countItem(strides)
        local dmgr = misc.damage(math.ceil(heal), actor.x, actor.y, false, Color.DAMAGE_HEAL)
        self.hp = self.hp + heal
    end
    if data.f % 5 == 0 then
        feather:burst("middle", actor.x + math.random(-10, 10), actor.y + math.random(-10, 10), 1)
    end

    darkness:burst("middle", actor.x + math.random(-2, 2), actor.y + math.random(-2, 2), 1)

end)

shadowfade:addCallback("end", function(actor)
    local data = actor:getData()
    local self = actor:getAccessor()
    self.pHmax = self.pHmax - 0.3
    self.activity = 0
    sounds.loop:stop()
    sounds.exit:play()
    --self.pGravity1 = self.pGravity1 + 0.08
    self.pGravity2 = self.pGravity2 + 0.225
    misc.shakeScreen(5)
    for i = 0, math.random(4, 5) do
        feather:burst("middle", actor.x + math.random(-20, 20), actor.y + math.random(-20, 20), 1)
    end
    actor.alpha = 1
    if isa(actor, "PlayerInstance") and not Object.findInstance(actor:get("child_poi")) then
        local newPoi = Object.find("POI", "vanilla"):create(actor.x, actor.y)
        newPoi:set("parent", actor.id)
        actor:set("child_poi", newPoi.id)
    end
    actor:getData().overridecd3 = stridesCooldown
end)

callback.register("onGameEnd", function(player)
    if sounds.loop:isPlaying() then
        sounds.loop:stop()
    end
end)

registercallback("onPlayerStep", function(player)
  local pNN = player:getData()
    if not pNN.overridecd3 then pNN.overridecd3 = 0 end
    if player:countItem(strides) > 0 then

	    player:setSkill(3,
        "Shadowfade",
        "Fade into darkness for ".. (3*player:countItem(strides)) .." seconds, becoming intangible and gaining movement speed. Heal for ".. 25 * player:countItem(strides) .."% of your maximum health.",
        stridesIcon, 1,
        6 * 60)
        player:setAlarm(4, math.clamp(player:getAlarm(4), 0, 9999))
        if player:get("activity") == 0 and player:control("ability3") == 3 and pNN.overridecd3 == 0 then
            player:applyBuff(shadowfade, (3*player:countItem(strides))*60)
        end
        if pNN.overridecd3 > 0 then pNN.overridecd3 = pNN.overridecd3 - 1 end
    end
end)

registercallback("onPlayerHUDDraw", function(player, hx, hy)
    local pNN = player:getData()
    local drawX, drawY = hx + (18 + 5) * 2, hy
    if player:countItem(strides) > 0 then
        stridesIcon:draw(drawX, drawY)
        if pNN.overridecd3 > 0 then
            graphics.color(Color.fromHex(0x1C1A22))
            graphics.alpha(0.8)
            graphics.rectangle(drawX, drawY, drawX + 18, drawY + 18)
            graphics.alpha(1) graphics.color(Color.WHITE)
            graphics.print(math.ceil(pNN.overridecd3 / 60, 1, 1), drawX + 11, drawY + 2, graphics.FONT_LARGE, graphics.ALIGN_MIDDLE)
        end
    end
end)

Lunar.register(strides)

---------------------------------------------------------------------------------------------------------------------

--Visions of Heresy--
local visions = Item.new("Visions of Heresy")
visions.pickupText = "Replaces 1st skill with Hungering Gaze."
visions.sprite = Sprite.load("Items/lunar/Graphics/lunar/Graphicsvisions", 1, 16, 16)
visions.color = LunarColor
visions:setLog{
	group = "end",
	description = "Replaces your 1st skill with &y&Hungering Gaze&!&: Fire a flurry of &b&tracking shards&!& that detonate after a delay, dealing &y&120% damage.&!&",
    priority = "&b&Unaccounted For&!&",
	story = "---",
	destination = "Donation Box,\nChurch of Rejuvination",
	date = "12/31/2056"
}

local visionsIcon = Sprite.load("Item/lunar/Graphics/hungeringGaze", 1, 0,0)

local visionsSprites = {
    idle = Sprite.load("Item/lunar/Graphics/gaze", 2, 6.5, 1.5),
    blast = Sprite.load("Item/lunar/Graphics/gazeSparks", 3, 15, 5.5),
    mask = Sprite.load("Item/lunar/Graphics/gazeMask", 1, 5.5, 5.5)
}

local gazeTrail = ParticleType.new("HungeringGaze")
gazeTrail:shape("Square")
gazeTrail:color(Color.fromRGB(145, 103, 255))
gazeTrail:alpha(1, 0)
gazeTrail:scale(0.1, 0.015)
gazeTrail:additive(true)
gazeTrail:life(30, 30)

local gaze = Object.new("LunarTrackingMissile")
gaze.sprite = visionsSprites.idle

gaze:addCallback("create", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    self.speed = 5
    self.direction = math.random(360)
    data.target = nil
    data.attached = nil
    data.parent = nil
    data.xOff = -1
    data.yOff = -1
    data.life = 3*60
    data.phase = 0
    data.team = "player"
    data.damage = 12
end)

gaze:addCallback("step", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    -------------------------------------
    gazeTrail:angle(self.direction, self.direction, 0, 0, true)
    gazeTrail:burst("middle", this.x, this.y, 1)
    -------------------------------------
    if data.phase == 0 then --flying
        if data.life > -1 then
            data.life = data.life - 1
        else
            data.phase = 1
            return
        end
        local nearest = actors:findNearest(this.x, this.y)
        if nearest and nearest:isValid() then
            if nearest:get("team") ~= data.team then
                data.target = nearest
            end
        end
        if data.target and data.target:isValid() then
            self.direction = math.approach(self.direction, GetAngleTowards(data.target.x, data.target.y, this.x, this.y), self.speed / 5)
            if this:collidesWith(data.target, this.x, this.y) then
                local i
                if data.parent then
                    i = data.parent:fireBullet(this.x, this.y, 0, 1, 0.1, nil, nil)
                else
                    i = misc.fireBullet(this.x, this.y, 0, 1, data.damage * 0.1, data.team, nil, nil)
                end
                i:set("specific_target", data.target.id)
                data.xOff = this.x - data.target.x
                data.yOff = this.y - data.target.y
                data.attached = data.target
                data.life = 60
                self.speed = 0
                data.phase = 1
            end
        end
        if this:collidesMap(this.x, this.y) then
            local exp
            if data.parent then
                exp = data.parent:fireExplosion(this.x, this.y, 0.25, 1, 0.1, nil, nil)
            else
                exp = misc.fireExplosion(this.x, this.y, 0.25, 1, data.damage * 0.1, data.team, nil, nil)
            end
            self.speed = 0
            data.life = 60
            data.phase = 1
        end

    elseif data.phase == 1 then --stuck to something / not flying
        if data.attached then
            if data.attached:isValid() then
                this.x = data.attached.x + data.xOff
                this.y = data.attached.y + data.yOff
            else
                data.xOff = -1
                data.yOff = -1
                self.speed = 5
                data.attached = nil
                data.phase = 0
            end
        end
        if data.life > -1 then
            data.life = data.life - 1
        else
            local exp
            if data.parent then
                exp = data.parent:fireExplosion(this.x, this.y, 0.25, 1, 1.2, visionsSprites.blast, nil)
            else
                exp = misc.fireExplosion(this.x, this.y, 0.25, 1, data.damage * 1.2, data.team, visionsSprites.blast, nil)
            end
            this:destroy()
            return
        end
    end

end)

local visionsCooldown = 2 * 60
local visionsShotCount = 12

visions:addCallback("pickup", function(player)
    if player:countItem(visions) == 1 and Ability.getMaxCharge(player, "z") ~= 12 then
        Ability.AddCharge(player, "z", 12 - Ability.getMaxCharge(player, "z"))
        Ability.setCharge(player, "z", Ability.getMaxCharge(player, "z"))
    else
        Ability.AddCharge(player, "z", 12)
    end
    Ability.setCooldown(player, "z", 2*60)
    Ability.setStop(player, "z", 0)

end)

registercallback("onPlayerStep", function(player)
  local pNN = player:getData()
    if not pNN.overridecd1 then pNN.overridecd1 = 0 end
    if player:countItem(visions) > 0 then
	    player:setSkill(1,
        "Hungering Gaze",
        "Fire a flurry of tracking shards that detonate after a delay, dealing 120% base damage. Hold up to ".. (12*player:countItem(visions)) .." charges that reload after ".. 2 * player:countItem(visions) .." seconds.",
        visionsIcon, 1,
        2 * 60)
        player:setAlarm(2, math.clamp(player:getAlarm(2), 0, 9999))
        if player:get("activity") == 0 and player:control("ability1") == 3 and pNN.overridecd1 == 0 then
            local v = gaze:create(player.x, player.y)
            v:set("direction", player:getFacingDirection())
            v:getData().parent = player
            v:getData().team = player:get("team")
            v:getData().damage = player:get("damage")
            Ability.setCharge(player, "z", Ability.getCharge(player, "z") - 1)
            if Ability.getCharge(player, "z") <= 0 then
                pNN.overridecd1 = visionsCooldown * player:countItem(visions)
                Ability.setCharge(player, "z", Ability.getMaxCharge(player, "z"))
            else
                pNN.overridecd1 = 10
            end
        end
        if pNN.overridecd1 > 0 then pNN.overridecd1 = pNN.overridecd1 - 1 end
    end
end)

registercallback("onPlayerHUDDraw", function(player, hx, hy)
    local pNN = player:getData()
    local drawX, drawY = hx, hy
    if player:countItem(visions) > 0 then
        visionsIcon:draw(drawX, drawY)
        if Ability.getCharge(player, "z") > 0 then
            if pNN.overridecd1 > 0 then
                graphics.color(Color.fromHex(0x1C1A22))
                graphics.alpha(0.8)
                graphics.rectangle(drawX, drawY, drawX + 18, drawY + 18)
                graphics.alpha(1) graphics.color(Color.WHITE)
                graphics.print(math.ceil(pNN.overridecd1 / 60, 1, 1), drawX + 11, drawY + 2, graphics.FONT_LARGE, graphics.ALIGN_MIDDLE)
            end
        end
    end
end)

Lunar.register(visions)

---------------------------------------------------------------------------------------------------------------------

--Beads of Fealty--
local beads = Item.new("Beads of Fealty")
beads.pickupText = "Seems to do nothing... but..."
beads.sprite = Sprite.load("beads", "Items/lunar/Graphics/beads", 1, 16, 16)
beads.color = LunarColor
beads:setLog{
	group = "end",
	description = "Seems to do nothing... &y&but...&!&",
    priority = "&b&Unaccounted For&!&",
	story = "I have faith.\nFaith will allow me to survive after death.\nFaith will allow me to continue my work.\nFaith will allow me to see past the lies of this world.\nFaith will bring me to a better world, a clean world.\nI have faith.",
	destination = "???,\nThe Moon",
	date = "12/9/2056"
}
Lunar.register(beads)

---------------------------------------------------------------------------------------------------------------------

--Effigy of Grief--
local effigy = Item.new("Effigy of Grief")
effigy.displayName = "Effigy of Grief"
effigy.pickupText = "Cripples all nearby characters when placed. Can be picked back up."
effigy.sprite =Sprite.load("effigy", "Items/lunar/Graphics/effigy", 2, 16, 16)
effigy.isUseItem = true
effigy.useCooldown = 0.5
effigy.color = LunarColor
effigy:setLog{
	group = "end",
	description = "&y&Reduces armor and movement speed&!& of &r&all nearby characters&!& within an area of effect.",
    priority = "&b&Unaccounted For&!&",
	story = "This priceless sculpture evokes powerful feelings in all who behold it. I mean this literally, everyone who even so much as glanced at the thing was sobbing like their families were killed. I had to wrap the thing in ten inches of lead so I couldn't look at it. You sure you want this thing in your museum? Might get some tear-stained lawsuits over this.",
	destination = "Brenceworth Museum,\nSilk Road,\nPluto",
	date = "1/12/2056"
}

-- Placed Effigy --

local effigyDebuff = Buff.new("Grieving")
effigyDebuff.sprite = Sprite.load("grief", "Item/lunar/Graphics/effigyDebuff", 1, 5, 7)
effigyDebuff:addCallback("start", function(actor)
	actor:set("pHmax", actor:get("pHmax") - 0.5)
	actor:set("armor", actor:get("armor") - 100)
end)
effigyDebuff:addCallback("end", function(actor)
	actor:set("pHmax", actor:get("pHmax") + 0.5)
	actor:set("armor", actor:get("armor") + 100)
end)
local effigyRadius = 100
local effigyObject = Object.new("Placed Effigy")
local effigySprites = {
    idle = Sprite.load("effigySprite", "Item/lunar/Graphics/effigy", 5, 9, 26),
    mask = Sprite.load("effigyMask", "Item/lunar/Graphics/effigyMask", 1, 6, 13)
}
effigyObject.sprite = effigySprites.idle
local effigySound = Sound.find("WormExplosion", "vanilla")

effigyObject:addCallback("create", function(self)
    local data = self:getData()
    self.mask = effigySprites.mask
    self:set("radius", effigyRadius)
    self.spriteSpeed = 0.2
    misc.shakeScreen(5)
    effigySound:play()
    self.y = FindGround(self.x, self.y)
    data.pickupCooldown = 60
    data.showText = false
    data.text1 = "&w&Press &y&'"..input.getControlString("swap").."'&w& to pick up."
end)
effigyObject:addCallback("step", function(self)
    local data = self:getData()
    if math.floor(self.subimage) >= self.sprite.frames then
        self.spriteSpeed = 0
    end
    if data.pickupCooldown > -1 then
        data.pickupCooldown = data.pickupCooldown - 1
    else
        local nearest = players:findNearest(self.x, self.y)
        if nearest and nearest:isValid() then
            if self:collidesWith(nearest, self.x, self.y) then
                data.showText = true
                if input.checkControl("swap", nearest) == input.PRESSED then
                    if nearest.useItem then
                        local i = nearest.useItem:create(self.x, self.y - 16)
                    end
                    nearest.useItem = effigy
                    self:destroy()
                    return
                end
            else
                data.showText = false
            end
        end
    end
    for _, inst in ipairs(actors:findAllEllipse(self.x - self:get("radius"), self.y - self:get("radius"), self.x + self:get("radius"), self.y + self:get("radius"))) do
        inst:applyBuff(effigyDebuff, 60*0.5)
    end
end)
effigyObject:addCallback("draw", function(self)
    local data = self:getData()
    graphics.color(Color.fromRGB(98, 121, 255))
    graphics.alpha(0.75)
    graphics.circle(self.x, self.y, self:get("radius"), true)
    graphics.alpha(0.05)
    graphics.circle(self.x, self.y, self:get("radius"), false)
    if data.showText then
        graphics.alpha(1)
        graphics.printColor(data.text1, self.x - (graphics.textWidth(data.text1, graphics.FONT_DEFAULT) / 2), self.y - 32, graphics.FONT_DEFAULT)
    end
end)

effigy:addCallback("use", function(player, embryo)
    local newEffigy = effigyObject:create(player.x, player.y)
    if embryo then
        newEffigy:set("radius", effigyRadius * 1.25)
    else
        newEffigy:set("radius", effigyRadius)
    end
    player.useItem = nil
    return
end) --place/pickup Effigy

Lunar.register(effigy)

---------------------------------------------------------------------------------------------------------------------

--Hellfire Tincture--
local hellfire = Item.new("Helfire Tincture")
hellfire.displayName = "Helfire Tincture"
hellfire.pickupText = "Ignite all nearby characters. Enemies take more damage."
hellfire.sprite =Sprite.load("hellfire", "Items/lunar/Graphics/hellfire", 2, 16, 16)
hellfire.isUseItem = true
hellfire.useCooldown = 45
hellfire.color = LunarColor
hellfire:setLog{
	group = "end",
    description = "&r&Ignite all characters nearby&!& for &y&5% of your max HP&!& per second.",
    priority = "&b&Unaccounted For&!&",
	story = "Be very careful when handling this. When I took the thing home and put it on my desk, I must've put it down too hard or something, cause next thing I knew, my house was on fire. Took the fire department five hours to put the fire out. So yeah, this thing's crazy volatile... I trust you'll handle it with care.",
	destination = "PO Box 5301,\nTerrence,\nIo",
	date = "1/12/2056"
}
Lunar.register(hellfire)

local hellFireRadius = 50 -- The radius of Hellfire's area of effect.
local hellFireLength = 8 -- The length of the Hellfire effect, in seconds.
local hellfireDelay = 10 --How long, in frames, the game waits before performing another burst of damage.

local hellfireBurning = Buff.new("Hellfire Tincture")
hellfireBurning.sprite = emptySprite --get that default ass buff sprite outta here my boy

-- Hellfire Sounds
local hellfireStart = Sound.find("WispBShoot1", "vanilla")
local hellfireLoop = Sound.find("WormBurning", "vanilla")
local hellfireStop = Sound.find("WormExplosion", "vanilla")

-- Hellfire Particles
local fireBurst = ParticleType.new("Hellfire")
fireBurst:sprite(Sprite.load("fire", "Item/lunar/Graphics/hellfireBurst", 7, 16, 20), true, true, false)
fireBurst:life(30, 60)
fireBurst:alpha(1, 0)
fireBurst:additive(true)
fireBurst:size(0.9, 1.1, 0.01, 0)
fireBurst:angle(0, 360, math.random(-5, 5), 0, true)

local otherFire = ParticleType.find("FireIce", "vanilla")

-- Hellfire Callbacks
hellfireBurning:addCallback("start", function(actor)
    hellfireLoop:loop()
end)

hellfireBurning:addCallback("end", function(actor)
    hellfireLoop:stop()
    hellfireStop:play(1)
end)

hellfireBurning:addCallback("step", function(actor)
    actor:set("hellfireTimer", actor:get("hellfireTimer") - 1)
    if actor:get("hellfireTimer") <= 0 then
        local baseDamage = actor:get("maxhp_base") / 20
        for _, inst in ipairs(actors:findAllEllipse(actor.x - actor:get("hellfireRadius"), actor.y - actor:get("hellfireRadius"), actor.x + actor:get("hellfireRadius"), actor.y + actor:get("hellfireRadius"))) do
            if inst:get("team") == "player" then
                if inst == actor then
                    local dmg = misc.fireBullet(inst.x, inst.y, inst:getFacingDirection(), 1, (baseDamage) * (hellfireDelay / 60), "neutral", nil, DAMAGER_NO_PROC + DAMAGER_NO_RECALC)
                    dmg:set("specific_target", inst.id)
                else
                    local dmg = misc.fireBullet(inst.x, inst.y, inst:getFacingDirection(), 1, (baseDamage * 0.5) * (hellfireDelay / 60), "neutral", nil, DAMAGER_NO_PROC + DAMAGER_NO_RECALC)
                    dmg:set("specific_target", inst.id)
                end
            elseif inst:get("team") == "enemy" then
                local dmg = misc.fireBullet(inst.x, inst.y, inst:getFacingDirection(), 1, (baseDamage * 24) * (hellfireDelay / 60), "neutral", nil, DAMAGER_NO_PROC + DAMAGER_NO_RECALC)
                dmg:set("specific_target", inst.id)
            end
        end
        actor:set("hellfireTimer", hellfireDelay)
    elseif actor:get("hellfireTimer") % 2 == 0 then
        local sizeRatio = (hellFireRadius / 31)
        fireBurst:size(sizeRatio*0.9, sizeRatio*1.1, 0.01, 0)
        fireBurst:burst("middle", actor.x, actor.y, 1)
    end
    otherFire:burst("below", actor.x + math.random(-actor.sprite.width, actor.sprite.width), actor.y, 1)
end)

registercallback("onPlayerDrawAbove", function(player)
    if player:hasBuff(hellfireBurning) and modloader.checkFlag("show_hellfire_aoe") then
        graphics.color(Color.fromRGB(45, 62, 223))
        graphics.alpha(0.5)
        graphics.circle(player.x, player.y, hellFireRadius, true)
    end
end)

hellfire:addCallback("use", function(player, embryo)
    hellfireStart:play(1 + math.random() * 0.1)
    player:set("hellfireTimer", 0)
    if embryo then
        player:set("hellfireRadius", hellFireRadius * 2)
    else
        player:set("hellfireRadius", hellFireRadius)
    end
    player:applyBuff(hellfireBurning, hellFireLength*60)
end)

registercallback("onGameEnd", function()
    hellfireLoop:stop()
end)

---------------------------------------------------------------------------------------------------------------------

-- Spinel Tonic --
local tonic = Item.new("Spinel Tonic")
tonic.displayName = "Spinel Tonic"
tonic.pickupText = "Dramatically increase all stats for 20 seconds. Chance of lowering stats while not in effect."
tonic.sprite =Sprite.load("tonic", "Items/lunar/Graphics/tonic", 2, 12, 16)
tonic.isUseItem = true
tonic.useCooldown = 45
tonic.color = LunarColor
tonic:setLog{
	group = "end",
    description = "&b&Dramatically increase all stats&!& for &y&20 seconds&!&. When the tonic wears off, &y&20% chance&!& to gain a &r&Tonic Affliction that lowers all stats&!&.",
    priority = "&b&Unaccounted For&!&",
	story = "This brew literally knocked my socks off. I don't know who made it, but I took a sip of the thing and woke up two weeks later. Among other things, while drunk I apparently: stole a car, lifted a ten ton truck to save what I thought was a trapped animal (it was a branch), successfully made 10,000 credits in a solid business venture, and did my taxes. This thing needs to go in the records, FAST.",
	destination = "Brewery Hall of Fame,\nMount Sinai B,\nVenus",
	date = "5/5/2056"
}
Lunar.register(tonic)

local afflictionChance = 1

local tonicAffliction = Item.new("Tonic Affliction")
tonicAffliction.displayName = "Tonic Affliction"
tonicAffliction.pickupText = "Reduces all stats by 5% when not under the effect of Spinel Tonic."
tonicAffliction.sprite = Sprite.load("tonicAffliction", "Items/lunar/Graphics/tonicAffliction", 1, 16, 16)
tonicAffliction.color = Color.BLACK

local tonicBuff = Buff.new("tonicBuff")
tonicBuff.sprite = Sprite.load("EfBuffTonic", "Item/lunar/Graphics/tonicBuff", 1, 9, 7.5)

tonicBuff:addCallback("start", function(player)
    player:set("damage", player:get("damage") + (2 * player:countItem(tonicAffliction))):set("damage", (player:get("damage") * 2))
    player:set("hp_regen", player:get("hp_regen") + (0.005 * player:countItem(tonicAffliction))):set("hp_regen", (player:get("hp_regen") * 3))
    player:set("armor", player:get("armor") + (5 * player:countItem(tonicAffliction))):set("armor", (player:get("armor") + 20) )
    player:set("percent_hp", player:get("percent_hp") + (0.05 * player:countItem(tonicAffliction))):set("percent_hp", (player:get("percent_hp") + 0.5))
    player:set("attack_speed", player:get("attack_speed") + (0.025 * player:countItem(tonicAffliction))):set("attack_speed", (player:get("attack_speed") + 0.7) )
    player:set("pHmax", player:get("pHmax") + (0.02 * player:countItem(tonicAffliction))):set("pHmax", (player:get("pHmax") + 0.3) )
end)

registercallback("onPlayerHUDDraw", function(player, x, y)
    if player:hasBuff(tonicBuff) then
        local w, h = graphics.getGameResolution()
        graphics.color(Color.DARK_BLUE)
        graphics.setBlendModeAdvanced("sourceColour", "sourceColourInv")
        graphics.rectangle(0, 0, w, h, false)
    end
end)
tonicBuff:addCallback("end", function(player)
    local getAffliction = math.random()
    if player:get("luck") then
        for i = 1, player:get("luck") do
            getAffliction = math.random()
        end
    end
    if getAffliction < afflictionChance then
        player:giveItem(tonicAffliction)
        local affliction = tonicAffliction:create(player.x + (player:get("pHspeed") * player.xscale), player.y + player:get("pVspeed"))
        affliction:set("item_dibs", player.id)
        affliction:set("used", 1)
    end
    player:set("damage", (player:get("damage") / 2)):set("damage", player:get("damage") - (2 * player:countItem(tonicAffliction)))
    player:set("hp_regen", math.clamp((player:get("hp_regen") / 3), 0, player:get("hp_regen"))):set("hp_regen", math.clamp(player:get("hp_regen") - (0.005 * player:countItem(tonicAffliction)), 0, player:get("hp_regen")))
    player:set("armor", (player:get("armor") - 20)):set("armor", player:get("armor") - (5 * player:countItem(tonicAffliction)))
    player:set("percent_hp", (player:get("percent_hp") - 0.5)):set("percent_hp", player:get("percent_hp") - (0.05 * player:countItem(tonicAffliction)))
    player:set("attack_speed", math.clamp((player:get("attack_speed") - 0.7), 0.5, player:get("attack_speed"))):set("attack_speed", math.clamp(player:get("attack_speed") - (0.025 * player:countItem(tonicAffliction)), 0.5, player:get("attack_speed")))
    player:set("pHmax", math.clamp((player:get("pHmax") - 0.3), 0.5, player:get("pHmax"))):set("pHmax", math.clamp(player:get("pHmax") - (0.02 * player:countItem(tonicAffliction)), 0.5, player:get("pHmax")))
end)

tonic:addCallback("use", function(player, embryo)
    player:applyBuff(tonicBuff, 20*60)
end)

IRL.setRemoval(tonicAffliction, function(player)
    if not player:hasBuff(tonicBuff) then
        player:set("damage", player:get("damage") + (2))
        player:set("hp_regen", player:get("hp_regen") + (0.005))
        player:set("armor", player:get("armor") + (5))
        player:set("percent_hp", player:get("percent_hp") + (0.05))
        player:set("attack_speed", player:get("attack_speed") + (0.025))
        player:set("pHmax", player:get("pHmax") + (0.02))
    end
end)

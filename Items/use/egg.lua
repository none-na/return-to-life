--RoR2 Demake Project
--Made by Sivelos
--egg.lua
--File created 2019/09/29

local egg = Item("Volcanic Egg")
egg.pickupText = "Transform into a draconic fireball, damaging enemies as you pass."

egg.sprite = Sprite.load("Items/use/Graphicsegg.png", 2, 14, 16)

egg.isUseItem = true
egg.useCooldown = 30

egg:setTier("use")
egg:setLog{
    group = "use",
    description = "Transform into a draconic fireball, damaging enemies for 200%. Detonates at the end for 800%.",
    story = "---",
    destination = "---,\n---,\n---",
    date = "--/--/2056"
}

local enemies = ParentObject.find("enemies", "vanilla")

local sprites = {
    fireball = Sprite.load("Graphics/fireBall", 1, 7, 7),
    detonate = Sprite.find("EfExplosive", "vanilla"),
    damage = Sprite.find("EfFirey", "vanilla")
}

local sounds = {
    detonate = Sound.find("ExplosiveShot", "vanilla")
}

local fireball = ParticleType.new("eggFire")
fireball:sprite(sprites.fireball, false, false, false)
fireball:additive(true)
fireball:alpha(1, 0)
fireball:angle(0, 0, 1, 0, true)
fireball:life(60, 60)

local volcanicEgg = Buff.new("VolcanicEgg")

volcanicEgg.sprite = Sprite.find("Empty", "RoR2Demake")

volcanicEgg:addCallback("start", function(actor)
    local data = actor:getData()
    local self = actor:getAccessor()
    data.f = 0
    self.pGravity2 = self.pGravity2 - 0.225
    actor.alpha = 0
    self.pHmax = self.pHmax + 0.3
    if Object.findInstance(actor:getAccessor().rope_parent) then
        actor:set("moveUp", 1)
    end
    data.eggHit = {}
    data.direction = actor.xscale
end)

volcanicEgg:addCallback("step", function(actor)
    local data = actor:getData()
    local self = actor:getAccessor()
    data.f = data.f + 1
    self.activity = 7
    if data.direction == -1 then
        actor:getAccessor().moveLeft = 1
        actor:getAccessor().moveRight = 0
    else
        actor:getAccessor().moveLeft = 0
        actor:getAccessor().moveRight = 1
    end
    if input.checkControl("left") == input.PRESSED then
        data.direction = -1
    elseif input.checkControl("right") == input.PRESSED then
        data.direction = 1
    end
    if data.f % 5 == 0 then
        ParticleType.find("Fire3", "vanilla"):burst("middle", actor.x + math.random(-10, 10), actor.y + math.random(-10, 10), 1)
    end
    local closestActor = enemies:findNearest(actor.x, actor.y)
    if closestActor and closestActor:isValid() then
        if actor:collidesWith(closestActor, actor.x, actor.y) then
            if closestActor:getAccessor().team ~= actor:getAccessor().team then
                if not data.eggHit[closestActor] then
                    local hit = actor:fireBullet(actor.x, actor.y, actor:getFacingDirection(), 1, 5 * data.eggBonus, sprites.damage)
                    hit:set("specific_target", closestActor.id)
                    data.eggHit[closestActor] = true
                end
            end
        end
    end
    ParticleType.find("Fire2", "vanilla"):burst("middle", actor.x + math.random(-2, 2), actor.y + math.random(-2, 2), 1)
    if input.checkControl("use", actor) == input.PRESSED then
        actor:removeBuff(volcanicEgg)
        actor:setAlarm(0, actor:getAlarm(0) + 30)
    end

end)

volcanicEgg:addCallback("end", function(actor)
    local data = actor:getData()
    local self = actor:getAccessor()
    misc.shakeScreen(5)
    self.pHmax = self.pHmax - 0.3
    sounds.detonate:play(1 + math.random() * 0.05)
    local explosion = actor:fireExplosion(actor.x, actor.y, 1, 4, 8 * data.eggBonus, sprites.detonate, nil)
    self.activity = 0
    self.pGravity2 = self.pGravity2 + 0.225
    actor.alpha = 1
    data.eggHit = {}
end)

callback.register("onPlayerDrawAbove", function(actor)
    if actor:hasBuff(volcanicEgg) then
        graphics.printColor("&w&Press &y&'"..input.getControlString("use").."'&w& to detonate.&!&", actor.x - (graphics.textWidth("Press '"..input.getControlString("use").."' to detonate.", graphics.FONT_DEFAULT)/2), actor.y - (actor.sprite.height * 2), graphics.FONT_DEFAULT)
    end
end)

egg:addCallback("use", function(player, embryo)
    if embryo then
        player:getData().eggBonus = 2
    else
        player:getData().eggBonus = 1
    end
    player:applyBuff(volcanicEgg, 5*60)
end)
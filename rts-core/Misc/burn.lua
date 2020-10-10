
Burned = {}
local burnSprite = Sprite.load("graphics/burn", 1, 5, 9)

local constants = {
    baseLength = 2*60, --Base length of burn, in frames
    tickRate = 30, --Burn deals damage every X frames
    maxDPS = 0.05, --maxHP * maxDPS = maximum amount of damage per second all burn stacks can do. If burn damage exceeds this percentage of HP, damage is decreased for all burnstacks
    maxLength = 5*60 --Burns cannot last longer than this
}

local actors = ParentObject.find("actors", "vanilla")

local burnFX = ParticleType.new("Smoldering")
burnFX:sprite(Sprite.load("graphics/full", 1, 0, 0), false, false, false)
burnFX:color(Color.fromRGB(255, 249, 170), Color.fromRGB(186, 61, 29), Color.fromRGB(32, 19, 21))
burnFX:speed(0, 1, 0, 0.1)
burnFX:direction(85, 95, 0, 1)
burnFX:life(30, 30)

registercallback("onActorInit", function(actor)
    local burnData = actor:getData()
    burnData.burnStacks = {}
end)

Burned.ApplyBurn = function(applier, target, multiplier)
    if target:getObject() == Object.find("WormBody", "vanilla") then
        target = Object.find("WormHead", "vanilla"):findNearest(target.x, target.y)
    elseif target:getObject() == Object.find("WurmBody", "vanilla") then
        target = Object.find("WurmHead", "vanilla"):findNearest(target.x, target.y)
    end
    local burnData = target:getData()
    if multiplier then
        if multiplier <= 0 then
            multiplier = 1
        end
    end
    -- {applier's damage, burn length, frames between each pulse of damage}
    local newBurnStack = {
        damage = applier:get("damage"),
        length = math.clamp(math.round((constants.baseLength) * (multiplier or 1)), 0, constants.maxLength),
        tickRate = constants.tickRate
    }
    if burnData.burnStacks and target:isValid() then
        table.insert(burnData.burnStacks, newBurnStack)
    end
end

Burned.Clear = function(target)
    local burnData = target:getData()
    burnData.burnStacks = {}
    burnData.burnStackCount = 0
end

registercallback("onHit", function(damager, hit, x, y)
    local parent = damager:getParent()
    if parent then
        if parent:isValid() and damager:get("burn") then
            if damager:get("burn") > 0 then
                Burned.ApplyBurn(parent, hit, damager:get("burn"))
            end
        end
    end
end)

registercallback("onStep", function()
    for _, actor in ipairs(actors:findAll()) do
        if actor:isValid() then
            local burnData = actor:getData()
            burnData.burnStackCount = 0
            if burnData.burnStacks ~= nil then
                -- Check to see if all burn stacks exceed DPS limit
                local totalDPS = 0
                for _, burnStack in ipairs(burnData.burnStacks) do
                    totalDPS = totalDPS + burnStack.damage --add stack damage to total DPS...
                end
                local damageModifier = 1
                if totalDPS > 0 then
                    damageModifier = math.clamp((actor:get("maxhp") * constants.maxDPS) / totalDPS, 0, 1)
                end
                -- Enforce Burn Stacks
                for _, burnStack in ipairs(burnData.burnStacks) do
                    burnData.burnStackCount = burnData.burnStackCount + 1 --Add to stack count
                    if burnStack.length > 0 then --Is the burn stack still applied?
                        if burnStack.tickRate <= 0 then --Tick the burn stack
                            local damage = math.clamp((burnStack.damage * damageModifier), 0, actor:get("maxhp") * 0.9) --Calculate damage
                            if math.round(damage) <= 0 then --If the rounded damage is less than zero, display 1 damage so it doesn't seem like NO damage is being applied
                                misc.damage(1, actor.x, actor.y - (actor.sprite.height / 2), false, Color.RED)
                            else
                                misc.damage(math.round(damage), actor.x, actor.y - (actor.sprite.height / 2), false, Color.RED)
                            end
                            local stat = "hp"
                            if actor:get("shield") > 0 then --If the actor's shields are up, change affected stat to shield
                                stat = "shield"
                            end
                            if actor:get("barrier") and actor:get("barrier") > 0 then --If the actor has a barrier, chance affected stat to barrier
                                stat = "barrier"
                            end
                            actor:set(stat, actor:get(stat) - damage) --Apply the damage
                            if stat == "shield" and actor:get("shield_cooldown") <= 0 then --If shield is affected and the shield isn't on cooldown, put it on cooldown
                                actor:set("shield_cooldown", 7*60)
                            end
                            burnStack.tickRate = constants.tickRate --Reset tick counter
                        else
                            burnStack.tickRate = burnStack.tickRate - 1 --Incriment tick rate
                        end
                        burnStack.length = burnStack.length - 1 --Incriment length
                    else
                        burnData.burnStackCount = burnData.burnStackCount - 1 --Once burn runs out, remove 1 from stack count
                        burnData.burnStacks[burnStack] = nil --Empty slot in burnStacks array
                    end
                end
                if actor:get("hp") <= 0 then --If the actor dies, reset burn data
                    burnData.burnStacks = {}
                    burnData.burnStackCount = 0
                end
            end 
        end
    end
end)

registercallback("onDraw", function()
    for _, actor in ipairs(actors:findAll()) do
        if actor:isValid() then
            local burnData = actor:getData()
            if burnData.burnStackCount == nil then
                burnData.burnStackCount = 0
            end
            if burnData.burnStackCount > 0 then
                burnFX:burst("above", actor.x + (math.random(-actor.sprite.width / 2, actor.sprite.width / 2)),actor.y + (math.random(-actor.sprite.height / 2, actor.sprite.height / 2)), 1)
                graphics.drawImage{
                    burnSprite,
                    actor.x,
                    actor.y - actor.sprite.height
                }
                graphics.printColor("&or&"..burnData.burnStackCount.."&!&", actor.x + (burnSprite.width / 4), actor.y - (actor.sprite.height), graphics.FONT_DAMAGE)
            end
        end
    end
end)

export("Burned")
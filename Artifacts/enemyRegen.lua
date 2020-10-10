local enemyRegen = Artifact.new("Vitality")
-- Make the artifact be unlocked by default
enemyRegen.unlocked = true


-- Set the artifact's loadout info
enemyRegen.loadoutSprite = Sprite.load("Artifacts/enemyRegen", 2, 18, 18)
enemyRegen.loadoutText = "Enemies regenerate health out of combat."

local enemies = ParentObject.find("enemies", "vanilla")

local regenCooldown = 3*60

local regenCoefficient = 0.001

registercallback("onActorInit", function(actor)
    if enemyRegen.active then
        if actor:get("team") == "enemy" then
            actor:set("regen_cooldown", regenCooldown)
        end
    end
    
end)

registercallback("onStep", function()
    if enemyRegen.active then
        for _, enemy in ipairs(enemies:findAll()) do
            if enemy:get("regen_cooldown") ~= nil then
                if enemy:get("regen_cooldown") <= 0 then
                    if (enemy:get("hp") + ((enemy:get("maxhp") * regenCoefficient)) > enemy:get("maxhp")) == false then
                        enemy:set("hp", enemy:get("hp") + (enemy:get("maxhp") * regenCoefficient))
                    end
                else
                    enemy:set("regen_cooldown", enemy:get("regen_cooldown") - 1)
                end
            end
        end
    end
end)

registercallback("onHit", function(damager, hit, x, y)
    if enemyRegen.active then
        if hit:get("team") == "enemy" then
            hit:set("regen_cooldown", regenCooldown)
        end
    end
end)
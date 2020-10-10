local mountain = Artifact.new("Mountain")
-- Make the artifact be unlocked by default
mountain.unlocked = true


-- Set the artifact's loadout info
mountain.loadoutSprite = Sprite.load("Artifacts/mountain", 2, 18, 18)
mountain.loadoutText = "More risk, more reward."
local difficultyIndicator = Sprite.load("Artifacts/mountainDifficulty", 1, 7, 8)


local director

local bonusAdd = 60 * 20
local bonusAddTimer = 0

registercallback("onStep", function()
    if mountain.active then
        director = misc.director
        if bonusAddTimer <= 0 then
            director:set("bonus_rate", director:get("bonus_rate") + ((director:get("stages_passed") or 0) + 1))
            if director:get("bonus_rate") % 15 == 0 then
                director:set("spawn_boss", 1)
            end
            director:set("boss_item_drops", (director:get("boss_item_drops") or 0) + math.round((director:get("stages_passed") + 2 or 2) / 2))
            bonusAddTimer = math.clamp(math.round(bonusAdd * (3 / director:get("stages_passed"))), 60, bonusAdd)
        else
            bonusAddTimer = bonusAddTimer - 1
        end
    end
    
end)

registercallback("onActorInit", function(actor)
	if mountain.active then
        director = misc.director
		local isEnemy = actor:get("team")
		if isEnemy == "enemy" then
            actor:set("point_value", actor:get("point_value") * ((director:get("stages_passed") or 0) + 10))
            if actor:get("exp_worth") then
                actor:set("exp_worth", (actor:get("exp_worth") * 2) or 1)
            end
		end
	end
end)

registercallback("onPlayerHUDDraw", function(player, x, y)
    if mountain.active then
        local w, h = graphics.getGameResolution()
        graphics.drawImage{
            difficultyIndicator,
            x = w - 110,
            y = 27
        }
    end
    
end)
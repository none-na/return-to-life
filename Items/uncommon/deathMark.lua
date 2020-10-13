--RoR2 Demake Project
--Made by Sivelos
--deathMark.lua
--File created 2020/04/29

local item = Item("Death Mark")
item.pickupText = "Enemies with four or more debuffs are marked for death, taking bonus damage."

item.sprite = restre.spriteLoad("Graphics/deathMark.png", 1, 16, 16)

item:setTier("uncommon")
item:setLog{
    group = "uncommon",
    description = "Enemies with &y&4&!& or more debuffs are &y&marked for death&!&, increasing damage taken by &y&+50%&!& from all sources for &b&7&!& seconds.",
    story = "Everyone said that I was crazy to search for lost artifacts on Mars. Idiots. There hasn’t been any proof of a previous civilization - but I’ve always trusted my gut. This skull proves that I’m right - that something did exist here before.\nThat smug professor at the university... always disparaging my research. I loved seeing the look on his face as I shook his hand. Idiot. Karma must have been working overtime - I heard he fell ill shortly after. I suppose my success was just too much for him.\n...In fact, everyone I’ve shown seems to not be returning my calls. Are they avoiding me? Are they scared this news would shake up their academic communities? Too proud to admit I’m right?\nI’ll find someone who will give me the recognition I deserve. I’ve worked too hard and done too much. If I don’t keep going, I think I might just die.",
    destination = "421 Lane,\nLab [72],\nMars",
    date = "2/22/2056"
}

local crit = Sound.find("Crit", "vanilla")

local buffIcon = Sprite.load("deathMarkBuff","Graphics/deathMark", 1, 9, 7)

local buff = Buff.new("deathMark")
buff.sprite = buffIcon

buff:addCallback("step", function(actor)
    local data = actor:getData()
    local stack = data.deathMark or 0
    if stack > 0 then
        local hpDelta = actor:get("hp") - actor:get("lastHp")
        if hpDelta < 0 then
            crit:play(0.5)
            local bonus = (math.abs(actor:get("hp") - hpDelta) * (1.5 * stack))
            misc.damage(bonus, actor.x, actor.y, false, Color.ROR_RED)
            actor:set("hp", actor:get("hp") - bonus)
        end
    end
end)
buff:addCallback("end", function(actor)
    local data = actor:getData()
    data.deathMark = 0
end)

callback.register("onHit", function(damager, hit, x, y)
    local parent = damager:getParent()
    if parent and parent:isValid() and type(parent) == "PlayerInstance" then
        if parent:countItem(item) > 0 then
            local stack = parent:countItem(item)
            local buffs = #hit:getBuffs()
            if buffs > 4 then
                if not hit:hasBuff(buff) then
                    hit:applyBuff(buff, 7*60)
                    hit:getData().deathMark = parent:countItem(item)
                end
            end
        end
    end
end)
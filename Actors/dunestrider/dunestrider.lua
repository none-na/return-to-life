local sprites = {
    idle = Sprite.load("ClayBIdle", "Actors/dunestrider/idle", 5, 38,67),
    walk = Sprite.load("ClayBWalk", "Actors/dunestrider/walk", 6, 50,68),
    death = Sprite.load("ClayBDeath", "Actors/dunestrider/death", 12, 39,89),
    --mask = Sprite.load("BellMask", "Actors/bell/idle", 1,8,14),
    palette = Sprite.load("ClayBPal", "Actors/dunestrider/palette", 1, 0, 0)
}

local dunestrider = Object.base("BossClassic", "ClayB")
dunestrider.sprite = sprites.idle

EliteType.registerPalette(sprites.palette, dunestrider)

dunestrider:addCallback("create", function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    self.name = "Clay Dunestrider"
    self.name2 = "Ravenous Symbiont"
    self.maxhp = 2100 * Difficulty.getScaling("hp")
    self.hp = self.maxhp
    self.damage = 20 * Difficulty.getScaling("damage")
    self.pHmax = 1
    actor:setAnimations{
        idle = sprites.idle,
        walk = sprites.walk,
        jump = sprites.idle,
        death = sprites.death,
    }
    self.sound_hit = Sound.find("ClayHit", "vanilla").id
    --self.sound_death = sounds.death.id
    actor.mask = sprites.idle
    self.show_boss_health = 1
    self.health_tier_threshold = 1
    self.exp_worth = 10
    self.shake_frame = 7
    actor:set("sprite_palette", sprites.palette.id)
    self.z_range = 0
    self.can_drop = 0
    self.can_jump = 0
end)

dunestrider:addCallback("step", function(actor)
    local self = actor:getAccessor()
    local data = actor:getData()
    if self.state == "attack1" then --summon balls
        if actor:getAlarm(2) <= -1 then
            
        end
    end
end)

local monsLog = MonsterLog.new("Clay Dunestrider")
MonsterLog.map[dunestrider] = monsLog

monsLog.displayName = "Clay Dunestrider"
monsLog.story = "Among the nastiest creatures this planet has to offer, the Clay Dunestrider is among the worst. Perhaps the progenitor of the Clay Men, or some twisted relative, the Dunestrider walks around on eight spindly legs, carrying a massive pot full of tar. This tar is no ordinary liquid... It seems to have some kind of lifeforce. Even now, the black stains covering my suit cling with an... unnatural persistence.\n\nThe Dunestriders gather along an Aqueduct in the middle of a scorching desert, which carries an unending flow of tar from an unknown source. Filling up their pots, the Dunestriders scatter to carry their tar across the planet. What purpose do they serve by doing this? Do they want to spread tar to every corner of this planet, and suck it dry of all life?"
monsLog.statHP = 2100
monsLog.statDamage = 20
monsLog.statSpeed = 1
monsLog.sprite = sprites.walk
monsLog.portrait = sprites.idle
monsLog.portraitSubimage = 1
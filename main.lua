--RoR2 Demake Project
--Made by N4K0
--main.lua
--File created 2019/04/07

-- Picked up by Sivelos

local debugMode = modloader.checkFlag("NIKO_DEBUG_ENABLE")

Music = {
    MainTheme = Sound.load("MainTheme", "Sounds/BGM/main_theme.ogg"),
    Dehydrated = Sound.load("Dehydrated", "Sounds/BGM/dehydrated.ogg"),
    Disdrometer = Sound.load("Disdrometer", "Sounds/BGM/disdrometer.ogg"),
    Evatransportation = Sound.load("Evatransportation", "Sounds/BGM/evatransportation.ogg"),
    Hydrophobia = Sound.load("Hydrophobia", "Sounds/BGM/hydrophobia.ogg"),
    IntoTheDoldrums = Sound.load("IntoTheDoldrums", "Sounds/BGM/into_the_doldrums.ogg"),
    KoppenAsFuck = Sound.load("KoppenAsFuck", "Sounds/BGM/koppen_as_fuck.ogg"),
    NocturnalEmission = Sound.load("NocturnalEmission", "Sounds/BGM/nocturnal_emission.ogg"),
    Parjanya = Sound.load("Parjanya", "Sounds/BGM/parjanya.ogg"),
    PetrichorV = Sound.load("PetrichorV", "Sounds/BGM/petrichor_v.ogg"),
    RaindropThatFellToTheSky = Sound.load("RaindropThatFellToTheSky", "Sounds/BGM/raindrop_that_fell_to_the_sky.ogg"),
    TerraPluviam = Sound.load("TerraPluviam", "Sounds/BGM/terra_pluviam.ogg"),
    ThermodynamicEquilibrium = Sound.load("ThermodynamicEquilibrium", "Sounds/BGM/thermodynamic_equilibrium.ogg"),
    AGlacierEventuallyFarts = Sound.load("AGlacierEventuallyFarts", "Sounds/BGM/glacierEventuallyFarts.ogg"),
}

--[[if debugMode then
	require("debug")
end]]--

local empty = Sprite.load("Empty", "Graphics/empty", 1, 0,0)
-- Libraries

local achieveIcons = {}

MakeAchievementIcon = function(sprite, subimage)
    local surface = Surface.new(sprite.width, sprite.height)
    graphics.setTarget(surface)
    graphics.drawImage{
    	image = sprite,
	    subimage = subimage,
    	x = 0,
	    y = 0
    }
    graphics.resetTarget()
    local dSprite = surface:createSprite(sprite.width/2, sprite.height/2)
    table.insert(achieveIcons, dSprite:finalize("achievementIcon"..#achieveIcons))
    return achieveIcons[#achieveIcons]
end


--Reskin title
require("misc.title")

--Other
require("Misc.teleporterSounds")
require("Misc.vignette")
require("Misc.flyingEnemy")
require("Misc.lunar")
require("Misc.enemyShields")

-- Characters

local Survivors = {
    "commando.commando",
    "huntress.huntress",
    "mercenary.merc",
    "engi.engi",
    --"acrid.acrid",
    --"loader.loader",
    "mult.mult",
    --"artificer.artificer",
    --"rex.rex"
}
for _, char in ipairs(Survivors) do
    local survivor = require("Actors."..char)   
end


--Allies
--[[require("Actors.tc280.tc280")
require("Actors.equipDrone.equipDrone")]]

-- Enemies
--[[require("Actors.beetle.beetle")
require("Actors.beetleGuard.beetleGuard")
require("Actors.vulture.vulture")
require("Actors.templar.templar")
require("Actors.bell.bell")
require("Actors.reaver.reaver")]]

-- Bosses
--[[require("Actors.reliquary.reliquary")
require("Actors.scavenger.scavenger")
require("Actors.titan.titan")
require("Actors.vagrant.vagrant")
require("Actors.dunestrider.dunestrider")
require("Actors.roboball.roboball")]]

--Enemy Stuff
if not modloader.checkFlag("disable_enemy_changes") then
    require("Misc.enemyModifiers")
end
require("Misc.eliteModifiers")

-- Other Actors
require("Actors.newt.newt")

--Rare Items
require("Items.disc")
require("Items.aegis")
require("Items.novaOnHeal")
require("Items.healingRack")
require("Items.wakeOfVultures")
require("Items.afterburner")
require("Items.catalyst")
require("Items.meathook")
require("Items.headstompers")
require("Items.brainstalks")
require("Items.clover")

--Uncommon Items
--require("Items.deathMark")
require("Items.tome")
require("Items.razorwire")
require("Items.daisy")
require("Items.guillotine")
require("Items.warhorn")
require("Items.stealthkit")
require("Items.fireRing")
require("Items.iceRing")
require("Items.quail")
require("Items.buckler")
require("Items.fuelCell")
require("Items.bandolier")
require("Items.pauldron")

--Common Items
--require("Items.armorPlate")
require("Items.meat")
require("Items.crystal")
require("Items.brooch")
require("Items.shieldgen")
require("Items.backupmag")
require("Items.aprounds")
require("Items.energyDrink")
require("Items.key")

--Boss Items
require("Items.knurl")
require("Items.queensGland")
require("Items.goldseed")
require("Items.disciple")
require("Items.genesisLoop")
require("Items.pearl")
---------------------------------------
BossItems = ItemPool.new("boss")
BossItems.weighted = true
BossItems:add(Item.find("Burning Witness", "vanilla"))
BossItems:add(Item.find("Colossal Knurl", "vanilla"))
BossItems:add(Item.find("Ifrit's Horn", "vanilla"))
BossItems:add(Item.find("Imp Overlord's Tentacle", "vanilla"))
BossItems:add(Item.find("Legendary Spark", "vanilla"))
BossItems:add(Item.find("Nematocyst Nozzle", "vanilla"))
BossItems:add(Item.find("Queen's Gland", "RoR2Demake"))
BossItems:add(Item.find("Little Disciple", "RoR2Demake"))
BossItems:add(Item.find("Genesis Loop", "RoR2Demake"))
BossItems:add(Item.find("Halcyon Seed", "RoR2Demake"))
BossItems:setWeight(Item.find("Halcyon Seed", "RoR2Demake"), 99999)
BossItems:add(Item.find("Pearl", "RoR2Demake"))
BossItems:setWeight(Item.find("Pearl", "RoR2Demake"), 99999)
BossItems:add(Item.find("Irradiant Pearl", "RoR2Demake"))
BossItems:setWeight(Item.find("Irradiant Pearl", "RoR2Demake"), 99999)
---------------------------------------

--Use Items
require("Items.elephant")
require("Items.egg")
require("Items.blastShower")
require("Items.gateway")
require("Items.hud")
require("Items.chrysalis")
require("Items.cube")
require("Items.capacitor")
require("Items.crowdfunder")
require("Items.woodsprite")
require("Items.bfg")
require("Items.radar")
require("Items.eliteAffix")
require("Items.fuelArray")

--Artifacts

--Objects
require("Objects.categoryChest")
require("Objects.mountainShrine")
require("Objects.obelisk")
require("Objects.printer")
--require("Objects.altarOfGold")

--Stages
--[[require("Stages.aqueduct")
--require("Stages.acres")
require("Stages.rallypoint")
require("Stages.sirensCall")
require("Stages.void")
require("Stages.bazaar")
require("Stages.moment")
require("Stages.goldshores")
require("Stages.ambry")]]


if modloader.checkFlag("ror2_debug") then
    local noEnemies = Artifact.new("Peace")
    noEnemies.unlocked = true
    noEnemies.loadoutSprite = Sprite.load("A","Artifacts/example artifact loadout", 2, 18, 18)
    noEnemies.loadoutText = "Disables enemy spawns."
    registercallback("onStep", function()
        if noEnemies.active then
            local director = misc.director
            director:set("points", 0)
        end
    end)

    local allEnemies = Artifact.new("Combat")
    allEnemies.unlocked = true
    allEnemies.loadoutSprite = Sprite.find("A", "RoR2Demake")
    allEnemies.loadoutText = "Encourages enemy spawns."
    registercallback("onStep", function()
        if allEnemies.active then
            local director = misc.director
            director:set("points", director:get("points") + 1)
        end
    end)
end
local itemsToLoad = {
  boss = {"disciple", "genesisLoop", "goldseed", "knurl", "pearl", "queensGland", },
  common = {"aprounds", "armorPlate", "backupmag", "brooch", "crystal", "energyDrink", "key", "meat", "shieldgen", "slug", },
  --lunar = {"lunarItems", },
  rare = {"aegis", "afterburner", "brainstalks", "catalyst", "clover", "disc", "headstompers", "healingRack", "meathook", "novaOnHeal", "wakeOfVultures", },
  uncommon = {"bandolier", "buckler", "chronobauble", "daisy", "deathMark", "fireRing", "fuelCell", "guillotine", "iceRing", "pauldron", "quail", "razorwire", "stealthkit", "tome", "warhorn", },
  use = {"bfg", "blastShower", "capacitor", "chrysalis", "crowdfunder", "cube", "egg", "elephant", "eliteAffix", "fuelArray", "gateway", "hud", "radar", "woodsprite", },
}

--Fake IRL to stop items from erroring
IRL = {
  setRemoval = function(a, b)

  end,
}

for tier, table in pairs(itemsToLoad) do
  for _, item in ipairs(table) do
    print(tier..[[\]]..item)
    restre_require(tier..[[\]]..item)
  end
end

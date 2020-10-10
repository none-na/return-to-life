

local goldShoresController = Object.new("GoldShoresMissionController")

local beaconTarget = 7
local beaconCooldown = 60*60 --How many frames it takes for beacons to deactivate when all are active
local aurelionite = Object.find("TitanGold", "RoR2Demake") --Ya boy, big dick Gold Man
local goldseed = Item.find("Halcyon Seed", "RoR2Demake") --The reward
local portal = Object.find("Gold Portal", "RoR2Demake")



goldShoresController:addCallback("create", function(self)
    self.x = 0
    self.y = 0
    local data = self:getData()
    data.beacons = 0 --How many beacons are currently activated
    data.state = 0 --Current state of the mission
    data.fullActivations = 0 --How many times every beacon has been activated
    data.cooldown = 0 --Cooldown for beacon deactivation
    data.boss = nil --Aurelionite instance
end)
goldShoresController:addCallback("step", function(self)
    local data = self:getData()
    local hud = misc.hud
    if data.state == 0 then --Not every beacon is activated
        if data.boss and data.boss:isValid() then
            data.boss:set("invincible", 9999)
            hud:set("boss_hp_color", Color.fromRGB(188, 152, 37).gml)
            for _, actorInst in ipairs(ParentObject.find("actors", "vanilla"):findAll()) do
                if actorInst ~= data.boss then
                    actorInst:set("show_boss_health", 0)
                end
            end
        end
        hud:set("objective_text", "Activate the Halcyon Beacons! ("..data.beacons.."/"..beaconTarget..")")
        if data.beacons >= 4 and not data.boss then
            if data.spawn then
                if data.spawn > 0 then
                    data.spawn = data.spawn - 1
                    misc.shakeScreen(1)
                else
                    local flash = Object.find("EfFlash", "vanilla"):create(0, 0)
                    Sound.find("TitanSpawn", "RoR2Demake"):play(1)
                    local inst = aurelionite:create(100, 100)
                    local self = inst:getAccessor()
                    self.damage = 40 * Difficulty.getScaling("damage")
                    self.maxhp = 2100 * Difficulty.getScaling("hp")
                    self.hp = self.maxhp
                    data.boss = inst
                end
            else
                data.spawn = 2*60
            end
        end
        if input.checkKeyboard("b") == input.PRESSED then
            data.beacons = data.beacons + 1
        end
        if data.beacons >= beaconTarget then
            data.state = 1
            data.boss:set("invincible", 0)
            data.cooldown = beaconCooldown
        end
    elseif data.state == 1 then --Every beacon has been activated, Aurelionite is vulnerable
        hud:set("boss_hp_color", Color.ROR_RED.gml)
        hud:set("objective_text", "Defeat the boss!")
        if data.cooldown > 0 then
            data.cooldown = data.cooldown - 1
        else
            local flash = Object.find("EfFlash", "vanilla"):create(0, 0)
            data.beacons = 0
            if data.beaconInsts then
                for _, inst in ipairs(data.beaconInsts) do
                    inst:set("active", 1)
                    inst:set("dead", 0)
                end
            end
            data.state = 0
        end
        if data.boss and not data.boss:isValid() then
            local reward = goldseed:create(100, 100)
            local exitPortal = portal:create(100, 100)
            data.state = 2
        end
    elseif data.state == 2 then --Aurelionite has been defeated
        hud:set("objective_text", "Proceed to the next level.")
    end


end)
goldShoresController:addCallback("destroy", function(self)
    local data = self:getData()

end)
goldShoresController:addCallback("draw", function(self)
    local data = self:getData()

end)
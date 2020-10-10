--Stage.lua

Stages = {}

Stages.count = 0

local collision = {
    default = Object.find("B", "vanilla"),
    spawnDisabled = Object.find("BNoSpawn", "vanilla"),
    spawnDisabled2 = Object.find("BNoSpawn2", "vanilla"),
    spawnDisabled3 = Object.find("BNoSpawn3", "vanilla"),
    rope = Object.find("Rope", "vanilla"),
    lava = Object.find("Lava", "vanilla"),
    slow = Object.find("Slow", "vanilla"),
    water = Object.find("Water", "vanilla"),
    bossSpawn = Object.find("BossSpawn", "vanilla"), --Colossus, Toxic Beast
    bossSpawn2 = Object.find("BossSpawn2", "vanilla") --Ifrit
}

Stages.Collisions = {
    [0] = collision.default,
    [1] = collision.spawnDisabled,
    [2] = collision.spawnDisabled2,
    [3] = collision.spawnDisabled3,
    [4] = collision.rope,
    [5] = collision.lava,
    [6] = collision.slow,
    [7] = collision.water,
    [8] = collision.bossSpawn,
    [9] = collision.bossSpawn2
}

local tile = Object.new("Tile")
tile:addCallback("create", function(self)
    self.spriteSpeed = 0
end)

Stages.new = function(args)
    local id = Stages.count
    Stages[id] = {}
    if args.displayName then
        Stages[id].displayName = args.displayName
    else
        Stages[id].displayName = "???"
    end
    if args.subname then
        Stages[id].subname = args.subname
    else
        Stages[id].subname = "???"
    end
    if args.dimensions then
        Stages[id].dimensions = args.dimensions
    end
    if args.tileSet then
        Stages[id].tileSet = args.tileSet
    else
        error("New stage must have tile set.")
        Stages[id] = {}
        return
    end
    if args.tileMap then
        Stages[id].tileMap = args.tileMap
    else
        error("New stage must have tile map.")
        Stages[id] = {}
        return
    end
    if args.collisionMap then
        Stages[id].collisionMap = args.collisionMap
    else
        error("New stage must have collision map.")
        Stages[id] = {}
        return
    end
    Stages.count = Stages.count + 1
    return Stages[id]
end

Stages.ResetCurrentStage = function()
    print("DELETE ALL COLLISION LOL")
    for _, b in ipairs(collision.default:findAll()) do
        b:destroy()
    end
    
end

Stages.DrawOverBG = function()
    if Stages["surface"] == nil or not Stages["surface"]:isValid() then
        local origColor = graphics.getColor()
        Stages["surface"] = Surface.new(Stage.getDimensions())
        graphics.color(Color.BLACK)
        graphics.setTarget(Stages["surface"])
        graphics.rectangle(0, 0, Stage.getDimensions())
        graphics.resetTarget()
        graphics.color(origColor)
    end
    Stages["surface"]:draw(0, 0)
end

local offset = 128

-- Pass in either stage ID or stage itself
Stages.BuildStage = function(var)
    local stage = nil
    if type(var) == "number" then
        stage = Stages[var]
    else
        stage = var
    end
    stage.instInfo = {}
    --Draw Tiles and Collision
    stage.instInfo.tiles = {}
    for y = offset, stage.dimensions.y + offset do
        for x = offset, stage.dimensions.x + offset do
            if x % 16 == 0 then
                if y % 16 == 0 then
                    local xx = x - offset
                    local yy = y - offset
                    --print("x:"..x..", y:"..y)
                    for depth = 0, 32000 do
                        if stage.tileMap[depth]  then
                            if stage.tileMap[depth][math.floor(xx/16)][math.floor(yy/16)] and stage.tileMap[depth][math.floor(xx/16)][math.floor(yy/16)] > 0 then
                                print("Creating tile at x:"..x..", y:"..y..", depth:"..depth)
                                local tileInst = tile:create(x, y)
                                tileInst.sprite = stage.tileSet
                                tileInst.depth = depth
                                tileInst.subimage = stage.tileMap[depth][math.floor(xx/16)][math.floor(yy/16)]
                            end
                        end
                    end
                    if stage.collisionMap[math.floor(xx/16)] and stage.collisionMap[math.floor(xx/16)][math.floor(yy/16)] then
                        print("Creating collision at x:"..x..", y:"..y)
                        local collisionInst = nil
                        if Stages.Collisions[stage.collisionMap[math.floor(xx/16)][math.floor(yy/16)].type] then 
                            collisionInst = Stages.Collisions[stage.collisionMap[math.floor(xx/16)][math.floor(yy/16)].type]:create(x,y)
                        else 
                            collisionInst = collision.default:create(x, y)
                        end
                        collisionInst.xscale = 1--stage.collisionMap[math.floor(x/16)][math.floor(y/16)].xscale
                        collisionInst.yscale = 1--stage.collisionMap[math.floor(x/16)][math.floor(y/16)].yscale
                    end
                end
            end
        end
    end
end

return Stages
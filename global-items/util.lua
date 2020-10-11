FindGround = function(x, y, dir)
    local dy = y
    local step = 1
    if dir then
        if dir < 0 then
            dir = -1
        elseif dir > 0 then
            dir = 1
        else
            dir = 1
        end
        step = dir
    end
    local sX, sY = Stage.getDimensions()
    while dy ~= (sY*step) do
        if Stage.collidesPoint(x, dy) then
            break
        else
            dy = dy + step
        end
    end
    return dy
end

Distance = function(x1, y1, x2, y2)
    return math.abs(math.sqrt(math.pow(x2-x1, 2) + math.pow(y2-y1, 2)))
end
-- Vector2D.lua

local vectors = {}

local Vector2D, vector2d = newtype("Vector2D")
-- Creates a vector2D by passing in a table of variables of two variables. Parameters marked with * will be automatically filled in by passed in parameters if not provided.
-- Possible Parameters:
    -- x (number): The vector's X component.*
    -- y (number): The vector's Y component.*
    -- z (number): The vector's magnitude.*
    -- angle (number): The vector's angle in degrees.*
    -- angleRad (number): The vector's angle in radians.*

function vector2d:__init(vars)
    vectors[self] = {}
    --Take in base parameters
    if vars.x then
        vectors[self].x = vars.x
    end
    if vars.y then
        vectors[self].y = vars.y
    end
    if vars.z then
        vectors[self].z = vars.z
    end
    if vars.angle then
        vectors[self].angle = vars.angle
    end
    if vars.angleRad then
        vectors[self].angleRad = vars.angleRad
    end
    --Solve for missing parameters
    if not vectors[self].x then
        if (vectors[self].y and vectors[self].z and (vectors[self].angle or vectors[self].angleRad)) then
            vectors[self].x = vectors[self].z * math.cos((vectors[self].angle or vectors[self].angleRad))
        end
    end
    if not vectors[self].y then
        if (vectors[self].x and vectors[self].z and (vectors[self].angle or vectors[self].angleRad)) then
            vectors[self].y = vectors[self].z * math.sin((vectors[self].angle or vectors[self].angleRad))
        end
    end
    if not vectors[self].z then
        if ((vectors[self].angle or vectors[self].angleRad)) then
            if vectors[self].x then
                vectors[self].z = vectors[self].x/math.cos((vectors[self].angle or vectors[self].angleRad))
            elseif vectors[self].y then
                vectors[self].z = vectors[self].y/math.sin((vectors[self].angle or vectors[self].angleRad))
            end
        end
    end


    --[[if vars.z then
        vectors[self].z = vars.z
        vectors[self].angle = vars.angle
        vectors[self].angleRad = vars.angle * (math.pi/180)
        vectors[self].x = vars.z * math.cos(vars.angle)
        vectors[self].y = vars.z * math.sin(vars.angle)
        
        vectors[self].quadrant = math.clamp(math.ceil(angle/90), 1, 4)
        if vectors[self].quadrant == 1 then --0 to 90
            vectors[self].x = math.abs(vectors[self].x)
            vectors[self].y = math.abs(vectors[self].y)
        elseif vectors[self].quadrant == 2 then --91 to 180
            vectors[self].x = math.abs(vectors[self].x)
            vectors[self].y = -math.abs(vectors[self].y)
        elseif vectors[self].quadrant == 3 then --181 to 270
            vectors[self].x = -math.abs(vectors[self].x)
            vectors[self].y = -math.abs(vectors[self].y)
        elseif vectors[self].quadrant == 4 then --271 to 360
            vectors[self].x = -math.abs(vectors[self].x)
            vectors[self].y = math.abs(vectors[self].y)
        end
    end]]
end

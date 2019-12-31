-- extension of the point class

-- returns the points between self and p2, in order from p1 to p2
function Point:PointsBetween(p2, offsetStart, offsetFinal)

    local function GetSteps(x, y)               -- Get the stair steps to an (x,y) position
        local steps = {}
        
        local horz = math.max(x, y)             -- Length of the stairs, steps are always 1px high
        local vert = math.min(x, y)             -- Height of the stairs
        
        for i = 0, vert - 1 do                  -- Go up the stairs
            local step = math.floor(0.5 + horz / (vert - i)) -- Length of this step
            steps[i] = step                     -- Add step
            horz = horz - step                  -- Go along the stairs
        end
        
        return steps
    end
    
    local function GetSign(x)                   -- Get the sign (-1, 0, 1) of a number
        return x > 0 and 1 or x < 0 and -1 or 0
    end
    
    local points = {}
    local p1 = self
    local lengthX = math.abs(p1.x - p2.x) + 1   -- x distance from here to there
    local lengthY = math.abs(p1.y - p2.y) + 1   -- y distance from here to there
    local tall = lengthY > lengthX              -- if the slope > 1
    local steps = GetSteps(lengthX, lengthY)    -- get the steps across the length
    local start = offsetStart or 0              -- range is limited between start and final
    local final = math.max(lengthX, lengthY) - (offsetFinal or 0)
    
    local inc = 0
    for j = 0, #steps do                        -- for each step across the stairs
        local step = steps[j]                   -- step
        for i = 1, step do                      -- across the length of the step
            local pos1 = inc                    -- coordinate along the stairs
            local pos2 = j                      -- coordinate going up the stairs
            if(inc >= start and inc < final) then   -- limit the range between start and final
                points[inc] = Point(                -- map stair to actual point, add point
                    p1.x + (tall and pos2 or pos1) * GetSign(p2.x - p1.x),
                    p1.y + (tall and pos1 or pos2) * GetSign(p2.y - p1.y))
            end
            inc = inc + 1                       -- increment as we travel across the stairs
        end
    end

    return points
end
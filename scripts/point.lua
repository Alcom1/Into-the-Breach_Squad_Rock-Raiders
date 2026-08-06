--extension of the point class

--hash a point into a unique integer
function Point:RR_Hash()
    return self.x + self.y * 8 --Unique hash for each grid position from 0-63
end

--returns the points between self and p2, in order from p1 to p2
function Point:RR_Bresenham(p2, limitStart, limitFinal)
    
    local function GetSign(x)               --Get the sign (-1, 0, 1) of a number
        return x > 0 and 1 or x < 0 and -1 or 0
    end
    
    local points = {}
    local p1 = self

    local lengthX = math.abs(p1.x - p2.x)   --x distance from here to there
    local lengthY = math.abs(p1.y - p2.y)   --y distance from here to there
    local tall = lengthY > lengthX          --if the slope > 1 (Shoutout to Tall Mech!)

    local horz = math.max(lengthX, lengthY) --Length of the stairs, steps are always 1px high
    local vert = math.min(lengthX, lengthY) --Height of the stairs

    local start = limitStart or 0           --range is limited between start and final
    local final = horz - (limitFinal or 0) + 1

    local diff = -horz                      --Difference in Bresenham's algorithm
    local curr = 0                          --Current height that we're at
    local index = 1                         --Index of insertion

    for i = 0, horz do                      --Bresenham's algorithm
        diff = diff + 2 * vert              --Diff upwards

        if index >= start and index <= final  then  --limit the range between start and final
            points[index - start] = Point(          --map stair to actual point, add point
                p1.x + (tall and curr or i) * GetSign(p2.x - p1.x), --Tall switches octants, Sign switches quadrants
                p1.y + (tall and i or curr) * GetSign(p2.y - p1.y))
        end
        index = index + 1                   --increment as we travel across the stairs

        if diff > 0 then                    --If difference has gone above 0, go up a step
            curr = curr + 1                 --Step upwards
            diff = diff - 2 * horz          --Diff downwards
        end
    end

    return points
end

--Function to return all points in a square ring around the point.
--Size is the distance from the center to the edge of the ring.
--A ring of size 2 is drawn like :
--
-- aaaab
-- d   b
-- d x b
-- d   b
-- dcccc
--
--Where x is this point (self), and each row/column of the same letter is a bar.
function Point:RR_RingTarget(size)

    local ret = {}
    local point = self
    local barLength = size * 2                                  --Length of each bar
    
    --Draw bar for each cardinal direction
    for dir = DIR_START, DIR_END do
        local fore = DIR_VECTORS[dir]                           --Foreward direction along the bar
        local side = DIR_VECTORS[(dir + 1) % 4] * size          --Sideways direction perpendicular to bar

        --For each point along bar
        for i = 0, barLength - 1 do
            local curr = point + side + fore * (i + 1 - size)   --Final calculated position of this bar-point

            if Board:IsValid(point) then                        --If the point on the bar is valid
                ret[#ret + 1] = curr                            --Add it
            end
        end
    end
    
    return ret

end

--Returns all points hit when firing a laser in a given direction
function Point:RR_LaserPoints(direction)
    
    local points = {}   --Points hit by laser
    local index = 1     --Index of next point to add
    local point = self  --Self

    --Just keep looping
    while true do
        
        --Move point forward
        point = point + DIR_VECTORS[direction]
        
        --Add point if it's valid
        if Board:IsValid(point) then
            points[index] = point
        end
        
        --Stop adding points if current space blocks lasers or is the the edge of the board
        if Board:IsBuilding(point) or Board:GetTerrain(point) == TERRAIN_MOUNTAIN or not Board:IsValid(point) then
            break
        else
            index = index + 1
        end
    end

    return points
end
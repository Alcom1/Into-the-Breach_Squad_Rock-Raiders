--If point's terrain is water/lava
function RR_IsSink(point)
    local terrain = Board:GetTerrain(point)
	return	RR_IsSink_T(terrain)
end

--If terrain is water/lava
function RR_IsSink_T(terrain)
	return	terrain == TERRAIN_WATER or terrain == TERRAIN_LAVA or terrain == TERRAIN_HOLE
end

--If point's terrain is mountain
function RR_IsMountain(point)
	return	Board:GetTerrain(point) == TERRAIN_MOUNTAIN
end

--If point's terrain has rock on it which will be destroyed by the given damage
function RR_HasDeadRock(point, damage)
	if Board:IsDeadly(damage, Pawn) then
		return RR_HasRock(point)
	else
		return false
	end
end

--If point's terrain has rock on it
function RR_HasRock(point)
	local pawn = Board:GetPawn(point)
	if pawn ~= nil then
		return string.match(pawn:GetType(), "Wall")
	else
		return false
	end
end
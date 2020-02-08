--If terrain is water/lava
function RR_IsSink(point)
    local terrain = Board:GetTerrain(point)
	return	terrain == TERRAIN_WATER or terrain == TERRAIN_LAVA or terrain == TERRAIN_HOLE
end

--If terrain is mountain
function RR_IsMountain(point)
	return	Board:GetTerrain(point) == TERRAIN_MOUNTAIN
end
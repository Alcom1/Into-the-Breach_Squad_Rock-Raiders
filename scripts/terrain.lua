--If terrain is water/lava
function RR_IsLiquid(point)
    local terrain = Board:GetTerrain(point)
	return	terrain == TERRAIN_WATER or terrain == TERRAIN_LAVA
end

--If terrain is mountain
function RR_IsMountain(point)
	return	Board:GetTerrain(point) == TERRAIN_MOUNTAIN
end
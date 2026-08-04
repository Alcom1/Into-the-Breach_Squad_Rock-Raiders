local RR_CRYSTAL_TARGET = 12

local mod = modApi:getCurrentMod()
local modApiExt = modapiext

--If this is a real mission, and not a fake mission, because it's not a test mission or whatever
local function isRealMission()
    local mission = GetCurrentMission()

    return true
		and mission ~= nil
		and mission ~= Mission_Test
		and Board
		and Board:IsMissionBoard()
end

--Count crystals on board
local function getCrystalCount()
	
	local crystalCount = 0

	--Count crystals on board
	local board_size = Board:GetSize()
	for i = 1, board_size.x - 1 do
		for j = 1, board_size.y - 1  do
			local loc = Point(i,j)
			if Board:GetItem(loc) == "Item_RR_Crystal_Mine" then
				crystalCount = crystalCount + 1
			end
		end
	end

	return crystalCount
end

--If pawn is valid for achievement 2
local function RR_IsValidForBlock(pawn)
	local pawnType = _G[pawn:GetType()]

	return 
		pawn:GetTeam() == TEAM_ENEMY
		and not pawnType:GetMinor() 
		and pawnType:GetLeader() == LEADER_NONE 
		and pawnType:GetDefaultFaction() ~= FACTION_BOTS
		and not pawn:IsFlying()
		and not pawn:IsJumper()
		and not pawn:IsBurrower()
end

--Achievement 1
local ach_rr_crystal = modApi.achievements:addExt{
	--Required
	id = "rr_ach1",
	name = "Earth's Bounty",
	image = mod.resourcePath.."img/achievements/ach_1.png",

	--Optional
	tooltip = "End a battle with at least "..RR_CRYSTAL_TARGET.." crystals present.",
	squad = "rr_rockraiders",

	--Extension
	textDiffComplete = "$highscore crystals mined",
}

function ach_rr_crystal:getTextProgress()
	if isRealMission() then
		return getCrystalCount().." crystals mined"
	end
end

--Achievement 2
local ach_rr_block = modApi.achievements:addExt{
	--Required
	id = "rr_ach2",
	name = "Difficult Terrain",
	image = mod.resourcePath.."img/achievements/ach_2.png",

	--Optional
	tooltip = "Surround a vek and stop it from moving with rock, mountain, or water tiles.",
	squad = "rr_rockraiders",
}

--Achievement 3
local ach_rr_fence = modApi.achievements:addExt{
	--Required
	id = "rr_ach3",
	name = "Complete Circuit",
	image = mod.resourcePath.."img/achievements/ach_3.png",

	--Optional
	tooltip = "Attack an electric fence with another electric fence.",
	squad = "rr_rockraiders",
}

-- Hooks!!!
--Achievement 1 hook
local function HOOK_onMissionEnded(mission)

	--Skip for test missions
	if not isRealMission() then
		return
	end
	
	local crystalCount = getCrystalCount()
	
	--If crystals equal or exceed requirement, unlock achievement
	if crystalCount >= RR_CRYSTAL_TARGET then
		ach_rr_crystal:completeWithHighscore(crystalCount)
	end

end

--Achievement 2 hook
local function HOOK_onNextTurnHook()

	--Skip for test missions
	if not isRealMission() then
		return
	end

	--At the start of player's turn
	if Game:GetTeamTurn() == TEAM_PLAYER then

		--For all pawns
		for _, pawnId in ipairs(extract_table(Board:GetPawns(TEAM_ENEMY))) do

			local pawn = Board:GetPawn(pawnId)

			--Pawn is valid, check if it's surrounded
			if RR_IsValidForBlock(pawn) then

				local isBlocked = true

				--Check adjacent squares, if each one blocks the vek
				for dir = DIR_START, DIR_END do                         --Loop through adjacent tiles
					local point = pawn:GetSpace() + DIR_VECTORS[dir]    --Adjacent tile Point

					if not Board:IsValid(point) then
						--LOG("VM - TILE OUTSIDE MAP")
					elseif RR_IsSink(point) then
						--LOG("VM - SINK TILE")
					elseif RR_IsMountain(point) then
						--LOG("VM - MOUNTAIN TILE")
					elseif RR_HasRock(point) then
						--LOG("VM - ROCK TILE") 
					else
						isBlocked = false
						break
					end
				end
				
				if isBlocked then
					ach_rr_block:addProgress{ complete = true }
					break
				end
			end
		end
	end
end

--Achievement 3... is not based on a hook. It's triggered from a weapon.
function RR_CheckAch3Trigger()

	--Skip for test missions
	if not isRealMission() then
		return
	end

	ach_rr_fence:addProgress{ complete = true }
end

modApi.events.onModsLoaded:subscribe(
	function()
		modApi:addMissionEndHook(HOOK_onMissionEnded)
		modApi:addNextTurnHook(HOOK_onNextTurnHook)
	end)
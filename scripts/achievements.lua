local RR_CRYSTAL_TARGET = 7
local RR_BURP_TARGET = 4

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
	for i = 0, board_size.x - 1 do
		for j = 1, board_size.y - 1  do
			local loc = Point(i,j)
			if Board:GetItem(loc) == "Item_RR_Crystal_Mine" then
				crystalCount = crystalCount + 1
			end
		end
	end

	return crystalCount
end

--Achievement 1
local ach_rr_crystal = modApi.achievements:addExt{
	--Required
	id = "rr_ach1",
	name = "Jet's Lucky Number",
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
	name = "B.U.R.P!",
	image = mod.resourcePath.."img/achievements/ach_2.png",

	--Optional
	tooltip = "Place 4 rocks in an adjacent row or column. (No diagonals.)",
	squad = "rr_rockraiders",
}

--Achievement 3
local ach_rr_fence = modApi.achievements:addExt{
	--Required
	id = "rr_ach3",
	name = "Circuit Breaker",
	image = mod.resourcePath.."img/achievements/ach_3.png",

	--Optional
	tooltip = "Attack an electric fence with another electric fence.",
	squad = "rr_rockraiders",
}

-- Hooks!!!
--Achievement 1 hook - Check if mission ends with required crystals
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

--Achievement 2 hook - Check if a summoned rock creates 4-in-a-row
local function HOOK_onPawnTracked(mission, pawn1)

	--Skip for test missions
	if not isRealMission() then
		return
	end

	--If pawn is a rock, check for 4-in-a-row
	if pawn1 ~= nil and string.match(pawn1:GetType(), "Wall") then

		local rockPoints = {}	--Will contain hashed points with rocks
		
		--For all TEAM_NONE pawns, if it's a wall, store its point-hash
		for _, id in ipairs(extract_table(Board:GetPawns(TEAM_NONE))) do
			local pawn2 = Board:GetPawn(id)

			if string.match(pawn2:GetType(), "Wall") then
				local space = pawn2:GetSpace()
				rockPoints[space:RR_Hash()] = 1
			end
		end

		--Point of new rock for reference, and the size of the board
		local point = pawn1:GetSpace()
		local board_size = Board:GetSize()

		--Count of current row/column, and the maximum adjacent count
		local curr = 0
		local max = 0

		--Check horizontal
		for i = 0, board_size.x - 1 do

			local check = Point(i, point.y)

			if rockPoints[check:RR_Hash()] ~= nil then
				curr = curr + 1
				max = math.max(max, curr)
			else
				curr = 0
			end

		end

		--Reset check
		curr = 0

		--Check vertical
		for i = 0, board_size.y - 1 do

			local check = Point(point.x, i)

			if rockPoints[check:RR_Hash()] ~= nil then
				curr = curr + 1
				max = math.max(max, curr)
			else
				curr = 0
			end
		end

		--If max is greater or equal to target, then there are 4? rocks in a row. Achievement complete!!!
		if max >= RR_BURP_TARGET then
			ach_rr_block:addProgress{ complete = true }
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

--Add hooks
modApi.events.onModsLoaded:subscribe(
	function()
		modApi:addMissionEndHook(HOOK_onMissionEnded)
		modApiExt:addPawnTrackedHook(HOOK_onPawnTracked)
	end)
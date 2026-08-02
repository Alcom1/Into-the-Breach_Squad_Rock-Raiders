local RR_CRYSTAL_TARGET = 12

local mod = modApi:getCurrentMod()
local modApiExt = modapiext

local ach_rr_crystal = modApi.achievements:add{
	id = "rr_ach1",
	name = "Earth's Bounty",
	tooltip = "End a battle with at least "..RR_CRYSTAL_TARGET.." crystals present.",
	image = mod.resourcePath.."img/achievements/ach_1.png",
	squad = "rr_rockraiders",
}

local ach_rr_block = modApi.achievements:add{
	id = "rr_ach2",
	name = "Difficult Terrain",
	tooltip = "Surround a vek and stop it from moving with rock, mountain, or water tiles.",
	image = mod.resourcePath.."img/achievements/ach_2.png",
	squad = "rr_rockraiders",
}

local ach_rr_fence = modApi.achievements:add{
	id = "rr_ach3",
	name = "Complete Circuit",
	tooltip = "Attack an electric fence with another electric fence.",
	image = mod.resourcePath.."img/achievements/ach_3.png",
	squad = "rr_rockraiders",
}

-- Hooks!!!
--Achievement 1 hook
local function HOOK_onMissionEnded(mission)
	
	--Count crystals
	
end

--Achievement 2 hook
local function HOOK_onvekMoveStart(mission)
	
	--Check if surrounded
	
end

--Achievement 3... is not based on a hook. It's triggered from a weapon.
function RR_CheckAch3Trigger()

	--Check if valid mission

end

modApi.events.onModsLoaded:subscribe(
	function()
		modApi:addMissionEndHook(HOOK_onMissionEnded)
		modApiExt:addVekMoveStartHook(HOOK_onvekMoveStart)
	end)
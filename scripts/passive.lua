--Fossilizer Passive by Lemonymous, edited by Alcom Isst
local this = {}
local trackedKills = {}
local trackedRaids = {}
local trackedSummons = {}

--The game should not save while the board is busy, so using a local table should be fine.
--However, we should probably reset it when the data don't make sense anymore.

----------------------------------------------------------------
--Reset functions
----------------------------------------------------------------
--Reset tracked pawns
local function RR_ResetTrackedPawns()
    trackedKills = {}
end

--Reset tracked pmineawns
local function RR_ResetTrackedRaids()
    trackedRaids = {}
end

--Reset tracked summons
local function RR_ResetTrackedSummons()
    trackedSummons = {}
end

--Reset everything
local function RR_ResetAll()
    RR_ResetTrackedPawns()
    RR_ResetTrackedRaids()
    RR_ResetTrackedSummons()
end

----------------------------------------------------------------
--Tracking functions
----------------------------------------------------------------
--Track a pawn
local function RR_TrackKill(pawn)
    trackedKills[pawn:GetId()] = pawn:GetSpace()    --Track this space
end

--Track a pawn
local function RR_TrackRaid(pawn)
    trackedRaids[pawn:GetId()] = pawn:GetSpace()    --Track this space
end

--Track a summon
local function RR_TrackSummon(pawn)
    trackedSummons[pawn:GetSpace():Hash()] = 1      --Track this hashed space
end

----------------------------------------------------------------
--Validation functions
----------------------------------------------------------------

--If Rock passive is active
local function RR_IsValidSummon()
    return IsPassiveSkill("lmn_Passive_RockOnDeath")
end

--If Rock passive is active, the pawn is an enemy, and the pawn is not on top of a summoning unit
local function RR_IsValidForRock(pawn)
    return IsPassiveSkill("lmn_Passive_RockOnDeath") and pawn:GetTeam() == TEAM_ENEMY and not trackedSummons[pawn:GetSpace():Hash()]
end

--If Rock passive is active, the pawn is a rock, and the pawn is not on top of a summoning unit
local function RR_IsValidForCrystal(pawn)
    return IsPassiveSkill("lmn_Passive_RockOnDeath") and string.match(pawn:GetType(), "Wall") and not trackedSummons[pawn:GetSpace():Hash()]
end

----------------------------------------------------------------
--Action functions
----------------------------------------------------------------

--Spawn a rock!
local function RR_CheckSpawnRock()
    local pawnId, loc = next(trackedKills)          --Get the first tracked pawn

    if pawnId then                                  --If the tracked pawn exists
        local fx = SkillEffect()                    --Create effect
        local d = SpaceDamage(loc)                  --Create damage
        d.sPawn = "Wall"                            --Damage spawns a rock
        d.sSound = "/enemy/digger_1/attack_queued"  --Damage sfx
        fx:AddDamage(d)                             --Add damage to effect
        
        Board:AddEffect(fx)                         --Add effect to board
        
        trackedKills[pawnId] = nil                  --We're done with this pawn, untrack it
    end
end

--Spawn a rock!
local function RR_CheckSpawnCrystal()
    local pawnId, loc = next(trackedRaids)          --Get the first tracked raid (mined rock)

    if pawnId then                                  --If the rock exists
        local fx = SkillEffect()                    --Create effect
        local d = SpaceDamage(loc)                  --Create damage
        d.sScript = "Board:ClearSpace("..loc:GetString()..")"
        d.sItem = "Item_RR_Crystal_Mine"
        --d.sAnimation = "rock1d"
        --d.sSound = "/support/rock/death"
        --d.sImageMark = "combat/crystal_0.png"
        fx:AddDamage(d)                             --Add damage to effect
        
        Board:AddEffect(fx)                         --Add effect to board
        
        trackedRaids[pawnId] = nil                  --We're done with this pawn, untrack it
    end
end

--Track rock spawning pawns to their new locations
local function RR_TrackPawns()
    for pawnId, loc in pairs(trackedKills) do       --For every tracked pawn
        local pawn = Board:GetPawn(pawnId)          --Track the pawn's position
        
        if pawn then                                --if pawn still exists
            trackedKills[pawnId] = pawn:GetSpace()  --update its tracked location.
        end
    end
end

----------------------------------------------------------------
--Init
----------------------------------------------------------------
function this:init()
    sdlext.addGameExitedHook(RR_ResetAll)
end

----------------------------------------------------------------
--Load
----------------------------------------------------------------
function this:load(modUtils)
    modApi:addPreLoadGameHook(RR_ResetAll)
    
    --On update, update the tracked pawn locations or both spawn a rock and clear tracked summons
    modApi:addMissionUpdateHook(function()
        if Board:GetBusyState() == 0 then   --Wait for the board to unbusy
            RR_CheckSpawnRock()             --Check for availability and spawn a rock
            RR_CheckSpawnCrystal()          --Check for availability and spawn a crystal
            RR_ResetTrackedSummons()        --Clear the tracked summon locations, we don't need them anymore.
        else                                --If the board is not busy 
            RR_TrackPawns()                 --Update the tracked positions for spawned
        end
    end)
    
    --When a pawn dies
    modUtils:addPawnKilledHook(function(mission, pawn)
        --Validate it and add it to the list of tracked pawns
        if RR_IsValidForRock(pawn) then
            RR_TrackKill(pawn)
        end

        if RR_IsValidForCrystal(pawn) then
            RR_TrackRaid(pawn)
        end
    end)
    
    --When a pawn summons
    modUtils:addPawnTrackedHook(function(mission, pawn)
        --if we are tracking summons, add it to the list of tracked summons.
        if RR_IsValidSummon() then
            RR_TrackSummon(pawn)
        end
    end)
end

return this

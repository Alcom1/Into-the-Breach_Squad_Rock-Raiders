--Fossilizer Passive by Lemonymous, edited by Alcom Isst
local this = {}
local trackedPawns = {}
local trackedSummons = {}
local trackedDynamite = {}

--The game should not save while the board is busy, so using a local table should be fine.
--However, we should probably reset it when the data don't make sense anymore.

----------------------------------------------------------------
--Reset functions
----------------------------------------------------------------
--Reset tracked pawns
local function RR_ResetTrackedPawns()
    trackedPawns = {}
end

--Reset tracked summons
local function RR_ResetTrackedSummons()
    trackedSummons = {}
end

--Reset tracked dynamite(
local function RR_ResetTrackedDynamite()
    trackedDynamite = {}
end

--Reset everything
local function RR_ResetAll()
    RR_ResetTrackedPawns()
    RR_ResetTrackedSummons()
end

----------------------------------------------------------------
--Tracking functions
----------------------------------------------------------------
--Track a pawn
local function RR_TrackPawn(pawn)
    trackedPawns[pawn:GetId()] = pawn:GetSpace()    --Track this space
end

--Track a summon
local function RR_TrackSummon(pawn)
    trackedSummons[pawn:GetSpace():Hash()] = 1      --Track this hashed space
end

--Track dynamite
local function RR_TrackDynamite(pawn)
    trackedDynamite[pawn:GetId()] = pawn:GetSpace() --Track this space
end

----------------------------------------------------------------
--Validation functions
----------------------------------------------------------------
--If a pawn is dynamite
local function RR_IsValidDynamite(pawn)
    return string.match(pawn:GetType(), "Pawn_RR_Spawn_Dynamite")
end

--If Rock passive is active
local function RR_IsValidSummon()
    return IsPassiveSkill("lmn_Passive_RockOnDeath")
end

--If Rock passive is active, the pawn is an enemy, and the pawn is not on top of a summoning unit
local function RR_IsValidForRock(pawn)
    return IsPassiveSkill("lmn_Passive_RockOnDeath") and pawn:GetTeam() == TEAM_ENEMY and not trackedSummons[pawn:GetSpace():Hash()]
end

----------------------------------------------------------------
--Action functions
----------------------------------------------------------------
--Detonate Dynamite!
local function RR_DetonateDynamite(pawn)
    pawn:FireWeapon(pawn:GetSpace(), 1)             --Blow it up!
end

--Detonate tracked dynamite!
local function RR_DetonateTrackedDynamite()
    local pawnId, loc = next(trackedDynamite)       --Get the first tracked pawn

    if pawnId then
        RR_DetonateDynamite(Board:GetPawn(pawnId))
        trackedDynamite[pawnId] = nil               --We're done with this pawn, untrack it
    end
end

--Spawn a rock!
local function RR_SpawnRock()
    local pawnId, loc = next(trackedPawns)          --Get the first tracked pawn

    if pawnId then                                  --If the tracked pawn exists
        local fx = SkillEffect()                    --Create effect
        local d = SpaceDamage(loc)                  --Create damage
        d.sPawn = "Wall"                            --Damage spawns a rock
        d.sSound = "/enemy/digger_1/attack_queued"  --Damage sfx
        fx:AddDamage(d)                             --Add damage to effect
        
        Board:AddEffect(fx)                         --Add effect to board
        
        trackedPawns[pawnId] = nil                  --We're done with this pawn, untrack it
    end
end

--Track rock spawning pawns to their new locations
local function RR_TrackRock()
    for pawnId, loc in pairs(trackedPawns) do       --For every tracked pawn
        local pawn = Board:GetPawn(pawnId)          --Track the pawn's position
        
        if pawn then                                --if pawn still exists
            trackedPawns[pawnId] = pawn:GetSpace()  --update its tracked location.
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
    
    --After Environment effects, trigger all dynamite
    modApi:addNextTurnHook(function()
        if Game:GetTeamTurn() == TEAM_ENEMY then
            local dynamiteTestPawns = extract_table(Board:GetPawns(TEAM_PLAYER))
            for i, id in ipairs(dynamiteTestPawns) do   --For each pawn id
                local pawn = Board:GetPawn(id)          --Get pawn from pawn id
                if RR_IsValidDynamite(pawn) then        --If the pawn is dynamite
                    RR_DetonateDynamite(pawn)           --Blow it up! (Instantly so we don't wait for the busy state)
                end
            end
        end
    end)
    
    --On update, update the tracked pawn locations or both spawn a rock and clear tracked summons
    modApi:addMissionUpdateHook(function()
        if Board:GetBusyState() == 0 then   --Wait for the board to unbusy
            RR_SpawnRock()                  --Spawn a rock
            RR_DetonateTrackedDynamite()    --Detonate tracked dynamite
            RR_ResetTrackedSummons()        --Clear the tracked summon locations, we don't need them anymore.
        else                                --If the board is not busy 
            RR_TrackRock()                  --Update the tracked positions for spawned
        end
    end)
    
    --When a pawn dies
    modUtils:addPawnKilledHook(function(mission, pawn)
        --Validate it and add it to the list of tracked pawns
        if RR_IsValidForRock(pawn) then
            RR_TrackPawn(pawn)
        end
    end)

    --When a grid space catches fire
    modUtils:addPawnIsFireHook(function(mission, pawn)
        --If the pawn there is dynamite
        if RR_IsValidDynamite(pawn) then    
            RR_TrackDynamite(pawn)          --Blow it up!
        end
    end)
    
    --When a pawn summons
    modUtils:addPawnTrackedHook(function(mission, pawn)
        --if we are tracking summons, add it to the list of tracked summons.
        if RR_IsValidSummon() then
            RR_TrackSummon(pawn)
        end

        --if this space is on fire and the pawn added there is dynamite
        if Board:IsFire(pawn:GetSpace()) and RR_IsValidDynamite(pawn) then
            RR_TrackDynamite(pawn)          --Blow it up!
        end
    end)
end

return this

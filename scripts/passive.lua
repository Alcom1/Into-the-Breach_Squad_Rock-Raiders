--Fossilizer Passive by Lemonymous, edited by Alcom Isst
local this = {}
local trackedPawns = {}
local trackedSummons = {}

--The game should not save while the board is busy, so using a local table should be fine.
--However, we should probably reset it when the data don't make sense anymore.

--Reset tracked pawns
local function RR_ResetTrackedPawns()
    trackedPawns = {}
end

--Reset tracked summons
local function RR_ResetTrackedSummons()
    trackedSummons = {}
end

--If a pawn is dynamite
local function RR_IsDynamite(pawn)
    return string.match(pawn:GetType(), "Pawn_RR_Spawn_Dynamite")
end

--Do a dynamite check and detonate it if true
local function RR_DetonateDynamite(pawn)
    if RR_IsDynamite(pawn) then                 --If the pawn is dynamite
        pawn:FireWeapon(pawn:GetSpace(), 1)     --Blow it up!
    end
end

--If Rock passive is active, the pawn is an enemy, and the pawn is not on top of a summoning unit
local function RR_IsValidForRock(pawn)
    return IsPassiveSkill("lmn_Passive_RockOnDeath") and pawn:GetTeam() == TEAM_ENEMY and not trackedSummons[pawn:GetSpace():Hash()]
end

--If Rock passive is active
local function RR_CanTrackSummons()
    return IsPassiveSkill("lmn_Passive_RockOnDeath")
end

--Init
function this:init()
    sdlext.addGameExitedHook(RR_ResetTrackedPawns)
end

--Load
function this:load(modUtils)
    modApi:addPreLoadGameHook(RR_ResetTrackedPawns)
    
    --After Environment effects, trigger all dynamite
    modApi:addNextTurnHook(function()
        if Game:GetTeamTurn() == TEAM_ENEMY then
            dynamiteTestPawns = extract_table(Board:GetPawns(TEAM_PLAYER))
            for i, id in ipairs(dynamiteTestPawns) do       --For each pawn
                RR_DetonateDynamite(Board:GetPawn(id))
            end
        end
    end)
    
    --On update, update the tracked pawn locations or both spawn a rock and clear tracked summons
    modApi:addMissionUpdateHook(function()
        
        --If board is not busy, spawn a rock for a tracked pawn
        if Board:GetBusyState() == 0 then                   --Wait for the board to unbusy
            
            local pawnid, loc = next(trackedPawns)          --Get the first tracked pawn
            
            if pawnid then                                  --If the tracked pawn exists
                local fx = SkillEffect()                    --Create effect
                local d = SpaceDamage(loc)                  --Create damage
                d.sPawn = "Wall"                            --Damage spawns a rock
                d.sSound = "/enemy/digger_1/attack_queued"  --Damage sfx
                fx:AddDamage(d)                             --Add damage to effect
                
                Board:AddEffect(fx)                         --Add effect to board
                
                trackedPawns[pawnid] = nil                  --We're done with this pawn, untrack it
            end

            RR_ResetTrackedSummons()                        --Clear the tracked summon locations, we don't need them anymore.
        else                                                --else update the tracked pawn positions
            for pawnid, loc in pairs(trackedPawns) do       --For every tracked pawn
                local pawn = Board:GetPawn(pawnid)          --Track the pawn's position
                
                if pawn then                                --if pawn still exists
                    trackedPawns[pawnid] = pawn:GetSpace()  --update its tracked location.
                end
            end
        end
    end)

    modUtils:addPawnIsFireHook(function(mission, pawn)
        RR_DetonateDynamite(pawn)
    end)
    
    --When a pawn dies, validate it and add it to the list of tracked pawns
    modUtils:addPawnKilledHook(function(mission, pawn)
        if RR_IsValidForRock(pawn) then
            trackedPawns[pawn:GetId()] = pawn:GetSpace()    --Track this space
        end
    end)
    
    --When a pawn summons
    modUtils:addPawnTrackedHook(function(mission, pawn)
        local space = pawn:GetSpace()

        --if we are tracking summons, add it to the list of tracked summons.
        if RR_CanTrackSummons() then
            trackedSummons[space:Hash()] = 1      --Track this hashed space
        end

        --if this space is on fire, do dynamite detonation
        if Board:IsFire(space) then
            RR_DetonateDynamite(pawn)
        end
    end)
end

return this

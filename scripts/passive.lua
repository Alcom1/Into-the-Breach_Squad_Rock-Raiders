--Fossilizer Passive by Lemonymous, edited by Alcom Isst
local this = {}
local selectedPawnId = nil
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

--If Rock passive is active, the pawn is an enemy, and the pawn is not on top of a summoning unit
local function RR_IsValidForRock(pawn)
    return IsPassiveSkill("lmn_Passive_RockOnDeath") and pawn:GetTeam() == TEAM_ENEMY and not trackedSummons[pawn:GetSpace():Hash()]
end

--If Rock passive is active
local function RR_CanTrackSummons()
    return IsPassiveSkill("lmn_Passive_RockOnDeath")
end

--Init
function this:init(mod)
    sdlext.addGameExitedHook(RR_ResetTrackedPawns)
end

--Load
function this:load(modUtils)
    modApi:addPreLoadGameHook(RR_ResetTrackedPawns)
    
    --After Environment effects, trigger all dynamite
    modApi:addPostEnvironmentHook(function(mission)
        dynamiteTestPawns = extract_table(Board:GetPawns(TEAM_ANY))
        for i, id in ipairs(dynamiteTestPawns) do       --For each pawn
            local pawn = Board:GetPawn(id)
            if RR_IsDynamite(pawn) then                 --If the pawn is dynamite
                pawn:FireWeapon(pawn:GetSpace(), 1)     --Blow it up!
            end
        end
    end)
    
    --On update, update the tracked pawn locations or both spawn a rock and clear tracked summons
    modApi:addMissionUpdateHook(function(mission)

        --Draw dynamite icons
        dynamiteTestPawns = extract_table(Board:GetPawns(TEAM_ANY))
        for i, id in ipairs(dynamiteTestPawns) do                               --For each pawn
            local pawn = Board:GetPawn(id)
            if RR_IsDynamite(pawn) and id ~= selectedPawnId then                --If the pawn is dynamite and is not selected
                Board:AddAnimation(pawn:GetSpace(), 'RR_Skull', ANIM_NO_DELAY)  --Draw dynamite icon
            end
        end

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

    --Store selected pawn ID
    modUtils:addPawnSelectedHook(function(mission, pawn) 
        selectedPawnId = pawn:GetId()
    end)

    --Unstore unselected pawn ID
    modUtils:addPawnDeselectedHook(function() 
        selectedPawnId = nil 
    end)
    
    --When a pawn dies, validate it and add it to the list of tracked pawns
    modUtils:addPawnKilledHook(function(mission, pawn)
        if RR_IsValidForRock(pawn) then
            trackedPawns[pawn:GetId()] = pawn:GetSpace()    --Track this space
        end
    end)
    
    --When a pawn summons, if we are tracking summons, add it to the list of tracked summons.
    modUtils:addPawnTrackedHook(function(mission, pawn)
        if RR_CanTrackSummons() then
            trackedSummons[pawn:GetSpace():Hash()] = 1      --Track this hashed space
        end
    end)
end

return this

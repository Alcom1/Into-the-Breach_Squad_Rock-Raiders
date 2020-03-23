--Fossilizer Passive by Lemonymous, edited by Alcom Isst
local this = {}
local trackedPawns = {}
local trackedSummons = {}

--The game should not save while the board is busy, so using a local table should be fine.
--However, we should probably reset it when the data don't make sense anymore.
local function resetTrackedPawns()
    trackedPawns = {}
end

sdlext.addGameExitedHook(resetTrackedPawns)

function this:load(modUtils)
    modApi:addPreLoadGameHook(resetTrackedPawns)
    
    --On update, update the tracked pawn locations or both spawn a rock and clear tracked summons
    modApi:addMissionUpdateHook(function(mission)
        
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

            trackedSummons = {}                             --Clear the tracked summon locations, we don't need them anymore.

        --else update the tracked pawn positions
        else
            for pawnid, loc in pairs(trackedPawns) do       --For every tracked pawn
                local pawn = Board:GetPawn(pawnid)          --Track the pawn's position
                
                if pawn then                                --if pawn still exists
                    trackedPawns[pawnid] = pawn:GetSpace()  --update its tracked location.
                end
            end
        end
    end)
    
    --When a pawn dies, validate it and add it to the list of tracked pawns that will spawn rocks
    modUtils:addPawnKilledHook(function(mission, pawn)
        if IsPassiveSkill("lmn_Passive_RockOnDeath") then
            local space = pawn:GetSpace()                   --Pawn location
            
            --If the pawn is an enemy and doesn't already have a tracked summon, track it so a rock will summon there.
            if pawn:GetTeam() == TEAM_ENEMY and not trackedSummons[space:Hash()] then
                trackedPawns[pawn:GetId()] = space          --Track this space
            end
        end
    end)
    
    --When a pawn spawns, add it to the list of tracked summon locations so a rock does not spawn there.
    modUtils:addPawnTrackedHook(function(mission, pawn)
        if IsPassiveSkill("lmn_Passive_RockOnDeath") then
            trackedSummons[pawn:GetSpace():Hash()] = 1  --Hash the pawn space, add it to tracked summon locations
        end
    end)
end

return this

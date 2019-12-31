--Fossilizer Passive by Lemonymous
local this = {}
local trackedPawns = {}

local function IsValidPawn(pawn)
    return pawn:GetTeam() == TEAM_ENEMY
end

-- the game should not save while the board is busy, so using a local table should be fine.
-- however, we should probably reset it when the data don't make sense anymore.
local function resetTrackedPawns()
    trackedPawns = {}
end

sdlext.addGameExitedHook(resetTrackedPawns)

function this:load(modUtils)
    modApi:addPreLoadGameHook(resetTrackedPawns)
    
    modApi:addMissionUpdateHook(function(mission)
        
        if Board:GetBusyState() == 0 then
            -- wait for the board to unbusy,
            -- and create the first rock in our list,
            -- busying the board again until it has been created.
            
            local pawnid, loc = next(trackedPawns)
            
            if pawnid then
                local fx = SkillEffect()
                local d = SpaceDamage(loc)
                d.sPawn = "Wall"
                d.sSound = "/enemy/digger_1/attack_queued"
                fx:AddDamage(d)
                
                Board:AddEffect(fx)
                
                trackedPawns[pawnid] = nil
            end
        else
            for pawnid, loc in pairs(trackedPawns) do
                local pawn = Board:GetPawn(pawnid)
                
                if pawn then
                    -- is pawn still exists, update its tracked location.
                    trackedPawns[pawnid] = pawn:GetSpace()
                end
            end
        end
    end)
    
    modUtils:addPawnKilledHook(function(mission, pawn)
        if IsPassiveSkill("lmn_Passive_RockOnDeath") then
            if IsValidPawn(pawn) then
                local pawnid = pawn:GetId()
                
                -- track pawn and let addMissionUpdateHook handle the timing of rock creation.
                trackedPawns[pawnid] = pawn:GetSpace()
            end
        end
    end)
end

return this

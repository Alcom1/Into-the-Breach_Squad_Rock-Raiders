--Fossilizer Passive by Lemonymous, edited by Alcom Isst
local this = {}
local trackedKills = {}
local trackedRocks = {}
local trackedSummons = {}
local trackedDummies = {}

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
local function RR_ResetTrackedRocks()
    trackedRocks = {}
end

--Reset tracked summons
local function RR_ResetTrackedSummons()
    trackedSummons = {}
end

--Reset tracked summons
local function RR_ResetTrackedDummies()
    trackedDummies = {}
end

--Reset everything
local function RR_ResetAll()
    RR_ResetTrackedPawns()
    RR_ResetTrackedRocks()
    RR_ResetTrackedSummons()
    RR_ResetTrackedDummies()
end

----------------------------------------------------------------
--Tracking functions
----------------------------------------------------------------
--Status of if pawn is dynamite or fence
local function RR_IsSmall(pawn)

    if string.match(pawn:GetType(), "Pawn_RR_Spawn_Dynamite") then
        return 1
    elseif string.match(pawn:GetType(), "Pawn_RR_Spawn_Fence") then
        return 2
    end

    return 0
end

--If a pawn is dynamite
local function RR_IsSmallBlocking(pawn)
    return Board:IsSpawning(pawn:GetSpace()) and (RR_IsSmall(pawn) > 0)
end

--Checks if there is an active psider psion psomewhere.
local function RR_IsSpiders()

    for i, v in ipairs(extract_table(Board:GetPawns(TEAM_ENEMY))) do
        local pawn = Board:GetPawn(v)

        if pawn:GetLeader() == LEADER_SPIDER and not pawn:IsDead() then
            return true
        end
    end

    return false
end

--Track a pawn
local function RR_TrackKill(pawn)

    trackedKills[pawn:GetId()] = pawn:GetSpace()                --Track this space

    --Spider edgecase, skip default spider egg spawn and track for alternative spawn
    if RR_IsSpiders() and not (pawn:GetLeader() == LEADER_SPIDER) then
        pawn:SetMutation(0)
        trackedKills[-pawn:GetId()] = 1
    end
end

--Track a pawn
local function RR_TrackRock(pawn)
    trackedRocks[pawn:GetId()] = pawn:GetSpace()                --Track this space
end

--Track a summon
local function RR_TrackSummon(pawn)
    trackedSummons[pawn:GetSpace():Hash()] = 1                  --Track this hashed space
end

--Track a summon
local function RR_TrackDummy(pawn)
    trackedDummies[pawn:GetSpace():Hash()] = RR_IsSmall(pawn)   --Track this hashed space
end

----------------------------------------------------------------
--Validation functions
----------------------------------------------------------------
--Get tier of current passive
local function RR_CurrentPassiveTier()
    if IsPassiveSkill("lmn_Passive_RockOnDeath_2") then
        return 2
    elseif IsPassiveSkill("lmn_Passive_RockOnDeath") then
        return 1
    end

    return 0
end

--If Rock passive is active and the summon is not a rock
local function RR_IsValidSummon(pawn)
    return RR_CurrentPassiveTier() > 0 and not string.match(pawn:GetType(), "Wall")
end

--If Rock passive is active, the pawn is an enemy, and the pawn is not on top of a summoning unit
local function RR_IsValidForRock(pawn)
    return RR_CurrentPassiveTier() > 0 and pawn:GetTeam() == TEAM_ENEMY and not trackedSummons[pawn:GetSpace():Hash()]
end

--If Rock passive is active, the pawn is a rock, and the pawn is not on top of a summoning unit
local function RR_IsValidForCrystal(pawn)
    return RR_CurrentPassiveTier() > 1 and string.match(pawn:GetType(), "Wall") and not trackedSummons[pawn:GetSpace():Hash()]
end

----------------------------------------------------------------
--Action functions
----------------------------------------------------------------
--Spawn a rock!
local function RR_CheckSpawnRock()
    local pawnId, loc = next(                       --Get the first tracked pawn
        filter_table(trackedKills, function (k,v) return k >= 0 end))

    if pawnId then                                  --If the tracked pawn exists
        local fx = SkillEffect()                    --Create effect
        local d = SpaceDamage(loc)                  --Create damage
        d.sPawn = "Wall"                            --Damage spawns a rock
        d.sSound = "/enemy/digger_1/attack_queued"  --Damage sfx
        fx:AddDamage(d)                             --Add damage to effect

        --Spider edgecase, summon a spider egg to a random adjacent or adjacent-diagonal tile
        if RR_IsSpiders() and trackedKills[-pawnId] then
            local spiderPoints = loc:RR_RingTarget(1)
            shuffle_list(spiderPoints)

            for i, point in ipairs(spiderPoints) do
                if not Board:IsBlocked(point, PATH_GROUND) then
                    local spiderDamage = SpaceDamage(point)
                    spiderDamage.sPawn = "SpiderlingEgg1"
                    fx:AddArtillery(loc, spiderDamage, "effects/shotup_spider.png", NO_DELAY)
                    Board:SetDangerous(point)       --Prevent vek from stepping on this spider
                    break
                end
            end
        end
        
        Board:AddEffect(fx)                         --Add effect to board

        Board:SetDangerous(loc)                     --Prevent vek from stepping on this rock if it spawned during emergence
        
        trackedKills[pawnId] = nil                  --We're done with this pawn, untrack it
        trackedKills[-pawnId] = nil
    end
end

--Spawn a rock!
local function RR_CheckSpawnCrystal()

    local fx = SkillEffect()    --Create effect
    local isSpawn = false       --If there is a crystal spawning

    --Put all crystal spawns in one fx for timing improvements
    while true do
        local pawnId, loc = next(trackedRocks)      --Get the first tracked raid (mined rock)

        if pawnId then                              --If the rock exists

            if not RR_IsSink(loc) then              --Do not spawn crystal on non-solid tiles

                local pawn = Board:GetPawn(pawnId)  --Delete current pawn away so it doesn't eat the crystal
                if pawn then                        
                    Board:RemovePawn(pawn)
                end

                if not isSpawn then                 --Play sound once if a crystal is spawning
                    fx:AddSound("/ui/battle/buff_boost")
                end

                local d = SpaceDamage(loc)          --Create damage
                d.sItem = "Item_RR_Crystal_Mine"    --Spawn a crystal!
                fx:AddDamage(d)                     --Add damage to effect
                fx:AddBurst(                        --Crystal spawn particles!
                    loc,
                    "Emitter_Crystal_Purp",
                    DIR_NONE)

                isSpawn = true                      --Confirm crystals are spawning

                Board:SetDangerous(loc)             --Prevent vek from stepping on this crystal
            end
            
            trackedRocks[pawnId] = nil              --We're done with this pawn, untrack it
        else
            break
        end
    end
            
    if isSpawn then
        Board:AddEffect(fx)                         --Add effect to board if there are any crystals to spawn
    end
end

--Track rock spawning pawns to their new locations
local function RR_TrackPawns()
    for pawnId, loc in pairs(trackedKills) do           --For every tracked pawn
        local pawn = Board:GetPawn(pawnId)              --Track the pawn's position

        if pawn then                                    --if pawn still exists
            trackedKills[pawnId] = pawn:GetSpace()      --update its tracked location.
        end
    end

    for pawnId, loc in pairs(trackedRocks) do           --For every tracked pawn
        local pawn = Board:GetPawn(pawnId)              --Track the pawn's position
        
        if pawn and Board:IsValid(pawn:GetSpace()) then --if pawn still exists
            trackedRocks[pawnId] = pawn:GetSpace()      --update its tracked location.
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

    --Next turn, mark crystals as dangerous and substitute lightweight pawns which are blocking
    modApi:addNextTurnHook(function()

        --Check for crystals and mark them as dangerous
        local board_size = Board:GetSize()
        for i = 2, board_size.x - 1 do
            for j = 2, board_size.y - 1  do
                local loc = Point(i,j)
                if Board:GetItem(loc) == "Item_RR_Crystal_Mine" then
                    Board:SetDangerous(loc)
                end
            end
        end

        --Substitute lightweight blocking pawns for their equivalent dummy item so they can't block.
        if Game:GetTeamTurn() == TEAM_ENEMY then
            local dynamiteTestPawns = extract_table(Board:GetPawns(TEAM_PLAYER))

            for i, id in ipairs(dynamiteTestPawns) do   --For each pawn id

                local pawn = Board:GetPawn(id)          --Get pawn from pawn id

                if RR_IsSmallBlocking(pawn) then        --If the pawn is too small to block and is blocking

                    local pawnType = RR_IsSmall(pawn)
                    RR_TrackDummy(pawn)                 --Track the resulting dummy for later animations
                    Board:RemovePawn(pawn)              --Blow it up! (Instantly so we don't wait for the busy state)

                    --Substitute removed pawns with dummy items
                    if pawnType == 1 then
                        Board:SetItem(pawn:GetSpace(),"Item_RR_Dum_Dynamite")
                    end
                    if pawnType == 2 then
                        Board:SetItem(pawn:GetSpace(), "Item_RR_Dum_Fence")
                    end
                end
            end
        end
    end)
    
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
            RR_TrackRock(pawn)
        end
    end)
    
    --When a pawn summons
    modUtils:addPawnTrackedHook(function(mission, pawn)
        --if we are tracking summons, add it to the list of tracked summons.
        if RR_IsValidSummon(pawn) then
            RR_TrackSummon(pawn)
        end

        local dumCheck = trackedDummies[pawn:GetSpace():Hash()]

        if dumCheck and dumCheck > 0 then
            trackedDummies[pawn:GetSpace()] = nil

            local dum_damage = SpaceDamage(pawn:GetSpace())

            if dumCheck == 1 then
                dum_damage.sAnimation = "Dynamited"
            end
            if dumCheck == 2 then
                dum_damage.sAnimation = "Electric Fenced"
            end

            Board:DamageSpace(dum_damage)
        end
    end)
end

return this

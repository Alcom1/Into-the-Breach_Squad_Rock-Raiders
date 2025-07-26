local mod = modApi:getCurrentMod()
local path = mod.scriptPath
local boardEvents = require(path .."libraries/boardEvents")

local RR_mine_damage = SpaceDamage(0)
RR_mine_damage.sAnimation = ""
RR_mine_damage.iCrack = EFFECT_REMOVE

Item_RR_Crystal_Mine = { 
    Image = "combat/crystal_purp.png", 
    Damage = RR_mine_damage,
    Tooltip = "rr_crystal_mine",
    Icon = "combat/crystal_purp.png", 
    UsedImage = ""}

--I do not like this approach to making vek not step on crystals
local RR_OldScorePositioning = ScorePositioning
function ScorePositioning(point, pawn)
    local mission = GetCurrentMission()

    if Board:GetItem(point) == "Item_RR_Crystal_Mine" then return -100 end

    return RR_OldScorePositioning(point, pawn)
end

--If a mech consumes a crystal, give it boost
boardEvents.onItemRemoved:subscribe(
    function(loc, removed_item)
        if removed_item == "Item_RR_Crystal_Mine"  then
            local pawn = Board:GetPawn(loc)
            if pawn then
                local mine_damage = SpaceDamage(loc)

                if Board:GetPawn(loc):IsMech() then
                    mine_damage.sScript = "Board:GetPawn("..loc:GetString().."):SetBoosted(true)"
                else
                    mine_damage.sItem = "Item_RR_Crystal_Mine"
                end
                
                Board:DamageSpace(mine_damage)
            end
        end
    end)

--If a crystal sinks, destroy it
BoardEvents.onTerrainChanged:subscribe(
    function(p, terrain, terrain_prev)
        local item = Board:GetItem(p)
        if item == "Item_RR_Crystal_Mine" then
            if RR_IsSink_T(terrain) then
                Board:RemoveItem(p)
            end
        end
    end)
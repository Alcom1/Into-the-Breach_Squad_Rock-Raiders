local mod = modApi:getCurrentMod()
local path = mod.scriptPath
local boardEvents = require(path .."libraries/boardEvents")

Item_RR_Crystal_Mine = {
    Damage =    SpaceDamage(0),
	--images assigned by options
    Tooltip =   "rr_crystal_mine",
    UsedImage = ""}

Item_RR_Dum_Dynamite = {
    Damage =    SpaceDamage(0),
    Image =     "combat/rr_itemdum_dynamite.png", 
    Icon =      "combat/rr_itemdum_dynamite.png", 
    UsedImage = ""}

Item_RR_Dum_Fence = {
    Damage =    SpaceDamage(0),
    Image =     "combat/rr_itemdum_fence.png", 
    Icon =      "combat/rr_itemdum_fence.png", 
    UsedImage = ""}

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
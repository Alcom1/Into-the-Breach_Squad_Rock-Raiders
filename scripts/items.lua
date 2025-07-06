local mod = modApi:getCurrentMod()
local path = mod.scriptPath
local boardEvents = require(path .."libraries/boardEvents")

local mine_damage = SpaceDamage(0)
mine_damage.sAnimation = ""
mine_damage.iCrack = EFFECT_REMOVE

Item_RR_Crystal_Mine = { 
    Image = "combat/crystal.png", 
    Damage = mine_damage,
    Tooltip = "rr_crystal_mine",
    Icon = "combat/crystal.png", 
    UsedImage = ""}

boardEvents.onItemRemoved:subscribe(
    function(loc, removed_item)
        if removed_item == "Item_RR_Crystal_Mine"  then

            local pawn = Board:GetPawn(loc)

            if pawn then
                local mine_damage = SpaceDamage(loc)
                mine_damage.sScript = [[
                    if Board:GetPawn(]]..loc:GetString()..[[):IsMech() then 
                        Board:GetPawn(]]..loc:GetString()..[[):SetBoosted(true) 
                    end]]
                Board:DamageSpace(mine_damage)
            end
        end
    end)

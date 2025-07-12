Weap_RR_Base_Transporter = Skill:new{
    Deployed1 = "TBA",
    Deployed2 = "TBA",
    Range = 3,
    TwoClick = true,
    LaunchSound = "/weapons/swap"
}

function Weap_RR_Base_Transporter:GetTargetArea(p1)
    local ret = PointList()
    local points = general_DiamondTarget(p1, self.Range)    --Get a diamond centered around self

    for i = 0, points:size() do                             --For each point in the diamond
        local point = points:index(i)                       --The point
        if 
            not Board:IsBlocked(point, PATH_FLYER) and      --If the point is not blocked
            not RR_IsSink(point) then                       --and not liquid
            ret:push_back(point)                            --the point is valid, add it
        end
    end

    return ret
end

function Weap_RR_Base_Transporter:GetSecondTargetArea(p1, p2)
    local ret = PointList()
    local points = general_DiamondTarget(p1, self.Range)    --Get a diamond centered around self

    for i = 0, points:size() do                             --For each point in the diamond
        local point = points:index(i)                       --The point
        if 
            not Board:IsBlocked(point, PATH_FLYER) and      --If the point is not blocked
            not RR_IsSink(point) and 
            not (p2 == point) then  --and not liquid
            ret:push_back(point)                            --the point is valid, add it
        end
    end

    return ret
end

--Click check for teleporter
function Weap_RR_Base_Transporter:IsTwoClickException(p1, p2)
    --Boosting is required to spawn second 
    if Board:GetPawn(p1):IsBoosted() then
        return false
    end
	
	return true
end


local function RR_HiddenTeleport(effect, p)
	--Fail a teleport to an invalid point, creating an enter effect here, in a script so it's not in the preview.
	effect:AddScript([[
		local effect = SkillEffect()
        local from = Point(]].. p.x ..",".. p.y ..[[)
        effect:AddTeleport(from, Point(-1, -1), FULL_DELAY)
		Board:AddEffect(effect)
	]])
end

function Weap_RR_Base_Transporter:GetSkillEffect(p1, p2)
    local ret = SkillEffect()

	local damage = SpaceDamage(p2, 0)   --Damage
    damage.sPawn = self.Deployed1       --Damage spawn
	ret:AddDamage(damage)               --Add damage
    RR_HiddenTeleport(ret, p2)          --Teleport effect

    return ret
end

function Weap_RR_Base_Transporter:GetFinalEffect(p1, p2, p3)
    local ret = self:GetSkillEffect(p1, p2)

    ret:AddScript("Board:GetPawn("..p1:GetString().."):SetBoosted(false)")
    
	local damage = SpaceDamage(p3, 0)   --Damage
    damage.sPawn = self.Deployed2       --Damage spawn
	ret:AddDamage(damage)               --Add damage
    RR_HiddenTeleport(ret, p3)          --Teleport effect

    return ret
end
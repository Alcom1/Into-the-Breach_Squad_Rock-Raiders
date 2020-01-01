weapon_base_transporter = Skill:new{
    Deployed = "TBA",
    Range = 3,
    LaunchSound = "/weapons/swap"
}

function weapon_base_transporter:GetTargetArea(p1)
    local ret = PointList()
    local points = general_DiamondTarget(p1, self.Range)    --Get a diamond centered around self

    for i = 0, points:size() do                             --For each point in the diamond
        local point = points:index(i)                       --The point
        if not Board:IsBlocked(point, PATH_FLYER) then      --If the point is not blocked
            ret:push_back(point)                            --the point is valid, add it
        end
    end

    return ret
end

function HiddenTeleport(effect, p)
	--Fail a teleport to an invalid point, creating an enter effect here, in a script so it's not in the preview.
	effect:AddScript([[
		local effect = SkillEffect()
        local from = Point(]].. p.x ..",".. p.y ..[[)
        effect:AddTeleport(from, Point(-1, -1), FULL_DELAY)
		Board:AddEffect(effect)
	]])
end

function weapon_base_transporter:GetSkillEffect(p1, p2)
    local ret = SkillEffect()

	local damage = SpaceDamage(p2, 0)   --Damage
    damage.sPawn = self.Deployed        --Damage spawn
	ret:AddDamage(damage)               --Add damage
    HiddenTeleport(ret, p2)             --Teleport effect

    return ret
end
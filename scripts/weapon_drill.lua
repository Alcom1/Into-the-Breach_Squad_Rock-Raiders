--Drill weapon with a charge, pass-through, damage, and pull effect
weap_prime_drill = Skill:new{
    Name = "Mining Drill",
    Description = "Charge and drill through tiles, pulling and damaging each one.",
    Class = "Prime",
    Icon = "weapons/weapon1.png",
    Rarity = 2,
    Damage = 1,
    PowerCost = 1,
    Upgrades = 2,
    UpgradeCost = { 2, 2 },
    UpgradeList = { "Impact Ramp", "Ally Immune" },
    ImpactRamp = false,
    FriendlyDamage = true,
    TipImage = {
        Unit = Point(2, 4),
        Building = Point(2, 3),
        Enemy = Point(2, 2),
        Enemy2 = Point(2, 1),
        Target = Point(2, 0)
    }
}

--Damage ramp upgrade
weap_prime_drill_A = weap_prime_drill:new{
    UpgradeDescription = "Damage increases by 1 for each unit you pass through.",
    ImpactRamp = true,
    TipImage = {
        Unit = Point(2, 4),
        Enemy = Point(2, 3),
        Enemy2 = Point(2, 2),
        Enemy3 = Point(2, 1),
        Target = Point(2, 0)
    }
}

--Ally Immune upgrade
weap_prime_drill_B = weap_prime_drill:new{
    UpgradeDescription = "Friendly units will not take damage or be pulled by this attack.",
    FriendlyDamage = false,
    TipImage = {
        Unit = Point(2, 4),
        Friendly = Point(2, 3),
        Enemy = Point(2, 2),
        Enemy2 = Point(2, 1),
        Target = Point(2, 0)
    }
}

--Both upgrades combined
weap_prime_drill_AB = weap_prime_drill:new{
    ImpactRamp = true,
    FriendlyDamage = false,
}	

--Target Area for pass-through
function weap_prime_drill:GetTargetArea(p1)
    local ret = PointList()
    for i = DIR_START, DIR_END do                           --For each direction
        for k = 1, INT_MAX do                               --For each tile in a line
            local point = p1 + DIR_VECTORS[i] * k
            if not Board:IsValid(point) then                --Break when we leave the board
                break
            end

            if not Board:IsBlocked(point, PATH_FLYER) then  --Point is valid if it can be flown to, if it is empty
                ret:push_back(point)
            end
        end
    end

    return ret
end

--Skill Effect for charge, damage, pull, and upgrades
function weap_prime_drill:GetSkillEffect(p1, p2)
    local ret = SkillEffect()
    local damagePoints = p1:PointsBetween(p2, 1, 1)                             --Points from here to there
    local pullDirection = GetDirection(p1 - p2)                                 --Direction to pull in
    
    ret:AddCharge(Board:GetPath(p1, p2, PATH_FLYER), NO_DELAY)                  --Charge!
    
    local ramp = 0

    for i, point in ipairs(damagePoints) do
        if self.FriendlyDamage or not Board:IsPawnTeam(point, TEAM_PLAYER) then --If ally immune, skip damage for allies
            local damage = SpaceDamage(point, self.Damage + ramp)               --Damage
            damage.iPush = pullDirection                                        --Damage pull
            ret:AddDamage(damage)                                               --Damage
            ret:AddDelay(0.1)                                                   --Damage delay as we travel
        end
        if self.ImpactRamp and Board:IsPawnSpace(point) then                    --If ramp, ramp
            ramp = ramp + 1                                                     --ramp
        end
    end

    return ret
end
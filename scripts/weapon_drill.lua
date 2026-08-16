--Drill weapon with a charge, pass-through, damage, and pull effect
Weap_RR_Prime_Drill = Skill:new{
    Name = "Mining Drill",
    Description = "Charge forward, drilling through each tile you pass.",
    Class = "Prime",
    Icon = "weapons/rr_weapon_drill.png",
    Damage = 1,
    Range = 3,
    PowerCost = 0,
    Upgrades = 2,
    UpgradeCost = { 1, 3 },
    UpgradeList = { "Unlimited Range", "Driller Knight!" },
    ImpactRamp = false,
    DamageAnimation = "rock1d",
    DamageSound = "/mech/distance/artillery/death",
    TipImage = {
        Unit = Point(2, 3),
        Enemy = Point(2, 2),
        Enemy2 = Point(2, 1),
        Target = Point(2, 0)
    }
}

--Ally Immune upgrade
Weap_RR_Prime_Drill_A = Weap_RR_Prime_Drill:new{
    UpgradeDescription = "Drill range is unlimited.",
    Range = INT_MAX,
    TipImage = {
        Unit = Point(2, 4),
        Enemy = Point(2, 3),
        Enemy2 = Point(2, 2),
        Enemy3 = Point(2, 1),
        Target = Point(2, 0)
    }
}

--Damage ramp upgrade
Weap_RR_Prime_Drill_B = Weap_RR_Prime_Drill:new{
    UpgradeDescription = "Damage increases by 1 for each unit you pass through.",
    ImpactRamp = true,
}

--Both upgrades combined
Weap_RR_Prime_Drill_AB = Weap_RR_Prime_Drill:new{
    ImpactRamp = true,
    Range = INT_MAX,
    TipImage = {
        Unit = Point(2, 4),
        Enemy = Point(2, 3),
        Enemy2 = Point(2, 2),
        Enemy3 = Point(2, 1),
        Target = Point(2, 0)
    }
}	

--Target Area for pass-through
function Weap_RR_Prime_Drill:GetTargetArea(p1)
    local ret = PointList()
    for i = DIR_START, DIR_END do                           --For each direction
        for k = 1, self.Range do                            --For each tile in a line
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
function Weap_RR_Prime_Drill:GetSkillEffect(p1, p2)
    local ret = SkillEffect()
    local damagePoints = p1:RR_Bresenham(p2, 1, 1)              --Points from here to there
    local pullDirection = GetDirection(p1 - p2)                 --Direction to pull in
    
    --ret:AddAnimation(p1, self.DamageAnimation)                --Initial Animation
    ret:AddSound(self.DamageSound)                              --Initial Drill Sound
    ret:AddCharge(Board:GetPath(p1, p2, PATH_FLYER), NO_DELAY)  --Charge!
    
    local ramp = 0

    for i, point in ipairs(damagePoints) do

        local damage = SpaceDamage(point, self.Damage + ramp)   --Damage
        damage.iPush = pullDirection                            --Damage pull
        if not RR_IsSink(point) then                            --vfx if on land
            damage.sAnimation = self.DamageAnimation
        end
        damage.sSound = self.DamageSound
        ret:AddDamage(damage)                                   --Damage
        ret:AddBounce(point, 4)                                 --Bounce

        if self.ImpactRamp and Board:IsPawnSpace(point) then    --If ramp, ramp
            ramp = ramp + 1                                     --ramp
        end
        
        ret:AddDelay(0.1)                                       --Delay effects as we travel
    end

    return ret
end
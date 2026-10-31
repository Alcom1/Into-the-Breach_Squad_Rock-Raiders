--Reference laser
Weap_RR_Prime_Crush_Laser = Laser_Base:new{
    Damage = 1
}

--Crush weapon with a charge, pass-through, damage, and pull effect
Weap_RR_Prime_Crush = Skill:new{
    Name = "Mining Laser",
    Description = "Travel in a line, firing a pair of peircing beams.",
    Class = "Brute",
    Icon = "weapons/rr_weapon_crush.png",
    Damage = 2,
    MinDamage = 1,
    Range = INT_MAX,
    PowerCost = 1,
    Upgrades = 2,
    UpgradeCost = { 2, 3 },
    UpgradeList = { "Drill!", "+1 Damage" },
    DrillBetween = false,
    LaserRef = Weap_RR_Prime_Crush_Laser,
	TwoClick = true,
	DriveSound = "/weapons/charge",
    DamageAnimation = "rock1d",
    DamageSound = "/mech/distance/artillery/death",
    DamageSoundLaser = "/weapons/burst_beam",
    TipImage = {
        --This doofus
        Unit = Point(1, 3),

        --Laser Line 1
        Enemy = Point(2, 3),
        Enemy2 = Point(3, 3),
        Enemy3 = Point(4, 3),

        --Laser Line 2
        Enemy4 = Point(2, 1),
        Enemy5 = Point(3, 1),
        Enemy6 = Point(4, 1),

        --Targets
		Target = Point(2, 3),
        Second_Click = Point(1, 1)
    }
}

--Damage upgrade
Weap_RR_Prime_Crush_A = Weap_RR_Prime_Crush:new{
    UpgradeDescription = "Drill through tiles between laser shots.",
    DrillBetween = true,
    TipImage = {
        --This doofus
        Unit = Point(1, 3),

        --Laser Line 1
        Enemy = Point(2, 3),
        Enemy2 = Point(3, 3),
        Enemy3 = Point(4, 3),

        --Laser Line 2
        Enemy4 = Point(2, 1),
        Enemy5 = Point(3, 1),
        Enemy6 = Point(4, 1),

        --Drill target
        Enemy7 = Point(1, 2),

        --Targets
		Target = Point(2, 3),
        Second_Click = Point(1, 1)
    }
}

--Damage upgrade
Weap_RR_Prime_Crush_B = Weap_RR_Prime_Crush:new{
    UpgradeDescription = "Increases drill and laser damage by 1.",
    Damage = 3
}

--Both upgrades combined
Weap_RR_Prime_Crush_AB = Weap_RR_Prime_Crush:new{
    DrillBetween = true,
    Damage = 3,
    TipImage = {
        --This doofus
        Unit = Point(1, 3),

        --Laser Line 1
        Enemy = Point(2, 3),
        Enemy2 = Point(3, 3),
        Enemy3 = Point(4, 3),

        --Laser Line 2
        Enemy4 = Point(2, 1),
        Enemy5 = Point(3, 1),
        Enemy6 = Point(4, 1),

        --Drill target
        Enemy7 = Point(1, 2),

        --Targets
		Target = Point(2, 3),
        Second_Click = Point(1, 1)
    }
}

--Target Area for Laser 1
function Weap_RR_Prime_Crush:GetTargetArea(p1)
    local ret = PointList()
    for i = DIR_START, DIR_END do
        ret:push_back(p1 + DIR_VECTORS[i])
    end

    return ret
end

--Target Area for Travelling after Laser 1
function Weap_RR_Prime_Crush:GetSecondTargetArea(p1, p2)

    local dir = GetDirection(p2 - p1)
    
    local ret = PointList()
    for i = DIR_START, DIR_END do                               --For each direction

        local dirTest = DIR_VECTORS[i]

        if dirTest:MD_Cross(p2 - p1) ~= 0 then                  --Lasers must be perpendicular to travel
            for k = 1, self.Range do                            --For each tile in a line
                local point = p1 + dirTest * k
                if not Board:IsValid(point) then                --Break when we leave the board
                    break
                end

                if not Board:IsBlocked(point, PATH_FLYER) then  --Point is valid if it can be flown to, if it is empty
                    ret:push_back(point)
                elseif not self.DrillBetween then               --Stop if not drilling
                    break
                end
            end
        end
    end

    return ret
end

--Click check for 2nd laser
function Weap_RR_Prime_Crush:IsTwoClickException(p1, p2)
    local target = p2 - p1

    --If both spaces perpedicular to laser 1 are blocked, do not two click
    for i = -1, 1, 2 do
        local perp = Point(target.y * i, target.x * i)

        --For all points in perpendicular line
        for k = 1, (self.DrillBetween and self.Range or 1) do
            local check = p1 + perp * k

            if not Board:IsValid(check) then    --Break when we leave the board
                break
            end

            if not Board:IsBlocked(check, PATH_FLYER) then
                return false
            end
        end
    end

	return true
end

--Adds a laser to SkillEffect
local function RR_ChromeLaser(self, effect, p1, p2)

    local laserPoints = p1:RR_LaserPoints(GetDirection(p2 - p1))    --Get laser points in firing direction
    local laserDamage = self.Damage                                 --Initial laser damage

    effect:AddDamage(SoundEffect(p1, self.DamageSoundLaser))

    --Deal damage for each lasered gridspace
    for i, point in ipairs(laserPoints) do

        local damage = SpaceDamage(point, laserDamage)
        
        --All but the final effect have no projectile. Laser projectile for final hit
        if i < #laserPoints then
            effect:AddDamage(damage)
        else
            effect:AddProjectile(
                p1, 
                damage,
                self.LaserRef.LaserArt, 
                FULL_DELAY)
        end

        --Decrement laser damage until it reaches the minimum
        laserDamage = math.max(laserDamage - 1, self.MinDamage)
    end

    return effect
end

--Skill Effect for Laser 1
function Weap_RR_Prime_Crush:GetSkillEffect(p1, p2)
    local ret = SkillEffect()

    ret = RR_ChromeLaser(self, ret, p1, p2)

    return ret
end

--Skill Effect for Laser 1, move, and Laser 2
function Weap_RR_Prime_Crush:GetFinalEffect(p1, p2, p3)
    local ret = self:GetSkillEffect(p1, p2)

    ret:AddDelay(0.35)
    ret:AddDamage(SoundEffect(p1, self.DriveSound))             --Initial Charge Sound
    ret:AddDelay(0.15)
    ret:AddCharge(Board:GetPath(p1, p3, PATH_FLYER), NO_DELAY)  --Charge!

    --Travel, and also drill if enabled
    local distance = p1:Manhattan(p3)
    if self.DrillBetween and distance >= 2 then
        local damagePoints = p1:RR_Bresenham(p3, 1, 1)          --Points from here to there
        local pullDirection = GetDirection(p1 - p3)             --Direction to pull in

        for i, point in ipairs(damagePoints) do
            local damage = SpaceDamage(point, self.Damage - 1)  --Damage
            damage.iPush = pullDirection                        --Damage pull
            if not RR_IsSink(point) then                        --vfx if on land
                damage.sAnimation = self.DamageAnimation
            end
            damage.sSound = self.DamageSound
            ret:AddDamage(damage)                               --Damage
            ret:AddBounce(point, 4)                             --Bounce
            
            ret:AddDelay(0.1)                                   --Delay effects as we travel
        end

        ret:AddDelay(0.2)                                       --Tiny extra delay to account for start/end
    else
        ret:AddDelay(0.1 * distance)
    end

    --Do not fire 2nd laser if submerged or smoked
    local isSink    = RR_IsSink(p3)     and not Board:GetPawn(p1):IsFlying()
    local isSmoke   = Board:IsSmoke(p3) and not Board:GetPawn(p1):IsIgnoreSmoke() and not IsPassiveSkill("Passive_HealingSmoke")
    if not isSink and not isSmoke then
        ret = RR_ChromeLaser(self, ret, p3, p3 + DIR_VECTORS[GetDirection(p2 - p1)])
    end

    return ret
end
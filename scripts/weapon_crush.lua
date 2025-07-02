--Reference laser
Weap_RR_Prime_Crush_Laser = Laser_Base:new{
    Damage = 1
}

--Crush weapon with a charge, pass-through, damage, and pull effect
Weap_RR_Prime_Crush = Skill:new{
    Name = "Chrome Array",
    Description = "Drill to an adjacent tile, then fire a piercing beam.",
    Class = "Brute",
    Icon = "weapons/weapon_crush.png",
    Range = 2,
    Damage = 1,
    PowerCost = 1,
    Upgrades = 2,
    UpgradeCost = { 2, 2 },
    UpgradeList = { "Power Miner!", "+1 Damage" },
    PowerMiner = false,
    LaserRef = Weap_RR_Prime_Crush_Laser,
	TwoClick = true,
    DamageAnimation = "rock1d",
    DamageSound = "/mech/distance/artillery/death",
    TipImage = {
        Unit = Point(2, 3),
        Enemy = Point(2, 2),
        Target = Point(2, 1)
    }
}

--Ally Immune upgrade
Weap_RR_Prime_Crush_A = Weap_RR_Prime_Crush:new{
    UpgradeDescription = "Destroying a rock with the laser drops an energy crystal tile that gives Mechs Boost.",
    PowerMiner = true
}

--Damage ramp upgrade
Weap_RR_Prime_Crush_B = Weap_RR_Prime_Crush:new{
    UpgradeDescription = "Increases drill and laser damage by 1.",
    Damage = 2
}

--Both upgrades combined
Weap_RR_Prime_Crush_AB = Weap_RR_Prime_Crush:new{
    PowerMiner = true,
    Damage = 2
}

--Target Area for pass-through
function Weap_RR_Prime_Crush:GetTargetArea(p1)
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

--Target Area for pass-through
function Weap_RR_Prime_Crush:GetSecondTargetArea(p1, p2)
    if not Board:GetPawn(p1):IsFlying() and RR_IsSink(p2) then
        return PointList()
    end

    return self.LaserRef:GetTargetArea(p2)
end

function Weap_RR_Prime_Crush:IsTwoClickException(p1, p2)
    if Board:GetPawn(p1):IsFlying() or not RR_IsSink(p2) then
        return false
    end
	
	return true
end

--Skill Effect for charge, damage, pull, and upgrades
function Weap_RR_Prime_Crush:GetSkillEffect(p1, p2)
    local ret = SkillEffect()

    ret:AddSound(self.DamageSound)                                  --Initial Drill Sound
    ret:AddCharge(Board:GetPath(p1, p2, PATH_FLYER), NO_DELAY)      --Charge!

    if p1:Manhattan(p2) >= 2 then
        local pullDirection = GetDirection(p1 - p2)                 --Direction to pull in
        local damage = SpaceDamage(
            p1 + DIR_VECTORS[GetDirection(p2 - p1)], 
            self.Damage)                                            --Damage
        damage.iPush = pullDirection                                --Damage pull
        damage.sAnimation = self.DamageAnimation
        damage.sSound = self.DamageSound
        ret:AddDamage(damage)                                       --Damage
    end

    return ret
end

--Skill Effect for charge, damage, pull, and upgrades
function Weap_RR_Prime_Crush:GetFinalEffect(p1, p2, p3)
    local ret = SkillEffect()
    local distance = p1:Manhattan(p2)

    ret:AddSound(self.DamageSound)                                  --Initial Drill Sound
    ret:AddCharge(Board:GetPath(p1, p2, PATH_FLYER), NO_DELAY)      --Charge!

    if distance >= 2 then
        local pullDirection = GetDirection(p1 - p2)                 --Direction to pull in
        local damage = SpaceDamage(
            p1 + DIR_VECTORS[GetDirection(p2 - p1)], 
            self.Damage)                                            --Damage
        damage.iPush = pullDirection                                --Damage pull
        damage.sAnimation = self.DamageAnimation
        damage.sSound = self.DamageSound
        ret:AddDamage(damage)                                       --Damage
    end

    if Board:GetPawn(p1):IsFlying() or not RR_IsSink(p2) then
        ret:AddDelay(0.1 * (distance + 1))
        ret:AddSound("/weapons/burst_beam")

        local laserPoints = p2:LaserPoints(GetDirection(p3 - p2))
        local laserDamage = self.Damage
    
        for i, point in ipairs(laserPoints) do

            local damage = SpaceDamage(point, laserDamage)

            if self.PowerMiner and RR_HasFragileRock(point, damage) then
                damage.sScript = "Board:ClearSpace("..point:GetString()..")"    --Just delete the rock
                damage.sItem = "Item_RR_Crystal_Mine"
                damage.sAnimation = "rock1d"
                damage.sSound = "/support/rock/death"
            end
            
            if i < #laserPoints then
                ret:AddDamage(damage)
            else
                ret:AddProjectile(
                    p2, 
                    damage,
                    self.LaserRef.LaserArt, 
                    FULL_DELAY)
            end

            laserDamage = math.max(laserDamage - 1, 1)
        end
    end

    return ret
end
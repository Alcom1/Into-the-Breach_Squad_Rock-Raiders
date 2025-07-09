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
    UpgradeCost = { 1, 3 },
    UpgradeList = { "Power Miner!", "+2 Damage" },
    PowerMiner = false,
    LaserRef = Weap_RR_Prime_Crush_Laser,
	TwoClick = true,
    DamageAnimation = "rock1d",
    DamageSound = "/mech/distance/artillery/death",
    DamageSoundMine = "/support/rock/death",
    DamageSoundLaser = "/weapons/burst_beam",
    DamageMarker = "combat/crystal_0.png",
    TipImage = {
        Unit = Point(1, 3),
        Enemy = Point(1, 2),
        Enemy2 = Point(2, 1),
        Enemy3 = Point(3, 1),
		Target = Point(1, 1),
        Second_Click = Point(4, 1)
    }
}

--Ally Immune upgrade
Weap_RR_Prime_Crush_A = Weap_RR_Prime_Crush:new{
    UpgradeDescription = "Destroying a rock with the laser drops an energy crystal tile that gives Mechs Boost.",
    PowerMiner = true,
    TipImage = {
        Unit = Point(2, 3),
        Enemy = Point(2, 1),
		Target = Point(2, 2),
        Second_Click = Point(2, 0),
		CustomEnemy = "Wall",
        Second_Target = Point(2, 1),
        Second_Origin = Point(2, 2),
    }
}

--Damage ramp upgrade
Weap_RR_Prime_Crush_B = Weap_RR_Prime_Crush:new{
    UpgradeDescription = "Increases drill and laser damage by 1.",
    Damage = 3
}

--Both upgrades combined
Weap_RR_Prime_Crush_AB = Weap_RR_Prime_Crush:new{
    PowerMiner = true,
    Damage = 3
}

--Target Area for short-range drill
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

--Target Area for 3-direction laser
function Weap_RR_Prime_Crush:GetSecondTargetArea(p1, p2)
    --Laser cannot be fired if mech is non-flying and sunk
    if not Board:GetPawn(p1):IsFlying() and RR_IsSink(p2) then
        return PointList()
    end

    local ret = PointList()

    --All directions
    for j = DIR_START, DIR_END do
        if j ~= GetDirection(p1 - p2) then                  --Except don't fire backwards
            for i, point in ipairs(p2:RR_LaserPoints(j)) do --Get all points for a laser
                ret:push_back(point)
            end
        end
    end

    return ret
end

--Click check for laser
function Weap_RR_Prime_Crush:IsTwoClickException(p1, p2)
    --Laser cannot be fired if mech is non-flying and sunk
    if Board:GetPawn(p1):IsFlying() or not RR_IsSink(p2) then
        return false
    end
	
	return true
end

--Skill Effect for charge, damage, and pull
function Weap_RR_Prime_Crush:GetSkillEffect(p1, p2)
    local ret = SkillEffect()

    ret:AddSound(self.DamageSound)                                      --Initial Drill Sound
    ret:AddCharge(Board:GetPath(p1, p2, PATH_FLYER), NO_DELAY)          --Charge!
    
    if p1:Manhattan(p2) >= 2 then   
        local point = p1 + DIR_VECTORS[GetDirection(p2 - p1)]           --Point where damage occurs
        local pullDirection = GetDirection(p1 - p2)                     --Direction to pull in
        local damage = SpaceDamage( 
            point,    
            self.Damage)                                                --Damage
        damage.iPush = pullDirection                                    --Damage pull
        if not RR_IsSink(point) then                                    --vfx if on land
            damage.sAnimation = self.DamageAnimation
        end
        damage.sSound = self.DamageSound    
        ret:AddDamage(damage)                                           --Damage
    end

    return ret
end

--Skill Effect for initial effect and then firing the mining laser
function Weap_RR_Prime_Crush:GetFinalEffect(p1, p2, p3)
    local ret = self:GetSkillEffect(p1, p2)                             --Initial drill effect

    --TIP IMAGE HACK
    if Board:IsTipImage() and p2 == Point(2, 1) then
        ret:AddScript("Board:GetPawn("..p2:GetString().."):SetBoosted(true)")
        return ret
    end

    --Laser can be fired if mech is flying or on land after drilling
    if Board:GetPawn(p1):IsFlying() or not RR_IsSink(p2) then
        ret:AddDelay(0.1 * (p1:Manhattan(p2) + 1))                      --Wait for drilling charge to complete
        ret:AddSound(self.DamageSoundLaser)                             --Laser sound

        local laserPoints = p2:RR_LaserPoints(GetDirection(p3 - p2))    --Get laser points in firing direction
        local laserDamage = self.Damage                                 --Initial laser damage
    
        --Deal damage for each lasered gridspace
        for i, point in ipairs(laserPoints) do

            local damage = SpaceDamage(point, laserDamage)

            --Clear the rock and place a crystal there for Power Miner effect and destroyed rock
            if self.PowerMiner and RR_HasDeadRock(point, damage) then
                damage.sScript = "Board:ClearSpace("..point:GetString()..")"
                damage.sItem = "Item_RR_Crystal_Mine"
                damage.sAnimation = self.DamageAnimation
                damage.sSound = self.DamageSoundMine
                damage.sImageMark = self.DamageMarker
            end
            
            --All but the final effect have no projectile. Laser projectile for final hit
            if i < #laserPoints then
                ret:AddDamage(damage)
            else
                ret:AddProjectile(
                    p2, 
                    damage,
                    self.LaserRef.LaserArt, 
                    FULL_DELAY)
            end

            --Decrement laser damage until it's 1
            laserDamage = math.max(laserDamage - 1, 1)
        end
    end

    return ret
end
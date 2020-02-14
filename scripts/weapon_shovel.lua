--Shovel that spawns and pushes a rock
Weap_RR_Brute_Shovel = Skill:new{
    Name = "Mining Scoop",
    Description = "Dig up a rock and dash in a line with it, damaging and pushing a target.",
    Class = "Brute",
    Icon = "weapons/weapon_scoop.png",
    Damage = 1,
    PowerCost = 1,
    Upgrades = 2,
    UpgradeCost = { 3, 2 },
    UpgradeList = { "+2 Damage", "Frozen Frenzy!" },
    CreateSound = "/enemy/digger_1/attack_queued",
    ChargeSound = "/weapons/charge",
    ImpactSound = "/impact/generic/explosion",
    DamageMarker = "combat/rock_l.png",
    FFrenzy = false,
    TipImage = {
        Unit = Point(2, 4),
        Enemy = Point(2, 1),
        Target = Point(2, 1)
    }
}

--Damage ramp upgrade
Weap_RR_Brute_Shovel_A = Weap_RR_Brute_Shovel:new{
    UpgradeDescription = "Increases damage by 2.",
    Damage = 3,
}

--Ally Immune upgrade
Weap_RR_Brute_Shovel_B = Weap_RR_Brute_Shovel:new{
    UpgradeDescription = "Freeze the rock you dig up.",
    FFrenzy = true
}

--Both upgrades combined
Weap_RR_Brute_Shovel_AB = Weap_RR_Brute_Shovel:new{
    Damage = 3,
    FFrenzy = true
}	

--Get the end of an earth path, a path that continues until before the ground ends
local function RR_GetEarthPathEnd(p1, p2)
    local travelPoints = p1:Bresenham(p2)       --Get all points from here to there

    for i, point in ipairs(travelPoints) do
        if RR_IsSink(point) then                --If this point will sink the rock
            return travelPoints[i - 1]          --Return the previous point
        end
    end

    return p2                                   --Return the last point if the ground never ends
end

-- Spawn a rock without a preview
local function RR_HiddenRock(effect, p)
	-- spawn rock via script so the preview doesn't know about it
	effect:AddScript([[
		local effect = SkillEffect()
        local damage = SpaceDamage(Point(]].. p.x ..",".. p.y ..[[), 0)
        damage.sPawn = "Wall"
        effect:AddDamage(damage)
		Board:AddEffect(effect)
	]])
end

-- Skill Effect that creates and charges self and a rock
function Weap_RR_Brute_Shovel:GetSkillEffect(p1, p2)
    --Initial points and conditions
    local ret = SkillEffect()
    local isTargeting = Board:IsBlocked(p2, PATH_FLYER)     --If we are targeting something, a non-empty tile
    local direction = GetDirection(p2 - p1)                 --The direction we are travelling in
    local isMeleeRange = p1:Manhattan(p2) == 1

    --Intial Sound effect
    ret:AddSound(self.ChargeSound)                          --Charge SFX

    --Special case where we melee a target
    if(isTargeting and isMeleeRange) then
        local meleeDamage = SpaceDamage(p2, self.Damage, direction) --Damage
        meleeDamage.sSound = self.ImpactSound                       --Damage sfx
        meleeDamage.sAnimation = "airpush_"..(direction % 4)        --Damage anim
        ret:AddMelee(p1, meleeDamage, NO_DELAY)                     --Melee
        ret:AddBounce(p1, 2)                                        --Bounce
        ret:AddBounce(p2, 2)                                        --Bounce
        return ret
    end

    --Repositioning based on conditions
    local bruteFinal = p2 - DIR_VECTORS[direction]          --The landing location of this mech
    local spawnStart = p1 + DIR_VECTORS[direction]          --The starting location of the rock

    local pointSink = RR_GetEarthPathEnd(p1, p2)            --Get a sink landing point for the rock
    local isSink =                                          --If the landing point will cause a sink
        math.abs(p1:Manhattan(p2)) > 
        math.abs(p1:Manhattan(pointSink))                   --Move comparison over by one if we are targeting something so we still attack it.
           
    local spawnFinal =                                      --The landing location of the rock
        isSink and                                          --Stop at the sink location if we're sinking, go to the target point otherwise
        pointSink + DIR_VECTORS[direction]                  --Move forward one so the spawn falls into the hole.
        or p2                                               --Go to the target point

    if isTargeting then                                     --Move landing locations backwards if we're targeting an enemy
        if not isSink then                                  --Move spawnFinal back if the rock didn't sink
            spawnFinal = bruteFinal
        end
        bruteFinal = bruteFinal - DIR_VECTORS[direction]
    end

    if isSink then
        bruteFinal = bruteFinal + DIR_VECTORS[direction]    --Wait no go back
    end

    --Actions and movement
    create = SpaceDamage(p2, 0)                             --Melee effect for creating a rock or attacking a unit
    create.sSound = self.CreateSound                        --Rock creating SFX
    ret:AddMelee(p1, create)                                --Rock creating visual
    RR_HiddenRock(ret, spawnStart)                          --Spawn a rock without previewing it
    ret:AddDelay(isMeleeRange and 0.05 or 0.25)             --Timing is off without this delay

    if self.FFrenzy and not RR_IsSink(spawnStart) then      --Frozen Frenzy, freeze the location where the rock spawned unless it's a sink
        damageFreeze = SpaceDamage(spawnStart, 0)           --Damage, Damage is overridden if we melee a target
        damageFreeze.iFrozen = 1                            --Damage Freeze
        ret:AddDamage(damageFreeze)                         --Damage
    end

    ret:AddCharge(Board:GetSimplePath(p1, bruteFinal), NO_DELAY)            --Shovel charge
    ret:AddCharge(Board:GetSimplePath(spawnStart, spawnFinal), NO_DELAY)    --Rock charge

    local temp = p1                                     --Add bounce effects like charge mech because we charging!
    while temp ~= p2  do
        ret:AddBounce(temp, 2)
        temp = temp + DIR_VECTORS[direction]
        if temp ~= p2 then
            ret:AddDelay(0.06)
        end
    end

    --Damage
    local damage = SpaceDamage(p2, 0)                   --Will either be a Damage & Push or a rock spawn indicator

    if isTargeting then                                 --Deal damage to and push a target
        damage.iPush = direction                        --Damage push
        damage.iDamage = self.Damage                    --Damage damage
        damage.sSound = self.ImpactSound                --Damage sfx
        damage.sAnimation = "airpush_"..(direction % 4) --Damage anim

        ret:AddMelee(bruteFinal, SpaceDamage(p2, 0), NO_DELAY)  --Melee animation for pushing rock into enemy
        ret:AddMelee(spawnFinal, SpaceDamage(p2, 0), NO_DELAY)  --Melee animation for pushing rock into enemy

        if not isSink then                              --If a rock lands here show it
            local marker = SpaceDamage(spawnFinal, 1)   --Show that we're placing a rock before here.
            marker.sImageMark = self.DamageMarker       --Show
            ret:AddDamage(marker)                       --Show
        end

    elseif not isSink then                              --If a rock lands here show it
        damage.sImageMark = self.DamageMarker           --Show that we're placing a rock here.
    end
    
    ret:AddDamage(damage)

    --It's finally over
    return ret
end
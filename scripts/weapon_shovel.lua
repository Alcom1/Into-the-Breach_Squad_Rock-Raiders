--Shovel that spawns and pushes a rock
Weap_RR_Brute_Shovel = Skill:new{
    Name = "Mining Scoop",
    Description = "Dig up and move a rock. Optionally shove the rock into an enemy, damaging and pushing it.",
    Class = "Brute",
    Icon = "weapons/weapon_scoop.png",
    Damage = 1,
    PowerCost = 1,
    Upgrades = 2,
    UpgradeCost = { 3, 1 },
    UpgradeList = { "+2 Damage", "Oresome!" },
    CreateSound = "/enemy/digger_1/attack_queued",
    ChargeSound = "/weapons/charge",
    ImpactSound = "/impact/generic/explosion",
    DamageMarker = "units/aliens/rock_1.png",
    Oresome = false,
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
    UpgradeDescription = "Placing a rock pushes units to the side.",
    Oresome = true
}

--Both upgrades combined
Weap_RR_Brute_Shovel_AB = Weap_RR_Brute_Shovel:new{
    Damage = 3,
    Oresome = true
}	

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

--If terrain is water
local function RR_IsLiquid(point)
    local terrain = Board:GetTerrain(point)
	return	terrain == TERRAIN_WATER or terrain == TERRAIN_LAVA
end

-- Skill Effect that creates and charges self and a rock
function Weap_RR_Brute_Shovel:GetSkillEffect(p1, p2)
    local ret = SkillEffect()
    local isTargeting = Board:IsBlocked(p2, PATH_FLYER)     --If we are targeting something, a non-empty tile
    local direction = GetDirection(p2 - p1)                 --The direction we are travelling in
    local isMeleeRange = p1:Manhattan(p2) == 1

    local bruteFinal = p2 - DIR_VECTORS[direction]          --The landing location of this mech
    local spawnStart = p1 + DIR_VECTORS[direction]          --The starting location of the rock
    local spawnFinal = p2                                   --The landing location of the rock

    if(isTargeting and isMeleeRange) then                   --Can't do anything to enemies within melee range so just stop.
        return ret
    end

    if isTargeting then                                     --Move landing locations backwards if we're targeting an enemy
        spawnFinal = bruteFinal
        bruteFinal = bruteFinal - DIR_VECTORS[direction]
    end

    local isStartLiquid = RR_IsLiquid(spawnStart)           --If the rock starting position is water
    local isFinalLiquid = RR_IsLiquid(spawnFinal)           --If the rock ending position is water

    if isStartLiquid then
        isTargeting = false                                 --Stop targeting if the start is water, we can't spawn a rock
        bruteFinal = bruteFinal + DIR_VECTORS[direction]    --Wait no go back
    end

    ret:AddSound(self.ChargeSound)                          --Charge SFX
    
    create = SpaceDamage(p2, 0)                             --Melee effect for creating a rock or attacking a unit
    create.sSound = self.CreateSound                        --Rock creating SFX
    ret:AddMelee(p1, create)                                --Rock creating visual
    RR_HiddenRock(ret, spawnStart)                          --Spawn a rock without previewing it
    ret:AddDelay(isMeleeRange and 0.05 or 0.25)             --Timing is off without this delay

    ret:AddCharge(Board:GetSimplePath(p1, bruteFinal), NO_DELAY)            --Shovel charge
    ret:AddCharge(Board:GetSimplePath(spawnStart, spawnFinal), NO_DELAY)    --Rock charge

    local temp = p1                                         --Add bounce effects like charge mech because we charging!
    while temp ~= p2  do
        ret:AddBounce(temp, 2)
        temp = temp + DIR_VECTORS[direction]
        if temp ~= p2 then
            ret:AddDelay(0.06)
        end
    end
    
    if not isStartLiquid then                               --We can't spawn rocks in water, so don't even bother.

        if self.Oresome then
            ret:AddBounce(spawnFinal, 3)
            local left = (direction - 1) % 4                --left direction
            local right = (direction + 1) % 4               --right direction
            local damageLeft = SpaceDamage(spawnFinal + DIR_VECTORS[left], 0, left)     --Damage left
            local damageRight = SpaceDamage(spawnFinal + DIR_VECTORS[right], 0, right)  --Damage right
            damageLeft.sAnimation = "airpush_"..left        --Damage left anim
            damageRight.sAnimation = "airpush_"..right      --Damage right anim
            damageLeft.sSound = self.ImpactSound            --Damage sfx
            ret:AddDamage(damageLeft)
            ret:AddDamage(damageRight)
        end

        local damage = SpaceDamage(p2, 0)                   --Will either be a Damage & Push or a rock spawn indicator

        if isTargeting then                                 --Deal damage to and push a target
            damage.iPush = direction                        --Damage push
            damage.iDamage = self.Damage                    --Damage damage
            damage.sSound = self.ImpactSound                --Damage sfx
            damage.sAnimation = "airpush_"..(direction % 4) --Damage anim

            if not isFinalLiquid then                       --If a rock lands here show it
                local marker = SpaceDamage(spawnFinal, 0)   --Show that we're placing a rock before here.
                marker.sImageMark = self.DamageMarker       --Show
                ret:AddDamage(marker)                       --Show
            end

            ret:AddMelee(bruteFinal, SpaceDamage(p2, 0), NO_DELAY)  --Melee animation for pushing rock into enemy
            ret:AddMelee(spawnFinal, SpaceDamage(p2, 0), NO_DELAY)  --Melee animation for pushing rock into enemy

        elseif not isFinalLiquid then                       --If a rock lands here show it
            damage.sImageMark = self.DamageMarker           --Show that we're placing a rock here.
        end
        
        ret:AddDamage(damage)
    end

    return ret
end
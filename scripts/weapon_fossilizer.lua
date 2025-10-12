--Passive weapon that turns all dead vek into rocks
Pass_RR_Generic_Fossilizer = PassiveSkill:new{
    Name = "Vek Fossilizer",
    Description = "All enemies will spawn a rock on death.",
    Icon = "weapons/passive_fossilizer.png",
    Damage = 0,
    Passive = "lmn_Passive_RockOnDeath",
    PowerCost = 0,
    Upgrades = 1,
    UpgradeCost = { 1 },
    UpgradeList = { "Power Miner!" },
    TipImage = {
        Unit = Point(2, 1),
        Enemy = Point(1, 2),
        Enemy2 = Point(2, 2),
        Enemy3 = Point(3, 2)
    }
}

--Miner upgrade
Pass_RR_Generic_Fossilizer_A = Pass_RR_Generic_Fossilizer:new{
    UpgradeDescription = "All rocks will spawn an energy crystal on death that gives mechs boost.",
    Passive = "lmn_Passive_RockOnDeath_2",
    TipImage = {
        Unit = Point(2, 1),
		Target = Point(2, 2),
        Enemy = Point(1, 2),
        Enemy2 = Point(2, 2),
        Enemy3 = Point(3, 2),
        CustomEnemy = "Wall"
    }
}

--Skill Effect for mouseover preview
function Pass_RR_Generic_Fossilizer:GetSkillEffect(p1, p2)
    local ret = SkillEffect()
    local isRock = self.Passive == "lmn_Passive_RockOnDeath"

    --Kill all 3 vek
    for xPos = 1, 3 do
        ret:AddDamage(SpaceDamage(Point(xPos, 2), DAMAGE_DEATH))
    end

    --Wait a bit
    ret:AddDelay(isRock and 0.25 or 1.00)

    --Spawn rocks (main) or crystals (upgrade!)
    for xPos = 1, 3 do
        local point = Point(xPos, 2)
        local damage = SpaceDamage(point, 0)

        --Rocks or crystals!
        if isRock then
            damage.sPawn = "Wall"
        else
            damage.sScript = "Board:ClearSpace("..point:GetString()..")"
            damage.sItem = "Item_RR_Crystal_Mine"
        end

        ret:AddDamage(damage)
        ret:AddBurst(
            point,
            "Emitter_Crystal_Purp",
            DIR_NONE)
    end

    --Collect the crystal! Get boosted!!!
    if not isRock then
        local damage = SpaceDamage(p2, 0)
        damage.sScript = "Board:GetPawn("..p2:GetString().."):SetBoosted(true)"

        ret:AddDelay(1.00)
        ret:AddMove(Board:GetPath(p1, p2, PATH_GROUND), FULL_DELAY)
        ret:AddDamage(damage)
        ret:AddDelay(1.00)
    end

    return ret
end
--Passive weapon that turns all dead vek into rocks
Pass_RR_Generic_Fossilizer = PassiveSkill:new{
    Name = "Vek Fossilizer",
    Description = "All Vek will spawn a rock on death.",
    Icon = "weapons/passive_fossilizer.png",
    Damage = 0,
    Passive = "lmn_Passive_RockOnDeath",
    PowerCost = 1,
    TipImage = {
        Unit = Point(2, 1),
        Enemy = Point(1, 2),
        Enemy2 = Point(2, 2),
        Enemy3 = Point(3, 2)
    }
}

--Skill Effect for mouseover preview
function Pass_RR_Generic_Fossilizer:GetSkillEffect(p1, p2)
    local ret = SkillEffect()
    for xPos = 1, 3 do                                              --Kill all 3 vek
        ret:AddDamage(SpaceDamage(Point(xPos, 2), DAMAGE_DEATH))
    end
    ret:AddDelay(0.25)                                              --Wait a bit
    for xPos = 1, 3 do                                              --Rocks!
        local damage = SpaceDamage(Point(xPos, 2), 0)
        damage.sPawn = "Wall"
        ret:AddDamage(damage)
    end
    return ret
end
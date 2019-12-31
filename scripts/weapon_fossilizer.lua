--Passive weapon that turns all dead vek into rocks
pass_generic_fossilizer = PassiveSkill:new{
    Name = "Vek Fossilizer",
    Description = "All Vek will spawn a rock on death.",
    Passive = "lmn_Passive_RockOnDeath",
    PowerCost = 1,
    Icon = "weapons/passive1.png",
    Damage = 0,
    TipImage = {
        Unit = Point(2, 1),
        Enemy = Point(1, 2),
        Enemy2 = Point(2, 2),
        Enemy3 = Point(3, 2)
    }
}

--Skill Effect for mouseover preview
function pass_generic_fossilizer:GetSkillEffect(p1, p2)
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
--Science weapon that deploys a dynamite spawn.
Weap_RR_Science_Deploy_Dynamite = Weap_RR_Base_Transporter:new{
    Name = "Dynamite Charge",
    Class = "Science",
    Description = "Teleport in an explosive that detonates when triggered or destroyed, pushing adjacent tiles.",
    Icon = "weapons/weapon3.png",
    Deployed = "pawn_spawn_dynamite",
    PowerCost = 1,
    Limited = 2,
    TipImage = {
        Unit = Point(2,4),
        Target = Point(2,2),
        Enemy = Point(3,2),
        Enemy2 = Point(1,2),
        Enemy3 = Point(2,3),
        Enemy4 = Point(2,1),
        Second_Origin = Point(2,2),
        Second_Target = Point(3,2),
    },
}

--Generic weapon used by Dynamite spawn, destroys self and push
weap_spawn_dynamite = Skill:new{
    LaunchSound = "/weapons/mercury_fist",
    Icon = "weapons/prime_smash.png",
    PathSize = 1,
    Damage = 1
}

--Skill Effect for self destruction and push
function weap_spawn_dynamite:GetSkillEffect(p1, p2)
    local ret = SkillEffect()
    for dir = DIR_START, DIR_END do                                 --Loop through surrounding tiles
        local damage = SpaceDamage(p1 + DIR_VECTORS[dir],  0, dir)  --Damage surrounding tiles
        damage.sAnimation = "airpush_"..(dir %4)                    --Damage
        ret:AddDamage(damage)                                       --Damage
    end
    local damageSelf = SpaceDamage(p1, DAMAGE_DEATH)                --Dynamite goes kaboom
    damageSelf.sAnimation = "ExploArt3"                             --Here's the kaboom
    ret:AddDamage(damageSelf)                                       --YES YES YES EXPLODE YES
    return ret
end
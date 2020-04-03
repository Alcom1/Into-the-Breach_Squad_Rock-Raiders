--Science weapon that deploys a fence spawn.
Weap_RR_Science_Deploy_Fence = Weap_RR_Base_Transporter:new{
    Name = "Electric Fence",
    Description = "Teleport in an electric fence that chains damage through adjacent targets.",
    Class = "Science",
    Icon = "weapons/weapon_fence.png",
    Deployed = "pawn_spawn_fence",
    PowerCost = 1,
    Upgrades = 2,
    UpgradeCost = { 2, 3 },
    UpgradeList = { "+1 Use", "+1 Damage" },
    Limited = 1,
    TipImage = {
        Unit = Point(2,4),
        Target = Point(2,2),
        Enemy = Point(1,1),
        Enemy2 = Point(2,1),
        Enemy3 = Point(3,1),
        Second_Origin = Point(2,2),
        Second_Target = Point(2,1),
    },
}

--More zappy damage
Weap_RR_Science_Deploy_Fence_A = Weap_RR_Science_Deploy_Fence:new{
    UpgradeDescription = "Increases uses per battle by 1.",
    Limited = 2
}

--More zappy damage (for less!)
Weap_RR_Science_Deploy_Fence_B = Weap_RR_Science_Deploy_Fence:new{
    UpgradeDescription = "Increases the Electric Fence's attack damage by 1.",
    Deployed = "pawn_spawn_fence2"
}

--Even more zappy damage!
Weap_RR_Science_Deploy_Fence_AB = Weap_RR_Science_Deploy_Fence:new{
    Deployed = "pawn_spawn_fence2",
    Limited = 2
}

--Generic weapon used by Electric Fence spawn
Weap_RR_Spawn_Lightning = Skill:new{
    Name = "Shock",
    Description = "Chain damage through adjacent targets.",
    LaunchSound = "/weapons/electric_whip",
    Icon = "weapons/weapon_fence_effect.png",
	PathSize = 1,
    Damage = 2,
    TipImage = {
        Unit = Point(2,2),
        Target = Point(2,1),
        Enemy = Point(1,1),
        Enemy2 = Point(2,1),
        Enemy3 = Point(3,1),
        CustomPawn = "pawn_spawn_fence"
    }
}

--Electric Fence with damage upgrade
Weap_RR_Spawn_Lightning2 = Weap_RR_Spawn_Lightning:new{
    Damage = 3
}

--Skill Effect for lightning attack
function Weap_RR_Spawn_Lightning:GetSkillEffect(p1, p2)
    local ret = SkillEffect()

    if not Board:IsPawnSpace(p2) then return ret end                        --Don't attack empty spaces
    local past = { [p1:Hash()] = true }                                     --We're not Pichu

    function RR_RecurseLightning(prev, curr, ret)
        past[curr:Hash()] = true                                            --Mark tile as past

        local damage = SpaceDamage(curr, self.Damage)                       --Damage adjacent tiles
        damage.sAnimation = "Lightning_Blue_"..GetDirection(curr - prev)    --Damage
        ret:AddDamage(damage)                                               --Damage

        for dir = DIR_START, DIR_END do                                     --Loop through adjacent tiles
            local next = curr + DIR_VECTORS[dir]                            --Adjacent tile Point
            if not past[next:Hash()] and Board:IsPawnSpace(next) then       --If tile is not past and has a pawn then
                ret = RR_RecurseLightning(curr, next, ret)                  --Recurse to adjacent tiles
            end
        end
        
        return ret
    end
    
    ret = RR_RecurseLightning(p1, p2, ret)                                  --Start recursion
    return ret
end
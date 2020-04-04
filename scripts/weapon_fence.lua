--Science weapon that deploys a fence spawn.
Weap_RR_Science_Deploy_Fence = Weap_RR_Base_Transporter:new{
    Name = "Electric Fence",
    Description = "Teleport in an electric fence that chains damage through adjacent targets.",
    Class = "Science",
    Icon = "weapons/weapon_fence.png",
    Deployed = "pawn_spawn_fence",
    PowerCost = 1,
    Upgrades = 2,
    UpgradeCost = { 2, 2 },
    UpgradeList = { "Ally Immune", "+1 Use" },
    Limited = 1,
    TipImage = {
        Unit = Point(2,4),
        Target = Point(2,2),
        Enemy = Point(1,1),
        Enemy2 = Point(2,1),
        Enemy3 = Point(3,1),
        Second_Origin = Point(2,2),
        Second_Target = Point(2,1)
    }
}

--More zappy damage
Weap_RR_Science_Deploy_Fence_A = Weap_RR_Science_Deploy_Fence:new{
    UpgradeDescription = "Friendly units will not take damage from fence lightning.",
    Deployed = "pawn_spawn_fence2",
    TipImage = {
        Unit = Point(2,4),
        Target = Point(2,2),
        Enemy = Point(1,1),
        Friendly = Point(2,1),
        Enemy3 = Point(3,1),
        Second_Origin = Point(2,2),
        Second_Target = Point(2,1)
    }
}

--More zappy damage (for less!)
Weap_RR_Science_Deploy_Fence_B = Weap_RR_Science_Deploy_Fence:new{
    UpgradeDescription = "Increases uses per battle by 1.",
    Limited = 2,
    TipImage = {
        Unit = Point(1,2),
        Target = Point(3,2),
        CustomPawn = "pawn_spawn_fence"
    }
}

--Even more zappy damage!
Weap_RR_Science_Deploy_Fence_AB = Weap_RR_Science_Deploy_Fence:new{
    Deployed = "pawn_spawn_fence2",
    Limited = 2
}

--Generic weapon used by Electric Fence spawn
Weap_RR_Spawn_Lightning = Skill:new{
    Name = "Lightning",
    Class = "Unique",
    Description = "Chain damage through adjacent targets.",
    LaunchSound = "/weapons/electric_whip",
    Icon = "weapons/weapon_fence_effect.png",
    FriendlyDamage = true,
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
    FriendlyDamage = false,
}

--Skill Effect for lightning attack
function Weap_RR_Spawn_Lightning:GetSkillEffect(p1, p2)
    local ret = SkillEffect()

    if not Board:IsPawnSpace(p2) then return ret end    --Don't attack empty spaces
    local past = { [p1:Hash()] = true }                 --We're not Pichu

    function RR_RecurseLightning(prev, curr, ret)       --Recursive lightning!
        past[curr:Hash()] = true                        --Mark tile as past

        local damage = SpaceDamage(curr, (
            self.FriendlyDamage or not Board:IsPawnTeam(curr, TEAM_PLAYER)) and --Ignore friendly targets
            self.Damage or                                                      --Damage
            DAMAGE_ZERO)                                                        --Damage for ignored targets

        damage.sAnimation = "Lightning_Blue_"..GetDirection(curr - prev)        --Damage Animation
        ret:AddDamage(damage)                                                   --Add Damage
                                
        for dir = DIR_START, DIR_END do                                         --Loop through adjacent tiles
            local next = curr + DIR_VECTORS[dir]                                --Adjacent tile Point
            if not past[next:Hash()] and Board:IsPawnSpace(next) then           --If tile is not past and has a pawn then
                ret = RR_RecurseLightning(curr, next, ret)                      --Recurse to adjacent tiles
            end
        end
        
        return ret
    end
    
    ret = RR_RecurseLightning(p1, p2, ret)              --Start recursion
    return ret
end
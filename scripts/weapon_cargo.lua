--Science weapon that deploys a fence spawn.
Weap_RR_Science_Deploy_Cargo = Weap_RR_Base_Transporter:new{
    Name = "Mining Equipment",
    Description = "Teleport in a temporary dynamite pack that pushes adjacent units when detonated. If boosted, also teleport in an electric fence that chains damage through adjacent targets.",
    Class = "Science",
    Icon = "weapons/weapon_fence.png",
    Deployed1 = "Pawn_RR_Spawn_Dynamite",
    Deployed2 = "Pawn_RR_Spawn_Fence",
    PowerCost = 1,
    Upgrades = 2,
    UpgradeCost = { 1, 3 },
    UpgradeList = { "Landslide!", "Ally Immune" },
    -- TipImage = {
    --     Unit = Point(2,4),
    --     Target = Point(2,2),
    --     Enemy = Point(1,1),
    --     Enemy2 = Point(2,1),
    --     Enemy3 = Point(3,1),
    --     Second_Origin = Point(2,2),
    --     Second_Target = Point(2,1)
    -- }
}

--
Weap_RR_Science_Deploy_Cargo_A = Weap_RR_Science_Deploy_Cargo:new{
    UpgradeDescription = "Dynamite destroys adjacent mountains. Destroyed mountains push adjacent tiles.",
    Deployed1 = "Pawn_RR_Spawn_Dynamite2"
}

--
Weap_RR_Science_Deploy_Cargo_B = Weap_RR_Science_Deploy_Cargo:new{
    UpgradeDescription = "Friendly units will not take damage from fence lightning.",
    Deployed2 = "Pawn_RR_Spawn_Fence2"
}

--Both upgrades combined
Weap_RR_Science_Deploy_Cargo_AB = Weap_RR_Science_Deploy_Cargo:new{
    Deployed1 = "Pawn_RR_Spawn_Dynamite2",
    Deployed2 = "Pawn_RR_Spawn_Fence2"
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
        CustomPawn = "Pawn_RR_Spawn_Fence"
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

    function RR_RecurseLightning(prev, curr, ret2)      --Recursive lightning!
        past[curr:Hash()] = true                        --Mark tile as past

        local damage = SpaceDamage(curr, (
            self.FriendlyDamage or not Board:IsPawnTeam(curr, TEAM_PLAYER)) and --Ignore friendly targets
            self.Damage or                                                      --Damage
            DAMAGE_ZERO)                                                        --Damage for ignored targets

        damage.sAnimation = "RR_Lightning_Blue_"..GetDirection(curr - prev)        --Damage Animation
        ret2:AddDamage(damage)                                                   --Add Damage

        for dir = DIR_START, DIR_END do                                         --Loop through adjacent tiles
            local next = curr + DIR_VECTORS[dir]                                --Adjacent tile Point
            if not past[next:Hash()] and Board:IsPawnSpace(next) then           --If tile is not past and has a pawn then
                ret2 = RR_RecurseLightning(curr, next, ret2)                      --Recurse to adjacent tiles
            end
        end

        return ret2
    end

    ret = RR_RecurseLightning(p1, p2, ret)              --Start recursion
    return ret
end

--Generic weapon used by Dynamite spawn, destroys self and push
Weap_RR_Spawn_Dynamite = Skill:new{
    Name = "Detonate",
    Class = "Unique",
    Description = "Detonate and push adjacent tiles.",
    LaunchSound = "/props/exploding_mine",
    Icon = "weapons/weapon_dynamite_effect.png",
    Ordered = true,
    ALandslideHasOccured = false,
    TipImage = {
        Unit = Point(2,2),
        Target = Point(3,2),
        Enemy = Point(3,2),
        Enemy2 = Point(1,2),
        Enemy3 = Point(2,3),
        Enemy4 = Point(2,1),
        CustomPawn = "Pawn_RR_Spawn_Dynamite"
    }
}

--A LANDSLIDE HAS OCCURRED 
Weap_RR_Spawn_Dynamite2 = Weap_RR_Spawn_Dynamite:new{
    Description = "Detonate and destroy adjacent mountains, pushing all adjacent tiles.",
    ALandslideHasOccured = true,                --A LANDSLIDE HAS OCCURRED
    TipImage = {                                --A LANDSLIDE HAS OCCURRED
        Unit = Point(2,2),                      --A LANDSLIDE HAS OCCURRED
        Mountain = Point(2,1),                  --A LANDSLIDE HAS OCCURRED
        Target = Point(2,1),                    --A LANDSLIDE HAS OCCURRED
        Enemy = Point(1,1),                     --A LANDSLIDE HAS OCCURRED
        Enemy2 = Point(3,1),                    --A LANDSLIDE HAS OCCURRED
        Enemy3 = Point(1,2),                    --A LANDSLIDE HAS OCCURRED
        Enemy4 = Point(3,2),                    --A LANDSLIDE HAS OCCURRED
        Enemy5 = Point(2,3),                    --A LANDSLIDE HAS OCCURRED
        CustomPawn = "Pawn_RR_Spawn_Dynamite2"  --A LANDSLIDE HAS OCCURRED
    }
}

--Dynamite trigger is on itself to simplify firing from hook
function Weap_RR_Spawn_Dynamite:GetTargetArea(p1)
    local ret = PointList()
    ret:push_back(p1)
    for dir = DIR_START, DIR_END do
        ret:push_back(p1 + DIR_VECTORS[dir])
    end
    return ret
end

--Skill Effect for self destruction and push
function Weap_RR_Spawn_Dynamite:GetSkillEffect(p1, p2)
    local ret = SkillEffect()

    for dir = DIR_START, DIR_END do                     --Loop through surrounding tiles
        local target = p1 + DIR_VECTORS[dir]
        local damage = SpaceDamage(target, 0)           --Damage surrounding tiles

        if self.ALandslideHasOccured and RR_IsMountain(target) then                 --A LANDSLIDE HAS OCCURRED

            ret:AddDamage(SpaceDamage(target, DAMAGE_DEATH))                        --A LANDSLIDE HAS OCCURRED

            for dir2 = dir + DIR_START - 1, dir + DIR_END - 2 do                    --A LANDSLIDE HAS OCCURRED
                dir2 = dir2 % 4                                                     --A LANDSLIDE HAS OCCURRED
                local damage2 = SpaceDamage(target + DIR_VECTORS[dir2], 0, dir2)    --A LANDSLIDE HAS OCCURRED
                damage2.sAnimation = "airpush_"..(dir2 % 4)                         --A LANDSLIDE HAS OCCURRED
                ret:AddDamage(damage2)                                              --A LANDSLIDE HAS OCCURRED
            end                                                                     --A LANDSLIDE HAS OCCURRED
        else
            damage.iPush = dir                          --Push
            damage.sAnimation = "airpush_"..(dir % 4)   --Damage
        end

        ret:AddDamage(damage)                           --Damage
    end

    local damageSelf = SpaceDamage(p1, DAMAGE_DEATH)    --Dynamite goes kaboom
    damageSelf.sAnimation = "ExploArt3"                 --Here's the kaboom
    ret:AddDamage(damageSelf)                           --YES YES YES EXPLODE YES

    return ret
end
--Science weapon that deploys a dynamite spawn.
Weap_RR_Science_Deploy_Dynamite = Weap_RR_Base_Transporter:new{
    Name = "Dynamite",
    Description = "Teleport in an explosive that will detonate before enemies emerge, pushing adjacent tiles.",
    Class = "Science",
    Icon = "weapons/weapon_dynamite.png",
    Deployed = "Pawn_RR_Spawn_Dynamite",
    PowerCost = 1,
    Upgrades = 1,
    UpgradeCost = { 1 },
    UpgradeList = { "Landslide!" },
    TipImage = {
        Unit = Point(2,4),
        Target = Point(2,2),
        Enemy = Point(3,2),
        Enemy2 = Point(1,2),
        Enemy3 = Point(2,3),
        Enemy4 = Point(2,1),
        Second_Origin = Point(2,2),
        Second_Target = Point(3,2)
    },
}

--A LANDSLIDE HAS OCCURRED 
Weap_RR_Science_Deploy_Dynamite_A = Weap_RR_Science_Deploy_Dynamite:new{                                         --A LANDSLIDE HAS OCCURRED
    UpgradeDescription = "Detonating destroys adjacent mountains. Destroyed mountains push adjacent tiles.",     --A LANDSLIDE HAS OCCURRED
    Deployed = "Pawn_RR_Spawn_Dynamite2",                                                                           --A LANDSLIDE HAS OCCURRED
    TipImage = {                    --A LANDSLIDE HAS OCCURRED
        Unit = Point(2,4),          --A LANDSLIDE HAS OCCURRED
        Mountain = Point(2,1),      --A LANDSLIDE HAS OCCURRED
        Target = Point(2,2),        --A LANDSLIDE HAS OCCURRED
        Enemy = Point(1,1),         --A LANDSLIDE HAS OCCURRED
        Enemy2 = Point(3,1),        --A LANDSLIDE HAS OCCURRED
        Enemy3 = Point(1,2),        --A LANDSLIDE HAS OCCURRED
        Enemy4 = Point(3,2),        --A LANDSLIDE HAS OCCURRED
        Enemy5 = Point(2,3),        --A LANDSLIDE HAS OCCURRED
        Second_Origin = Point(2,2), --A LANDSLIDE HAS OCCURRED
        Second_Target = Point(2,1)  --A LANDSLIDE HAS OCCURRED
    }
}

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
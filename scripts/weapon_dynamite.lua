--Science weapon that deploys a dynamite spawn.
Weap_RR_Science_Deploy_Dynamite = Weap_RR_Base_Transporter:new{
    Name = "Dynamite Charge",
    Description = "Teleport in an explosive that detonates when triggered or destroyed, pushing adjacent tiles.",
    Class = "Science",
    Icon = "weapons/weapon3.png",
    Deployed = "pawn_spawn_dynamite",
    PowerCost = 1,
    Upgrades = 2,
    UpgradeCost = { 1, 1 },
    UpgradeList = { "Landslide!", "+1 Use" },
    Limited = 2,
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
Weap_RR_Science_Deploy_Dynamite_A = Weap_RR_Science_Deploy_Dynamite:new{                                                        --A LANDSLIDE HAS OCCURRED
    UpgradeDescription = "Dynamite destroys adjacent mountains when it explodes. Destroyed mountains push adjacent enemies.",   --A LANDSLIDE HAS OCCURRED
    Deployed = "pawn_spawn_dynamite2",                                                                                          --A LANDSLIDE HAS OCCURRED
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

--Unlimited Uses
Weap_RR_Science_Deploy_Dynamite_B = Weap_RR_Science_Deploy_Dynamite:new{
    UpgradeDescription = "Increases uses per battle by 1.",
	Limited = 3
}

--Both upgrades combined
Weap_RR_Science_Deploy_Dynamite_AB = Weap_RR_Science_Deploy_Dynamite:new{
    Deployed = "pawn_spawn_dynamite2",        --A LANDSLIDE HAS OCCURRED
	Limited = 3
}

--Generic weapon used by Dynamite spawn, destroys self and push
Weap_RR_Spawn_Dynamite = Skill:new{
    LaunchSound = "/weapons/mercury_fist",
    Icon = "weapons/prime_smash.png",
    PathSize = 1,
    Damage = 1,
    ALandslideHasOccured = false
}

--A LANDSLIDE HAS OCCURRED 
Weap_RR_Spawn_Dynamite2 = Weap_RR_Spawn_Dynamite:new{   --A LANDSLIDE HAS OCCURRED
    ALandslideHasOccured = true                         --A LANDSLIDE HAS OCCURRED
}                                                       --A LANDSLIDE HAS OCCURRED

--If terrain is mountain
local function RR_IsMountain(point)
	return	Board:GetTerrain(point) == TERRAIN_MOUNTAIN
end

--Skill Effect for self destruction and push
function Weap_RR_Spawn_Dynamite:GetSkillEffect(p1, p2)
    local ret = SkillEffect()

    for dir = DIR_START, DIR_END do                     --Loop through surrounding tiles
        local target = p1 + DIR_VECTORS[dir]
        local damage = SpaceDamage(target, 0)           --Damage surrounding tiles

        if self.ALandslideHasOccured and RR_IsMountain(target) then                 --A LANDSLIDE HAS OCCURRED
            LOG('A LANDSLIDE HAS OCCURRED')                                         --A LANDSLIDE HAS OCCURRED
                                                                                    --A LANDSLIDE HAS OCCURRED
            ret:AddDamage(SpaceDamage(target, DAMAGE_DEATH))                        --A LANDSLIDE HAS OCCURRED
                                                                                    --A LANDSLIDE HAS OCCURRED
            for dir2 = DIR_START, DIR_END do                                        --A LANDSLIDE HAS OCCURRED
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
--Science weapon that deploys a fence spawn.
weap_science_deploy_fence = Deployable:new{
    Name = "Electric Fence",
    Class = "Science",
    Description = "Teleport in a stationary Electric fence that deals chain damage through adjacent units.",
    Icon = "weapons/weapon3.png",
    Deployed = "pawn_spawn_fence",
    Projectile = "effects/shotup_tank.png",
    PowerCost = 1,
    LaunchSound = "/weapons/deploy_tank",
    ImpactSound = "/impact/generic/mech",
    Limited = 2,
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

--Generic weapon used by Electric Fence spawn
weap_spawn_lightning = Skill:new{
    LaunchSound = "/weapons/electric_whip",
    Icon = "weapons/prime_lightning.png",
    Damage = 1
}

--Skill Effect for lightning attack
function weap_spawn_lightning:GetSkillEffect(p1, p2)
    local ret = SkillEffect()
    local hash = function(point) return point.x + point.y * 8 end           -- Hash Point into an int for indexing
    local past = { [hash(p1)] = true }                                      -- We're not Pichu

    function recurseLightning(prev, curr, ret)
        past[hash(curr)] = true                                             -- Mark tile as past

        local damage = SpaceDamage(curr, self.Damage)                       -- Damage adjacent tiles
        damage.sAnimation = "Lightning_Attack_"..GetDirection(curr - prev)  -- Damage
        ret:AddDamage(damage)                                               -- Damage

        for dir = DIR_START, DIR_END do                                     -- Loop through adjacent tiles
            local next = curr + DIR_VECTORS[dir]                            -- Adjacent tile Point
            if not past[hash(next)] and Board:IsPawnSpace(next) then        -- If tile is not past and has a pawn then
                ret = recurseLightning(curr, next, ret)                     -- Recurse to adjacent tiles
            end
        end
        
        return ret
    end
    
    ret = recurseLightning(p1, p2, ret)                                     -- Start recursion
    return ret
end
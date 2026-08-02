--Science weapon that deploys a fence spawn.
Weap_RR_Science_Deploy_Cargo = Weap_RR_Base_Transporter:new{
    Name = "Mining Equipment",
    Description = "Deploy a dynamite pack. If placed over an energy crystal, upgrade it to an electric fence.",
    Class = "Science",
    Icon = "weapons/rr_weapon_cargo.png",
    Deployed1 = "Pawn_RR_Spawn_Dynamite",
    Deployed2 = "Pawn_RR_Spawn_Fence",
    PowerCost = 1,
    Upgrades = 2,
    UpgradeCost = { 1, 2 },
    UpgradeList = { "Landslide!", "+1 Damage" },
    CustomTipImage = "Weap_RR_Science_Deploy_Cargo_Tip",
    TipImage = {
        Unit = Point(2,3),
        Target = Point(1,2),
        Second_Origin = Point(2,3),
        Second_Target = Point(1,1),
        Enemy = Point(2,2),
        Enemy2 = Point(2,1),
        Enemy3 = Point(3,1)
    }
}

--Dynamite cargo upgrade
Weap_RR_Science_Deploy_Cargo_A = Weap_RR_Science_Deploy_Cargo:new{
    UpgradeDescription = "Dynamite destroys adjacent mountains, revealing an energy crystal.",
    Deployed1 = "Pawn_RR_Spawn_Dynamite2",
    CustomTipImage = "Weap_RR_Science_Deploy_Cargo_Tip_A",
    TipImage = {                    --A LANDSLIDE HAS OCCURRED
        Unit = Point(2,4),          --A LANDSLIDE HAS OCCURRED
        Mountain = Point(2,1),      --A LANDSLIDE HAS OCCURRED
        Target = Point(2,2),        --A LANDSLIDE HAS OCCURRED
        Enemy3 = Point(1,2),        --A LANDSLIDE HAS OCCURRED
        Enemy4 = Point(3,2),        --A LANDSLIDE HAS OCCURRED
        Enemy5 = Point(2,3),        --A LANDSLIDE HAS OCCURRED
        Second_Origin = Point(2,2), --A LANDSLIDE HAS OCCURRED
        Second_Target = Point(2,1)  --A LANDSLIDE HAS OCCURRED
    }
}

--Fence cargo upgrade
Weap_RR_Science_Deploy_Cargo_B = Weap_RR_Science_Deploy_Cargo:new{
    UpgradeDescription = "Increases electric fence damage by 1.",
    Deployed2 = "Pawn_RR_Spawn_Fence2",
    CustomTipImage = "Weap_RR_Science_Deploy_Cargo_Tip_B",
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

--Both upgrades combined
Weap_RR_Science_Deploy_Cargo_AB = Weap_RR_Science_Deploy_Cargo:new{
    Deployed1 = "Pawn_RR_Spawn_Dynamite2",
    Deployed2 = "Pawn_RR_Spawn_Fence2"
}

--Tip images
Weap_RR_Science_Deploy_Cargo_Tip = Weap_RR_Science_Deploy_Cargo:new{}
Weap_RR_Science_Deploy_Cargo_Tip_A = Weap_RR_Science_Deploy_Cargo_A:new{}
Weap_RR_Science_Deploy_Cargo_Tip_B = Weap_RR_Science_Deploy_Cargo_B:new{}
Weap_RR_Science_Deploy_Cargo_Tip_AB = Weap_RR_Science_Deploy_Cargo_AB:new{}

--Custom tip image to start with a crystal, and spawn and trigger Dynamite and Fence
function Weap_RR_Science_Deploy_Cargo_Tip:GetSkillEffect(p1, p2)
    Board:SetItem(Point(1,1), "Item_RR_Crystal_Mine")   --Crystal in TipImage
	local ret = SkillEffect()

    local isDynamite = p2.y == 2                        --Dynamite goes here

    --Damage that sets spawn
    local spawn1 = SpaceDamage(p2, 0)   --Damage
    spawn1.sPawn = isDynamite and self.Deployed1 or self.Deployed2
	ret:AddDamage(spawn1)               --Add damage
    RR_HiddenTeleport(ret, p2)          --Teleport effect

    ret:AddDelay(1)

    --Damage that activates spawn
    ret = (
        isDynamite and
        Weap_RR_Spawn_Dynamite:GetSkillEffect(p2, p2, ret) or
        Weap_RR_Spawn_Lightning:GetSkillEffect(p2, Point(2,1), ret))

    ret:AddDelay(1)

	return ret
end

--Custom tip image to start with a crystal, and spawn a Fence
function Weap_RR_Science_Deploy_Cargo_Tip_B:GetSkillEffect(p1, p2)
    Board:SetItem(Point(2,2), "Item_RR_Crystal_Mine")   --Crystal in TipImage
	local ret = SkillEffect()

    --Damage that sets spawn
    local spawn1 = SpaceDamage(p2, 0)   --Damage
    spawn1.sPawn = self.Deployed2
	ret:AddDamage(spawn1)               --Add damage
    RR_HiddenTeleport(ret, p2)          --Teleport effect

	return ret
end

--Generic weapon used by Electric Fence spawn
Weap_RR_Spawn_Lightning = Skill:new{
    Name = "Lightning",
    Class = "Unique",
    Description = "Chain damage through adjacent targets.",
    LaunchSound = "/weapons/electric_whip",
    Icon = "weapons/rr_weapon_fence_effect.png",
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
    Damage = 3
}

--Achievement
local function RR_Check_Ach3(effect, p)
	--spawn rock via script so the preview doesn't know about it
	effect:AddScript([[
        local target = Board:GetPawn(Point(]].. p.x ..",".. p.y ..[[))

        if target ~= nil and target:GetType():find("^Pawn_RR_Spawn_Fence") ~= nil then 
            RR_CheckAch3Trigger()
        end
	]])
end

--Skill Effect for lightning attack
function Weap_RR_Spawn_Lightning:GetSkillEffect(p1, p2, ese)
	local ret = ese or SkillEffect()

    if not Board:IsPawnSpace(p2) then return ret end    --Don't attack empty spaces
    local past = { [p1:Hash()] = true }                 --We're not Pichu

    function RR_RecurseLightning(prev, curr, ret2)      --Recursive lightning!
        past[curr:Hash()] = true                        --Mark tile as past

        RR_Check_Ach3(ret2, curr)

        local damage = SpaceDamage(curr, self.Damage)

        damage.sAnimation = "RR_Lightning_Blue_"..GetDirection(curr - prev)     --Damage Animation
        ret2:AddDamage(damage)                                                  --Add Damage

        for dir = DIR_START, DIR_END do                                         --Loop through adjacent tiles
            local next = curr + DIR_VECTORS[dir]                                --Adjacent tile Point
            if not past[next:Hash()] and Board:IsPawnSpace(next) then           --If tile is not past and has a pawn then
                ret2 = RR_RecurseLightning(curr, next, ret2)                    --Recurse to adjacent tiles
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
    Icon = "weapons/rr_weapon_dynamite_effect.png",
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
    Description = "Detonate and destroy adjacent mountains, revealing an energy crystal.",
    ALandslideHasOccured = true,                --A LANDSLIDE HAS OCCURRED
    TipImage = {                                --A LANDSLIDE HAS OCCURRED
        Unit = Point(2,2),                      --A LANDSLIDE HAS OCCURRED
        Mountain = Point(2,1),                  --A LANDSLIDE HAS OCCURRED
        Target = Point(2,1),                    --A LANDSLIDE HAS OCCURRED
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
function Weap_RR_Spawn_Dynamite:GetSkillEffect(p1, p2, ese)
	local ret = ese or SkillEffect()

    for dir = DIR_START, DIR_END do                             --Loop through surrounding tiles
        local target = p1 + DIR_VECTORS[dir]

        --A LANDSLIDE HAS OCCURRED
        if self.ALandslideHasOccured and RR_IsMountain(target) then
            local damage = SpaceDamage(target, DAMAGE_DEATH)    --A LANDSLIDE HAS OCCURRED
            damage.sItem = "Item_RR_Crystal_Mine"               --A LANDSLIDE HAS OCCURRED
            ret:AddDamage(damage)
        else
            local damage = SpaceDamage(target, 0)               --Damage surrounding tiles
            damage.iPush = dir                                  --Push
            damage.sAnimation = "airpush_"..(dir % 4)           --Damage
            ret:AddDamage(damage)                               --Damage
        end
    end

    local damageSelf = SpaceDamage(p1, DAMAGE_DEATH)            --Dynamite goes kaboom
    damageSelf.sAnimation = "ExploArt3"                         --Here's the kaboom
    ret:AddDamage(damageSelf)                                   --YES YES YES EXPLODE YES

    if(Board:IsTipImage()) then                                 --Tip Image delay
        ret:AddDelay(4.0)
    end

    return ret
end
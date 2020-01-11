--Shovel that spawns and pushes a rock
Weap_RR_Brute_Shovel = Skill:new{
    Name = "Mining Scoop",
    Description = "Charge and place a rock, or charge into an enemy, damaging and pushing it.",
    Class = "Brute",
    Icon = "weapons/weapon2.png",
    Damage = 1,
    PowerCost = 1,
    CreateSound = "/enemy/digger_1/attack_queued",
    ChargeSound = "/weapons/charge",
    DamageAnimation = "ExploAir2",
    DamageMarker = "units/aliens/rock_1.png",
    TipImage = {
        Unit = Point(2, 4),
        Enemy = Point(2, 1),
        Target = Point(2, 1)
    }
}

-- Spawn a rock without a preview
local function RR_HiddenRock(effect, p)
	-- spawn rock via script so the preview doesn't know about it
	effect:AddScript([[
		local effect = SkillEffect()
        local damage = SpaceDamage(Point(]].. p.x ..",".. p.y ..[[), 0)
        damage.sPawn = "Wall"
        effect:AddDamage(damage)
		Board:AddEffect(effect)
	]])
end

-- Skill Effect that creates and charges self and a rock
function Weap_RR_Brute_Shovel:GetSkillEffect(p1, p2)
    local ret = SkillEffect()
    local targeting = Board:IsBlocked(p2, PATH_FLYER)   --If we are targeting something, a non-empty tile
    local direction = GetDirection(p2 - p1)             --The direction we are travelling in
    local useMelee = p1:Manhattan(p2) == 1

    local bruteFinal = p2 - DIR_VECTORS[direction]      --The landing location of this mech
    local spawnStart = p1 + DIR_VECTORS[direction]      --The starting location of the rock
    
    if useMelee or not targeting then
        create = SpaceDamage(p2, 0)                     --Melee effect for creating a rock or attacking a unit
        --create.sSound = self.CreateSound
        ret:AddMelee(p1, create)
    end

    if not targeting then
        RR_HiddenRock(ret, spawnStart)                  --Spawn a rock without previewing it
        ret:AddDelay(useMelee and 0.05 or 0.25)         --Timing is off without this delay
    end

    if not useMelee then
        ret:AddSound(self.ChargeSound)
        ret:AddCharge(Board:GetSimplePath(p1, bruteFinal), NO_DELAY)    --Shovel charge
    end

    if not targeting then
        ret:AddCharge(Board:GetSimplePath(spawnStart, p2), NO_DELAY)    --Rock charge
    end

    local temp = p1                             --Add bounce effects like charge mech
    while temp ~= p2  do
        ret:AddBounce(temp, 2)
        temp = temp + DIR_VECTORS[direction]
        if temp ~= p2 then
            ret:AddDelay(0.06)
        end
    end
    
    local damage = SpaceDamage(p2, 0)           --Will either be a Damage & Push or a rock spawn indicator
    if targeting then                           --Damage unit if targeting
        damage.iPush = direction                --Damage
        damage.iDamage = self.Damage            --Damage
        damage.sAnimation = self.DamageAnimation
    else                                        --Indicate rock spawn if not targeting
        damage.sImageMark = self.DamageMarker
    end
    ret:AddDamage(damage)                       --Damage

    return ret
end

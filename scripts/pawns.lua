local mod = mod_loader.mods[modApi.currentMod]
local imageOffset = modApi:getPaletteImageOffset(mod.id)

Pawn_RR_Mech_Drill = Pawn:new {
    Name = "Drill Mech",
    Class = "Prime",
    Health = 3,
    MoveSpeed = 3,
    Image = "rr_mech_drill",
    ImageOffset = imageOffset,
    SkillList = { "Weap_RR_Prime_Drill", "Pass_RR_Generic_Fossilizer" },
    SoundLocation = "/mech/prime/punch_mech/",
    DefaultTeam = TEAM_PLAYER,
    ImpactMaterial = IMPACT_METAL,
    Massive = true
}

Pawn_RR_Mech_Loader = Pawn:new {
    Name = "Loader Mech",
    Class = "Brute",
    Health = 3,
    MoveSpeed = 3,
    Image = "rr_mech_loader",
    ImageOffset = imageOffset,
    SkillList = { "Weap_RR_Brute_Shovel", "Pass_RR_Generic_Fossilizer" },
    SoundLocation = "/mech/brute/tank/",
    DefaultTeam = TEAM_PLAYER,
    ImpactMaterial = IMPACT_METAL,
    Massive = true
}

Pawn_RR_Mech_Transport = Pawn:new {
    Name = "Transport Mech",
    Class = "Science",
    Health = 3,
    MoveSpeed = 2,
    Image = "rr_mech_transport",
    ImageOffset = imageOffset,
    SkillList = { "Weap_RR_Science_Deploy_Cargo", "Pass_RR_Generic_Fossilizer" },
	SoundLocation = "/mech/flying/jet_mech/",
    Flying = true,
    DefaultTeam = TEAM_PLAYER,
    ImpactMaterial = IMPACT_METAL,
    Massive = true
}

Pawn_RR_Mech_Crusher = Pawn:new {
    Name = "Crusher Mech",
    Class = "Brute",
    Health = 3,
    MoveSpeed = 2,
    Image = "rr_mech_crusher",
    ImageOffset = imageOffset,
    SkillList = { "Weap_RR_Prime_Crush", "Pass_RR_Generic_Fossilizer" },
    SoundLocation = "/mech/brute/tank/",
    DefaultTeam = TEAM_PLAYER,
    ImpactMaterial = IMPACT_METAL,
    Massive = true
}

Pawn_RR_Spawn_Fence = Pawn:new{
    Name = "Electric Fence",
    Health = 1,
    MoveSpeed = 0,
    Image = "rr_spawn_fence",
    SkillList = { "Weap_RR_Spawn_Lightning" },
	SoundLocation = "/support/earthmover",
    DefaultTeam = TEAM_PLAYER,
    ImpactMaterial = IMPACT_METAL,
	Pushable = false,
    Corpse = false
}

Pawn_RR_Spawn_Fence2 = Pawn_RR_Spawn_Fence:new{
    SkillList = { "Weap_RR_Spawn_Lightning2" }
}

Pawn_RR_Spawn_Dynamite = Pawn:new{
    Name = "Dynamite",
    Health = 1,
    MoveSpeed = 0,
    Image = "rr_spawn_dynamite",
    SkillList = { "Weap_RR_Spawn_Dynamite" },
	SoundLocation = "/support/earthmover",
    DefaultTeam = TEAM_PLAYER,
    ImpactMaterial = IMPACT_METAL,
    Corpse = false
}

Pawn_RR_Spawn_Dynamite2 = Pawn_RR_Spawn_Dynamite:new{
    SkillList = { "Weap_RR_Spawn_Dynamite2" }   --A LANDSLIDE HAS OCCURRED
}
Pawn_RR_Mech_Drill = Pawn:new {
    Name = "Drill Mech",
    Class = "Prime",
    Health = 3,
    MoveSpeed = 3,
    Image = "Drill Mech",
    ImageOffset = FURL_COLORS.colorsRockRaider,
    SkillList = { "Weap_RR_Prime_Drill" }, -- 
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
    Image = "Loader Mech",
    ImageOffset = FURL_COLORS.colorsRockRaider,
    SkillList = { "Weap_RR_Brute_Shovel", "Pass_RR_Generic_Fossilizer" },
    SoundLocation = "/mech/brute/tank/",
    DefaultTeam = TEAM_PLAYER,
    ImpactMaterial = IMPACT_METAL,
    Massive = true,
}

Pawn_RR_Mech_Transport = Pawn:new {
    Name = "Transport Mech",
    Class = "Science",
    Health = 2,
    MoveSpeed = 3,
    Image = "Transport Mech",
    ImageOffset = FURL_COLORS.colorsRockRaider,
    SkillList = { "Weap_RR_Science_Deploy_Fence", "Weap_RR_Science_Deploy_Dynamite" },
	SoundLocation = "/mech/flying/jet_mech/",
    Flying = true,
    DefaultTeam = TEAM_PLAYER,
    ImpactMaterial = IMPACT_METAL,
    Massive = true
}

pawn_spawn_fence = Pawn:new{
    Name = "Electric Fence",
    Health = 1,
    MoveSpeed = 0,
    Image = "Electric Fence",
    SkillList = { "Weap_RR_Spawn_Lightning" },
	SoundLocation = "/support/earthmover",
    DefaultTeam = TEAM_PLAYER,
    ImpactMaterial = IMPACT_METAL,
	Pushable = false,
    Corpse = false,
}

pawn_spawn_fence2 = pawn_spawn_fence:new{
    SkillList = { "Weap_RR_Spawn_Lightning2" }
}

pawn_spawn_dynamite = Pawn:new{
    Name = "Dynamite",
    Health = 1,
    MoveSpeed = 0,
    Image = "Dynamite",
    SkillList = { "Weap_RR_Spawn_Dynamite" },
	SoundLocation = "/support/earthmover",
    DefaultTeam = TEAM_PLAYER,
    ImpactMaterial = IMPACT_METAL,
    Corpse = false,
}

pawn_spawn_dynamite2 = pawn_spawn_dynamite:new{
    SkillList = { "Weap_RR_Spawn_Dynamite2" }   --A LANDSLIDE HAS OCCURRED
}
pawn_mech_drill = Pawn:new {
    Name = "Drill Mech",
    Class = "Prime",
    Health = 2,
    MoveSpeed = 3,
    Armor = true,
    Image = "Drill Mech",
    ImageOffset = FURL_COLORS.colorsRockRaider,
    SkillList = { "weap_prime_drill" }, --  
    SoundLocation = "/mech/prime/punch_mech/",
    DefaultTeam = TEAM_PLAYER,
    ImpactMaterial = IMPACT_METAL,
    Massive = true
}

pawn_mech_loader = Pawn:new {
    Name = "Loader Mech",
    Class = "Brute",
    Health = 2,
    MoveSpeed = 3,
    Armor = true,
    Image = "Loader Mech",
    ImageOffset = FURL_COLORS.colorsRockRaider,
    SkillList = { "weap_brute_shovel", "pass_generic_fossilizer" },
    SoundLocation = "/mech/brute/tank/",
    DefaultTeam = TEAM_PLAYER,
    ImpactMaterial = IMPACT_METAL,
    Massive = true,
}

pawn_mech_transport = Pawn:new {
    Name = "Transport Mech",
    Class = "Science",
    Health = 2,
    MoveSpeed = 3,
    Image = "Transport Mech",
    ImageOffset = FURL_COLORS.colorsRockRaider,
    SkillList = { "weap_science_deploy_fence", "weap_science_deploy_dynamite" },
    SoundLocation = "/mech/distance/artillery/",
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
    SkillList = { "weap_spawn_lightning" },
    SoundLocation = "/mech/prime/punch_mech/",
    ImageOffset = FURL_COLORS.colorsRockRaider,
    DefaultTeam = TEAM_PLAYER,
    ImpactMaterial = IMPACT_METAL,
    Corpse = false,
}

pawn_spawn_dynamite = Pawn:new{
    Name = "Dynamite Charge",
    Health = 1,
    MoveSpeed = 0,
    Image = "Dynamite",
    SkillList = { "weap_spawn_dynamite" },
    SoundLocation = "/mech/prime/punch_mech/",
    ImageOffset = FURL_COLORS.colorsRockRaider,
    DefaultTeam = TEAM_PLAYER,
    ImpactMaterial = IMPACT_METAL,
    Corpse = false,
}

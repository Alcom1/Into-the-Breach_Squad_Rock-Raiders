--LEGO Rock Raiders Mech Squad
--Inspired by the LEGO Rock Raiders LEGO theme and PC game.

--Credits (Original Edition) :
--Alex/Alcom Isst :     Design, scripting, and intial sprites
--Salt Potato :         Mech animations, shadows, and auxiliary sprites
--Lemonymous :          Initial Passive script, Trait library
--,̶'̶,̶|̶'̶,̶'̶_̶   :          Playtesting

--Credits (Advanced Edition) :
--Alexandria/Alcom :    Lead developer
--Rachel :              <3

--And Thank you to the rest of the ItB Community!

--Mod
local mod = {
    id = "squad_rock_raiders_ae",
    name = "Rock Raiders",
    version = "2.00",
    icon = "img/icons/mod_icon.png",
    icon_squad = "img/icons/squad_icon.png",
    requirements = {},
	dependencies = {
        memedit = "1.0.4",
        modApiExt = "1.2"
    }
}

--Mod Metadata with options
function mod:metadata()
	modApi:addGenerationOption(
        "option_rr_green", 
        "Use Green Crystals", 
        "Use classic green for energy crystals instead of purple.", 
        {enabled = false})

	modApi:addGenerationOption(
        "option_rr_squad",
        "Squad Composition",
        "The 3 Mechs for Rock Raiders that are picked from the 4 available.",
        {
            values = { "no_d", "no_l", "no_c", "no_t" },
            strings = { "No Drill Mech", "No Loader Mech", "No Crusher Mech", "No Transport Mech" },
            tooltips = {
                "Loader, Crusher, and Transport Mechs", 
                "Drill, Crusher, and Transport Mechs", 
                "Drill, Loader, and Transport Mechs", 
                "Drill, Loader, and Crusher Mechs" },
            value = "no_c"
        })
end

--Initialize mod
function mod:init()

    modApi:appendMechAssets("img/units/player", "rr_")
    modApi:appendWeaponAssets("img/weapons",    "rr_")
    modApi:appendCombatAssets("img/combat",     "rr_")

    --mech sprites
    local mechSprites = {
        --Drill Mech
        rr_mech_drill =                 { PosX = -22, PosY = -7 },
        rr_mech_drill_ns =              { },
        rr_mech_drill_a =               { PosX = -22, PosY = -7, NumFrames = 8, Time = 0.20 },
        rr_mech_drill_broken =          { PosX = -22, PosY = -7 },
        rr_mech_drill_w =               { PosX = -23, PosY =  4 },
        rr_mech_drill_w_broken =        { PosX = -23, PosY =  4 },

        --Loader Mech
        rr_mech_loader =                { PosX = -24, PosY = -3 },
        rr_mech_loader_ns =             { },
        rr_mech_loader_a =              { PosX = -24, PosY = -3, NumFrames = 4 },
        rr_mech_loader_broken =         { PosX = -24, PosY = -3 },
        rr_mech_loader_w =              { PosX = -23, PosY =  5 },
        rr_mech_loader_w_broken =       { PosX = -23, PosY =  5 },

        --Transport Mech
        rr_mech_transport =             { PosX = -25, PosY = -17 },
        rr_mech_transport_ns =          { },
        rr_mech_transport_a =           { PosX = -25, PosY = -17, NumFrames = 16, Time = 0.15 },
        rr_mech_transport_broken =      { PosX = -25, PosY =  -7 },
        rr_mech_transport_w_broken =    { PosX = -25, PosY =  -4 },

        --Crusher Mech
        rr_mech_crusher =               { PosX = -25, PosY = -3 },
        rr_mech_crusher_ns =            { },
        rr_mech_crusher_a =             { PosX = -25, PosY = -3, NumFrames = 8, Time = 0.20 },
        rr_mech_crusher_broken =        { PosX = -25, PosY = -1 },
        rr_mech_crusher_w =             { PosX = -26, PosY =  5 },
        rr_mech_crusher_w_broken =      { PosX = -24, PosY =  8 },

        --Spawned Dynamite
        rr_spawn_dynamite =             { PosX = -10, PosY = 7 },
        rr_spawn_dynamite_ns =          { },
        rr_spawn_dynamite_a =           { PosX = -10, PosY = 7, NumFrames = 20, Time = 0.20 },
        rr_spawn_dynamite_death =       { PosX = -14, PosY = -7, NumFrames = 12, Time = 0.12, Loop = false },
        
        --Spawned Electric Fence
        rr_spawn_fence =                { PosX = -11, PosY = -20 },
        rr_spawn_fence_ns =             { },
        rr_spawn_fence_a =              { PosX = -11, PosY = -20, NumFrames = 2, Time = 1.00 },
        rr_spawn_fence_death =          { PosX = -21, PosY = -20, NumFrames = 11, Time = 0.12, Loop = false },
    }

    --Mapping file names for mech sprites
    local tagmaps = {
        {"_ns",         "_ns"},
        {"_a",          "a"},
        {"_broken",     "_broken"},
        {"_w",          "w"},
        {"_w_broken",   "w_broken"},
        {"_death",      "d"}
    }

    local animDefs = {}

    for id, mechSprite in pairs(mechSprites) do
        mechSprite.Image = "units/player/"..id..".png"

        for _, map in ipairs(tagmaps) do
            id = id:gsub(map[1].."$", map[2])
        end
        
        animDefs[id] = mechSprite
    end

    modApi:createMechAnimations(animDefs)

    --Color palette
    modApi:addPalette{
        id = mod.id,
        name = "Rock Raiders Old Gray",
        image = "img/units/player/mech_drill_ns.png",
        colorMap = {
            lights =         { 204, 204,  31 },
            main_highlight = { 110, 118, 111 },
            main_light =     {  69,  74,  70 },
            main_mid =       {  36,  41,  36 },
            main_dark =      {  14,  15,  15 },
            metal_light =    { 163, 164, 168 },
            metal_mid =      {  87,  89,  88 },
            metal_dark =     {  21,  33,  40 },
        },
    }

    --Misc sprite assets
    local generalSprites = {
        {"img/weapons/rr_weapon_crush.png",           "img/weapons/weapon_crush.png"},
        {"img/weapons/rr_weapon_drill.png",           "img/weapons/weapon_drill.png"},
        {"img/weapons/rr_weapon_scoop.png",           "img/weapons/weapon_scoop.png"},
        {"img/weapons/rr_weapon_cargo.png",           "img/weapons/weapon_cargo.png"},
        {"img/weapons/rr_weapon_fence_effect.png",    "img/weapons/weapon_fence_effect.png"},
        {"img/weapons/rr_weapon_dynamite_effect.png", "img/weapons/weapon_dynamite_effect.png"},
        {"img/weapons/rr_passive_fossilizer.png",     "img/weapons/passive_fossilizer.png"},

        {"img/combat/rr_rock_0.png",                  "img/combat/rock_0.png"},
        {"img/combat/rr_rock_1.png",                  "img/combat/rock_1.png"},
        {"img/combat/rr_rock_2.png",                  "img/combat/rock_2.png"},
        {"img/combat/rr_feather.png",                 "img/combat/feather.png"},
        {"img/combat/rr_feather2.png",                "img/combat/feather2.png"},
        {"img/combat/rr_laser_elec_blue_R.png",       "img/combat/laser_elec_blue_R.png"},
        {"img/combat/rr_laser_elec_blue_U.png",       "img/combat/laser_elec_blue_U.png"},
        {"img/combat/rr_crystal.png",                 "img/combat/crystal.png"},
        {"img/combat/rr_crystal_purp.png",            "img/combat/crystal_purp.png"},
        {"img/combat/rr_crystal_spark.png",           "img/combat/crystal_spark.png"},
        {"img/combat/rr_crystal_spark_purp.png",      "img/combat/crystal_spark_purp.png"},
        {"img/combat/rr_crystal_0.png",               "img/combat/crystal_0.png"},
        {"img/combat/rr_itemdum_dynamite.png",        "img/units/player/spawn_dynamite.png"},
        {"img/combat/rr_itemdum_fence.png",           "img/units/player/spawn_fence.png"}
    }

    for _, generalSprite in ipairs(generalSprites) do
        modApi:appendAsset(generalSprite[1], self.resourcePath..generalSprite[2])
    end

    Location["combat/rr_crystal.png"] = Point(-15, 3)
    Location["combat/rr_crystal_purp.png"] = Point(-15, 3)
    Location["combat/rr_crystal_0.png"] = Point(-15, 3)
    Location["combat/rr_rock_0.png"] = Point(-35, -13)
    Location["combat/rr_rock_1.png"] = Point(-35, -13)
    Location["combat/rr_rock_2.png"] = Point(-35, -13)
    Location["combat/rr_itemdum_dynamite.png"] = Point(-10, 7)
    Location["combat/rr_itemdum_fence.png"] = Point(-11, -20)

    --Special text
    TILE_TOOLTIPS["rr_crystal_mine"]  = {"Energy Crystal", "Any friendly mech that stops on this space will be boosted."}

    --Animation Assets
    local baseAnim = Animation:new{
        NumFrames = 1, 
        Loop = false, 
        Time = 0.5
    }

    ANIMS.RR_Lightning_Blue_0 = baseAnim:new{
        Image = "combat/rr_laser_elec_blue_U.png",
        PosX = -26,
        PosY = 13.5
    }

    ANIMS.RR_Lightning_Blue_1 = baseAnim:new{
        Image = "combat/rr_laser_elec_blue_R.png",
        PosX = -26, 
        PosY = -7.5
    }

    ANIMS.RR_Lightning_Blue_2 = baseAnim:new{
        Image = "combat/rr_laser_elec_blue_U.png",
        PosX = 2,
        PosY = -7.5
    }

    ANIMS.RR_Lightning_Blue_3 = baseAnim:new{
        Image = "combat/rr_laser_elec_blue_R.png",
        PosX = 2,
        PosY = 13.5
    }

    --Initialized Scripts
    self.passive = require(self.scriptPath.."passive")
    self.passive:init()
    self.trait = require(self.scriptPath.."libraries/trait")

    lightweightPawns = { "Pawn_RR_Spawn_Dynamite", "Pawn_RR_Spawn_Dynamite2", "Pawn_RR_Spawn_Fence", "Pawn_RR_Spawn_Fence2" }

    local traitFunc1 = function(trait, pawn)

        if Board:IsSpawning(pawn:GetSpace()) then
            return false
        end

        for _, name in ipairs(lightweightPawns) do
            if pawn:GetType() == name then
                return true
            end
        end

        return false
    end

    local traitFunc2 = function(trait, pawn)

        if not Board:IsSpawning(pawn:GetSpace()) then
            return false
        end

        for _, name in ipairs(lightweightPawns) do
            if pawn:GetType() == name then
                return true
            end
        end

        return false
    end

    self.trait:add({
        func = traitFunc1,
        icon =          "img/combat/rr_feather.png", 
        
        
        desc_title =    "Lightweight",
        desc_text =     "This unit cannot block vek from spawning (and will be destroyed instead)."
    })

    self.trait:add({
        func = traitFunc2,
        icon =          "img/combat/rr_feather.png", 
        icon_glow =     "img/combat/rr_feather2.png",
        icon_offset =   Point(-13, 10),
        desc_title =    "Lightweight",
        desc_text =     "This unit cannot block vek from spawning (and will be destroyed instead)."
    })

    --Scripts
    local scripts = {
        "libraries/achievementsExt",
        "achievements",
        "items",
        "options",
        "pawns",
        "particles",
        "point",
        "terrain",
        "weapon_crush",
        "weapon_transporter",
        "weapon_drill",
        "weapon_fossilizer",
        "weapon_shovel",
        "weapon_cargo"
    }

    for _, script in ipairs(scripts) do
        require(self.scriptPath..script)
    end

end

--Load mod
function mod:load(options, version)

    --Load initialized scripts
    self.passive:load()

    --Remove mech selected in options, so squad has only 3 members.
    local squadOptionMap = {
        no_d = 2, 
        no_l = 3, 
        no_c = 4, 
        no_t = 5}

    local squadMechs = {
        "Rock Raiders",
        "Pawn_RR_Mech_Drill", 
        "Pawn_RR_Mech_Loader", 
        "Pawn_RR_Mech_Crusher",
        "Pawn_RR_Mech_Transport",
    }

    table.remove(squadMechs, squadOptionMap[options.option_rr_squad.value])

    --Give fossilizer passive to Crusher Mech if Transport is not present. Otherwise remove it.
    if options.option_rr_squad.value == "no_t" then
        table.insert(Pawn_RR_Mech_Crusher.SkillList, "Pass_RR_Generic_Fossilizer")
    elseif #Pawn_RR_Mech_Crusher.SkillList > 1 then
        table.remove(Pawn_RR_Mech_Crusher.SkillList, #Pawn_RR_Mech_Crusher.SkillList)
    end

    --Squad
    squadMechs.id = "rr_rockraiders"
    modApi:addSquadTrue(
        squadMechs, 
        "Rock Raiders",
        "Utilizing repurposed mining equipment, these Mechs can construct a mighty bulwark against the oncoming vek hoard.",
        self.resourcePath..self.icon_squad)

end

return mod
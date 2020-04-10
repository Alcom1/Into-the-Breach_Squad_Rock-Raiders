--LEGO Rock Raiders Mech Squad
--Inspired by the LEGO Rock Raiders LEGO theme and PC game.

--Credits :
--Alex/Alcom Isst :     Design, scripting, and intial sprites
--Salt Potato :         Mech animations, shadows, and auxiliary sprites
--Lemonymous :          Initial Passive script, Trait library
--,̶'̶,̶|̶'̶,̶'̶_̶   :          Playtesting

--And Thank you to the rest of the ItB Community!

--Mod
local mod = {
    id = "squad_rock_raiders",
    name = "Rock Raiders",
    version = "0.10",
    icon = "img/icons/mod_icon.png",
    icon_squad = "img/icons/squad_icon.png",
    requirements = {}
}

--Initialize mod
function mod:init()

    --Unit Sprite Assets
    require(self.scriptPath.."FURL")(self, {
        {	
            Type = "color",
            Name = "colorsRockRaider",
            
            PlateHighlight =	{ 204, 204,  31 },	--chickenhole
            PlateLight =		{ 110, 118, 111 },	--main highlight
            PlateMid =			{  69,  74,  70 },	--main light
            PlateDark =			{  36,  41,  36 },	--main mid
            PlateOutline =		{  14,  15,  15 },	--main dark
            BodyHighlight =		{ 163, 164, 168 },	--metal light
            BodyColor =			{  87,  89,  88 },	--metal mid
            PlateShadow =		{  21,  33,  40 },	--metal dark 
        },
        {
            Type =              "mech",
            Name =              "Drill Mech",
            Filename =          "mech_drill",		
            Path =              "img/units/player",
            ResourcePath =      "units/player",

            Default =           { PosX = -22, PosY = -7 },
            Animated =          { PosX = -22, PosY = -7, NumFrames = 8, Time = 0.20},
            Broken =            { PosX = -22, PosY = -7 },
            Submerged =         { PosX = -23, PosY =  4 },
            SubmergedBroken =   { PosX = -23, PosY =  4 },
            Icon =              {},
        },
        {
            Type =              "mech",
            Name =              "Loader Mech",
            Filename =          "mech_loader",		
            Path =              "img/units/player",
            ResourcePath =      "units/player",

            Default =           { PosX = -25, PosY = -3 },
            Animated =          { PosX = -25, PosY = -3, NumFrames = 4},
            Broken =            { PosX = -25, PosY = -3 },
            Submerged =         { PosX = -23, PosY =  5 },
            SubmergedBroken =	{ PosX = -23, PosY =  5 },
            Icon =              {},
        },
        {
            Type =              "mech",
            Name =              "Transport Mech",
            Filename =          "mech_transport",
            Path =              "img/units/player",
            ResourcePath =      "units/player",

            Default =           { PosX = -25, PosY = -17 },
            Animated =          { PosX = -25, PosY = -17, NumFrames = 16, Time = 0.15},
            Broken =            { PosX = -25, PosY =  -7 },
            SubmergedBroken =	{ PosX = -25, PosY =  -4 },
            Icon =              { PosX = 0, PosY = 0 },
        },
        {
            Type =              "mech",
            Name =              "Electric Fence",
            Filename =          "spawn_fence",		
            Path =              "img/units/player",
            ResourcePath =      "units/player",

            Default =           { PosX = -11, PosY = -20 },
            Animated =          { PosX = -11, PosY = -20, NumFrames = 2, Time = 1.00 },
            Death =             { PosX = -21, PosY = -20, NumFrames = 11 },
            Icon =              {},
        },
        {
            Type =              "mech",
            Name =              "Dynamite",
            Filename =          "spawn_dynamite",		
            Path =              "img/units/player",
            ResourcePath =      "units/player",

            Default =           { PosX = -10, PosY = 7 },
            Animated =          { PosX = -10, PosY = 7, NumFrames = 20, Time = 0.20},
            Death =             { PosX = -14, PosY = -7, NumFrames = 12, Time = 0.12 },
            Icon =              {},
        }
    })

    --Sprite Assets
    modApi:appendAsset("img/weapons/weapon_drill.png",self.resourcePath.."img/weapons/weapon_drill.png")
    modApi:appendAsset("img/weapons/weapon_scoop.png",self.resourcePath.."img/weapons/weapon_scoop.png")
    modApi:appendAsset("img/weapons/weapon_fence.png",self.resourcePath.."img/weapons/weapon_fence.png")
    modApi:appendAsset("img/weapons/weapon_fence_effect.png",self.resourcePath.."img/weapons/weapon_fence_effect.png")
    modApi:appendAsset("img/weapons/weapon_dynamite.png",self.resourcePath.."img/weapons/weapon_dynamite.png")
    modApi:appendAsset("img/weapons/weapon_dynamite_effect.png",self.resourcePath.."img/weapons/weapon_dynamite_effect.png")
    modApi:appendAsset("img/weapons/passive_fossilizer.png",self.resourcePath.."img/weapons/passive_fossilizer.png")
    modApi:appendAsset("img/combat/rock_0.png",self.resourcePath.."img/combat/rock_0.png")
    modApi:appendAsset("img/combat/rock_1.png",self.resourcePath.."img/combat/rock_1.png")
    modApi:appendAsset("img/combat/rock_2.png",self.resourcePath.."img/combat/rock_2.png")
    modApi:appendAsset("img/combat/decal.png",self.resourcePath.."img/combat/decal.png")
    modApi:appendAsset("img/combat/decal_glow.png",self.resourcePath.."img/combat/decal_glow.png")
    modApi:appendAsset("img/combat/laser_elec_blue_R.png",self.resourcePath.."img/combat/laser_elec_blue_R.png")
    modApi:appendAsset("img/combat/laser_elec_blue_U.png",self.resourcePath.."img/combat/laser_elec_blue_U.png")

    Location["combat/rock_0.png"] = Point(-35, -13)
    Location["combat/rock_1.png"] = Point(-35, -13)
    Location["combat/rock_2.png"] = Point(-35, -13)

    --Animation Assets
    local baseAnim = Animation:new{
        NumFrames = 1, 
        Loop = false, 
        Time = 0.5
    }

    ANIMS.RR_Lightning_Blue_0 = baseAnim:new{
        Image = "combat/laser_elec_blue_U.png",
        PosX = -26,
        PosY = 13.5
    }

    ANIMS.RR_Lightning_Blue_1 = baseAnim:new{
        Image = "combat/laser_elec_blue_R.png",
        PosX = -26, 
        PosY = -7.5
    }

    ANIMS.RR_Lightning_Blue_2 = baseAnim:new{
        Image = "combat/laser_elec_blue_U.png",
        PosX = 2,
        PosY = -7.5
    }

    ANIMS.RR_Lightning_Blue_3 = baseAnim:new{
        Image = "combat/laser_elec_blue_R.png",
        PosX = 2,
        PosY = 13.5
    }

    --Initialized Scripts
    self.modApiExt = require(self.scriptPath .."modApiExt/modApiExt")
    self.modApiExt:init()
    self.passive = require(self.scriptPath.."passive")
    self.passive:init()
    self.trait = require(self.scriptPath.."libraries/trait")
    self.trait:Add({
        PawnTypes =     { "Pawn_RR_Spawn_Dynamite", "Pawn_RR_Spawn_Dynamite2" },
        Icon =          { "img/combat/decal.png", Point(-16, -1) },
        Description =   { "Short Fuse", "Will detonate before enemies emerge, and also immediately if on fire."}
    })
    
    --Scripts
    require(self.scriptPath.."pawns")
    require(self.scriptPath.."point")
    require(self.scriptPath.."terrain")
    require(self.scriptPath.."weapon_transporter")
    require(self.scriptPath.."weapon_drill")
    require(self.scriptPath.."weapon_dynamite")
    require(self.scriptPath.."weapon_fossilizer")
    require(self.scriptPath.."weapon_shovel")
    require(self.scriptPath.."weapon_fence")

end

--Load mod
function mod:load(options, version)

    --Load initialized scripts
    self.modApiExt:load(self, options, version)
    self.passive:load(self.modApiExt)
    self.trait:load()

    --Squad
    modApi:addSquadTrue(
        {
            "Rock Raiders",
            "Pawn_RR_Mech_Drill", 
            "Pawn_RR_Mech_Loader", 
            "Pawn_RR_Mech_Transport"
        }, 
        "Rock Raiders",
        "Utilizing repurposed mining equipment, these mechs can construct a mighty bulwark against the oncoming vek hoard.",
        self.resourcePath..self.icon_squad)

end

return mod
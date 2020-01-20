
local mod = {
    id = "squad_rock_raiders",
    name = "Rock Raiders",
    version = "0.02",
    icon = "img/icons/mod_icon.png",
    icon_squad = "img/icons/squad_icon.png",
    description = "Utilizing repurposed mining equipment, these mechs can construct a mighty bulwark against the oncoming vek hoard.",
    requirements = {}
}

function mod:init()

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
            Type = "mech",
            Name = "Drill Mech",
            Filename = "mech_drill",		
            Path = "img/units/player",
            ResourcePath = "units/player",

            Default =           { PosX = -22, PosY = -8 },
            Animated =          { PosX = -22, PosY = -8, NumFrames = 2},
            Broken =            { PosX = -22, PosY = -8 },
            Submerged =         { PosX = -22, PosY = -8 },
            SubmergedBroken =	{ PosX = -22, PosY = -8 },
            Icon =              {},
        },
        {
            Type = "mech",
            Name = "Loader Mech",
            Filename = "mech_loader",		
            Path = "img/units/player",
            ResourcePath = "units/player",

            Default =           { PosX = -25, PosY = -3 },
            Animated =          { PosX = -25, PosY = -3, NumFrames = 1},
            Broken =            { PosX = -25, PosY = -3 },
            Submerged =         { PosX = -25, PosY = -3 },
            SubmergedBroken =	{ PosX = -25, PosY = -3 },
            Icon =              {},
        },
        {
            Type = "mech",
            Name = "Transport Mech",
            Filename = "mech_transport",
            Path = "img/units/player",
            ResourcePath = "units/player",

            Default =           { PosX = -21, PosY = -17 },
            Animated =          { PosX = -21, PosY = -17, NumFrames = 16, Time = 0.15},
            Broken =            { PosX = -21, PosY = -17 },
            Submerged =         { PosX = -21, PosY = -17 },
            SubmergedBroken =	{ PosX = -21, PosY = -17 },
            Icon =              {},
        },
        {
            Type = "mech",
            Name = "Electric Fence",
            Filename = "spawn_fence",		
            Path = "img/units/player",
            ResourcePath = "units/player",

            Default =           { PosX = -10, PosY = 3 },
            Animated =          { PosX = -10, PosY = 3, NumFrames = 1},
            Broken =            { PosX = -10, PosY = 3 },
            Submerged =         { PosX = -10, PosY = 3 },
            SubmergedBroken =	{ PosX = -10, PosY = 3 },
            Icon =              {},
        },
        {
            Type = "mech",
            Name = "Dynamite",
            Filename = "spawn_dynamite",		
            Path = "img/units/player",
            ResourcePath = "units/player",

            Default =           { PosX = -10, PosY = 8 },
            Animated =          { PosX = -10, PosY = 8, NumFrames = 1},
            Broken =            { PosX = -10, PosY = 8 },
            Submerged =         { PosX = -10, PosY = 8 },
            SubmergedBroken =	{ PosX = -10, PosY = 8 },
            Icon =              {},
        }
    })

    modApi:appendAsset("img/weapons/weapon_drill.png",self.resourcePath.."img/weapons/weapon_drill.png")
    modApi:appendAsset("img/weapons/weapon_scoop.png",self.resourcePath.."img/weapons/weapon_scoop.png")
    modApi:appendAsset("img/weapons/weapon3.png",self.resourcePath.."img/weapons/weapon3.png")
    modApi:appendAsset("img/weapons/passive_fossilizer.png",self.resourcePath.."img/weapons/passive_fossilizer.png")

    self.modApiExt = require(self.scriptPath .."modApiExt/modApiExt")
    self.modApiExt:init()
    
    require(self.scriptPath.."passive")
    require(self.scriptPath.."pawns")
    require(self.scriptPath.."point")
    require(self.scriptPath.."weapon_transporter")
    require(self.scriptPath.."weapon_drill")
    require(self.scriptPath.."weapon_dynamite")
    require(self.scriptPath.."weapon_fossilizer")
    require(self.scriptPath.."weapon_shovel")
    require(self.scriptPath.."weapon_fence")

    Location["units/aliens/rock_1.png"] = Point(-18, 0)
end

function mod:load(options, version)
    self.modApiExt:load(self, options, version)

    modApi:addSquadTrue(
    {
        "Rock Raiders",
        "Pawn_RR_Mech_Drill", 
        "Pawn_RR_Mech_Loader", 
        "Pawn_RR_Mech_Transport"
    }, "Rock Raiders", self.description, self.resourcePath..self.icon_squad)
    
    require(self.scriptPath .."passive"):load(self.modApiExt)
end

return mod
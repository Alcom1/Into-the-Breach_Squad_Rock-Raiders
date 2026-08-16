local mod = mod_loader.mods[modApi.currentMod]

modApi.events.onModLoaded:subscribe(function(id)
	if id ~= mod.id then return end

    local options = mod_loader.currentModContent[id].options

    if options["option_rr_green"].enabled then
        Emitter_Crystal.image =             "combat/rr_crystal_spark.png"
        Item_RR_Crystal_Mine.Image =        "combat/rr_crystal.png"
        Item_RR_Crystal_Mine.Icon =         "combat/rr_crystal.png"
    else
        Emitter_Crystal.image =             "combat/rr_crystal_spark_purp.png"
        Item_RR_Crystal_Mine.Image =        "combat/rr_crystal_purp.png"
        Item_RR_Crystal_Mine.Icon =         "combat/rr_crystal_purp.png"
    end
end)
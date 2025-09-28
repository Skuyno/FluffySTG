
/// Matrix Upgrade: Hemolytic Bloom — seeds the arm blade with hemophage blooms, cockroach charge sacs, and slaughter demon gore anchors that harvest blood and detonate caustic spores.
/datum/changeling_genetic_matrix_recipe/hemolytic_bloom
	id = "matrix_hemolytic_bloom"
	name = "Hemolytic Bloom"
	description = "Seed the arm blade with hemophage blooms, cockroach charge sacs, and slaughter demon gore anchors to harvest blood and detonate caustic spores."
	module = list(
			"id" = "matrix_hemolytic_bloom",
			"name" = "Hemolytic Bloom",
			"desc" = "Arm Blade strikes intensify bleeding, refund chems, and slain victims erupt into caustic spores.",
			"category" = GENETIC_MATRIX_CATEGORY_UPGRADE,
			"slotType" = BIO_INCUBATOR_SLOT_FLEX,
			"tags" = list("arm_blade", "sustain"),
			"button_icon_state" = "armblade",
	)
	required_cells = list(
		CHANGELING_CELL_ID_HEMOPHAGE,
		CHANGELING_CELL_ID_COCKROACH,
		CHANGELING_CELL_ID_SLAUGHTER_DEMON,
	)
	required_abilities = list(
			/datum/action/changeling/weapon/arm_blade,
	)

/obj/effect/particle_effect/fluid/smoke/hemolytic_bloom
	parent_type = /obj/effect/particle_effect/fluid/smoke/quick
	lifetime = 2 SECONDS

/obj/effect/particle_effect/fluid/smoke/hemolytic_bloom/Initialize(mapload, datum/fluid_group/group, ...)
	. = ..()
	add_atom_colour("#84ff9f", FIXED_COLOUR_PRIORITY)
	color = "#84ff9f"

/obj/effect/temp_visual/changeling_hemolytic_seed
	name = "hemolytic bloom"
	icon = 'icons/effects/blood.dmi'
	icon_state = "splatter1"
	layer = ABOVE_MOB_LAYER
	plane = GAME_PLANE
	duration = 4 SECONDS
	light_range = 1.5
	light_color = "#8bff9a"
	var/datum/weakref/changeling_ref

/obj/effect/temp_visual/changeling_hemolytic_seed/Initialize(mapload, mob/living/victim, datum/antagonist/changeling/changeling_data)
	. = ..()
	changeling_ref = WEAKREF(changeling_data)
	color = "#9bff8c"
	alpha = 220
	animate(src, alpha = 90, time = 1 SECONDS, easing = EASE_OUT)
	addtimer(CALLBACK(src, PROC_REF(burst)), 2 SECONDS)
	return .

/obj/effect/temp_visual/changeling_hemolytic_seed/proc/burst()
	if(QDELETED(src))
		return
	playsound(src, 'sound/effects/splat.ogg', 55, TRUE)
	visible_message(
		span_danger("[src] ruptures into a spray of acidic spores!"),
		span_notice("Our bloom erupts, digesting fresh biomass."),
	)
	var/turf/location = get_turf(src)
	if(istype(location))
		do_smoke(range = 1, location = location, smoke_type = /obj/effect/particle_effect/fluid/smoke/hemolytic_bloom)
		for(var/dir in GLOB.cardinals)
			new /obj/effect/temp_visual/dir_setting/bloodsplatter(location, dir, "#6bff9f")
		var/obj/effect/temp_visual/small_smoke/halfsecond/mist = new(location)
		mist.color = "#7fffb2"
	for(var/mob/living/target in range(1, src))
		if(IS_CHANGELING(target))
			continue
		target.adjustToxLoss(12)
		target.apply_status_effect(/datum/status_effect/dazed, 4 SECONDS)
	var/datum/antagonist/changeling/changeling_data = changeling_ref?.resolve()
	changeling_data?.adjust_chemicals(4)
	qdel(src)

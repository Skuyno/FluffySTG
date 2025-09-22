
/// Upgrade: Hemolytic Bloom — seeds the arm blade with hemophage blooms that harvest blood and detonate caustic pods.
/datum/changeling_genetic_matrix_recipe/hemolytic_bloom
	id = "matrix_hemolytic_bloom"
	name = "Hemolytic Bloom"
	description = "Weave hemophage glands through our arm blade to siphon blood for chems and explosive spores."
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
			CHANGELING_CELL_ID_GLOCKROACH,
	)
	required_abilities = list(
			/datum/action/changeling/weapon/arm_blade,
	)

/obj/effect/temp_visual/changeling_hemolytic_seed
	name = "hemolytic bloom"
	icon = 'icons/effects/blood.dmi'
	icon_state = "splatter1"
	layer = ABOVE_MOB_LAYER
	plane = GAME_PLANE
        duration = 4 SECONDS
	var/datum/weakref/changeling_ref

/obj/effect/temp_visual/changeling_hemolytic_seed/Initialize(mapload, mob/living/victim, datum/antagonist/changeling/changeling_data)
	. = ..()
	changeling_ref = WEAKREF(changeling_data)
	addtimer(CALLBACK(src, PROC_REF(burst)), 2 SECONDS)
	return .

/obj/effect/temp_visual/changeling_hemolytic_seed/proc/burst()
	if(QDELETED(src))
		return
	visible_message(
		span_danger("[src] ruptures into a spray of acidic spores!"),
		span_notice("Our bloom erupts, digesting fresh biomass."),
	)
        for(var/mob/living/target in range(1, src))
		if(IS_CHANGELING(target))
			continue
                target.adjustToxLoss(12)
                target.apply_status_effect(/datum/status_effect/dazed, 4 SECONDS)
	var/datum/antagonist/changeling/changeling_data = changeling_ref?.resolve()
        changeling_data?.adjust_chemicals(4)
	qdel(src)

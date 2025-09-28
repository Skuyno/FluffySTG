
/// Matrix Upgrade: Ashen Pump — superheats Gene Stim with tajaran heat glands, ash drake embers, and Bubblegum furnace bile.
/datum/changeling_genetic_matrix_recipe/ashen_pump
	id = "matrix_ashen_pump"
	name = "Ashen Pump"
	description = "Superheat Gene Stim with Tajaran heat glands, ash drake embers, and Bubblegum furnace bile."
	module = list(
			"id" = "matrix_ashen_pump",
			"name" = "Ashen Pump",
			"desc" = "Gene Stim leaves a plasma flare trail, reduces burn damage, and extends its rush at extra chem cost.",
			"category" = GENETIC_MATRIX_CATEGORY_UPGRADE,
			"slotType" = BIO_INCUBATOR_SLOT_FLEX,
			"tags" = list("gene_stim", "burn"),
			"exclusiveTags" = list("gene_stim"),
			"button_icon_state" = "adrenaline",
	)
	required_cells = list(
		CHANGELING_CELL_ID_TAJARAN,
		CHANGELING_CELL_ID_ASH_DRAKE,
		CHANGELING_CELL_ID_BUBBLEGUM,
	)
	required_abilities = list(
			/datum/action/changeling/adrenaline,
	)

/datum/status_effect/changeling_ashen_pump
	id = "changeling_ashen_pump"
	status_type = STATUS_EFFECT_REFRESH
	duration = 10 SECONDS
	tick_interval = 0.5 SECONDS
	alert_type = null
	var/datum/weakref/changeling_ref
	var/applied_bonus = FALSE

/datum/status_effect/changeling_ashen_pump/on_creation(mob/living/new_owner, datum/antagonist/changeling/changeling_data)
	changeling_ref = WEAKREF(changeling_data)
	return ..()

/datum/status_effect/changeling_ashen_pump/on_apply()
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_owner_moved))
	apply_burn_bonus()
	create_flare(get_turf(owner))
	return TRUE

/datum/status_effect/changeling_ashen_pump/on_remove()
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	remove_burn_bonus()
	return ..()

/datum/status_effect/changeling_ashen_pump/tick(seconds_between_ticks)
	create_flare(get_turf(owner))

/datum/status_effect/changeling_ashen_pump/proc/on_owner_moved(atom/movable/source, atom/old_loc, move_dir, forced, list/atom/old_locs)
	SIGNAL_HANDLER
	create_flare(old_loc)
	// Reapply the flare to the tile we just entered so the changeling
	// immediately extinguishes themselves even if they step back into
	// an existing hotspot.
	create_flare(get_turf(owner))

/datum/status_effect/changeling_ashen_pump/proc/create_flare(atom/location)
	if(!owner || !isturf(location))
		return
	var/turf/open/T = get_turf(location)
	if(!istype(T))
		return
	new /obj/effect/temp_visual/changeling_ashen_flare(T)
	if(!(locate(/obj/effect/hotspot) in T))
		new /obj/effect/hotspot(T)
	T.hotspot_expose(900, 50, 1)
	if(owner in T)
		owner.extinguish_mob()
	for(var/mob/living/carbon/victim in T)
		if(victim == owner || IS_CHANGELING(victim))
			continue
		victim.adjust_fire_stacks(0.5)
		victim.ignite_mob()

/datum/status_effect/changeling_ashen_pump/proc/apply_burn_bonus()
	if(applied_bonus)
		return
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		var/datum/physiology/phys = H.physiology
		if(phys)
			phys.burn_mod *= 0.5
			applied_bonus = TRUE

/datum/status_effect/changeling_ashen_pump/proc/remove_burn_bonus()
	if(!applied_bonus)
		return
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		var/datum/physiology/phys = H.physiology
		if(phys)
			phys.burn_mod /= 0.5
	applied_bonus = FALSE

/obj/effect/temp_visual/changeling_ashen_flare
	name = "ashen flare"
	icon = 'icons/effects/fire.dmi'
	icon_state = "heavy"
	duration = 0.8 SECONDS
	light_range = 2
	light_color = LIGHT_COLOR_FIRE
	randomdir = FALSE

/obj/effect/temp_visual/changeling_ashen_flare/Initialize(mapload)
	. = ..()
	color = "#ffb347"
	animate(src, alpha = 0, time = duration, easing = EASE_OUT)

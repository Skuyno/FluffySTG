
/// Upgrade: Ashen Pump — superheats Gene Stim into a plasma bleed that shields against burn and scorches the ground.
/datum/changeling_genetic_matrix_recipe/ashen_pump
	id = "matrix_ashen_pump"
	name = "Ashen Pump"
	description = "Graft ash drake vents and plasmaman sacs into Gene Stim for fiery overdrive."
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
			CHANGELING_CELL_ID_ASH_DRAKE,
			CHANGELING_CELL_ID_PLASMAMAN,
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
	var/last_turf
	var/applied_bonus = FALSE

/datum/status_effect/changeling_ashen_pump/on_creation(mob/living/new_owner, datum/antagonist/changeling/changeling_data)
	changeling_ref = WEAKREF(changeling_data)
	return ..()

/datum/status_effect/changeling_ashen_pump/on_apply()
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_owner_moved))
	apply_burn_bonus()
	create_flare(get_turf(owner))
	last_turf = get_turf(owner)
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
	last_turf = get_turf(owner)

/datum/status_effect/changeling_ashen_pump/proc/create_flare(atom/location)
	if(!isturf(location))
		return
	var/turf/T = location
	new /obj/effect/temp_visual/dir_setting/firing_effect/red(T, owner.dir)
	T.hotspot_expose(600, 10)

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

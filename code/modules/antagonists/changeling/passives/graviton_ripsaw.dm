
/datum/changeling_genetic_matrix_recipe/graviton_ripsaw
	id = "matrix_graviton_ripsaw"
	name = "Graviton Ripsaw"
	description = "Fuse Tajaran pounce tendons with voidwalker gravity shears and space carp momentum fins to turn the armblade into a gravitic saw."
	module = list(
		"id" = "matrix_graviton_ripsaw",
		"name" = "Graviton Ripsaw",
		"desc" = "Arm Blade attacks yank victims inward while right-click launches a flesh tether to reel ourselves forward.",
		"category" = GENETIC_MATRIX_CATEGORY_UPGRADE,
		"slotType" = BIO_INCUBATOR_SLOT_FLEX,
		"moduleType" = /datum/changeling_genetic_module/upgrade/graviton_ripsaw,
		"tags" = list("arm_blade", "control", "mobility"),
		"button_icon_state" = "armblade",
)
	required_cells = list(
		CHANGELING_CELL_ID_TAJARAN,
		CHANGELING_CELL_ID_VOIDWALKER,
		CHANGELING_CELL_ID_SPACE_CARP,
	)
	required_abilities = list(
		/datum/action/changeling/weapon/arm_blade,
	)

/datum/status_effect/changeling_gravitic_pull
	id = "changeling_gravitic_pull"
	status_type = STATUS_EFFECT_REFRESH
	duration = 5 SECONDS
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = null
	/// Weak reference to the changeling who struck the victim.
	var/datum/weakref/source_ref

/datum/status_effect/changeling_gravitic_pull/on_creation(mob/living/new_owner, mob/living/source)
	source_ref = WEAKREF(source)
	return ..()

/datum/status_effect/changeling_gravitic_pull/on_apply()
	. = ..()
	if(!.)
		return FALSE
	apply_gravitic_tug()
	return TRUE

/datum/status_effect/changeling_gravitic_pull/refresh(mob/living/new_owner, mob/living/source)
	..()
	source_ref = WEAKREF(source)
	apply_gravitic_tug()

/datum/status_effect/changeling_gravitic_pull/on_remove()
	source_ref = null
	return ..()

/datum/status_effect/changeling_gravitic_pull/proc/apply_gravitic_tug()
	var/mob/living/source = source_ref?.resolve()
	if(!source || !owner)
		return
	if(source == owner || owner.stat == DEAD)
		return
	owner.adjustStaminaLoss(12)
	owner.set_jitter_if_lower(3 SECONDS)
	if(owner.anchored || owner.throwing || owner.buckled)
		return
	var/turf/owner_turf = get_turf(owner)
	var/turf/source_turf = get_turf(source)
	if(!owner_turf || !source_turf)
		return
	if(owner_turf.z != source_turf.z)
		return
	if(get_dist(owner_turf, source_turf) <= 1)
		return
	step_towards(owner, source)


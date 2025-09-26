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

/datum/changeling_genetic_module/upgrade/graviton_ripsaw
	id = "matrix_graviton_ripsaw"
	passive_effects = list()

	COOLDOWN_DECLARE(grapple_cooldown)

/datum/changeling_genetic_module/upgrade/graviton_ripsaw/on_deactivate()
	COOLDOWN_RESET(src, grapple_cooldown)
	return ..()

#define GRAVITON_RIPSAW_GRAPPLE_RANGE 7
#define GRAVITON_RIPSAW_GRAPPLE_COOLDOWN (2 SECONDS)

/datum/changeling_genetic_module/upgrade/graviton_ripsaw/proc/try_grapple(atom/grapple_target, mob/living/user)
	if(!is_active() || get_owner_mob() != user)
		return NONE
	if(!istype(user))
		return ITEM_INTERACT_BLOCKING
	if(user.throwing)
		user.balloon_alert(user, "mid-flight!")
		return ITEM_INTERACT_BLOCKING
	if(user.buckled || user.anchored)
		user.balloon_alert(user, "stuck!")
		return ITEM_INTERACT_BLOCKING
	if(!COOLDOWN_FINISHED(src, grapple_cooldown))
		user.balloon_alert(user, "tendons recovering!")
		return ITEM_INTERACT_BLOCKING
	var/turf/user_turf = get_turf(user)
	var/turf/target_turf = get_turf(grapple_target)
	if(!user_turf || !target_turf)
		return ITEM_INTERACT_BLOCKING
	var/dist = get_dist(user_turf, target_turf)
	if(dist <= 0)
		user.balloon_alert(user, "need anchor!")
		return ITEM_INTERACT_BLOCKING
	if(dist == -1 || dist > GRAVITON_RIPSAW_GRAPPLE_RANGE)
		user.balloon_alert(user, "out of reach!")
		return ITEM_INTERACT_BLOCKING
	var/list/path = get_line(user_turf, target_turf)
	var/turf/destination = user_turf
	var/steps = 0
	for(var/i = 2, i <= length(path), i++)
		var/turf/step = path[i]
		if(!istype(step))
			break
		steps++
		if(steps > GRAVITON_RIPSAW_GRAPPLE_RANGE)
			break
		if(step.is_blocked_turf(TRUE, source_atom = user))
			break
		destination = step
	if(destination == user_turf)
		user.balloon_alert(user, "no clear path!")
		return ITEM_INTERACT_BLOCKING
	var/distance_to_destination = clamp(get_dist(user_turf, destination), 1, GRAVITON_RIPSAW_GRAPPLE_RANGE)
	COOLDOWN_START(src, grapple_cooldown, GRAVITON_RIPSAW_GRAPPLE_COOLDOWN)
	user.setDir(get_dir(user_turf, destination))
	user.Beam(
		destination,
		icon_state = "zipline_hook",
		time = 0.5 SECONDS,
		emissive = FALSE,
		maxdistance = GRAVITON_RIPSAW_GRAPPLE_RANGE,
		layer = BELOW_MOB_LAYER,
	)
	playsound(user, 'sound/effects/splat.ogg', 40, TRUE)
	user.throw_at(destination, distance_to_destination, 1, user, spin = FALSE, gentle = TRUE)
	return ITEM_INTERACT_SUCCESS

/datum/changeling_genetic_module/upgrade/graviton_ripsaw/proc/handle_hit(atom/target, mob/living/user)
	if(!is_active() || !istype(user) || !isliving(target))
		return
	var/mob/living/living_target = target
	if(living_target == user || living_target.stat == DEAD)
		return
	living_target.apply_status_effect(/datum/status_effect/changeling_gravitic_pull, user)

#undef GRAVITON_RIPSAW_GRAPPLE_RANGE
#undef GRAVITON_RIPSAW_GRAPPLE_COOLDOWN

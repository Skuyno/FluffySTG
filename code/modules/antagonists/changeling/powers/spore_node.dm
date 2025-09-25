
/datum/action/changeling/spore_node
	name = "Spore Node"
	desc = "Seed a stationary pheromone node that alerts us and can burst into slowing spores. Costs 8 chemicals."
	helptext = "Requires the Spore Node key matrix. Using it while a node exists detonates the current node."
	button_icon_state = "spread_infestation"
	chemical_cost = 8
	dna_cost = CHANGELING_POWER_UNOBTAINABLE
	req_stat = CONSCIOUS
	disabled_by_fire = FALSE

/datum/action/changeling/spore_node/sting_action(mob/living/user)
	var/datum/antagonist/changeling/changeling_data = IS_CHANGELING(user)
	if(!changeling_data?.is_genetic_matrix_module_active("matrix_spore_node"))
		user.balloon_alert(user, "needs node module")
		return FALSE
	if(changeling_data.detonate_spore_node(user))
		return TRUE
	var/turf/placement = get_turf(user)
	if(!placement || placement.is_blocked_turf(TRUE, source_atom = user))
		user.balloon_alert(user, "bad turf")
		return FALSE
	if(!do_after(user, 4 SECONDS, target = placement, extra_checks = CALLBACK(src, PROC_REF(can_continue_spore_node), user, placement)))
		return FALSE
	changeling_data = IS_CHANGELING(user)
	if(!changeling_data?.is_genetic_matrix_module_active("matrix_spore_node"))
		return FALSE
	if(changeling_data.matrix_spore_node_ref?.resolve())
		return FALSE
	placement = get_turf(user)
	if(!placement || placement.is_blocked_turf(TRUE, source_atom = user))
		return FALSE
	return changeling_data.place_spore_node(placement, user)

/datum/action/changeling/spore_node/proc/can_continue_spore_node(mob/living/user, turf/placement)
	if(QDELETED(src) || QDELETED(user) || user.stat >= UNCONSCIOUS)
		return FALSE
	if(!placement)
		return FALSE
	var/turf/current_turf = get_turf(user)
	if(!current_turf || current_turf != placement)
		return FALSE
	if(placement.is_blocked_turf(TRUE, source_atom = user))
		return FALSE
	var/datum/antagonist/changeling/changeling_data = IS_CHANGELING(user)
	if(!changeling_data?.is_genetic_matrix_module_active("matrix_spore_node"))
		return FALSE
	if(changeling_data.matrix_spore_node_ref?.resolve())
		return FALSE
	return TRUE

/obj/structure/changeling_spore_node
	name = "spore node"
	desc = "A pulsating changeling beacon that hums with pheromonal static."
	icon = 'icons/mob/simple/meteor_heart.dmi'
	icon_state = "eggs"
	anchored = TRUE
	density = FALSE
	obj_flags = CAN_BE_HIT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	max_integrity = 80
	/// Cached changeling maintaining the node.
	var/datum/weakref/changeling_ref
	/// Tracks recently pinged mobs to avoid spam.
	var/list/tracked_refs = list()

/obj/structure/changeling_spore_node/Initialize(mapload, datum/antagonist/changeling/changeling_data)
	. = ..()
	if(changeling_data)
		changeling_ref = WEAKREF(changeling_data)
	START_PROCESSING(SSobj, src)
	return .

/obj/structure/changeling_spore_node/Destroy()
	STOP_PROCESSING(SSobj, src)
	tracked_refs.Cut()
	var/datum/antagonist/changeling/changeling_data = changeling_ref?.resolve()
	changeling_data?.clear_spore_node(src)
	changeling_ref = null
	return ..()

/obj/structure/changeling_spore_node/process(seconds_per_tick)
	var/datum/antagonist/changeling/changeling_data = changeling_ref?.resolve()
	if(!changeling_data || changeling_data.owner?.current?.stat == DEAD)
		qdel(src)
		return
	var/list/current_refs = list()
	for(var/mob/living/victim in range(2, src))
		if(IS_CHANGELING(victim) || victim.stat == DEAD)
			continue
		var/datum/weakref/ref = WEAKREF(victim)
		current_refs += ref
		if(tracked_refs[ref])
			continue
		notify_changeling(victim)
	tracked_refs = current_refs

/obj/structure/changeling_spore_node/proc/notify_changeling(mob/living/victim)
	var/datum/antagonist/changeling/changeling_data = changeling_ref?.resolve()
	if(!changeling_data)
		return
	var/mob/living/owner = changeling_data.owner?.current
	if(!owner)
		return
	owner.balloon_alert(owner, "spore ping: [victim]")
	to_chat(owner, span_changeling("Our spore node senses movement near [victim]."))

/obj/structure/changeling_spore_node/proc/detonate(mob/living/user)
	playsound(src, 'sound/effects/magic/disable_tech.ogg', 60, TRUE)
	visible_message(
		span_danger("[src] ruptures into a haze of grasping spores!"),
		span_notice("Our spores rupture into a slowing miasma."),
	)
	do_smoke(range = 1, location = loc)
	for(var/mob/living/target in range(3, src))
		if(target.stat == DEAD || IS_CHANGELING(target))
			continue
		target.adjustStaminaLoss(40)
		target.Knockdown(2 SECONDS)
		target.apply_status_effect(/datum/status_effect/dazed, 6 SECONDS)
	qdel(src)
	var/datum/antagonist/changeling/changeling_data = changeling_ref?.resolve()
	changeling_data?.spore_node_detonated(user)

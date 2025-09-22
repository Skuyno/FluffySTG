
/datum/action/changeling/chorus_stasis
	name = "Chorus Stasis"
	desc = "Spin a cocoon around ourselves or one adjacent creature, healing quietly until detonated. Costs 18 chemicals."
	helptext = "Requires the Chorus Stasis key. Target an adjacent mob to cocoon them instead; reusing detonates the cocoon."
	button_icon_state = "fake_death"
	chemical_cost = 18
	dna_cost = CHANGELING_POWER_UNOBTAINABLE
	req_stat = CONSCIOUS
	disabled_by_fire = FALSE

/datum/action/changeling/chorus_stasis/sting_action(mob/living/user, mob/living/target)
	var/datum/antagonist/changeling/changeling_data = IS_CHANGELING(user)
	if(!changeling_data?.matrix_chorus_stasis_active)
		user.balloon_alert(user, "needs chorus key")
		return FALSE
	return changeling_data.handle_chorus_stasis_activation(user, target)

/obj/structure/changeling_chorus_cocoon
	name = "chorus cocoon"
	desc = "A resonant changeling pod humming with muffled voices."
	icon = 'icons/mob/simple/meteor_heart.dmi'
	icon_state = "flesh_pod_open"
	anchored = TRUE
	density = FALSE
	can_buckle = TRUE
	buckle_lying = TRUE
	max_buckled_mobs = 1
	obj_flags = CAN_BE_HIT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	max_integrity = 80
	/// Changeling source maintaining the cocoon.
	var/datum/weakref/changeling_ref
	/// Tracks mobs currently concealed by the cocoon.
	var/list/cocooned_mobs = list()

/obj/structure/changeling_chorus_cocoon/Initialize(mapload, datum/antagonist/changeling/changeling_data)
	. = ..()
	if(changeling_data)
		changeling_ref = WEAKREF(changeling_data)
	cocooned_mobs = list()
	START_PROCESSING(SSobj, src)
	update_cocoon_appearance()
	return .

/obj/structure/changeling_chorus_cocoon/Destroy()
	for(var/mob/living/occupant in buckled_mobs.Copy())
		unbuckle_mob(occupant, force = TRUE, can_fall = FALSE)
	for(var/mob/living/hidden in cocooned_mobs.Copy())
		remove_cocoon_effects(hidden)
	cocooned_mobs.Cut()
	STOP_PROCESSING(SSobj, src)
	var/datum/antagonist/changeling/changeling_data = changeling_ref?.resolve()
	changeling_data?.clear_chorus_cocoon(src)
	changeling_ref = null
	return ..()

/obj/structure/changeling_chorus_cocoon/process(seconds_per_tick)
	if(!length(cocooned_mobs))
		return
	for(var/mob/living/victim as anything in cocooned_mobs.Copy())
		if(QDELETED(victim) || !(victim in buckled_mobs))
			remove_cocoon_effects(victim)
			continue
		if(victim.stat == DEAD)
			continue
		heal_cocooned_mob(victim, seconds_per_tick)

/obj/structure/changeling_chorus_cocoon/proc/heal_cocooned_mob(mob/living/victim, seconds_per_tick)
	if(!isliving(victim))
		return
	victim.adjustBruteLoss(-2.4 * seconds_per_tick, updating_health = FALSE, forced = TRUE)
	victim.adjustFireLoss(-2 * seconds_per_tick, updating_health = FALSE, forced = TRUE)
	victim.adjustOxyLoss(-3 * seconds_per_tick, updating_health = FALSE, forced = TRUE)
	victim.adjustToxLoss(-0.8 * seconds_per_tick, forced = TRUE)
	victim.adjustStaminaLoss(-6 * seconds_per_tick, updating_stamina = FALSE)
	victim.updatehealth()
	victim.update_stamina()

/obj/structure/changeling_chorus_cocoon/proc/add_occupant(mob/living/victim)
	if(length(buckled_mobs) >= max_buckled_mobs)
		return FALSE
	if(!victim.buckle_mob(src, force = TRUE, check_loc = TRUE))
		return FALSE
	victim.visible_message(
		span_warning("[victim] is swallowed by [src]!"),
		span_userdanger("A thick chorus of tendrils binds you inside the cocoon!"),
	)
	return TRUE

/obj/structure/changeling_chorus_cocoon/post_buckle_mob(mob/living/buckled_mob)
	. = ..()
	apply_cocoon_effects(buckled_mob)
	update_cocoon_appearance()

/obj/structure/changeling_chorus_cocoon/proc/update_cocoon_appearance()
	if(length(buckled_mobs))
		icon_state = "flesh_pod"
	else
		icon_state = "flesh_pod_open"

/obj/structure/changeling_chorus_cocoon/post_unbuckle_mob(mob/living/unbuckled_mob)
	. = ..()
	remove_cocoon_effects(unbuckled_mob)
	update_cocoon_appearance()

/obj/structure/changeling_chorus_cocoon/proc/apply_cocoon_effects(mob/living/victim)
	if(!isliving(victim))
		return
	cocooned_mobs |= victim
	victim.SetInvisibility(INVISIBILITY_MAXIMUM, id = REF(src))
	ADD_TRAIT(victim, TRAIT_HANDS_BLOCKED, REF(src))

/obj/structure/changeling_chorus_cocoon/proc/remove_cocoon_effects(mob/living/victim)
	if(!isliving(victim))
		return
	cocooned_mobs -= victim
	victim.RemoveInvisibility(REF(src))
	REMOVE_TRAIT(victim, TRAIT_HANDS_BLOCKED, REF(src))

/obj/structure/changeling_chorus_cocoon/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!isliving(user))
		return TRUE
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return TRUE
	user.visible_message(
		span_warning("[user] claws at [src], tearing at its tendrils!"),
		span_warning("You start ripping apart the cocoon..."),
	)
	if(!do_after(user, 2.5 SECONDS, target = src))
		return TRUE
	if(QDELETED(src))
		return TRUE
	visible_message(
		span_danger("[src] splits apart under the assault!"),
		span_notice("We rip open the cocoon."),
	)
	qdel(src)
	return TRUE

/obj/structure/changeling_chorus_cocoon/proc/detonate(mob/living/user)
	playsound(src, 'sound/effects/magic/clockwork/anima_fragment_attack.ogg', 60, TRUE)
	visible_message(
		span_danger("[src] ruptures in a wave of soporific gas!"),
		span_notice("We unravel the cocoon, flooding the area with muting spores."),
	)
	for(var/mob/living/occupant in buckled_mobs.Copy())
		unbuckle_mob(occupant, force = TRUE, can_fall = FALSE)
		occupant.Knockdown(2 SECONDS)
	for(var/mob/living/target in range(3, src))
		if(target.stat == DEAD || IS_CHANGELING(target))
			continue
		target.adjustStaminaLoss(50)
		target.Knockdown(4 SECONDS)
		target.adjust_confusion(60)
	qdel(src)
	var/datum/antagonist/changeling/changeling_data = changeling_ref?.resolve()
	changeling_data?.chorus_cocoon_detonated(user)

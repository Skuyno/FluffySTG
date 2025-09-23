/datum/action/changeling/chorus_stasis
	name = "Chorus Stasis"
	desc = "Weave a living cocoon that shelters and mends its occupant. Costs 18 chemicals."
	helptext = "Requires the Chorus Stasis key. Target an adjacent creature to wrap them immediately; otherwise we climb inside ourselves. Only one cocoon may exist at a time."
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
	desc = "A resonant changeling pod lined with patient heartbeats."
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
	/// Changeling maintaining this cocoon.
	var/datum/weakref/changeling_ref
	/// Mob currently wrapped within the cocoon.
	var/mob/living/current_occupant

/obj/structure/changeling_chorus_cocoon/Initialize(mapload, datum/antagonist/changeling/changeling_data)
	. = ..()
	if(istype(changeling_data))
		bind_to_changeling(changeling_data)
	START_PROCESSING(SSobj, src)
	if(!(src in GLOB.changeling_chorus_cocoons))
		GLOB.changeling_chorus_cocoons += src
	refresh_visual_state()
	return .

/obj/structure/changeling_chorus_cocoon/Destroy()
	release_occupant(TRUE)
	STOP_PROCESSING(SSobj, src)
	GLOB.changeling_chorus_cocoons -= src
	var/datum/antagonist/changeling/changeling_data = changeling_ref?.resolve()
	changeling_ref = null
	changeling_data?.notify_chorus_cocoon_removed(src)
	return ..()

/obj/structure/changeling_chorus_cocoon/proc/bind_to_changeling(datum/antagonist/changeling/changeling_data)
	if(!istype(changeling_data))
		return
	changeling_ref = WEAKREF(changeling_data)

/obj/structure/changeling_chorus_cocoon/proc/should_restrain(mob/living/victim)
	if(!istype(victim))
		return FALSE
	var/datum/antagonist/changeling/changeling_data = changeling_ref?.resolve()
	return changeling_data?.owner?.current != victim

/obj/structure/changeling_chorus_cocoon/proc/release_occupant(force_release = FALSE)
	if(!current_occupant)
		return
	var/mob/living/victim = current_occupant
	if(victim.buckled != src)
		set_current_occupant(null)
		return
	unbuckle_mob(victim, force = TRUE, can_fall = FALSE)
	if(force_release && victim)
		victim.forceMove(get_turf(src))

/obj/structure/changeling_chorus_cocoon/post_buckle_mob(mob/living/buckled_mob)
	. = ..()
	if(QDELETED(src))
		return
	set_current_occupant(buckled_mob)
	if(istype(buckled_mob) && buckled_mob.loc != src)
		buckled_mob.forceMove(src)
	refresh_visual_state()
	if(istype(buckled_mob))
		buckled_mob.visible_message(
			span_warning("[buckled_mob] is wrapped in [src]!"),
			span_notice("The cocoon folds shut, filling your ears with calming chords."),
		)

/obj/structure/changeling_chorus_cocoon/post_unbuckle_mob(mob/living/unbuckled_mob)
	. = ..()
	if(unbuckled_mob == current_occupant)
		set_current_occupant(null)
	if(istype(unbuckled_mob) && unbuckled_mob.loc == src)
		unbuckled_mob.forceMove(get_turf(src))
	refresh_visual_state()

/obj/structure/changeling_chorus_cocoon/proc/set_current_occupant(mob/living/new_occupant)
	if(current_occupant == new_occupant)
		return
	if(current_occupant)
		remove_cocoon_effects(current_occupant)
	current_occupant = null
	if(!istype(new_occupant))
		return
	current_occupant = new_occupant
	apply_cocoon_effects(current_occupant)

/obj/structure/changeling_chorus_cocoon/proc/apply_cocoon_effects(mob/living/victim)
	if(!istype(victim))
		return
	victim.extinguish_mob()
	var/list/traits_to_add = list(TRAIT_ANALGESIA)
	if(should_restrain(victim))
		traits_to_add += TRAIT_RESTRAINED
	victim.add_traits(traits_to_add, REF(src))

/obj/structure/changeling_chorus_cocoon/proc/remove_cocoon_effects(mob/living/victim)
	if(!istype(victim))
		return
	victim.remove_traits(list(TRAIT_ANALGESIA, TRAIT_RESTRAINED), REF(src))

/obj/structure/changeling_chorus_cocoon/proc/refresh_visual_state()
	icon_state = length(buckled_mobs) ? "flesh_pod" : "flesh_pod_open"

/obj/structure/changeling_chorus_cocoon/process(seconds_per_tick)
	var/mob/living/occupant = locate(/mob/living) in buckled_mobs
	if(!istype(occupant) || QDELETED(occupant))
		if(current_occupant)
			set_current_occupant(null)
		return
	if(occupant != current_occupant)
		set_current_occupant(occupant)
	maintain_occupant(occupant, seconds_per_tick)

/obj/structure/changeling_chorus_cocoon/proc/maintain_occupant(mob/living/victim, seconds_between_ticks)
	if(!istype(victim))
		return
	if(victim.stat != DEAD)
		heal_occupant(victim, seconds_between_ticks)
	if(!HAS_TRAIT(victim, TRAIT_ANALGESIA) || (should_restrain(victim) && !HAS_TRAIT(victim, TRAIT_RESTRAINED)))
		apply_cocoon_effects(victim)

/obj/structure/changeling_chorus_cocoon/proc/heal_occupant(mob/living/victim, seconds_between_ticks)
	var/heal_scale = max(seconds_between_ticks, 0)
	var/brute_heal = 5 * heal_scale
	var/burn_heal = 5 * heal_scale
	var/stamina_heal = 10 * heal_scale
	victim.heal_overall_damage(brute = brute_heal, burn = burn_heal, stamina = stamina_heal, forced = TRUE, updating_health = FALSE)
	victim.adjustToxLoss(-2 * heal_scale, forced = TRUE)
	victim.adjustOxyLoss(-6 * heal_scale, updating_health = FALSE, forced = TRUE)
	victim.adjust_drowsiness(-4 * heal_scale)
	victim.extinguish_mob()
	if(iscarbon(victim))
		var/mob/living/carbon/carbon_victim = victim
		if(carbon_victim.blood_volume && carbon_victim.blood_volume < BLOOD_VOLUME_NORMAL)
			carbon_victim.blood_volume = min(carbon_victim.blood_volume + (3 * heal_scale), BLOOD_VOLUME_NORMAL)
	victim.updatehealth()
	victim.update_stamina()

/obj/structure/changeling_chorus_cocoon/proc/accept_occupant(mob/living/victim)
	if(!istype(victim))
		return FALSE
	if(victim.buckled || isobj(victim.loc))
		return FALSE
	if(!victim.buckle_mob(src, force = TRUE, check_loc = TRUE))
		return FALSE
	return TRUE

/obj/structure/changeling_chorus_cocoon/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return TRUE
	if(!isliving(user))
		return TRUE
	if(length(buckled_mobs))
		if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
			return TRUE
		var/mob/living/occupant = locate(/mob/living) in buckled_mobs
		user.visible_message(
			span_warning("[user] pulls at [src]'s seams, trying to free [occupant]!"),
			span_warning("You start peeling open the cocoon."),
		)
		if(!do_after(user, 3 SECONDS, target = src))
			return TRUE
		if(QDELETED(src))
			return TRUE
		if(occupant && occupant.buckled == src)
			user.visible_message(
				span_warning("[user] tears open [src], freeing [occupant]!"),
				span_notice("You rip the cocoon apart and pull [occupant] free."),
			)
			release_occupant()
		refresh_visual_state()
		return TRUE
	user.visible_message(
		span_warning("[user] starts rending [src] apart!"),
		span_warning("You begin to tear down the cocoon."),
	)
	if(!do_after(user, 2 SECONDS, target = src))
		return TRUE
	if(QDELETED(src))
		return TRUE
	user.visible_message(
		span_danger("[src] collapses into slack flesh at [user]'s touch!"),
		span_notice("You dismantle the chorus cocoon."),
	)
	qdel(src)
	return TRUE


/datum/action/changeling/chorus_stasis
	name = "Chorus Stasis"
	desc = "Spin a cocoon around ourselves or an adjacent creature, rapidly knitting wounds until detonated. Costs 18 chemicals."
	helptext = "Requires the Chorus Stasis key. Target an adjacent mob to cocoon them instead; reuse while it exists to detonate it."
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
	desc = "A resonant changeling pod humming with layered heartbeats."
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
	/// Changeling maintaining the cocoon.
	var/datum/weakref/changeling_ref
	/// Mob currently wrapped within the cocoon.
	var/mob/living/current_occupant

/obj/structure/changeling_chorus_cocoon/Initialize(mapload, datum/antagonist/changeling/changeling_data)
	. = ..()
	if(changeling_data)
		changeling_ref = WEAKREF(changeling_data)
	START_PROCESSING(SSobj, src)
	GLOB.changeling_chorus_cocoons += src
	update_cocoon_appearance()
	return .

/obj/structure/changeling_chorus_cocoon/Destroy()
	for(var/mob/living/occupant in buckled_mobs.Copy())
		unbuckle_mob(occupant, force = TRUE, can_fall = FALSE)
	set_current_occupant(null)
	STOP_PROCESSING(SSobj, src)
	GLOB.changeling_chorus_cocoons -= src
	var/datum/antagonist/changeling/changeling_data = changeling_ref?.resolve()
	changeling_data?.clear_chorus_cocoon(src)
	changeling_ref = null
	return ..()

/obj/structure/changeling_chorus_cocoon/process(seconds_per_tick)
	if(!length(buckled_mobs))
		if(current_occupant)
			set_current_occupant(null)
		return
	var/mob/living/occupant = locate(/mob/living) in buckled_mobs
	if(!istype(occupant) || QDELETED(occupant))
		if(current_occupant)
			set_current_occupant(null)
		return
	if(occupant != current_occupant)
		set_current_occupant(occupant)
	maintain_occupant(occupant, seconds_per_tick)

/obj/structure/changeling_chorus_cocoon/proc/add_occupant(mob/living/victim)
	if(!isliving(victim))
		return FALSE
	if(length(buckled_mobs) >= max_buckled_mobs)
		return FALSE
	if(!victim.buckle_mob(src, force = TRUE, check_loc = TRUE))
		return FALSE
	victim.visible_message(
		span_warning("[victim] is swallowed by [src]!"),
		span_userdanger("A thick chorus of tendrils binds you inside the cocoon!"),
	)
	to_chat(victim, span_notice("A soothing chorus thrums through your body, beginning to knit your wounds."))
	return TRUE

/obj/structure/changeling_chorus_cocoon/post_buckle_mob(mob/living/buckled_mob)
	. = ..()
	set_current_occupant(buckled_mob)
	update_cocoon_appearance()

/obj/structure/changeling_chorus_cocoon/proc/update_cocoon_appearance()
	if(length(buckled_mobs))
		icon_state = "flesh_pod"
	else
		icon_state = "flesh_pod_open"

/obj/structure/changeling_chorus_cocoon/post_unbuckle_mob(mob/living/unbuckled_mob)
	. = ..()
	if(unbuckled_mob == current_occupant)
		set_current_occupant(null)
	update_cocoon_appearance()

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
	victim.SetInvisibility(INVISIBILITY_MAXIMUM, id = REF(src))
	victim.extinguish_mob()
	victim.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILIZED, TRAIT_STASIS, TRAIT_ANALGESIA), REF(src))

/obj/structure/changeling_chorus_cocoon/proc/remove_cocoon_effects(mob/living/victim)
	if(!istype(victim))
		return
	victim.RemoveInvisibility(REF(src))
	victim.remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILIZED, TRAIT_STASIS, TRAIT_ANALGESIA), REF(src))
	victim.SetSleeping(0)

/obj/structure/changeling_chorus_cocoon/proc/maintain_occupant(mob/living/victim, seconds_between_ticks)
	if(!istype(victim))
		return
	if(victim.stat != DEAD)
		heal_occupant(victim, seconds_between_ticks)
	if(!HAS_TRAIT(victim, TRAIT_STASIS) || !HAS_TRAIT(victim, TRAIT_HANDS_BLOCKED) || !HAS_TRAIT(victim, TRAIT_IMMOBILIZED))
		apply_cocoon_effects(victim)

/obj/structure/changeling_chorus_cocoon/proc/heal_occupant(mob/living/victim, seconds_between_ticks)
	var/heal_scale = max(seconds_between_ticks, 0)
	var/brute_heal = 6 * heal_scale
	var/burn_heal = 6 * heal_scale
	var/stamina_heal = 12 * heal_scale
	victim.heal_overall_damage(brute = brute_heal, burn = burn_heal, stamina = stamina_heal, forced = TRUE, updating_health = FALSE)
	victim.adjustToxLoss(-4 * heal_scale, forced = TRUE)
	victim.adjustOxyLoss(-8 * heal_scale, updating_health = FALSE, forced = TRUE)
	victim.adjust_drowsiness(-5 * heal_scale)
	victim.extinguish_mob()
	if(iscarbon(victim))
		var/mob/living/carbon/carbon_victim = victim
		if(carbon_victim.blood_volume && carbon_victim.blood_volume < BLOOD_VOLUME_NORMAL)
			carbon_victim.blood_volume = min(carbon_victim.blood_volume + (4 * heal_scale), BLOOD_VOLUME_NORMAL)
	victim.updatehealth()
	victim.update_stamina()

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

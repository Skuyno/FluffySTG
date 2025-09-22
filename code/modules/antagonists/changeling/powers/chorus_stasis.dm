
/datum/action/changeling/chorus_stasis
	name = "Chorus Stasis"
	desc = "Spin a cocoon around ourselves and a victim or ally, healing quietly until detonated. Costs 18 chemicals."
	helptext = "Requires the Chorus Stasis key. Target an adjacent mob to pull them inside; reusing detonates the cocoon."
	button_icon_state = "fakedeath"
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
       icon = 'modular_nova/modules/spider/icons/spider.dmi'
	icon_state = "cocoon"
	anchored = TRUE
	density = FALSE
	can_buckle = TRUE
	buckle_lying = TRUE
	max_buckled_mobs = 2
	resistance_flags = FIRE_PROOF | ACID_PROOF
	max_integrity = 80
	/// Changeling source maintaining the cocoon.
	var/datum/weakref/changeling_ref

/obj/structure/changeling_chorus_cocoon/Initialize(mapload, datum/antagonist/changeling/changeling_data)
	. = ..()
	if(changeling_data)
		changeling_ref = WEAKREF(changeling_data)
	START_PROCESSING(SSobj, src)
	return .

/obj/structure/changeling_chorus_cocoon/Destroy()
	STOP_PROCESSING(SSobj, src)
	for(var/mob/living/occupant in buckled_mobs.Copy())
		unbuckle_mob(occupant, force = TRUE, can_fall = FALSE)
	var/datum/antagonist/changeling/changeling_data = changeling_ref?.resolve()
	changeling_data?.clear_chorus_cocoon(src)
	changeling_ref = null
	return ..()

/obj/structure/changeling_chorus_cocoon/process(seconds_per_tick)
	for(var/mob/living/occupant in buckled_mobs)
		if(occupant.stat == DEAD)
			continue
		occupant.adjustBruteLoss(-1.2 * seconds_per_tick, updating_health = FALSE, forced = TRUE)
		occupant.adjustFireLoss(-1 * seconds_per_tick, updating_health = FALSE, forced = TRUE)
		occupant.adjustOxyLoss(-1.5 * seconds_per_tick, updating_health = FALSE, forced = TRUE)
		occupant.adjustToxLoss(-0.4 * seconds_per_tick, forced = TRUE)
		occupant.adjustStaminaLoss(-3 * seconds_per_tick, updating_stamina = FALSE)
		occupant.updatehealth()

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

/obj/structure/changeling_chorus_cocoon/proc/detonate(mob/living/user)
       playsound(src, 'sound/effects/magic/clockwork/anima_fragment_attack.ogg', 60, TRUE)
	visible_message(
		span_danger("[src] ruptures in a wave of soporific gas!"),
		span_notice("We unravel the cocoon, flooding the area with muting spores."),
	)
	for(var/mob/living/occupant in buckled_mobs.Copy())
		unbuckle_mob(occupant, force = TRUE, can_fall = FALSE)
               occupant.Knockdown(1 SECONDS)
	for(var/mob/living/target in range(2, src))
		if(target.stat == DEAD || IS_CHANGELING(target))
			continue
               target.adjustStaminaLoss(25)
               target.Knockdown(2 SECONDS)
		target.adjust_confusion(30)
	qdel(src)
	var/datum/antagonist/changeling/changeling_data = changeling_ref?.resolve()
	changeling_data?.chorus_cocoon_detonated(user)

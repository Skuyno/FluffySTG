/datum/action/changeling/resonant_shriek
	name = "Resonant Shriek"
	desc = "Our lungs and vocal cords shift, allowing us to briefly emit a noise that deafens and confuses humans, causing them to lose some control over their movements. Best used to stop prey from escaping. Costs 20 chemicals."
	helptext = "Emits a high-frequency sound that confuses and deafens humans to hamper their movement, blows out nearby lights and overloads cyborg sensors."
	button_icon_state = "resonant_shriek"
	chemical_cost = 20
	dna_cost = 1
	req_human = TRUE
	disabled_by_fire = FALSE

//A flashy ability, good for crowd control and sowing chaos.
/datum/action/changeling/resonant_shriek/sting_action(mob/user)
	..()
	var/datum/antagonist/changeling/changeling_data = IS_CHANGELING(user)
	var/range_bonus = round(changeling_data?.get_genetic_matrix_effect("resonant_shriek_range_add", 0))
	var/effective_range = max(4 + range_bonus, 0)
	var/confusion_mult = changeling_data?.get_genetic_matrix_effect("resonant_shriek_confusion_mult", 1) || 1
	if(user.movement_type & VENTCRAWLING)
		user.balloon_alert(user, "can't shriek in pipes!")
		return FALSE
	for(var/mob/living/M in get_hearers_in_view(effective_range, user))
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(!IS_CHANGELING(C))
				var/obj/item/organ/ears/ears = C.get_organ_slot(ORGAN_SLOT_EARS)
				if(ears)
					ears.adjustEarDamage(0, 30)
				var/confusion_duration = round(25 SECONDS * confusion_mult)
				var/jitter_duration = round(100 SECONDS * confusion_mult)
				C.adjust_confusion(confusion_duration)
				C.set_jitter_if_lower(jitter_duration)
			else
				SEND_SOUND(C, sound('sound/effects/screech.ogg'))

		if(issilicon(M))
			SEND_SOUND(M, sound('sound/items/weapons/flash.ogg'))
			M.Paralyze(rand(100,200))

	for(var/obj/machinery/light/L in range(effective_range, user))
		L.on = TRUE
		L.break_light_tube()
		stoplag()
	return TRUE

/datum/action/changeling/dissonant_shriek
	name = "Dissonant Shriek"
	desc = "We shift our vocal cords to release a dissonant, high-frequency sound that overloads nearby electronics. Breaks headsets and cameras, and can sometimes break laser weaponry, doors, and modsuits. Costs 20 chemicals."
	button_icon_state = "dissonant_shriek"
	chemical_cost = 20
	dna_cost = 1
	disabled_by_fire = FALSE

/datum/action/changeling/dissonant_shriek/sting_action(mob/user)
	..()
	if(user.movement_type & VENTCRAWLING)
		user.balloon_alert(user, "can't shriek in pipes!")
		return FALSE
	var/datum/antagonist/changeling/changeling_data = IS_CHANGELING(user)
	var/emp_range_bonus = round(changeling_data?.get_genetic_matrix_effect("dissonant_shriek_emp_range_add", 0))
	var/heavy_range = max(2 + emp_range_bonus, 0)
	var/light_range = max(5 + emp_range_bonus, 0)
	empulse(get_turf(user), heavy_range, light_range, 1)
	for(var/obj/machinery/light/L in range(light_range, user))
		L.on = TRUE
		L.break_light_tube()
		stoplag()

	if(changeling_data?.matrix_predatory_howl_active)
		var/lethal_range = max(2 + emp_range_bonus, 0)
		var/structure_mult = changeling_data?.get_genetic_matrix_effect("dissonant_shriek_structure_mult", 1) || 1
		for(var/mob/living/victim in get_hearers_in_view(lethal_range, user))
			if(victim == user || IS_CHANGELING(victim))
				continue
			var/damage = victim.apply_damage(round(25 * structure_mult), BRUTE, BODY_ZONE_HEAD, forced = TRUE, wound_bonus = 15, sharpness = SHARP_POINTY)
			if(damage > 0)
				victim.visible_message(
					span_danger("[victim] reels as [user]'s killing tone tears through [victim.p_their()] skull!"),
					span_userdanger("A razor-edged resonance rips through your skull!"),
					span_hear("You hear a skull-splitting shriek!"),
				)
		for(var/obj/O in range(lethal_range, user))
			if(!O.uses_integrity)
				continue
			if(!istype(O, /obj/machinery) && !istype(O, /obj/structure))
				continue
			O.take_damage(round(40 * structure_mult), BRUTE, MELEE, TRUE, get_dir(O, user))

	return TRUE

/datum/action/changeling/regenerate
	name = "Regenerate"
	desc = "Allows us to regrow and restore missing external limbs and vital internal organs, as well as removing shrapnel, healing major wounds, and restoring blood volume. Costs 10 chemicals."
	helptext = "Will alert nearby crew if any external limbs are regenerated. Can be used while unconscious."
	button_icon_state = "regenerate"
	chemical_cost = 10
	dna_cost = CHANGELING_POWER_INNATE
	req_stat = HARD_CRIT

/datum/action/changeling/regenerate/sting_action(mob/living/user)
	if(!iscarbon(user))
		user.balloon_alert(user, "nothing missing!")
		return FALSE

	..()
	to_chat(user, span_notice("You feel an itching, both inside and outside as your tissues knit and reknit."))
	var/mob/living/carbon/carbon_user = user
	var/got_limbs_back = length(carbon_user.get_missing_limbs()) >= 1
	var/datum/antagonist/changeling/changeling_data = IS_CHANGELING(user)
	carbon_user.fully_heal(HEAL_BODY)
	if(changeling_data?.is_genetic_matrix_module_active("matrix_symbiotic_overgrowth"))
		var/needs_update = FALSE
		needs_update |= carbon_user.adjustBruteLoss(-50, updating_health = FALSE, forced = TRUE)
		needs_update |= carbon_user.adjustFireLoss(-50, updating_health = FALSE, forced = TRUE)
		needs_update |= carbon_user.adjustToxLoss(-40, forced = TRUE)
		needs_update |= carbon_user.adjustOxyLoss(-40, updating_health = FALSE, forced = TRUE)
		var/stam_delta = carbon_user.adjustStaminaLoss(-80, updating_stamina = FALSE)
		if(stam_delta)
			needs_update = TRUE
		if(needs_update)
			carbon_user.updatehealth()
	// Occurs after fully heal so the ling themselves can hear the sound effects (if deaf prior)
	if(got_limbs_back)
		playsound(user, 'sound/effects/magic/demon_consume.ogg', 50, TRUE)
		carbon_user.visible_message(
			span_warning("[user]'s missing limbs reform, making a loud, grotesque sound!"),
			span_userdanger("Your limbs regrow, making a loud, crunchy sound and giving you great pain!"),
			span_hear("You hear organic matter ripping and tearing!"),
		)
		carbon_user.emote("scream")

	return TRUE

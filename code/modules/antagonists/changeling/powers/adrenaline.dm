/datum/action/changeling/adrenaline
	name = "Gene Stim"
	desc = "We concentrate our chemicals into a potent stimulant, rendering our form stupendously robust against being incapacitated. Costs 25 chemicals."
	helptext = "Disregard any condition that has stunned us and suffuse our form with FOUR units of Changeling Adrenaline; our form recovers massive stamina and simply disregards any pain or fatigue during its effects."
	button_icon_state = "adrenaline"
	chemical_cost = 25 // similar cost to biodegrade, as they serve similar purposes
	dna_cost = 2
	req_human = FALSE
	req_stat = CONSCIOUS
	disabled_by_fire = TRUE

//Recover from stuns.
/datum/action/changeling/adrenaline/sting_action(mob/living/carbon/user)
	..()

	// Get us standing up.
	user.SetAllImmobility(0)
	user.setStaminaLoss(0)
	user.set_resting(FALSE, instant = TRUE)

	user.reagents.add_reagent(/datum/reagent/medicine/changelingadrenaline, 4) //Tank 5 consecutive baton hits

	to_chat(user, span_changeling("The staggering rush of a stimulant honed precisely to our biology is INVIGORATING. We will not be subdued."))

	var/datum/antagonist/changeling/changeling_data = IS_CHANGELING(user)
	changeling_data?.apply_matrix_adrenal_overdrive(user)
	changeling_data?.schedule_adrenal_spike_shockwave(user)
	changeling_data?.on_gene_stim_used(user)

	return TRUE

/datum/status_effect/changeling_adrenal_overdrive
	id = "changeling_adrenal_overdrive"
	status_type = STATUS_EFFECT_REFRESH
	duration = 5 SECONDS
	tick_interval = 0.5 SECONDS
	alert_type = null

	/// Cached changeling datum sustaining the overdrive.
	var/datum/antagonist/changeling/changeling_source

/datum/status_effect/changeling_adrenal_overdrive/on_creation(mob/living/new_owner, datum/antagonist/changeling/changeling_data)
	changeling_source = changeling_data
	return ..()

/datum/status_effect/changeling_adrenal_overdrive/refresh(mob/living/new_owner, datum/antagonist/changeling/changeling_data)
	if(changeling_data)
		changeling_source = changeling_data
	return ..()

/datum/status_effect/changeling_adrenal_overdrive/on_apply()
	return owner != null

/datum/status_effect/changeling_adrenal_overdrive/tick(seconds_between_ticks)
	if(owner.stat == DEAD)
		qdel(src)
		return
	owner.adjustStaminaLoss(-15)

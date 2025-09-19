/datum/action/changeling/sting/harvest_environment
	name = "Harvest Environment"
	desc = "Draws cytology samples from residue, surfaces, and simple organisms."
	helptext = "Use on swabbable surfaces or cultures to add their biomaterial to our stores."
	button_icon_state = "sting_extract"
	chemical_cost = 0
	dna_cost = CHANGELING_POWER_INNATE
	req_human = TRUE
	disabled_by_fire = FALSE
	var/harvest_time = 5 SECONDS

/datum/action/changeling/sting/harvest_environment/can_sting(mob/living/user, atom/target)
	if(!..())
		return
	if(!target || target == user)
		return
	if(!user.Adjacent(target))
		user.balloon_alert(user, "get closer!")
		return
	return TRUE

/datum/action/changeling/sting/harvest_environment/sting_action(mob/living/user, atom/target)
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
	if(!changeling)
		return FALSE

	if(!do_after(user, harvest_time, target, hidden = TRUE))
		user.balloon_alert(user, "interrupted!")
		return FALSE

	var/list/samples = list()
	var/result = SEND_SIGNAL(target, COMSIG_SWAB_FOR_SAMPLES, samples)
	if(!(result & COMPONENT_SWAB_FOUND) || !LAZYLEN(samples))
		user.balloon_alert(user, "sterile!")
		return FALSE

	var/list/harvested = changeling.harvest_biomaterials_from_samples(samples, target)
	if(!LAZYLEN(harvested))
		user.balloon_alert(user, "sterile!")
		return FALSE

	var/summary = changeling.build_harvest_summary(harvested)
	user.visible_message(span_notice("[user] collects biological residue from [target]!"), span_notice("We gather [summary]."))
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("Harvest Environment", "1"))
	return TRUE

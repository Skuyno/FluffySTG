
/datum/action/changeling/memory_archive
	name = "Memory Archivist"
	desc = "Hand off a captured dossier from a prior absorption."
	helptext = "Requires the Memory Archivist passive. Share with an adjacent target to brief them."
	button_icon_state = "mimic_voice"
	chemical_cost = 0
	dna_cost = CHANGELING_POWER_UNOBTAINABLE
	req_stat = CONSCIOUS
	disabled_by_fire = FALSE

/datum/action/changeling/memory_archive/sting_action(mob/living/user, mob/living/target)
	if(!target || !isliving(target))
		user.balloon_alert(user, "needs target")
		return FALSE
	var/datum/antagonist/changeling/changeling_data = IS_CHANGELING(user)
	if(!changeling_data?.matrix_memory_archivist_active)
		user.balloon_alert(user, "no archives")
		return FALSE
	return changeling_data.share_memory_fragment(user, target)

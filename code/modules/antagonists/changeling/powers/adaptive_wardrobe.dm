/datum/action/changeling/adaptive_wardrobe
	name = "Adaptive Wardrobe"
	desc = "We internalize the outfits of our prey, letting us mimic their wardrobe without manifesting fragile flesh clothing."
	helptext = "This ability is passive, allowing our transformations to project stolen clothing as disguising overlays instead of spawning flesh replicas."
	owner_has_control = FALSE
	dna_cost = 1

/datum/action/changeling/adaptive_wardrobe/on_purchase(mob/user, is_respec)
	. = ..()
	var/datum/antagonist/changeling/changeling_data = IS_CHANGELING(user)
	if(changeling_data)
		changeling_data.has_adaptive_wardrobe = TRUE

/datum/action/changeling/adaptive_wardrobe/Remove(mob/remove_from)
	var/mob/living/carbon/human/target = remove_from
	if(!target && istype(owner, /mob/living/carbon/human))
		target = owner
	var/datum/antagonist/changeling/changeling_data = IS_CHANGELING(target || owner)
	if(changeling_data)
		if(target)
			changeling_data.clear_clothing_disguise(target)
		else
			changeling_data.clear_clothing_disguise()
		changeling_data.has_adaptive_wardrobe = FALSE
	return ..()

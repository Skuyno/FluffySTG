/datum/action/changeling/sting/harvest_cells
	name = "Harvest Cells"
	desc = "We silently pierce a victim or sample to obtain cytology-ready cell lines."
	helptext = "Collects a cytology cell entry from living station species, barnyard animals, or cytology samples without alerting witnesses."
	button_icon_state = "sting_extract"
	chemical_cost = 10
	dna_cost = CHANGELING_POWER_INNATE
	allow_nonliving_targets = TRUE

/datum/action/changeling/sting/harvest_cells/can_sting(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(!target)
		return FALSE
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
	if(!changeling?.chosen_sting)
		to_chat(user, span_warning("We must prepare our sting before harvesting."))
		return FALSE
	if(changeling.chosen_sting != src)
		to_chat(user, span_warning("We have primed a different sting."))
		return FALSE
	if(target.mob_biotypes & MOB_ROBOTIC)
		user.balloon_alert(user, "no organic cells!")
		return FALSE
	if(!reachable_target(user, target, changeling?.sting_range || 0))
		return FALSE
	var/list/cell_ids = collect_cell_ids(target)
	if(!cell_ids.len)
		user.balloon_alert(user, "no viable cells!")
		return FALSE
	return TRUE

/datum/action/changeling/sting/harvest_cells/try_to_sting_nonliving(mob/living/user, atom/target)
	if(!can_harvest_nonliving(user, target))
		return FALSE
	if(disabled_by_fire && user.fire_stacks && user.on_fire)
		user.balloon_alert(user, "on fire!")
		return FALSE
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
	if(!perform_harvest(user, target))
		return FALSE
	changeling?.adjust_chemicals(-chemical_cost)
	user.changeNext_move(CLICK_CD_MELEE)
	return TRUE

/datum/action/changeling/sting/harvest_cells/sting_action(mob/living/user, mob/living/target)
	if(!perform_harvest(user, target))
		return FALSE
	..()
	return TRUE

/datum/action/changeling/sting/harvest_cells/sting_feedback(mob/living/user, mob/living/target)
	return TRUE

/datum/action/changeling/sting/harvest_cells/proc/can_harvest_nonliving(mob/living/user, atom/target)
	if(!target)
		return FALSE
	if(!can_use_harvest(user))
		return FALSE
	if(!isturf(user.loc))
		return FALSE
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
	if(!reachable_target(user, target, changeling?.sting_range || 0))
		return FALSE
	var/list/cell_ids = collect_cell_ids(target)
	if(!cell_ids.len)
		user.balloon_alert(user, "no viable cells!")
		return FALSE
	return TRUE

/datum/action/changeling/sting/harvest_cells/proc/reachable_target(mob/living/user, atom/target, range)
	if(!IN_GIVEN_RANGE(user, target, range))
		return FALSE
	var/list/path = get_path_to(user, target, max_distance = range, simulated_only = FALSE)
	return length(path) > 0

/datum/action/changeling/sting/harvest_cells/proc/perform_harvest(mob/living/user, atom/target)
	if(!target)
		return FALSE
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
	if(!changeling)
		return FALSE
	if(!changeling.bio_incubator)
		changeling.create_bio_incubator()
	var/datum/changeling_bio_incubator/incubator = changeling.bio_incubator
	var/list/cell_ids = collect_cell_ids(target)
	if(!cell_ids.len)
		user.balloon_alert(user, "no viable cells!")
		return FALSE
	var/newly_added = 0
	var/list/new_names = list()
	for(var/cell_id as anything in cell_ids)
		if(incubator.add_cell(cell_id))
			newly_added++
			new_names += incubator.get_nice_name_from_path(cell_id)
	if(!newly_added)
		user.balloon_alert(user, "already catalogued")
		return FALSE
	var/descriptor = get_target_descriptor(target)
	to_chat(user, span_notice("We stealthily harvest [english_list(new_names, "and")] from [descriptor]."))
	if(isliving(target))
		notify_target(target)
	return TRUE

/datum/action/changeling/sting/harvest_cells/proc/get_target_descriptor(atom/target)
	if(isliving(target))
		var/mob/living/living_target = target
		return living_target.name
	return target.name

/datum/action/changeling/sting/harvest_cells/proc/notify_target(mob/living/target)
	if(!target)
		return
	to_chat(target, span_warning("You feel a fleeting prick beneath your skin."))

/datum/action/changeling/sting/harvest_cells/proc/collect_cell_ids(atom/target)
	var/list/ids = list()
	if(!target)
		return ids

	var/swabbed = collect_cells_via_swab(target, ids)

	if(istype(target, /datum/biological_sample))
		for(var/cell_id as anything in collect_cells_from_sample(target))
			if(!(cell_id in ids))
				ids += cell_id
	else if(istype(target, /obj/item/petri_dish))
		var/obj/item/petri_dish/dish = target
		if(dish.sample)
			for(var/cell_id as anything in collect_cells_from_sample(dish.sample))
				if(!(cell_id in ids))
					ids += cell_id
	else if(istype(target, /obj/machinery/vatgrower))
		var/obj/machinery/vatgrower/vat = target
		if(vat.biological_sample)
			for(var/cell_id as anything in collect_cells_from_sample(vat.biological_sample))
				if(!(cell_id in ids))
					ids += cell_id

	if(isliving(target) && !swabbed)
		var/mob/living/living_target = target
		for(var/cell_id as anything in get_cell_id_from_living(living_target))
			if(!(cell_id in ids))
				ids += cell_id

	return ids

/datum/action/changeling/sting/harvest_cells/proc/collect_cells_via_swab(atom/target, list/ids)
	if(!target || !ids)
		return FALSE

	var/list/swabbed_samples = list()
	var/swab_result = SEND_SIGNAL(target, COMSIG_SWAB_FOR_SAMPLES, swabbed_samples)
	if(!(swab_result & COMPONENT_SWAB_FOUND))
		return FALSE

	for(var/datum/biological_sample/sample as anything in swabbed_samples)
		for(var/cell_id as anything in collect_cells_from_sample(sample))
			if(!(cell_id in ids))
				ids += cell_id
		qdel(sample)

	return TRUE

/datum/action/changeling/sting/harvest_cells/proc/collect_cells_from_sample(datum/biological_sample/sample)
	var/list/ids = list()
	if(!sample)
		return ids
	for(var/datum/micro_organism/microbe as anything in sample.micro_organisms)
		if(!istype(microbe, /datum/micro_organism/cell_line))
			continue
		var/datum/micro_organism/cell_line/cell_line = microbe
		var/cell_id = "[cell_line.type]"
		if(!(cell_id in ids))
			ids += cell_id
	return ids

/datum/action/changeling/sting/harvest_cells/proc/get_cell_id_from_living(mob/living/target)
	var/list/ids = list()
	if(!target)
		return ids

	var/cell_line_source = target.cell_line
	if(cell_line_source)
		if(istext(cell_line_source))
			var/list/cell_line_table = GLOB.cell_line_tables?[cell_line_source]
			if(islist(cell_line_table))
				for(var/datum/micro_organism/cell_line/cell_type as anything in cell_line_table)
					var/cell_id = "[cell_type]"
					if(!(cell_id in ids))
						ids += cell_id
		else if(ispath(cell_line_source, /datum/micro_organism/cell_line))
			var/cell_id = "[cell_line_source]"
			if(!(cell_id in ids))
				ids += cell_id

	if(ids.len)
		return ids

	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(!human_target.has_dna())
			return ids
		var/datum/species/species = human_target.dna?.species
		var/species_cell_line = species?.cell_line
		if(species_cell_line)
			if(istext(species_cell_line))
				var/list/species_cell_line_table = GLOB.cell_line_tables?[species_cell_line]
				if(islist(species_cell_line_table))
					for(var/datum/micro_organism/cell_line/cell_type as anything in species_cell_line_table)
						var/cell_id = "[cell_type]"
						if(!(cell_id in ids))
							ids += cell_id
			else if(ispath(species_cell_line, /datum/micro_organism/cell_line))
				var/cell_id = "[species_cell_line]"
				if(!(cell_id in ids))
					ids += cell_id

	return ids
/datum/action/changeling/sting/harvest_cells/proc/can_use_harvest(mob/living/user)
	if(!can_be_used_by(user))
		return FALSE
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
	if(!changeling)
		return FALSE
	if(!changeling.chosen_sting)
		to_chat(user, span_warning("We must prepare our sting before harvesting."))
		return FALSE
	if(changeling.chosen_sting != src)
		to_chat(user, span_warning("We have primed a different sting."))
		return FALSE
	if(changeling.chem_charges < chemical_cost)
		user.balloon_alert(user, "needs [chemical_cost] chemicals!")
		return FALSE
	if(changeling.absorbed_count < req_dna)
		user.balloon_alert(user, "needs [req_dna] dna sample\s!")
		return FALSE
	if(changeling.true_absorbs < req_absorbs)
		user.balloon_alert(user, "needs [req_absorbs] absorption\s!")
		return FALSE
	if(req_stat < user.stat)
		user.balloon_alert(user, "incapacitated!")
		return FALSE
	if((HAS_TRAIT(user, TRAIT_DEATHCOMA)) && (!ignores_fakedeath))
		user.balloon_alert(user, "playing dead!")
		return FALSE
	return TRUE

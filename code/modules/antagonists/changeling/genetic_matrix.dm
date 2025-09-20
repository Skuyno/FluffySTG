/// Coordinating datum for the changeling genetic matrix interface.
/datum/genetic_matrix
	var/name = "Genetic Matrix"
	var/datum/antagonist/changeling/changeling
	var/datum/changeling_bio_incubator/listened_incubator

/datum/genetic_matrix/New(datum/antagonist/changeling/changeling)
	. = ..()
	src.changeling = changeling
	register_with_incubator()

/datum/genetic_matrix/Destroy()
	unregister_from_incubator()
	changeling = null
	return ..()

/datum/genetic_matrix/proc/register_with_incubator()
	unregister_from_incubator()
	if(!changeling)
		return
	var/datum/changeling_bio_incubator/incubator = changeling.bio_incubator
	if(!incubator)
		return
	listened_incubator = incubator
	RegisterSignal(incubator, COMSIG_CHANGELING_BIO_INCUBATOR_UPDATED, PROC_REF(on_bio_incubator_updated))

/datum/genetic_matrix/proc/unregister_from_incubator()
	if(listened_incubator)
		UnregisterSignal(listened_incubator, COMSIG_CHANGELING_BIO_INCUBATOR_UPDATED)
		listened_incubator = null

/datum/genetic_matrix/proc/on_bio_incubator_updated(datum/changeling_bio_incubator/incubator, update_flags)
	SIGNAL_HANDLER
	if(QDELETED(src))
		return
	SStgui.update_uis(src)

/datum/genetic_matrix/ui_state(mob/user)
	return GLOB.always_state

/datum/genetic_matrix/ui_status(mob/user, datum/ui_state/state)
	if(!changeling)
		return UI_CLOSE
	return UI_INTERACTIVE

/datum/genetic_matrix/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GeneticMatrix", name)
		ui.open()

/datum/genetic_matrix/ui_static_data(mob/user)
	var/max_slots = 0
	var/max_builds = 0
	var/datum/changeling_bio_incubator/incubator = changeling?.bio_incubator
	if(incubator)
		max_slots = incubator.get_max_slots()
		max_builds = incubator.get_max_builds()
	return list(
		"maxModuleSlots" = max_slots,
		"maxAbilitySlots" = max_slots,
		"maxBuilds" = max_builds,
	)

/datum/genetic_matrix/ui_data(mob/user)
	var/list/data = list()
	if(!changeling)
		return data
	if(!changeling.bio_incubator)
		changeling.create_bio_incubator()
	register_with_incubator()
	var/datum/changeling_bio_incubator/incubator = changeling.bio_incubator
	changeling.ensure_genetic_matrix_setup()
	changeling.prune_genetic_matrix_assignments()
	data["builds"] = changeling.get_genetic_matrix_builds_data()
	data["resultCatalog"] = changeling.get_genetic_matrix_profile_catalog()
	var/list/module_catalog = changeling.get_genetic_matrix_module_catalog()
	data["moduleCatalog"] = module_catalog
	data["abilityCatalog"] = module_catalog
	var/list/module_storage = changeling.get_genetic_matrix_module_storage()
	data["modules"] = module_storage
	data["abilities"] = module_storage
	data["cells"] = changeling.get_genetic_matrix_profile_storage()
	data["cytologyCells"] = incubator ? incubator.get_cells_data() : list()
	data["recipes"] = incubator ? incubator.get_recipes_data() : list()
	data["skills"] = changeling.get_genetic_matrix_skills_data()
	data["canAddBuild"] = incubator ? incubator.can_add_build() : FALSE
	return data

/datum/genetic_matrix/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!changeling)
		return FALSE
	var/mob/user = ui.user
	var/datum/changeling_bio_incubator/incubator = changeling.bio_incubator
	switch(action)
		if("create_build")
			if(!incubator || !incubator.can_add_build())
				return FALSE
			var/default_name = "Matrix Build [incubator.builds.len + 1]"
			var/new_name = tgui_input_text(user, "Name the new build.", "Create Genetic Matrix Build", default_name, 32)
			if(isnull(new_name))
				return FALSE
			new_name = sanitize_text(new_name)
			if(!length(new_name))
				new_name = default_name
			changeling.add_genetic_matrix_build(new_name)
			return TRUE
		if("delete_build")
			var/datum/changeling_bio_incubator/build/build = changeling.find_genetic_matrix_build(params["build"])
			if(!build)
				return FALSE
			if(tgui_alert(user, "Delete build \"[build.name]\"?", "Remove Build", list("Delete", "Cancel")) != "Delete")
				return FALSE
			changeling.remove_genetic_matrix_build(build)
			return TRUE
		if("rename_build")
			var/datum/changeling_bio_incubator/build/build = changeling.find_genetic_matrix_build(params["build"])
			if(!build)
				return FALSE
			var/new_name = tgui_input_text(user, "Enter a new name for this build.", "Rename Build", build.name, 32)
			if(isnull(new_name))
				return FALSE
			new_name = sanitize_text(new_name)
			if(!length(new_name))
				return FALSE
			build.name = new_name
			build.bio_incubator?.notify_update()
			return TRUE
		if("clear_build")
			var/datum/changeling_bio_incubator/build/build = changeling.find_genetic_matrix_build(params["build"])
			if(!build)
				return FALSE
			changeling.clear_genetic_matrix_build(build)
			return TRUE
		if("set_build_profile")
			var/datum/changeling_bio_incubator/build/build = changeling.find_genetic_matrix_build(params["build"])
			if(!build)
				return FALSE
			var/datum/changeling_profile/profile = changeling.find_genetic_matrix_profile(params["profile"])
			changeling.assign_genetic_matrix_profile(build, profile)
			return TRUE
		if("clear_build_profile")
			var/datum/changeling_bio_incubator/build/build = changeling.find_genetic_matrix_build(params["build"])
			if(!build)
				return FALSE
			changeling.assign_genetic_matrix_profile(build, null)
			return TRUE
		if("set_build_module", "set_build_ability")
			var/datum/changeling_bio_incubator/build/build = changeling.find_genetic_matrix_build(params["build"])
			if(!build)
				return FALSE
			var/max_slots = incubator ? incubator.get_max_slots() : 0
			var/slot = clamp(text2num(params["slot"]), 1, max_slots)
			if(!slot)
				return FALSE
			var/module_identifier = params["module"]
			if(isnull(module_identifier))
				module_identifier = params["ability"]
			if(!module_identifier)
				changeling.assign_genetic_matrix_module(build, null, slot)
				return TRUE
			return changeling.assign_genetic_matrix_module(build, module_identifier, slot)
		if("clear_build_module", "clear_build_ability")
			var/datum/changeling_bio_incubator/build/build = changeling.find_genetic_matrix_build(params["build"])
			if(!build)
				return FALSE
			var/max_slots = incubator ? incubator.get_max_slots() : 0
			var/slot = clamp(text2num(params["slot"]), 1, max_slots)
			if(!slot)
				return FALSE
			changeling.assign_genetic_matrix_module(build, null, slot)
			return TRUE
	return FALSE

/datum/action/changeling/genetic_matrix
	name = "Genetic Matrix"
	button_icon_state = "sting_transform"
	background_icon_state = "bg_changeling"
	overlay_icon_state = "bg_changeling_border"
	check_flags = NONE

/datum/action/changeling/genetic_matrix/New(Target)
	. = ..()
	if(!istype(Target, /datum/genetic_matrix))
		stack_trace("genetic_matrix action created with non-matrix target.")
		qdel(src)

/datum/action/changeling/genetic_matrix/Trigger(mob/clicker, trigger_flags)
	if(!(trigger_flags & TRIGGER_FORCE_AVAILABLE) && !IsAvailable(feedback = TRUE))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_ACTION_TRIGGER, src) & COMPONENT_ACTION_BLOCK_TRIGGER)
		return FALSE
	var/datum/genetic_matrix/matrix = target
	if(!matrix)
		return FALSE
	matrix.ui_interact(owner)
	return TRUE

/// Ensure that the matrix data structures exist and have at least one build configured.
/datum/antagonist/changeling/proc/ensure_genetic_matrix_setup()
	bio_incubator?.ensure_default_build()

/// Remove invalid references from matrix builds.
/datum/antagonist/changeling/proc/prune_genetic_matrix_assignments()
	bio_incubator?.prune_assignments()

/// Generate data for the matrix builds to send to the UI.
/datum/antagonist/changeling/proc/get_genetic_matrix_builds_data()
	var/list/output = list()
	var/datum/changeling_bio_incubator/incubator = bio_incubator
	if(!incubator)
		return output
	return incubator.get_builds_data()

/// Produce a sortable profile dataset for quick access on the matrix tab.
/datum/antagonist/changeling/proc/get_genetic_matrix_profile_catalog()
	var/list/catalog = list()
	if(!stored_profiles)
		return catalog
	for(var/datum/changeling_profile/profile as anything in stored_profiles)
		catalog += list(get_genetic_matrix_profile_data(profile))
	sortTim(catalog, GLOBAL_PROC_REF(cmp_assoc_list_name))
	return catalog

/// Provide profile data for the storage tab.
/datum/antagonist/changeling/proc/get_genetic_matrix_profile_storage()
	return get_genetic_matrix_profile_catalog()

/// Aggregate module information available to the changeling.
/datum/antagonist/changeling/proc/get_genetic_matrix_module_catalog()
	var/list/catalog = list()
	var/list/seen_ids = list()
	if(bio_incubator)
		for(var/list/entry as anything in bio_incubator.get_crafted_module_catalog())
			var/id = entry["id"]
			if(!id)
				continue
			catalog += list(entry.Copy())
			seen_ids[id] = TRUE
	for(var/datum/action/changeling/innate as anything in innate_powers)
		var/path = innate.type
		if(!ispath(path) || seen_ids["[path]"])
			continue
		var/list/data = get_genetic_matrix_module_data_from_path(path)
		if(!data)
			continue
		data["source"] = "innate"
		catalog += list(data)
		seen_ids[data["id"]] = TRUE
	for(var/path in purchased_powers)
		var/id = "[path]"
		if(seen_ids[id])
			continue
		var/list/data = get_genetic_matrix_module_data_from_path(path)
		if(!data)
			continue
		data["source"] = "purchased"
		catalog += list(data)
		seen_ids[id] = TRUE
	sortTim(catalog, GLOBAL_PROC_REF(cmp_assoc_list_name))
	return catalog

/// Provide detailed module data for the storage tab.
/datum/antagonist/changeling/proc/get_genetic_matrix_module_storage()
	return get_genetic_matrix_module_catalog()

/// Return a dataset summarizing the owner's skills.
/datum/antagonist/changeling/proc/get_genetic_matrix_skills_data()
	var/list/data = list()
	if(!owner)
		return data
	var/datum/mind/mind = owner
	if(!mind.known_skills)
		return data
	for(var/skill_type in mind.known_skills)
		var/datum/skill/skill_datum = skill_type
		var/level = mind.get_skill_level(skill_type)
		var/list/entry = list(
			"id" = "[skill_type]",
			"name" = initial(skill_datum.name),
			"level" = level,
			"levelName" = mind.get_skill_level_name(skill_type),
			"exp" = mind.get_skill_exp(skill_type),
			"desc" = initial(skill_datum.desc),
		)
		data += list(entry)
	sortTim(data, GLOBAL_PROC_REF(cmp_assoc_list_name))
	return data

/// Add a new matrix build for this changeling.
/datum/antagonist/changeling/proc/add_genetic_matrix_build(name)
	return bio_incubator ? bio_incubator.add_build(name) : null

/// Remove and clean up an existing matrix build.
/datum/antagonist/changeling/proc/remove_genetic_matrix_build(datum/changeling_bio_incubator/build/build)
	bio_incubator?.remove_build(build)

/// Clear all assignments from a specific build without deleting it.
/datum/antagonist/changeling/proc/clear_genetic_matrix_build(datum/changeling_bio_incubator/build/build)
	bio_incubator?.clear_build(build)

/// Assign a DNA profile to a build.
/datum/antagonist/changeling/proc/assign_genetic_matrix_profile(datum/changeling_bio_incubator/build/build, datum/changeling_profile/profile)
	bio_incubator?.assign_profile(build, profile)

/// Assign a module to a slot within a build. Passing null clears the slot.
/datum/antagonist/changeling/proc/assign_genetic_matrix_module(datum/changeling_bio_incubator/build/build, module_identifier, slot)
	return bio_incubator ? bio_incubator.assign_module(build, module_identifier, slot) : FALSE

/// Determine whether the changeling currently possesses a given module identifier.
/datum/antagonist/changeling/proc/has_genetic_matrix_module(module_identifier)
	if(isnull(module_identifier))
		return FALSE
	var/id_text = bio_incubator?.sanitize_module_id(module_identifier)
	if(!id_text)
		return FALSE
	if(bio_incubator?.has_module(id_text))
		return TRUE
	var/path = text2path(id_text)
	if(ispath(path, /datum/action/changeling))
		if(purchased_powers && purchased_powers[path])
			return TRUE
		for(var/datum/action/changeling/innate as anything in innate_powers)
			if(innate.type == path)
				return TRUE
	return FALSE

/// Locate a matrix build using its reference string.
/datum/antagonist/changeling/proc/find_genetic_matrix_build(identifier)
	return bio_incubator ? bio_incubator.find_build(identifier) : null

/// Locate a stored profile using its reference string.
/datum/antagonist/changeling/proc/find_genetic_matrix_profile(identifier)
	if(isnull(identifier))
		return null
	for(var/datum/changeling_profile/profile as anything in stored_profiles)
		if(REF(profile) == identifier)
			return profile
	return null

/// Convert a stored profile to UI-friendly data.
/datum/antagonist/changeling/proc/get_genetic_matrix_profile_data(datum/changeling_profile/profile)
	var/list/quirk_names = list()
	for(var/datum/quirk/quirk as anything in profile.quirks)
		quirk_names += initial(quirk.name)
	var/list/skillchip_names = list()
	for(var/list/chip_metadata in profile.skillchips)
		var/chip_type = chip_metadata["type"]
		if(ispath(chip_type, /obj/item/skillchip))
			var/obj/item/skillchip/skillchip_type = chip_type
			skillchip_names += initial(skillchip_type.name)
		else if(chip_type)
			skillchip_names += "[chip_type]"
	return list(
		"id" = REF(profile),
		"name" = profile.name,
		"protected" = profile.protected,
		"age" = profile.age,
		"physique" = profile.physique,
		"voice" = profile.voice,
		"quirks" = quirk_names,
		"quirk_count" = quirk_names.len,
		"skillchips" = skillchip_names,
		"skillchip_count" = skillchip_names.len,
		"scar_count" = LAZYLEN(profile.stored_scars),
		"id_icon" = profile.id_icon,
	)

/// Convert an ability type path to UI-friendly data for compatibility.
/datum/antagonist/changeling/proc/get_genetic_matrix_module_data_from_path(datum/action/changeling/ability_path)
	if(isnull(ability_path))
		return null
	var/list/data = list(
		"id" = "[ability_path]",
		"name" = initial(ability_path.name),
		"desc" = initial(ability_path.desc),
		"helptext" = initial(ability_path.helptext),
		"chemical_cost" = initial(ability_path.chemical_cost),
		"dna_cost" = initial(ability_path.dna_cost),
		"req_dna" = initial(ability_path.req_dna),
		"req_absorbs" = initial(ability_path.req_absorbs),
		"button_icon_state" = initial(ability_path.button_icon_state),
	)
	return data

/// Legacy helper for callers expecting the old name.
/datum/antagonist/changeling/proc/get_genetic_matrix_ability_data(datum/action/changeling/ability_path)
	return get_genetic_matrix_module_data_from_path(ability_path)

/// Handle updates when a new DNA profile is added.
/datum/antagonist/changeling/proc/on_genetic_matrix_profile_added(datum/changeling_profile/profile)
	ensure_genetic_matrix_setup()
	if(!bio_incubator)
		return
	for(var/datum/changeling_bio_incubator/build/build as anything in bio_incubator.builds)
		if(!build.assigned_profile)
			build.assigned_profile = profile
			bio_incubator.notify_update(BIO_INCUBATOR_UPDATE_BUILDS)
			break

/// Handle updates when a DNA profile is removed.
/datum/antagonist/changeling/proc/on_genetic_matrix_profile_removed(datum/changeling_profile/profile)
	if(!bio_incubator)
		return
	var/changed = FALSE
	for(var/datum/changeling_bio_incubator/build/build as anything in bio_incubator.builds)
		if(build.assigned_profile == profile)
			build.assigned_profile = null
			changed = TRUE
	if(changed)
		bio_incubator.notify_update(BIO_INCUBATOR_UPDATE_BUILDS)

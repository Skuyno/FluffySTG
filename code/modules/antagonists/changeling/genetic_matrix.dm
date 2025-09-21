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
	changeling.update_genetic_matrix_unlocks()
	changeling.prune_genetic_matrix_assignments()
	data["builds"] = changeling.get_genetic_matrix_builds_data()
	data["modules"] = changeling.get_genetic_matrix_module_catalog()
	data["abilities"] = changeling.get_genetic_matrix_ability_catalog()
	data["cells"] = incubator ? incubator.get_cells_data() : list()
	data["recipes"] = changeling.get_genetic_matrix_recipe_data()
	data["standardAbilities"] = changeling.get_standard_ability_catalog()
	data["geneticPoints"] = changeling.genetic_points
	data["absorbs"] = changeling.true_absorbs
	data["dnaSamples"] = changeling.absorbed_count
        data["canReadapt"] = changeling.can_respec
        data["isReconfiguring"] = changeling.is_genetic_matrix_reconfiguring()
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
                if("clear_build")
                        var/datum/changeling_bio_incubator/build/build = changeling.find_genetic_matrix_build(params["build"])
                        if(!build)
                                return FALSE
                        changeling.clear_genetic_matrix_build(build)
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
		if("craft_module")
			var/recipe_id = params["recipe"]
			if(!recipe_id)
				return FALSE
			return changeling.craft_genetic_matrix_module(recipe_id)
		if("purchase_standard")
                        var/ability_id = params["ability"]
                        if(!ability_id)
                                return FALSE
                        var/datum/action/changeling/ability_path = text2path(ability_id)
                        if(!ispath(ability_path, /datum/action/changeling))
                                return FALSE
                        return changeling.purchase_power(ability_path)
                if("readapt_standard")
                        return changeling.readapt()
                if("commit_build")
                        var/datum/changeling_bio_incubator/build/build = changeling.find_genetic_matrix_build(params["build"])
                        if(!build)
                                return FALSE
                        return changeling.commit_genetic_matrix_build(build, user)
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

/// Aggregate crafted module information available to the changeling.
/datum/antagonist/changeling/proc/get_genetic_matrix_module_catalog()
	var/list/catalog = list()
	if(!bio_incubator)
		return catalog
	for(var/list/entry as anything in bio_incubator.get_crafted_module_catalog())
		if(!islist(entry))
			continue
		var/list/copy = entry.Copy()
		copy["crafted"] = TRUE
		catalog += list(copy)
	sortTim(catalog, GLOBAL_PROC_REF(cmp_assoc_list_name))
	return catalog

/// Aggregate ability information for display.
/datum/antagonist/changeling/proc/get_genetic_matrix_ability_catalog()
	var/list/catalog = list()
	var/list/seen = list()
	for(var/datum/action/changeling/innate as anything in innate_powers)
		var/path = innate.type
		if(!ispath(path, /datum/action/changeling))
			continue
		var/id = "[path]"
		if(seen[id])
			continue
		var/list/data = get_genetic_matrix_module_data_from_path(path)
		if(!data)
			continue
		if(!data["id"])
			data["id"] = id
		data["source"] = "innate"
		data["category"] = "ability"
		data["slotType"] = BIO_INCUBATOR_SLOT_FLEX
		if(!islist(data["tags"]))
			data["tags"] = list()
		if(!islist(data["exclusiveTags"]))
			data["exclusiveTags"] = list()
		catalog += list(data)
		seen[id] = TRUE
	for(var/path in purchased_powers)
		var/id = "[path]"
		if(seen[id])
			continue
		var/list/data = get_genetic_matrix_module_data_from_path(path)
		if(!data)
			continue
		if(!data["id"])
			data["id"] = id
		data["source"] = "purchased"
		data["category"] = "ability"
		data["slotType"] = BIO_INCUBATOR_SLOT_FLEX
		if(!islist(data["tags"]))
			data["tags"] = list()
		if(!islist(data["exclusiveTags"]))
			data["exclusiveTags"] = list()
		catalog += list(data)
		seen[id] = TRUE
	sortTim(catalog, GLOBAL_PROC_REF(cmp_assoc_list_name))
	return catalog

/// Produce the list of standard purchasable abilities for the Standard Skills tab.
/datum/antagonist/changeling/proc/get_standard_ability_catalog()
	var/list/catalog = list()
	for(var/datum/action/changeling/ability_path as anything in all_powers)
		var/dna_cost = initial(ability_path.dna_cost)
		if(dna_cost < 0 || dna_cost == CHANGELING_POWER_INNATE)
			continue
		var/list/entry = list(
			"id" = "[ability_path]",
			"name" = initial(ability_path.name),
			"desc" = initial(ability_path.desc),
			"helptext" = initial(ability_path.helptext),
			"dnaCost" = dna_cost,
			"absorbsRequired" = initial(ability_path.req_absorbs),
			"dnaRequired" = initial(ability_path.req_dna),
			"chemicalCost" = initial(ability_path.chemical_cost),
			"button_icon_state" = initial(ability_path.button_icon_state),
		)
		entry["owned"] = has_changeling_ability(ability_path)
		entry["hasPoints"] = genetic_points >= dna_cost
		entry["hasAbsorbs"] = true_absorbs >= entry["absorbsRequired"]
		entry["hasDNA"] = absorbed_count >= entry["dnaRequired"]
		catalog += list(entry)
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

/// Assign a module to a slot within a build. Passing null clears the slot.
/datum/antagonist/changeling/proc/assign_genetic_matrix_module(datum/changeling_bio_incubator/build/build, module_identifier, slot)
	return bio_incubator ? bio_incubator.assign_module(build, module_identifier, slot) : FALSE

/// Determine whether the changeling currently possesses a given crafted module identifier.
/datum/antagonist/changeling/proc/has_genetic_matrix_module(module_identifier)
	if(isnull(module_identifier))
		return FALSE
	if(!bio_incubator)
		return FALSE
	var/id_text = bio_incubator.sanitize_module_id(module_identifier)
	if(!id_text)
		return FALSE
	return bio_incubator.has_module(id_text)

/// Determine whether the changeling currently possesses a given ability.
/datum/antagonist/changeling/proc/has_changeling_ability(ability_identifier)
	if(isnull(ability_identifier))
		return FALSE
	var/datum/action/changeling/ability_path
	if(ispath(ability_identifier, /datum/action/changeling))
		ability_path = ability_identifier
	else if(istext(ability_identifier))
		ability_path = text2path(ability_identifier)
	else
		return FALSE
	if(!ability_path)
		return FALSE
	if(purchased_powers[ability_path])
		return TRUE
	for(var/datum/action/changeling/power as anything in innate_powers)
		if(power.type == ability_path)
			return TRUE
	return FALSE

/// Determine whether the changeling has collected a specific cytology cell identifier.
/datum/antagonist/changeling/proc/has_cytology_cell(cell_identifier)
	if(isnull(cell_identifier) || !bio_incubator)
		return FALSE
	var/cell_id = changeling_normalize_cell_id(cell_identifier)
	if(!cell_id)
		return FALSE
	return cell_id in bio_incubator.cell_ids

/// Check if a recipe's requirements are satisfied by our inventory.
/datum/antagonist/changeling/proc/can_access_genetic_recipe(list/recipe_data)
	if(!islist(recipe_data))
		return FALSE
	var/list/required_cells = recipe_data["requiredCells"]
	if(islist(required_cells))
		for(var/cell_id in required_cells)
			if(!has_cytology_cell(cell_id))
				return FALSE
	var/list/required_abilities = recipe_data["requiredAbilities"]
	if(islist(required_abilities))
		for(var/ability_id in required_abilities)
			if(!has_changeling_ability(ability_id))
				return FALSE
	return TRUE

/// Generate recipe metadata for the UI.
/datum/antagonist/changeling/proc/get_genetic_matrix_recipe_data()
	var/list/output = list()
	var/datum/changeling_bio_incubator/incubator = bio_incubator
	for(var/recipe_key in GLOB.changeling_genetic_matrix_recipes)
		var/list/recipe = GLOB.changeling_genetic_matrix_recipes[recipe_key]
		if(!islist(recipe))
			continue
		var/id_text = recipe["id"]
		if(isnull(id_text))
			id_text = recipe_key
		var/sanitized_id = incubator ? incubator.sanitize_module_id(id_text) : "[id_text]"
		var/list/entry = list(
			"id" = sanitized_id,
			"name" = recipe["name"],
			"desc" = recipe["desc"],
		)
		var/list/module_block = null
		if(islist(recipe["module"]))
			module_block = recipe["module"].Copy()
			if(isnull(module_block["id"]))
				module_block["id"] = sanitized_id
			if(incubator)
				module_block["id"] = incubator.sanitize_module_id(module_block["id"])
				module_block["slotType"] = incubator.sanitize_slot_type(module_block["slotType"])
				module_block["category"] = incubator.sanitize_category(module_block["category"])
				module_block["tags"] = incubator.sanitize_tag_list(module_block["tags"])
				module_block["exclusiveTags"] = incubator.sanitize_tag_list(module_block["exclusiveTags"])
		entry["module"] = module_block
		var/list/cell_entries = list()
		var/list/required_cells = recipe["requiredCells"]
		if(islist(required_cells))
			for(var/cell_id in required_cells)
				var/text_id = changeling_normalize_cell_id(cell_id)
				if(isnull(text_id))
					text_id = incubator ? incubator.sanitize_module_id(cell_id) : "[cell_id]"
				cell_entries += list(list(
					"id" = text_id,
					"name" = changeling_get_cell_display_name(cell_id),
					"have" = has_cytology_cell(cell_id),
				))
		entry["requiredCells"] = cell_entries
		var/list/ability_entries = list()
		var/list/required_abilities = recipe["requiredAbilities"]
		if(islist(required_abilities))
			for(var/ability_path in required_abilities)
				var/list/ability_data = get_genetic_matrix_module_data_from_path(ability_path)
				if(!islist(ability_data))
					var/nice_name = incubator ? incubator.get_nice_name_from_path(ability_path) : changeling_get_nice_name_from_path(ability_path)
					ability_data = list("name" = nice_name)
				ability_entries += list(list(
					"id" = "[ability_path]",
					"name" = ability_data["name"],
					"desc" = ability_data["desc"],
					"have" = has_changeling_ability(ability_path),
				))
		entry["requiredAbilities"] = ability_entries
		entry["unlocked"] = can_access_genetic_recipe(recipe)
		entry["learned"] = incubator ? (sanitized_id in incubator.recipe_ids) : FALSE
		var/module_id = module_block ? module_block["id"] : sanitized_id
		entry["crafted"] = incubator ? incubator.has_module(module_id) : FALSE
		output += list(entry)
	return output

/// Attempt to craft a module unlocked by a recipe.
/datum/antagonist/changeling/proc/craft_genetic_matrix_module(recipe_identifier)
	if(!bio_incubator)
		create_bio_incubator()
	var/datum/changeling_bio_incubator/incubator = bio_incubator
	if(!incubator)
		return FALSE
	var/sanitized_id = incubator.sanitize_module_id(recipe_identifier)
	if(!sanitized_id)
		return FALSE
	var/list/recipe = GLOB.changeling_genetic_matrix_recipes[sanitized_id]
	if(!islist(recipe))
		for(var/list/entry in GLOB.changeling_genetic_matrix_recipes)
			if(!islist(entry))
				continue
			var/entry_id = entry["id"]
			if(isnull(entry_id))
				continue
			if(incubator.sanitize_module_id(entry_id) == sanitized_id)
				recipe = entry
				break
	if(!islist(recipe))
		return FALSE
	if(!can_access_genetic_recipe(recipe))
		return FALSE
	var/list/module_block = recipe["module"]
	if(!islist(module_block))
		return FALSE
	var/module_id = module_block["id"]
	if(isnull(module_id))
		module_id = sanitized_id
	module_id = incubator.sanitize_module_id(module_id)
	if(incubator.has_module(module_id))
		var/mob/living/user = owner?.current
		user?.balloon_alert(user, "already crafted")
		return FALSE
	var/list/module_copy = module_block.Copy()
	module_copy["id"] = module_id
	if(!incubator.register_module(module_id, module_copy))
		return FALSE
	var/mob/living/user = owner?.current
	if(user)
		to_chat(user, span_notice("We weave [module_copy["name"]] into our genetic matrix."))
	return TRUE

/// Synchronize recipe unlocks with the contents of our incubator.
/datum/antagonist/changeling/proc/update_genetic_matrix_unlocks()
	if(!bio_incubator)
		return
	var/datum/changeling_bio_incubator/incubator = bio_incubator
	for(var/recipe_key in GLOB.changeling_genetic_matrix_recipes)
		var/list/recipe = GLOB.changeling_genetic_matrix_recipes[recipe_key]
		if(!islist(recipe))
			continue
		var/id_text = recipe["id"]
		if(isnull(id_text))
			id_text = recipe_key
		var/sanitized_id = incubator.sanitize_module_id(id_text)
		if(!sanitized_id)
			continue
		if(can_access_genetic_recipe(recipe))
			incubator.add_recipe(sanitized_id)
		else
			incubator.remove_recipe(sanitized_id)

/// Locate a matrix build using its reference string.
/datum/antagonist/changeling/proc/find_genetic_matrix_build(identifier)
	return bio_incubator ? bio_incubator.find_build(identifier) : null

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


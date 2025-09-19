#include "changeling_crafting.dm"

// Genetic Matrix -
// The place where Changelings reorganize their genomes.
/datum/genetic_matrix
	/// The name of the matrix interface.
	var/name = "genetic matrix"
	/// The changeling who owns this matrix.
	var/datum/antagonist/changeling/changeling
	/// Cached result of the most recent crafting attempt.
	var/list/last_crafting_result

/datum/genetic_matrix/New(my_changeling)
	. = ..()
	changeling = my_changeling

/datum/genetic_matrix/Destroy()
	changeling = null
	last_crafting_result = null
	return ..()

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
	var/list/data = list()
	data["abilities"] = get_ability_catalog()
	data["crafting_recipes"] = build_crafting_recipe_payload()
	return data

/datum/genetic_matrix/ui_data(mob/user)
	var/list/data = list()

	data["can_readapt"] = changeling.can_respec
	data["owned_abilities"] = assoc_to_keys(changeling.purchased_powers)
	data["genetic_points_count"] = changeling.genetic_points
	data["total_genetic_points"] = changeling.total_genetic_points
	data["absorb_count"] = changeling.true_absorbs
	data["dna_count"] = changeling.absorbed_count
	data["chem_charges"] = changeling.chem_charges
	data["chem_storage"] = changeling.total_chem_storage
	data["chem_recharge_rate"] = changeling.chem_recharge_rate
	data["chem_recharge_slowdown"] = changeling.chem_recharge_slowdown
	data["active_effects"] = build_active_effects()
	var/list/catalog = get_ability_catalog()
	data["synergy_tips"] = build_synergy_tips(catalog)
	data["incompatibilities"] = collect_incompatibilities(catalog)
	data["presets"] = build_preset_payload()
	data["preset_limit"] = changeling.max_genetic_presets
	data["active_build"] = changeling.export_active_build_state()
	data["biomaterials"] = changeling.build_biomaterial_payload()
	data["signature_cells"] = changeling.build_signature_payload()
	if(islist(last_crafting_result))
		data["crafting_result"] = last_crafting_result.Copy()
	else
		data["crafting_result"] = null

	return data

/datum/genetic_matrix/proc/get_ability_catalog()
	var/static/list/abilities
	if(!abilities)
		abilities = list()

		for(var/datum/action/changeling/ability_path as anything in changeling.all_powers)

			var/dna_cost = initial(ability_path.dna_cost)

			if(dna_cost < 0)
				continue

			var/list/ability_data = list()
			ability_data["name"] = initial(ability_path.name)
			ability_data["desc"] = initial(ability_path.desc)
			ability_data["path"] = ability_path
			ability_data["helptext"] = initial(ability_path.helptext)
			ability_data["genetic_point_required"] = dna_cost
			ability_data["absorbs_required"] = initial(ability_path.req_absorbs)
			ability_data["dna_required"] = initial(ability_path.req_dna)
			ability_data["chemical_cost"] = initial(ability_path.chemical_cost)
			ability_data["req_human"] = initial(ability_path.req_human)
			ability_data["req_stat"] = initial(ability_path.req_stat)
			ability_data["disabled_by_fire"] = initial(ability_path.disabled_by_fire)

			abilities += list(ability_data)

		// Sorts abilities alphabetically by default
		sortTim(abilities, /proc/cmp_assoc_list_name)

	return abilities

/datum/genetic_matrix/proc/build_active_effects()
	var/list/effects = list()

	for(var/datum/action/changeling/power as anything in changeling.innate_powers)
		if(!istype(power))
			continue

		var/list/entry = list()
		entry["name"] = power.name
		entry["desc"] = power.desc
		entry["helptext"] = power.helptext
		entry["path"] = power.type
		entry["chemical_cost"] = power.chemical_cost
		entry["dna_cost"] = power.dna_cost
		entry["req_absorbs"] = power.req_absorbs
		entry["req_dna"] = power.req_dna
		entry["innate"] = TRUE
		effects += list(entry)

	for(var/power_path in changeling.purchased_powers)
		var/datum/action/changeling/power = changeling.purchased_powers[power_path]
		if(!istype(power))
			continue

		var/list/effect = list()
		effect["name"] = power.name
		effect["desc"] = power.desc
		effect["helptext"] = power.helptext
		effect["path"] = power_path
		effect["chemical_cost"] = power.chemical_cost
		effect["dna_cost"] = power.dna_cost
		effect["req_absorbs"] = power.req_absorbs
		effect["req_dna"] = power.req_dna
		effect["innate"] = FALSE
		effects += list(effect)

	return effects

/datum/genetic_matrix/proc/build_synergy_tips(list/catalog)
	var/list/tips = list()

	var/list/low_cost = list()
	var/list/chem_hungry = list()
	var/list/absorb_targets = list()
	var/list/dna_targets = list()

	var/next_absorb_target
	var/list/next_absorb_names = list()
	var/next_dna_target
	var/list/next_dna_names = list()

	for(var/list/ability_data as anything in catalog)
		var/name = ability_data["name"]
		var/cost = ability_data["genetic_point_required"]
		var/chem_cost = ability_data["chemical_cost"]
		var/absorb_req = ability_data["absorbs_required"]
		var/dna_req = ability_data["dna_required"]

		if(cost <= 1)
			low_cost += name

		if(chem_cost >= 25)
			chem_hungry += "[name] ([chem_cost] chems)"

		if(absorb_req > changeling.true_absorbs)
			if(isnull(next_absorb_target) || absorb_req < next_absorb_target)
				next_absorb_target = absorb_req
				next_absorb_names = list(name)
			else if(absorb_req == next_absorb_target)
				next_absorb_names += name

		if(dna_req > changeling.absorbed_count)
			if(isnull(next_dna_target) || dna_req < next_dna_target)
				next_dna_target = dna_req
				next_dna_names = list(name)
			else if(dna_req == next_dna_target)
				next_dna_names += name

	if(length(low_cost))
		var/list/tip = list()
		tip["title"] = "Foundational Sequences"
		tip["description"] = "Low cost evolutions ideal for establishing a toolkit."
		tip["abilities"] = low_cost.Copy(1, min(length(low_cost) + 1, 7))
		tips += list(tip)

	if(next_absorb_target)
		var/list/absorb_tip = list()
		var/needed = max(0, next_absorb_target - changeling.true_absorbs)
		absorb_tip["title"] = "Absorption Milestone"
		absorb_tip["description"] = "Absorb [needed] more host[needed == 1 ? "" : "s"] to unlock:"
		absorb_tip["abilities"] = next_absorb_names
		tips += list(absorb_tip)

	if(next_dna_target)
		var/list/dna_tip = list()
		var/dna_needed = max(0, next_dna_target - changeling.absorbed_count)
		dna_tip["title"] = "DNA Threshold"
		dna_tip["description"] = "Harvest [dna_needed] additional DNA sample[dna_needed == 1 ? "" : "s"] to access:"
		dna_tip["abilities"] = next_dna_names
		tips += list(dna_tip)

	if(length(chem_hungry))
		var/list/chem_tip = list()
		chem_tip["title"] = "Chemical Investments"
		chem_tip["description"] = "Maintain chemical reserves ([changeling.chem_charges]/[changeling.total_chem_storage]) to leverage:"
		chem_tip["abilities"] = chem_hungry.Copy(1, min(length(chem_hungry) + 1, 6))
		tips += list(chem_tip)

	return tips

/datum/genetic_matrix/proc/collect_incompatibilities(list/catalog)
	var/list/warnings = list()

	if(!changeling.can_respec)
		warnings += "Absorb additional genomes to enable readaptation."

	var/list/points_short = list()
	var/list/absorb_short = list()
	var/list/dna_short = list()

	for(var/list/ability_data as anything in catalog)
		if(changeling.purchased_powers[ability_data["path"]])
			continue

		var/points_needed = ability_data["genetic_point_required"] - changeling.genetic_points
		if(points_needed > 0)
			var/list/list_for_cost = points_short[points_needed]
			if(!islist(list_for_cost))
				list_for_cost = list()
				points_short[points_needed] = list_for_cost
			list_for_cost += ability_data["name"]

		var/absorb_needed = ability_data["absorbs_required"] - changeling.true_absorbs
		if(absorb_needed > 0)
			var/list/list_for_absorb = absorb_short[absorb_needed]
			if(!islist(list_for_absorb))
				list_for_absorb = list()
				absorb_short[absorb_needed] = list_for_absorb
			list_for_absorb += ability_data["name"]

		var/dna_needed = ability_data["dna_required"] - changeling.absorbed_count
		if(dna_needed > 0)
			var/list/list_for_dna = dna_short[dna_needed]
			if(!islist(list_for_dna))
				list_for_dna = list()
				dna_short[dna_needed] = list_for_dna
			list_for_dna += ability_data["name"]

	for(var/needed in points_short)
		var/list/names = points_short[needed]
		warnings += "Need [needed] more genetic point[needed == 1 ? "" : "s"] for [english_list(names)]."

	for(var/needed_absorb in absorb_short)
		var/list/absorb_names = absorb_short[needed_absorb]
		warnings += "Need [needed_absorb] more absorb[needed_absorb == 1 ? "" : "s"] for [english_list(absorb_names)]."

	for(var/needed_dna in dna_short)
		var/list/dna_names = dna_short[needed_dna]
		warnings += "Need [needed_dna] more DNA sample[needed_dna == 1 ? "" : "s"] for [english_list(dna_names)]."

	return warnings

/datum/genetic_matrix/proc/build_preset_payload()
	var/list/output = list()
	var/index = 1
	if(!LAZYLEN(changeling.genetic_presets))
		return output

	for(var/list/preset as anything in changeling.genetic_presets)
		var/list/entry = list()
		entry["id"] = index
		entry["name"] = preset["name"]
		var/list/blueprint = changeling.sanitize_build_blueprint(preset[CHANGELING_BUILD_BLUEPRINT])
		var/datum/action/changeling/key_path = blueprint[CHANGELING_KEY_BUILD_SLOT]
		var/list/secondary_paths = blueprint[CHANGELING_SECONDARY_BUILD_SLOTS]
		if(ispath(key_path, /datum/action/changeling))
			entry["primary"] = changeling.build_slot_payload(key_path, changeling.purchased_powers[key_path], CHANGELING_KEY_BUILD_SLOT, 1)
		else
			entry["primary"] = null
		var/list/secondary_payload = list()
		var/slot_index = 1
		if(islist(secondary_paths))
			for(var/path in secondary_paths)
				if(!ispath(path, /datum/action/changeling))
					continue
				secondary_payload += list(changeling.build_slot_payload(path, changeling.purchased_powers[path], CHANGELING_SECONDARY_BUILD_SLOTS, slot_index))
				slot_index++
		entry["secondaries"] = secondary_payload
		entry["ability_count"] = slot_index - 1 + (entry["primary"] ? 1 : 0)
		entry[CHANGELING_BUILD_BLUEPRINT] = blueprint
		output += list(entry)
		index++

return output

/datum/genetic_matrix/proc/get_crafting_recipes()
	if(islist(GLOB.changeling_crafting_recipes))
		return GLOB.changeling_crafting_recipes
	return list()

/datum/genetic_matrix/proc/build_crafting_recipe_payload()
	var/list/output = list()
	var/list/recipes = get_crafting_recipes()
	if(!islist(recipes))
		return output
	for(var/list/recipe as anything in recipes)
		if(!islist(recipe))
			continue
		var/list/entry = list()
		entry["id"] = recipe[CHANGELING_CRAFT_ID]
		entry["name"] = recipe[CHANGELING_CRAFT_NAME]
		entry["description"] = recipe[CHANGELING_CRAFT_DESC]
		if(recipe[CHANGELING_CRAFT_RESULT_TEXT])
			entry["result_text"] = recipe[CHANGELING_CRAFT_RESULT_TEXT]
		var/list/material_payload = list()
		var/list/materials = recipe[CHANGELING_CRAFT_BIOMATERIALS]
		if(islist(materials))
			for(var/list/material as anything in materials)
				if(!islist(material))
					continue
				var/category_value = material[CHANGELING_CRAFT_BIO_CATEGORY]
				var/category = isnull(category_value) ? null : lowertext("[category_value]")
				if(!istext(category))
					continue
				var/id_value = material[CHANGELING_CRAFT_BIO_ID]
				if(!istext(id_value))
					continue
				var/list/material_entry = list(
					"category" = category,
					"category_name" = material[CHANGELING_CRAFT_BIO_CATEGORY_NAME] || capitalize(replacetext(category, "_", " ")),
					"id" = id_value,
					"name" = material[CHANGELING_CRAFT_BIO_NAME] || capitalize(replacetext(id_value, "_", " ")),
					"count" = material[CHANGELING_CRAFT_BIO_COUNT] || 1,
				)
				if(material[CHANGELING_CRAFT_BIO_DESC])
					material_entry["description"] = material[CHANGELING_CRAFT_BIO_DESC]
				material_payload += list(material_entry)
		entry["biomaterials"] = material_payload
		var/list/ability_payload = list()
		var/list/ability_requirements = recipe[CHANGELING_CRAFT_ABILITIES]
		if(islist(ability_requirements))
			for(var/ability_path in ability_requirements)
				if(!ispath(ability_path, /datum/action/changeling))
					continue
				var/list/metadata = changeling.get_static_power_metadata(ability_path)
				var/list/ability_entry = list(
					"path" = ability_path,
					"name" = metadata ? metadata["name"] : "[ability_path]",
				)
				if(metadata && metadata["desc"])
					ability_entry["desc"] = metadata["desc"]
				ability_payload += list(ability_entry)
		entry["abilities"] = ability_payload
		var/list/grant_payload = list()
		var/list/grant_definitions = recipe[CHANGELING_CRAFT_GRANTS]
		if(islist(grant_definitions))
			for(var/list/grant as anything in grant_definitions)
				if(!islist(grant))
					continue
				var/datum/action/changeling/grant_path = grant[CHANGELING_CRAFT_POWER]
				if(!ispath(grant_path, /datum/action/changeling))
					continue
				var/slot_choice = grant[CHANGELING_CRAFT_SLOT] || CHANGELING_SECONDARY_BUILD_SLOTS
				var/list/grant_meta = changeling.get_static_power_metadata(grant_path)
				var/list/grant_entry = list(
					"path" = grant_path,
					"name" = grant_meta ? grant_meta["name"] : "[grant_path]",
					"slot" = slot_choice,
					"slot_name" = slot_choice == CHANGELING_KEY_BUILD_SLOT ? "Primary" : "Secondary",
				)
				if(grant_meta && grant_meta["desc"])
					grant_entry["desc"] = grant_meta["desc"]
				if(grant[CHANGELING_CRAFT_FORCE])
					grant_entry["force"] = TRUE
				grant_payload += list(grant_entry)
		if(LAZYLEN(grant_payload))
			entry["grants"] = grant_payload
		if(islist(recipe[CHANGELING_CRAFT_PASSIVES]))
			entry["passives"] = recipe[CHANGELING_CRAFT_PASSIVES].Copy()
		output += list(entry)
	return output

/datum/genetic_matrix/proc/process_crafting_request(list/raw_materials, list/raw_abilities, mob/user)
	if(!changeling)
		return list("success" = FALSE, "message" = "We lack a genome to reshape.", "timestamp" = world.time)
	var/list/material_map = normalize_crafting_materials(raw_materials)
	var/list/ability_list = normalize_crafting_abilities(raw_abilities)
	if(!LAZYLEN(material_map))
		if(user)
			to_chat(user, span_warning("We must dedicate biomaterials to craft a genome."))
		return list(
			"success" = FALSE,
			"message" = "We must dedicate biomaterials to craft a genome.",
			"errors" = list("Select biomaterials to weave."),
			"timestamp" = world.time,
		)
	var/list/recipe = find_crafting_recipe(material_map, ability_list)
	if(!islist(recipe))
		if(user)
			to_chat(user, span_warning("No genome pattern responds to those catalysts."))
		return list(
			"success" = FALSE,
			"message" = "No genome pattern responds to that configuration.",
			"timestamp" = world.time,
		)
	var/list/errors = list()
	if(!validate_crafting_request(recipe, material_map, ability_list, errors))
		if(user)
			for(var/error in errors)
				to_chat(user, span_warning("[error]"))
		return list(
			"success" = FALSE,
			"message" = "We lack the resources to stabilize that genome.",
			"errors" = errors,
			"timestamp" = world.time,
		)
	return apply_crafting_recipe(recipe, material_map, ability_list, user)

/datum/genetic_matrix/proc/normalize_crafting_materials(list/raw_materials)
	var/list/output = list()
	if(!islist(raw_materials))
		return output
	for(var/index in raw_materials)
		var/list/material = raw_materials[index]
		if(!islist(material))
			continue
		var/category_value = material["category"]
		if(isnull(category_value))
			category_value = material[CHANGELING_CRAFT_BIO_CATEGORY]
		var/category = isnull(category_value) ? null : lowertext("[category_value]")
		if(!istext(category))
			continue
		var/id_value = material["id"]
		if(isnull(id_value))
			id_value = material[CHANGELING_CRAFT_BIO_ID]
		if(isnull(id_value))
			continue
		var/material_id = changeling_sanitize_material_id(id_value)
		var/count_value = material["count"]
		if(isnull(count_value))
			count_value = material[CHANGELING_CRAFT_BIO_COUNT]
		var/amount = 0
		if(isnum(count_value))
			amount = count_value
		else if(istext(count_value))
			amount = text2num(count_value)
		else
			amount = 1
		amount = round(amount)
		if(amount <= 0)
			continue
		var/list/category_map = output[category]
		if(!islist(category_map))
			category_map = list()
			output[category] = category_map
		category_map[material_id] = (category_map[material_id] || 0) + amount
	return output

/datum/genetic_matrix/proc/normalize_crafting_abilities(list/raw_abilities)
	var/list/output = list()
	if(!islist(raw_abilities))
		return output
	for(var/index in raw_abilities)
		var/value = raw_abilities[index]
		var/datum/action/changeling/path = null
		if(ispath(value, /datum/action/changeling))
			path = value
		else if(istext(value))
			path = text2path(value)
		if(!ispath(path, /datum/action/changeling))
			continue
		output[path] = TRUE
	return assoc_to_keys(output)

/datum/genetic_matrix/proc/find_crafting_recipe(list/material_map, list/ability_list)
	var/list/recipes = get_crafting_recipes()
	if(!islist(recipes))
		return null
	for(var/list/recipe as anything in recipes)
		if(!islist(recipe))
			continue
		if(does_recipe_match(recipe, material_map, ability_list))
			return recipe
	return null

/datum/genetic_matrix/proc/does_recipe_match(list/recipe, list/material_map, list/ability_list)
	if(!islist(recipe))
		return FALSE
	var/list/requirements = recipe[CHANGELING_CRAFT_BIOMATERIALS]
	var/list/material_copy = list()
	if(islist(material_map))
		for(var/category in material_map)
			var/list/selected = material_map[category]
			if(!islist(selected))
				continue
			var/list/dup = list()
			for(var/id in selected)
				dup[id] = selected[id]
			material_copy[category] = dup
	if(islist(requirements))
		for(var/list/req as anything in requirements)
			if(!islist(req))
				return FALSE
			var/category_value = req[CHANGELING_CRAFT_BIO_CATEGORY]
			var/category = isnull(category_value) ? null : lowertext("[category_value]")
			var/id_value = req[CHANGELING_CRAFT_BIO_ID]
			if(!istext(category) || !istext(id_value))
				return FALSE
			var/count_required = req[CHANGELING_CRAFT_BIO_COUNT] || 1
			var/list/category_map = material_copy[category]
			if(!islist(category_map))
				return FALSE
			var/current_count = category_map[id_value]
			if(!isnum(current_count) || current_count != count_required)
				return FALSE
			category_map -= id_value
			if(!LAZYLEN(category_map))
				material_copy -= category
	for(var/category in material_copy)
		var/list/leftover = material_copy[category]
		if(islist(leftover) && LAZYLEN(leftover))
			return FALSE
	var/list/ability_requirements = recipe[CHANGELING_CRAFT_ABILITIES]
	var/list/ability_set = list()
	for(var/path in ability_list)
		if(ispath(path, /datum/action/changeling))
			ability_set[path] = TRUE
	if(islist(ability_requirements) && LAZYLEN(ability_requirements))
		if(LAZYLEN(ability_requirements) != LAZYLEN(ability_set))
			return FALSE
		for(var/path in ability_requirements)
			if(!ability_set[path])
				return FALSE
	else if(LAZYLEN(ability_set))
		return FALSE
	return TRUE

/datum/genetic_matrix/proc/validate_crafting_request(list/recipe, list/material_map, list/ability_list, list/errors)
	var/valid = TRUE
	if(!islist(errors))
		errors = list()
	var/list/ability_requirements = recipe[CHANGELING_CRAFT_ABILITIES]
	if(islist(ability_requirements))
		for(var/path in ability_requirements)
			if(!ispath(path, /datum/action/changeling))
				continue
			var/has_power = changeling.purchased_powers[path] ? TRUE : FALSE
			if(!has_power)
				for(var/datum/action/changeling/power as anything in changeling.innate_powers)
					if(istype(power) && power.type == path)
						has_power = TRUE
						break
			if(!has_power)
				var/list/meta = changeling.get_static_power_metadata(path)
				var/name = meta ? meta["name"] : "that adaptation"
				errors += "We must evolve [name] before we can catalyze this genome."
				valid = FALSE
	var/list/requirements = recipe[CHANGELING_CRAFT_BIOMATERIALS]
	if(islist(requirements))
		for(var/list/req as anything in requirements)
			if(!islist(req))
				continue
			var/category_value = req[CHANGELING_CRAFT_BIO_CATEGORY]
			var/category = isnull(category_value) ? null : lowertext("[category_value]")
			var/id_value = req[CHANGELING_CRAFT_BIO_ID]
			var/name = req[CHANGELING_CRAFT_BIO_NAME] || capitalize(replacetext(id_value, "_", " "))
			var/count_required = req[CHANGELING_CRAFT_BIO_COUNT] || 1
			var/available = 0
			if(istext(category) && istext(id_value))
				var/list/category_entry = changeling.biomaterial_inventory?[category]
				var/list/items = category_entry ? category_entry["items"] : null
				var/list/item_entry = islist(items) ? items[id_value] : null
				available = item_entry ? (item_entry["count"] || 0) : 0
			if(available < count_required)
				var/category_name = req[CHANGELING_CRAFT_BIO_CATEGORY_NAME] || capitalize(replacetext(category, "_", " "))
				errors += "We require [count_required] [name] ([category_name]) but only possess [available]."
				valid = FALSE
	return valid

/datum/genetic_matrix/proc/build_material_cost_map(list/recipe)
	var/list/costs = list()
	var/list/requirements = recipe[CHANGELING_CRAFT_BIOMATERIALS]
	if(!islist(requirements))
		return costs
	for(var/list/req as anything in requirements)
		if(!islist(req))
			continue
		var/category_value = req[CHANGELING_CRAFT_BIO_CATEGORY]
		var/category = isnull(category_value) ? null : lowertext("[category_value]")
		var/id_value = req[CHANGELING_CRAFT_BIO_ID]
		if(!istext(category) || !istext(id_value))
			continue
		var/count_required = req[CHANGELING_CRAFT_BIO_COUNT] || 1
		var/list/category_map = costs[category]
		if(!islist(category_map))
			category_map = list()
			costs[category] = category_map
		category_map[id_value] = (category_map[id_value] || 0) - count_required
	return costs

/datum/genetic_matrix/proc/apply_crafting_recipe(list/recipe, list/material_map, list/ability_list, mob/user)
	var/list/result = list(
		"success" = TRUE,
		"recipe" = recipe[CHANGELING_CRAFT_ID],
		"name" = recipe[CHANGELING_CRAFT_NAME],
		"timestamp" = world.time,
	)
	var/list/material_costs = build_material_cost_map(recipe)
	var/list/outcome_payload = list()
	if(LAZYLEN(material_costs))
		outcome_payload["biomaterials"] = material_costs
	if(islist(recipe[CHANGELING_CRAFT_OUTCOME]))
		for(var/key in recipe[CHANGELING_CRAFT_OUTCOME])
			outcome_payload[key] = recipe[CHANGELING_CRAFT_OUTCOME][key]
	if(LAZYLEN(outcome_payload))
		changeling.register_crafting_outcome(outcome_payload, TRUE)
	var/message = recipe[CHANGELING_CRAFT_RESULT_TEXT]
	if(!istext(message) || !length(message))
		var/name = recipe[CHANGELING_CRAFT_NAME] || "genome pattern"
		message = "We weave the [name] genome pattern."
	result["message"] = message
	var/list/grant_results = list()
	var/list/grant_errors = list()
	var/list/grant_definitions = recipe[CHANGELING_CRAFT_GRANTS]
	var/granted_any = FALSE
	if(islist(grant_definitions))
		for(var/list/grant as anything in grant_definitions)
			if(!islist(grant))
				continue
			var/datum/action/changeling/power_path = grant[CHANGELING_CRAFT_POWER]
			if(!ispath(power_path, /datum/action/changeling))
				continue
			var/slot_choice = grant[CHANGELING_CRAFT_SLOT] || CHANGELING_SECONDARY_BUILD_SLOTS
			var/force_slot = grant[CHANGELING_CRAFT_FORCE] ? TRUE : FALSE
			var/list/meta = changeling.get_static_power_metadata(power_path)
			var/power_name = meta ? meta["name"] : "[power_path]"
			var/list/grant_entry = list(
				"path" = power_path,
				"name" = power_name,
				"slot" = slot_choice,
			)
			var/success = TRUE
			var/slot_assigned = FALSE
			var/message_text
			if(changeling.purchased_powers[power_path])
				granted_any = TRUE
				if(changeling.register_power_slot(power_path, slot_choice, force_slot))
					slot_assigned = TRUE
					message_text = slot_choice == CHANGELING_KEY_BUILD_SLOT ? "We anchor [power_name] as our key adaptation." : "We sequence [power_name] into a secondary slot."
				else if(slot_choice == CHANGELING_KEY_BUILD_SLOT && changeling.register_power_slot(power_path, CHANGELING_SECONDARY_BUILD_SLOTS, force_slot))
					slot_assigned = TRUE
					grant_entry["slot"] = CHANGELING_SECONDARY_BUILD_SLOTS
					message_text = "We retain [power_name] within our secondary lattice."
				else
					message_text = "We already command [power_name], but lack lattice space to reposition it."
			else
				if(changeling.give_power(power_path))
					granted_any = TRUE
					if(changeling.register_power_slot(power_path, slot_choice, force_slot))
						slot_assigned = TRUE
						message_text = slot_choice == CHANGELING_KEY_BUILD_SLOT ? "We anchor [power_name] as our key adaptation." : "We sequence [power_name] into a secondary slot."
					else if(slot_choice == CHANGELING_KEY_BUILD_SLOT && changeling.register_power_slot(power_path, CHANGELING_SECONDARY_BUILD_SLOTS, force_slot))
						slot_assigned = TRUE
						grant_entry["slot"] = CHANGELING_SECONDARY_BUILD_SLOTS
						message_text = "We manifest [power_name] and bind it to a secondary slot."
					else
						success = TRUE
						grant_entry["slot"] = null
						message_text = "We manifest [power_name], but lack the space to stabilize it."
				else
					success = FALSE
					message_text = "Our genome rejects the [power_name] sequence."
			grant_entry["success"] = success
			if(message_text)
				grant_entry["message"] = message_text
			if(!slot_assigned)
				grant_entry["slot"] = grant_entry["slot"]
			if(!success)
				grant_errors += message_text
			grant_results += list(grant_entry)
	if(LAZYLEN(grant_results))
		result["grants"] = grant_results
	var/list/passive_defs = recipe[CHANGELING_CRAFT_PASSIVES]
	var/list/passive_results = list()
	if(islist(passive_defs))
		for(var/key in passive_defs)
			var/value = passive_defs[key]
			if(!isnum(value) || value == 0)
				continue
			switch(key)
				if("chem_storage")
					changeling.total_chem_storage = max(0, changeling.total_chem_storage + value)
					changeling.chem_charges = clamp(changeling.chem_charges, 0, changeling.total_chem_storage)
					passive_results[key] = changeling.total_chem_storage
				if("chem_charges")
					changeling.adjust_chemicals(value)
					passive_results[key] = changeling.chem_charges
				if("chem_recharge_rate")
					changeling.chem_recharge_rate = max(0, changeling.chem_recharge_rate + value)
					passive_results[key] = changeling.chem_recharge_rate
				if("chem_recharge_slowdown")
					changeling.chem_recharge_slowdown = max(0, changeling.chem_recharge_slowdown + value)
					passive_results[key] = changeling.chem_recharge_slowdown
	if(LAZYLEN(passive_results))
		result["passives"] = passive_results
	if(granted_any)
		changeling.synchronize_build_state()
	if(user)
		to_chat(user, span_notice(message))
		if(LAZYLEN(grant_results))
			for(var/list/grant_entry as anything in grant_results)
				var/grant_message = grant_entry["message"]
				if(!istext(grant_message))
					continue
				if(grant_entry["success"])
					to_chat(user, span_notice(grant_message))
				else
					to_chat(user, span_warning(grant_message))
		if(LAZYLEN(passive_results))
			for(var/passive_key in passive_results)
				var/current_value = passive_results[passive_key]
				var/passive_message
				switch(passive_key)
					if("chem_storage")
						passive_message = "Our chemical lattice expands to hold [round(current_value, 0.1)] units."
					if("chem_charges")
						passive_message = "Our reserves settle at [round(current_value, 0.1)] units."
					if("chem_recharge_rate")
						passive_message = "Our recharge rate adjusts to [round(current_value, 0.1)]."
					if("chem_recharge_slowdown")
						passive_message = "Our recharge slowdown shifts to [round(current_value, 0.1)]."
				if(passive_message)
					to_chat(user, span_notice(passive_message))
	if(LAZYLEN(grant_errors))
		result["errors"] = grant_errors
	return result

/datum/genetic_matrix/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("readapt")
			if(changeling.can_respec)
				changeling.readapt()

		if("evolve")
			var/datum/action/changeling/power_path = text2path(params["path"])
			if(power_path)
				var/slot_choice = lowertext(params["slot"])
				var/slot_identifier = CHANGELING_SECONDARY_BUILD_SLOTS
				if(slot_choice == CHANGELING_KEY_BUILD_SLOT || slot_choice == "primary")
					slot_identifier = CHANGELING_KEY_BUILD_SLOT
				changeling.purchase_power(power_path, slot_identifier)

		if("craft")
			var/list/raw_materials = isnull(params["materials"]) ? null : safe_json_decode(params["materials"])
			var/list/raw_abilities = isnull(params["abilities"]) ? null : safe_json_decode(params["abilities"])
			last_crafting_result = process_crafting_request(raw_materials, raw_abilities, user)
			if(!islist(last_crafting_result))
				last_crafting_result = list(
					"success" = FALSE,
					"message" = "We cannot interpret that configuration of biomaterials.",
				)
			return TRUE

		if("set_primary")
			var/datum/action/changeling/promote_path = text2path(params["path"])
			if(promote_path)
				changeling.set_active_key_power(promote_path)

		if("retire_power")
			var/datum/action/changeling/retire_path = text2path(params["path"])
			if(retire_path)
				changeling.remove_power(retire_path)

		if("save_preset")
			var/preset_name = sanitize_text(params["name"], "")
			preset_name = htmlrendertext(preset_name)
			if(!length(preset_name))
				preset_name = "Matrix Preset [length(changeling.genetic_presets) + 1]"
			changeling.save_genetic_preset(preset_name)

		if("apply_preset")
			var/idx = text2num(params["id"])
			changeling.apply_genetic_preset(idx)

		if("delete_preset")
			var/delete_idx = text2num(params["id"])
			changeling.delete_genetic_preset(delete_idx)

		if("rename_preset")
			var/rename_idx = text2num(params["id"])
			var/new_name = sanitize_text(params["name"], "")
			new_name = htmlrendertext(new_name)
			if(length(new_name))
				changeling.rename_genetic_preset(rename_idx, new_name)

	return TRUE

/datum/action/genetic_matrix
	name = "Genetic Matrix"
	button_icon = 'icons/obj/drinks/soda.dmi'
	button_icon_state = "changelingsting"
	background_icon_state = "bg_changeling"
	overlay_icon_state = "bg_changeling_border"
	check_flags = NONE

/datum/action/genetic_matrix/New(Target)
	. = ..()
	if(!istype(Target, /datum/genetic_matrix))
		stack_trace("genetic_matrix action created with non-matrix target.")
		qdel(src)

/datum/action/genetic_matrix/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	target.ui_interact(owner)

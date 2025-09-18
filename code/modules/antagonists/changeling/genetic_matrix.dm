// Genetic Matrix -
// The place where Changelings reorganize their genomes.
/datum/genetic_matrix
	/// The name of the matrix interface.
	var/name = "genetic matrix"
	/// The changeling who owns this matrix.
	var/datum/antagonist/changeling/changeling

/datum/genetic_matrix/New(my_changeling)
	. = ..()
	changeling = my_changeling

/datum/genetic_matrix/Destroy()
	changeling = null
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

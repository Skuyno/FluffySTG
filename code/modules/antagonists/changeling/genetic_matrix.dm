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
        return data

/datum/genetic_matrix/ui_data(mob/user)
        var/list/data = list()

        data["can_readapt"] = changeling.can_respec
        data["absorb_count"] = changeling.true_absorbs
        data["dna_count"] = changeling.absorbed_count
        data["chem_charges"] = changeling.chem_charges
        data["chem_storage"] = changeling.total_chem_storage
        data["chem_recharge_rate"] = changeling.chem_recharge_rate
        data["chem_recharge_slowdown"] = changeling.chem_recharge_slowdown
        data["active_effects"] = build_active_effects()
        var/list/recipe_catalog = changeling.build_recipe_catalog()
        data["recipes"] = recipe_catalog
        data["synergy_tips"] = build_synergy_tips(recipe_catalog)
        data["incompatibilities"] = collect_incompatibilities(recipe_catalog)
        data["presets"] = build_preset_payload()
        data["preset_limit"] = changeling.max_genetic_presets
        data["active_build"] = changeling.export_active_build_state()
        data["biomaterials"] = changeling.build_biomaterial_payload()
        data["signature_cells"] = changeling.build_signature_payload()

	return data

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
                effect["req_absorbs"] = power.req_absorbs
                effect["req_dna"] = power.req_dna
                effect["innate"] = FALSE
                effects += list(effect)

	return effects

/datum/genetic_matrix/proc/build_synergy_tips(list/recipe_catalog)
        var/list/tips = list()
        if(!islist(recipe_catalog))
                return tips

        var/signature_gap
        var/list/signature_targets = list()
        var/list/category_gaps = list()
        var/list/respec_recipe

        for(var/list/recipe as anything in recipe_catalog)
                if(!islist(recipe))
                        continue
                var/result_type = lowertext(recipe["result_type"] || "ability")
                if(result_type == "respec")
                        respec_recipe = recipe
                if(result_type != "ability" || recipe["owned"])
                        continue
                var/ability_name = recipe["ability_name"] || recipe["name"]
                var/list/requirements = recipe["requirements"]
                if(!islist(requirements))
                        continue
                for(var/list/requirement as anything in requirements)
                        if(!islist(requirement))
                                continue
                        var/missing = max(0, requirement["required"] - requirement["available"])
                        if(missing <= 0)
                                continue
                        var/req_type = requirement["type"]
                        if(req_type == "signature" || req_type == "signature_any")
                                if(isnull(signature_gap) || missing < signature_gap)
                                        signature_gap = missing
                                        signature_targets = list(ability_name)
                                else if(missing == signature_gap)
                                        signature_targets += ability_name
                        else if(req_type == "biomaterial")
                                var/category_id = requirement["category"]
                                var/list/info = category_gaps[category_id]
                                if(!islist(info) || missing < info["missing"])
                                        info = list("missing" = missing, "names" = list(ability_name))
                                        category_gaps[category_id] = info
                                else if(missing == info["missing"])
                                        info["names"] += ability_name

        if(signature_gap)
                var/list/tip = list()
                tip["title"] = "Signature Catalysis"
                tip["description"] = "Harvest [signature_gap] more signature cell[signature_gap == 1 ? "" : "s"] to imprint:"
                tip["abilities"] = signature_targets
                tips += list(tip)

        for(var/category_id in category_gaps)
                var/list/info = category_gaps[category_id]
                if(!islist(info))
                        continue
                var/list/category_entry = changeling.get_biomaterial_category(category_id)
                var/category_name = ""
                if(islist(category_entry))
                        category_name = category_entry["name"]
                if(!istext(category_name) || !length(category_name))
                        category_name = capitalize(replacetext("[category_id]", "_", " "))
                var/list/tip = list()
                var/missing = info["missing"]
                tip["title"] = "[category_name] Reserve"
                tip["description"] = "Secure [missing] more sample[missing == 1 ? "" : "s"] to craft:"
                tip["abilities"] = info["names"]
                tips += list(tip)

        if(islist(respec_recipe) && !changeling.can_respec)
                var/list/missing_parts = list()
                for(var/list/requirement as anything in respec_recipe["requirements"])
                        if(!islist(requirement))
                                continue
                        var/missing = max(0, requirement["required"] - requirement["available"])
                        if(missing <= 0)
                                continue
                        missing_parts += "[missing] [requirement["name"] || requirement["id"]]"
                if(LAZYLEN(missing_parts))
                        var/list/tip = list()
                        tip["title"] = "Recombinase Prep"
                        tip["description"] = "Gather [english_list(missing_parts)] to distill a recombinase charge."
                        tips += list(tip)

        return tips
/datum/genetic_matrix/proc/collect_incompatibilities(list/recipe_catalog)
        var/list/warnings = list()

        if(changeling.can_respec <= 0)
                warnings += "Craft a recombinase charge to enable readaptation."

        if(!islist(recipe_catalog))
                return warnings

        for(var/list/recipe as anything in recipe_catalog)
                if(!islist(recipe))
                        continue
                var/result_type = lowertext(recipe["result_type"] || "ability")
                if(result_type != "ability" || recipe["owned"])
                        continue
                var/list/requirements = recipe["requirements"]
                if(!islist(requirements))
                        continue
                var/list/missing_parts = list()
                for(var/list/requirement as anything in requirements)
                        if(!islist(requirement))
                                continue
                        var/missing = max(0, requirement["required"] - requirement["available"])
                        if(missing <= 0)
                                continue
                        var/part_name = requirement["name"] || requirement["id"]
                        if(requirement["type"] == "signature_any")
                                part_name = part_name || "signature cell"
                        missing_parts += "[missing] [part_name]"
                if(LAZYLEN(missing_parts))
                        var/ability_name = recipe["ability_name"] || recipe["name"]
                        warnings += "Need [english_list(missing_parts)] for [ability_name]."

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

		if("craft")
			var/recipe_id = params["id"]
			if(istext(recipe_id))
				var/slot_choice = lowertext(params["slot"])
				var/slot_identifier = CHANGELING_SECONDARY_BUILD_SLOTS
				if(slot_choice == CHANGELING_KEY_BUILD_SLOT || slot_choice == "primary")
					slot_identifier = CHANGELING_KEY_BUILD_SLOT
				changeling.craft_recipe(recipe_id, slot_identifier)
			else if(params["path"])
				var/datum/action/changeling/power_path = text2path(params["path"])
				if(power_path)
					var/slot_choice = lowertext(params["slot"])
					var/slot_identifier = CHANGELING_SECONDARY_BUILD_SLOTS
					if(slot_choice == CHANGELING_KEY_BUILD_SLOT || slot_choice == "primary")
						slot_identifier = CHANGELING_KEY_BUILD_SLOT
					changeling.craft_recipe_for_power(power_path, slot_identifier)

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

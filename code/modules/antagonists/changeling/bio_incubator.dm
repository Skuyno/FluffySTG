#ifndef CHANGELING_MODULE_ACTIVE_FLAG
#define CHANGELING_MODULE_ACTIVE_FLAG "__changeling_module_active__"
#endif

#define BIO_INCUBATOR_MAX_MODULE_SLOTS 4
#define BIO_INCUBATOR_MAX_BUILDS 6

#define BIO_INCUBATOR_UPDATE_CELLS (1<<0)
#define BIO_INCUBATOR_UPDATE_RECIPES (1<<1)
#define BIO_INCUBATOR_UPDATE_MODULES (1<<2)
#define BIO_INCUBATOR_UPDATE_BUILDS (1<<3)
#define BIO_INCUBATOR_UPDATE_ALL (BIO_INCUBATOR_UPDATE_CELLS | BIO_INCUBATOR_UPDATE_RECIPES | BIO_INCUBATOR_UPDATE_MODULES | BIO_INCUBATOR_UPDATE_BUILDS)

#define BIO_INCUBATOR_SLOT_KEY "key"
#define BIO_INCUBATOR_SLOT_FLEX "flex"

/// Stores changeling genetic matrix inventory and build configuration.
/datum/changeling_bio_incubator
	/// Owning changeling datum.
	var/datum/antagonist/changeling/changeling
	/// Unique identifiers for collected cell signatures.
	var/list/cell_ids = list()
	/// Unique identifiers for known crafting recipes.
	var/list/recipe_ids = list()
	/// Assoc list of crafted module definitions indexed by identifier.
	var/list/crafted_modules = list()
	/// Stored build presets.
	var/list/datum/changeling_bio_incubator/build/builds = list()
	/// Currently applied module instances indexed by slot.
	var/list/datum/changeling_genetic_module/active_modules = list()

/datum/changeling_bio_incubator/New(datum/antagonist/changeling/changeling)
	. = ..()
	src.changeling = changeling
	ensure_active_capacity()

/datum/changeling_bio_incubator/Destroy()
	cell_ids = null
	recipe_ids = null
	crafted_modules = null
	QDEL_LIST(builds)
	builds = null
	if(LAZYLEN(active_modules))
		for(var/i in 1 to active_modules.len)
			var/datum/changeling_genetic_module/module = active_modules[i]
			if(!module)
				continue
			deactivate_module_instance(i, module)
	active_modules = null
	changeling = null
	return ..()

/datum/changeling_bio_incubator/proc/get_max_builds()
	return BIO_INCUBATOR_MAX_BUILDS

/datum/changeling_bio_incubator/proc/get_max_slots()
	return BIO_INCUBATOR_MAX_MODULE_SLOTS

/datum/changeling_bio_incubator/proc/can_add_build()
	return builds.len < get_max_builds()

/datum/changeling_bio_incubator/proc/ensure_default_build()
	var/changed = FALSE
	if(builds.len > 1)
		for(var/i in 2 to builds.len)
			var/datum/changeling_bio_incubator/build/extra = builds[i]
			if(!extra)
				continue
			qdel(extra)
		builds.Cut(2, builds.len + 1)
		changed = TRUE
	if(!builds.len)
		var/datum/changeling_bio_incubator/build/build = new(src)
		build.name = "Genetic Matrix"
		build.ensure_slot_capacity()
		builds += list(build)
		changed = TRUE
	var/datum/changeling_bio_incubator/build/primary = builds[1]
	if(primary)
		primary.ensure_slot_capacity()
	ensure_active_capacity()
	var/has_active_modules = FALSE
	for(var/datum/changeling_genetic_module/module as anything in active_modules)
		if(!module)
			continue
		has_active_modules = TRUE
		break
	if(!has_active_modules)
		apply_build_configuration(primary, notify = FALSE)
	else
		sanitize_active_modules()
	if(changed)
		notify_update(BIO_INCUBATOR_UPDATE_BUILDS)

/datum/changeling_bio_incubator/proc/add_build(name)
	if(!can_add_build())
		return null
	var/datum/changeling_bio_incubator/build/build = new(src)
	build.name = name
	build.ensure_slot_capacity()
	builds += list(build)
	notify_update(BIO_INCUBATOR_UPDATE_BUILDS)
	return build

/datum/changeling_bio_incubator/proc/remove_build(datum/changeling_bio_incubator/build/build)
	if(!build)
		return
	if(build in builds)
		builds -= build
	qdel(build)
	notify_update(BIO_INCUBATOR_UPDATE_BUILDS)

/datum/changeling_bio_incubator/proc/clear_build(datum/changeling_bio_incubator/build/build)
	if(!build)
		return
	var/changed = build.clear_configuration()
	if(changed)
		notify_update(BIO_INCUBATOR_UPDATE_BUILDS)

/datum/changeling_bio_incubator/proc/find_build(identifier)
	if(isnull(identifier))
		return null
	for(var/datum/changeling_bio_incubator/build/build as anything in builds)
		if(REF(build) == identifier)
			return build
	return null

/datum/changeling_bio_incubator/proc/get_builds_data()
	var/list/output = list()
	for(var/datum/changeling_bio_incubator/build/build as anything in builds)
		output += list(build.to_data())
	return output

/datum/changeling_bio_incubator/proc/prune_assignments()
	for(var/datum/changeling_bio_incubator/build/build as anything in builds)
		build.ensure_slot_capacity()
		for(var/i in 1 to build.module_ids.len)
			var/module_id = build.module_ids[i]
			if(!module_id)
				continue
			if(!changeling?.has_genetic_matrix_module(module_id))
				build.module_ids[i] = null
				continue
			if(!module_slot_allowed(module_id, i))
				build.module_ids[i] = null
	sanitize_active_modules()

/datum/changeling_bio_incubator/proc/assign_module(datum/changeling_bio_incubator/build/build, module_identifier, slot)
	if(!build)
		return FALSE
	build.ensure_slot_capacity()
	if(slot < 1 || slot > get_max_slots())
		return FALSE
	if(isnull(module_identifier))
		if(!build.set_module(slot, null))
			return FALSE
		notify_update(BIO_INCUBATOR_UPDATE_BUILDS)
		return TRUE
	var/module_id = sanitize_module_id(module_identifier)
	if(isnull(module_id))
		return FALSE
	if(!changeling?.has_genetic_matrix_module(module_id))
		return FALSE
	var/list/module_data = get_module_data(module_id)
	if(!islist(module_data))
		return FALSE
	if(!module_slot_allowed(module_id, slot))
		return FALSE
	if(build_has_exclusive_conflict(build, module_id, module_data, slot))
		var/mob/living/user = changeling?.owner?.current
		user?.balloon_alert(user, "module conflict!")
		return FALSE
	if(!build.set_module(slot, module_id))
		return FALSE
	notify_update(BIO_INCUBATOR_UPDATE_BUILDS)
	return TRUE

/datum/changeling_bio_incubator/proc/sanitize_module_id(module_identifier)
	if(isnull(module_identifier))
		return null
	if(istext(module_identifier))
		return module_identifier
	if(ispath(module_identifier))
		return "[module_identifier]"
	return "[module_identifier]"

/datum/changeling_bio_incubator/proc/sanitize_slot_type(slot_type)
	var/text_value = LOWER_TEXT(trimtext(isnull(slot_type) ? "" : "[slot_type]"))
	if(text_value == BIO_INCUBATOR_SLOT_KEY || text_value == "key" || text_value == "key_active")
		return BIO_INCUBATOR_SLOT_KEY
	return BIO_INCUBATOR_SLOT_FLEX

/datum/changeling_bio_incubator/proc/sanitize_category(category)
	if(isnull(category))
		return null
	var/text_value = LOWER_TEXT(trimtext("[category]"))
	return length(text_value) ? text_value : null

/datum/changeling_bio_incubator/proc/sanitize_tag_list(list/tags)
	var/list/output = list()
	if(!islist(tags))
		return output
	for(var/tag in tags)
		var/text_value = LOWER_TEXT(trimtext(isnull(tag) ? "" : "[tag]"))
		if(!length(text_value))
			continue
		if(!(text_value in output))
			output += text_value
	return output

/datum/changeling_bio_incubator/proc/tag_lists_conflict(list/tags_a, list/tags_b)
	var/list/a = sanitize_tag_list(tags_a)
	var/list/b = sanitize_tag_list(tags_b)
	if(!a.len || !b.len)
		return FALSE
	var/list/lookup = list()
	for(var/tag in a)
		lookup[tag] = TRUE
	for(var/tag in b)
		if(lookup[tag])
			return TRUE
	return FALSE

/datum/changeling_bio_incubator/proc/build_has_exclusive_conflict(datum/changeling_bio_incubator/build/build, module_id, list/module_data, slot)
	if(!build)
		return FALSE
	var/list/new_tags = module_data?["exclusiveTags"]
	if(!islist(new_tags) || !new_tags.len)
		return FALSE
	new_tags = sanitize_tag_list(new_tags)
	if(!new_tags.len)
		return FALSE
	build.ensure_slot_capacity()
	for(var/i in 1 to build.module_ids.len)
		if(i == slot)
			continue
		var/existing_id = build.module_ids[i]
		if(!existing_id || existing_id == module_id)
			continue
		var/list/existing_data = get_module_data(existing_id)
		if(!islist(existing_data))
			continue
		if(tag_lists_conflict(new_tags, existing_data["exclusiveTags"]))
			return TRUE
	return FALSE

/datum/changeling_bio_incubator/proc/module_slot_allowed(module_id, slot)
	if(isnull(module_id))
		return TRUE
	var/category = get_module_slot_category(module_id)
	if(slot == 1)
		return category == BIO_INCUBATOR_SLOT_KEY
	return category != BIO_INCUBATOR_SLOT_KEY

/datum/changeling_bio_incubator/proc/get_module_slot_category(module_id)
	var/list/module_data = crafted_modules?[module_id]
	if(islist(module_data))
		return sanitize_slot_type(module_data["slotType"])
	return BIO_INCUBATOR_SLOT_FLEX

/datum/changeling_bio_incubator/proc/register_module(module_id, list/module_data)
	if(isnull(module_id) || !islist(module_data))
		return FALSE
	module_id = sanitize_module_id(module_id)
	var/list/data_copy = module_data.Copy()
	data_copy["id"] = module_id
	data_copy["slotType"] = sanitize_slot_type(data_copy["slotType"])
	data_copy["category"] = sanitize_category(data_copy["category"])
	data_copy["tags"] = sanitize_tag_list(data_copy["tags"])
	data_copy["exclusiveTags"] = sanitize_tag_list(data_copy["exclusiveTags"])
	var/module_type = data_copy["moduleType"]
	if(istext(module_type))
		module_type = text2path(module_type)
	if(!ispath(module_type, /datum/changeling_genetic_module))
		module_type = GLOB.changeling_genetic_module_types?[module_id]
	if(ispath(module_type, /datum/changeling_genetic_module))
		data_copy["moduleType"] = module_type
		data_copy["moduleTypePath"] = module_type
	if(!data_copy["source"])
		data_copy["source"] = "crafted"
	crafted_modules[module_id] = data_copy
	notify_update(BIO_INCUBATOR_UPDATE_MODULES)
	return TRUE

/datum/changeling_bio_incubator/proc/unregister_module(module_id)
	module_id = sanitize_module_id(module_id)
	if(!crafted_modules[module_id])
		return FALSE
	del crafted_modules[module_id]
	ensure_active_capacity()
	var/changed = FALSE
	var/list/deactivated = list()
	for(var/i in 1 to active_modules.len)
		var/datum/changeling_genetic_module/module = active_modules[i]
		if(!module || module.id != module_id)
			continue
		deactivate_module_instance(i, module, deactivated)
		changed = TRUE
	var/list/module_changes = build_module_change_payload(null, deactivated)
	if(changed)
		notify_update(BIO_INCUBATOR_UPDATE_BUILDS, module_changes)
	notify_update(BIO_INCUBATOR_UPDATE_MODULES | BIO_INCUBATOR_UPDATE_BUILDS, module_changes)
	return TRUE

/datum/changeling_bio_incubator/proc/has_module(module_id)
	module_id = sanitize_module_id(module_id)
	return crafted_modules[module_id] != null

/datum/changeling_bio_incubator/proc/get_crafted_module_catalog()
	var/list/catalog = list()
	var/list/datum/changeling_genetic_module/active_instances = get_active_modules()
	for(var/module_id in crafted_modules)
		var/list/entry = crafted_modules[module_id]
		if(!islist(entry))
			continue
		var/list/copy = entry.Copy()
		var/is_active = FALSE
		var/slot_index = null
		for(var/i in 1 to active_instances.len)
			var/datum/changeling_genetic_module/module = active_instances[i]
			if(!module || module.id != module_id)
				continue
			is_active = TRUE
			slot_index = i
			break
		copy["active"] = is_active
		copy["slot"] = slot_index
		catalog += list(copy)
	return catalog

/datum/changeling_bio_incubator/proc/get_module_data(module_id)
	module_id = sanitize_module_id(module_id)
	if(isnull(module_id))
		return null
	var/list/entry = crafted_modules[module_id]
	if(islist(entry))
		return entry.Copy()
	return null

/datum/changeling_bio_incubator/proc/ensure_active_capacity()
	var/max_slots = get_max_slots()
	if(!islist(active_modules))
		active_modules = list()
	if(max_slots <= 0)
		if(active_modules.len)
			for(var/i in 1 to active_modules.len)
				var/datum/changeling_genetic_module/module = active_modules[i]
				if(!module)
					continue
				deactivate_module_instance(i, module)
		active_modules.Cut()
		return
	while(active_modules.len < max_slots)
		active_modules += null
	if(active_modules.len > max_slots)
		for(var/i in max_slots + 1 to active_modules.len)
			var/datum/changeling_genetic_module/module = active_modules[i]
			if(!module)
				continue
			deactivate_module_instance(i, module)
		active_modules.Cut(max_slots + 1, active_modules.len + 1)

/datum/changeling_bio_incubator/proc/get_active_modules()
	ensure_active_capacity()
	return active_modules.Copy()

/datum/changeling_bio_incubator/proc/get_active_module_ids()
	ensure_active_capacity()
	var/list/ids = list()
	for(var/i in 1 to active_modules.len)
		var/datum/changeling_genetic_module/module = active_modules[i]
		ids += list(module ? module.id : null)
	return ids

/datum/changeling_bio_incubator/proc/find_module_instance(module_identifier)
	var/id_text = sanitize_module_id(module_identifier)
	if(!id_text)
		return null
	ensure_active_capacity()
	for(var/datum/changeling_genetic_module/module as anything in active_modules)
		if(!module)
			continue
		if(module.id != id_text)
			continue
		return module
	return null

/datum/changeling_bio_incubator/proc/create_module_instance(module_id)
	if(isnull(module_id))
		return null
	var/list/entry = crafted_modules?[module_id]
	var/module_type = null
	if(islist(entry))
		module_type = entry["moduleTypePath"]
		if(isnull(module_type))
			module_type = entry["moduleType"]
		if(istext(module_type))
			module_type = text2path(module_type)
	if(!ispath(module_type, /datum/changeling_genetic_module))
		module_type = GLOB.changeling_genetic_module_types?[module_id]
	if(istext(module_type))
		module_type = text2path(module_type)
	var/datum/changeling_genetic_module/module
	if(ispath(module_type, /datum/changeling_genetic_module))
		module = new module_type()
	else
		module = new_module_for_id(module_id, changeling)
	if(!module)
		return null
	module.id = module_id
	module.assign_owner(changeling)
	return module

/datum/changeling_bio_incubator/proc/deactivate_module_instance(slot, datum/changeling_genetic_module/module, list/deactivated = null)
	if(!module)
		return
	if(slot && active_modules.len >= slot && active_modules[slot] == module)
		active_modules[slot] = null
	module.on_deactivate()
	module.vars[CHANGELING_MODULE_ACTIVE_FLAG] = FALSE
	module.assign_owner(null)
	if(islist(deactivated) && module.id)
		deactivated += list(list(
			"id" = module.id,
			"slot" = slot,
		))
	qdel(module)

/datum/changeling_bio_incubator/proc/build_module_change_payload(list/activated = null, list/deactivated = null)
	var/list/payload = list()
	if(LAZYLEN(activated))
		payload["activated"] = activated.Copy()
	if(LAZYLEN(deactivated))
		payload["deactivated"] = deactivated.Copy()
	if(!payload.len)
		return null
	return payload

/datum/changeling_bio_incubator/proc/is_module_active(module_identifier)
	if(isnull(module_identifier))
		return FALSE
	ensure_active_capacity()
	var/id_text = sanitize_module_id(module_identifier)
	if(!id_text)
		return FALSE
	for(var/datum/changeling_genetic_module/module as anything in active_modules)
		if(!module || module.id != id_text)
			continue
		return TRUE
	return FALSE

/datum/changeling_bio_incubator/proc/apply_build_configuration(datum/changeling_bio_incubator/build/build, notify = TRUE)
	if(!build)
		return FALSE
	ensure_active_capacity()
	build.ensure_slot_capacity()
	var/max_slots = get_max_slots()
	var/list/activated = list()
	var/list/deactivated = list()
	var/changed = FALSE
	for(var/i in 1 to max_slots)
		var/desired_id = null
		if(i <= build.module_ids.len)
			desired_id = sanitize_module_id(build.module_ids[i])
		if(desired_id && (!has_module(desired_id) || !module_slot_allowed(desired_id, i)))
			desired_id = null
		var/datum/changeling_genetic_module/current = active_modules.len >= i ? active_modules[i] : null
		if(current && (!desired_id || current.id != desired_id))
			deactivate_module_instance(i, current, deactivated)
			changed = TRUE
			current = null
		if(!desired_id)
			continue
		if(current)
			current.assign_owner(changeling)
			continue
		var/datum/changeling_genetic_module/new_module = create_module_instance(desired_id)
		if(!new_module)
			continue
		active_modules[i] = new_module
		changed = TRUE
		var/activation_result = new_module.on_activate()
		if(!activation_result)
			deactivate_module_instance(i, new_module)
			continue
		new_module.vars[CHANGELING_MODULE_ACTIVE_FLAG] = TRUE
		if(new_module.id)
			activated += list(list(
				"id" = new_module.id,
				"slot" = i,
			))
	var/list/module_changes = build_module_change_payload(activated, deactivated)
	if(changed && notify)
		notify_update(BIO_INCUBATOR_UPDATE_BUILDS, module_changes)
	else if(!changed)
		ensure_active_capacity()
	return TRUE

/datum/changeling_bio_incubator/proc/sanitize_active_modules()
	ensure_active_capacity()
	var/changed = FALSE
	var/list/deactivated = list()
	for(var/i in 1 to active_modules.len)
		var/datum/changeling_genetic_module/module = active_modules[i]
		if(!module)
			continue
		var/module_id = module.id
		if(module_id && has_module(module_id) && module_slot_allowed(module_id, i))
			continue
		deactivate_module_instance(i, module, deactivated)
		changed = TRUE
	if(changed)
		var/list/module_changes = build_module_change_payload(null, deactivated)
		notify_update(BIO_INCUBATOR_UPDATE_BUILDS, module_changes)
	return changed

/datum/changeling_bio_incubator/proc/add_cell(cell_identifier)
	var/cell_id = changeling_normalize_cell_id(cell_identifier)
	if(isnull(cell_id))
		return FALSE
	if(cell_id in cell_ids)
		return FALSE
	cell_ids += cell_id
	notify_update(BIO_INCUBATOR_UPDATE_CELLS)
	changeling?.update_genetic_matrix_unlocks()
	return TRUE

/proc/changeling_get_nice_name_from_path(path_input)
	var/text_value = istext(path_input) ? path_input : "[path_input]"
	var/list/split_path = splittext(text_value, "/")
	if(!split_path.len)
		return text_value
	var/raw = split_path[split_path.len]
	raw = replacetext(raw, "_", " " )
	return capitalize(raw)

/datum/changeling_bio_incubator/proc/get_cells_data()
	var/list/output = list()
	for(var/cell_id in cell_ids)
		var/list/entry = build_cell_entry(cell_id)
		if(entry)
			output += list(entry)
	return output

/datum/changeling_bio_incubator/proc/build_cell_entry(cell_id)
	var/list/entry = list(
		"id" = cell_id,
	)
	var/list/metadata = changeling_get_cell_metadata(cell_id)
	entry["name"] = changeling_get_cell_display_name(cell_id)
	entry["desc"] = metadata?["desc"]
	return entry

/datum/changeling_bio_incubator/proc/get_nice_name_from_path(path_input)
	return changeling_get_nice_name_from_path(path_input)

/datum/changeling_bio_incubator/proc/add_recipe(recipe_identifier)
	var/recipe_id = sanitize_module_id(recipe_identifier)
	if(isnull(recipe_id))
		return FALSE
	if(recipe_id in recipe_ids)
		return FALSE
	recipe_ids += recipe_id
	notify_update(BIO_INCUBATOR_UPDATE_RECIPES)
	return TRUE

/datum/changeling_bio_incubator/proc/remove_recipe(recipe_identifier)
	var/recipe_id = sanitize_module_id(recipe_identifier)
	if(isnull(recipe_id))
		return FALSE
	if(!(recipe_id in recipe_ids))
		return FALSE
	recipe_ids -= recipe_id
	notify_update(BIO_INCUBATOR_UPDATE_RECIPES)
	return TRUE

/datum/changeling_bio_incubator/proc/get_recipes_data()
	var/list/output = list()
	for(var/recipe_id in recipe_ids)
		output += list(list(
			"id" = recipe_id,
			"name" = get_nice_name_from_path(recipe_id),
		))
	return output

/datum/changeling_bio_incubator/proc/notify_update(update_flags = BIO_INCUBATOR_UPDATE_ALL, list/module_changes = null)
	SEND_SIGNAL(src, COMSIG_CHANGELING_BIO_INCUBATOR_UPDATED, update_flags, module_changes)
	if(changeling?.genetic_matrix)
		SStgui.update_uis(changeling.genetic_matrix)

/// Definition of a single build preset.
/datum/changeling_bio_incubator/build
	var/datum/changeling_bio_incubator/bio_incubator
	var/name = "Matrix Build"
	var/list/module_ids = list()

/datum/changeling_bio_incubator/build/New(datum/changeling_bio_incubator/bio_incubator)
	. = ..()
	src.bio_incubator = bio_incubator

/datum/changeling_bio_incubator/build/Destroy()
	module_ids = null
	bio_incubator = null
	return ..()

/datum/changeling_bio_incubator/build/proc/ensure_slot_capacity()
	while(module_ids.len < bio_incubator?.get_max_slots())
		module_ids += null

/datum/changeling_bio_incubator/build/proc/clear_configuration()
	var/changed = FALSE
	ensure_slot_capacity()
	for(var/i in 1 to module_ids.len)
		if(module_ids[i])
			module_ids[i] = null
			changed = TRUE
	return changed

/datum/changeling_bio_incubator/build/proc/set_module(slot, module_id)
	ensure_slot_capacity()
	if(module_ids[slot] == module_id)
		return FALSE
	if(module_id)
		for(var/i in 1 to module_ids.len)
			if(module_ids[i] != module_id)
				continue
			module_ids[i] = null
	module_ids[slot] = module_id
	return TRUE

/datum/changeling_bio_incubator/build/proc/to_data()
	var/list/data = list(
		"id" = REF(src),
		"name" = name,
	)
	ensure_slot_capacity()
	var/list/active_ids = bio_incubator?.get_active_module_ids() || list()
	var/list/datum/changeling_genetic_module/active_instances = bio_incubator?.get_active_modules() || list()
	data["activeModuleIds"] = active_ids.Copy()
	var/list/module_data = list()
	for(var/i in 1 to module_ids.len)
		var/module_id = module_ids[i]
		if(!module_id)
			module_data += list(null)
			continue
		var/list/entry = bio_incubator?.get_module_data(module_id)
		if(!entry)
			module_ids[i] = null
			module_data += list(null)
			continue
		entry = entry.Copy()
		entry["slot"] = i
		var/is_active = FALSE
		if(i <= active_instances.len)
			var/datum/changeling_genetic_module/active_module = active_instances[i]
			if(active_module?.id == module_id)
				is_active = TRUE
		entry["active"] = is_active
		module_data += list(entry)
	data["modules"] = module_data
	return data

#undef BIO_INCUBATOR_MAX_MODULE_SLOTS
#undef BIO_INCUBATOR_MAX_BUILDS
#undef BIO_INCUBATOR_UPDATE_CELLS
#undef BIO_INCUBATOR_UPDATE_RECIPES

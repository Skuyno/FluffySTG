#define BIO_INCUBATOR_MAX_MODULE_SLOTS 8
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
	/// Unique identifiers for collected cytology cell lines.
	var/list/cell_ids = list()
	/// Unique identifiers for known crafting recipes.
	var/list/recipe_ids = list()
	/// Assoc list of crafted module definitions indexed by identifier.
	var/list/crafted_modules = list()
	/// Stored build presets.
	var/list/datum/changeling_bio_incubator/build/builds = list()
	/// Currently active build preset.
	var/datum/changeling_bio_incubator/build/active_build

/datum/changeling_bio_incubator/New(datum/antagonist/changeling/changeling)
	. = ..()
	src.changeling = changeling

/datum/changeling_bio_incubator/Destroy()
	cell_ids = null
	recipe_ids = null
	crafted_modules = null
	QDEL_LIST(builds)
	builds = null
	active_build = null
	changeling = null
	return ..()

/datum/changeling_bio_incubator/proc/get_max_builds()
	return BIO_INCUBATOR_MAX_BUILDS

/datum/changeling_bio_incubator/proc/get_max_slots()
	return BIO_INCUBATOR_MAX_MODULE_SLOTS

/datum/changeling_bio_incubator/proc/can_add_build()
	return builds.len < get_max_builds()

/datum/changeling_bio_incubator/proc/ensure_default_build()
	if(builds.len)
		if(!active_build || !(active_build in builds))
			active_build = builds[1]
		return
	var/index = builds.len + 1
	add_build("Matrix Build [index]")
	if(!active_build && builds.len)
		active_build = builds[1]
		notify_update(BIO_INCUBATOR_UPDATE_BUILDS)

/datum/changeling_bio_incubator/proc/add_build(name)
	if(!can_add_build())
		return null
	var/datum/changeling_bio_incubator/build/build = new(src)
	build.name = name
	build.ensure_slot_capacity()
	builds += build
	if(!active_build)
		active_build = build
		notify_update(BIO_INCUBATOR_UPDATE_BUILDS)
	return build

/datum/changeling_bio_incubator/proc/remove_build(datum/changeling_bio_incubator/build/build)
	if(!build)
		return
	if(build in builds)
		builds -= build
	if(active_build == build)
		active_build = null
	qdel(build)
	if(!active_build && builds.len)
		active_build = builds[1]
	notify_update(BIO_INCUBATOR_UPDATE_BUILDS)

/datum/changeling_bio_incubator/proc/set_active_build(datum/changeling_bio_incubator/build/build)
	if(!build)
		return FALSE
	if(!(build in builds))
		return FALSE
	if(active_build == build)
		return TRUE
	active_build = build
	notify_update(BIO_INCUBATOR_UPDATE_BUILDS)
	return TRUE

/datum/changeling_bio_incubator/proc/get_active_build()
	return active_build

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

/datum/changeling_bio_incubator/proc/find_build_for_profile(datum/changeling_profile/profile)
	if(!profile)
		return null
	for(var/datum/changeling_bio_incubator/build/build as anything in builds)
		if(build.assigned_profile == profile)
			return build
	return null

/datum/changeling_bio_incubator/proc/prune_assignments()
	var/active_changed = FALSE
	for(var/datum/changeling_bio_incubator/build/build as anything in builds)
		build.ensure_slot_capacity()
		if(build.assigned_profile && !(build.assigned_profile in changeling?.stored_profiles))
			build.assigned_profile = null
		for(var/i in 1 to build.module_ids.len)
			var/module_id = build.module_ids[i]
			if(!module_id)
				continue
			if(!changeling?.has_genetic_matrix_module(module_id))
				build.module_ids[i] = null
				continue
			if(!module_slot_allowed(module_id, i))
				build.module_ids[i] = null
				continue
			if(build_has_exclusive_conflict(build, module_id, get_module_data(module_id), i))
				build.module_ids[i] = null
	if(active_build && !(active_build in builds))
		active_build = null
		active_changed = TRUE
	if(!active_build && builds.len)
		active_build = builds[1]
		active_changed = TRUE
	if(active_changed)
		notify_update(BIO_INCUBATOR_UPDATE_BUILDS)

/datum/changeling_bio_incubator/proc/assign_profile(datum/changeling_bio_incubator/build/build, datum/changeling_profile/profile)
	if(!build)
		return FALSE
	if(profile && !(profile in changeling?.stored_profiles))
		return FALSE
	if(build.assigned_profile == profile)
		return TRUE
	build.assigned_profile = profile
	notify_update(BIO_INCUBATOR_UPDATE_BUILDS)
	return TRUE

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
	notify_update(BIO_INCUBATOR_UPDATE_MODULES | BIO_INCUBATOR_UPDATE_BUILDS)
	return TRUE

/datum/changeling_bio_incubator/proc/has_module(module_id)
	module_id = sanitize_module_id(module_id)
	return crafted_modules[module_id] != null

/datum/changeling_bio_incubator/proc/get_crafted_module_catalog()
	var/list/catalog = list()
	for(var/module_id in crafted_modules)
		var/list/entry = crafted_modules[module_id]
		if(!islist(entry))
			continue
		catalog += list(entry.Copy())
	return catalog

/datum/changeling_bio_incubator/proc/get_module_data(module_id)
	module_id = sanitize_module_id(module_id)
	if(isnull(module_id))
		return null
	var/list/entry = crafted_modules[module_id]
	if(islist(entry))
		return entry.Copy()
	return null

/datum/changeling_bio_incubator/proc/add_cell(cell_identifier)
	var/cell_id = sanitize_module_id(cell_identifier)
	if(isnull(cell_id))
		return FALSE
	if(cell_id in cell_ids)
		return FALSE
	cell_ids += cell_id
	notify_update(BIO_INCUBATOR_UPDATE_CELLS)
	changeling?.update_genetic_matrix_unlocks()
	return TRUE

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
	var/path = text2path(cell_id)
	if(ispath(path, /datum/micro_organism/cell_line))
		var/datum/micro_organism/cell_line/cell_line = new path()
		var/name_source = path
		if(cell_line)
			name_source = cell_line.resulting_atom || path
			entry["desc"] = cell_line.desc
			qdel(cell_line)
		else
			entry["desc"] = null
		entry["name"] = get_nice_name_from_path(name_source)
	else
		entry["name"] = get_nice_name_from_path(cell_id)
		entry["desc"] = null
	return entry

/datum/changeling_bio_incubator/proc/get_nice_name_from_path(path_input)
	var/text_value = istext(path_input) ? path_input : "[path_input]"
	var/list/split_path = splittext(text_value, "/")
	if(!split_path.len)
		return text_value
	var/raw = split_path[split_path.len]
	raw = replacetext(raw, "_", " " )
	return capitalize(raw)

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

/datum/changeling_bio_incubator/proc/notify_update(update_flags = BIO_INCUBATOR_UPDATE_ALL)
	SEND_SIGNAL(src, COMSIG_CHANGELING_BIO_INCUBATOR_UPDATED, update_flags)
	if(changeling?.genetic_matrix)
		SStgui.update_uis(changeling.genetic_matrix)

/// Definition of a single build preset.
/datum/changeling_bio_incubator/build
	var/datum/changeling_bio_incubator/bio_incubator
	var/name = "Matrix Build"
	var/datum/changeling_profile/assigned_profile
	var/list/module_ids = list()

/datum/changeling_bio_incubator/build/New(datum/changeling_bio_incubator/bio_incubator)
	. = ..()
	src.bio_incubator = bio_incubator

/datum/changeling_bio_incubator/build/Destroy()
	assigned_profile = null
	module_ids = null
	bio_incubator = null
	return ..()

/datum/changeling_bio_incubator/build/proc/ensure_slot_capacity()
	while(module_ids.len < bio_incubator?.get_max_slots())
		module_ids += null

/datum/changeling_bio_incubator/build/proc/clear_configuration()
	var/changed = FALSE
	if(assigned_profile)
		assigned_profile = null
		changed = TRUE
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
	var/datum/antagonist/changeling/changeling = bio_incubator?.changeling
	data["active"] = bio_incubator?.active_build == src
	if(changeling && assigned_profile && (assigned_profile in changeling.stored_profiles))
		data["profile"] = changeling.get_genetic_matrix_profile_data(assigned_profile)
	else
		data["profile"] = null
	ensure_slot_capacity()
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
		module_data += list(entry)
	data["modules"] = module_data
	return data

#undef BIO_INCUBATOR_MAX_MODULE_SLOTS
#undef BIO_INCUBATOR_MAX_BUILDS
#undef BIO_INCUBATOR_UPDATE_CELLS
#undef BIO_INCUBATOR_UPDATE_RECIPES

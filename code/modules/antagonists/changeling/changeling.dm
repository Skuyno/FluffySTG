/// Helper to format the text that gets thrown onto the chem hud element.
#define FORMAT_CHEM_CHARGES_TEXT(charges) MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#dd66dd'>[round(charges)]</font></div>")

/// Normalizes identifiers for biomaterial records.
/proc/changeling_sanitize_material_id(identifier)
	if(isnull(identifier))
		return "biomaterial"
	var/id_text = lowertext("[identifier]")
	id_text = replacetext(id_text, " ", "_")
	id_text = replacetext(id_text, "-", "_")
	id_text = replacetext(id_text, "/", "_")
	id_text = replacetext(id_text, "\\", "_")
	id_text = replacetext(id_text, "'", "")
	id_text = replacetext(id_text, "\"", "")
	id_text = replacetext(id_text, "\[", "")
	id_text = replacetext(id_text, "\]", "")
	while(length(id_text) && copytext(id_text, 1, 2) == "_")
		id_text = copytext(id_text, 2)
	if(!length(id_text))
		return "biomaterial"
	return id_text

/datum/antagonist/changeling
	name = "\improper Changeling"
	roundend_category = "changelings"
	antagpanel_category = "Changeling"
	pref_flag = ROLE_CHANGELING
	antag_moodlet = /datum/mood_event/focused
	antag_hud_name = "changeling"
	hijack_speed = 0.5
	ui_name = "AntagInfoChangeling"
	suicide_cry = "FOR THE HIVE!!"
	can_assign_self_objectives = FALSE // NOVA EDIT CHANGE - Too loose of a cannon, and doesn't have staff sign off - ORIGINAL: can_assign_self_objectives = TRUE
	default_custom_objective = "Consume the station's most valuable genomes."
	hardcore_random_bonus = TRUE
	stinger_sound = 'sound/music/antag/ling_alert.ogg'

	/// Whether to give this changeling objectives or not
	var/give_objectives = TRUE
	/// Weather we assign objectives which compete with other lings
	var/competitive_objectives = FALSE

	// Changeling Stuff.
	// If you want good boy points,
	// separate the changeling (antag)
	// and the changeling (mechanics).

	/// list of datum/changeling_profile
	var/list/stored_profiles = list()
	/// The original profile of this changeling.
	var/datum/changeling_profile/first_profile = null
	/// How many DNA strands the changeling can store for transformation.
	var/dna_max = 6
	/// The amount of DNA gained. Includes DNA sting.
	var/absorbed_count = 0
	/// The amount of DMA gained using absorb, not DNA sting. Start with one (your original DNA)
	var/true_absorbs = 0
	/// The number of chemicals the changeling currently has.
	var/chem_charges = 20
	/// The max chemical storage the changeling currently has.
	var/total_chem_storage = 75
	/// The chemical recharge rate per life tick.
	var/chem_recharge_rate = 1
	/// Any additional modifiers triggered by changelings that modify the chem_recharge_rate.
	var/chem_recharge_slowdown = 0
	/// The range this ling can sting things.
	var/sting_range = 2
	/// Changeling name, what other lings see over the hivemind when talking.
	var/changelingID = "Changeling"
	/// The number of genetics points (to buy powers) this ling currently has.
	var/genetic_points = 10
	/// The max number of genetics points (to buy powers) this ling can have..
	var/total_genetic_points = 10
	/// List of all powers we start with.
	var/list/innate_powers = list()
	/// Associated list of all powers we have evolved / integrated via the matrix. [path] = [instance of path]
	var/list/purchased_powers = list()
	
	/// The voice we're mimicing via the changeling voice ability.
	var/mimicing = ""
	/// Whether we can currently respec in the genetic matrix.
	var/can_respec = 0
	
	/// The currently active changeling sting.
	var/datum/action/changeling/sting/chosen_sting
	/// A reference to our genetic matrix datum.
	var/datum/genetic_matrix/genetic_matrix
	/// A reference to our genetic matrix action (which opens the UI for the datum).
	var/datum/action/genetic_matrix/genetic_matrix_action
	/// Stored loadouts of purchased powers for quick swapping.
	var/list/genetic_presets = list()
	/// Maximum amount of presets we are willing to remember.
	var/static/max_genetic_presets = 6
	/// Predefined genetic presets that every changeling begins with.
	var/static/list/default_genetic_build_presets = list(
		list(
			"name" = "Rapid Responder",
			CHANGELING_BUILD_BLUEPRINT = list(
				CHANGELING_KEY_BUILD_SLOT = /datum/action/changeling/adrenaline,
				CHANGELING_SECONDARY_BUILD_SLOTS = list(
					/datum/action/changeling/fleshmend,
					/datum/action/changeling/augmented_eyesight,
					/datum/action/changeling/sting/extract_dna,
				),
			),
		),
		list(
			"name" = "Silent Infiltrator",
			CHANGELING_BUILD_BLUEPRINT = list(
				CHANGELING_KEY_BUILD_SLOT = /datum/action/changeling/digitalcamo,
				CHANGELING_SECONDARY_BUILD_SLOTS = list(
					/datum/action/changeling/mimicvoice,
					/datum/action/changeling/adaptive_wardrobe,
					/datum/action/changeling/sting/mute,
				),
			),
		),
	)
	/// Default biomaterial categories tracked within the changeling genetic matrix.
	var/static/list/default_biomaterial_categories = list(
		list("id" = "predatory", "name" = "Predatory Biomass"),
		list("id" = "adaptive", "name" = "Adaptive Tissue"),
		list("id" = "resilience", "name" = "Resilience Samples"),
	)
	/// Categorised biomaterial inventory seeded for the changeling.
	var/list/biomaterial_inventory
	/// Signature cells archived from unique targets.
	var/list/signature_cells
	/// Snapshot of the currently slotted abilities (key + secondary slots).
	var/list/active_build_slots

	/// UI displaying how many chems we have
	var/atom/movable/screen/ling/chems/lingchemdisplay
	/// UI displayng our currently active sting
	var/atom/movable/screen/ling/sting/lingstingdisplay

	/// The name of our "hive" that our ling came from. Flavor.
	var/hive_name

	/// Static typecache of all changeling powers that are usable.
	var/static/list/all_powers = typecacheof(/datum/action/changeling, ignore_root_path = TRUE)

	/// Static list of possible ids. Initialized into the greek alphabet the first time it is used
	var/static/list/possible_changeling_IDs

	/// Satic list of what each slot associated with (in regard to changeling flesh items).
	var/static/list/slot2type = list(
		"head" = /obj/item/clothing/head/changeling,
		"wear_mask" = /obj/item/clothing/mask/changeling,
		"wear_neck" = /obj/item/changeling,
		"back" = /obj/item/changeling,
		"wear_suit" = /obj/item/clothing/suit/changeling,
		"w_uniform" = /obj/item/clothing/under/changeling,
		"shoes" = /obj/item/clothing/shoes/changeling,
		"belt" = /obj/item/changeling,
		"gloves" = /obj/item/clothing/gloves/changeling,
		"glasses" = /obj/item/clothing/glasses/changeling,
		"ears" = /obj/item/changeling,
		"wear_id" = /obj/item/changeling/id,
		"s_store" = /obj/item/changeling,
	)

	/// A list of all memories we've stolen through absorbs.
	var/list/stolen_memories = list()

	/// Cached metadata for changeling powers keyed by type path.
	var/static/list/power_metadata_cache = list()

	///	Keeps track of the currently selected profile.
	var/datum/changeling_profile/current_profile
	/// Whether we can disguise clothing using stored icon snapshots
	var/has_adaptive_wardrobe = FALSE
	/// Snapshot currently applied as a clothing disguise overlay
	var/datum/icon_snapshot/current_clothing_disguise
	/// Mob currently using our clothing disguise overlay
	var/mob/living/carbon/human/clothing_disguise_target

/datum/antagonist/changeling/New()
	. = ..()
	initialize_changeling_inventories()
	hive_name = hive_name()
	for(var/datum/antagonist/changeling/other_ling in GLOB.antagonists)
		if(!other_ling.owner || other_ling.owner == owner)
			continue
		competitive_objectives = TRUE
		break



/datum/antagonist/changeling/Destroy()
	QDEL_NULL(genetic_matrix_action)
	QDEL_NULL(genetic_matrix)
	genetic_presets.Cut()
	biomaterial_inventory?.Cut()
	signature_cells?.Cut()
	active_build_slots?.Cut()
	current_profile = null
	clear_clothing_disguise()
	return ..()

/datum/antagonist/changeling/on_gain()
	generate_name()
	ensure_default_presets_loaded()
	create_genetic_matrix()
	create_innate_actions()
	create_initial_profile()
	if(give_objectives)
		forge_objectives()
	owner.current.get_language_holder().omnitongue = TRUE
	return ..()

/datum/antagonist/changeling/apply_innate_effects(mob/living/mob_override)
	var/mob/mob_to_tweak = mob_override || owner.current
	if(!isliving(mob_to_tweak))
		return

	var/mob/living/living_mob = mob_to_tweak
	handle_clown_mutation(living_mob, "You have evolved beyond your clownish nature, allowing you to wield weapons without harming yourself.")
	RegisterSignal(living_mob, COMSIG_MOB_LOGIN, PROC_REF(on_login))
	RegisterSignal(living_mob, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	RegisterSignal(living_mob, COMSIG_LIVING_POST_FULLY_HEAL, PROC_REF(on_fullhealed))
	RegisterSignal(living_mob, COMSIG_MOB_GET_STATUS_TAB_ITEMS, PROC_REF(get_status_tab_item))
	RegisterSignal(living_mob, COMSIG_LIVING_DEATH, PROC_REF(on_owner_death))
	RegisterSignals(living_mob, list(COMSIG_MOB_MIDDLECLICKON, COMSIG_MOB_ALTCLICKON), PROC_REF(on_click_sting))
	ADD_TRAIT(living_mob, TRAIT_FAKE_SOULLESS, CHANGELING_TRAIT)

	if(living_mob.hud_used)
		var/datum/hud/hud_used = living_mob.hud_used

		lingchemdisplay = new /atom/movable/screen/ling/chems(null, hud_used)
		hud_used.infodisplay += lingchemdisplay

		lingstingdisplay = new /atom/movable/screen/ling/sting(null, hud_used)
		hud_used.infodisplay += lingstingdisplay

		hud_used.show_hud(hud_used.hud_version)
	else
		RegisterSignal(living_mob, COMSIG_MOB_HUD_CREATED, PROC_REF(on_hud_created))

	make_brain_decoy(living_mob)

/datum/antagonist/changeling/proc/make_brain_decoy(mob/living/ling)
	var/obj/item/organ/brain/our_ling_brain = ling.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(isnull(our_ling_brain) || our_ling_brain.decoy_override)
		return

	// Brains are optional for lings.
	// This is automatically cleared if the ling is.
	our_ling_brain.AddComponent(/datum/component/ling_decoy_brain, src)


/// Applies a clothing disguise overlay onto the user using a stored snapshot.
/datum/antagonist/changeling/proc/apply_clothing_disguise(mob/living/carbon/human/user, datum/icon_snapshot/disguise_snapshot)
	if(!istype(user) || !disguise_snapshot)
		return

	clear_clothing_disguise(user)
	clothing_disguise_target = user
	current_clothing_disguise = disguise_snapshot
	user.icon = disguise_snapshot.icon
	user.icon_state = disguise_snapshot.icon_state
	user.cut_overlays()
	if(disguise_snapshot.overlays)
		user.add_overlay(disguise_snapshot.overlays)
	user.update_held_items()

/// Clears any currently applied clothing disguise overlay.
/datum/antagonist/changeling/proc/clear_clothing_disguise(mob/living/carbon/human/target)
	var/mob/living/carbon/human/disguised = clothing_disguise_target
	if(target)
		disguised = target
	else if(!disguised && owner && istype(owner.current, /mob/living/carbon/human))
		disguised = owner.current
	if(disguised && disguised == clothing_disguise_target && current_clothing_disguise)
		disguised.cut_overlays()
		disguised.regenerate_icons()
		disguised.update_held_items()
	clothing_disguise_target = null
	current_clothing_disguise = null

/datum/antagonist/changeling/proc/generate_name()
	var/honorific
	if(owner.current.gender == FEMALE)
		honorific = "Ms."
	else if(owner.current.gender == MALE)
		honorific = "Mr."
	else
		honorific = "Mx."

	if(!possible_changeling_IDs)
		possible_changeling_IDs = GLOB.greek_letters.Copy()
	if(possible_changeling_IDs.len)
		changelingID = "[honorific] [pick_n_take(possible_changeling_IDs)]"
	else
		changelingID = "[honorific] [rand(1,999)]"

/datum/antagonist/changeling/proc/on_hud_created(datum/source)
	SIGNAL_HANDLER

	var/datum/hud/ling_hud = owner.current.hud_used

	lingchemdisplay = new(null, ling_hud)
	ling_hud.infodisplay += lingchemdisplay

	lingstingdisplay = new(null, ling_hud)
	ling_hud.infodisplay += lingstingdisplay

	ling_hud.show_hud(ling_hud.hud_version)

/datum/antagonist/changeling/remove_innate_effects(mob/living/mob_override)
	var/mob/living/living_mob = mob_override || owner.current
	handle_clown_mutation(living_mob, removing = FALSE)
	UnregisterSignal(living_mob, list(COMSIG_MOB_LOGIN, COMSIG_LIVING_LIFE, COMSIG_LIVING_POST_FULLY_HEAL, COMSIG_MOB_GET_STATUS_TAB_ITEMS, COMSIG_MOB_MIDDLECLICKON, COMSIG_MOB_ALTCLICKON, COMSIG_LIVING_DEATH))
	REMOVE_TRAIT(living_mob, TRAIT_FAKE_SOULLESS, CHANGELING_TRAIT)
	if(istype(living_mob, /mob/living/carbon/human))
		clear_clothing_disguise(living_mob)
	else
		clear_clothing_disguise()

	if(living_mob.hud_used)
		var/datum/hud/hud_used = living_mob.hud_used

		hud_used.infodisplay -= lingchemdisplay
		hud_used.infodisplay -= lingstingdisplay
		QDEL_NULL(lingchemdisplay)
		QDEL_NULL(lingstingdisplay)

	// The old body's brain still remains a decoy, I guess?

/datum/antagonist/changeling/on_removal()
	remove_changeling_powers(include_innate = TRUE)
	return ..()

/datum/antagonist/changeling/farewell()
	if(owner.current)
		to_chat(owner.current, span_userdanger("You grow weak and lose your powers! You are no longer a changeling and are stuck in your current form!"))

/*
 * Instantiate the genetic matrix for the changeling.
 */
/datum/antagonist/changeling/proc/create_genetic_matrix()
	genetic_matrix = new(src)
	genetic_matrix_action = new(genetic_matrix)
	genetic_matrix_action.Grant(owner.current)
	synchronize_build_state()

/datum/antagonist/changeling/proc/initialize_changeling_inventories()
	biomaterial_inventory = list()
	if(LAZYLEN(default_biomaterial_categories))
		for(var/list/category as anything in default_biomaterial_categories)
			var/category_id = category["id"]
			var/category_name = category["name"]
			biomaterial_inventory[category_id] = list(
				"id" = category_id,
				"name" = category_name,
				"items" = list(),
			)
	signature_cells = list()
	reset_active_build_slots()

/datum/antagonist/changeling/proc/reset_active_build_slots()
	active_build_slots = list(
		CHANGELING_KEY_BUILD_SLOT = null,
		CHANGELING_SECONDARY_BUILD_SLOTS = list(),
	)

/datum/antagonist/changeling/proc/get_secondary_build_slots()
	if(!islist(active_build_slots))
		reset_active_build_slots()
	var/list/secondary = active_build_slots[CHANGELING_SECONDARY_BUILD_SLOTS]
	if(!islist(secondary))
		secondary = list()
		active_build_slots[CHANGELING_SECONDARY_BUILD_SLOTS] = secondary
	return secondary

/datum/antagonist/changeling/proc/ensure_default_presets_loaded()
	if(LAZYLEN(genetic_presets))
		return
	for(var/list/preset as anything in default_genetic_build_presets)
		var/list/build_blueprint = sanitize_build_blueprint(preset[CHANGELING_BUILD_BLUEPRINT])
		genetic_presets += list(list(
			"name" = preset["name"],
			CHANGELING_BUILD_BLUEPRINT = build_blueprint,
		))

/datum/antagonist/changeling/proc/sanitize_build_blueprint(list/raw_build)
	var/list/build = list()
	var/key_path = null
	if(islist(raw_build))
		if(ispath(raw_build[CHANGELING_KEY_BUILD_SLOT], /datum/action/changeling))
			key_path = raw_build[CHANGELING_KEY_BUILD_SLOT]
		var/list/secondary_paths = list()
		if(islist(raw_build[CHANGELING_SECONDARY_BUILD_SLOTS]))
			for(var/path in raw_build[CHANGELING_SECONDARY_BUILD_SLOTS])
				if(!ispath(path, /datum/action/changeling))
					continue
				if(path == key_path || (path in secondary_paths))
					continue
				secondary_paths += path
				if(secondary_paths.len >= CHANGELING_SECONDARY_SLOT_LIMIT)
					break
		build[CHANGELING_SECONDARY_BUILD_SLOTS] = secondary_paths
	else
		build[CHANGELING_SECONDARY_BUILD_SLOTS] = list()
	build[CHANGELING_KEY_BUILD_SLOT] = key_path
	return build

/datum/antagonist/changeling/proc/synchronize_build_state()
	if(!islist(active_build_slots))
		reset_active_build_slots()
	var/datum/action/changeling/key_path = active_build_slots[CHANGELING_KEY_BUILD_SLOT]
	if(!ispath(key_path, /datum/action/changeling) || !purchased_powers[key_path])
		key_path = null
	var/list/valid_secondary = list()
	for(var/path in get_secondary_build_slots())
		if(!ispath(path, /datum/action/changeling))
			continue
		if(!purchased_powers[path])
			continue
		if(path == key_path)
			continue
		if(valid_secondary.len >= CHANGELING_SECONDARY_SLOT_LIMIT)
			break
		valid_secondary += path
	active_build_slots[CHANGELING_KEY_BUILD_SLOT] = key_path
	active_build_slots[CHANGELING_SECONDARY_BUILD_SLOTS] = valid_secondary

/datum/antagonist/changeling/proc/get_biomaterial_category(category_id)
	if(!biomaterial_inventory)
		biomaterial_inventory = list()
	var/list/category_entry = biomaterial_inventory[category_id]
	if(!islist(category_entry))
		var/display_name
		for(var/list/default_entry as anything in default_biomaterial_categories)
			if(lowertext("[default_entry["id"]]") == lowertext("[category_id]"))
				display_name = default_entry["name"]
				break
		category_entry = list(
			"id" = category_id,
			"name" = display_name || capitalize(replacetext("[category_id]", "_", " ")),
			"items" = list(),
		)
		biomaterial_inventory[category_id] = category_entry
	return category_entry

/datum/antagonist/changeling/proc/adjust_biomaterial_entry(category_id, material_id, amount = 1, list/metadata)
	if(isnull(category_id) || isnull(material_id) || !isnum(amount))
		return 0
	var/list/category_entry = get_biomaterial_category(category_id)
	var/list/items = category_entry["items"]
	if(!islist(items))
		items = list()
		category_entry["items"] = items
	var/list/item_entry = items[material_id]
	if(!islist(item_entry))
		item_entry = list(
			"id" = material_id,
			"count" = 0,
		)
	if(islist(metadata))
		for(var/key in metadata)
			if(isnull(metadata[key]))
				continue
			item_entry[key] = metadata[key]
	item_entry["count"] = (item_entry["count"] || 0) + amount
	if(item_entry["count"] <= 0)
		items -= material_id
		return 0
	items[material_id] = item_entry
	return item_entry["count"]

/datum/antagonist/changeling/proc/adjust_signature_cell(cell_id, amount = 1, list/metadata)
	if(isnull(cell_id) || !isnum(amount))
		return 0
	if(!islist(signature_cells))
		signature_cells = list()
	var/list/cell_entry = signature_cells[cell_id]
	if(!islist(cell_entry))
		cell_entry = list(
			"id" = cell_id,
			"count" = 0,
		)
	if(islist(metadata))
		for(var/key in metadata)
			if(isnull(metadata[key]))
				continue
			cell_entry[key] = metadata[key]
	cell_entry["count"] = (cell_entry["count"] || 0) + amount
	if(cell_entry["count"] <= 0)
		signature_cells -= cell_id
		return 0
	signature_cells[cell_id] = cell_entry
	return cell_entry["count"]

/datum/antagonist/changeling/proc/can_harvest_biomaterials(mob/living/target, verbose = TRUE)
	if(!target || QDELETED(target))
		return FALSE
	if(target.stat == DEAD)
		if(verbose && owner?.current)
			to_chat(owner.current, span_warning("We require a living specimen."))
		return FALSE
	var/list/profile = target.get_changeling_biomaterial_profile()
	if(!LAZYLEN(profile))
		if(verbose && owner?.current)
			to_chat(owner.current, span_warning("No viable biomaterial detected within [target]."))
		return FALSE
	return TRUE

/datum/antagonist/changeling/proc/harvest_biomaterials_from_mob(mob/living/target)
	if(!target)
		return list()
	var/list/profile = target.get_changeling_biomaterial_profile()
	if(!LAZYLEN(profile))
		return list()
	var/list/results = list()
	var/base_name = initial(target.name) || "specimen"
	var/mob/living/carbon/dna_bearing_target
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		dna_bearing_target = human_target
	else if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		dna_bearing_target = carbon_target
	var/datum/dna/target_dna
	if(dna_bearing_target)
		target_dna = dna_bearing_target.has_dna()
		if(!target_dna)
			dna_bearing_target = null
	for(var/list/entry as anything in profile)
		if(!islist(entry))
			continue
		var/category = entry[CHANGELING_HARVEST_CATEGORY] || CHANGELING_BIOMATERIAL_CATEGORY_ADAPTIVE
		var/material_id = entry[CHANGELING_HARVEST_ID]
		if(!istext(material_id) || !length(material_id))
			material_id = changeling_sanitize_material_id(target.type)
		var/amount = max(1, entry[CHANGELING_HARVEST_AMOUNT] || 1)
		var/sample_name = entry[CHANGELING_HARVEST_NAME]
		if(!istext(sample_name) || !length(sample_name))
			sample_name = "[base_name] biomaterial"
		var/sample_description = entry[CHANGELING_HARVEST_DESCRIPTION]
		if(!istext(sample_description) || !length(sample_description))
			sample_description = "Biomaterial harvested from [base_name]."
		var/list/metadata = list(
			"name" = sample_name,
			"description" = sample_description,
		)
		if(entry[CHANGELING_HARVEST_QUALITY])
			metadata["quality"] = entry[CHANGELING_HARVEST_QUALITY]
		adjust_biomaterial_entry(category, material_id, amount, metadata)
		results += list(list(
			CHANGELING_HARVEST_CATEGORY = category,
			CHANGELING_HARVEST_ID = material_id,
			CHANGELING_HARVEST_NAME = sample_name,
			CHANGELING_HARVEST_DESCRIPTION = sample_description,
			CHANGELING_HARVEST_AMOUNT = amount,
		))
		if(entry[CHANGELING_HARVEST_SIGNATURE] && target_dna)
			var/signature_source_name = dna_bearing_target?.real_name || target.real_name || sample_name
			var/signature_id = target_dna.unique_enzymes || changeling_sanitize_material_id(signature_source_name || material_id)
			var/list/signature_metadata = list(
				"name" = signature_source_name || sample_name,
				"description" = "A distinctive cytology signature harvested from [target].",
			)
			adjust_signature_cell(signature_id, 1, signature_metadata)
	return results

/datum/antagonist/changeling/proc/harvest_biomaterials_from_samples(list/samples, atom/source)
	var/list/results = list()
	if(!islist(samples))
		return results
	for(var/sample_entry in samples)
		if(!istype(sample_entry, /datum/biological_sample))
			continue
		var/datum/biological_sample/sample = sample_entry
		for(var/datum/micro_organism/MO as anything in sample.micro_organisms)
			if(!istype(MO, /datum/micro_organism/cell_line))
				continue
			var/list/info = resolve_cell_line_biomaterial(MO, source)
			if(!islist(info))
				continue
			var/list/metadata = info["metadata"]
			adjust_biomaterial_entry(info[CHANGELING_HARVEST_CATEGORY], info[CHANGELING_HARVEST_ID], info[CHANGELING_HARVEST_AMOUNT], metadata)
			results += list(list(
				CHANGELING_HARVEST_CATEGORY = info[CHANGELING_HARVEST_CATEGORY],
				CHANGELING_HARVEST_ID = info[CHANGELING_HARVEST_ID],
				CHANGELING_HARVEST_NAME = info[CHANGELING_HARVEST_NAME],
				CHANGELING_HARVEST_DESCRIPTION = info[CHANGELING_HARVEST_DESCRIPTION],
				CHANGELING_HARVEST_AMOUNT = info[CHANGELING_HARVEST_AMOUNT],
			))
		qdel(sample)
	return results

/datum/antagonist/changeling/proc/resolve_cell_line_biomaterial(datum/micro_organism/cell_line/cell_line, atom/source)
	var/category = determine_cell_line_category(cell_line)
	var/material_id = changeling_sanitize_material_id(cell_line.type)
	var/display_name = cell_line.desc || "Cell culture"
	var/source_name = source ? source.name : "the environment"
	var/description = "[display_name] collected from [source_name]."
	var/list/metadata = list(
		"name" = display_name,
		"description" = description,
	)
	return list(
		CHANGELING_HARVEST_CATEGORY = category,
		CHANGELING_HARVEST_ID = material_id,
		CHANGELING_HARVEST_NAME = display_name,
		CHANGELING_HARVEST_DESCRIPTION = description,
		CHANGELING_HARVEST_AMOUNT = 1,
		"metadata" = metadata,
	)

/datum/antagonist/changeling/proc/determine_cell_line_category(datum/micro_organism/cell_line/cell_line)
	var/static/list/predatory_cell_lines = typecacheof(list(
		/datum/micro_organism/cell_line/blob_spore,
		/datum/micro_organism/cell_line/blobbernaut,
		/datum/micro_organism/cell_line/bear,
		/datum/micro_organism/cell_line/carp,
		/datum/micro_organism/cell_line/megacarp,
		/datum/micro_organism/cell_line/snake,
		/datum/micro_organism/cell_line/glockroach,
		/datum/micro_organism/cell_line/hauberoach,
		/datum/micro_organism/cell_line/vat_beast,
		/datum/micro_organism/cell_line/netherworld,
		/datum/micro_organism/cell_line/clown/glutton,
		/datum/micro_organism/cell_line/mega_arachnid,
	))
	if(is_type_in_typecache(cell_line, predatory_cell_lines))
		return CHANGELING_BIOMATERIAL_CATEGORY_PREDATORY
	var/static/list/resilience_cell_lines = typecacheof(list(
		/datum/micro_organism/cell_line/cockroach,
		/datum/micro_organism/cell_line/mouse,
		/datum/micro_organism/cell_line/pine,
		/datum/micro_organism/cell_line/snail,
		/datum/micro_organism/cell_line/gelatinous_cube,
		/datum/micro_organism/cell_line/walking_mushroom,
		/datum/micro_organism/cell_line/axolotl,
		/datum/micro_organism/cell_line/frog,
		/datum/micro_organism/cell_line/sholean_grapes,
	))
	if(is_type_in_typecache(cell_line, resilience_cell_lines))
		return CHANGELING_BIOMATERIAL_CATEGORY_RESILIENCE
	return CHANGELING_BIOMATERIAL_CATEGORY_ADAPTIVE

/datum/antagonist/changeling/proc/build_harvest_summary(list/results)
	if(!LAZYLEN(results))
		return ""
	var/list/fragments = list()
	for(var/list/result as anything in results)
		if(!islist(result))
			continue
		var/amount = result[CHANGELING_HARVEST_AMOUNT] || 1
		var/name = result[CHANGELING_HARVEST_NAME]
		if(!istext(name) || !length(name))
			name = capitalize(replacetext(result[CHANGELING_HARVEST_ID], "_", " "))
		var/category = result[CHANGELING_HARVEST_CATEGORY] || CHANGELING_BIOMATERIAL_CATEGORY_ADAPTIVE
		fragments += "[name] x[amount] ([category])"
	return english_list(fragments)

/datum/antagonist/changeling/proc/export_build_blueprint()
	if(!islist(active_build_slots))
		reset_active_build_slots()
	var/list/blueprint = list()
	if(ispath(active_build_slots[CHANGELING_KEY_BUILD_SLOT], /datum/action/changeling))
		blueprint[CHANGELING_KEY_BUILD_SLOT] = active_build_slots[CHANGELING_KEY_BUILD_SLOT]
	else
		blueprint[CHANGELING_KEY_BUILD_SLOT] = null
	var/list/secondary_paths = list()
	for(var/path in get_secondary_build_slots())
		if(ispath(path, /datum/action/changeling))
			secondary_paths += path
	blueprint[CHANGELING_SECONDARY_BUILD_SLOTS] = secondary_paths
	return blueprint

/datum/antagonist/changeling/proc/get_static_power_metadata(power_path)
	if(!ispath(power_path, /datum/action/changeling))
		return null
	var/list/metadata = power_metadata_cache[power_path]
	if(metadata)
		return metadata
	var/datum/action/changeling/temp_action = new power_path()
	if(!temp_action)
		return null
	metadata = list(
		"name" = temp_action.name,
		"desc" = temp_action.desc,
		"helptext" = temp_action.helptext,
		"dna_cost" = temp_action.dna_cost,
		"chemical_cost" = temp_action.chemical_cost,
	)
	power_metadata_cache[power_path] = metadata
	QDEL_NULL(temp_action)
	return metadata

/datum/antagonist/changeling/proc/build_slot_payload(power_path, datum/action/changeling/power, slot_id, slot_index)
	var/list/payload = list(
		"slot" = slot_id,
		"index" = slot_index,
		"path" = power_path,
	)
	if(power)
		payload["name"] = power.name
		payload["desc"] = power.desc
		payload["helptext"] = power.helptext
		payload["dna_cost"] = power.dna_cost
		payload["chemical_cost"] = power.chemical_cost
	else if(ispath(power_path, /datum/action/changeling))
		var/list/metadata = get_static_power_metadata(power_path)
		if(metadata)
			payload["name"] = metadata["name"]
			payload["desc"] = metadata["desc"]
			payload["helptext"] = metadata["helptext"]
			payload["dna_cost"] = metadata["dna_cost"]
			payload["chemical_cost"] = metadata["chemical_cost"]
	return payload

/datum/antagonist/changeling/proc/export_active_build_state()
	var/list/state = list()
	var/datum/action/changeling/key_path = active_build_slots?[CHANGELING_KEY_BUILD_SLOT]
	if(ispath(key_path, /datum/action/changeling) && purchased_powers[key_path])
		state[CHANGELING_KEY_BUILD_SLOT] = build_slot_payload(key_path, purchased_powers[key_path], CHANGELING_KEY_BUILD_SLOT, 1)
	else
		state[CHANGELING_KEY_BUILD_SLOT] = null
	var/list/secondary_payload = list()
	var/index = 1
	for(var/path in get_secondary_build_slots())
		if(!ispath(path, /datum/action/changeling))
			continue
		var/datum/action/changeling/ability = purchased_powers[path]
		secondary_payload += list(build_slot_payload(path, ability, CHANGELING_SECONDARY_BUILD_SLOTS, index))
		index++
	state[CHANGELING_SECONDARY_BUILD_SLOTS] = secondary_payload
	state["secondary_capacity"] = CHANGELING_SECONDARY_SLOT_LIMIT
	return state

/datum/antagonist/changeling/proc/build_biomaterial_payload()
	var/list/output = list()
	if(!islist(biomaterial_inventory))
		return output
	for(var/category_id in biomaterial_inventory)
		var/list/category_entry = biomaterial_inventory[category_id]
		if(!islist(category_entry))
			continue
		var/list/items_payload = list()
		var/list/items = category_entry["items"]
		if(islist(items))
			for(var/material_id in items)
				var/list/item_entry = items[material_id]
				if(!islist(item_entry))
					continue
				var/list/item_payload = list(
					"id" = item_entry["id"] || material_id,
					"name" = item_entry["name"] || capitalize(replacetext("[material_id]", "_", " ")),
					"count" = max(0, item_entry["count"] || 0),
				)
				if(item_entry["description"])
					item_payload["description"] = item_entry["description"]
				if(item_entry["quality"])
					item_payload["quality"] = item_entry["quality"]
				items_payload += list(item_payload)
		var/list/category_payload = list(
			"id" = category_entry["id"] || category_id,
			"name" = category_entry["name"] || capitalize(replacetext("[category_id]", "_", " ")),
			"items" = items_payload,
		)
		output += list(category_payload)
	return output

/datum/antagonist/changeling/proc/build_signature_payload()
	var/list/output = list()
	if(!islist(signature_cells))
		return output
	for(var/cell_id in signature_cells)
		var/list/cell_entry = signature_cells[cell_id]
		if(!islist(cell_entry))
			continue
		var/list/entry_payload = list(
			"id" = cell_entry["id"] || cell_id,
			"name" = cell_entry["name"] || capitalize(replacetext("[cell_id]", "_", " ")),
			"count" = max(0, cell_entry["count"] || 0),
		)
		if(cell_entry["description"])
			entry_payload["description"] = cell_entry["description"]
		output += list(entry_payload)
	return output

/datum/antagonist/changeling/proc/register_crafting_outcome(list/outcome_data, apply_immediately = FALSE)
	if(!islist(outcome_data))
		return FALSE
	if(islist(outcome_data["biomaterials"]))
		var/list/material_map = outcome_data["biomaterials"]
		for(var/category_id in material_map)
			var/value = material_map[category_id]
			if(islist(value))
				for(var/material_id in value)
					var/entry = value[material_id]
					if(isnum(entry))
						adjust_biomaterial_entry(category_id, material_id, entry)
					else if(islist(entry))
						var/amount = entry["count"] || entry["amount"] || 1
						adjust_biomaterial_entry(category_id, material_id, amount, entry)
			else if(isnum(value))
				adjust_biomaterial_entry(category_id, category_id, value)
	if(islist(outcome_data["signature_cells"]))
		var/list/signature_map = outcome_data["signature_cells"]
		for(var/cell_id in signature_map)
			var/sig_value = signature_map[cell_id]
			if(isnum(sig_value))
				adjust_signature_cell(cell_id, sig_value)
			else if(islist(sig_value))
				var/sig_amount = sig_value["count"] || sig_value["amount"] || 1
				adjust_signature_cell(cell_id, sig_amount, sig_value)
	var/apply_flag = apply_immediately || outcome_data["apply_build"]
	if(apply_flag && islist(outcome_data[CHANGELING_BUILD_BLUEPRINT]))
		apply_build(outcome_data[CHANGELING_BUILD_BLUEPRINT])
	return TRUE

/datum/antagonist/changeling/proc/register_power_slot(power_path, slot_identifier, force = FALSE)
	if(!ispath(power_path, /datum/action/changeling))
		return FALSE
	if(!islist(active_build_slots))
		reset_active_build_slots()
	remove_slot_assignment(power_path)
	if(slot_identifier == CHANGELING_KEY_BUILD_SLOT)
		var/current_key = active_build_slots[CHANGELING_KEY_BUILD_SLOT]
		if(current_key && current_key != power_path && !force)
			return FALSE
		active_build_slots[CHANGELING_KEY_BUILD_SLOT] = power_path
		return TRUE
	var/list/secondary_slots = get_secondary_build_slots()
	if(secondary_slots.len >= CHANGELING_SECONDARY_SLOT_LIMIT && !force)
		return FALSE
	if(force && secondary_slots.len >= CHANGELING_SECONDARY_SLOT_LIMIT)
		secondary_slots.Cut(CHANGELING_SECONDARY_SLOT_LIMIT, CHANGELING_SECONDARY_SLOT_LIMIT + 1)
	secondary_slots += power_path
	return TRUE

/datum/antagonist/changeling/proc/remove_slot_assignment(power_path)
	if(!islist(active_build_slots) || !power_path)
		return
	if(active_build_slots[CHANGELING_KEY_BUILD_SLOT] == power_path)
		active_build_slots[CHANGELING_KEY_BUILD_SLOT] = null
	var/list/secondary_slots = get_secondary_build_slots()
	for(var/index = secondary_slots.len, index > 0, index--)
		if(secondary_slots[index] == power_path)
			secondary_slots.Cut(index, index + 1)

/datum/antagonist/changeling/proc/remove_power(power_path, refund_points = TRUE)
	var/datum/action/changeling/power = purchased_powers[power_path]
	if(!power)
		return FALSE
	remove_slot_assignment(power_path)
	if(owner?.current)
		power.Remove(owner.current)
	qdel(power)
	purchased_powers -= power_path
	if(refund_points)
		var/refund = 0
		var/list/metadata = get_static_power_metadata(power_path)
		if(metadata)
			refund = metadata["dna_cost"] || 0
		refund = max(0, refund)
		if(refund)
			genetic_points = clamp(genetic_points + refund, 0, total_genetic_points)
	synchronize_build_state()
	return TRUE

/datum/antagonist/changeling/proc/get_power_display_name(power_path)
	if(purchased_powers[power_path])
		return purchased_powers[power_path].name
	if(ispath(power_path, /datum/action/changeling))
		var/list/metadata = get_static_power_metadata(power_path)
		if(metadata && metadata["name"])
			return metadata["name"]
	return "sequence"

/datum/antagonist/changeling/proc/set_active_key_power(power_path)
	if(!ispath(power_path, /datum/action/changeling))
		return FALSE
	var/datum/action/changeling/power = purchased_powers[power_path]
	if(!power)
		if(owner?.current)
			to_chat(owner.current, span_warning("We must evolve that sequence before we can promote it."))
		return FALSE
	if(active_build_slots?[CHANGELING_KEY_BUILD_SLOT] == power_path)
		if(owner?.current)
			to_chat(owner.current, span_notice("[power.name] already anchors our primary matrix."))
		synchronize_build_state()
		return TRUE
	var/previous_key = active_build_slots?[CHANGELING_KEY_BUILD_SLOT]
	if(!register_power_slot(power_path, CHANGELING_KEY_BUILD_SLOT, TRUE))
		if(owner?.current)
			to_chat(owner.current, span_warning("We fail to bind [power.name] as our key adaptation."))
		return FALSE
	if(previous_key && previous_key != power_path && purchased_powers[previous_key])
		var/list/secondary_slots = get_secondary_build_slots()
		if(secondary_slots.len >= CHANGELING_SECONDARY_SLOT_LIMIT)
			var/old_name = get_power_display_name(previous_key)
			remove_power(previous_key)
			if(owner?.current)
				to_chat(owner.current, span_warning("We shed [old_name] to maintain stability in our matrix."))
		else
			register_power_slot(previous_key, CHANGELING_SECONDARY_BUILD_SLOTS)
	synchronize_build_state()
	if(owner?.current)
		to_chat(owner.current, span_notice("We elevate [power.name] as our key adaptation."))
	return TRUE

/datum/antagonist/changeling/proc/apply_build(list/build_blueprint, replace_existing = TRUE)
	if(!islist(build_blueprint))
		return list("applied" = 0, "failed" = list())
	var/list/clean_blueprint = sanitize_build_blueprint(build_blueprint)
	var/datum/action/changeling/key_path = clean_blueprint[CHANGELING_KEY_BUILD_SLOT]
	var/list/secondary_paths = clean_blueprint[CHANGELING_SECONDARY_BUILD_SLOTS]
	var/list/desired_paths = list()
	if(ispath(key_path, /datum/action/changeling))
		desired_paths += key_path
	for(var/path in secondary_paths)
		if(path in desired_paths)
			continue
		desired_paths += path
	if(replace_existing)
		for(var/existing_path in assoc_to_keys(purchased_powers))
			if(!(existing_path in desired_paths))
				remove_power(existing_path)
	var/applied = 0
	var/list/failures = list()
	if(ispath(key_path, /datum/action/changeling))
		if(!purchased_powers[key_path])
			if(purchase_power(key_path, CHANGELING_KEY_BUILD_SLOT, TRUE))
				applied++
			else
				failures += get_power_display_name(key_path)
		else
			register_power_slot(key_path, CHANGELING_KEY_BUILD_SLOT, TRUE)
	else
		active_build_slots[CHANGELING_KEY_BUILD_SLOT] = null
	var/list/validated_secondaries = list()
	for(var/path in secondary_paths)
		if(path == key_path)
			continue
		if(!purchased_powers[path])
			if(purchase_power(path, CHANGELING_SECONDARY_BUILD_SLOTS, TRUE))
				applied++
			else
				failures += get_power_display_name(path)
				continue
		validated_secondaries += path
	reset_active_build_slots()
	if(ispath(key_path, /datum/action/changeling) && purchased_powers[key_path])
		active_build_slots[CHANGELING_KEY_BUILD_SLOT] = key_path
	var/list/final_secondaries = list()
	for(var/path in validated_secondaries)
		if(path == active_build_slots[CHANGELING_KEY_BUILD_SLOT])
			continue
		if(!purchased_powers[path])
			continue
		if(final_secondaries.len >= CHANGELING_SECONDARY_SLOT_LIMIT)
			break
		final_secondaries += path
	active_build_slots[CHANGELING_SECONDARY_BUILD_SLOTS] = final_secondaries
	synchronize_build_state()
	return list("applied" = applied, "failed" = failures, CHANGELING_BUILD_BLUEPRINT = clean_blueprint)

/datum/antagonist/changeling/proc/save_genetic_preset(preset_name)
	if(!owner?.current)
		return FALSE
	var/list/current_blueprint = export_build_blueprint()
	var/list/secondary_paths = current_blueprint[CHANGELING_SECONDARY_BUILD_SLOTS]
	if(!ispath(current_blueprint[CHANGELING_KEY_BUILD_SLOT], /datum/action/changeling) && !LAZYLEN(secondary_paths))
		to_chat(owner.current, span_warning("We have no manifested adaptations to archive."))
		return FALSE
	var/list/sanitized = sanitize_build_blueprint(current_blueprint)
	for(var/list/preset as anything in genetic_presets)
		if(preset["name"] == preset_name)
			preset[CHANGELING_BUILD_BLUEPRINT] = sanitized
			to_chat(owner.current, span_notice("We refine our [preset_name] genome matrix."))
			return TRUE
	if(LAZYLEN(genetic_presets) >= max_genetic_presets)
		to_chat(owner.current, span_warning("We cannot remember more than [max_genetic_presets] adaptation templates."))
		return FALSE
	var/list/new_entry = list(
		"name" = preset_name,
		CHANGELING_BUILD_BLUEPRINT = sanitized,
	)
	genetic_presets += list(new_entry)
	to_chat(owner.current, span_notice("We archive the [preset_name] adaptation sequence."))
	return TRUE

/datum/antagonist/changeling/proc/delete_genetic_preset(index)
	if(!isnum(index))
		return FALSE
        if(index < 1 || index > LAZYLEN(genetic_presets))
                return FALSE
        var/list/preset = genetic_presets[index]
        var/preset_label = preset ? preset["name"] : "lost"
        genetic_presets.Cut(index, index + 1)
        if(owner?.current && preset)
                to_chat(owner.current, span_notice("We purge the [preset_label] template."))
        return TRUE

/datum/antagonist/changeling/proc/rename_genetic_preset(index, new_name)
	if(!isnum(index))
		return FALSE
	if(index < 1 || index > LAZYLEN(genetic_presets))
		return FALSE
	var/list/preset = genetic_presets[index]
	if(!preset)
		return FALSE
	preset["name"] = new_name
	if(owner?.current)
		to_chat(owner.current, span_notice("We rechristen our template as [new_name]."))
	return TRUE

/datum/antagonist/changeling/proc/apply_genetic_preset(index)
	if(!isnum(index))
		return FALSE
	if(index < 1 || index > LAZYLEN(genetic_presets))
		return FALSE
	var/list/preset = genetic_presets[index]
	var/list/blueprint = sanitize_build_blueprint(preset[CHANGELING_BUILD_BLUEPRINT])
	var/list/result = apply_build(blueprint)
	preset[CHANGELING_BUILD_BLUEPRINT] = result[CHANGELING_BUILD_BLUEPRINT]
	var/applied = result["applied"] || 0
	var/list/failures = result["failed"] || list()
	if(owner?.current)
		var/preset_name = preset["name"]
		if(applied)
			to_chat(owner.current, span_notice("We align our genome with [preset_name], manifesting [applied] adaptation[applied == 1 ? "" : "s"]."))
		if(LAZYLEN(failures))
			to_chat(owner.current, span_warning("We lack the resources for [english_list(failures)]."))
	return applied > 0

/datum/antagonist/changeling/proc/create_innate_actions()
	for(var/datum/action/changeling/path as anything in all_powers)
		if(initial(path.dna_cost) != CHANGELING_POWER_INNATE)
			continue

		var/datum/action/changeling/innate_ability = new path()
		innate_powers += innate_ability
		innate_ability.on_purchase(owner.current, TRUE)

/*
 * Signal proc for [COMSIG_MOB_LOGIN].
 * Gives us back our action buttons if we lose them on log-in.
 */
/datum/antagonist/changeling/proc/on_login(datum/source)
	SIGNAL_HANDLER

	if(!isliving(source))
		return
	var/mob/living/living_source = source
	if(!living_source.mind)
		return

	regain_powers()

/**
 * Signal proc for [COMSIG_LIVING_LIFE].
 * Handles regenerating chemicals on life ticks.
 */
/datum/antagonist/changeling/proc/on_life(datum/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	var/delta_time = DELTA_WORLD_TIME(SSmobs)
	var/mob/living/living_owner = owner.current

	// If dead, we only regenerate up to half chem storage.
	if(owner.current.stat == DEAD)
		adjust_chemicals((chem_recharge_rate - chem_recharge_slowdown) * delta_time, total_chem_storage * 0.5)

	// If we're not dead and not on fire - we go up to the full chem cap at normal speed. If on fire we only regenerate at 1/4th the normal speed
	else
		if(living_owner.fire_stacks && living_owner.on_fire)
			adjust_chemicals((chem_recharge_rate - 0.75) * delta_time)
		else
			adjust_chemicals((chem_recharge_rate - chem_recharge_slowdown) * delta_time)

/**
 * Signal proc for [COMSIG_LIVING_POST_FULLY_HEAL]
 */
/datum/antagonist/changeling/proc/on_fullhealed(mob/living/source, heal_flags)
	SIGNAL_HANDLER

	// Aheal restores all chemicals
	if(heal_flags & HEAL_ADMIN)
		adjust_chemicals(INFINITY)

	// Makes sure the brain, if recreated, is a decoy as expected
	make_brain_decoy(source)

/**
 * Signal proc for [COMSIG_LIVING_DEATH].
 */
/datum/antagonist/changeling/proc/on_owner_death(mob/living/source, gibbed)
	SIGNAL_HANDLER

	if(istype(source, /mob/living/carbon/human))
		clear_clothing_disguise(source)
	else
		clear_clothing_disguise()

/**
 * Signal proc for [COMSIG_MOB_MIDDLECLICKON] and [COMSIG_MOB_ALTCLICKON].
 * Allows the changeling to sting people with a click.
 */
/datum/antagonist/changeling/proc/on_click_sting(mob/living/ling, atom/clicked)
	SIGNAL_HANDLER

	// nothing to handle
	if(!chosen_sting)
		return
	if(!isliving(ling) || clicked == ling || ling.stat != CONSCIOUS)
		return
	// sort-of hack done here: we use in_given_range here because it's quicker.
	// actual ling stings do pathfinding to determine whether the target's "in range".
	// however, this is "close enough" preliminary checks to not block click
	if(!isliving(clicked) || !IN_GIVEN_RANGE(ling, clicked, sting_range))
		return

	INVOKE_ASYNC(chosen_sting, TYPE_PROC_REF(/datum/action/changeling/sting, try_to_sting), ling, clicked)

	return COMSIG_MOB_CANCEL_CLICKON

/datum/antagonist/changeling/proc/get_status_tab_item(mob/living/source, list/items)
	SIGNAL_HANDLER
	items += "Chemical Storage: [chem_charges]/[total_chem_storage]"
	items += "Absorbed DNA: [absorbed_count]"

/*
 * Adjust the chem charges of the ling by [amount]
 * and clamp it between 0 and override_cap (if supplied) or total_chem_storage (if no override supplied)
 */
/datum/antagonist/changeling/proc/adjust_chemicals(amount, override_cap)
	if(!isnum(amount))
		return
	var/cap_to = isnum(override_cap) ? override_cap : total_chem_storage
	chem_charges = clamp(chem_charges + amount, 0, cap_to)

	lingchemdisplay?.maptext = FORMAT_CHEM_CHARGES_TEXT(chem_charges)

/*
 * Remove changeling powers from the current Changeling's purchased_powers list.
 *
 * if [include_innate] = TRUE, will also remove all powers from the Changeling's innate_powers list.
 */
/datum/antagonist/changeling/proc/remove_changeling_powers(include_innate = FALSE)
	if(!isliving(owner.current))
		return

	if(chosen_sting)
		chosen_sting.unset_sting(owner.current)

	QDEL_LIST_ASSOC_VAL(purchased_powers)
	purchased_powers = list()
	if(include_innate)
		QDEL_LIST(innate_powers)

	genetic_points = total_genetic_points
	chem_charges = min(chem_charges, total_chem_storage)
	chem_recharge_rate = initial(chem_recharge_rate)
	chem_recharge_slowdown = initial(chem_recharge_slowdown)
	reset_active_build_slots()
	synchronize_build_state()

/*
 * For resetting all of the changeling's action buttons. (IE, re-granting them all.)
 */

/datum/antagonist/changeling/proc/regain_powers()
	genetic_matrix_action.Grant(owner.current)
	for(var/datum/action/changeling/power as anything in innate_powers)
		power.on_purchase(owner.current)

	for(var/power_path in purchased_powers)
		var/datum/action/changeling/power = purchased_powers[power_path]
		if(istype(power))
			power.on_purchase(owner.current)

/*
 * The act of purchasing a certain power for a changeling.
 *
 * [sting_path] - the power that's being purchased / evolved.
 */
/datum/antagonist/changeling/proc/purchase_power(datum/action/changeling/sting_path, slot_identifier, force_slot = FALSE)
	if(!ispath(sting_path, /datum/action/changeling))
		CRASH("Changeling purchase_power attempted to purchase an invalid typepath! (got: [sting_path])")

	if(purchased_powers[sting_path])
		to_chat(owner.current, span_warning("We have already evolved this ability!"))
		return FALSE

	var/slot_choice = (slot_identifier == CHANGELING_KEY_BUILD_SLOT) ? CHANGELING_KEY_BUILD_SLOT : CHANGELING_SECONDARY_BUILD_SLOTS
	if(slot_choice == CHANGELING_KEY_BUILD_SLOT)
		var/current_key = active_build_slots?[CHANGELING_KEY_BUILD_SLOT]
		if(current_key && current_key != sting_path && !force_slot)
			to_chat(owner.current, span_warning("Our primary adaptation slot is already occupied."))
			return FALSE
	else
		var/list/secondary_slots = get_secondary_build_slots()
		if(secondary_slots.len >= CHANGELING_SECONDARY_SLOT_LIMIT && !force_slot)
			to_chat(owner.current, span_warning("We cannot integrate more than [CHANGELING_SECONDARY_SLOT_LIMIT] secondary sequences at once."))
			return FALSE

	if(genetic_points < initial(sting_path.dna_cost))
		to_chat(owner.current, span_warning("We have reached our capacity for abilities!"))
		return FALSE

	if(absorbed_count < initial(sting_path.req_dna))
		to_chat(owner.current, span_warning("We lack the DNA to evolve this ability!"))
		return FALSE

	if(true_absorbs < initial(sting_path.req_absorbs))
		to_chat(owner.current, span_warning("We lack the absorbed DNA to evolve this ability!"))
		return FALSE

	if(initial(sting_path.dna_cost) < 0)
		to_chat(owner.current, span_warning("We cannot evolve this ability!"))
		return FALSE

	//To avoid potential exploits by buying new powers while in stasis, which clears your verblist. // Probably not a problem anymore, but whatever.
	if(HAS_TRAIT(owner.current, TRAIT_DEATHCOMA))
		to_chat(owner.current, span_warning("We lack the energy to evolve new abilities right now!"))
		return FALSE

	var/success = give_power(sting_path)
	if(success)
		if(!register_power_slot(sting_path, slot_choice, force_slot))
			remove_power(sting_path, FALSE)
			to_chat(owner.current, span_warning("We cannot stabilize this sequence within our current matrix."))
			return FALSE
		genetic_points -= initial(sting_path.dna_cost)
		synchronize_build_state()
	return success

/**
 * Gives a passed changeling power datum to the player
 *
 * Is passed a path to a changeling power, and applies it to the user.
 * If successful, we return TRUE, otherwise not.
 *
 * Arguments:
 * * power_path - The path of the power we will be giving to our attached player.
 */

/datum/antagonist/changeling/proc/give_power(power_path)
	var/datum/action/changeling/new_action = new power_path()

	if(!new_action)
		to_chat(owner.current, "This is awkward. Changeling power purchase failed, please report this bug to a coder!")
		CRASH("Changeling give_power was unable to grant a new changeling action for path [power_path]!")

	purchased_powers[power_path] = new_action
	new_action.on_purchase(owner.current) // Grant() is ran in this proc, see changeling_powers.dm.
	log_changeling_power("[key_name(owner)] adapted the [new_action.name] power")
	SSblackbox.record_feedback("tally", "changeling_power_purchase", 1, new_action.name)

	return TRUE

/*
 * Changeling's ability to re-adapt all of their learned powers.
 */
/datum/antagonist/changeling/proc/readapt()
	if(!ishuman(owner.current) || ismonkey(owner.current))
		to_chat(owner.current, span_warning("We can't remove our evolutions in this form!"))
		return FALSE

	if(HAS_TRAIT_FROM(owner.current, TRAIT_DEATHCOMA, CHANGELING_TRAIT))
		to_chat(owner.current, span_warning("We are too busy reforming ourselves to readapt right now!"))
		return FALSE

	if(!can_respec)
		to_chat(owner.current, span_warning("You lack the power to readapt your evolutions!"))
		return FALSE

	to_chat(owner.current, span_notice("We have removed our evolutions from this form, and are now ready to readapt."))
	clear_clothing_disguise(owner.current)
	remove_changeling_powers()
	can_respec -= 1
	SSblackbox.record_feedback("tally", "changeling_power_purchase", 1, "Readapt")
	log_changeling_power("[key_name(owner)] readapted their changeling powers")
	return TRUE

/*
 * Get the corresponding changeling profile for the passed name.
 */
/datum/antagonist/changeling/proc/get_dna(searched_dna_name)
	for(var/datum/changeling_profile/found_profile as anything in stored_profiles)
		if(searched_dna_name == found_profile.name)
			return found_profile

/*
 * Checks if we have a changeling profile with the passed DNA.
 */
/datum/antagonist/changeling/proc/has_profile_with_dna(datum/dna/searched_dna)
	for(var/datum/changeling_profile/found_profile as anything in stored_profiles)
		if(searched_dna.is_same_as(found_profile.dna))
			return TRUE
	return FALSE

/*
 * Checks if this changeling can absorb the DNA of [target].
 * if [verbose] = TRUE, give feedback as to why they cannot absorb the DNA.
 */
/datum/antagonist/changeling/proc/can_absorb_dna(mob/living/carbon/human/target, verbose = TRUE)
	if(!target)
		return FALSE
	if(!iscarbon(owner.current))
		return FALSE
	var/mob/living/carbon/user = owner.current

	if(stored_profiles.len)
		// If our current DNA is the stalest, we gotta ditch it before absorbing more.
		var/datum/changeling_profile/top_profile = stored_profiles[1]
		if(top_profile.dna.is_same_as(user.dna) && stored_profiles.len > dna_max)
			if(verbose)
				to_chat(user, span_warning("We have reached our capacity to store genetic information! We must transform before absorbing more."))
			return FALSE

	if(!target.has_dna())
		if(verbose)
			to_chat(user, span_warning("[target] is not compatible with our biology."))
		return FALSE
	if(has_profile_with_dna(target.dna))
		if(verbose)
			to_chat(user, span_warning("We already have this DNA in storage!"))
		return FALSE
	if(HAS_TRAIT(target, TRAIT_NO_DNA_COPY))
		if(verbose)
			to_chat(user, span_warning("[target] is not compatible with our biology."))
		return FALSE
	if(HAS_TRAIT(target, TRAIT_BADDNA))
		if(verbose)
			to_chat(user, span_warning("[target]'s DNA is ruined beyond usability!"))
		return FALSE
	if(HAS_TRAIT(target, TRAIT_HUSK))
		if(verbose)
			to_chat(user, span_warning("[target]'s body is ruined beyond usability!"))
		return FALSE
	if(!ishuman(target) || ismonkey(target))//Absorbing monkeys is entirely possible, but it can cause issues with transforming. That's what lesser form is for anyway!
		if(verbose)
			to_chat(user, span_warning("We could gain no benefit from absorbing a lesser creature."))
		return FALSE

	return TRUE

/*
 * Create a new changeling profile datum based off of [target].
 *
 * target - the human we're basing the new profile off of.
 * protect - if TRUE, set the new profile to protected, preventing it from being removed (without force).
 */
/datum/antagonist/changeling/proc/create_profile(mob/living/carbon/human/target, protect = 0)
	var/datum/changeling_profile/new_profile = new()

	target.dna.real_name = target.real_name //Set this again, just to be sure that it's properly set.

	// Set up a copy of their DNA in our profile.
	var/datum/dna/new_dna = new target.dna.type()
	target.dna.copy_dna(new_dna)
	new_profile.dna = new_dna
	new_profile.name = target.real_name
	new_profile.protected = protect

	new_profile.age = target.age
	new_profile.physique = target.physique
	new_profile.athletics_level = target.mind?.get_skill_level(/datum/skill/athletics) || SKILL_LEVEL_NONE

	// Grab the target's quirks.
	for(var/datum/quirk/target_quirk as anything in target.quirks)
		LAZYADD(new_profile.quirks, new target_quirk.type)

	// Clothes, of course
	new_profile.underwear = target.underwear
	new_profile.underwear_color = target.underwear_color
	new_profile.undershirt = target.undershirt
	new_profile.socks = target.socks
	// NOVA EDIT ADDITION START
	new_profile.bra = target.bra
	new_profile.undershirt_color = target.undershirt_color
	new_profile.socks_color = target.socks_color
	new_profile.bra_color = target.bra_color
	new_profile.emissive_eyes = target.emissive_eyes
	new_profile.scream_type = target.selected_scream?.type || /datum/scream_type/none
	new_profile.laugh_type = target.selected_laugh?.type || /datum/laugh_type/none
	new_profile.target_height = target.mob_height
	new_profile.target_mob_size = target.mob_size
	//NOVA EDIT ADDITION END

	//THE FLUFFY FRONTIER EDIT ADDITION BEGIN - Blooper
	new_profile.blooper_id = target.blooper_id
	new_profile.blooper_pitch = target.blooper_pitch
	new_profile.blooper_speed = target.blooper_speed
	new_profile.blooper_pitch_range = target.blooper_pitch_range
	//THE FLUFFY FRONTIER EDIT END

	// Grab skillchips they have
	new_profile.skillchips = target.clone_skillchip_list(TRUE)

	// Get any scars they may have
	for(var/datum/scar/target_scar as anything in target.all_scars)
		LAZYADD(new_profile.stored_scars, target_scar.format())

	// Make an icon snapshot of what they currently look like
	var/datum/icon_snapshot/entry = new()
	entry.name = target.name
	entry.icon = target.icon
	entry.icon_state = target.icon_state
	entry.overlays = target.get_overlays_copy(list(HANDS_LAYER, HANDCUFF_LAYER, LEGCUFF_LAYER))
	new_profile.profile_snapshot = entry

	// Grab the target's sechut icon.
	new_profile.id_icon = target.wear_id?.get_sechud_job_icon_state()

	var/list/slots = list("head", "wear_mask", "wear_neck", "back", "wear_suit", "w_uniform", "shoes", "belt", "gloves", "glasses", "ears", "wear_id", "s_store")
	for(var/slot in slots)
		if(!(slot in target.vars))
			continue
		var/obj/item/clothing/clothing_item = target.vars[slot]
		if(!clothing_item)
			continue
		new_profile.name_list[slot] = clothing_item.name
		new_profile.appearance_list[slot] = clothing_item.appearance
		new_profile.flags_cover_list[slot] = clothing_item.flags_cover
		new_profile.lefthand_file_list[slot] = clothing_item.lefthand_file
		new_profile.righthand_file_list[slot] = clothing_item.righthand_file
		new_profile.inhand_icon_state_list[slot] = clothing_item.inhand_icon_state
		new_profile.worn_icon_list[slot] = clothing_item.worn_icon
		new_profile.worn_icon_state_list[slot] = clothing_item.worn_icon_state
		new_profile.exists_list[slot] = 1
		// NOVA EDIT ADDITION START
		new_profile.worn_icon_digi_list[slot] = clothing_item.worn_icon_digi
		new_profile.worn_icon_monkey_list[slot] = clothing_item.worn_icon_monkey
		new_profile.worn_icon_teshari_list[slot] = clothing_item.worn_icon_teshari
		new_profile.worn_icon_vox_list[slot] = clothing_item.worn_icon_vox
		new_profile.supports_variations_flags_list[slot] = clothing_item.supports_variations_flags
		// NOVA EDIT ADDITION END

	new_profile.voice = target.voice
	new_profile.voice_filter = target.voice_filter

	return new_profile

/*
 * Add a new profile to our changeling's profile list.
 * Pops the first profile in the list if we're above our limit of profiles.
 *
 * new_profile - the profile being added.
 */
/datum/antagonist/changeling/proc/add_profile(datum/changeling_profile/new_profile)
	if(stored_profiles.len > dna_max)
		if(!push_out_profile())
			return

	if(!first_profile)
		first_profile = new_profile
		current_profile = first_profile

	stored_profiles += new_profile
	absorbed_count++

/*
 * Create a new profile from the given [profile_target]
 * and add it to our profile list via add_profile.
 *
 * profile_target - the human we're making a profile based off of
 * protect - if TRUE, mark the new profile as protected. If protected, it cannot be removed / popped from the profile list (without force).
 */
/datum/antagonist/changeling/proc/add_new_profile(mob/living/carbon/human/profile_target, protect = FALSE)
	var/datum/changeling_profile/new_profile = create_profile(profile_target, protect)
	add_profile(new_profile)
	return new_profile

/*
 * Remove a given profile from the profile list.
 *  *
 * profile_target - the human we want to remove from our profile list (looks for a profile with a matching name)
 * force - if TRUE, removes the profile even if it's protected.
 */
/datum/antagonist/changeling/proc/remove_profile(mob/living/carbon/human/profile_target, force = FALSE)
	for(var/datum/changeling_profile/found_profile as anything in stored_profiles)
		if(profile_target.real_name == found_profile.name)
			if(found_profile.protected && !force)
				continue
			stored_profiles -= found_profile
			qdel(found_profile)

/*
 * Removes the highest changeling profile from the list
 * that isn't protected and returns TRUE if successful.
 *
 * Returns TRUE if a profile was removed, FALSE otherwise.
 */
/datum/antagonist/changeling/proc/push_out_profile()
	var/datum/changeling_profile/profle_to_remove
	for(var/datum/changeling_profile/found_profile as anything in stored_profiles)
		if(!found_profile.protected)
			profle_to_remove = found_profile
			break

	if(profle_to_remove)
		stored_profiles -= profle_to_remove
		return TRUE
	return FALSE

/*
 * Create a profile based on the changeling's initial appearance.
 */
/datum/antagonist/changeling/proc/create_initial_profile()
	if(!ishuman(owner.current))
		return

	add_new_profile(owner.current)

/datum/antagonist/changeling/forge_objectives()
	var/escape_objective_possible = TRUE

	switch(competitive_objectives ? rand(1,3) : 1)
		if(1)
			var/datum/objective/absorb/absorb_objective = new
			absorb_objective.owner = owner
			absorb_objective.gen_amount_goal(6, 8)
			objectives += absorb_objective
		if(2)
			var/datum/objective/absorb_most/ac = new
			ac.owner = owner
			objectives += ac
		if(3)
			var/datum/objective/absorb_changeling/ac = new
			ac.owner = owner
			objectives += ac

	if(prob(60))
		var/datum/objective/steal/steal_objective = new
		steal_objective.owner = owner
		steal_objective.find_target()
		objectives += steal_objective

	var/list/active_ais = active_ais()
	if(active_ais.len && prob(100/GLOB.joined_player_list.len))
		var/datum/objective/destroy/destroy_objective = new
		destroy_objective.owner = owner
		destroy_objective.find_target()
		objectives += destroy_objective
	else
		if(prob(70))
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			objectives += kill_objective
		else
			var/datum/objective/maroon/maroon_objective = new
			maroon_objective.owner = owner

			if (!(locate(/datum/objective/escape) in objectives) && escape_objective_possible)
				var/datum/objective/escape/escape_with_identity/identity_theft = new
				identity_theft.owner = owner
				identity_theft.find_target()
				identity_theft.update_explanation_text()
				escape_objective_possible = FALSE
				maroon_objective.target = identity_theft.target || maroon_objective.find_target()
				maroon_objective.update_explanation_text()
				objectives += maroon_objective
				objectives += identity_theft
			else
				maroon_objective.find_target()
				objectives += maroon_objective


	if (!(locate(/datum/objective/escape) in objectives) && escape_objective_possible)
		if(prob(50))
			var/datum/objective/escape/escape_objective = new
			escape_objective.owner = owner
			objectives += escape_objective
		else
			var/datum/objective/escape/escape_with_identity/identity_theft = new
			identity_theft.owner = owner
			identity_theft.find_target()
			objectives += identity_theft
		escape_objective_possible = FALSE

/datum/antagonist/changeling/get_admin_commands()
	. = ..()
	if(stored_profiles.len && (owner.current.real_name != first_profile.name))
		.["Transform to initial appearance."] = CALLBACK(src, PROC_REF(admin_restore_appearance))

/*
 * Restores the appearance of the changeling to the original DNA.
 */
/datum/antagonist/changeling/proc/admin_restore_appearance(mob/admin)
	if(!stored_profiles.len || !iscarbon(owner.current))
		to_chat(admin, span_danger("Resetting DNA failed!"))
		return

	var/mob/living/carbon/carbon_owner = owner.current
	first_profile.dna.copy_dna(carbon_owner.dna, COPY_DNA_SE|COPY_DNA_SPECIES)
	carbon_owner.real_name = first_profile.name
	carbon_owner.updateappearance(mutcolor_update = TRUE)
	carbon_owner.domutcheck()

/*
 * Transform the currentc hangeing [user] into the [chosen_profile].
 */
/datum/antagonist/changeling/proc/transform(mob/living/carbon/human/user, datum/changeling_profile/chosen_profile)
	var/static/list/slot2slot = list(
		"head" = ITEM_SLOT_HEAD,
		"wear_mask" = ITEM_SLOT_MASK,
		"wear_neck" = ITEM_SLOT_NECK,
		"back" = ITEM_SLOT_BACK,
		"wear_suit" = ITEM_SLOT_OCLOTHING,
		"w_uniform" = ITEM_SLOT_ICLOTHING,
		"shoes" = ITEM_SLOT_FEET,
		"belt" = ITEM_SLOT_BELT,
		"gloves" = ITEM_SLOT_GLOVES,
		"glasses" = ITEM_SLOT_EYES,
		"ears" = ITEM_SLOT_EARS,
		"wear_id" = ITEM_SLOT_ID,
		"s_store" = ITEM_SLOT_SUITSTORE,
	)

	clear_clothing_disguise(user)
	var/use_clothing_disguise = has_adaptive_wardrobe && !isnull(chosen_profile.profile_snapshot)

	var/datum/dna/chosen_dna = chosen_profile.dna
	user.real_name = chosen_profile.name
	user.underwear = chosen_profile.underwear
	user.underwear_color = chosen_profile.underwear_color
	user.undershirt = chosen_profile.undershirt
	user.socks = chosen_profile.socks
	user.age = chosen_profile.age
	user.physique = chosen_profile.physique
	user.mind?.set_level(/datum/skill/athletics, chosen_profile.athletics_level, silent = TRUE)
	user.voice = chosen_profile.voice
	user.voice_filter = chosen_profile.voice_filter
	// NOVA EDIT ADDITION START
	user.bra = chosen_profile.bra
	user.undershirt_color = chosen_profile.undershirt_color
	user.socks_color = chosen_profile.socks_color
	user.bra_color = chosen_profile.bra_color
	user.emissive_eyes = chosen_profile.emissive_eyes
	user.dna.mutant_bodyparts = chosen_dna.mutant_bodyparts.Copy()
	user.dna.body_markings = chosen_dna.body_markings.Copy()

	qdel(user.selected_scream)
	qdel(user.selected_laugh)
	user.selected_scream = new chosen_profile.scream_type
	user.selected_laugh = new chosen_profile.laugh_type
	user.mob_size = chosen_profile.target_mob_size
	user.set_mob_height(chosen_profile.target_height)

	// Only certain quirks will be copied, to avoid making the changeling blind or wheelchair-bound when they can simply pretend to have these quirks.

	for(var/datum/quirk/target_quirk in user.quirks)
		for(var/mimicable_quirk in mimicable_quirks_list)
			if(target_quirk.name == mimicable_quirk)
				user.remove_quirk(target_quirk.type)
				break

	for(var/datum/quirk/target_quirk in chosen_profile.quirks)
		for(var/mimicable_quirk in mimicable_quirks_list)
			if(target_quirk.name == mimicable_quirk)
				user.add_quirk(target_quirk.type)
				break
	// NOVA EDIT ADDITION END

	chosen_dna.copy_dna(user.dna, COPY_DNA_SE|COPY_DNA_SPECIES)

	for(var/obj/item/bodypart/limb as anything in user.bodyparts)
		limb.update_limb(is_creating = TRUE)

	user.updateappearance(mutcolor_update = TRUE, eyeorgancolor_update = TRUE) // NOVA EDIT CHANGE - ORIGINAL: user.updateappearance(mutcolor_update = TRUE)
	user.domutcheck()

	// Get rid of any scars from previous Changeling-ing
	for(var/datum/scar/old_scar as anything in user.all_scars)
		if(old_scar.fake)
			user.all_scars -= old_scar
			qdel(old_scar)

	// Now, we do skillchip stuff, AFTER DNA code.
	// (There's a mutation that increases max chip complexity available, even though we force-implant skillchips.)

	// Remove existing skillchips.
	user.destroy_all_skillchips(silent = FALSE)

	// Add new set of skillchips.
	for(var/chip in chosen_profile.skillchips)
		var/chip_type = chip["type"]
		var/obj/item/skillchip/skillchip = new chip_type(user)

		if(!istype(skillchip))
			stack_trace("Failure to implant changeling from [chosen_profile] with skillchip [skillchip]. Tried to implant with non-skillchip type [chip_type]")
			qdel(skillchip)
			continue

		// Try force-implanting and activating. If it doesn't work, there's nothing much we can do. There may be some
		// incompatibility out of our hands
		var/implant_msg = user.implant_skillchip(skillchip, TRUE)
		if(implant_msg)
			// Hopefully recording the error message will help debug it.
			stack_trace("Failure to implant changeling from [chosen_profile] with skillchip [skillchip]. Error msg: [implant_msg]")
			qdel(skillchip)
			continue

		// Time to set the metadata. This includes trying to activate the chip.
		var/set_meta_msg = skillchip.set_metadata(chip)

		if(set_meta_msg)
			// Hopefully recording the error message will help debug it.
			stack_trace("Failure to activate changeling skillchip from [chosen_profile] with skillchip [skillchip] using [chip] metadata. Error msg: [set_meta_msg]")
			continue

	if(use_clothing_disguise)
		for(var/slot in slot2type)
			if(istype(user.vars[slot], slot2type[slot]))
				qdel(user.vars[slot])
	else
		//vars hackery. not pretty, but better than the alternative.
		for(var/slot in slot2type)
			if(istype(user.vars[slot], slot2type[slot]) && !(chosen_profile.exists_list[slot])) // Remove unnecessary flesh items
				qdel(user.vars[slot])
				continue

			if((user.vars[slot] && !istype(user.vars[slot], slot2type[slot])) || !(chosen_profile.exists_list[slot]))
				continue

			if(istype(user.vars[slot], slot2type[slot]) && slot == "wear_id") // Always remove old flesh IDs - so they get properly updated.
				qdel(user.vars[slot])

			var/obj/item/new_flesh_item
			var/equip = FALSE
			if(!user.vars[slot])
				var/slot_type = slot2type[slot]
				equip = TRUE
				new_flesh_item = new slot_type(user)

			else if(istype(user.vars[slot], slot2type[slot]))
				new_flesh_item = user.vars[slot]

			new_flesh_item.appearance = chosen_profile.appearance_list[slot]
			new_flesh_item.name = chosen_profile.name_list[slot]
			new_flesh_item.flags_cover = chosen_profile.flags_cover_list[slot]
			new_flesh_item.lefthand_file = chosen_profile.lefthand_file_list[slot]
			new_flesh_item.righthand_file = chosen_profile.righthand_file_list[slot]
			new_flesh_item.inhand_icon_state = chosen_profile.inhand_icon_state_list[slot]
			new_flesh_item.worn_icon = chosen_profile.worn_icon_list[slot]
			new_flesh_item.worn_icon_state = chosen_profile.worn_icon_state_list[slot]
			// NOVA EDIT ADDITION START
			new_flesh_item.worn_icon_digi = chosen_profile.worn_icon_digi_list[slot]
			new_flesh_item.worn_icon_monkey = chosen_profile.worn_icon_monkey_list[slot]
			new_flesh_item.worn_icon_teshari = chosen_profile.worn_icon_teshari_list[slot]
			new_flesh_item.worn_icon_vox = chosen_profile.worn_icon_vox_list[slot]
			new_flesh_item.supports_variations_flags = chosen_profile.supports_variations_flags_list[slot]
			// NOVA EDIT ADDITION END

			if(istype(new_flesh_item, /obj/item/changeling/id) && chosen_profile.id_icon)
				var/obj/item/changeling/id/flesh_id = new_flesh_item
				flesh_id.hud_icon = chosen_profile.id_icon

			if(equip)
				user.equip_to_slot_or_del(new_flesh_item, slot2slot[slot], indirect_action = TRUE)
				if(!QDELETED(new_flesh_item))
					ADD_TRAIT(new_flesh_item, TRAIT_NODROP, CHANGELING_TRAIT)

	for(var/stored_scar_line in chosen_profile.stored_scars)
		var/datum/scar/attempted_fake_scar = user.load_scar(stored_scar_line)
		if(attempted_fake_scar)
			attempted_fake_scar.fake = TRUE

	user.regenerate_icons()
	user.name = user.get_visible_name()
	current_profile = chosen_profile
	// NOVA EDIT START
	user.updateappearance(mutcolor_update = TRUE, eyeorgancolor_update = TRUE)
	user.regenerate_icons()
	user.name = user.get_visible_name()
	// NOVA EDIT END
	//THE FLUFFY FRONTIER EDIT ADDITION BEGIN - Blooper
	user.blooper = null
	user.blooper_id = chosen_profile.blooper_id
	user.blooper_pitch = chosen_profile.blooper_pitch
	user.blooper_speed = chosen_profile.blooper_speed
	user.blooper_pitch_range = chosen_profile.blooper_pitch_range
	//THE FLUFFY FRONTIER EDIT END

	if(use_clothing_disguise)
		apply_clothing_disguise(user, chosen_profile.profile_snapshot)

// Changeling profile themselves. Store a data to store what every DNA instance looked like.
/datum/changeling_profile
	/// The name of the profile / the name of whoever this profile source.
	var/name = "a bug"
	/// Whether this profile is protected - if TRUE, it cannot be removed from a changeling's profiles without force
	var/protected = FALSE
	/// The DNA datum associated with our profile from the profile source
	var/datum/dna/dna
	/// Assoc list of item slot to item name - stores the name of every item of this profile.
	var/list/name_list = list()
	/// Assoc list of item slot to apperance - stores the appearance of every item of this profile.
	var/list/appearance_list = list()
	/// Assoc list of item slot to flag - stores the flags_cover of every item of this profile.
	var/list/flags_cover_list = list()
	/// Assoc list of item slot to boolean - stores whether an item in that slot exists
	var/list/exists_list = list()
	/// Assoc list of item slot to file - stores the lefthand file of the item in that slot
	var/list/lefthand_file_list = list()
	/// Assoc list of item slot to file - stores the righthand file of the item in that slot
	var/list/righthand_file_list = list()
	/// Assoc list of item slot to file - stores the inhand file of the item in that slot
	var/list/inhand_icon_state_list = list()
	/// Assoc list of item slot to file - stores the worn icon file of the item in that slot
	var/list/worn_icon_list = list()
	/// Assoc list of item slot to string - stores the worn icon state of the item in that slot
	var/list/worn_icon_state_list = list()
	/// The underwear worn by the profile source
	var/underwear
	/// The colour of the underwear worn by the profile source
	var/underwear_color
	/// The undershirt worn by the profile source
	var/undershirt
	/// The socks worn by the profile source
	var/socks
	/// A list of paths for any skill chips the profile source had installed
	var/list/skillchips = list()
	/// What scars the profile sorce had, in string form (like persistent scars)
	var/list/stored_scars
	/// Icon snapshot of the profile
	var/datum/icon_snapshot/profile_snapshot
	/// ID HUD icon associated with the profile
	var/id_icon
	/// The age of the profile source.
	var/age
	/// The body type of the profile source.
	var/physique
	/// The athleticism of the profile source.
	var/athletics_level
	/// The quirks of the profile source.
	var/list/quirks = list()
	/// The TTS voice of the profile source
	var/voice
	/// The TTS filter of the profile filter
	var/voice_filter = ""

/datum/changeling_profile/Destroy()
	qdel(dna)
	LAZYCLEARLIST(stored_scars)
	QDEL_LAZYLIST(quirks)
	return ..()

/*
 * Copy every aspect of this file into a new instance of a profile.
 * Must be suppied with an instance.
 */
/datum/changeling_profile/proc/copy_profile(datum/changeling_profile/new_profile)
	new_profile.name = name
	new_profile.protected = protected
	new_profile.dna = new dna.type()
	dna.copy_dna(new_profile.dna)
	new_profile.name_list = name_list.Copy()
	new_profile.appearance_list = appearance_list.Copy()
	new_profile.flags_cover_list = flags_cover_list.Copy()
	new_profile.exists_list = exists_list.Copy()
	new_profile.lefthand_file_list = lefthand_file_list.Copy()
	new_profile.righthand_file_list = righthand_file_list.Copy()
	new_profile.inhand_icon_state_list = inhand_icon_state_list.Copy()
	new_profile.underwear = underwear
	new_profile.underwear_color = underwear_color
	new_profile.undershirt = undershirt
	new_profile.socks = socks
	new_profile.worn_icon_list = worn_icon_list.Copy()
	new_profile.worn_icon_state_list = worn_icon_state_list.Copy()
	new_profile.skillchips = skillchips.Copy()
	new_profile.stored_scars = stored_scars.Copy()
	new_profile.profile_snapshot = profile_snapshot
	new_profile.id_icon = id_icon
	new_profile.age = age
	new_profile.physique = physique
	new_profile.athletics_level = athletics_level
	new_profile.quirks = quirks.Copy()
	new_profile.voice = voice
	new_profile.voice_filter = voice_filter
	// NOVA EDIT ADDITION START
	new_profile.undershirt_color = undershirt_color
	new_profile.socks_color = socks_color
	new_profile.bra = bra
	new_profile.bra_color = bra_color
	new_profile.emissive_eyes = emissive_eyes

	new_profile.worn_icon_digi_list = worn_icon_digi_list.Copy()
	new_profile.worn_icon_monkey_list = worn_icon_monkey_list.Copy()
	new_profile.worn_icon_teshari_list = worn_icon_teshari_list.Copy()
	new_profile.worn_icon_vox_list = worn_icon_vox_list.Copy()
	new_profile.supports_variations_flags_list = supports_variations_flags_list.Copy()
	new_profile.scream_type = scream_type
	new_profile.laugh_type = laugh_type
	// NOVA EDIT ADDITION END

/datum/antagonist/changeling/roundend_report()
	var/list/parts = list()

	// NOVA EDIT REMOVAL START
	/*
	var/changeling_win = TRUE
	if(!owner.current)
	changeling_win = FALSE
	 */
	// NOVA EDIT REMOVAL END

	parts += printplayer(owner)
	parts += "<b>Genomes Extracted:</b> [absorbed_count]<br>"

	if(objectives.len)
		var/count = 1
		for(var/datum/objective/objective in objectives)
			// NOVA EDIT START - No greentext
			/*
			if(!objective.check_completion())
			changeling_win = FALSE
			parts += "<b>Objective #[count]</b>: [objective.explanation_text] [objective.get_roundend_success_suffix()]"
			 */
			parts += "<b>Objective #[count]</b>: [objective.explanation_text]"
			// NOVA EDIT END - No greentext
			count++

	// NOVA EDIT REMOVAL START - No greentext
	/*
	if(changeling_win)
	parts += span_greentext("The changeling was successful!")
	else
	parts += span_redtext("The changeling has failed.")
	 */
	// NOVA EDIT REMOVAL END - No greentext

	return parts.Join("<br>")

/datum/antagonist/changeling/get_preview_icon()
	var/icon/final_icon = render_preview_outfit(/datum/outfit/changeling)
	var/icon/split_icon = render_preview_outfit(/datum/outfit/job/engineer)

	final_icon.Shift(WEST, ICON_SIZE_X / 2)
	final_icon.Shift(EAST, ICON_SIZE_X / 2)

	split_icon.Shift(EAST, ICON_SIZE_X / 2)
	split_icon.Shift(WEST, ICON_SIZE_X / 2)

	final_icon.Blend(split_icon, ICON_OVERLAY)

	return finish_preview_icon(final_icon)

/datum/antagonist/changeling/ui_data(mob/user)
	var/list/data = list()
	var/list/memories = list()

	for(var/memory_key in stolen_memories)
		memories += list(list("name" = memory_key, "story" = stolen_memories[memory_key]))

	data["memories"] = memories
	data["true_name"] = changelingID
	data["hive_name"] = hive_name
	data["stolen_antag_info"] = antag_memory
	data["objectives"] = get_objectives()
	return data

// Changelings spawned from non-changeling headslugs (IE, due to being transformed into a headslug as a non-ling). Weaker than a normal changeling.
/datum/antagonist/changeling/headslug
	name = "\improper Headslug Changeling"
	show_in_antagpanel = FALSE
	give_objectives = FALSE
	antag_flags = ANTAG_SKIP_GLOBAL_LIST

	genetic_points = 5
	total_genetic_points = 5
	chem_charges = 10
	total_chem_storage = 50

/datum/antagonist/changeling/headslug/greet()
	play_stinger()
	to_chat(owner, span_bolddanger("You are a fresh changeling birthed from a headslug! \
		You aren't as strong as a normal changeling, as you are newly born."))


/datum/antagonist/changeling/space
	name = "\improper Space Changeling"

/datum/antagonist/changeling/space/get_preview_icon()
	var/icon/final_icon = render_preview_outfit(/datum/outfit/changeling_space)
	return finish_preview_icon(final_icon)

/datum/antagonist/changeling/space/greet()
	play_stinger()
	to_chat(src, span_changeling("Our mind stirs to life, from the depths of an endless slumber..."))

/datum/outfit/changeling
	name = "Changeling"

	head = /obj/item/clothing/head/helmet/changeling
	suit = /obj/item/clothing/suit/armor/changeling
	l_hand = /obj/item/melee/arm_blade

/datum/outfit/changeling_space
	name = "Changeling (Space)"
	l_hand = /obj/item/melee/arm_blade

#undef FORMAT_CHEM_CHARGES_TEXT

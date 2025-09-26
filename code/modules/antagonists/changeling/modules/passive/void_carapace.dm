/datum/changeling_genetic_matrix_recipe/void_carapace
	id = "matrix_void_carapace"
	name = "Void Carapace"
	description = "Crystallize void-borne armor from Teshari void instincts, goliath stone plates, and watcher frost cores across our frame without permanent penalties."
	module = list(
		"id" = "matrix_void_carapace",
		"name" = "Void Carapace",
		"desc" = "Improves Void Adaption by shortening its chem slowdown, expanding hazard senses, and granting broader immunity.",
		"category" = GENETIC_MATRIX_CATEGORY_PASSIVE,
		"slotType" = BIO_INCUBATOR_SLOT_FLEX,
		"moduleType" = /datum/changeling_genetic_module/passive/void_carapace,
		"tags" = list("environment", "defense"),
		"exclusiveTags" = list("adaptation"),
		"button_icon_state" = null,
	)
	required_cells = list(
		CHANGELING_CELL_ID_TESHARI,
		CHANGELING_CELL_ID_GOLIATH,
		CHANGELING_CELL_ID_WATCHER,
	)
	required_abilities = list(
		/datum/action/changeling/void_adaption,
	)

/datum/changeling_genetic_module/passive/void_carapace
	id = "matrix_void_carapace"
	passive_effects = list()

/datum/changeling_genetic_module/passive/void_carapace/on_activate()
	. = ..()
	sync_state()
	return .

/datum/changeling_genetic_module/passive/void_carapace/on_deactivate()
	sync_state()
	return ..()

/datum/changeling_genetic_module/passive/void_carapace/on_owner_changed(mob/living/old_holder, mob/living/new_holder)
	. = ..()
	sync_state()

/datum/changeling_genetic_module/passive/void_carapace/proc/sync_state()
	var/datum/antagonist/changeling/changeling_owner = owner
	if(!changeling_owner)
		return
	var/datum/action/changeling/void_adaption/adaption = changeling_owner.get_changeling_power_instance(/datum/action/changeling/void_adaption)
	adaption?.sync_module_state(changeling_owner)

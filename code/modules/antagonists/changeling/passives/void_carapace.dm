/// Passive: Void Carapace — condenses teshari void instincts, goliath stone plates, and watcher frost cores into armor that surges during hazard exposure.
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

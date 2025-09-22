/// Passive: Barbed Larynx — reshapes our voicebox into resonant spines that amplify sonic assaults.
/datum/changeling_genetic_matrix_recipe/barbed_larynx
	id = "matrix_barbed_larynx"
	name = "Barbed Larynx"
	description = "Thread needle-like ossifications through our voicebox to channel brutal harmonics."
	module = list(
		"id" = "matrix_barbed_larynx",
		"name" = "Barbed Larynx",
		"desc" = "Bolsters our sonic shrieks with broader reach and lingering vertigo.",
		"category" = GENETIC_MATRIX_CATEGORY_PASSIVE,
		"slotType" = BIO_INCUBATOR_SLOT_FLEX,
		"tags" = list("sonic", "crowd_control"),
		"exclusiveTags" = list("shriek_range"),
		"button_icon_state" = "resonant_shriek",
		"effects" = list(
			"resonant_shriek_range_add" = 1,
			"resonant_shriek_confusion_mult" = 1.05,
		),
	)
	required_cells = list(
		CHANGELING_CELL_ID_FELINID,
		CHANGELING_CELL_ID_SHADEKIN,
	)
	required_abilities = list(
		/datum/action/changeling/resonant_shriek,
	)

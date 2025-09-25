/// Passive: Abyssal Slip — braids teshari sprint tendons, fox pads, and mothroach clingers for silent, shadow-hugging movement.
/datum/changeling_genetic_module/passive/abyssal_slip
	passive_effects = list(
		"move_speed_slowdown" = -0.05,
	)

/datum/changeling_genetic_matrix_recipe/abyssal_slip
	id = "matrix_abyssal_slip"
	name = "Abyssal Slip"
	description = "Fuse Teshari sprint tendons with fox pads and mothroach clingers to melt into station shadows and walls."
	module = list(
		"id" = "matrix_abyssal_slip",
		"name" = "Abyssal Slip",
		"desc" = "Grants silent footsteps, smoother transitions with Darkness Adaptation, and a slight speed edge while skulking.",
		"category" = GENETIC_MATRIX_CATEGORY_PASSIVE,
		"slotType" = BIO_INCUBATOR_SLOT_FLEX,
		"moduleType" = /datum/changeling_genetic_module/passive/abyssal_slip,
		"tags" = list("stealth", "mobility"),
		"effects" = list(
			"move_speed_slowdown" = -0.05,
		),
	)
	required_cells = list(
		CHANGELING_CELL_ID_TESHARI,
		CHANGELING_CELL_ID_FOX,
		CHANGELING_CELL_ID_MOTHROACH,
	)
	required_abilities = list(
		/datum/action/changeling/darkness_adaptation,
	)

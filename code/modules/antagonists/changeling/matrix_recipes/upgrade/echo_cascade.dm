
/// Matrix Upgrade: Echo Cascade — layers teshari overtones, parrot mimic chords, and butterfly wing chimes for delayed sonic aftershocks and EMP rebounds.
/datum/changeling_genetic_matrix_recipe/echo_cascade
	id = "matrix_echo_cascade"
	name = "Echo Cascade"
	description = "Stack Teshari overtones, parrot mimic chords, and butterfly wing chimes into our shriek for delayed echoes and EMP rebounds."
	module = list(
			"id" = "matrix_echo_cascade",
			"name" = "Echo Cascade",
			"desc" = "Resonant and dissonant shrieks spawn delayed pulses that disorient prey and spark mini-EMPs.",
			"category" = GENETIC_MATRIX_CATEGORY_UPGRADE,
			"slotType" = BIO_INCUBATOR_SLOT_FLEX,
			"tags" = list("sonic", "crowd_control"),
			"button_icon_state" = "resonant_shriek",
	)
	required_cells = list(
		CHANGELING_CELL_ID_TESHARI,
		CHANGELING_CELL_ID_PARROT,
		CHANGELING_CELL_ID_BUTTERFLY,
	)
	required_abilities = list(
			/datum/action/changeling/resonant_shriek,
	)

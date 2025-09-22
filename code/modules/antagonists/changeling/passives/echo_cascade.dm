
/// Upgrade: Echo Cascade — layers resonant harmonics for delayed sonic aftershocks and EMP rebounds.
/datum/changeling_genetic_matrix_recipe/echo_cascade
	id = "matrix_echo_cascade"
	name = "Echo Cascade"
	description = "Anchor ethereal resonators into our shrieks so echoes ripple after the initial blast."
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
			CHANGELING_CELL_ID_ETHEREAL,
			CHANGELING_CELL_ID_REVENANT,
	)
	required_abilities = list(
			/datum/action/changeling/resonant_shriek,
	)

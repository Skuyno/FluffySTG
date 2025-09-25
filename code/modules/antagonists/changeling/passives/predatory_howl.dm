/// Passive: Predatory Howl — refines the dissonant shriek with vulpkanin hunting howls, nightmare shadow lungs, and corgi pack calls into an execution note that ruptures skulls and machinery alike.
/datum/changeling_genetic_matrix_recipe/predatory_howl
	id = "matrix_predatory_howl"
	name = "Predatory Howl"
	description = "Refocuses our dissonant shriek with vulpkanin hunting howls, nightmare shadow lungs, and corgi pack calls into a devastating execution note."
	module = list(
		"id" = "matrix_predatory_howl",
		"name" = "Predatory Howl",
		"desc" = "Upgrades Dissonant Shriek with a razor-focused killing tone and heightened structure damage.",
		"helptext" = "Stacks with resonant shriek bonuses; incompatible with other key actives.",
		"category" = GENETIC_MATRIX_CATEGORY_KEY,
		"slotType" = BIO_INCUBATOR_SLOT_KEY,
		"tags" = list("sonic", "offense"),
		"exclusiveTags" = list("key_active"),
		"button_icon_state" = "dissonant_shriek",
	)
	required_cells = list(
		CHANGELING_CELL_ID_VULPKANIN,
		CHANGELING_CELL_ID_NIGHTMARE,
		CHANGELING_CELL_ID_CORGI,
	)
	required_abilities = list(
		/datum/action/changeling/dissonant_shriek,
	)

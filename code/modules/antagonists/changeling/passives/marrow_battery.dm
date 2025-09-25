/// Passive: Marrow Battery — cultivates hemophage marrow, cow endurance blood, and sheep insulating plasma that refuels our chemical reserves on its own.
/datum/changeling_genetic_matrix_recipe/marrow_battery
	id = "matrix_marrow_battery"
	name = "Marrow Battery"
	description = "Spool hemophage marrow, cow endurance blood, and sheep insulating plasma into a living capacitor that drips power back into our glands."
	module = list(
		"id" = "matrix_marrow_battery",
		"name" = "Marrow Battery",
		"desc" = "Accelerates baseline chemical regeneration while gently easing stamina recovery downtime.",
		"category" = GENETIC_MATRIX_CATEGORY_PASSIVE,
		"slotType" = BIO_INCUBATOR_SLOT_FLEX,
		"tags" = list("chemicals", "sustain"),
		"exclusiveTags" = list("chem_pool"),
		"button_icon_state" = null,
		"effects" = list(
			"chem_recharge_rate_add" = 1.2,
			"stamina_regen_time_mult" = 0.9,
		),
	)
	required_cells = list(
		CHANGELING_CELL_ID_HEMOPHAGE,
		CHANGELING_CELL_ID_COW,
		CHANGELING_CELL_ID_SHEEP,
	)

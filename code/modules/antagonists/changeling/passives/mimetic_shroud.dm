/// Upgrade: Mimetic Shroud — floods chameleon skin with alien chromatophores for deeper, longer invisibility bursts.
/datum/changeling_genetic_matrix_recipe/mimetic_shroud
	id = "matrix_mimetic_shroud"
	name = "Mimetic Shroud"
	description = "Infuse our chameleon skin with resonant skin nodules for uncanny fades."
	module = list(
		"id" = "matrix_mimetic_shroud",
		"name" = "Mimetic Shroud",
		"desc" = "Extends Feathered Veil bursts, reduces their cooldown, and deepens the invisibility dip.",
		"category" = GENETIC_MATRIX_CATEGORY_UPGRADE,
		"slotType" = BIO_INCUBATOR_SLOT_FLEX,
		"tags" = list("stealth", "mobility"),
		"exclusiveTags" = list("camo_upgrade"),
		"button_icon_state" = "digital_camo",
		"effects" = list(
			"feathered_veil_burst_duration_add" = 0.5 SECONDS,
			"feathered_veil_cooldown_mult" = 0.75,
			"feathered_veil_alpha_add" = -20,
		),
	)
	required_cells = list(
		CHANGELING_CELL_ID_MOTH,
		CHANGELING_CELL_ID_SKRELL,
	)
	required_abilities = list(
		/datum/action/changeling/chameleon_skin,
	)

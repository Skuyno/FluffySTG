
/// Key Active: Chorus Stasis — weaves a two-body cocoon that heals, conceals, and can erupt into soporific gas.
/datum/changeling_genetic_matrix_recipe/chorus_stasis
	id = "matrix_chorus_stasis"
	name = "Chorus Stasis"
	description = "Spin a cooperative cocoon to hide allies or prey before detonating them in chemical fog."
	module = list(
			"id" = "matrix_chorus_stasis",
			"name" = "Chorus Stasis",
			"desc" = "Encase up to two bodies in a stasis cocoon that heals quietly and can burst into disorienting gas.",
			"helptext" = "Activate to create or add to a cocoon; reuse while a cocoon exists to detonate it.",
			"category" = GENETIC_MATRIX_CATEGORY_KEY,
			"slotType" = BIO_INCUBATOR_SLOT_KEY,
			"tags" = list("healing", "control"),
			"exclusiveTags" = list("key_active"),
	)
	required_cells = list(
			CHANGELING_CELL_ID_SPACE_DRAGON,
			CHANGELING_CELL_ID_SLIMEPERSON,
	)

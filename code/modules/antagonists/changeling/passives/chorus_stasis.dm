
/// Key Active: Chorus Stasis — weaves a single-body cocoon that heals, conceals, and can erupt into soporific gas.
/datum/changeling_genetic_matrix_recipe/chorus_stasis
	id = "matrix_chorus_stasis"
	name = "Chorus Stasis"
        description = "Spin a solitary cocoon to hide yourself or one victim before detonating it in chemical fog."
	module = list(
			"id" = "matrix_chorus_stasis",
			"name" = "Chorus Stasis",
                        "desc" = "Encase one body in a stasis cocoon that quietly heals and can burst into disorienting gas.",
                        "helptext" = "Activate to cocoon yourself or an adjacent creature; reuse while it exists to detonate it.",
			"category" = GENETIC_MATRIX_CATEGORY_KEY,
			"slotType" = BIO_INCUBATOR_SLOT_KEY,
			"tags" = list("healing", "control"),
			"exclusiveTags" = list("key_active"),
	)
	required_cells = list(
			CHANGELING_CELL_ID_SPACE_DRAGON,
			CHANGELING_CELL_ID_SLIMEPERSON,
	)

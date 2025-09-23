
/// Key Active: Chorus Stasis — weaves a single-body cocoon that soothes and restores whoever rests within.
/datum/changeling_genetic_matrix_recipe/chorus_stasis
	id = "matrix_chorus_stasis"
	name = "Chorus Stasis"
	description = "Spin a solitary cocoon to shelter yourself or a victim, steadily mending their wounds."
	module = list(
			"id" = "matrix_chorus_stasis",
			"name" = "Chorus Stasis",
			"desc" = "Encase one body in a stasis cocoon that patiently heals flesh with layered heartbeats.",
			"helptext" = "Activate to raise a cocoon at your feet. Target an adjacent creature to wrap them immediately; otherwise we slip inside ourselves. Only one cocoon may exist at a time and whoever rests inside quickly mends.",
			"category" = GENETIC_MATRIX_CATEGORY_KEY,
			"slotType" = BIO_INCUBATOR_SLOT_KEY,
			"tags" = list("healing", "control"),
			"exclusiveTags" = list("key_active"),
	)
	required_cells = list(
			CHANGELING_CELL_ID_SPACE_DRAGON,
			CHANGELING_CELL_ID_SLIMEPERSON,
	)

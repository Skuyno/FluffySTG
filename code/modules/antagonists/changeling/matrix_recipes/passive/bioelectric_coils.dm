/// Matrix Passive: Bioelectric Coils — weaves slimeperson conduits, cockroach capacitors, and space carp charge sinks to supercharge every stride while shrugging off fatigue.
/datum/changeling_genetic_matrix_recipe/bioelectric_coils
	id = "matrix_bioelectric_coils"
	name = "Bioelectric Coils"
	description = "Thread slimeperson conduits, cockroach capacitors, and space carp charge sinks through our musculature for brutal sustained speed."
	module = list(
		"id" = "matrix_bioelectric_coils",
		"name" = "Bioelectric Coils",
		"desc" = "Floods our frame with keyed bioelectric surges, greatly boosting pace and stamina efficiency.",
		"helptext" = "Too potent for flex slots; occupies a key conduit.",
		"category" = GENETIC_MATRIX_CATEGORY_PASSIVE,
		"slotType" = BIO_INCUBATOR_SLOT_KEY,
		"tags" = list("mobility", "stamina"),
		"exclusiveTags" = list("key_speed"),
		"button_icon_state" = null,
		"effects" = list(
			"move_speed_slowdown" = -0.04,
			"stamina_use_mult" = 0.8,
			"stamina_regen_time_mult" = 0.7,
		),
	)
	required_cells = list(
		CHANGELING_CELL_ID_SLIMEPERSON,
		CHANGELING_CELL_ID_COCKROACH,
		CHANGELING_CELL_ID_SPACE_CARP,
	)

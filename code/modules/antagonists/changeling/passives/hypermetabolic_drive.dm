/// Passive: Hypermetabolic Drive — splices teshari twitch muscle, rabbit sprint tendons, and space carp charge fins for relentless pace.
/datum/changeling_genetic_matrix_recipe/hypermetabolic_drive
	id = "matrix_hypermetabolic_drive"
	name = "Hypermetabolic Drive"
	description = "Channel Teshari sprint enzymes, rabbit sprint tendons, and space carp charge fins into our baseline gait."
	module = list(
		"id" = "matrix_hypermetabolic_drive",
		"name" = "Hypermetabolic Drive",
		"desc" = "Increases our default stride and hastens stamina rebound between bursts of speed.",
		"category" = GENETIC_MATRIX_CATEGORY_PASSIVE,
		"slotType" = BIO_INCUBATOR_SLOT_FLEX,
		"tags" = list("mobility", "stamina"),
		"exclusiveTags" = list("speed_boost"),
		"button_icon_state" = null,
		"effects" = list(
			"move_speed_slowdown" = -0.03,
			"stamina_regen_time_mult" = 0.8,
		),
	)
	required_cells = list(
		CHANGELING_CELL_ID_TESHARI,
		CHANGELING_CELL_ID_RABBIT,
		CHANGELING_CELL_ID_SPACE_CARP,
	)

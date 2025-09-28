/// Matrix Passive: Anaerobic Reservoir — layers human training lungs, goat stamina hearts, and pig blood caches to thicken our stamina pool.
/datum/changeling_genetic_matrix_recipe/anaerobic_reservoir
	id = "matrix_anaerobic_reservoir"
	name = "Anaerobic Reservoir"
	description = "Forge redundant oxygen sacs from human training lungs, goat stamina hearts, and pig blood caches to blunt fatigue and vent a burst of strength when exhaustion peaks."
	module = list(
		"id" = "matrix_anaerobic_reservoir",
		"name" = "Anaerobic Reservoir",
		"desc" = "Adds a reserve of stamina and trims everyday expenditure, then erupts near collapse to refill us and cushion the next impact.",
		"category" = GENETIC_MATRIX_CATEGORY_PASSIVE,
		"slotType" = BIO_INCUBATOR_SLOT_FLEX,
		"tags" = list("stamina", "resilience"),
		"exclusiveTags" = list("stamina_reservoir"),
		"button_icon_state" = null,
		"effects" = list(
			"max_stamina_add" = 60,
			"stamina_use_mult" = 0.8,
		),
	)
	required_cells = list(
		CHANGELING_CELL_ID_HUMAN,
		CHANGELING_CELL_ID_GOAT,
		CHANGELING_CELL_ID_PIG,
	)

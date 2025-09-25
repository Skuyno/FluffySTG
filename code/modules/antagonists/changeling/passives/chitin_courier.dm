
/// Passive: Chitin Courier — folds slimeperson cytogel, mothroach clingers, and cargo crab plating into a hidden subdermal cargo pocket.
/datum/changeling_genetic_module/passive/chitin_courier
	passive_effects = list()

/datum/changeling_genetic_matrix_recipe/chitin_courier
	id = "matrix_chitin_courier"
	name = "Chitin Courier"
	description = "Weld slimeperson cytogel, mothroach clingers, and cargo crab plating into a hidden subdermal cargo pocket."
	module = list(
			"id" = "matrix_chitin_courier",
			"name" = "Chitin Courier",
		"desc" = "Adds a quick-action subdermal stash for a medium item, perfect for contraband swaps.",
			"category" = GENETIC_MATRIX_CATEGORY_PASSIVE,
			"slotType" = BIO_INCUBATOR_SLOT_FLEX,
		"moduleType" = /datum/changeling_genetic_module/passive/chitin_courier,
			"tags" = list("utility", "stealth"),
	)
	required_cells = list(
		CHANGELING_CELL_ID_SLIMEPERSON,
		CHANGELING_CELL_ID_MOTHROACH,
		CHANGELING_CELL_ID_CRAB,
	)

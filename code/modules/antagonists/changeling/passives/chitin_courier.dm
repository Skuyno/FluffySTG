
/// Passive: Chitin Courier — folds insectoid carapace into a hidden subdermal cargo pocket.
/datum/changeling_genetic_matrix_recipe/chitin_courier
	id = "matrix_chitin_courier"
	name = "Chitin Courier"
	description = "Carve a concealed cache beneath our skin to smuggle tools without outward traces."
	module = list(
			"id" = "matrix_chitin_courier",
			"name" = "Chitin Courier",
                "desc" = "Adds a quick-action subdermal stash for a medium item, perfect for contraband swaps.",
			"category" = GENETIC_MATRIX_CATEGORY_PASSIVE,
			"slotType" = BIO_INCUBATOR_SLOT_FLEX,
			"tags" = list("utility", "stealth"),
	)
	required_cells = list(
			CHANGELING_CELL_ID_INSECT,
			CHANGELING_CELL_ID_NABBER,
	)


/// Passive: Memory Archivist — distills revenant echoes into sharable absorption dossiers.
/datum/changeling_genetic_matrix_recipe/memory_archivist
	id = "matrix_memory_archivist"
	name = "Memory Archivist"
	description = "Crystallize absorbed identities into hand-off packets for hive allies."
	module = list(
			"id" = "matrix_memory_archivist",
			"name" = "Memory Archivist",
			"desc" = "Absorptions capture a reusable dossier that can be shared with a target for impersonation prep.",
			"category" = GENETIC_MATRIX_CATEGORY_PASSIVE,
			"slotType" = BIO_INCUBATOR_SLOT_FLEX,
			"tags" = list("intelligence", "teamwork"),
	)
	required_cells = list(
			CHANGELING_CELL_ID_HEMOPHAGE,
			CHANGELING_CELL_ID_REVENANT,
	)

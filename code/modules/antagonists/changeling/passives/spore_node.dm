
/// Key Active: Spore Node — plants a pheromone sensor node that can be detonated into restraining spores.
/datum/changeling_genetic_matrix_recipe/spore_node
	id = "matrix_spore_node"
	name = "Spore Node"
	description = "Grow a stationary bio-beacon that scouts and can burst into slowing spores on command."
	module = list(
			"id" = "matrix_spore_node",
			"name" = "Spore Node",
			"desc" = "Deploy a remote pheromone node: it warns of trespassers, can be reclaimed, or detonated remotely.",
			"helptext" = "Only one node may exist at a time. Re-activating the ability detonates the current node.",
			"category" = GENETIC_MATRIX_CATEGORY_KEY,
			"slotType" = BIO_INCUBATOR_SLOT_KEY,
			"tags" = list("utility", "control"),
			"exclusiveTags" = list("key_active"),
	)
	required_cells = list(
			CHANGELING_CELL_ID_PODWEAK,
			CHANGELING_CELL_ID_BEE,
	)

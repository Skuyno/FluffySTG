
/// Passive: Aether Drake Mantle — grafts draconic void plating for effortless EVA pushes and hardened resistances.
/datum/changeling_genetic_matrix_recipe/aether_drake_mantle
	id = "matrix_aether_drake_mantle"
	name = "Aether Drake Mantle"
	description = "Infuse our void adaptations with draconic plating to roam the stars without effort."
	module = list(
			"id" = "matrix_aether_drake_mantle",
			"name" = "Aether Drake Mantle",
			"desc" = "Remixes Void Adaption with manual EVA bursts, space mobility traits, and reinforced resistances.",
			"category" = GENETIC_MATRIX_CATEGORY_PASSIVE,
			"slotType" = BIO_INCUBATOR_SLOT_FLEX,
			"tags" = list("mobility", "environment"),
			"exclusiveTags" = list("adaptation"),
	)
	required_cells = list(
			CHANGELING_CELL_ID_SPACE_DRAGON,
			CHANGELING_CELL_ID_ASH_DRAKE,
	)
	required_abilities = list(
			/datum/action/changeling/void_adaption,
	)

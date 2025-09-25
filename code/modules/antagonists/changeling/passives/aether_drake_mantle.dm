
/// Passive: Aether Drake Mantle — weaves vulpkanin cold coats, space dragon plasma scales, and ash drake furnace plates into resilient void plating.
/datum/changeling_genetic_matrix_recipe/aether_drake_mantle
	id = "matrix_aether_drake_mantle"
	name = "Aether Drake Mantle"
	description = "Infuse our void adaptations with vulpkanin cold coats, space dragon plasma scales, and ash drake furnace plates to roam the stars without effort."
	module = list(
			"id" = "matrix_aether_drake_mantle",
			"name" = "Aether Drake Mantle",
			"desc" = "Remixes Void Adaption with manual EVA bursts, space mobility traits, and reinforced resistances.",
			"category" = GENETIC_MATRIX_CATEGORY_PASSIVE,
		"slotType" = BIO_INCUBATOR_SLOT_FLEX,
		"tags" = list("mobility", "environment"),
		"exclusiveTags" = list("adaptation"),
		"effects" = list(
			"incoming_brute_damage_mult" = 0.7,
			"incoming_burn_damage_mult" = 0.7,
		),
	)
	required_cells = list(
		CHANGELING_CELL_ID_VULPKANIN,
		CHANGELING_CELL_ID_SPACE_DRAGON,
		CHANGELING_CELL_ID_ASH_DRAKE,
	)
	required_abilities = list(
			/datum/action/changeling/void_adaption,
	)

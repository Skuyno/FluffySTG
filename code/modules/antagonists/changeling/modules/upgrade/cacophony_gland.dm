/datum/changeling_genetic_matrix_recipe/cacophony_gland
	id = "matrix_cacophony_gland"
	name = "Cacophony Gland"
	description = "Grow reverberant ducts from vulpkanin hunting howls, corgi pack bellows, and pug pressure veins to project punishing harmonics across the arena."
	module = list(
		"id" = "matrix_cacophony_gland",
		"name" = "Cacophony Gland",
		"desc" = "Widens the dissonant shriek's coverage and hardens its structure-rending cadence.",
		"helptext" = "Occupies a key slot due to the overwhelming pressure it exerts.",
		"category" = GENETIC_MATRIX_CATEGORY_UPGRADE,
		"slotType" = BIO_INCUBATOR_SLOT_KEY,
		"moduleType" = /datum/changeling_genetic_module/upgrade/cacophony_gland,
		"tags" = list("sonic", "siege"),
		"exclusiveTags" = list("shriek_upgrade"),
		"button_icon_state" = "dissonant_shriek",
		"effects" = list(
			"dissonant_shriek_emp_range_add" = 2,
			"dissonant_shriek_structure_mult" = 1.3,
		),
	)
	required_cells = list(
		CHANGELING_CELL_ID_VULPKANIN,
		CHANGELING_CELL_ID_CORGI,
		CHANGELING_CELL_ID_PUG,
	)
	required_abilities = list(
		/datum/action/changeling/dissonant_shriek,
	)

/datum/changeling_genetic_module/upgrade/cacophony_gland
	id = "matrix_cacophony_gland"
	passive_effects = list(
		"dissonant_shriek_emp_range_add" = 2,
		"dissonant_shriek_structure_mult" = 1.3,
	)

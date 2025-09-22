/// Upgrade: Cacophony Gland — reworks our lungs into a resonant array that weaponizes the dissonant shriek.
/datum/changeling_genetic_matrix_recipe/cacophony_gland
	id = "matrix_cacophony_gland"
	name = "Cacophony Gland"
	description = "Grow reverberant ducts that project punishing harmonics across the arena."
	module = list(
		"id" = "matrix_cacophony_gland",
		"name" = "Cacophony Gland",
		"desc" = "Widens the dissonant shriek's coverage and hardens its structure-rending cadence.",
		"helptext" = "Occupies a key slot due to the overwhelming pressure it exerts.",
		"category" = GENETIC_MATRIX_CATEGORY_UPGRADE,
		"slotType" = BIO_INCUBATOR_SLOT_KEY,
		"tags" = list("sonic", "siege"),
		"exclusiveTags" = list("shriek_upgrade"),
		"button_icon_state" = "dissonant_shriek",
		"effects" = list(
			"dissonant_shriek_emp_range_add" = 1,
			"dissonant_shriek_structure_mult" = 1.15,
		),
	)
	required_cells = list(
		CHANGELING_CELL_ID_VOX,
		CHANGELING_CELL_ID_GLOCKROACH,
	)
	required_abilities = list(
		/datum/action/changeling/dissonant_shriek,
	)

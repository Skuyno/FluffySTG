/// Upgrade: Predator's Sinew — fuses tajaran pounce fibers, space carp launch fins, and fox pack tendons to steady Strained Muscles with a reactive tackle.
/datum/changeling_genetic_module/upgrade/predator_sinew
	passive_effects = list()

/datum/changeling_genetic_matrix_recipe/predator_sinew
	id = "matrix_predator_sinew"
	name = "Predator's Sinew"
	description = "Splice Tajaran pounce fibers, space carp launch fins, and fox pack tendons to tame our Strained Muscles technique."
	module = list(
		"id" = "matrix_predator_sinew",
		"name" = "Predator's Sinew",
		"desc" = "Reduces stamina backlash from Strained Muscles and adds a short sprint on activation.",
		"category" = GENETIC_MATRIX_CATEGORY_UPGRADE,
		"slotType" = BIO_INCUBATOR_SLOT_FLEX,
		"moduleType" = /datum/changeling_genetic_module/upgrade/predator_sinew,
		"tags" = list("mobility", "strength"),
		"exclusiveTags" = list("mobility"),
		"button_icon_state" = "strained_muscles",
	)
	required_cells = list(
		CHANGELING_CELL_ID_TAJARAN,
		CHANGELING_CELL_ID_SPACE_CARP,
		CHANGELING_CELL_ID_FOX,
	)
	required_abilities = list(
		/datum/action/changeling/strained_muscles,
	)

/// Matrix Upgrade: Plasma Knit — saturates Fleshmend with tajaran scar-knitting, spider silk, and sheep clotting gel that lingers longer and knits faster.
/datum/changeling_genetic_matrix_recipe/plasma_knit
	id = "matrix_plasma_knit"
	name = "Plasma Knit"
	description = "Thread Tajaran scar-knitting, spider silk, and sheep clotting gel through our regeneration slurry for denser healing."
	module = list(
		"id" = "matrix_plasma_knit",
		"name" = "Plasma Knit",
		"desc" = "Extends Fleshmend's duration and amplifies each restorative pulse.",
		"category" = GENETIC_MATRIX_CATEGORY_UPGRADE,
		"slotType" = BIO_INCUBATOR_SLOT_FLEX,
		"tags" = list("healing", "support"),
		"exclusiveTags" = list("fleshmend_upgrade"),
		"button_icon_state" = "fleshmend",
		"effects" = list(
			"fleshmend_duration_add" = 6 SECONDS,
			"fleshmend_heal_mult" = 1.4,
		),
	)
	required_cells = list(
		CHANGELING_CELL_ID_TAJARAN,
		CHANGELING_CELL_ID_SPIDER,
		CHANGELING_CELL_ID_SHEEP,
	)
	required_abilities = list(
		/datum/action/changeling/fleshmend,
	)

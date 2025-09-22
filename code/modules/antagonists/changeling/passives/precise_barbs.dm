/// Upgrade: Precise Barbs — tempers our musculature with fine-tuned spicules for relentless pursuit.
/datum/changeling_genetic_matrix_recipe/precise_barbs
	id = "matrix_precise_barbs"
	name = "Precise Barbs"
	description = "Refine our internal barbs into micro-anchors that recycle stamina and chems."
	module = list(
		"id" = "matrix_precise_barbs",
		"name" = "Precise Barbs",
		"desc" = "Reduces exertion costs and bolsters chem flow for extended hunts.",
		"category" = GENETIC_MATRIX_CATEGORY_UPGRADE,
		"slotType" = BIO_INCUBATOR_SLOT_FLEX,
		"tags" = list("mobility", "sustain"),
		"exclusiveTags" = list("endurance_upgrade"),
		"button_icon_state" = "strained_muscles",
		"effects" = list(
                        "stamina_use_mult" = 0.8,
                        "chem_recharge_rate_add" = 0.4,
		),
	)
	required_cells = list(
		CHANGELING_CELL_ID_NABBER,
		CHANGELING_CELL_ID_VULPKANIN,
	)
	required_abilities = list(
		/datum/action/changeling/strained_muscles,
	)

/// Passive: Feathered Veil — braids avian camouflage into chameleon skin pulses for burst movement invisibility.
/datum/changeling_genetic_matrix_recipe/feathered_veil
	id = "matrix_feathered_veil"
	name = "Feathered Veil"
	description = "Blend avian camouflage with predatory cunning for near-perfect stillness."
	module = list(
		"id" = "matrix_feathered_veil",
		"name" = "Feathered Veil",
		"desc" = "Bolsters Chameleon Skin with brief bursts of total visual suppression while moving.",
                "category" = GENETIC_MATRIX_CATEGORY_PASSIVE,
                "slotType" = BIO_INCUBATOR_SLOT_FLEX,
                "tags" = list("stealth", "mobility"),
                "exclusiveTags" = list("stealth"),
                "button_icon_state" = "digital_camo",
                "effects" = list(
                        "feathered_veil_burst_duration_add" = 0.5 SECONDS,
                        "feathered_veil_cooldown_mult" = 0.8,
                        "feathered_veil_alpha_add" = -10,
                ),
	)
	required_cells = list(
		CHANGELING_CELL_ID_TESHARI,
		CHANGELING_CELL_ID_CHICKEN,
	)
	required_abilities = list(
		/datum/action/changeling/chameleon_skin,
	)

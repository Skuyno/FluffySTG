
/// Passive: Abyssal Slip — threads shadekin chromatophores for silent, shadow-hugging movement.
/datum/changeling_genetic_matrix_recipe/abyssal_slip
	id = "matrix_abyssal_slip"
	name = "Abyssal Slip"
	description = "Fuse Teshari sprint tendons with shadekin film to glide unheard along station shadows."
	module = list(
			"id" = "matrix_abyssal_slip",
			"name" = "Abyssal Slip",
			"desc" = "Grants silent footsteps, smoother chameleon transitions, and a slight speed edge while skulking.",
			"category" = GENETIC_MATRIX_CATEGORY_PASSIVE,
			"slotType" = BIO_INCUBATOR_SLOT_FLEX,
			"tags" = list("stealth", "mobility"),
			"effects" = list(
					"move_speed_slowdown" = -0.15,
			),
	)
	required_cells = list(
			CHANGELING_CELL_ID_TESHARI,
			CHANGELING_CELL_ID_SHADEKIN,
	)
	required_abilities = list(
			/datum/action/changeling/chameleon_skin,
	)

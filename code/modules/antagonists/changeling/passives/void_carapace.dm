/// Passive: Void Carapace — condenses void-touched armor that surges during hazard exposure.
/datum/changeling_genetic_matrix_recipe/void_carapace
        id = "matrix_void_carapace"
        name = "Void Carapace"
        description = "Crystallize void-borne armor across our frame without permanent penalties."
        module = list(
                "id" = "matrix_void_carapace",
                "name" = "Void Carapace",
                "desc" = "Improves Void Adaption by shortening its chem slowdown and granting brief hazard immunity bursts.",
                "category" = GENETIC_MATRIX_CATEGORY_PASSIVE,
                "slotType" = BIO_INCUBATOR_SLOT_FLEX,
                "tags" = list("environment", "defense"),
                "exclusiveTags" = list("adaptation"),
                "button_icon_state" = null,
        )
        required_cells = list(
                CHANGELING_CELL_ID_VOX,
                CHANGELING_CELL_ID_COLOSSUS,
        )
        required_abilities = list(
                /datum/action/changeling/void_adaption,
        )

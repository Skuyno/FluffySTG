/// Passive: Symbiotic Overgrowth — cultivates idle tissues that regenerate slowly and prime Regenerate for deeper healing bursts.
/datum/changeling_genetic_matrix_recipe/symbiotic_overgrowth
        id = "matrix_symbiotic_overgrowth"
        name = "Symbiotic Overgrowth"
        description = "Cultivates regenerative tissues that keep working even while dormant."
        module = list(
                "id" = "matrix_symbiotic_overgrowth",
                "name" = "Symbiotic Overgrowth",
                "desc" = "Grants a slow baseline regeneration and improves the potency of the Regenerate ability.",
                "category" = GENETIC_MATRIX_CATEGORY_PASSIVE,
                "slotType" = BIO_INCUBATOR_SLOT_FLEX,
                "tags" = list("healing", "sustain"),
                "exclusiveTags" = list("healing"),
                "button_icon_state" = "regenerate",
        )
        required_cells = list(
                CHANGELING_CELL_ID_HUMAN,
                CHANGELING_CELL_ID_GOAT,
        )
        required_abilities = list(
                /datum/action/changeling/regenerate,
        )

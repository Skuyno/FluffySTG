/// Passive: Predatory Howl — refines the technophagic shriek into an execution note that ruptures skulls and machinery alike.
/datum/changeling_genetic_matrix_recipe/predatory_howl
        id = "matrix_predatory_howl"
        name = "Predatory Howl"
        description = "Refocuses our technophagic shriek into a devastating execution note."
        module = list(
                "id" = "matrix_predatory_howl",
                "name" = "Predatory Howl",
                "desc" = "Upgrades Technophagic Shriek with a razor-focused killing tone and heightened structure damage.",
                "helptext" = "Stacks with resonant shriek bonuses; incompatible with other key actives.",
                "category" = GENETIC_MATRIX_CATEGORY_KEY,
                "slotType" = BIO_INCUBATOR_SLOT_KEY,
                "tags" = list("sonic", "offense"),
                "exclusiveTags" = list("key_active"),
                "button_icon_state" = "dissonant_shriek",
        )
        required_cells = list(
                CHANGELING_CELL_ID_VOX,
                CHANGELING_CELL_ID_TAJARAN,
        )
        required_abilities = list(
                /datum/action/changeling/dissonant_shriek,
        )

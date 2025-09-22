/// Passive: Anaerobic Reservoir — layers redundant oxygen stores that thicken our stamina pool for extended fights.
/datum/changeling_genetic_matrix_recipe/anaerobic_reservoir
        id = "matrix_anaerobic_reservoir"
        name = "Anaerobic Reservoir"
        description = "Forge redundant oxygen sacs to blunt fatigue and keep our muscles charged."
        module = list(
                "id" = "matrix_anaerobic_reservoir",
                "name" = "Anaerobic Reservoir",
                "desc" = "Adds a reserve of stamina and trims everyday expenditure, keeping us fresh in prolonged brawls.",
                "category" = GENETIC_MATRIX_CATEGORY_PASSIVE,
                "slotType" = BIO_INCUBATOR_SLOT_FLEX,
                "tags" = list("stamina", "resilience"),
                "exclusiveTags" = list("stamina_reservoir"),
                "button_icon_state" = null,
                "effects" = list(
                        "max_stamina_add" = 40,
                        "stamina_use_mult" = 0.9,
                ),
        )
        required_cells = list(
                CHANGELING_CELL_ID_DWARF,
                CHANGELING_CELL_ID_GOAT,
        )

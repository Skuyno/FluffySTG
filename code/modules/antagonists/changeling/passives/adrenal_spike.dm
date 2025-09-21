/// Upgrade: Adrenal Spike — bottles barnyard endurance into a reactive countershock for Gene Stim.
/datum/changeling_genetic_matrix_recipe/adrenal_spike
        id = "matrix_adrenal_spike"
        name = "Adrenal Spike"
        description = "Bottle barnyard endurance into a reusable combat stimulant."
        module = list(
                "id" = "matrix_adrenal_spike",
                "name" = "Adrenal Spike",
                "desc" = "Upgrades Gene Stim with bonus stamina recovery and a reactive countershock when stunned.",
                "category" = GENETIC_MATRIX_CATEGORY_UPGRADE,
                "slotType" = BIO_INCUBATOR_SLOT_FLEX,
                "tags" = list("stamina", "burst"),
                "exclusiveTags" = list("stamina"),
                "button_icon_state" = "adrenaline",
        )
        required_cells = list(
                CHANGELING_CELL_ID_COW,
                CHANGELING_CELL_ID_HUMAN,
        )
        required_abilities = list(
                /datum/action/changeling/adrenaline,
        )

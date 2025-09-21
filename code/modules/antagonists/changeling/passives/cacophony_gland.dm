/// Upgrade: Cacophony Gland — reworks our lungs into a resonant array that weaponizes both shriek disciplines.
/datum/changeling_genetic_matrix_recipe/cacophony_gland
        id = "matrix_cacophony_gland"
        name = "Cacophony Gland"
        description = "Grow reverberant ducts that project punishing harmonics across the arena."
        module = list(
                "id" = "matrix_cacophony_gland",
                "name" = "Cacophony Gland",
                "desc" = "Widens shriek coverage, intensifies disorientation, and hardens technophagic structure damage.",
                "helptext" = "Occupies a key slot due to the overwhelming pressure it exerts.",
                "category" = GENETIC_MATRIX_CATEGORY_UPGRADE,
                "slotType" = BIO_INCUBATOR_SLOT_KEY,
                "tags" = list("sonic", "crowd_control"),
                "exclusiveTags" = list("shriek_upgrade"),
                "button_icon_state" = "resonant_shriek",
                "effects" = list(
                        "resonant_shriek_range_add" = 1,
                        "resonant_shriek_confusion_mult" = 1.2,
                        "dissonant_shriek_structure_mult" = 1.15,
                ),
        )
        required_cells = list(
                CHANGELING_CELL_ID_VOX,
                CHANGELING_CELL_ID_GLOCKROACH,
        )
        required_abilities = list(
                /datum/action/changeling/resonant_shriek,
        )

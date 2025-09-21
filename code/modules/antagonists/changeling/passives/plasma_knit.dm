/// Upgrade: Plasma Knit — saturates Fleshmend with webbed plasma that lingers longer and knits faster.
/datum/changeling_genetic_matrix_recipe/plasma_knit
        id = "matrix_plasma_knit"
        name = "Plasma Knit"
        description = "Thread caustic plasma silk through our regeneration slurry for denser healing."
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
                        "fleshmend_duration_add" = 3 SECONDS,
                        "fleshmend_heal_mult" = 1.2,
                ),
        )
        required_cells = list(
                CHANGELING_CELL_ID_GIANT_SPIDER,
                CHANGELING_CELL_ID_PODWEAK,
        )
        required_abilities = list(
                /datum/action/changeling/fleshmend,
        )

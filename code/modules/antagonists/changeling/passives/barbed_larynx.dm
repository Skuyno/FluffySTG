/// Passive: Barbed Larynx — reinforces our stinging anatomy with telescoping harpoons for safer injections.
/datum/changeling_genetic_matrix_recipe/barbed_larynx
        id = "matrix_barbed_larynx"
        name = "Barbed Larynx"
        description = "Extend needle-like ossifications through our voicebox to lengthen sting reach."
        module = list(
                "id" = "matrix_barbed_larynx",
                "name" = "Barbed Larynx",
                "desc" = "Extends sting range and stability, letting us tag prey from a step farther without risk.",
                "category" = GENETIC_MATRIX_CATEGORY_PASSIVE,
                "slotType" = BIO_INCUBATOR_SLOT_FLEX,
                "tags" = list("sting", "utility"),
                "exclusiveTags" = list("sting_range"),
                "button_icon_state" = null,
                "effects" = list(
                        "sting_range_add" = 1,
                ),
        )
        required_cells = list(
                CHANGELING_CELL_ID_FELINID,
                CHANGELING_CELL_ID_SHADEKIN,
        )

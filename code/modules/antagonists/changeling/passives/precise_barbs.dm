/// Upgrade: Precise Barbs — tempers our harvest stings with telescoping quills for cleaner strikes and thriftier sampling.
/datum/changeling_genetic_matrix_recipe/precise_barbs
        id = "matrix_precise_barbs"
        name = "Precise Barbs"
        description = "Refine our stingers into articulated barbs that sip cells without wasted chems."
        module = list(
                "id" = "matrix_precise_barbs",
                "name" = "Precise Barbs",
                "desc" = "Extends Harvest Cells range and trims its chemical expenditure.",
                "category" = GENETIC_MATRIX_CATEGORY_UPGRADE,
                "slotType" = BIO_INCUBATOR_SLOT_FLEX,
                "tags" = list("sting", "collection"),
                "exclusiveTags" = list("harvest_upgrade"),
                "button_icon_state" = "sting_extract",
                "effects" = list(
                        "harvest_cells_chem_discount" = 4,
                        "harvest_cells_bonus_range" = 1,
                ),
        )
        required_cells = list(
                CHANGELING_CELL_ID_NABBER,
                CHANGELING_CELL_ID_VULPKANIN,
        )
        required_abilities = list(
                /datum/action/changeling/sting/harvest_cells,
        )

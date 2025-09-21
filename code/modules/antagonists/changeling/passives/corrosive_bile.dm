/// Upgrade: Corrosive Bile — distills hyperacidic enzymes that melt restraints in moments with less expenditure.
/datum/changeling_genetic_matrix_recipe/corrosive_bile
        id = "matrix_corrosive_bile"
        name = "Corrosive Bile"
        description = "Concentrate volatile bile streams that chew through bindings almost instantly."
        module = list(
                "id" = "matrix_corrosive_bile",
                "name" = "Corrosive Bile",
                "desc" = "Speeds up Biodegrade reactions while shaving their chemical costs.",
                "category" = GENETIC_MATRIX_CATEGORY_UPGRADE,
                "slotType" = BIO_INCUBATOR_SLOT_FLEX,
                "tags" = list("acid", "escape"),
                "exclusiveTags" = list("biodegrade_upgrade"),
                "button_icon_state" = "biodegrade",
                "effects" = list(
                        "biodegrade_timer_mult" = 0.7,
                        "biodegrade_chem_discount" = 8,
                ),
        )
        required_cells = list(
                CHANGELING_CELL_ID_XENO,
                CHANGELING_CELL_ID_MORPH,
        )
        required_abilities = list(
                /datum/action/changeling/biodegrade,
        )

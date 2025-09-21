/// Passive: Hypermetabolic Drive — splices predator twitch muscle with aquatic flow for relentless pace.
/datum/changeling_genetic_matrix_recipe/hypermetabolic_drive
        id = "matrix_hypermetabolic_drive"
        name = "Hypermetabolic Drive"
        description = "Channel sprint-born enzymes and aquatic glide into our baseline gait."
        module = list(
                "id" = "matrix_hypermetabolic_drive",
                "name" = "Hypermetabolic Drive",
                "desc" = "Increases our default stride and hastens stamina rebound between bursts of speed.",
                "category" = GENETIC_MATRIX_CATEGORY_PASSIVE,
                "slotType" = BIO_INCUBATOR_SLOT_FLEX,
                "tags" = list("mobility", "stamina"),
                "exclusiveTags" = list("speed_boost"),
                "button_icon_state" = null,
                "effects" = list(
                        "move_speed_slowdown" = -0.06,
                        "stamina_regen_time_mult" = 0.9,
                ),
        )
        required_cells = list(
                CHANGELING_CELL_ID_VULPKANIN,
                CHANGELING_CELL_ID_SPACE_CARP,
        )

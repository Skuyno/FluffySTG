#define GENETIC_MATRIX_CATEGORY_KEY "key_active"
#define GENETIC_MATRIX_CATEGORY_PASSIVE "passive"
#define GENETIC_MATRIX_CATEGORY_UPGRADE "upgrade"

GLOBAL_LIST_INIT_TYPED(changeling_genetic_recipes, /list, list())

/datum/changeling_genetic_recipe
        /// Unique identifier for the recipe.
        var/id
        /// Display name for the recipe result.
        var/name
        /// Required cytology cell identifiers.
        var/list/required_cells = list()
        /// Required changeling ability identifiers.
        var/list/required_abilities = list()
        /// Base module data granted on completion.
        var/list/module_data = list()

/datum/changeling_genetic_recipe/New()
        . = ..()
        if(isnull(id))
                CRASH("Changeling genetic recipe created without an id.")
        GLOB.changeling_genetic_recipes += src

/datum/changeling_genetic_recipe/Destroy()
        GLOB.changeling_genetic_recipes -= src
        return ..()

/datum/changeling_genetic_recipe/proc/get_module_id()
        if(!module_data)
                return id
        return module_data["id"] || id

/datum/changeling_genetic_recipe/proc/get_module_data()
        var/list/output = module_data ? module_data.Copy() : list()
        if(!output["id"])
                output["id"] = get_module_id()
        if(!output["name"])
                output["name"] = name
        if(!output["category"])
                output["category"] = GENETIC_MATRIX_CATEGORY_PASSIVE
        if(!output["slotType"])
                output["slotType"] = BIO_INCUBATOR_SLOT_FLEX
        return output

/datum/changeling_genetic_recipe/proc/matches(list/cell_ids, list/ability_ids)
        if(isnull(cell_ids))
                cell_ids = list()
        if(isnull(ability_ids))
                ability_ids = list()
        var/list/cell_lookup = list()
        for(var/entry in cell_ids)
                cell_lookup["[entry]"] = TRUE
        var/list/ability_lookup = list()
        for(var/entry in ability_ids)
                ability_lookup["[entry]"] = TRUE
        for(var/required_cell in required_cells)
                if(!cell_lookup["[required_cell]"])
                        return FALSE
        for(var/required_ability in required_abilities)
                if(!ability_lookup["[required_ability]"])
                        return FALSE
        return TRUE

/datum/changeling_genetic_recipe/regenerative_core
        id = "module_regenerative_core"
        name = "Regenerative Core"
        required_cells = list(/datum/micro_organism/cell_line/human)
        required_abilities = list(/datum/action/changeling/fleshmend)
        module_data = list(
                "id" = "module_regenerative_core",
                "name" = "Regenerative Core",
                "desc" = "Refine our rapid tissue replication to operate continuously, improving passive regeneration.",
                "helptext" = "Combining a human genome imprint with Fleshmend gives us a low, constant healing factor.",
                "category" = GENETIC_MATRIX_CATEGORY_PASSIVE,
                "slotType" = BIO_INCUBATOR_SLOT_FLEX,
                "tags" = list("regeneration", "sustain"),
                "conflictTags" = list("regeneration"),
        )

/datum/changeling_genetic_recipe/predators_mantle
        id = "module_predators_mantle"
        name = "Predator's Mantle"
        required_cells = list(
                /datum/micro_organism/cell_line/vox,
                /datum/micro_organism/cell_line/tajaran,
        )
        required_abilities = list(/datum/action/changeling/weapon/arm_blade)
        module_data = list(
                "id" = "module_predators_mantle",
                "name" = "Predator's Mantle",
                "desc" = "Forge a brutal key-form that channels armblade ferocity into a focused execution strike.",
                "helptext" = "The hybrid avian-feline matrix grants a devastating melee burst usable as a key active module.",
                "category" = GENETIC_MATRIX_CATEGORY_KEY,
                "slotType" = BIO_INCUBATOR_SLOT_KEY,
                "tags" = list("melee", "burst"),
                "conflictTags" = list("key_active"),
        )

/datum/changeling_genetic_recipe/chimeric_overclock
        id = "module_chimeric_overclock"
        name = "Chimeric Overclock"
        required_cells = list(
                /datum/micro_organism/cell_line/human,
                /datum/micro_organism/cell_line/tajaran,
        )
        required_abilities = list(/datum/action/changeling/adrenaline)
        module_data = list(
                "id" = "module_chimeric_overclock",
                "name" = "Chimeric Overclock",
                "desc" = "Rework Gene Stim to surge longer without burning out as quickly.",
                "helptext" = "Our stimulant pathways absorb Tajaran resilience, stretching adrenaline surges.",
                "category" = GENETIC_MATRIX_CATEGORY_UPGRADE,
                "slotType" = BIO_INCUBATOR_SLOT_FLEX,
                "tags" = list("stamina", "stim"),
                "conflictTags" = list("stamina"),
        )

/datum/changeling_genetic_recipe/shepherds_bulwark
        id = "module_shepherds_bulwark"
        name = "Shepherd's Bulwark"
        required_cells = list(
                /datum/micro_organism/cell_line/cow,
                /datum/micro_organism/cell_line/goat,
        )
        required_abilities = list(/datum/action/changeling/biodegrade)
        module_data = list(
                "id" = "module_shepherds_bulwark",
                "name" = "Shepherd's Bulwark",
                "desc" = "Stabilise our form, resisting restraints and blunt trauma alike.",
                "helptext" = "Rural biomass teaches our hide to dissolve shackles without sacrificing resilience.",
                "category" = GENETIC_MATRIX_CATEGORY_PASSIVE,
                "slotType" = BIO_INCUBATOR_SLOT_FLEX,
                "tags" = list("defense", "resistance"),
                "conflictTags" = list("defense"),
        )

/datum/changeling_genetic_recipe/skyborne_echo
        id = "module_skyborne_echo"
        name = "Skyborne Echo"
        required_cells = list(
                /datum/micro_organism/cell_line/vox,
                /datum/micro_organism/cell_line/teshari,
        )
        required_abilities = list(/datum/action/changeling/digitalcamo)
        module_data = list(
                "id" = "module_skyborne_echo",
                "name" = "Skyborne Echo",
                "desc" = "Refine digital camouflage with avian proprioception to glide unseen.",
                "helptext" = "Improves our camouflage to muffle footfalls and motion when the ability is active.",
                "category" = GENETIC_MATRIX_CATEGORY_UPGRADE,
                "slotType" = BIO_INCUBATOR_SLOT_FLEX,
                "tags" = list("stealth"),
                "conflictTags" = list("stealth"),
        )

/datum/changeling_genetic_recipe/feathered_locomotion
        id = "module_feathered_locomotion"
        name = "Feathered Locomotion"
        required_cells = list(
                /datum/micro_organism/cell_line/teshari,
                /datum/micro_organism/cell_line/chicken,
        )
        required_abilities = list(/datum/action/changeling/strained_muscles)
        module_data = list(
                "id" = "module_feathered_locomotion",
                "name" = "Feathered Locomotion",
                "desc" = "Convert Strained Muscles into controlled bursts inspired by avian musculature.",
                "helptext" = "Lightweight avian myomers temper the crash from our speed bursts.",
                "category" = GENETIC_MATRIX_CATEGORY_UPGRADE,
                "slotType" = BIO_INCUBATOR_SLOT_FLEX,
                "tags" = list("mobility"),
                "conflictTags" = list("mobility"),
        )

#undef GENETIC_MATRIX_CATEGORY_KEY
#undef GENETIC_MATRIX_CATEGORY_PASSIVE
#undef GENETIC_MATRIX_CATEGORY_UPGRADE

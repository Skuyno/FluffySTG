/datum/action/changeling/sting/harvest_cells
        name = "Harvest Cells Sting"
        desc = "We stealthily harvest cytology-compatible cells from living creatures or stored samples."
        helptext = "Activate to silently collect cytology cell lines from organic targets, petri dishes, or other cytology samples."
        button_icon_state = "sting_extract"
        chemical_cost = 25
        dna_cost = CHANGELING_POWER_INNATE

/datum/action/changeling/sting/harvest_cells/can_target_atom(mob/living/user, atom/target)
        if(isnull(target) || target == user)
                return FALSE
        if(istype(target, /mob/living))
                return TRUE
        return length(get_potential_cell_ids(target)) > 0

/datum/action/changeling/sting/harvest_cells/can_sting(mob/living/user, atom/target)
        if(!..())
                return FALSE
        if(!target)
                return FALSE
        if(!length(get_potential_cell_ids(target)))
                user.balloon_alert(user, "no cytology cells!")
                return FALSE
        return TRUE

/datum/action/changeling/sting/harvest_cells/sting_action(mob/living/user, atom/target)
        var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
        if(!changeling)
                return FALSE
        changeling.create_bio_incubator()
        var/datum/changeling_bio_incubator/incubator = changeling.bio_incubator
        if(!incubator)
                return FALSE
        var/list/cell_ids = get_potential_cell_ids(target)
        if(!cell_ids.len)
                return FALSE
        var/added_any = FALSE
        for(var/cell_id in cell_ids)
                if(incubator.add_cell(cell_id))
                        added_any = TRUE
        if(!added_any)
                user.balloon_alert(user, "already catalogued")
                return FALSE
        return TRUE

/datum/action/changeling/sting/harvest_cells/sting_feedback(mob/living/user, atom/target)
        var/name_text = istype(target, /atom) ? target.name : "target"
        if(!name_text)
                name_text = "target"
        to_chat(user, span_notice("We stealthily harvest cytology cells from [name_text]."))
        if(isliving(target))
                var/mob/living/living_target = target
                to_chat(living_target, span_warning("You feel the faintest prick."))

/datum/action/changeling/sting/harvest_cells/proc/get_potential_cell_ids(atom/target)
        var/list/cell_ids = list()
        if(!target)
                return cell_ids
        if(ismob(target))
                var/mob/mob_target = target
                for(var/entry in mob_target.get_cytology_cell_ids())
                        if(!(entry in cell_ids))
                                cell_ids += entry
        else
                for(var/entry in target.get_cytology_cell_ids())
                        if(!(entry in cell_ids))
                                cell_ids += entry
        var/datum/biological_sample/sample = get_embedded_sample(target)
        if(sample)
                for(var/entry in sample.get_cell_line_types())
                        if(!(entry in cell_ids))
                                cell_ids += entry
        return cell_ids

/datum/action/changeling/sting/harvest_cells/proc/get_embedded_sample(atom/target)
        if(!target)
                return null
        if(istype(target, /obj/item/petri_dish))
                var/obj/item/petri_dish/dish = target
                if(istype(dish.sample, /datum/biological_sample))
                        return dish.sample
        var/datum/biological_sample/sample = target.vars["biological_sample"]
        if(!istype(sample))
                sample = target.vars["sample"]
        if(!istype(sample))
                return null
        return sample

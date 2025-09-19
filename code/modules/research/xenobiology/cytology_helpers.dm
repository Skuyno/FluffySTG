/atom/proc/get_cytology_cell_ids()
        return list()

/datum/biological_sample/proc/get_cell_line_types()
        var/list/output = list()
        for(var/datum/micro_organism/cell_line/cell_line in micro_organisms)
                output += cell_line.type
        return output

/obj/item/petri_dish/get_cytology_cell_ids()
        var/list/ids = ..()
        if(!sample)
                return ids
        for(var/cell_id in sample.get_cell_line_types())
                if(!(cell_id in ids))
                        ids += cell_id
        return ids

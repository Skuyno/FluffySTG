/datum/changeling_genetic_module/passive/crystalline_buffer
	id = "matrix_crystalline_buffer"
	passive_effects = list()

/datum/changeling_genetic_module/passive/crystalline_buffer/on_activate()
	. = ..()
	apply_state()
	return .

/datum/changeling_genetic_module/passive/crystalline_buffer/on_deactivate()
	remove_state()
	return ..()

/datum/changeling_genetic_module/passive/crystalline_buffer/on_owner_changed(mob/living/old_holder, mob/living/new_holder)
	. = ..()
	if(new_holder)
		apply_state()
	else
		remove_state()

/datum/changeling_genetic_module/passive/crystalline_buffer/proc/apply_state()
	if(!is_active())
		return
	var/mob/living/living_owner = get_owner_mob()
	living_owner?.apply_status_effect(/datum/status_effect/changeling_crystalline_buffer, owner)

/datum/changeling_genetic_module/passive/crystalline_buffer/proc/remove_state()
	var/mob/living/living_owner = get_owner_mob()
	living_owner?.remove_status_effect(/datum/status_effect/changeling_crystalline_buffer)

/datum/changeling_genetic_module/upgrade/ashen_pump
	id = "matrix_ashen_pump"
	passive_effects = list()

/datum/changeling_genetic_module/upgrade/ashen_pump/on_deactivate()
	var/mob/living/living_owner = get_owner_mob()
	if(living_owner)
		living_owner.remove_status_effect(/datum/status_effect/changeling_ashen_pump)
	return ..()

/datum/changeling_genetic_module/upgrade/ashen_pump/on_owner_changed(mob/living/old_holder, mob/living/new_holder)
	. = ..()
	if(!new_holder && old_holder)
		old_holder.remove_status_effect(/datum/status_effect/changeling_ashen_pump)

/datum/changeling_genetic_module/upgrade/ashen_pump/proc/on_gene_stim_used(mob/living/carbon/user)
	if(!is_active() || !istype(user))
		return
	user.apply_status_effect(/datum/status_effect/changeling_ashen_pump, owner)
	owner?.adjust_chemicals(-3)

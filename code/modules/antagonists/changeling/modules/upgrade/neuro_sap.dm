/datum/changeling_genetic_module/upgrade/neuro_sap
	id = "matrix_neuro_sap"
	passive_effects = list()

	var/bonus_applied = FALSE

/datum/changeling_genetic_module/upgrade/neuro_sap/on_deactivate()
	var/mob/living/living_owner = get_owner_mob()
	if(living_owner)
		living_owner.remove_status_effect(/datum/status_effect/changeling_neuro_sap)
	remove_bonus()
	return ..()

/datum/changeling_genetic_module/upgrade/neuro_sap/on_owner_changed(mob/living/old_holder, mob/living/new_holder)
	. = ..()
	if(!new_holder && old_holder)
		old_holder.remove_status_effect(/datum/status_effect/changeling_neuro_sap)
	if(!new_holder)
		remove_bonus()

/datum/changeling_genetic_module/upgrade/neuro_sap/proc/apply_bonus()
	if(bonus_applied)
		return
	var/datum/antagonist/changeling/changeling_owner = owner
	if(!changeling_owner)
		return
	changeling_owner.chem_recharge_rate += 0.8
	bonus_applied = TRUE

/datum/changeling_genetic_module/upgrade/neuro_sap/proc/remove_bonus()
	if(!bonus_applied)
		return
	var/datum/antagonist/changeling/changeling_owner = owner
	if(changeling_owner)
		changeling_owner.chem_recharge_rate -= 0.8
	bonus_applied = FALSE

/datum/changeling_genetic_module/upgrade/neuro_sap/proc/on_panacea_used(mob/living/carbon/user)
	if(!is_active() || !istype(user))
		return
	user.apply_status_effect(/datum/status_effect/changeling_neuro_sap, owner)

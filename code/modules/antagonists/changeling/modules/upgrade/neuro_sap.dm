/datum/changeling_genetic_matrix_recipe/neuro_sap
	id = "matrix_neuro_sap"
	name = "Neuro Sap"
	description = "Steep Panacea with slimeperson buffer gel, bee toxin filters, and Legion null-masks to harden us against toxins and radiation."
	module = list(
			"id" = "matrix_neuro_sap",
			"name" = "Neuro Sap",
			"desc" = "Panacea leaves a regenerative film that shrugs toxins, slows radiation, and boosts chem recharge.",
			"category" = GENETIC_MATRIX_CATEGORY_UPGRADE,
			"slotType" = BIO_INCUBATOR_SLOT_FLEX,
		"moduleType" = /datum/changeling_genetic_module/upgrade/neuro_sap,
			"tags" = list("panacea", "chemicals"),
			"exclusiveTags" = list("panacea"),
			"button_icon_state" = "panacea",
	)
	required_cells = list(
		CHANGELING_CELL_ID_SLIMEPERSON,
		CHANGELING_CELL_ID_BEE,
		CHANGELING_CELL_ID_LEGION,
	)
	required_abilities = list(
			/datum/action/changeling/panacea,
	)

/datum/status_effect/changeling_neuro_sap
	id = "changeling_neuro_sap"
	status_type = STATUS_EFFECT_REFRESH
	duration = 90 SECONDS
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = null
	var/datum/weakref/changeling_ref

/datum/status_effect/changeling_neuro_sap/on_creation(mob/living/new_owner, datum/antagonist/changeling/changeling_data)
	changeling_ref = WEAKREF(changeling_data)
	return ..()

/datum/status_effect/changeling_neuro_sap/on_apply()
	owner.add_traits(list(TRAIT_RADIMMUNE, TRAIT_TOXIMMUNE), TRAIT_STATUS_EFFECT(id))
	var/datum/antagonist/changeling/changeling_data = changeling_ref?.resolve()
       var/datum/changeling_genetic_module/upgrade/neuro_sap/neuro_module = changeling_data?.module_manager?.get_module("matrix_neuro_sap")
	neuro_module?.apply_bonus()
	return TRUE

/datum/status_effect/changeling_neuro_sap/on_remove()
	owner.remove_traits(list(TRAIT_RADIMMUNE, TRAIT_TOXIMMUNE), TRAIT_STATUS_EFFECT(id))
	var/datum/antagonist/changeling/changeling_data = changeling_ref?.resolve()
       var/datum/changeling_genetic_module/upgrade/neuro_sap/neuro_module = changeling_data?.module_manager?.get_module("matrix_neuro_sap")
	neuro_module?.remove_bonus()
	return ..()

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


/// Upgrade: Neuro Sap — steeps Panacea with ghoul enzymes that harden us against toxins and radiation.
/datum/changeling_genetic_matrix_recipe/neuro_sap
	id = "matrix_neuro_sap"
	name = "Neuro Sap"
	description = "Condense neuro-reactive sap so Panacea grants lingering immunity and chemical momentum."
	module = list(
			"id" = "matrix_neuro_sap",
			"name" = "Neuro Sap",
			"desc" = "Panacea leaves a regenerative film that shrugs toxins, slows radiation, and boosts chem recharge.",
			"category" = GENETIC_MATRIX_CATEGORY_UPGRADE,
			"slotType" = BIO_INCUBATOR_SLOT_FLEX,
			"tags" = list("panacea", "chemicals"),
			"exclusiveTags" = list("panacea"),
			"button_icon_state" = "panacea",
	)
	required_cells = list(
			CHANGELING_CELL_ID_GHOUL,
			CHANGELING_CELL_ID_PLASMAMAN,
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
	changeling_data?.apply_neuro_sap_bonus()
	return TRUE

/datum/status_effect/changeling_neuro_sap/on_remove()
	owner.remove_traits(list(TRAIT_RADIMMUNE, TRAIT_TOXIMMUNE), TRAIT_STATUS_EFFECT(id))
	var/datum/antagonist/changeling/changeling_data = changeling_ref?.resolve()
	changeling_data?.remove_neuro_sap_bonus()
	return ..()

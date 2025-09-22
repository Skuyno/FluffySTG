
/// Upgrade: Graviton Ripsaw — braids voidwalker muscle into our arm blade for gravitational sweeps.
/datum/changeling_genetic_matrix_recipe/graviton_ripsaw
	id = "matrix_graviton_ripsaw"
	name = "Graviton Ripsaw"
	description = "Channel voidwalker tendons through our arm blade to drag prey and lunge across open space."
	module = list(
			"id" = "matrix_graviton_ripsaw",
			"name" = "Graviton Ripsaw",
			"desc" = "Arm Blade attacks tug victims inward and let us sling toward anchored targets for EVA mobility.",
			"category" = GENETIC_MATRIX_CATEGORY_UPGRADE,
			"slotType" = BIO_INCUBATOR_SLOT_FLEX,
			"tags" = list("arm_blade", "control"),
			"button_icon_state" = "armblade",
	)
	required_cells = list(
			CHANGELING_CELL_ID_VOIDWALKER,
			CHANGELING_CELL_ID_SPACE_CARP,
	)
	required_abilities = list(
			/datum/action/changeling/weapon/arm_blade,
	)

/datum/movespeed_modifier/changeling/gravitic_pull
	multiplicative_slowdown = 1.3

/datum/status_effect/changeling_gravitic_pull
	id = "changeling_gravitic_pull"
	status_type = STATUS_EFFECT_REFRESH
	duration = 3 SECONDS
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = null

/datum/status_effect/changeling_gravitic_pull/on_apply()
	owner.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/changeling/gravitic_pull, TRUE)
	return TRUE

/datum/status_effect/changeling_gravitic_pull/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/changeling/gravitic_pull)
	return ..()

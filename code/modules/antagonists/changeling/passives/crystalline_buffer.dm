/// Passive: Crystalline Buffer — suspends human riot plating, colossus prism shards, and watcher frost cores as ablative, chem-feeding barrier charges.
/datum/changeling_genetic_matrix_recipe/crystalline_buffer
	id = "matrix_crystalline_buffer"
	name = "Crystalline Buffer"
	description = "Mount human riot plating, colossus prism shards, and watcher frost cores across our hide to absorb the first blows and flash back energy."
	module = list(
		"id" = "matrix_crystalline_buffer",
		"name" = "Crystalline Buffer",
		"desc" = "Stores four refueling prism charges that negate incoming stuns before erupting in a blinding flash.",
		"category" = GENETIC_MATRIX_CATEGORY_PASSIVE,
		"slotType" = BIO_INCUBATOR_SLOT_FLEX,
		"tags" = list("defense", "chemicals"),
		"exclusiveTags" = list("shield"),
	)
	required_cells = list(
		CHANGELING_CELL_ID_HUMAN,
		CHANGELING_CELL_ID_COLOSSUS,
		CHANGELING_CELL_ID_WATCHER,
	)

/datum/status_effect/changeling_crystalline_buffer
	id = "changeling_crystalline_buffer"
	status_type = STATUS_EFFECT_UNIQUE
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = null
	var/datum/weakref/changeling_ref
	var/charges_left = 4
	var/recharge_delay = 12.5 SECONDS

/datum/status_effect/changeling_crystalline_buffer/on_creation(mob/living/new_owner, datum/antagonist/changeling/changeling_data)
	changeling_ref = WEAKREF(changeling_data)
	return ..()

/datum/status_effect/changeling_crystalline_buffer/on_apply()
	RegisterSignals(owner, list(
		COMSIG_LIVING_STATUS_STUN,
		COMSIG_LIVING_STATUS_KNOCKDOWN,
		COMSIG_LIVING_STATUS_PARALYZE,
		COMSIG_LIVING_STATUS_IMMOBILIZE,
	), PROC_REF(on_incapacitation))
	RegisterSignal(owner, COMSIG_LIVING_GENERIC_STUN_CHECK, PROC_REF(on_generic_check))
	RegisterSignal(owner, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	return TRUE

/datum/status_effect/changeling_crystalline_buffer/on_remove()
	UnregisterSignal(owner, list(
		COMSIG_LIVING_STATUS_STUN,
		COMSIG_LIVING_STATUS_KNOCKDOWN,
		COMSIG_LIVING_STATUS_PARALYZE,
		COMSIG_LIVING_STATUS_IMMOBILIZE,
		COMSIG_LIVING_GENERIC_STUN_CHECK,
		COMSIG_ATOM_EXAMINE,
	))
	return ..()

/datum/status_effect/changeling_crystalline_buffer/proc/on_examine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("A lattice of crystal plates shimmers beneath the skin.")

/datum/status_effect/changeling_crystalline_buffer/proc/on_incapacitation(mob/living/source, amount, ignore_canstun)
	SIGNAL_HANDLER
	if(amount <= 0 || ignore_canstun)
		return NONE
	if(use_charge())
		return COMPONENT_NO_STUN
	return NONE

/datum/status_effect/changeling_crystalline_buffer/proc/on_generic_check(mob/living/source, check_flags)
	SIGNAL_HANDLER
	if(use_charge(FALSE))
		return COMPONENT_NO_STUN
	return NONE

/datum/status_effect/changeling_crystalline_buffer/proc/use_charge(apply_effects = TRUE)
	if(charges_left <= 0)
		return FALSE
	charges_left--
	if(apply_effects)
		owner.visible_message(
			span_warning("[owner]'s skin flashes with refracted light, scattering the blow!"),
			span_changeling("Our crystalline buffer devours the impact."),
		)
		var/datum/antagonist/changeling/changeling_data = changeling_ref?.resolve()
		changeling_data?.adjust_chemicals(6)
	if(charges_left <= 0)
		trigger_flash()
		if(recharge_delay > 0)
			addtimer(CALLBACK(src, PROC_REF(recharge_buffer)), recharge_delay)
	return TRUE

/datum/status_effect/changeling_crystalline_buffer/proc/trigger_flash()
	owner.flash_act(visual = TRUE)
	for(var/mob/living/victim in oview(1, owner))
		if(victim == owner)
			continue
		victim.adjustStaminaLoss(20)
		victim.apply_status_effect(/datum/status_effect/dazed, 3 SECONDS)

/datum/status_effect/changeling_crystalline_buffer/proc/recharge_buffer()
	charges_left = 4
	var/datum/antagonist/changeling/changeling_data = changeling_ref?.resolve()
	if(changeling_data?.owner?.current)
		to_chat(changeling_data.owner.current, span_changeling("Our crystalline buffer reconstitutes new charges."))

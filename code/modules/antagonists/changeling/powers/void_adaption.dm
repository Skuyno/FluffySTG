/datum/action/changeling/void_adaption
	name = "Void Adaption"
	desc = "We prepare our cells to resist the hostile environment outside of the station. We may freely travel wherever we wish."
	helptext = "This ability is passive, and will automatically protect us in situations of extreme cold or vacuum, \
		as well as removing our need to breathe oxygen, although we will still be affected by hazardous gases. \
		While it is actively protecting us from temperature or pressure it reduces our chemical regeneration rate."
	owner_has_control = FALSE
	dna_cost = 2

	/// Traits we apply to become immune to the environment
	var/static/list/gain_traits = list(TRAIT_NO_BREATHLESS_DAMAGE, TRAIT_RESISTCOLD, TRAIT_RESISTLOWPRESSURE, TRAIT_SNOWSTORM_IMMUNE)
	/// Additional traits granted when the void carapace matrix module is active.
	var/static/list/module_gain_traits = list(TRAIT_RESISTHEAT, TRAIT_RESISTHIGHPRESSURE)
	/// How much we slow chemical regeneration while active, in chems per second
	var/recharge_slowdown = 0.25
	/// Baseline slowdown applied without void carapace.
	var/base_recharge_slowdown = 0.25
	/// Slowdown applied when the void carapace matrix module is active.
	var/module_recharge_slowdown = 0.05
	/// Are we currently protecting our user?
	var/currently_active = FALSE
	/// Cached changeling datum for module syncing.
	var/datum/antagonist/changeling/linked_changeling
	/// Do we currently have the module traits applied to our owner?
	var/module_traits_applied = FALSE

/datum/action/changeling/void_adaption/on_purchase(mob/user, is_respec)
	. = ..()
	user.add_traits(gain_traits, REF(src))
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(check_environment))
	sync_module_state(IS_CHANGELING(user))

/datum/action/changeling/void_adaption/Remove(mob/remove_from)
	remove_from.remove_traits(gain_traits, REF(src))
	UnregisterSignal(remove_from, COMSIG_LIVING_LIFE)
	if (currently_active)
		on_removed_adaption(remove_from, "Our cells relax, despite the danger!")
	update_module_traits(FALSE)
	linked_changeling = null
	return ..()

/// Checks if we would be providing any useful benefit at present
/datum/action/changeling/void_adaption/proc/check_environment(mob/living/void_adapted)
	SIGNAL_HANDLER

	var/list/active_reasons = list()
	var/has_carapace = linked_changeling?.matrix_void_carapace_active

	var/datum/gas_mixture/environment = void_adapted.loc.return_air()
	if (!isnull(environment))
		var/vulnerable_temperature = void_adapted.get_body_temp_cold_damage_limit()
		var/affected_temperature = environment.return_temperature()
		var/environment_pressure = environment.return_pressure()
		if (ishuman(void_adapted))
			var/mob/living/carbon/human/special_boy = void_adapted
			var/cold_protection = special_boy.get_cold_protection(affected_temperature)
			vulnerable_temperature *= (1 - cold_protection)

			var/affected_pressure = special_boy.calculate_affecting_pressure(environment_pressure)
			if (affected_pressure < HAZARD_LOW_PRESSURE)
				active_reasons += "vacuum"
			if (has_carapace && affected_pressure > HAZARD_HIGH_PRESSURE)
				if(!("pressure" in active_reasons))
					active_reasons += "pressure"
			if (has_carapace)
				var/heat_limit = special_boy.get_body_temp_heat_damage_limit()
				var/heat_protection = special_boy.get_heat_protection(affected_temperature)
				heat_limit *= (1 + heat_protection)
				if (affected_temperature > heat_limit)
					if(!("heat" in active_reasons))
						active_reasons += "heat"
		else if (has_carapace)
			if (environment_pressure > HAZARD_HIGH_PRESSURE)
				if(!("pressure" in active_reasons))
					active_reasons += "pressure"
			var/base_heat_limit = void_adapted.get_body_temp_heat_damage_limit()
			if (affected_temperature > base_heat_limit)
				if(!("heat" in active_reasons))
					active_reasons += "heat"

		if (affected_temperature < vulnerable_temperature)
			active_reasons += "cold"

	var/should_be_active = !!length(active_reasons)
	if (currently_active == should_be_active)
		return

	if (!should_be_active)
		on_removed_adaption(void_adapted, "Our cells relax in safer air.")
		return
	var/datum/antagonist/changeling/changeling_data = linked_changeling
	if(!changeling_data || changeling_data.owner?.current != void_adapted)
		changeling_data = IS_CHANGELING(void_adapted)
		linked_changeling = changeling_data
	to_chat(void_adapted, span_changeling("Our cells harden themselves against the [pick(active_reasons)]."))
	changeling_data?.chem_recharge_slowdown -= recharge_slowdown
	currently_active = TRUE

/// Called when we stop being adapted
/datum/action/changeling/void_adaption/proc/on_removed_adaption(mob/living/former, message)
	var/datum/antagonist/changeling/changeling_data = IS_CHANGELING(former)
	to_chat(former, span_changeling(message))
	changeling_data?.chem_recharge_slowdown += recharge_slowdown
	currently_active = FALSE

/datum/action/changeling/void_adaption/proc/sync_module_state(datum/antagonist/changeling/changeling_data)
	if(changeling_data)
		linked_changeling = changeling_data
	else if(owner)
		linked_changeling = IS_CHANGELING(owner)
	var/target_slowdown = base_recharge_slowdown
	var/has_carapace = linked_changeling?.matrix_void_carapace_active
	if(has_carapace)
		target_slowdown = module_recharge_slowdown
	if(recharge_slowdown == target_slowdown)
		return
	if(currently_active && linked_changeling)
		linked_changeling.chem_recharge_slowdown += recharge_slowdown
		recharge_slowdown = target_slowdown
		linked_changeling.chem_recharge_slowdown -= recharge_slowdown
	else
		recharge_slowdown = target_slowdown
	update_module_traits(has_carapace)
	if(owner && has_carapace)
		check_environment(owner)


/datum/action/changeling/void_adaption/proc/update_module_traits(has_module)
	if(!ismob(owner))
		module_traits_applied = FALSE
		return
	if(has_module)
		if(module_traits_applied)
			return
		owner.add_traits(module_gain_traits, REF(src))
		module_traits_applied = TRUE
		return
	if(!module_traits_applied)
		return
	owner.remove_traits(module_gain_traits, REF(src))
	module_traits_applied = FALSE

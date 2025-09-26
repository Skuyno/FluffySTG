/**
	* Coordinates changeling genetic modules and aggregates their passive effects.
	*/

/datum/changeling_module_manager
	/// Owning changeling antagonist datum.
	var/datum/antagonist/changeling/changeling
	/// Bio incubator backing the module state.
	var/datum/changeling_bio_incubator/listened_incubator
	/// Active module instances indexed by identifier.
	var/list/modules_by_id = list()
	/// Cached passive effect totals.
	var/list/genetic_matrix_effect_cache = list()
	/// Mob currently benefitting from passive modifiers.
	var/mob/living/matrix_passive_effects_bound_mob
	/// Cached movement slowdown applied to the owner.
	var/matrix_current_movespeed_slowdown = 0
	/// Cached stamina usage multiplier applied to the owner.
	var/matrix_current_stamina_use_mult = 1
	/// Cached stamina regeneration multiplier applied to the owner.
	var/matrix_current_stamina_regen_mult = 1
	/// Cached max stamina bonus applied to the owner.
	var/matrix_current_max_stamina_bonus = 0
	/// Cached chemical recharge modifier applied to the owner.
	var/matrix_current_chem_rate_bonus = 0
	/// Cached sting range modifier applied to the owner.
	var/matrix_current_sting_range_bonus = 0
	/// Cached brute damage multiplier applied to the owner.
	var/matrix_current_brute_damage_mult = 1
	/// Cached burn damage multiplier applied to the owner.
	var/matrix_current_burn_damage_mult = 1

/datum/changeling_module_manager/New(datum/antagonist/changeling/changeling)
	. = ..()
	src.changeling = changeling
	genetic_matrix_effect_cache = changeling_get_default_matrix_effects()
	set_bio_incubator(changeling?.bio_incubator)

/datum/changeling_module_manager/Destroy()
	clear_matrix_passive_effects()
	if(modules_by_id)
		for(var/id in modules_by_id.Copy())
			var/datum/changeling_genetic_module/module = modules_by_id[id]
			deactivate_genetic_matrix_module(id, module)
		modules_by_id.Cut()
	unregister_from_incubator()
	changeling = null
	return ..()

/datum/changeling_module_manager/proc/register_with_incubator(datum/changeling_bio_incubator/incubator)
	if(listened_incubator == incubator)
		return
	unregister_from_incubator()
	if(!incubator)
		return
	listened_incubator = incubator
	RegisterSignal(listened_incubator, COMSIG_CHANGELING_BIO_INCUBATOR_UPDATED, PROC_REF(on_bio_incubator_updated))

/datum/changeling_module_manager/proc/unregister_from_incubator()
	if(!listened_incubator)
		return
	UnregisterSignal(listened_incubator, COMSIG_CHANGELING_BIO_INCUBATOR_UPDATED)
	listened_incubator = null

/datum/changeling_module_manager/proc/set_bio_incubator(datum/changeling_bio_incubator/incubator)
	register_with_incubator(incubator)
	refresh_active_modules()

/datum/changeling_module_manager/proc/on_bio_incubator_updated(datum/changeling_bio_incubator/incubator, update_flags, list/module_changes)
	SIGNAL_HANDLER
	if(QDELETED(src))
		return
	refresh_active_modules()

/datum/changeling_module_manager/proc/refresh_active_modules()
	var/datum/changeling_bio_incubator/incubator = listened_incubator || changeling?.bio_incubator
	if(!incubator)
		return
	if(!modules_by_id)
		modules_by_id = list()
	var/list/datum/changeling_genetic_module/active_instances = incubator.get_active_modules()
	var/list/new_map = list()
	for(var/datum/changeling_genetic_module/instance as anything in active_instances)
		if(!instance || QDELETED(instance))
			continue
		var/id_text = get_module_id_text(instance.id)
		if(isnull(id_text))
			continue
		if(new_map[id_text])
			continue
		new_map[id_text] = instance
	var/list/previous_modules = modules_by_id.Copy()
	for(var/id in previous_modules)
		var/datum/changeling_genetic_module/old_module = previous_modules[id]
		var/datum/changeling_genetic_module/current_module = new_map[id]
		if(old_module && current_module && old_module == current_module)
			continue
		modules_by_id -= id
		deactivate_genetic_matrix_module(id, old_module)
	for(var/id in new_map)
		var/datum/changeling_genetic_module/module = new_map[id]
		if(previous_modules[id] == module)
			modules_by_id[id] = module
			continue
		activate_genetic_matrix_module(id, module)
	update_matrix_passive_effects()

/datum/changeling_module_manager/proc/get_module_id_text(module_identifier)
	if(isnull(module_identifier))
		return null
	if(istext(module_identifier))
		return module_identifier
	if(listened_incubator)
		var/id_text = listened_incubator.sanitize_module_id(module_identifier)
		if(id_text)
			return id_text
	return "[module_identifier]"

/datum/changeling_module_manager/proc/activate_genetic_matrix_module(module_identifier, datum/changeling_genetic_module/module)
	if(!module || QDELETED(module))
		return
	var/id_text = get_module_id_text(module_identifier)
	if(isnull(id_text))
		return
	if(module.owner != changeling)
		module.assign_owner(changeling)
	var/already_active = module.vars?[CHANGELING_MODULE_ACTIVE_FLAG]
	if(!already_active)
		var/activation_result = module.on_activate()
		if(!activation_result)
			module.on_deactivate()
			module.assign_owner(null)
			module.vars[CHANGELING_MODULE_ACTIVE_FLAG] = FALSE
			return
	module.vars[CHANGELING_MODULE_ACTIVE_FLAG] = TRUE
	modules_by_id[id_text] = module
	module.on_owner_changed(null, changeling?.owner?.current)
	changeling?.on_matrix_module_activated(module)

/datum/changeling_module_manager/proc/deactivate_genetic_matrix_module(module_identifier, datum/changeling_genetic_module/module)
	var/id_text = get_module_id_text(module_identifier)
	if(isnull(id_text))
		id_text = null
	if(module && !QDELETED(module))
		var/mob/living/old_holder = module.get_owner_mob()
		if(module.vars?[CHANGELING_MODULE_ACTIVE_FLAG])
			module.on_deactivate()
		module.vars[CHANGELING_MODULE_ACTIVE_FLAG] = FALSE
		module.on_owner_changed(old_holder, null)
		if(module.owner == changeling)
			module.assign_owner(null)
	if(id_text && modules_by_id)
		modules_by_id -= id_text
	changeling?.on_matrix_module_deactivated(module_identifier, module)

/datum/changeling_module_manager/proc/on_owner_mob_changed(mob/living/old_holder, mob/living/new_holder)
	if(!modules_by_id)
		return
	for(var/id in modules_by_id)
		var/datum/changeling_genetic_module/module = modules_by_id[id]
		if(!module || QDELETED(module))
			continue
		module.on_owner_changed(old_holder, new_holder)

/datum/changeling_module_manager/proc/get_active_modules()
	if(!modules_by_id)
		return list()
	return modules_by_id.Copy()

/datum/changeling_module_manager/proc/is_module_active(module_identifier)
	return !!get_module(module_identifier)

/datum/changeling_module_manager/proc/get_module(module_identifier)
	var/id_text = get_module_id_text(module_identifier)
	if(isnull(id_text))
		return null
	return modules_by_id?[id_text]

/datum/changeling_module_manager/proc/process_modules(delta_time)
	if(!modules_by_id)
		return
	for(var/id in modules_by_id)
		var/datum/changeling_genetic_module/module = modules_by_id[id]
		if(!module || QDELETED(module))
			continue
		module.on_tick(delta_time)

/datum/changeling_module_manager/proc/clear_matrix_passive_effects()
	if(matrix_passive_effects_bound_mob)
		var/mob/living/living_owner = matrix_passive_effects_bound_mob
		living_owner.remove_movespeed_modifier(/datum/movespeed_modifier/changeling/genetic_matrix)
		if(istype(living_owner, /mob/living/carbon/human))
			var/mob/living/carbon/human/human_owner = living_owner
			var/datum/physiology/phys = human_owner.physiology
			if(phys)
				if(matrix_current_stamina_use_mult != 1)
					phys.stamina_mod /= matrix_current_stamina_use_mult
				if(matrix_current_brute_damage_mult != 1)
					phys.brute_mod /= matrix_current_brute_damage_mult
				if(matrix_current_burn_damage_mult != 1)
					phys.burn_mod /= matrix_current_burn_damage_mult
		if(matrix_current_stamina_regen_mult != 1)
			living_owner.stamina_regen_time /= matrix_current_stamina_regen_mult
		if(matrix_current_max_stamina_bonus)
			living_owner.max_stamina -= matrix_current_max_stamina_bonus
			living_owner.staminaloss = clamp(living_owner.staminaloss, 0, living_owner.max_stamina)
	var/datum/antagonist/changeling/changeling = src.changeling
	if(changeling)
		if(matrix_current_chem_rate_bonus)
			changeling.chem_recharge_rate -= matrix_current_chem_rate_bonus
		if(matrix_current_sting_range_bonus)
			changeling.sting_range -= matrix_current_sting_range_bonus
	matrix_passive_effects_bound_mob = null
	matrix_current_movespeed_slowdown = 0
	matrix_current_stamina_use_mult = 1
	matrix_current_stamina_regen_mult = 1
	matrix_current_max_stamina_bonus = 0
	matrix_current_chem_rate_bonus = 0
	matrix_current_sting_range_bonus = 0
	matrix_current_brute_damage_mult = 1
	matrix_current_burn_damage_mult = 1
	genetic_matrix_effect_cache = changeling_get_default_matrix_effects()

/datum/changeling_module_manager/proc/update_matrix_passive_effects()
	var/static/list/multiplicative_effect_keys = list(
		"stamina_use_mult",
		"stamina_regen_time_mult",
		"fleshmend_heal_mult",
		"biodegrade_timer_mult",
		"resonant_shriek_confusion_mult",
		"dissonant_shriek_structure_mult",
		"incoming_brute_damage_mult",
		"incoming_burn_damage_mult",
	)
	var/list/effect_totals = changeling_get_default_matrix_effects()
	if(modules_by_id)
		for(var/id in modules_by_id)
			var/datum/changeling_genetic_module/module = modules_by_id[id]
			if(!module || QDELETED(module))
				continue
			var/list/module_effects = module.get_passive_effects()
			if(!islist(module_effects))
				continue
			for(var/effect_key in module_effects)
				var/effect_value = module_effects[effect_key]
				if(isnull(effect_value))
					continue
				if(isnum(effect_value))
					if(effect_key in multiplicative_effect_keys)
						effect_totals[effect_key] *= effect_value
					else
						effect_totals[effect_key] += effect_value
				else
					effect_totals[effect_key] = effect_value
	apply_matrix_passive_effect_totals(effect_totals)

/datum/changeling_module_manager/proc/apply_matrix_passive_effect_totals(list/totals)
	clear_matrix_passive_effects()
	if(!islist(totals))
		totals = changeling_get_default_matrix_effects()
	var/datum/antagonist/changeling/changeling = src.changeling
	var/mob/living/living_owner = changeling?.owner?.current
	var/move_slowdown = totals["move_speed_slowdown"]
	var/stamina_mult = totals["stamina_use_mult"]
	var/regen_mult = totals["stamina_regen_time_mult"]
	var/max_bonus = round(totals["max_stamina_add"])
	var/chem_bonus = totals["chem_recharge_rate_add"]
	var/sting_bonus = round(totals["sting_range_add"])
	var/brute_damage_mult = isnum(totals["incoming_brute_damage_mult"]) ? totals["incoming_brute_damage_mult"] : 1
	var/burn_damage_mult = isnum(totals["incoming_burn_damage_mult"]) ? totals["incoming_burn_damage_mult"] : 1
	brute_damage_mult = max(brute_damage_mult, 0.0001)
	burn_damage_mult = max(burn_damage_mult, 0.0001)

	matrix_current_movespeed_slowdown = move_slowdown
	matrix_current_stamina_use_mult = stamina_mult
	matrix_current_stamina_regen_mult = regen_mult
	matrix_current_max_stamina_bonus = max_bonus
	matrix_current_chem_rate_bonus = chem_bonus
	matrix_current_sting_range_bonus = sting_bonus
	matrix_current_brute_damage_mult = brute_damage_mult
	matrix_current_burn_damage_mult = burn_damage_mult

	if(changeling)
		if(chem_bonus)
			changeling.chem_recharge_rate += chem_bonus
		if(sting_bonus)
			changeling.sting_range += sting_bonus

	genetic_matrix_effect_cache = totals.Copy()

	if(!isliving(living_owner))
		return

	matrix_passive_effects_bound_mob = living_owner
	living_owner.remove_movespeed_modifier(/datum/movespeed_modifier/changeling/genetic_matrix)
	if(move_slowdown)
		living_owner.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/changeling/genetic_matrix, TRUE, multiplicative_slowdown = move_slowdown)
	if(istype(living_owner, /mob/living/carbon/human))
		var/mob/living/carbon/human/human_owner = living_owner
		var/datum/physiology/phys = human_owner.physiology
		if(phys)
			if(stamina_mult != 1)
				phys.stamina_mod *= stamina_mult
			if(brute_damage_mult != 1)
				phys.brute_mod *= brute_damage_mult
			if(burn_damage_mult != 1)
				phys.burn_mod *= burn_damage_mult
	if(regen_mult != 1)
		living_owner.stamina_regen_time *= regen_mult
	if(max_bonus)
		living_owner.max_stamina += max_bonus
		living_owner.staminaloss = clamp(living_owner.staminaloss, 0, living_owner.max_stamina)

/datum/changeling_module_manager/proc/get_genetic_matrix_effect(effect_key, default_value)
	if(!islist(genetic_matrix_effect_cache))
		return default_value
	var/result = genetic_matrix_effect_cache[effect_key]
	if(isnull(result))
		return default_value
	return result

/datum/changeling_module_manager/proc/on_genetic_matrix_reset()
	refresh_active_modules()


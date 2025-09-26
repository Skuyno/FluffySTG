/datum/changeling_genetic_module/passive/anaerobic_reservoir
	id = "matrix_anaerobic_reservoir"
	passive_effects = list(
		"max_stamina_add" = 40,
		"stamina_use_mult" = 0.9,
	)

	COOLDOWN_DECLARE(surge_cooldown)

	var/mob/living/bound_host
	var/guard_amount = 0
	var/guard_feedback = FALSE

/datum/changeling_genetic_module/passive/anaerobic_reservoir/on_activate()
	. = ..()
	bind_host(get_owner_mob())
	return .

/datum/changeling_genetic_module/passive/anaerobic_reservoir/on_deactivate()
	unbind_host()
	guard_amount = 0
	guard_feedback = FALSE
	COOLDOWN_RESET(src, surge_cooldown)
	return ..()

/datum/changeling_genetic_module/passive/anaerobic_reservoir/on_owner_changed(mob/living/old_holder, mob/living/new_holder)
	. = ..()
	if(old_holder && old_holder == bound_host)
			unbind_host()
	if(new_holder)
			bind_host(new_holder)
	else
			guard_amount = 0
			guard_feedback = FALSE

/datum/changeling_genetic_module/passive/anaerobic_reservoir/on_tick(seconds_between_ticks)
	. = ..()
	try_surge()

/datum/changeling_genetic_module/passive/anaerobic_reservoir/proc/bind_host(mob/living/new_holder)
	if(bound_host == new_holder)
		return
	unbind_host()
	if(!is_active() || !isliving(new_holder))
		return
	register_module_signal(new_holder, COMSIG_LIVING_ADJUST_STAMINA_DAMAGE, PROC_REF(on_adjust_stamina_damage))
	bound_host = new_holder

/datum/changeling_genetic_module/passive/anaerobic_reservoir/proc/unbind_host()
	if(!bound_host)
		return
	unregister_module_signal(bound_host, COMSIG_LIVING_ADJUST_STAMINA_DAMAGE)
	bound_host = null

#define ANAEROBIC_RESERVOIR_TRIGGER_MARGIN 15
#define ANAEROBIC_RESERVOIR_STAMINA_RESTORE 35
#define ANAEROBIC_RESERVOIR_GUARD_AMOUNT 12
#define ANAEROBIC_RESERVOIR_COOLDOWN (20 SECONDS)

/datum/changeling_genetic_module/passive/anaerobic_reservoir/proc/try_surge()
	if(!is_active())
		return
	var/mob/living/living_owner = bound_host || get_owner_mob()
	if(!isliving(living_owner) || living_owner.stat == DEAD)
		return
	bind_host(living_owner)
	if(!COOLDOWN_FINISHED(src, surge_cooldown))
		return
	var/threshold = max(0, living_owner.max_stamina - ANAEROBIC_RESERVOIR_TRIGGER_MARGIN)
	if(living_owner.staminaloss < threshold)
		return
	var/recovered = living_owner.adjustStaminaLoss(-ANAEROBIC_RESERVOIR_STAMINA_RESTORE)
	if(recovered <= 0)
		return
	guard_amount = ANAEROBIC_RESERVOIR_GUARD_AMOUNT
	guard_feedback = FALSE
	to_chat(living_owner, span_changeling("Our anaerobic reservoir vents, flooding our muscles and bracing for the next blow."))
	COOLDOWN_START(src, surge_cooldown, ANAEROBIC_RESERVOIR_COOLDOWN)

/datum/changeling_genetic_module/passive/anaerobic_reservoir/proc/on_adjust_stamina_damage(mob/living/source, damage_type, amount, forced)
	SIGNAL_HANDLER
	if(!is_active() || source != bound_host)
		return NONE
	if(amount <= 0 || guard_amount <= 0)
		return NONE
	var/absorbed = min(guard_amount, amount)
	if(absorbed <= 0)
		return NONE
	guard_amount -= absorbed
	if(!guard_feedback && source.stat == CONSCIOUS)
		to_chat(source, span_changeling("Redundant oxygen sacs bulge, diffusing the strike."))
		guard_feedback = TRUE
	var/remaining = amount - absorbed
	if(remaining <= 0)
		return COMPONENT_IGNORE_CHANGE
	source.adjustStaminaLoss(remaining, forced = forced)
	return COMPONENT_IGNORE_CHANGE

#undef ANAEROBIC_RESERVOIR_TRIGGER_MARGIN
#undef ANAEROBIC_RESERVOIR_STAMINA_RESTORE
#undef ANAEROBIC_RESERVOIR_GUARD_AMOUNT
#undef ANAEROBIC_RESERVOIR_COOLDOWN

/datum/changeling_genetic_module/upgrade/echo_cascade
	id = "matrix_echo_cascade"
	passive_effects = list()

	var/list/pending_timers = list()

/datum/changeling_genetic_module/upgrade/echo_cascade/on_deactivate()
	clear_timers()
	return ..()

/datum/changeling_genetic_module/upgrade/echo_cascade/proc/schedule_resonant_echo(mob/living/user, range, confusion_mult)
	if(!is_active() || !istype(user))
		return
	var/id_one = addtimer(CALLBACK(src, PROC_REF(perform_resonant_echo), user, range, confusion_mult, 1), 1.2 SECONDS, TIMER_STOPPABLE)
	var/id_two = addtimer(CALLBACK(src, PROC_REF(perform_resonant_echo), user, max(range - 1, 0), confusion_mult, 2), 2.4 SECONDS, TIMER_STOPPABLE)
	if(id_one)
		pending_timers += id_one
	if(id_two)
		pending_timers += id_two

/datum/changeling_genetic_module/upgrade/echo_cascade/proc/perform_resonant_echo(mob/living/user, range, confusion_mult, echo_index)
	if(!is_active() || !istype(user) || user.stat == DEAD)
		return
	var/turf/user_turf = get_turf(user)
	if(user_turf)
		playsound(user_turf, 'sound/effects/screech.ogg', 40, TRUE)
	var/confusion = round(24 SECONDS * confusion_mult / max(echo_index, 1))
	var/jitter = round(120 SECONDS * confusion_mult / max(echo_index, 1))
	for(var/mob/living/target in get_hearers_in_view(max(range, 0), user))
		if(target == user || IS_CHANGELING(target))
			continue
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			C.adjust_confusion(confusion)
			C.set_jitter_if_lower(jitter)
			C.apply_status_effect(/datum/status_effect/dazed, 2 SECONDS)
		else if(issilicon(target))
			target.Paralyze(10)

/datum/changeling_genetic_module/upgrade/echo_cascade/proc/schedule_dissonant_echo(mob/living/user, heavy_range, light_range)
	if(!is_active() || !istype(user))
		return
	var/id_one = addtimer(CALLBACK(src, PROC_REF(perform_dissonant_echo), user, heavy_range, light_range, 1), 1.2 SECONDS, TIMER_STOPPABLE)
	var/id_two = addtimer(CALLBACK(src, PROC_REF(perform_dissonant_echo), user, max(heavy_range - 1, 0), max(light_range - 1, 0), 2), 2.4 SECONDS, TIMER_STOPPABLE)
	if(id_one)
		pending_timers += id_one
	if(id_two)
		pending_timers += id_two

/datum/changeling_genetic_module/upgrade/echo_cascade/proc/perform_dissonant_echo(mob/living/user, heavy_range, light_range, echo_index)
	if(!is_active() || !istype(user) || user.stat == DEAD)
		return
	var/turf/user_turf = get_turf(user)
	if(user_turf)
		playsound(user_turf, 'sound/items/weapons/flash.ogg', 45, TRUE)
	empulse(user_turf, max(heavy_range, 0), max(light_range, 0), 1)
	for(var/mob/living/target in oview(max(light_range, 0), user))
		if(target == user || IS_CHANGELING(target))
			continue
		if(issilicon(target))
			target.Paralyze(10)
		else
			target.adjustStaminaLoss(16)

/datum/changeling_genetic_module/upgrade/echo_cascade/proc/clear_timers()
	if(!LAZYLEN(pending_timers))
		return
	for(var/timer_id in pending_timers)
		deltimer(timer_id)
	pending_timers.Cut()

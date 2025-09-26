/datum/changeling_genetic_module/upgrade/adrenal_spike
	id = "matrix_adrenal_spike"
	passive_effects = list()

	var/matrix_adrenal_spike_shockwave_timer

/datum/changeling_genetic_module/upgrade/adrenal_spike/on_deactivate()
	if(matrix_adrenal_spike_shockwave_timer)
		deltimer(matrix_adrenal_spike_shockwave_timer)
		matrix_adrenal_spike_shockwave_timer = null
	var/mob/living/living_owner = get_owner_mob()
	living_owner?.remove_status_effect(/datum/status_effect/changeling_adrenal_overdrive)
	return ..()

/datum/changeling_genetic_module/upgrade/adrenal_spike/on_owner_changed(mob/living/old_holder, mob/living/new_holder)
	. = ..()
	if(!new_holder && old_holder)
		old_holder.remove_status_effect(/datum/status_effect/changeling_adrenal_overdrive)
	if(!new_holder && matrix_adrenal_spike_shockwave_timer)
		deltimer(matrix_adrenal_spike_shockwave_timer)
		matrix_adrenal_spike_shockwave_timer = null

/datum/changeling_genetic_module/upgrade/adrenal_spike/proc/apply_overdrive(mob/living/carbon/user)
	if(!is_active() || !istype(user))
		return
	user.apply_status_effect(/datum/status_effect/changeling_adrenal_overdrive, owner)

/datum/changeling_genetic_module/upgrade/adrenal_spike/proc/schedule_shockwave(mob/living/carbon/user)
	if(!is_active() || !istype(user))
		return
	if(matrix_adrenal_spike_shockwave_timer)
		deltimer(matrix_adrenal_spike_shockwave_timer)
	matrix_adrenal_spike_shockwave_timer = addtimer(CALLBACK(src, PROC_REF(trigger_shockwave), user), 2 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/changeling_genetic_module/upgrade/adrenal_spike/proc/trigger_shockwave(mob/living/carbon/user)
	matrix_adrenal_spike_shockwave_timer = null
	if(!is_active() || !istype(user) || user.stat == DEAD)
		return
	var/turf/user_turf = get_turf(user)
	if(user_turf)
		playsound(user_turf, 'sound/effects/bang.ogg', 50, TRUE)
	user.visible_message(
		span_warning("[user] releases a concussive chemical shockwave!"),
		span_changeling("We vent a surge of volatile chemicals in a stunning wave."),
	)
	for(var/mob/living/nearby in oview(2, user))
		if(nearby == user || nearby.stat == DEAD)
			continue
		nearby.Knockdown(3 SECONDS)
		nearby.adjustStaminaLoss(20)

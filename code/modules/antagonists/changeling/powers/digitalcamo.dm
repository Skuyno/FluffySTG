/datum/action/changeling/digitalcamo
	name = "Digital Camouflage"
	desc = "By evolving the ability to distort our form and proportions, we defeat common algorithms used to detect lifeforms on cameras."
	helptext = "We cannot be tracked by camera or seen by AI units while using this skill. However, humans looking at us will find us... uncanny."
	button_icon_state = "digital_camo"
	dna_cost = 1
	active = FALSE

//Prevents AIs tracking you but makes you easily detectable to the human-eye.
/datum/action/changeling/digitalcamo/sting_action(mob/user)
	..()
	if(active)
		to_chat(user, span_notice("We return to normal."))
		user.RemoveElement(/datum/element/digitalcamo)
		active = FALSE
	else
		to_chat(user, span_notice("We distort our form to hide from the AI."))
		user.AddElement(/datum/element/digitalcamo)
		active = TRUE
	var/datum/antagonist/changeling/changeling_data = IS_CHANGELING(user)
	changeling_data?.ensure_matrix_feathered_veil_status()
	return TRUE

/datum/action/changeling/digitalcamo/Remove(mob/user)
	user.RemoveElement(/datum/element/digitalcamo)
	var/datum/antagonist/changeling/changeling_data = IS_CHANGELING(user)
	changeling_data?.remove_matrix_feathered_veil_status()
	..()

/datum/status_effect/changeling_feathered_veil
	id = "changeling_feathered_veil"
	status_type = STATUS_EFFECT_UNIQUE
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = null

	/// The changeling datum maintaining this effect.
	var/datum/antagonist/changeling/changeling_source
	/// The digital camo action powering the effect.
	var/datum/action/changeling/digitalcamo/camo_source
	/// Cached alpha to restore when the invisibility burst ends.
	var/original_alpha = 255
	/// When we can next trigger another invisibility burst (world.time deciseconds).
	var/next_burst_allowed = 0
	/// Timer tracking the fade-out of a burst.
	var/tmp/current_burst_timer
	/// How long we remain fully invisible after moving.
	var/burst_duration = 1.5 SECONDS
	/// Cooldown between bursts while continuously moving.
	var/burst_cooldown = 1 SECONDS
	/// How transparent we become during the burst.
	var/burst_alpha = 15

/datum/status_effect/changeling_feathered_veil/on_creation(mob/living/new_owner, datum/antagonist/changeling/changeling_data, datum/action/changeling/digitalcamo/camo)
	changeling_source = changeling_data
	camo_source = camo
	original_alpha = new_owner?.alpha || original_alpha
	return ..()

/datum/status_effect/changeling_feathered_veil/on_apply()
	if(!owner)
		return FALSE
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_owner_moved))
	RegisterSignal(owner, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(on_owner_position_changed))
	update_sources(changeling_source, camo_source)
	return TRUE

/datum/status_effect/changeling_feathered_veil/on_remove()
	end_invisibility_burst(TRUE)
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_SET_BODY_POSITION))
	changeling_source = null
	camo_source = null

/datum/status_effect/changeling_feathered_veil/proc/update_sources(datum/antagonist/changeling/changeling_data, datum/action/changeling/digitalcamo/camo)
	if(changeling_data)
		changeling_source = changeling_data
	if(camo)
		camo_source = camo
	if(!changeling_source?.matrix_feathered_veil_active || !camo_source?.active || QDELETED(owner))
		qdel(src)
		return
	original_alpha = owner.alpha

/datum/status_effect/changeling_feathered_veil/proc/on_owner_moved(atom/movable/source, atom/oldloc, atom/newloc)
	SIGNAL_HANDLER
	if(owner?.stat != CONSCIOUS)
		return
	trigger_invisibility_burst()

/datum/status_effect/changeling_feathered_veil/proc/on_owner_position_changed(mob/living/source, new_position)
	SIGNAL_HANDLER
	if(new_position != LYING_DOWN)
		return
	// Cancel any pending burst if we drop prone, as we're no longer sprinting.
	end_invisibility_burst()

/datum/status_effect/changeling_feathered_veil/proc/trigger_invisibility_burst()
	if(world.time < next_burst_allowed)
		return
	if(!changeling_source?.matrix_feathered_veil_active || !camo_source?.active)
		qdel(src)
		return
	next_burst_allowed = world.time + burst_cooldown
	original_alpha = owner.alpha
	owner.alpha = burst_alpha
	if(current_burst_timer)
		deltimer(current_burst_timer)
	current_burst_timer = addtimer(CALLBACK(src, PROC_REF(end_invisibility_burst)), burst_duration, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/status_effect/changeling_feathered_veil/proc/end_invisibility_burst(force_reset = FALSE)
	if(current_burst_timer)
		deltimer(current_burst_timer)
		current_burst_timer = null
	if(!owner)
		return
	if(force_reset || owner.alpha < original_alpha)
		owner.alpha = original_alpha

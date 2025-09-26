/datum/changeling_genetic_module/passive/abyssal_slip
	id = "matrix_abyssal_slip"
	passive_effects = list(
		"move_speed_slowdown" = -0.05,
	)

	var/mob/living/bound_host

/datum/changeling_genetic_module/passive/abyssal_slip/on_activate()
	. = ..()
	bind_host(get_owner_mob())
	return .

/datum/changeling_genetic_module/passive/abyssal_slip/on_deactivate()
	unbind_host()
	remove_traits()
	return ..()

/datum/changeling_genetic_module/passive/abyssal_slip/on_owner_changed(mob/living/old_holder, mob/living/new_holder)
	. = ..()
	if(old_holder && old_holder == bound_host)
		unbind_host()
	if(new_holder)
		bind_host(new_holder)
	else
		remove_traits()

/datum/changeling_genetic_module/passive/abyssal_slip/proc/bind_host(mob/living/new_holder)
	if(bound_host == new_holder)
		return
	unbind_host()
	if(!is_active() || !isliving(new_holder))
		return
	register_module_signal(new_holder, COMSIG_MOVABLE_MOVED, PROC_REF(on_host_moved))
	bound_host = new_holder
	apply_traits()

/datum/changeling_genetic_module/passive/abyssal_slip/proc/unbind_host()
	if(!bound_host)
		return
	unregister_module_signal(bound_host, COMSIG_MOVABLE_MOVED)
	bound_host = null

/datum/changeling_genetic_module/passive/abyssal_slip/proc/apply_traits()
	var/mob/living/living_owner = get_owner_mob()
	if(!is_active() || !living_owner)
		return
	living_owner.add_traits(list(TRAIT_SILENT_FOOTSTEPS, TRAIT_LIGHT_STEP), CHANGELING_TRAIT)

/datum/changeling_genetic_module/passive/abyssal_slip/proc/remove_traits()
	var/mob/living/living_owner = get_owner_mob()
	if(!living_owner)
		return
	living_owner.remove_traits(list(TRAIT_SILENT_FOOTSTEPS, TRAIT_LIGHT_STEP), CHANGELING_TRAIT)

/datum/changeling_genetic_module/passive/abyssal_slip/proc/on_host_moved(atom/movable/source, atom/old_loc, move_dir, forced, list/atom/old_locs)
	SIGNAL_HANDLER
	if(!is_active() || source != bound_host)
		return
	var/mob/living/living_owner = bound_host
	var/datum/status_effect/darkness_adapted/adaptation = living_owner?.has_status_effect(/datum/status_effect/darkness_adapted)
	adaptation?.update_invis()

/// Manages genetic matrix state and effects for a changeling antagonist.
///
/// Responsible for tracking module activation, dispatching matrix-specific
/// signals, and applying or clearing the various passive and active effects
/// granted by the genetic matrix system. Keeps matrix data out of the core
/// antagonist datum so that it can focus on higher level gameplay flow.
/datum/changeling_matrix_manager
	/// Parent changeling that owns this manager.
	var/datum/antagonist/changeling/changeling
	/// Cached identifiers for currently active genetic matrix modules.
	var/list/current_matrix_module_ids = list()
	/// Whether the predatory howl matrix module is active.
	var/matrix_predatory_howl_active = FALSE
	/// Whether the symbiotic overgrowth matrix module is active.
	var/matrix_symbiotic_overgrowth_active = FALSE
	/// Whether the predator sinew matrix module is active.
	var/matrix_predator_sinew_active = FALSE
	/// Whether the void carapace matrix module is active.
	var/matrix_void_carapace_active = FALSE
	/// Whether the adrenal spike matrix module is active.
	var/matrix_adrenal_spike_active = FALSE
	/// Whether the aether drake mantle matrix module is active.
	var/matrix_aether_drake_active = FALSE
	/// Whether the graviton ripsaw matrix module is active.
	var/matrix_graviton_ripsaw_active = FALSE
	/// Cooldown tracker for graviton ripsaw's tether launch.
	COOLDOWN_DECLARE(matrix_graviton_ripsaw_grapple_cooldown)
	/// Whether the hemolytic bloom matrix module is active.
	var/matrix_hemolytic_bloom_active = FALSE
	/// Whether the echo cascade matrix module is active.
	var/matrix_echo_cascade_active = FALSE
	/// Whether the abyssal slip matrix module is active.
	var/matrix_abyssal_slip_active = FALSE
	/// Whether the crystalline buffer matrix module is active.
	var/matrix_crystalline_buffer_active = FALSE
	/// Whether the anaerobic reservoir matrix module is active.
	var/matrix_anaerobic_reservoir_active = FALSE
	/// Temporary stamina cushion granted by the anaerobic reservoir surge.
	var/matrix_anaerobic_reservoir_guard = 0
	/// Whether we've already messaged about the current anaerobic guard soaking a hit.
	var/matrix_anaerobic_reservoir_guard_feedback = FALSE
	/// Cooldown tracker for anaerobic reservoir surges.
	COOLDOWN_DECLARE(matrix_anaerobic_reservoir_cooldown)
	/// Whether the ashen pump matrix module is active.
	var/matrix_ashen_pump_active = FALSE
	/// Whether the neuro sap matrix module is active.
	var/matrix_neuro_sap_active = FALSE
	/// Whether the neuro sap chemical bonus is currently applied.
	var/matrix_neuro_sap_bonus_applied = FALSE
	/// Whether the chitin courier matrix module is active.
	var/matrix_chitin_courier_active = FALSE
	/// Whether the spore node matrix module is active.
	var/matrix_spore_node_active = FALSE
	/// Mob currently registered for predator's sinew hit hooks.
	var/mob/living/matrix_predator_sinew_bound_mob
	/// Mob currently registered for anaerobic reservoir stamina interception.
	var/mob/living/matrix_anaerobic_reservoir_bound_mob
	/// Timer tracking a pending adrenal spike shockwave.
	var/matrix_adrenal_spike_shockwave_timer
	/// Cached mob registered for abyssal slip movement hooks.
	var/mob/living/matrix_abyssal_slip_bound_mob
	/// Whether aether drake mantle traits are currently applied.
	var/matrix_aether_drake_traits_applied = FALSE
	/// Pending timers spawned by echo cascade.
	var/list/matrix_echo_cascade_pending = list()
	/// Matrix-provided aether burst action instance.
	var/datum/action/changeling/aether_burst/matrix_aether_burst_action
	/// Matrix-provided chitin courier action instance.
	var/datum/action/changeling/chitin_courier/matrix_chitin_courier_action
	/// Matrix-provided spore node action instance.
	var/datum/action/changeling/spore_node/matrix_spore_node_action
	/// Weak reference to an active spore node structure.
	var/datum/weakref/matrix_spore_node_ref
	/// Container for a stored item from chitin courier.
	var/obj/effect/abstract/changeling_chitin_cache/matrix_chitin_courier_cache
	/// Stored item within the chitin courier cache.
	var/obj/item/matrix_chitin_courier_item
	/// Tracks corpses that have already produced a hemolytic seed.
	var/list/matrix_hemolytic_seeded = list()
	/// Aggregated matrix effects currently applied to this changeling.
	var/list/genetic_matrix_effect_cache = list()
	/// Mob currently benefiting from passive matrix effect adjustments.
	var/mob/living/matrix_passive_effects_bound_mob
	/// Cached slowdown applied by passive matrix effects.
	var/matrix_current_movespeed_slowdown = 0
	/// Cached stamina usage multiplier from passive effects.
	var/matrix_current_stamina_use_mult = 1
	/// Cached stamina regeneration multiplier from passive effects.
	var/matrix_current_stamina_regen_mult = 1
	/// Cached max stamina bonus applied by passive effects.
	var/matrix_current_max_stamina_bonus = 0
	/// Cached chemical recharge modifier from passive effects.
	var/matrix_current_chem_rate_bonus = 0
	/// Cached sting range bonus from passive effects.
	var/matrix_current_sting_range_bonus = 0
	/// Cached brute damage multiplier from passive effects.
	var/matrix_current_brute_damage_mult = 1
	/// Cached burn damage multiplier from passive effects.
	var/matrix_current_burn_damage_mult = 1


/datum/changeling_matrix_manager/New(datum/antagonist/changeling/changeling)
	. = ..()
	src.changeling = changeling

/datum/changeling_matrix_manager/Destroy()
	clear_matrix_passive_effects()
	remove_matrix_aether_burst_action()
	remove_matrix_aether_drake_traits()
	remove_matrix_chitin_courier_action()
	clear_chitin_courier_cache(drop_item = TRUE)
	remove_matrix_spore_node_action()
	clear_spore_node()
	remove_matrix_abyssal_slip_traits()
	unbind_abyssal_slip_signals()
	unbind_predator_sinew_signals()
	unbind_anaerobic_reservoir_signals()
	clear_matrix_echo_cascade_timers()
	matrix_hemolytic_seeded.Cut()
	matrix_echo_cascade_pending.Cut()
	changeling = null
	return ..()
/datum/changeling_matrix_manager/proc/apply_genetic_matrix_effects()
	var/list/active_ids = list()
	if(changeling.bio_incubator)
		var/list/incubator_ids = changeling.bio_incubator.get_active_module_ids()
		for(var/module_id in incubator_ids)
			if(isnull(module_id))
				continue
			var/id_text = changeling.bio_incubator.sanitize_module_id(module_id)
			if(isnull(id_text))
				id_text = "[module_id]"
			if(!(id_text in active_ids))
				active_ids += id_text
	current_matrix_module_ids = active_ids
	update_matrix_predatory_howl("matrix_predatory_howl" in active_ids)
	update_matrix_symbiotic_overgrowth("matrix_symbiotic_overgrowth" in active_ids)
	update_matrix_predator_sinew_effect("matrix_predator_sinew" in active_ids)
	update_matrix_void_carapace_effect("matrix_void_carapace" in active_ids)
	update_matrix_adrenal_spike_effect("matrix_adrenal_spike" in active_ids)
	update_matrix_aether_drake_effect("matrix_aether_drake_mantle" in active_ids)
	update_matrix_graviton_ripsaw_effect("matrix_graviton_ripsaw" in active_ids)
	update_matrix_hemolytic_bloom_effect("matrix_hemolytic_bloom" in active_ids)
	update_matrix_echo_cascade_effect("matrix_echo_cascade" in active_ids)
	update_matrix_abyssal_slip_effect("matrix_abyssal_slip" in active_ids)
	update_matrix_crystalline_buffer_effect("matrix_crystalline_buffer" in active_ids)
	update_matrix_anaerobic_reservoir_effect("matrix_anaerobic_reservoir" in active_ids)
	update_matrix_ashen_pump_effect("matrix_ashen_pump" in active_ids)
	update_matrix_neuro_sap_effect("matrix_neuro_sap" in active_ids)
	update_matrix_chitin_courier_effect("matrix_chitin_courier" in active_ids)
	update_matrix_spore_node_effect("matrix_spore_node" in active_ids)
	update_matrix_passive_effects(active_ids)

/datum/changeling_matrix_manager/proc/is_genetic_matrix_module_active(module_identifier)
	if(isnull(module_identifier))
		return FALSE
	var/id_text
	if(istext(module_identifier))
		id_text = module_identifier
	else if(changeling.bio_incubator)
		id_text = changeling.bio_incubator.sanitize_module_id(module_identifier)
	if(isnull(id_text))
		id_text = "[module_identifier]"
	return id_text in current_matrix_module_ids

/datum/changeling_matrix_manager/proc/update_matrix_predatory_howl(is_active)
	matrix_predatory_howl_active = !!is_active

/datum/changeling_matrix_manager/proc/update_matrix_symbiotic_overgrowth(is_active)
	matrix_symbiotic_overgrowth_active = !!is_active

/datum/changeling_matrix_manager/proc/update_matrix_predator_sinew_effect(is_active)
	matrix_predator_sinew_active = !!is_active
	if(!matrix_predator_sinew_active)
		unbind_predator_sinew_signals()
		return
	bind_predator_sinew_signals(changeling.owner?.current)

/datum/changeling_matrix_manager/proc/bind_predator_sinew_signals(mob/living/new_host)
	if(matrix_predator_sinew_bound_mob == new_host)
		return
	unbind_predator_sinew_signals()
	if(!matrix_predator_sinew_active || !isliving(new_host))
		return
	RegisterSignal(new_host, COMSIG_MOB_ITEM_ATTACK, PROC_REF(on_predator_sinew_item_attack))
	RegisterSignal(new_host, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_predator_sinew_unarmed_attack))
	matrix_predator_sinew_bound_mob = new_host

/datum/changeling_matrix_manager/proc/unbind_predator_sinew_signals()
	if(!matrix_predator_sinew_bound_mob)
		return
	UnregisterSignal(matrix_predator_sinew_bound_mob, list(COMSIG_MOB_ITEM_ATTACK, COMSIG_LIVING_UNARMED_ATTACK))
	matrix_predator_sinew_bound_mob = null

/datum/changeling_matrix_manager/proc/on_predator_sinew_item_attack(mob/living/source, mob/living/target, mob/living/user, list/modifiers, list/attack_modifiers)
	SIGNAL_HANDLER
	handle_predator_sinew_knockdown(target)

/datum/changeling_matrix_manager/proc/on_predator_sinew_unarmed_attack(mob/living/source, atom/target, proximity_flag, list/modifiers)
	SIGNAL_HANDLER
	if(isliving(target))
		handle_predator_sinew_knockdown(target)

/datum/changeling_matrix_manager/proc/handle_predator_sinew_knockdown(mob/living/target)
	if(!matrix_predator_sinew_active)
		return
	var/mob/living/carbon/user = changeling.owner?.current
	if(!istype(user) || user != matrix_predator_sinew_bound_mob)
		return
	var/datum/action/changeling/strained_muscles/muscles = changeling.get_changeling_power_instance(/datum/action/changeling/strained_muscles)
	if(!muscles?.active)
		return
	if(user.move_intent != MOVE_INTENT_RUN || !user.combat_mode)
		return
	if(!istype(target) || target == user || target.stat == DEAD)
		return
var/stamina_cost = 12
	if(user.staminaloss + stamina_cost >= user.max_stamina)
		return
	user.adjustStaminaLoss(stamina_cost)
	target.Knockdown(2 SECONDS)
	target.visible_message(
		span_danger("[target] is hammered off balance by [user]'s driving strike!"),
		span_userdanger("A brutal shoulder slam knocks you sprawling!"),
		span_hear("You hear a heavy impact and a body hitting the ground."),
	)

/datum/changeling_matrix_manager/proc/update_matrix_void_carapace_effect(is_active)
	matrix_void_carapace_active = !!is_active
	var/datum/action/changeling/void_adaption/adaption = changeling.get_changeling_power_instance(/datum/action/changeling/void_adaption)
	adaption?.sync_module_state(src)

/datum/changeling_matrix_manager/proc/update_matrix_adrenal_spike_effect(is_active)
	matrix_adrenal_spike_active = !!is_active
	if(!matrix_adrenal_spike_active)
		if(matrix_adrenal_spike_shockwave_timer)
			deltimer(matrix_adrenal_spike_shockwave_timer)
			matrix_adrenal_spike_shockwave_timer = null
		changeling.owner?.current?.remove_status_effect(/datum/status_effect/changeling_adrenal_overdrive)

/datum/changeling_matrix_manager/proc/apply_matrix_adrenal_overdrive(mob/living/carbon/user)
	if(!matrix_adrenal_spike_active || !istype(user))
		return
	user.apply_status_effect(/datum/status_effect/changeling_adrenal_overdrive, src)

/datum/changeling_matrix_manager/proc/schedule_adrenal_spike_shockwave(mob/living/carbon/user)
	if(!matrix_adrenal_spike_active || !istype(user))
		return
	if(matrix_adrenal_spike_shockwave_timer)
		deltimer(matrix_adrenal_spike_shockwave_timer)
	matrix_adrenal_spike_shockwave_timer = addtimer(CALLBACK(src, PROC_REF(adrenal_spike_shockwave), user), 2 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/changeling_matrix_manager/proc/adrenal_spike_shockwave(mob/living/carbon/user)
	matrix_adrenal_spike_shockwave_timer = null
	if(!matrix_adrenal_spike_active || !istype(user) || user.stat == DEAD)
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

/datum/changeling_matrix_manager/proc/update_matrix_aether_drake_effect(is_active)
	matrix_aether_drake_active = !!is_active
	if(!matrix_aether_drake_active)
		remove_matrix_aether_burst_action()
		remove_matrix_aether_drake_traits()
		return
	ensure_matrix_aether_burst_action()
	apply_matrix_aether_drake_traits()
	var/datum/action/changeling/void_adaption/adaption = changeling.get_changeling_power_instance(/datum/action/changeling/void_adaption)
	adaption?.sync_module_state(src)

/datum/changeling_matrix_manager/proc/ensure_matrix_aether_burst_action()
	if(!matrix_aether_drake_active)
		return
	if(!matrix_aether_burst_action)
		matrix_aether_burst_action = new
	if(changeling.owner?.current)
		matrix_aether_burst_action.Grant(changeling.owner.current)

/datum/changeling_matrix_manager/proc/remove_matrix_aether_burst_action()
	if(!matrix_aether_burst_action)
		return
	if(changeling.owner?.current)
		matrix_aether_burst_action.Remove(changeling.owner.current)
	QDEL_NULL(matrix_aether_burst_action)

/datum/changeling_matrix_manager/proc/apply_matrix_aether_drake_traits()
	if(!matrix_aether_drake_active)
		return
	var/mob/living/living_owner = changeling.owner?.current
	if(!isliving(living_owner))
		return
	if(!matrix_aether_drake_traits_applied)
		living_owner.add_traits(list(TRAIT_SPACEWALK, TRAIT_FREE_HYPERSPACE_MOVEMENT), CHANGELING_TRAIT)
		matrix_aether_drake_traits_applied = TRUE

/datum/changeling_matrix_manager/proc/remove_matrix_aether_drake_traits()
	if(matrix_aether_drake_traits_applied && changeling.owner?.current)
		changeling.owner.current.remove_traits(list(TRAIT_SPACEWALK, TRAIT_FREE_HYPERSPACE_MOVEMENT), CHANGELING_TRAIT)
		matrix_aether_drake_traits_applied = FALSE

/datum/changeling_matrix_manager/proc/update_matrix_graviton_ripsaw_effect(is_active)
	matrix_graviton_ripsaw_active = !!is_active
	if(!matrix_graviton_ripsaw_active)
		COOLDOWN_RESET(src, matrix_graviton_ripsaw_grapple_cooldown)

#define GRAVITON_RIPSAW_GRAPPLE_RANGE 7
#define GRAVITON_RIPSAW_GRAPPLE_COOLDOWN (2 SECONDS)

/datum/changeling_matrix_manager/proc/try_matrix_graviton_ripsaw_grapple(atom/grapple_target, mob/living/user)
	if(!matrix_graviton_ripsaw_active || changeling.owner?.current != user)
		return NONE
	if(!istype(user))
		return ITEM_INTERACT_BLOCKING
	if(user.throwing)
		user.balloon_alert(user, "mid-flight!")
		return ITEM_INTERACT_BLOCKING
	if(user.buckled || user.anchored)
		user.balloon_alert(user, "stuck!")
		return ITEM_INTERACT_BLOCKING
	if(!COOLDOWN_FINISHED(src, matrix_graviton_ripsaw_grapple_cooldown))
		user.balloon_alert(user, "tendons recovering!")
		return ITEM_INTERACT_BLOCKING
	var/turf/user_turf = get_turf(user)
	var/turf/target_turf = get_turf(grapple_target)
	if(!user_turf || !target_turf)
		return ITEM_INTERACT_BLOCKING
	var/dist = get_dist(user_turf, target_turf)
	if(dist <= 0)
		user.balloon_alert(user, "need anchor!")
		return ITEM_INTERACT_BLOCKING
	if(dist == -1 || dist > GRAVITON_RIPSAW_GRAPPLE_RANGE)
		user.balloon_alert(user, "out of reach!")
		return ITEM_INTERACT_BLOCKING
	var/list/path = get_line(user_turf, target_turf)
	var/turf/destination = user_turf
	var/steps = 0
	for(var/i = 2, i <= length(path), i++)
		var/turf/step = path[i]
		if(!istype(step))
			break
		steps++
		if(steps > GRAVITON_RIPSAW_GRAPPLE_RANGE)
			break
		if(step.is_blocked_turf(TRUE, source_atom = user))
			break
		destination = step
	if(destination == user_turf)
		user.balloon_alert(user, "no clear path!")
		return ITEM_INTERACT_BLOCKING
	var/distance_to_destination = clamp(get_dist(user_turf, destination), 1, GRAVITON_RIPSAW_GRAPPLE_RANGE)
	COOLDOWN_START(src, matrix_graviton_ripsaw_grapple_cooldown, GRAVITON_RIPSAW_GRAPPLE_COOLDOWN)
	user.setDir(get_dir(user_turf, destination))
	user.Beam(
		destination,
		icon_state = "zipline_hook",
		time = 0.5 SECONDS,
		emissive = FALSE,
		maxdistance = GRAVITON_RIPSAW_GRAPPLE_RANGE,
		layer = BELOW_MOB_LAYER
	)
	playsound(user, 'sound/effects/splat.ogg', 40, TRUE)
	user.throw_at(destination, distance_to_destination, 1, user, spin = FALSE, gentle = TRUE)
	return ITEM_INTERACT_SUCCESS

#undef GRAVITON_RIPSAW_GRAPPLE_RANGE
#undef GRAVITON_RIPSAW_GRAPPLE_COOLDOWN

/datum/changeling_matrix_manager/proc/update_matrix_hemolytic_bloom_effect(is_active)
	matrix_hemolytic_bloom_active = !!is_active
	if(!matrix_hemolytic_bloom_active)
		matrix_hemolytic_seeded.Cut()

/datum/changeling_matrix_manager/proc/update_matrix_echo_cascade_effect(is_active)
	matrix_echo_cascade_active = !!is_active
	if(!matrix_echo_cascade_active)
		clear_matrix_echo_cascade_timers()

/datum/changeling_matrix_manager/proc/clear_matrix_echo_cascade_timers()
	if(!LAZYLEN(matrix_echo_cascade_pending))
		return
	for(var/timer_id in matrix_echo_cascade_pending)
		deltimer(timer_id)
	matrix_echo_cascade_pending.Cut()

/datum/changeling_matrix_manager/proc/update_matrix_abyssal_slip_effect(is_active)
	matrix_abyssal_slip_active = !!is_active
	if(!matrix_abyssal_slip_active)
		remove_matrix_abyssal_slip_traits()
		unbind_abyssal_slip_signals()
		return
	apply_matrix_abyssal_slip_traits()
	bind_abyssal_slip_signals(changeling.owner?.current)

/datum/changeling_matrix_manager/proc/apply_matrix_abyssal_slip_traits()
	if(!matrix_abyssal_slip_active || !changeling.owner?.current)
		return
	changeling.owner.current.add_traits(list(TRAIT_SILENT_FOOTSTEPS, TRAIT_LIGHT_STEP), CHANGELING_TRAIT)

/datum/changeling_matrix_manager/proc/remove_matrix_abyssal_slip_traits()
	if(!changeling.owner?.current)
		return
	changeling.owner.current.remove_traits(list(TRAIT_SILENT_FOOTSTEPS, TRAIT_LIGHT_STEP), CHANGELING_TRAIT)

/datum/changeling_matrix_manager/proc/bind_abyssal_slip_signals(mob/living/new_host)
	if(matrix_abyssal_slip_bound_mob == new_host)
		return
	unbind_abyssal_slip_signals()
	if(!matrix_abyssal_slip_active || !isliving(new_host))
		return
	RegisterSignal(new_host, COMSIG_MOVABLE_MOVED, PROC_REF(on_abyssal_slip_moved))
	matrix_abyssal_slip_bound_mob = new_host

/datum/changeling_matrix_manager/proc/unbind_abyssal_slip_signals()
	if(!matrix_abyssal_slip_bound_mob)
		return
	UnregisterSignal(matrix_abyssal_slip_bound_mob, COMSIG_MOVABLE_MOVED)
	matrix_abyssal_slip_bound_mob = null

/datum/changeling_matrix_manager/proc/on_abyssal_slip_moved(atom/movable/source, atom/old_loc, move_dir, forced, list/atom/old_locs)
	SIGNAL_HANDLER
	if(!matrix_abyssal_slip_active || source != matrix_abyssal_slip_bound_mob)
		return
	var/mob/living/living_owner = matrix_abyssal_slip_bound_mob
	if(!living_owner)
		return
	var/datum/status_effect/darkness_adapted/adaptation = living_owner.has_status_effect(/datum/status_effect/darkness_adapted)
	adaptation?.update_invis()

/datum/changeling_matrix_manager/proc/update_matrix_crystalline_buffer_effect(is_active)
	matrix_crystalline_buffer_active = !!is_active
	var/mob/living/living_owner = changeling.owner?.current
	if(!living_owner)
		return
	if(matrix_crystalline_buffer_active)
		living_owner.apply_status_effect(/datum/status_effect/changeling_crystalline_buffer, src)
	else
		living_owner.remove_status_effect(/datum/status_effect/changeling_crystalline_buffer)

/datum/changeling_matrix_manager/proc/update_matrix_anaerobic_reservoir_effect(is_active)
	matrix_anaerobic_reservoir_active = !!is_active
	if(!matrix_anaerobic_reservoir_active)
		matrix_anaerobic_reservoir_guard = 0
		matrix_anaerobic_reservoir_guard_feedback = FALSE
		COOLDOWN_RESET(src, matrix_anaerobic_reservoir_cooldown)
		unbind_anaerobic_reservoir_signals()
		return
	bind_anaerobic_reservoir_signals(changeling.owner?.current)

/datum/changeling_matrix_manager/proc/bind_anaerobic_reservoir_signals(mob/living/new_host)
	if(matrix_anaerobic_reservoir_bound_mob == new_host)
		return
	unbind_anaerobic_reservoir_signals()
	if(!matrix_anaerobic_reservoir_active || !isliving(new_host))
		return
	RegisterSignal(new_host, COMSIG_LIVING_ADJUST_STAMINA_DAMAGE, PROC_REF(on_anaerobic_reservoir_stamina_damage))
	matrix_anaerobic_reservoir_bound_mob = new_host

/datum/changeling_matrix_manager/proc/unbind_anaerobic_reservoir_signals()
	if(!matrix_anaerobic_reservoir_bound_mob)
		return
	UnregisterSignal(matrix_anaerobic_reservoir_bound_mob, COMSIG_LIVING_ADJUST_STAMINA_DAMAGE)
	matrix_anaerobic_reservoir_bound_mob = null
	matrix_anaerobic_reservoir_guard = 0
	matrix_anaerobic_reservoir_guard_feedback = FALSE

#define ANAEROBIC_RESERVOIR_TRIGGER_MARGIN 15
#define ANAEROBIC_RESERVOIR_STAMINA_RESTORE 35
#define ANAEROBIC_RESERVOIR_GUARD_AMOUNT 12
#define ANAEROBIC_RESERVOIR_COOLDOWN (20 SECONDS)

/datum/changeling_matrix_manager/proc/try_matrix_anaerobic_reservoir_surge(mob/living/living_owner)
	if(!matrix_anaerobic_reservoir_active || !isliving(living_owner))
		return
	bind_anaerobic_reservoir_signals(living_owner)
	if(living_owner.stat == DEAD)
		return
	if(!COOLDOWN_FINISHED(src, matrix_anaerobic_reservoir_cooldown))
		return
	var/threshold = max(0, living_owner.max_stamina - ANAEROBIC_RESERVOIR_TRIGGER_MARGIN)
	if(living_owner.staminaloss < threshold)
		return
	var/recovered = living_owner.adjustStaminaLoss(-ANAEROBIC_RESERVOIR_STAMINA_RESTORE)
	if(recovered <= 0)
		return
	matrix_anaerobic_reservoir_guard = ANAEROBIC_RESERVOIR_GUARD_AMOUNT
	matrix_anaerobic_reservoir_guard_feedback = FALSE
	to_chat(living_owner, span_changeling("Our anaerobic reservoir vents, flooding our muscles and bracing for the next blow."))
	COOLDOWN_START(src, matrix_anaerobic_reservoir_cooldown, ANAEROBIC_RESERVOIR_COOLDOWN)

/datum/changeling_matrix_manager/proc/on_anaerobic_reservoir_stamina_damage(mob/living/source, damage_type, amount, forced)
	SIGNAL_HANDLER
	if(!matrix_anaerobic_reservoir_active || source != matrix_anaerobic_reservoir_bound_mob)
		return NONE
	if(amount <= 0 || matrix_anaerobic_reservoir_guard <= 0)
		return NONE
	var/absorbed = min(matrix_anaerobic_reservoir_guard, amount)
	if(absorbed <= 0)
		return NONE
	matrix_anaerobic_reservoir_guard -= absorbed
	if(!matrix_anaerobic_reservoir_guard_feedback && source.stat == CONSCIOUS)
		to_chat(source, span_changeling("Redundant oxygen sacs bulge, diffusing the strike."))
		matrix_anaerobic_reservoir_guard_feedback = TRUE
	var/remaining = amount - absorbed
	if(remaining <= 0)
		return COMPONENT_IGNORE_CHANGE
	source.adjustStaminaLoss(remaining, forced = forced)
	return COMPONENT_IGNORE_CHANGE

#undef ANAEROBIC_RESERVOIR_TRIGGER_MARGIN
#undef ANAEROBIC_RESERVOIR_STAMINA_RESTORE
#undef ANAEROBIC_RESERVOIR_GUARD_AMOUNT
#undef ANAEROBIC_RESERVOIR_COOLDOWN

/datum/changeling_matrix_manager/proc/update_matrix_ashen_pump_effect(is_active)
	matrix_ashen_pump_active = !!is_active
	if(!matrix_ashen_pump_active && changeling.owner?.current)
		changeling.owner.current.remove_status_effect(/datum/status_effect/changeling_ashen_pump)

/datum/changeling_matrix_manager/proc/update_matrix_neuro_sap_effect(is_active)
	matrix_neuro_sap_active = !!is_active
	if(!matrix_neuro_sap_active && changeling.owner?.current)
		changeling.owner.current.remove_status_effect(/datum/status_effect/changeling_neuro_sap)
	remove_neuro_sap_bonus()

/datum/changeling_matrix_manager/proc/update_matrix_chitin_courier_effect(is_active)
	matrix_chitin_courier_active = !!is_active
	if(!matrix_chitin_courier_active)
		remove_matrix_chitin_courier_action()
		clear_chitin_courier_cache(drop_item = TRUE)
		return
	ensure_matrix_chitin_courier_action()

/datum/changeling_matrix_manager/proc/ensure_matrix_chitin_courier_action()
	if(!matrix_chitin_courier_active)
		return
	if(!matrix_chitin_courier_action)
		matrix_chitin_courier_action = new
	if(changeling.owner?.current)
		matrix_chitin_courier_action.Grant(changeling.owner.current)

/datum/changeling_matrix_manager/proc/remove_matrix_chitin_courier_action()
	if(!matrix_chitin_courier_action)
		return
	if(changeling.owner?.current)
		matrix_chitin_courier_action.Remove(changeling.owner.current)
	QDEL_NULL(matrix_chitin_courier_action)

/datum/changeling_matrix_manager/proc/apply_neuro_sap_bonus()
	if(matrix_neuro_sap_bonus_applied)
		return
	changeling.chem_recharge_rate += 0.8
	matrix_neuro_sap_bonus_applied = TRUE

/datum/changeling_matrix_manager/proc/remove_neuro_sap_bonus()
	if(!matrix_neuro_sap_bonus_applied)
		return
	changeling.chem_recharge_rate -= 0.8
	matrix_neuro_sap_bonus_applied = FALSE

/datum/changeling_matrix_manager/proc/schedule_resonant_echo(mob/living/user, range, confusion_mult)
	if(!matrix_echo_cascade_active || !istype(user))
		return
	var/id_one = addtimer(CALLBACK(src, PROC_REF(perform_resonant_echo), user, range, confusion_mult, 1), 1.2 SECONDS, TIMER_STOPPABLE)
	var/id_two = addtimer(CALLBACK(src, PROC_REF(perform_resonant_echo), user, max(range - 1, 0), confusion_mult, 2), 2.4 SECONDS, TIMER_STOPPABLE)
	if(id_one)
		matrix_echo_cascade_pending += id_one
	if(id_two)
		matrix_echo_cascade_pending += id_two

/datum/changeling_matrix_manager/proc/perform_resonant_echo(mob/living/user, range, confusion_mult, echo_index)
	if(!matrix_echo_cascade_active || !istype(user) || user.stat == DEAD)
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

/datum/changeling_matrix_manager/proc/schedule_dissonant_echo(mob/living/user, heavy_range, light_range)
	if(!matrix_echo_cascade_active || !istype(user))
		return
	var/id_one = addtimer(CALLBACK(src, PROC_REF(perform_dissonant_echo), user, heavy_range, light_range, 1), 1.2 SECONDS, TIMER_STOPPABLE)
	var/id_two = addtimer(CALLBACK(src, PROC_REF(perform_dissonant_echo), user, max(heavy_range - 1, 0), max(light_range - 1, 0), 2), 2.4 SECONDS, TIMER_STOPPABLE)
	if(id_one)
		matrix_echo_cascade_pending += id_one
	if(id_two)
		matrix_echo_cascade_pending += id_two

/datum/changeling_matrix_manager/proc/perform_dissonant_echo(mob/living/user, heavy_range, light_range, echo_index)
	if(!matrix_echo_cascade_active || !istype(user) || user.stat == DEAD)
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

/datum/changeling_matrix_manager/proc/handle_graviton_ripsaw_hit(atom/target, mob/living/user)
	if(!matrix_graviton_ripsaw_active || !istype(user))
		return
	if(!isliving(target))
		return
	var/mob/living/living_target = target
	if(living_target == user || living_target.stat == DEAD)
		return
	living_target.apply_status_effect(/datum/status_effect/changeling_gravitic_pull, user)

/datum/changeling_matrix_manager/proc/handle_hemolytic_bloom_hit(atom/target, mob/living/user)
	if(!matrix_hemolytic_bloom_active || !isliving(target) || !istype(user))
		return
	var/mob/living/living_target = target
	if(isliving(user))
		user.adjustBruteLoss(-1.6, forced = TRUE)
		changeling.adjust_chemicals(2)
	if(iscarbon(living_target))
		var/mob/living/carbon/C = living_target
		var/zone = BODY_ZONE_CHEST
		if(istype(user, /mob/living/carbon))
			var/mob/living/carbon/attacker = user
			zone = attacker.zone_selected || BODY_ZONE_CHEST
		var/obj/item/bodypart/part = C.get_bodypart(zone)
		if(!part)
			part = C.get_bodypart(BODY_ZONE_CHEST)
		part?.adjustBleedStacks(6, 0)
	if(living_target.stat == DEAD)
		for(var/datum/weakref/ref in matrix_hemolytic_seeded.Copy())
			var/mob/living/cached = ref?.resolve()
			if(!cached)
				matrix_hemolytic_seeded -= ref
		if(!(WEAKREF(living_target) in matrix_hemolytic_seeded))
			spawn_hemolytic_seed(living_target)

/datum/changeling_matrix_manager/proc/spawn_hemolytic_seed(mob/living/victim)
	if(!matrix_hemolytic_bloom_active || !istype(victim))
		return
	var/turf/location = get_turf(victim)
	if(!istype(location))
		return
	matrix_hemolytic_seeded += WEAKREF(victim)
	new /obj/effect/temp_visual/changeling_hemolytic_seed(location, victim, src)

/datum/changeling_matrix_manager/proc/on_gene_stim_used(mob/living/carbon/user)
	if(!matrix_ashen_pump_active || !istype(user))
		return
	user.apply_status_effect(/datum/status_effect/changeling_ashen_pump, src)
	changeling.adjust_chemicals(-3)

/datum/changeling_matrix_manager/proc/on_panacea_used(mob/living/carbon/user)
	if(!matrix_neuro_sap_active || !istype(user))
		return
	user.apply_status_effect(/datum/status_effect/changeling_neuro_sap, src)

/datum/changeling_matrix_manager/proc/update_matrix_spore_node_effect(is_active)
	matrix_spore_node_active = !!is_active
	if(!matrix_spore_node_active)
		remove_matrix_spore_node_action()
		clear_spore_node()
		return
	ensure_matrix_spore_node_action()

/datum/changeling_matrix_manager/proc/ensure_matrix_spore_node_action()
	if(!matrix_spore_node_active)
		return
	if(!matrix_spore_node_action)
		matrix_spore_node_action = new
	if(changeling.owner?.current)
		matrix_spore_node_action.Grant(changeling.owner.current)

/datum/changeling_matrix_manager/proc/remove_matrix_spore_node_action()
	if(!matrix_spore_node_action)
		return
	if(changeling.owner?.current)
		matrix_spore_node_action.Remove(changeling.owner.current)
	QDEL_NULL(matrix_spore_node_action)

/datum/changeling_matrix_manager/proc/stash_chitin_courier_item(obj/item/held_item, mob/living/user)
	if(!matrix_chitin_courier_active || !istype(held_item))
		return FALSE
	if(matrix_chitin_courier_item)
		clear_chitin_courier_cache(drop_item = TRUE)
	if(!matrix_chitin_courier_cache)
		matrix_chitin_courier_cache = new(user)
	matrix_chitin_courier_cache.forceMove(user)
	held_item.forceMove(matrix_chitin_courier_cache)
	matrix_chitin_courier_item = held_item
	user.visible_message(
		span_warning("[user] flexes [user.p_their()] arm as flesh folds swallow [held_item]!"),
		span_changeling("We thread [held_item] into a hidden courier sac."),
	)
	return TRUE

/datum/changeling_matrix_manager/proc/retrieve_chitin_courier_item(mob/living/user)
	if(!matrix_chitin_courier_item)
		return FALSE
	var/obj/item/stored = matrix_chitin_courier_item
	matrix_chitin_courier_item = null
	if(!istype(user))
		stored.forceMove(get_turf(stored))
		clear_chitin_courier_cache()
		return TRUE
	if(!user.put_in_hands(stored))
		stored.forceMove(get_turf(user))
	user.visible_message(
		span_warning("[user] flexes and extrudes [stored] from beneath [user.p_their()] skin!"),
		span_changeling("We regurgitate our cached [stored]."),
	)
	clear_chitin_courier_cache()
	return TRUE

/datum/changeling_matrix_manager/proc/clear_chitin_courier_cache(drop_item = FALSE)
	if(matrix_chitin_courier_item)
		var/obj/item/stored = matrix_chitin_courier_item
		matrix_chitin_courier_item = null
		if(drop_item)
			var/turf/drop_loc = get_turf(changeling.owner?.current) || get_turf(stored)
			stored.forceMove(drop_loc)
		else
			stored.forceMove(get_turf(stored))
	QDEL_NULL(matrix_chitin_courier_cache)

/datum/changeling_matrix_manager/proc/place_spore_node(turf/location, mob/living/user)
	if(!matrix_spore_node_active || !istype(location))
		return FALSE
	clear_spore_node()
	var/obj/structure/changeling_spore_node/node = new(location, src)
	matrix_spore_node_ref = WEAKREF(node)
	if(istype(user))
		user.visible_message(
			span_warning("[user] plants a throbbing spore node that quickly roots into the floor!"),
			span_changeling("We seed a pheromone node to watch this space."),
		)
	return TRUE

/datum/changeling_matrix_manager/proc/detonate_spore_node(mob/living/user)
	var/obj/structure/changeling_spore_node/node = matrix_spore_node_ref?.resolve()
	if(!node)
		return FALSE
	node.detonate(user)
	return TRUE

/datum/changeling_matrix_manager/proc/spore_node_detonated(mob/living/user)
	matrix_spore_node_ref = null
	if(!istype(user))
		return
	to_chat(user, span_changeling("Our spore node ruptures, flooding the area with grasping spores."))

/datum/changeling_matrix_manager/proc/clear_spore_node(obj/structure/changeling_spore_node/ignore)
	var/obj/structure/changeling_spore_node/current = matrix_spore_node_ref?.resolve()
	if(current && (!ignore || ignore != current))
		qdel(current)
	matrix_spore_node_ref = null

/datum/changeling_matrix_manager/proc/clear_matrix_passive_effects()
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

/datum/changeling_matrix_manager/proc/update_matrix_passive_effects(list/active_ids)
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
	if(islist(active_ids))
		for(var/module_id in active_ids)
			var/list/recipe = GLOB.changeling_genetic_matrix_recipes[module_id]
			if(!islist(recipe))
				continue
			var/list/module_data = recipe["module"]
			if(!islist(module_data))
				continue
			var/list/module_effects = module_data["effects"]
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

/datum/changeling_matrix_manager/proc/apply_matrix_passive_effect_totals(list/totals)
	clear_matrix_passive_effects()
	if(!islist(totals))
		totals = changeling_get_default_matrix_effects()
	var/mob/living/living_owner = changeling.owner?.current
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

/datum/changeling_matrix_manager/proc/get_genetic_matrix_effect(effect_key, default_value)
	if(!islist(genetic_matrix_effect_cache))
		return default_value
	var/result = genetic_matrix_effect_cache[effect_key]
	if(isnull(result))
		return default_value
	return result


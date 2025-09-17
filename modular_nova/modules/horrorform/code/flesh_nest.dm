#define FLESH_NEST_AURA_RANGE 4
#define FLESH_NEST_HEAL_AMOUNT 4
#define FLESH_NEST_ABSENCE_LIMIT (1 MINUTES)
#define FLESH_NEST_SLIP_COOLDOWN (4 SECONDS)

#define FLESH_NEST_DESTROY_NONE 0
#define FLESH_NEST_DESTROY_RECLAIMED 1
#define FLESH_NEST_DESTROY_DECAY 2

/obj/structure/destructible/horrorform/flesh_nest
	name = "flesh nest"
	desc = "A pulsating bundle of sinew anchored to the floor by ropey tendrils."
	icon = 'icons/obj/structures/cult.dmi'
	icon_state = "pylon"
	color = "#7a1f1f"
	density = FALSE
	anchored = TRUE
	max_integrity = 180
	resistance_flags = FLAMMABLE
	light_range = 1.5
	light_power = 0.4
	light_color = COLOR_BLOOD
	obj_flags = CAN_BE_HIT
	var/datum/weakref/owner_ref
	var/last_owner_presence = 0
	var/list/afflicted_mobs = list()
	var/destroy_context = FLESH_NEST_DESTROY_NONE

/obj/structure/destructible/horrorform/flesh_nest/Initialize(mapload, mob/living/simple_animal/hostile/true_changeling/creator)
	. = ..()
	if(creator)
		owner_ref = WEAKREF(creator)
		creator.active_nest = src
	last_owner_presence = world.time
	set_light(1.5, 0.4, COLOR_BLOOD)
	playsound(src, 'sound/effects/blob/attackblob.ogg', 40, TRUE)
	new /obj/effect/temp_visual/blood_drop_rising(get_turf(src))
	START_PROCESSING(SSfastprocess, src)
	animate(src, transform = matrix() * 1.05, time = 8, easing = SINE_EASING)
	animate(transform = matrix(), time = 8, easing = SINE_EASING, loop = -1)
	return .

/obj/structure/destructible/horrorform/flesh_nest/Destroy(force)
	STOP_PROCESSING(SSfastprocess, src)
	for(var/mob/living/target as anything in afflicted_mobs)
		if(!QDELETED(target))
			target.remove_status_effect(/datum/status_effect/grouped/flesh_nest, REF(src))
	afflicted_mobs.Cut()
	var/mob/living/simple_animal/hostile/true_changeling/owner = owner_ref?.resolve()
	if(owner && owner.active_nest == src)
		owner.active_nest = null
	switch(destroy_context)
		if(FLESH_NEST_DESTROY_RECLAIMED)
			if(owner)
				to_chat(owner, span_notice("We reclaim the biomass of our nest."))
		if(FLESH_NEST_DESTROY_DECAY)
			;
		else
			visible_message(span_warning("[src] is torn apart and its gore splatters across the floor!"), \
				span_userdanger("Our flesh nest has been destroyed!"))
			playsound(src, 'sound/effects/splat.ogg', 60, TRUE)
			if(owner)
				to_chat(owner, span_userdanger("Our flesh nest has been destroyed!"))
	new /obj/effect/temp_visual/blood_drop_falling(get_turf(src))
	owner_ref = null
	return ..()

/obj/structure/destructible/horrorform/flesh_nest/process()
	var/mob/living/simple_animal/hostile/true_changeling/owner = owner_ref?.resolve()
	if(!owner || QDELETED(owner))
		if(destroy_context == FLESH_NEST_DESTROY_NONE)
			destroy_context = FLESH_NEST_DESTROY_DECAY
			visible_message(span_warning("[src] shrivels without its master!"))
		qdel(src)
		return
	var/turf/owner_turf = get_turf(owner)
	var/owner_near = FALSE
	if(owner_turf && owner_turf.z == z && owner.stat != DEAD && get_dist(owner, src) <= FLESH_NEST_AURA_RANGE)
		owner_near = TRUE
		last_owner_presence = world.time
		var/need_update = FALSE
		need_update |= owner.adjustBruteLoss(-FLESH_NEST_HEAL_AMOUNT, updating_health = FALSE)
		need_update |= owner.adjustFireLoss(-FLESH_NEST_HEAL_AMOUNT, updating_health = FALSE)
		need_update |= owner.adjustStaminaLoss(-10, updating_stamina = FALSE)
		if(need_update)
			owner.updatehealth()
		if(prob(25))
			new /obj/effect/temp_visual/heal(owner_turf, COLOR_BLOOD)
			playsound(owner, 'sound/effects/blob/attackblob.ogg', 20, TRUE)
	if(!owner_near && world.time - last_owner_presence > FLESH_NEST_ABSENCE_LIMIT)
		decay(owner)
		return
	var/list/current_targets = list()
	for(var/mob/living/target in range(FLESH_NEST_AURA_RANGE, src))
		if(target == owner)
			continue
		if(owner && faction_check(owner.faction, target.faction))
			continue
		target.apply_status_effect(/datum/status_effect/grouped/flesh_nest, REF(src))
		current_targets[target] = TRUE
		afflicted_mobs[target] = TRUE
	for(var/mob/living/target as anything in afflicted_mobs.Copy())
		if(current_targets[target])
			continue
		if(!QDELETED(target))
			target.remove_status_effect(/datum/status_effect/grouped/flesh_nest, REF(src))
		afflicted_mobs -= target

/obj/structure/destructible/horrorform/flesh_nest/fire_act(exposed_temperature, exposed_volume)
	. = ..()
	if(exposed_temperature >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		take_damage(8, BURN, FIRE)
		if(prob(20))
			visible_message(span_warning("[src] chars and cracks under the heat!"))
	return .

/obj/structure/destructible/horrorform/flesh_nest/proc/dissolve(mob/living/simple_animal/hostile/true_changeling/reclaimer)
	if(QDELETED(src) || destroy_context != FLESH_NEST_DESTROY_NONE)
		return
	destroy_context = FLESH_NEST_DESTROY_RECLAIMED
	if(reclaimer)
		visible_message(span_notice("[src] sloughs apart and is reabsorbed by [reclaimer]!"), \
			span_notice("We reclaim our nest's mass."))
	else
		visible_message(span_notice("[src] collapses into a pool of gore."))
	playsound(src, 'sound/effects/splat.ogg', 50, TRUE)
	qdel(src)

/obj/structure/destructible/horrorform/flesh_nest/proc/decay(mob/living/simple_animal/hostile/true_changeling/owner)
	if(destroy_context != FLESH_NEST_DESTROY_NONE)
		return
	destroy_context = FLESH_NEST_DESTROY_DECAY
	visible_message(span_warning("[src] withers into lifeless sludge."), span_warning("Our nest rots without us!"))
	if(owner)
		to_chat(owner, span_warning("Our nest rots without us!"))
	playsound(src, 'sound/effects/splat.ogg', 40, TRUE)
	qdel(src)

/datum/movespeed_modifier/flesh_nest
	id = "flesh_nest"
	multiplicative_slowdown = 1.4
	flags = IGNORE_NOSLOW

/datum/status_effect/grouped/flesh_nest
	id = "flesh_nest"
	alert_type = /atom/movable/screen/alert/status_effect/flesh_nest
	tick_interval = 3 SECONDS
	var/overlay_key
	COOLDOWN_DECLARE(next_slip)

/datum/status_effect/grouped/flesh_nest/source_added(source, ...)
	. = ..()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/flesh_nest)
	owner.add_client_colour(/datum/client_colour/flesh_nest, REF(src))
	overlay_key = "flesh_nest_dark_[REF(src)]"
	owner.overlay_fullscreen(overlay_key, /atom/movable/screen/fullscreen/impaired, 1)

/datum/status_effect/grouped/flesh_nest/source_removed(source, removing)
	. = ..()
	if(!removing)
		return
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/flesh_nest)
	owner.remove_client_colour(REF(src))
	if(overlay_key)
		owner.clear_fullscreen(overlay_key)
		overlay_key = null

/datum/status_effect/grouped/flesh_nest/tick(seconds_between_ticks)
	. = ..()
	if(owner.stat == DEAD)
		return
	if(COOLDOWN_FINISHED(src, next_slip))
		COOLDOWN_START(src, next_slip, FLESH_NEST_SLIP_COOLDOWN)
		if(prob(35))
			var/obj/structure/destructible/horrorform/flesh_nest/nest
			for(var/source in sources)
				nest = locate(source)
				if(nest)
					break
			owner.slip(1.5 SECONDS, nest, GALOSHES_DONT_HELP | SLIDE)
			owner.adjustStaminaLoss(8)
			if(prob(50))
				playsound(owner, 'sound/effects/splat.ogg', 20, TRUE)

/atom/movable/screen/alert/status_effect/flesh_nest
	name = "Viscous Biomass"
	desc = "Thick changeling biomass clings to you, sapping your speed and coating your vision in darkness."
	icon_state = "slime"

/datum/client_colour/flesh_nest
	color = list(
		0.55, 0,    0,    0, 0,
		0,    0.55, 0,    0, 0,
		0,    0,    0.55, 0, 0,
		0,    0,    0,    1, 0,
	)
	fade_in = 0.2 SECONDS
	fade_out = 0.4 SECONDS
	split_filters = TRUE

#undef FLESH_NEST_AURA_RANGE
#undef FLESH_NEST_HEAL_AMOUNT
#undef FLESH_NEST_ABSENCE_LIMIT
#undef FLESH_NEST_SLIP_COOLDOWN
#undef FLESH_NEST_DESTROY_NONE
#undef FLESH_NEST_DESTROY_RECLAIMED
#undef FLESH_NEST_DESTROY_DECAY

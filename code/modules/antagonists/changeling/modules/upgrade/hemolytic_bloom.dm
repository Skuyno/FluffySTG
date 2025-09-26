/datum/changeling_genetic_module/upgrade/hemolytic_bloom
	id = "matrix_hemolytic_bloom"
	passive_effects = list()

	var/list/seeded_corpses = list()

/datum/changeling_genetic_module/upgrade/hemolytic_bloom/on_deactivate()
	seeded_corpses.Cut()
	return ..()

/datum/changeling_genetic_module/upgrade/hemolytic_bloom/proc/handle_hit(atom/target, mob/living/user)
	if(!is_active() || !isliving(target) || !istype(user))
		return
	var/mob/living/living_target = target
	if(isliving(user))
		user.adjustBruteLoss(-1.6, forced = TRUE)
		owner?.adjust_chemicals(2)
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
		cleanup_seed_list()
		if(!(WEAKREF(living_target) in seeded_corpses))
			spawn_seed(living_target)

/datum/changeling_genetic_module/upgrade/hemolytic_bloom/proc/cleanup_seed_list()
	if(!LAZYLEN(seeded_corpses))
		return
	for(var/datum/weakref/ref in seeded_corpses.Copy())
			if(!ref?.resolve())
				seeded_corpses -= ref

/datum/changeling_genetic_module/upgrade/hemolytic_bloom/proc/spawn_seed(mob/living/victim)
	if(!is_active() || !istype(victim))
		return
	var/turf/location = get_turf(victim)
	if(!istype(location))
		return
	seeded_corpses += WEAKREF(victim)
	new /obj/effect/temp_visual/changeling_hemolytic_seed(location, victim, owner)

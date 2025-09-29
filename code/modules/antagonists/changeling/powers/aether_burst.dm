
/datum/action/changeling/aether_burst
	name = "Aetheric Burst"
	desc = "We vent draconic plasma to shove ourselves through open space. Costs 8 chemicals."
	helptext = "Requires the Aether Drake Mantle. Propels us a few tiles in the direction we face even in zero-g."
	button_icon_state = "lesser_form"
	chemical_cost = 8
	dna_cost = CHANGELING_POWER_UNOBTAINABLE
	req_stat = CONSCIOUS
	disabled_by_fire = FALSE

	/// Cooldown tracker in deciseconds.
	var/next_allowed = 0
	/// Minimum delay between bursts.
	var/cooldown_length = 30

/datum/action/changeling/aether_burst/sting_action(mob/living/user)
	var/datum/antagonist/changeling/changeling_data = IS_CHANGELING(user)
	if(!changeling_data?.matrix_manager?.matrix_aether_drake_active)
		user.balloon_alert(user, "requires mantle")
		return FALSE
	if(world.time < next_allowed)
		user.balloon_alert(user, "recharging")
		return FALSE

	var/turf/current = get_turf(user)
	if(!current)
		return FALSE
	var/direction = user.dir
	if(!direction)
		direction = pick(GLOB.cardinals)
	var/turf/target = get_ranged_target_turf(user, direction, 6)
	if(!target || target == current)
		user.balloon_alert(user, "no room")
		return FALSE
	if(user.throw_at(target, range = 6, speed = 2, thrower = user, gentle = TRUE))
		next_allowed = world.time + cooldown_length
		playsound(user, 'sound/effects/magic/wand_teleport.ogg', 50, TRUE)
		user.visible_message(
			span_warning("[user] rockets forward in a streak of violet plasma!"),
			span_changeling("We vent a burst of voidfire to surge ahead."),
		)
		return TRUE
	user.balloon_alert(user, "cannot move")
	return FALSE

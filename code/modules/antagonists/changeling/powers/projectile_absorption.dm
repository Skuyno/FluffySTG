/datum/action/changeling/projectile_absorption
	name = "Projectile Absorption"
	desc = "We distend our flesh to swallow hostile projectiles before hurling them back in every direction."
	helptext = "Activating the ability slows us as we absorb incoming projectiles for a short time. Reactivate it or wait for the stored projectiles to be unleashed automatically."
	button_icon_state = "organic_shield"
	chemical_cost = 0
	dna_cost = 2
	req_stat = CONSCIOUS
	/// How many chemicals are drained when we start absorbing
	var/absorption_chemical_cost = 20
	/// Maximum projectiles we can hold at once
	var/max_absorbed_projectiles = 8
	/// Stored projectile types waiting to be released
	var/list/absorbed_projectiles = list()
	/// Timer id for automatic release
	var/absorption_timer_id
	/// How long we keep the absorption active before releasing automatically
	var/absorption_duration = 5 SECONDS

/datum/action/changeling/projectile_absorption/can_sting(mob/living/carbon/user, mob/living/target)
	if(active)
		return TRUE
	if(!..())
		return FALSE
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
	if(!changeling)
		return FALSE
	if(changeling.chem_charges < absorption_chemical_cost)
		user.balloon_alert(user, "needs [absorption_chemical_cost] chemicals!")
		return FALSE
	return TRUE

/datum/action/changeling/projectile_absorption/sting_action(mob/living/carbon/user)
	..()
	if(active)
		finish_absorption()
		return TRUE
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
	if(!changeling)
		return FALSE
	changeling.adjust_chemicals(-absorption_chemical_cost)
	absorbed_projectiles.Cut()
	active = TRUE
	user.add_movespeed_modifier(/datum/movespeed_modifier/changeling/projectile_absorption)
	RegisterSignal(user, COMSIG_PROJECTILE_PREHIT, PROC_REF(on_projectile_absorbed))
	RegisterSignal(user, COMSIG_QDELETING, PROC_REF(on_owner_deleted))
	if(absorption_timer_id)
		deltimer(absorption_timer_id)
	absorption_timer_id = addtimer(CALLBACK(src, PROC_REF(finish_absorption)), absorption_duration, TIMER_STOPPABLE)
	to_chat(user, span_changeling("We tense our form, ready to drink in incoming fire."))
	return TRUE

/datum/action/changeling/projectile_absorption/Remove(mob/user)
	finish_absorption(FALSE)
	return ..()

/datum/action/changeling/projectile_absorption/proc/on_owner_deleted(mob/living/source)
	SIGNAL_HANDLER
	finish_absorption(FALSE)

/datum/action/changeling/projectile_absorption/proc/on_projectile_absorbed(mob/living/victim, obj/projectile/incoming)
	SIGNAL_HANDLER
	if(!active || victim != owner)
		return NONE
	if(!istype(incoming))
		return NONE
	if(incoming.firer == owner)
		return NONE
	if(incoming.damage <= 0 && incoming.stamina <= 0)
		return NONE
	if(absorbed_projectiles.len >= max_absorbed_projectiles)
		return PROJECTILE_INTERRUPT_HIT
	absorbed_projectiles += incoming.type
	if(absorbed_projectiles.len >= max_absorbed_projectiles)
		finish_absorption()
	return PROJECTILE_INTERRUPT_HIT

/datum/action/changeling/projectile_absorption/proc/finish_absorption(release_projectiles = TRUE)
	if(absorption_timer_id)
		deltimer(absorption_timer_id)
		absorption_timer_id = null
	var/mob/living/carbon/user = owner
	if(user)
		user.remove_movespeed_modifier(/datum/movespeed_modifier/changeling/projectile_absorption)
		UnregisterSignal(user, list(COMSIG_PROJECTILE_PREHIT, COMSIG_QDELETING))
	active = FALSE
	var/list/projectiles_to_fire
	if(release_projectiles && absorbed_projectiles.len)
		projectiles_to_fire = absorbed_projectiles.Copy()
	absorbed_projectiles.Cut()
	if(!release_projectiles || !projectiles_to_fire || !user)
		return
	var/turf/start = get_turf(user)
	if(!start)
		return
	var/count = projectiles_to_fire.len
	if(!count)
		return
	var/step = count ? 360 / count : 360
	var/base_angle = rand(0, 359)
	for(var/i in 1 to count)
		var/proj_type = projectiles_to_fire[i]
		if(!ispath(proj_type, /obj/projectile))
			continue
		var/obj/projectile/launch = new proj_type(start)
		launch.starting = start
		launch.firer = user
		launch.fired_from = src
		launch.ignore_source_check = TRUE
		var/angle = base_angle + (i - 1) * step
		if(count > 1)
			angle += rand(-round(step / 4), round(step / 4))
		angle = (angle % 360 + 360) % 360
		launch.fire(angle)
	to_chat(user, span_changeling("We release a storm of stolen munitions!"))

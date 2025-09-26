/datum/changeling_genetic_module/passive/aether_drake_mantle
	id = "matrix_aether_drake_mantle"
	passive_effects = list(
		"incoming_brute_damage_mult" = 0.7,
		"incoming_burn_damage_mult" = 0.7,
	)

	var/datum/action/changeling/aether_burst/aether_burst_action
	var/traits_applied = FALSE

/datum/changeling_genetic_module/passive/aether_drake_mantle/on_activate()
	. = ..()
	ensure_action()
	apply_traits()
	sync_void_adaption()
	return .

/datum/changeling_genetic_module/passive/aether_drake_mantle/on_deactivate()
	revoke_action()
	remove_traits()
	sync_void_adaption()
	return ..()

/datum/changeling_genetic_module/passive/aether_drake_mantle/on_owner_changed(mob/living/old_holder, mob/living/new_holder)
	. = ..()
	if(new_holder)
		ensure_action()
		apply_traits()
	else
		revoke_action()
		remove_traits()
	sync_void_adaption()

/datum/changeling_genetic_module/passive/aether_drake_mantle/proc/ensure_action()
	if(!is_active())
		return
	if(!aether_burst_action)
		aether_burst_action = new
	grant_module_action(aether_burst_action)

/datum/changeling_genetic_module/passive/aether_drake_mantle/proc/revoke_action()
	if(!aether_burst_action)
		return
	revoke_module_action(aether_burst_action)

/datum/changeling_genetic_module/passive/aether_drake_mantle/proc/apply_traits()
	if(traits_applied || !is_active())
		return
	var/mob/living/living_owner = get_owner_mob()
	if(!isliving(living_owner))
		return
	living_owner.add_traits(list(TRAIT_SPACEWALK, TRAIT_FREE_HYPERSPACE_MOVEMENT), CHANGELING_TRAIT)
	traits_applied = TRUE

/datum/changeling_genetic_module/passive/aether_drake_mantle/proc/remove_traits()
	if(!traits_applied)
		return
	var/mob/living/living_owner = get_owner_mob()
	if(!living_owner)
		traits_applied = FALSE
		return
	living_owner.remove_traits(list(TRAIT_SPACEWALK, TRAIT_FREE_HYPERSPACE_MOVEMENT), CHANGELING_TRAIT)
	traits_applied = FALSE

/datum/changeling_genetic_module/passive/aether_drake_mantle/proc/sync_void_adaption()
	var/datum/antagonist/changeling/changeling_owner = owner
	if(!changeling_owner)
		return
	var/datum/action/changeling/void_adaption/adaption = changeling_owner.get_changeling_power_instance(/datum/action/changeling/void_adaption)
	adaption?.sync_module_state(changeling_owner)

/datum/changeling_genetic_module/passive/void_carapace
	id = "matrix_void_carapace"
	passive_effects = list()

/datum/changeling_genetic_module/passive/void_carapace/on_activate()
	. = ..()
	sync_state()
	return .

/datum/changeling_genetic_module/passive/void_carapace/on_deactivate()
	sync_state()
	return ..()

/datum/changeling_genetic_module/passive/void_carapace/on_owner_changed(mob/living/old_holder, mob/living/new_holder)
	. = ..()
	sync_state()

/datum/changeling_genetic_module/passive/void_carapace/proc/sync_state()
	var/datum/antagonist/changeling/changeling_owner = owner
	if(!changeling_owner)
		return
	var/datum/action/changeling/void_adaption/adaption = changeling_owner.get_changeling_power_instance(/datum/action/changeling/void_adaption)
	adaption?.sync_module_state(changeling_owner)

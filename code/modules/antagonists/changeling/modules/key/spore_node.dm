/datum/changeling_genetic_module/key/spore_node
	id = "matrix_spore_node"
	passive_effects = list()

	var/datum/action/changeling/spore_node/spore_action
	var/datum/weakref/node_ref

/datum/changeling_genetic_module/key/spore_node/on_activate()
	. = ..()
	ensure_action()
	return .

/datum/changeling_genetic_module/key/spore_node/on_deactivate()
	revoke_action()
	clear_node()
	return ..()

/datum/changeling_genetic_module/key/spore_node/on_owner_changed(mob/living/old_holder, mob/living/new_holder)
	. = ..()
	if(new_holder)
		ensure_action()
	else
		revoke_action()
		clear_node()

/datum/changeling_genetic_module/key/spore_node/proc/ensure_action()
	if(!is_active())
		return
	if(!spore_action)
		spore_action = new
	grant_module_action(spore_action)

/datum/changeling_genetic_module/key/spore_node/proc/revoke_action()
	if(!spore_action)
		return
	revoke_module_action(spore_action)

/datum/changeling_genetic_module/key/spore_node/proc/place_node(turf/location, mob/living/user)
	if(!is_active() || !istype(location))
		return FALSE
	clear_node()
	var/obj/structure/changeling_spore_node/node = new(location, src)
	node_ref = WEAKREF(node)
	if(istype(user))
		user.visible_message(
			span_warning("[user] plants a throbbing spore node that quickly roots into the floor!"),
			span_changeling("We seed a pheromone node to watch this space."),
		)
	return TRUE

/datum/changeling_genetic_module/key/spore_node/proc/detonate_node(mob/living/user)
	var/obj/structure/changeling_spore_node/node = node_ref?.resolve()
	if(!node)
		return FALSE
	node.detonate(user)
	return TRUE

/datum/changeling_genetic_module/key/spore_node/proc/node_detonated(mob/living/user)
	node_ref = null
	if(!istype(user))
		return
	to_chat(user, span_changeling("Our spore node ruptures, flooding the area with grasping spores."))

/datum/changeling_genetic_module/key/spore_node/proc/clear_node(obj/structure/changeling_spore_node/ignore)
	var/obj/structure/changeling_spore_node/current = node_ref?.resolve()
	if(current && (!ignore || ignore != current))
		qdel(current)
	node_ref = null

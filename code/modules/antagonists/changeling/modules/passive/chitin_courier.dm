/datum/changeling_genetic_module/passive/chitin_courier
	id = "matrix_chitin_courier"
	passive_effects = list()

	var/datum/action/changeling/chitin_courier/courier_action
	var/obj/effect/abstract/changeling_chitin_cache/cache
	var/obj/item/stored_item

/datum/changeling_genetic_module/passive/chitin_courier/on_activate()
	. = ..()
	ensure_action()
	return .

/datum/changeling_genetic_module/passive/chitin_courier/on_deactivate()
	revoke_action()
	clear_cache(TRUE)
	return ..()

/datum/changeling_genetic_module/passive/chitin_courier/on_owner_changed(mob/living/old_holder, mob/living/new_holder)
	. = ..()
	if(new_holder)
		ensure_action()
	else
		revoke_action()
		clear_cache(TRUE)

/datum/changeling_genetic_module/passive/chitin_courier/proc/ensure_action()
	if(!is_active())
		return
	if(!courier_action)
		courier_action = new
	grant_module_action(courier_action)

/datum/changeling_genetic_module/passive/chitin_courier/proc/revoke_action()
	if(!courier_action)
		return
	revoke_module_action(courier_action)

/datum/changeling_genetic_module/passive/chitin_courier/proc/stash_item(obj/item/held_item, mob/living/user)
	if(!is_active() || !istype(held_item))
		return FALSE
	if(stored_item)
		clear_cache(TRUE)
	if(!cache)
		cache = new(user)
	cache.forceMove(user)
	held_item.forceMove(cache)
	stored_item = held_item
	if(istype(user))
		user.visible_message(
			span_warning("[user] flexes [user.p_their()] arm as flesh folds swallow [held_item]!"),
			span_changeling("We thread [held_item] into a hidden courier sac."),
		)
	return TRUE

/datum/changeling_genetic_module/passive/chitin_courier/proc/retrieve_item(mob/living/user)
	if(!stored_item)
		return FALSE
	var/obj/item/held = stored_item
	stored_item = null
	if(!istype(user))
		held.forceMove(get_turf(held))
		clear_cache()
		return TRUE
	if(!user.put_in_hands(held))
		held.forceMove(get_turf(user))
	user.visible_message(
		span_warning("[user] flexes and extrudes [held] from beneath [user.p_their()] skin!"),
		span_changeling("We regurgitate our cached [held]."),
	)
	clear_cache()
	return TRUE

/datum/changeling_genetic_module/passive/chitin_courier/proc/clear_cache(drop_item = FALSE)
	if(stored_item)
		var/obj/item/held = stored_item
		stored_item = null
		if(drop_item)
			var/turf/drop_loc = get_turf(get_owner_mob()) || get_turf(held)
			held.forceMove(drop_loc)
		else
			held.forceMove(get_turf(held))
	QDEL_NULL(cache)

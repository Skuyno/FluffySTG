
/datum/action/changeling/chitin_courier
        name = "Chitin Courier"
        desc = "We unfurl a hidden cache beneath our skin for a single medium item."
        helptext = "Store or retrieve a compact contraband item invisibly. Requires the Chitin Courier matrix passive."
	button_icon_state = "lesserform"
	chemical_cost = 0
	dna_cost = CHANGELING_POWER_UNOBTAINABLE
	req_stat = CONSCIOUS
	disabled_by_fire = FALSE

/datum/action/changeling/chitin_courier/sting_action(mob/living/user)
	var/datum/antagonist/changeling/changeling_data = IS_CHANGELING(user)
	if(!changeling_data?.matrix_chitin_courier_active)
		user.balloon_alert(user, "needs courier")
		return FALSE
	if(changeling_data.retrieve_chitin_courier_item(user))
		return TRUE
	var/obj/item/held = user.get_active_held_item()
	if(!held)
		user.balloon_alert(user, "empty hand")
		return FALSE
        if(held.w_class > WEIGHT_CLASS_NORMAL)
                user.balloon_alert(user, "too bulky")
                return FALSE
	if(!user.temporarilyRemoveItemFromInventory(held))
		user.balloon_alert(user, "cannot stash")
		return FALSE
	changeling_data.stash_chitin_courier_item(held, user)
	return TRUE

/obj/effect/abstract/changeling_chitin_cache
	name = "subdermal cache"
	invisibility = INVISIBILITY_ABSTRACT
	anchored = TRUE
	density = FALSE
	/// Prevents it from being moved by accidents.
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF

// Cellular Emporium -
// The place where Changelings go to purchase biological weaponry.
/datum/cellular_emporium
	/// The name of the emporium - why does it need a name? Dunno
	var/name = "cellular emporium"
	/// The changeling who owns this emporium
	var/datum/antagonist/changeling/changeling

/datum/cellular_emporium/New(my_changeling)
	. = ..()
	changeling = my_changeling

/datum/cellular_emporium/Destroy()
	changeling = null
	return ..()

/datum/cellular_emporium/ui_state(mob/user)
	return GLOB.always_state

/datum/cellular_emporium/ui_status(mob/user, datum/ui_state/state)
	if(!changeling)
		return UI_CLOSE
	return UI_INTERACTIVE

/datum/cellular_emporium/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CellularEmporium", name)
		ui.open()

/datum/cellular_emporium/ui_static_data(mob/user)
        var/list/data = list()
        data["abilities"] = changeling?.get_standard_skill_catalog() || list()
        return data

/datum/cellular_emporium/ui_data(mob/user)
        var/list/data = list()
        var/list/state = changeling?.get_standard_skill_state() || list()
        data["can_readapt"] = state["can_readapt"]
        data["owned_abilities"] = state["owned"] || list()
        data["genetic_points_count"] = state["genetic_points"]
        data["absorb_count"] = state["absorb_count"]
        data["dna_count"] = state["dna_count"]

        return data

/datum/cellular_emporium/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("readapt")
			if(changeling.can_respec)
				changeling.readapt()

		if("evolve")
			// purchase_power sanity checks stuff like typepath, DNA, and absorbs for us.
			changeling.purchase_power(text2path(params["path"]))

	return TRUE

/datum/action/cellular_emporium
	name = "Cellular Emporium"
	button_icon = 'icons/obj/drinks/soda.dmi'
	button_icon_state = "changelingsting"
	background_icon_state = "bg_changeling"
	overlay_icon_state = "bg_changeling_border"
	check_flags = NONE

/datum/action/cellular_emporium/New(Target)
	. = ..()
	if(!istype(Target, /datum/cellular_emporium))
		stack_trace("cellular_emporium action created with non-emporium.")
		qdel(src)

/datum/action/cellular_emporium/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	target.ui_interact(owner)

/// Handles changeling HUD widgets and their lifecycle for a single antagonist.
///
/// The UI manager is responsible for wiring up the special chemical and
/// sting displays when a changeling gains its HUD, responding to HUD creation
/// events, and cleaning the widgets up when the changeling loses access to its
/// powers. Gameplay logic stays on the main antagonist datum while this helper
/// keeps the presentation code self-contained.
#define FORMAT_CHEM_CHARGES_TEXT(charges) MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#dd66dd'>[round(charges)]</font></div>")

/datum/changeling_ui_manager
	var/datum/antagonist/changeling/changeling
	var/mob/living/bound_mob
	var/atom/movable/screen/ling/chems/chem_display
	var/atom/movable/screen/ling/sting/sting_display

/datum/changeling_ui_manager/New(datum/antagonist/changeling/changeling)
	. = ..()
	src.changeling = changeling

/datum/changeling_ui_manager/Destroy()
	unbind()
	changeling = null
	return ..()

/datum/changeling_ui_manager/proc/bind(mob/living/mob)
	if(bound_mob == mob)
		return
	unbind()
	if(!isliving(mob))
		return
	bound_mob = mob
	if(bound_mob.hud_used)
		setup_displays(bound_mob.hud_used)
	else
		RegisterSignal(bound_mob, COMSIG_MOB_HUD_CREATED, PROC_REF(on_hud_created))

/datum/changeling_ui_manager/proc/unbind(mob/living/mob)
	if(mob && mob != bound_mob)
		return
	if(bound_mob)
		UnregisterSignal(bound_mob, COMSIG_MOB_HUD_CREATED)
		clear_displays(bound_mob?.hud_used)
	bound_mob = null

/datum/changeling_ui_manager/proc/on_hud_created(datum/source)
	SIGNAL_HANDLER
	var/mob/living/mob = bound_mob
	if(!mob)
		return
	UnregisterSignal(mob, COMSIG_MOB_HUD_CREATED)
	if(!mob.hud_used)
		return
	setup_displays(mob.hud_used)

/datum/changeling_ui_manager/proc/setup_displays(datum/hud/hud)
	if(!hud)
		return
	chem_display = new(null, hud)
	hud.infodisplay += chem_display
	sting_display = new(null, hud)
	hud.infodisplay += sting_display
	hud.show_hud(hud.hud_version)
	update_chem_display()

/datum/changeling_ui_manager/proc/clear_displays(datum/hud/hud)
	if(hud)
		hud.infodisplay -= chem_display
		hud.infodisplay -= sting_display
	QDEL_NULL(chem_display)
	QDEL_NULL(sting_display)

/datum/changeling_ui_manager/proc/get_sting_display()
	return sting_display

/datum/changeling_ui_manager/proc/update_chem_display()
	if(!chem_display || !changeling)
		return
	chem_display.maptext = FORMAT_CHEM_CHARGES_TEXT(changeling.chem_charges)

#undef FORMAT_CHEM_CHARGES_TEXT

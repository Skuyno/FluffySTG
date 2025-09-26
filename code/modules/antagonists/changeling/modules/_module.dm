/**
	* Base class for changeling genetic matrix modules and registry helpers.
	*/

#define CHANGELING_MODULE_ACTIVE_FLAG "__changeling_module_active__"

GLOBAL_LIST_EMPTY(changeling_genetic_module_registry)

/proc/changeling_module_registry_key(module_identifier)
	if(isnull(module_identifier))
		return null
	if(istext(module_identifier))
		return module_identifier
	return "[module_identifier]"

/proc/register_changeling_module(module_identifier, datum_type)
	var/id_key = changeling_module_registry_key(module_identifier)
	if(!istext(id_key) || !length(id_key))
		CRASH("Attempted to register changeling module with invalid id [module_identifier]")
	if(!ispath(datum_type, /datum/changeling_genetic_module))
		CRASH("Attempted to register changeling module [id_key] with invalid type [datum_type]")
	if(GLOB.changeling_genetic_module_registry[id_key])
		CRASH("Duplicate changeling module id registration for [id_key]")
	GLOB.changeling_genetic_module_registry[id_key] = datum_type
	return TRUE

/proc/new_module_for_id(module_identifier, datum/antagonist/changeling/changeling_datum)
	var/id_key = changeling_module_registry_key(module_identifier)
	if(isnull(id_key))
		return null
	var/module_type = GLOB.changeling_genetic_module_registry[id_key]
	if(!module_type)
		return null
	var/datum/changeling_genetic_module/module = new module_type()
	module.id = id_key
	if(changeling_datum)
		module.assign_owner(changeling_datum)
	return module

/datum/changeling_genetic_module
	/// Unique identifier for this module instance.
	var/id
	/// Changeling antagonist datum that owns this module.
	var/datum/antagonist/changeling/owner
	/// Passive effects granted by this module.
	var/list/passive_effects = list()
	/// Internal tracker of registered signals.
	var/list/_registered_signals
	/// Internal tracker of granted action datums.
	var/list/_granted_actions

/datum/changeling_genetic_module/Destroy()
	revoke_all_module_actions(TRUE)
	clear_module_signals()
	owner = null
	return ..()

/datum/changeling_genetic_module/proc/assign_owner(datum/antagonist/changeling/new_owner)
	if(owner == new_owner)
		return
	var/mob/living/old_holder = get_owner_mob()
	if(old_holder)
		revoke_all_module_actions(TRUE, old_holder)
	if(owner)
		clear_module_signals()
	owner = new_owner

/datum/changeling_genetic_module/proc/on_activate()
	return TRUE

/datum/changeling_genetic_module/proc/on_deactivate()
	revoke_all_module_actions(TRUE)
	clear_module_signals()
	return TRUE

/datum/changeling_genetic_module/proc/on_tick(seconds_between_ticks)
	return

/datum/changeling_genetic_module/proc/get_passive_effects()
	return passive_effects

/datum/changeling_genetic_module/proc/get_owner_mob()
	return owner?.owner?.current

/datum/changeling_genetic_module/proc/is_active()
	return vars?[CHANGELING_MODULE_ACTIVE_FLAG]

/datum/changeling_genetic_module/proc/on_owner_changed(mob/living/old_holder, mob/living/new_holder)
	return

/datum/changeling_genetic_module/proc/register_module_signal(datum/source, signals, callback)
	if(!source || !callback || !signals)
		return
	if(islist(signals))
		RegisterSignals(source, signals, callback)
	else
		RegisterSignal(source, signals, callback)
	if(!_registered_signals)
		_registered_signals = list()
	var/list/source_signals = _registered_signals[source]
	if(!source_signals)
		source_signals = list()
		_registered_signals[source] = source_signals
	if(islist(signals))
		for(var/signal in signals)
			if(!(signal in source_signals))
				source_signals += signal
	else if(!(signals in source_signals))
		source_signals += signals

/datum/changeling_genetic_module/proc/unregister_module_signal(datum/source, signals = null)
	if(!_registered_signals || !source)
		return
	var/list/source_signals = _registered_signals[source]
	if(!source_signals)
		return
	var/list/to_remove
	if(isnull(signals))
		to_remove = source_signals.Copy()
		source_signals.Cut()
		_registered_signals -= source
	else if(islist(signals))
		to_remove = list()
		for(var/signal in signals)
			if(signal in source_signals)
				to_remove += signal
				source_signals -= signal
	else if(signals in source_signals)
		to_remove = list(signals)
		source_signals -= signals
	if(LAZYLEN(to_remove))
		UnregisterSignal(source, to_remove)
	if(source_signals && !length(source_signals))
		_registered_signals -= source

/datum/changeling_genetic_module/proc/clear_module_signals()
	if(!_registered_signals)
		return
	for(var/datum/source as anything in _registered_signals)
		var/list/signals = _registered_signals[source]
		if(LAZYLEN(signals))
			UnregisterSignal(source, signals)
	_registered_signals.Cut()
	_registered_signals = null

/datum/changeling_genetic_module/proc/grant_module_action(datum/action/action, mob/living/recipient = null)
	if(!action)
		return null
	if(!recipient)
		recipient = get_owner_mob()
	if(!recipient)
		return null
	action.Grant(recipient)
	if(!_granted_actions)
		_granted_actions = list()
	if(!(action in _granted_actions))
		_granted_actions += action
	return action

/datum/changeling_genetic_module/proc/revoke_module_action(datum/action/action, delete_action = FALSE, mob/living/recipient = null)
	if(!_granted_actions || !action)
		return
	if(!recipient)
		recipient = get_owner_mob()
	if(recipient)
		action.Remove(recipient)
	_granted_actions -= action
	if(delete_action)
		QDEL_NULL(action)

/datum/changeling_genetic_module/proc/revoke_all_module_actions(delete_actions = FALSE, mob/living/recipient = null)
	if(!_granted_actions)
		return
	if(!recipient)
		recipient = get_owner_mob()
	for(var/datum/action/action as anything in _granted_actions)
		if(recipient)
			action.Remove(recipient)
		if(delete_actions)
			QDEL_NULL(action)
	_granted_actions.Cut()
	_granted_actions = null

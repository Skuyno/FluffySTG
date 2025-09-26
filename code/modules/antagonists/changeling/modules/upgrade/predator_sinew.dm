/datum/changeling_genetic_module/upgrade/predator_sinew
	id = "matrix_predator_sinew"
	passive_effects = list()

	var/mob/living/bound_host

/datum/changeling_genetic_module/upgrade/predator_sinew/on_activate()
	. = ..()
	bind_host(get_owner_mob())
	return .

/datum/changeling_genetic_module/upgrade/predator_sinew/on_deactivate()
	unbind_host()
	return ..()

/datum/changeling_genetic_module/upgrade/predator_sinew/on_owner_changed(mob/living/old_holder, mob/living/new_holder)
	. = ..()
	if(old_holder && old_holder == bound_host)
		unbind_host()
	if(new_holder)
		bind_host(new_holder)

/datum/changeling_genetic_module/upgrade/predator_sinew/proc/bind_host(mob/living/new_holder)
	if(bound_host == new_holder)
		return
	unbind_host()
	if(!is_active() || !isliving(new_holder))
		return
	register_module_signal(new_holder, COMSIG_MOB_ITEM_ATTACK, PROC_REF(on_item_attack))
	register_module_signal(new_holder, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))
	bound_host = new_holder

/datum/changeling_genetic_module/upgrade/predator_sinew/proc/unbind_host()
	if(!bound_host)
		return
	unregister_module_signal(bound_host, list(COMSIG_MOB_ITEM_ATTACK, COMSIG_LIVING_UNARMED_ATTACK))
	bound_host = null

/datum/changeling_genetic_module/upgrade/predator_sinew/proc/on_item_attack(mob/living/source, mob/living/target, mob/living/user, list/modifiers, list/attack_modifiers)
	SIGNAL_HANDLER
	handle_knockdown(target)

/datum/changeling_genetic_module/upgrade/predator_sinew/proc/on_unarmed_attack(mob/living/source, atom/target, proximity_flag, list/modifiers)
	SIGNAL_HANDLER
	if(isliving(target))
		handle_knockdown(target)

/datum/changeling_genetic_module/upgrade/predator_sinew/proc/handle_knockdown(mob/living/target)
	if(!is_active())
		return
	var/mob/living/carbon/user = get_owner_mob()
	if(!istype(user) || user != bound_host)
		return
	var/datum/action/changeling/strained_muscles/muscles = owner?.get_changeling_power_instance(/datum/action/changeling/strained_muscles)
	if(!muscles?.active)
		return
	if(user.move_intent != MOVE_INTENT_RUN || !user.combat_mode)
		return
	if(!istype(target) || target == user || target.stat == DEAD)
		return
	var/stamina_cost = 6
	if(user.staminaloss + stamina_cost >= user.max_stamina)
		return
	user.adjustStaminaLoss(stamina_cost)
	target.Knockdown(2 SECONDS)
	target.visible_message(
		span_danger("[target] is hammered off balance by [user]'s driving strike!"),
		span_userdanger("A brutal shoulder slam knocks you sprawling!"),
		span_hear("You hear a heavy impact and a body hitting the ground."),
	)

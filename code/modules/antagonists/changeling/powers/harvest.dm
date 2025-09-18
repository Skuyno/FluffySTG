/datum/action/changeling/sting/harvest_biomass
        name = "Harvest Biomass"
        desc = "We siphon viable tissue from a living organism, fueling our evolution without a messy feast."
        helptext = "Requires close contact with a living, organic target. Leaves them weakened but alive."
        button_icon_state = "absorb_dna"
        dna_cost = CHANGELING_POWER_INNATE
        chemical_cost = 0
        req_human = FALSE

/datum/action/changeling/sting/harvest_biomass/can_sting(mob/living/user, atom/target)
        if(!..())
                return FALSE
        if(!isliving(target))
                user.balloon_alert(user, "no life to siphon!")
                return FALSE
        if(target == user)
                user.balloon_alert(user, "counterproductive!")
                return FALSE
        var/mob/living/living_target = target
        if(living_target.mob_biotypes & MOB_ROBOTIC)
                user.balloon_alert(user, "synthetic shell!")
                return FALSE
        if(HAS_TRAIT(living_target, TRAIT_HUSK) || HAS_TRAIT(living_target, TRAIT_BADDNA))
                user.balloon_alert(user, "no viable cells!")
                return FALSE
        if(living_target.has_status_effect(/datum/status_effect/changeling/harvested))
                user.balloon_alert(user, "already drained!")
                return FALSE
        return TRUE

/datum/action/changeling/sting/harvest_biomass/sting_action(mob/living/user, atom/target)
        var/mob/living/living_target = target
        if(!do_after(user, 3 SECONDS, living_target, hidden = TRUE))
                return FALSE
        var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
        if(!changeling)
                return FALSE
        if(!changeling.harvest_biomaterials_from(living_target))
                user.balloon_alert(user, "no viable sample!")
                return FALSE
        living_target.apply_status_effect(/datum/status_effect/changeling/harvested, 2 MINUTES)
        log_combat(user, living_target, "harvested", "biomass")
        return TRUE

/datum/action/changeling/sting/harvest_biomass/sting_feedback(mob/living/user, atom/target)
        var/mob/living/living_target = target
        to_chat(user, span_changeling("We draw nutrient-rich biomass from [living_target]."))
        if(living_target)
                to_chat(living_target, span_warning("A burning sting ripples through your body as something siphons your cells!"))
        return TRUE

/datum/action/changeling/sting/harvest_residue
        name = "Siphon Residue"
        desc = "We draw cytology samples from contaminated surfaces, caches, and specimens."
        helptext = "Targets objects or floors that still hold viable residue."
        button_icon_state = "sting_extract"
        dna_cost = CHANGELING_POWER_INNATE
        chemical_cost = 0
        req_human = FALSE
        allow_nonliving_targets = TRUE

/datum/action/changeling/sting/harvest_residue/can_sting(mob/living/user, atom/target)
        if(!..())
                return FALSE
        if(isliving(target))
                user.balloon_alert(user, "use biomass harvest!")
                return FALSE
        return TRUE

/datum/action/changeling/sting/harvest_residue/sting_action(mob/living/user, atom/target)
        if(!do_after(user, 2 SECONDS, target, hidden = TRUE))
                return FALSE
        var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
        if(!changeling)
                return FALSE
        if(!changeling.harvest_biomaterials_from(target))
                user.balloon_alert(user, "no residue here!")
                return FALSE
        log_combat(user, target, "harvested", "surface residue")
        return TRUE

/datum/action/changeling/sting/harvest_residue/sting_feedback(mob/living/user, atom/target)
        to_chat(user, span_changeling("We leech the lingering samples from [target]."))
        return TRUE

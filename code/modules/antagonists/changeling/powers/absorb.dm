/datum/action/changeling/absorb_dna
        name = "Harvest Biomass"
        desc = "Siphon living biomaterial and genetic data from a restrained victim."
        helptext = "Requires a firm grip on the target, but no longer demands a lethal choke."
        button_icon_state = "absorb_dna"
        chemical_cost = 0
        dna_cost = CHANGELING_POWER_INNATE
        req_human = TRUE
        /// Prevents overlapping harvest attempts.
        var/is_harvesting = FALSE
        /// Duration of the extraction sequence.
        var/harvest_time = 10 SECONDS

/datum/action/changeling/absorb_dna/can_sting(mob/living/carbon/owner)
        if(!..())
                return

        if(is_harvesting)
                owner.balloon_alert(owner, "already harvesting!")
                return

        if(!owner.pulling || !iscarbon(owner.pulling))
                owner.balloon_alert(owner, "needs grab!")
                return

        if(owner.grab_state < GRAB_AGGRESSIVE)
                owner.balloon_alert(owner, "tighten grip!")
                return

        var/mob/living/carbon/human/target = owner.pulling
        var/datum/antagonist/changeling/changeling = IS_CHANGELING(owner)
        if(!changeling.can_harvest_biomaterials(target))
                return
        return changeling.can_absorb_dna(target)

/datum/action/changeling/absorb_dna/sting_action(mob/living/carbon/owner)
        SHOULD_CALL_PARENT(FALSE)

        var/datum/antagonist/changeling/changeling = IS_CHANGELING(owner)
        var/mob/living/carbon/human/target = owner.pulling
        if(!target)
                return FALSE

        is_harvesting = TRUE
        owner.visible_message(span_warning("[owner] unfurls slender proboscises into [target]!"), span_notice("We begin extracting living biomaterial from [target]."))
        to_chat(target, span_userdanger("You feel invasive spines piercing your flesh as cells are siphoned away!"))

        if(!do_after(owner, harvest_time, target, hidden = TRUE))
                owner.balloon_alert(owner, "interrupted!")
                is_harvesting = FALSE
                return FALSE

        if(owner.pulling != target || owner.grab_state < GRAB_AGGRESSIVE)
                owner.balloon_alert(owner, "lost control!")
                is_harvesting = FALSE
                return FALSE

        var/list/results = changeling.harvest_biomaterials_from_mob(target)
        if(!LAZYLEN(results))
                owner.balloon_alert(owner, "no viable cells!")
                is_harvesting = FALSE
                return FALSE

        var/summary = changeling.build_harvest_summary(results)
        owner.visible_message(span_notice("[owner] drains a slurry of tissue from [target]!"), span_notice("We extract [summary]."))
        to_chat(target, span_warning("A wave of fatigue follows the extraction."))

        if(!changeling.has_profile_with_dna(target.dna))
                changeling.add_new_profile(target)
        owner.copy_languages(target, LANGUAGE_ABSORB)

        changeling.absorbed_count++
        changeling.true_absorbs++

        SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("Harvest Biomass", "1"))
        log_combat(owner, target, "harvested", object = "biomaterial harvest", addition = summary)

        is_harvesting = FALSE
        return TRUE

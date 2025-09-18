/datum/status_effect/changeling/harvested
        id = "changeling_harvested"
        status_type = STATUS_EFFECT_UNIQUE
        alert_type = null
        remove_on_death = TRUE

/datum/status_effect/changeling/harvested/on_apply()
        . = ..()
        if(owner)
                to_chat(owner, span_warning("Your body feels hollow after the invasive siphoning."))

/datum/status_effect/changeling/harvested/on_remove()
        . = ..()
        if(owner)
                to_chat(owner, span_notice("The drained ache within your body finally fades."))

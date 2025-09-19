#define GENETIC_MATRIX_MAX_ABILITY_SLOTS 8
#define GENETIC_MATRIX_MAX_BUILDS 6

/// Coordinating datum for the changeling genetic matrix interface.
/datum/genetic_matrix
  var/name = "Genetic Matrix"
  var/datum/antagonist/changeling/changeling

/datum/genetic_matrix/New(datum/antagonist/changeling/changeling)
  . = ..()
  src.changeling = changeling

/datum/genetic_matrix/Destroy()
  changeling = null
  return ..()

/datum/genetic_matrix/ui_state(mob/user)
  return GLOB.always_state

/datum/genetic_matrix/ui_status(mob/user, datum/ui_state/state)
  if(!changeling)
    return UI_CLOSE
  return UI_INTERACTIVE

/datum/genetic_matrix/ui_interact(mob/user, datum/tgui/ui)
  ui = SStgui.try_update_ui(user, src, ui)
  if(!ui)
    ui = new(user, src, "GeneticMatrix", name)
    ui.open()

/datum/genetic_matrix/ui_static_data(mob/user)
  return list(
    "maxAbilitySlots" = GENETIC_MATRIX_MAX_ABILITY_SLOTS,
    "maxBuilds" = GENETIC_MATRIX_MAX_BUILDS,
  )

/datum/genetic_matrix/ui_data(mob/user)
  var/list/data = list()
  if(!changeling)
    return data

  changeling.ensure_genetic_matrix_setup()
  changeling.prune_genetic_matrix_assignments()

  var/datum/changeling_bio_incubator/incubator = changeling.get_bio_incubator()
  if(incubator)
    data["builds"] = incubator.get_builds_data()
    data["cells"] = incubator.get_cells_data()
    data["recipes"] = incubator.get_recipes_data()
    data["abilities"] = incubator.get_modules_data()
    data["canAddBuild"] = incubator.can_add_build()
  else
    data["builds"] = list()
    data["cells"] = list()
    data["recipes"] = list()
    data["abilities"] = list()
    data["canAddBuild"] = FALSE

  data["resultCatalog"] = changeling.get_genetic_matrix_profile_catalog()
  data["abilityCatalog"] = changeling.get_genetic_matrix_ability_catalog()
  data["skills"] = changeling.get_genetic_matrix_skills_data()
  return data

/datum/genetic_matrix/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
  . = ..()
  if(.)
    return

  if(!changeling)
    return FALSE

  var/mob/user = ui.user
  var/datum/changeling_bio_incubator/incubator = changeling.get_bio_incubator()

  switch(action)
    if("create_build")
      if(!incubator || !incubator.can_add_build())
        return FALSE

      var/build_count = 0
      if(incubator?.build_presets)
        build_count = incubator.build_presets.len
      var/default_name = "Matrix Build [build_count + 1]"
      var/new_name = tgui_input_text(user, "Name the new build.", "Create Genetic Matrix Build", default_name, 32)
      if(isnull(new_name))
        return FALSE

      new_name = sanitize_text(new_name)
      if(!length(new_name))
        new_name = default_name

      changeling.add_genetic_matrix_build(new_name)
      return TRUE

    if("delete_build")
      var/datum/changeling_bio_build/build = changeling.find_genetic_matrix_build(params["build"])
      if(!build)
        return FALSE

      if(tgui_alert(user, "Delete build \"[build.name]\"?", "Remove Build", list("Delete", "Cancel")) != "Delete")
        return FALSE

      changeling.remove_genetic_matrix_build(build)
      return TRUE

    if("rename_build")
      var/datum/changeling_bio_build/build = changeling.find_genetic_matrix_build(params["build"])
      if(!build)
        return FALSE

      var/new_name = tgui_input_text(user, "Enter a new name for this build.", "Rename Build", build.name, 32)
      if(isnull(new_name))
        return FALSE

      new_name = sanitize_text(new_name)
      if(!length(new_name))
        return FALSE

      build.name = new_name
      return TRUE

    if("clear_build")
      var/datum/changeling_bio_build/build = changeling.find_genetic_matrix_build(params["build"])
      if(!build)
        return FALSE

      changeling.clear_genetic_matrix_build(build)
      return TRUE

    if("set_build_profile")
      var/datum/changeling_bio_build/build = changeling.find_genetic_matrix_build(params["build"])
      if(!build)
        return FALSE

      var/datum/changeling_profile/profile = changeling.find_genetic_matrix_profile(params["profile"])
      changeling.assign_genetic_matrix_profile(build, profile)
      return TRUE

    if("clear_build_profile")
      var/datum/changeling_bio_build/build = changeling.find_genetic_matrix_build(params["build"])
      if(!build)
        return FALSE

      changeling.assign_genetic_matrix_profile(build, null)
      return TRUE

    if("set_build_ability")
      var/datum/changeling_bio_build/build = changeling.find_genetic_matrix_build(params["build"])
      if(!build)
        return FALSE

      var/slot = clamp(text2num(params["slot"]), 1, GENETIC_MATRIX_MAX_ABILITY_SLOTS)
      if(!slot)
        return FALSE

      var/ability_identifier = params["ability"]
      if(!ability_identifier)
        changeling.assign_genetic_matrix_ability(build, null, slot)
        return TRUE

      if(changeling.assign_genetic_matrix_ability(build, ability_identifier, slot))
        return TRUE

      return FALSE

    if("clear_build_ability")
      var/datum/changeling_bio_build/build = changeling.find_genetic_matrix_build(params["build"])
      if(!build)
        return FALSE

      var/slot = clamp(text2num(params["slot"]), 1, GENETIC_MATRIX_MAX_ABILITY_SLOTS)
      if(!slot)
        return FALSE

      changeling.assign_genetic_matrix_ability(build, null, slot)
      return TRUE

  return FALSE

/datum/action/changeling/genetic_matrix
  name = "Genetic Matrix"
  button_icon_state = "sting_transform"
  background_icon_state = "bg_changeling"
  overlay_icon_state = "bg_changeling_border"
  check_flags = NONE

/datum/action/changeling/genetic_matrix/New(Target)
  . = ..()
  if(!istype(Target, /datum/genetic_matrix))
    stack_trace("genetic_matrix action created with non-matrix target.")
    qdel(src)

/datum/action/changeling/genetic_matrix/Trigger(mob/clicker, trigger_flags)
  if(!(trigger_flags & TRIGGER_FORCE_AVAILABLE) && !IsAvailable(feedback = TRUE))
    return FALSE

  if(SEND_SIGNAL(src, COMSIG_ACTION_TRIGGER, src) & COMPONENT_ACTION_BLOCK_TRIGGER)
    return FALSE

  var/datum/genetic_matrix/matrix = target
  if(!matrix)
    return FALSE

  matrix.ui_interact(owner)
  return TRUE

/// Ensure that the matrix data structures exist and have at least one build configured.
/datum/antagonist/changeling/proc/ensure_genetic_matrix_setup()
  var/datum/changeling_bio_incubator/incubator = get_bio_incubator()
  incubator?.ensure_default_build()

/// Remove invalid references from matrix builds.
/datum/antagonist/changeling/proc/prune_genetic_matrix_assignments()
  var/datum/changeling_bio_incubator/incubator = get_bio_incubator()
  incubator?.prune_build_assignments()

/// Generate data for the matrix builds to send to the UI.
/datum/antagonist/changeling/proc/get_genetic_matrix_builds_data()
  var/datum/changeling_bio_incubator/incubator = get_bio_incubator()
  if(!incubator)
    return list()

  return incubator.get_builds_data()

/// Produce a sortable profile dataset for quick access on the matrix tab.
/datum/antagonist/changeling/proc/get_genetic_matrix_profile_catalog()
  var/list/catalog = list()
  if(!stored_profiles)
    return catalog

  for(var/datum/changeling_profile/profile as anything in stored_profiles)
    catalog += list(get_genetic_matrix_profile_data(profile))

  sortTim(catalog, GLOBAL_PROC_REF(cmp_assoc_list_name))
  return catalog

/// Provide profile data for the storage tab.
/datum/antagonist/changeling/proc/get_genetic_matrix_profile_storage()
  return get_genetic_matrix_profile_catalog()

/// Aggregate ability information available to the changeling.
/datum/antagonist/changeling/proc/get_genetic_matrix_ability_catalog()
  var/list/catalog = list()
  var/list/seen_paths = list()

  for(var/datum/action/changeling/innate as anything in innate_powers)
    var/path = innate.type
    if(!ispath(path))
      continue
    if(seen_paths[path])
      continue

    var/list/entry = get_genetic_matrix_ability_data(path)
    entry["source"] = "innate"
    catalog += list(entry)
    seen_paths[path] = TRUE

  for(var/path in purchased_powers)
    if(seen_paths[path])
      continue

    var/list/entry = get_genetic_matrix_ability_data(path)
    entry["source"] = "purchased"
    catalog += list(entry)
    seen_paths[path] = TRUE

  sortTim(catalog, GLOBAL_PROC_REF(cmp_assoc_list_name))
  return catalog

/// Provide detailed ability data for the storage tab.
/datum/antagonist/changeling/proc/get_genetic_matrix_ability_storage()
  var/datum/changeling_bio_incubator/incubator = get_bio_incubator()
  if(!incubator)
    return list()

  return incubator.get_modules_data()

/// Return a dataset summarizing the owner's skills.
/datum/antagonist/changeling/proc/get_genetic_matrix_skills_data()
  var/list/data = list()
  if(!owner)
    return data

  var/datum/mind/mind = owner
  if(!mind.known_skills)
    return data

  for(var/skill_type in mind.known_skills)
    var/datum/skill/skill_datum = skill_type
    var/level = mind.get_skill_level(skill_type)
    var/list/entry = list(
      "id" = "[skill_type]",
      "name" = initial(skill_datum.name),
      "level" = level,
      "levelName" = mind.get_skill_level_name(skill_type),
      "exp" = mind.get_skill_exp(skill_type),
      "desc" = initial(skill_datum.desc),
    )
    data += list(entry)

  sortTim(data, GLOBAL_PROC_REF(cmp_assoc_list_name))
  return data

/// Add a new matrix build for this changeling.
/datum/antagonist/changeling/proc/add_genetic_matrix_build(name)
  var/datum/changeling_bio_incubator/incubator = get_bio_incubator()
  if(!incubator)
    return null

  return incubator.add_build(name)

/// Remove and clean up an existing matrix build.
/datum/antagonist/changeling/proc/remove_genetic_matrix_build(datum/changeling_bio_build/build)
  var/datum/changeling_bio_incubator/incubator = get_bio_incubator()
  incubator?.remove_build(build)

/// Clear all assignments from a specific build without deleting it.
/datum/antagonist/changeling/proc/clear_genetic_matrix_build(datum/changeling_bio_build/build)
  var/datum/changeling_bio_incubator/incubator = get_bio_incubator()
  incubator?.clear_build(build)

/// Assign a DNA profile to a build.
/datum/antagonist/changeling/proc/assign_genetic_matrix_profile(datum/changeling_bio_build/build, datum/changeling_profile/profile)
  var/datum/changeling_bio_incubator/incubator = get_bio_incubator()
  incubator?.assign_profile(build, profile)

/// Assign an ability to a slot within a build. Passing null clears the slot.
/datum/antagonist/changeling/proc/assign_genetic_matrix_ability(datum/changeling_bio_build/build, ability_identifier, slot)
  var/datum/changeling_bio_incubator/incubator = get_bio_incubator()
  if(!incubator)
    return FALSE

  if(isnull(build))
    return FALSE

  if(isnull(ability_identifier))
    return incubator.assign_module(build, null, slot)

  var/module_identifier
  if(istext(ability_identifier))
    module_identifier = ability_identifier
  else if(ispath(ability_identifier, /datum/action/changeling))
    module_identifier = "[ability_identifier]"
  else if(istype(ability_identifier, /datum/changeling_bio_module))
    var/datum/changeling_bio_module/module = ability_identifier
    module_identifier = module.id
  else
    module_identifier = "[ability_identifier]"

  return incubator.assign_module(build, module_identifier, slot)

/// Determine whether the changeling currently possesses a given ability type.
/datum/antagonist/changeling/proc/has_genetic_matrix_ability(datum/action/changeling/ability_path)
  if(isnull(ability_path))
    return FALSE

  if(purchased_powers && purchased_powers[ability_path])
    return TRUE

  for(var/datum/action/changeling/innate as anything in innate_powers)
    if(innate.type == ability_path)
      return TRUE

  return FALSE

/// Locate a matrix build using its reference string.
/datum/antagonist/changeling/proc/find_genetic_matrix_build(identifier)
  var/datum/changeling_bio_incubator/incubator = get_bio_incubator()
  if(!incubator)
    return null

  return incubator.find_build(identifier)

/// Locate a stored profile using its reference string.
/datum/antagonist/changeling/proc/find_genetic_matrix_profile(identifier)
  if(isnull(identifier))
    return null

  for(var/datum/changeling_profile/profile as anything in stored_profiles)
    if(REF(profile) == identifier)
      return profile

  return null

/// Convert a stored profile to UI-friendly data.
/datum/antagonist/changeling/proc/get_genetic_matrix_profile_data(datum/changeling_profile/profile)
  var/list/quirk_names = list()
  for(var/datum/quirk/quirk as anything in profile.quirks)
    quirk_names += initial(quirk.name)

  var/list/skillchip_names = list()
  for(var/list/chip_metadata in profile.skillchips)
    var/chip_type = chip_metadata["type"]
    if(ispath(chip_type, /obj/item/skillchip))
      var/obj/item/skillchip/skillchip_type = chip_type
      skillchip_names += initial(skillchip_type.name)
    else if(chip_type)
      skillchip_names += "[chip_type]"

  return list(
    "id" = REF(profile),
    "name" = profile.name,
    "protected" = profile.protected,
    "age" = profile.age,
    "physique" = profile.physique,
    "voice" = profile.voice,
    "quirks" = quirk_names,
    "quirk_count" = quirk_names.len,
    "skillchips" = skillchip_names,
    "skillchip_count" = skillchip_names.len,
    "scar_count" = LAZYLEN(profile.stored_scars),
    "id_icon" = profile.id_icon,
  )

/// Convert an ability type path to UI-friendly data.
/datum/antagonist/changeling/proc/get_genetic_matrix_ability_data(datum/action/changeling/ability_path)
  var/list/data = list(
    "id" = "[ability_path]",
    "name" = initial(ability_path.name),
    "desc" = initial(ability_path.desc),
    "helptext" = initial(ability_path.helptext),
    "chemical_cost" = initial(ability_path.chemical_cost),
    "dna_cost" = initial(ability_path.dna_cost),
    "req_dna" = initial(ability_path.req_dna),
    "req_absorbs" = initial(ability_path.req_absorbs),
    "button_icon_state" = initial(ability_path.button_icon_state),
  )
  return data

/// Handle updates when a new DNA profile is added.
/datum/antagonist/changeling/proc/on_genetic_matrix_profile_added(datum/changeling_profile/profile)
  var/datum/changeling_bio_incubator/incubator = get_bio_incubator()
  if(!incubator)
    return

  incubator.on_profile_added(profile)

/// Handle updates when a DNA profile is removed.
/datum/antagonist/changeling/proc/on_genetic_matrix_profile_removed(datum/changeling_profile/profile)
  var/datum/changeling_bio_incubator/incubator = get_bio_incubator()
  incubator?.on_profile_removed(profile)

#undef GENETIC_MATRIX_MAX_ABILITY_SLOTS
#undef GENETIC_MATRIX_MAX_BUILDS


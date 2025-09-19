#define CHANGELING_BIO_MAX_MODULE_SLOTS 8
#define CHANGELING_BIO_MAX_BUILD_COUNT 6
#define CHANGELING_BIO_KEY_SLOT 1

#define CHANGELING_BIO_MODULE_CATEGORY_KEY_ACTIVE "key_active"
#define CHANGELING_BIO_MODULE_CATEGORY_PASSIVE "passive"
#define CHANGELING_BIO_MODULE_CATEGORY_UPGRADE "upgrade"
#define CHANGELING_BIO_MODULE_CATEGORY_GENERAL "general"

/datum/changeling_bio_incubator
  /// Owning changeling datum.
  var/datum/antagonist/changeling/changeling
  /// Cytology cell identifiers collected by this changeling.
  var/list/collected_cell_ids = list()
  /// Recipe identifiers unlocked for module crafting.
  var/list/learned_recipe_ids = list()
  /// Mapping of module identifiers to crafted module datums.
  var/list/crafted_modules = list()
  /// Builds configured for the genetic matrix UI.
  var/list/build_presets = list()

  New(datum/antagonist/changeling/changeling_owner)
    . = ..()
    changeling = changeling_owner

  Destroy()
    changeling = null
    if(build_presets)
      for(var/datum/changeling_bio_build/build as anything in build_presets)
        qdel(build)
    build_presets = null

    if(crafted_modules)
      for(var/module_id in crafted_modules)
        var/datum/changeling_bio_module/module = crafted_modules[module_id]
        qdel(module)
    crafted_modules = null

    collected_cell_ids = null
    learned_recipe_ids = null
    return ..()

  /// Ensure that the incubator always has at least one build available.
  proc/ensure_default_build()
    if(build_presets && build_presets.len)
      return
    add_build("Matrix Build 1")

  /// Remove invalid references from tracked builds and module assignments.
  proc/prune_build_assignments()
    if(!build_presets?.len)
      return

    for(var/datum/changeling_bio_build/build as anything in build_presets)
      build.prune_assignments()

  /// Generate UI data for matrix builds.
  proc/get_builds_data()
    var/list/output = list()
    if(!build_presets?.len)
      return output

    for(var/datum/changeling_bio_build/build as anything in build_presets)
      output += list(build.to_data())

    return output

  /// Generate UI data for stored cytology cells.
  proc/get_cells_data()
    var/list/output = list()
    if(!collected_cell_ids?.len)
      return output

  for(var/cell_id in collected_cell_ids)
      output += list(list(
        "id" = "[cell_id]",
        "name" = "[cell_id]",
        "protected" = FALSE,
        "age" = null,
        "physique" = null,
        "voice" = null,
        "quirks" = list(),
        "quirk_count" = 0,
        "skillchips" = list(),
        "skillchip_count" = 0,
        "scar_count" = 0,
        "id_icon" = null,
      ))
    return output

  /// Generate UI data for known recipes.
  proc/get_recipes_data()
    var/list/output = list()
    if(!learned_recipe_ids?.len)
      return output

    for(var/recipe_id in learned_recipe_ids)
      output += list(list(
        "id" = "[recipe_id]",
        "name" = "[recipe_id]",
      ))
    return output

  /// Generate UI data for crafted modules.
  proc/get_modules_data()
    var/list/output = list()
    if(!crafted_modules?.len)
      return output

    for(var/module_id in crafted_modules)
      var/datum/changeling_bio_module/module = crafted_modules[module_id]
      if(!module)
        continue
      output += list(module.to_data())
    sortTim(output, GLOBAL_PROC_REF(cmp_assoc_list_name))
    return output

  /// Locate a crafted module by identifier.
  proc/find_module(identifier)
    if(isnull(identifier) || !crafted_modules)
      return null
    if(crafted_modules[identifier])
      return crafted_modules[identifier]
    return null

  /// Ensure a module exists for the provided ability path and return it.
  proc/get_or_create_ability_module(datum/action/changeling/ability_path)
    if(isnull(ability_path))
      return null

    var/id = "[ability_path]"
    var/datum/changeling_bio_module/module = find_module(id)
    if(module)
      return module

    module = new(src)
    module.id = id
    module.name = initial(ability_path.name)
    module.category = CHANGELING_BIO_MODULE_CATEGORY_GENERAL
    module.allow_duplicates = FALSE
    module.ability_path = ability_path
    module.source = "ability"
    crafted_modules[id] = module
    SEND_SIGNAL(src, COMSIG_CHANGELING_BIO_INCUBATOR_MODULES_CHANGED, module)
    SEND_SIGNAL(src, COMSIG_CHANGELING_BIO_INCUBATOR_DIRTY)
    return module

  /// Add a new build to the incubator.
  proc/add_build(name)
    if(!build_presets)
      build_presets = list()
    var/datum/changeling_bio_build/build = new(src)
    build.name = name
    build.ensure_slot_capacity()
    build_presets += build
    SEND_SIGNAL(src, COMSIG_CHANGELING_BIO_INCUBATOR_BUILDS_CHANGED, build)
    SEND_SIGNAL(src, COMSIG_CHANGELING_BIO_INCUBATOR_DIRTY)
    return build

  /// Remove and delete an existing build.
  proc/remove_build(datum/changeling_bio_build/build)
    if(!build)
      return
    if(build_presets?.len && (build in build_presets))
      build_presets -= build
    qdel(build)
    SEND_SIGNAL(src, COMSIG_CHANGELING_BIO_INCUBATOR_BUILDS_CHANGED, null)
    SEND_SIGNAL(src, COMSIG_CHANGELING_BIO_INCUBATOR_DIRTY)

  /// Clear all assignments from a build.
  proc/clear_build(datum/changeling_bio_build/build)
    if(!build)
      return
    build.clear_assignments()
    SEND_SIGNAL(src, COMSIG_CHANGELING_BIO_INCUBATOR_BUILDS_CHANGED, build)
    SEND_SIGNAL(src, COMSIG_CHANGELING_BIO_INCUBATOR_DIRTY)

  /// Assign a DNA profile to the provided build.
  proc/assign_profile(datum/changeling_bio_build/build, datum/changeling_profile/profile)
    if(!build)
      return
    if(profile && changeling && !(profile in changeling.stored_profiles))
      return
    build.assigned_profile = profile
    SEND_SIGNAL(src, COMSIG_CHANGELING_BIO_INCUBATOR_BUILDS_CHANGED, build)
    SEND_SIGNAL(src, COMSIG_CHANGELING_BIO_INCUBATOR_DIRTY)

  /// Assign a module to a specific slot on a build. Passing null clears the slot.
  proc/assign_module(datum/changeling_bio_build/build, identifier, slot)
    if(!build)
      return FALSE

    var/datum/changeling_bio_module/module
    if(!isnull(identifier))
      module = find_module(identifier)
      if(!module)
        var/datum/action/changeling/ability_path = text2path(identifier)
        if(ispath(ability_path, /datum/action/changeling))
          module = get_or_create_ability_module(ability_path)
      if(!module)
        return FALSE

    if(!build.set_module(slot, module))
      return FALSE

    SEND_SIGNAL(src, COMSIG_CHANGELING_BIO_INCUBATOR_BUILDS_CHANGED, build)
    SEND_SIGNAL(src, COMSIG_CHANGELING_BIO_INCUBATOR_DIRTY)
    return TRUE

  /// Locate a build using its reference identifier string.
  proc/find_build(identifier)
    if(isnull(identifier) || !build_presets?.len)
      return null

    for(var/datum/changeling_bio_build/build as anything in build_presets)
      if(REF(build) == identifier)
        return build

    return null

  /// Whether we can add more builds without exceeding the configured cap.
  proc/can_add_build()
    return !build_presets || (build_presets.len < CHANGELING_BIO_MAX_BUILD_COUNT)

  /// Handle bookkeeping when a new profile is added to the changeling.
  proc/on_profile_added(datum/changeling_profile/profile)
    if(!profile)
      return
    ensure_default_build()
    for(var/datum/changeling_bio_build/build as anything in build_presets)
      if(build.assigned_profile)
        continue
      build.assigned_profile = profile
      SEND_SIGNAL(src, COMSIG_CHANGELING_BIO_INCUBATOR_BUILDS_CHANGED, build)
      SEND_SIGNAL(src, COMSIG_CHANGELING_BIO_INCUBATOR_DIRTY)
      break

  /// Remove references to a profile that has been deleted.
  proc/on_profile_removed(datum/changeling_profile/profile)
    if(!profile || !build_presets?.len)
      return

    var/changed = FALSE
    for(var/datum/changeling_bio_build/build as anything in build_presets)
      if(build.assigned_profile != profile)
        continue
      build.assigned_profile = null
      changed = TRUE
    if(changed)
      SEND_SIGNAL(src, COMSIG_CHANGELING_BIO_INCUBATOR_BUILDS_CHANGED, null)
      SEND_SIGNAL(src, COMSIG_CHANGELING_BIO_INCUBATOR_DIRTY)

  /// Attempt to record a new cell identifier.
  proc/add_cell(cell_id)
    if(isnull(cell_id))
      return FALSE
    if(!collected_cell_ids)
      collected_cell_ids = list()
    if(cell_id in collected_cell_ids)
      return FALSE
    collected_cell_ids += cell_id
    SEND_SIGNAL(src, COMSIG_CHANGELING_BIO_INCUBATOR_CELLS_CHANGED, cell_id)
    SEND_SIGNAL(src, COMSIG_CHANGELING_BIO_INCUBATOR_DIRTY)
    return TRUE

  /// Remove a stored cell identifier.
  proc/remove_cell(cell_id)
    if(isnull(cell_id) || !collected_cell_ids?.len)
      return FALSE
    if(!(cell_id in collected_cell_ids))
      return FALSE
    collected_cell_ids -= cell_id
    SEND_SIGNAL(src, COMSIG_CHANGELING_BIO_INCUBATOR_CELLS_CHANGED, cell_id)
    SEND_SIGNAL(src, COMSIG_CHANGELING_BIO_INCUBATOR_DIRTY)
    return TRUE

  /// Mark a recipe as known.
  proc/learn_recipe(recipe_id)
    if(isnull(recipe_id))
      return FALSE
    if(!learned_recipe_ids)
      learned_recipe_ids = list()
    if(recipe_id in learned_recipe_ids)
      return FALSE
    learned_recipe_ids += recipe_id
    SEND_SIGNAL(src, COMSIG_CHANGELING_BIO_INCUBATOR_RECIPES_CHANGED, recipe_id)
    SEND_SIGNAL(src, COMSIG_CHANGELING_BIO_INCUBATOR_DIRTY)
    return TRUE

  /// Forget a known recipe.
  proc/unlearn_recipe(recipe_id)
    if(isnull(recipe_id) || !learned_recipe_ids?.len)
      return FALSE
    if(!(recipe_id in learned_recipe_ids))
      return FALSE
    learned_recipe_ids -= recipe_id
    SEND_SIGNAL(src, COMSIG_CHANGELING_BIO_INCUBATOR_RECIPES_CHANGED, recipe_id)
    SEND_SIGNAL(src, COMSIG_CHANGELING_BIO_INCUBATOR_DIRTY)
    return TRUE

/// Individual build configuration stored within the incubator.
/datum/changeling_bio_build
  var/datum/changeling_bio_incubator/incubator
  var/name = "Matrix Build"
  var/datum/changeling_profile/assigned_profile
  var/list/module_ids = list()

  New(datum/changeling_bio_incubator/incubator_owner)
    . = ..()
    incubator = incubator_owner

  Destroy()
    assigned_profile = null
    module_ids = null
    incubator = null
    return ..()

  /// Make sure the module id list always has a slot entry for each possible slot.
  proc/ensure_slot_capacity()
    while(module_ids.len < CHANGELING_BIO_MAX_MODULE_SLOTS)
      module_ids += null

  /// Remove any stale references from this build.
  proc/prune_assignments()
    ensure_slot_capacity()
    if(assigned_profile && !(assigned_profile in incubator?.changeling?.stored_profiles))
      assigned_profile = null

    var/list/seen_modules = list()
    for(var/i in 1 to module_ids.len)
      var/module_id = module_ids[i]
      if(isnull(module_id))
        continue
      var/datum/changeling_bio_module/module = incubator?.find_module(module_id)
      if(!module || !module.is_valid_slot(i) || !module.is_available())
        module_ids[i] = null
        continue
      if(!module.allow_duplicates && seen_modules[module_id])
        module_ids[i] = null
        continue
      seen_modules[module_id] = TRUE

  /// Clear profile and module assignments.
  proc/clear_assignments()
    assigned_profile = null
    ensure_slot_capacity()
    for(var/i in 1 to module_ids.len)
      module_ids[i] = null

  /// Attempt to assign a module to a particular slot.
  proc/set_module(slot, datum/changeling_bio_module/module)
    ensure_slot_capacity()
    if(slot < 1 || slot > CHANGELING_BIO_MAX_MODULE_SLOTS)
      return FALSE

    if(isnull(module))
      module_ids[slot] = null
      return TRUE

    if(!module.is_valid_slot(slot))
      return FALSE

    if(!module.allow_duplicates)
      for(var/i in 1 to module_ids.len)
        if(i == slot)
          continue
        if(module_ids[i] == module.id)
          return FALSE

    if(!module.is_available())
      return FALSE

    module_ids[slot] = module.id
    return TRUE

  /// Convert this build to UI-friendly data.
  proc/to_data()
    var/list/data = list(
      "id" = REF(src),
      "name" = name,
    )

    var/datum/antagonist/changeling/changeling_owner = incubator?.changeling
    if(changeling_owner && assigned_profile && (assigned_profile in changeling_owner.stored_profiles))
      data["profile"] = changeling_owner.get_genetic_matrix_profile_data(assigned_profile)
    else
      data["profile"] = null

    ensure_slot_capacity()
    var/list/module_data = list()
    for(var/i in 1 to module_ids.len)
      var/module_id = module_ids[i]
      if(isnull(module_id))
        module_data += list(null)
        continue

      var/datum/changeling_bio_module/module = incubator?.find_module(module_id)
      if(!module)
        module_data += list(null)
        module_ids[i] = null
        continue

      if(!module.is_valid_slot(i) || !module.is_available())
        module_data += list(null)
        module_ids[i] = null
        continue

      module_data += list(module.to_slot_data(i))

    data["abilities"] = module_data
    return data

/// Representation of a crafted genetic module.
/datum/changeling_bio_module
  var/datum/changeling_bio_incubator/incubator
  var/id
  var/name = "Genetic Module"
  var/category = CHANGELING_BIO_MODULE_CATEGORY_GENERAL
  var/source = "crafted"
  var/allow_duplicates = FALSE
  var/allow_key_slot = TRUE
  var/list/required_cells = list()
  var/list/required_abilities = list()
  var/datum/action/changeling/ability_path/ability_path

  New(datum/changeling_bio_incubator/incubator_owner)
    . = ..()
    incubator = incubator_owner

  Destroy()
    incubator = null
    required_cells = null
    required_abilities = null
    ability_path = null
    return ..()

  /// Whether this module may be used in the specified slot.
  proc/is_valid_slot(slot)
    if(slot < 1 || slot > CHANGELING_BIO_MAX_MODULE_SLOTS)
      return FALSE
    if(category == CHANGELING_BIO_MODULE_CATEGORY_KEY_ACTIVE)
      return slot == CHANGELING_BIO_KEY_SLOT
    if(slot == CHANGELING_BIO_KEY_SLOT)
      return allow_key_slot
    return TRUE

  /// Whether this module can currently be used by the owning changeling.
  proc/is_available()
    if(!ability_path)
      return TRUE
    return incubator?.changeling?.has_genetic_matrix_ability(ability_path) ?? FALSE

  /// Produce UI data for storage displays.
  proc/to_data()
  var/list/data = list(
    "id" = id,
    "name" = name,
    "category" = category,
    "source" = source,
    "allowsDuplicates" = allow_duplicates,
    "allowKeySlot" = allow_key_slot,
    "requiredCells" = required_cells?.Copy(),
    "requiredAbilities" = required_abilities?.Copy(),
    "desc" = null,
    "helptext" = null,
    "chemical_cost" = null,
    "dna_cost" = null,
    "req_dna" = null,
    "req_absorbs" = null,
    "button_icon_state" = null,
  )

    if(ability_path && incubator?.changeling)
      var/list/ability_data = incubator.changeling.get_genetic_matrix_ability_data(ability_path)
      if(ability_data)
        if(!name || name == initial(name))
          data["name"] = ability_data["name"]
        data["abilityId"] = ability_data["id"]
        for(var/key in ability_data)
          if(isnull(data[key]))
            data[key] = ability_data[key]
    if(isnull(data["chemical_cost"]))
      data["chemical_cost"] = 0
    if(isnull(data["dna_cost"]))
      data["dna_cost"] = 0
    if(isnull(data["req_dna"]))
      data["req_dna"] = 0
    if(isnull(data["req_absorbs"]))
      data["req_absorbs"] = 0
    if(isnull(data["desc"]))
      data["desc"] = ""
    if(isnull(data["helptext"]))
      data["helptext"] = ""
    return data

  /// Produce UI data for slot assignments.
  proc/to_slot_data(slot)
    var/list/data
    if(ability_path && incubator?.changeling)
      data = incubator.changeling.get_genetic_matrix_ability_data(ability_path)
    if(!data)
      data = list(
        "id" = id,
        "name" = name,
        "desc" = "",
        "helptext" = "",
        "chemical_cost" = 0,
        "dna_cost" = 0,
        "req_dna" = 0,
        "req_absorbs" = 0,
        "button_icon_state" = null,
      )
    data["slot"] = slot
    data["moduleId"] = id
    data["moduleCategory"] = category
    data["moduleSource"] = source
    return data

#undef CHANGELING_BIO_MODULE_CATEGORY_KEY_ACTIVE
#undef CHANGELING_BIO_MODULE_CATEGORY_PASSIVE
#undef CHANGELING_BIO_MODULE_CATEGORY_UPGRADE
#undef CHANGELING_BIO_MODULE_CATEGORY_GENERAL
#undef CHANGELING_BIO_MAX_MODULE_SLOTS
#undef CHANGELING_BIO_MAX_BUILD_COUNT
#undef CHANGELING_BIO_KEY_SLOT

#define GENETIC_MATRIX_CATEGORY_KEY "key_active"
#define GENETIC_MATRIX_CATEGORY_PASSIVE "passive"
#define GENETIC_MATRIX_CATEGORY_UPGRADE "upgrade"

GLOBAL_LIST_EMPTY(changeling_genetic_module_types)
GLOBAL_LIST_INIT(changeling_genetic_matrix_recipes, setup_changeling_genetic_matrix_recipes())

/// Movespeed modifier used for genetic matrix passive bonuses.
/datum/movespeed_modifier/changeling/genetic_matrix
	id = "changeling_genetic_matrix"
	variable = TRUE

/// Base type used to define a genetic matrix recipe entry.
/datum/changeling_genetic_matrix_recipe
	/// Unique identifier for the recipe and crafted module.
	var/id = ""
	/// Display name for the recipe entry.
	var/name = ""
	/// Short description of the recipe entry.
	var/description = ""
	/// Metadata describing the crafted module.
	var/list/module = list()
	/// The module type spawned when crafting this recipe.
	var/module_type
	/// Cells required to craft the recipe.
	var/list/required_cells = list()
	/// Abilities required to unlock the recipe.
	var/list/required_abilities = list()
	/// Additional root-level data to append to the recipe payload.
	var/list/extra_fields

/datum/changeling_genetic_matrix_recipe/proc/build_module_data()
	var/list/block = LAZYCOPY(module)
	if(!islist(block))
		block = list()
	if(!block["id"])
		block["id"] = id
	if(!block["name"])
		block["name"] = name
	if(!block["desc"])
		block["desc"] = description
	if(module_type && !block["moduleType"])
		block["moduleType"] = module_type
	if(islist(block["effects"]))
		block["effects"] = block["effects"].Copy()
	return block

/datum/changeling_genetic_matrix_recipe/proc/build_recipe()
	if(!istext(id) || !length(id))
		stack_trace("Changeling genetic matrix recipe missing id on [type]")
		return null
	var/list/data = list(
		"id" = id,
		"name" = name,
		"desc" = description,
		"module" = build_module_data(),
		"requiredCells" = required_cells?.Copy() || list(),
		"requiredAbilities" = required_abilities?.Copy() || list(),
	)
	if(islist(extra_fields))
		for(var/key in extra_fields)
			data[key] = extra_fields[key]
	return data

/// Assemble the genetic matrix recipe catalog from all defined recipes.
/proc/setup_changeling_genetic_matrix_recipes()
	var/list/output = list()
	GLOB.changeling_genetic_module_types = list()
	for(var/recipe_type as anything in subtypesof(/datum/changeling_genetic_matrix_recipe))
		if(recipe_type == /datum/changeling_genetic_matrix_recipe)
			continue
		var/datum/changeling_genetic_matrix_recipe/recipe = new recipe_type
		var/list/data = recipe.build_recipe()
		if(!islist(data))
			qdel(recipe)
			continue
		var/recipe_id = data["id"]
		if(output[recipe_id])
			stack_trace("Duplicate changeling genetic matrix recipe id [recipe_id]")
			qdel(recipe)
			continue
		output[recipe_id] = data
		var/list/module_data = data["module"]
		if(islist(module_data))
			var/module_type = module_data["moduleType"]
			if(ispath(module_type, /datum/changeling_genetic_module))
				GLOB.changeling_genetic_module_types[recipe_id] = module_type
		qdel(recipe)
	return output

/// Produce a baseline dictionary for matrix effects with sensible defaults.
/proc/changeling_get_default_matrix_effects()
	return list(
		"move_speed_slowdown" = 0,
		"stamina_use_mult" = 1,
		"stamina_regen_time_mult" = 1,
		"max_stamina_add" = 0,
		"chem_recharge_rate_add" = 0,
		"sting_range_add" = 0,
		"fleshmend_duration_add" = 0,
		"fleshmend_heal_mult" = 1,
		"harvest_cells_chem_discount" = 0,
		"harvest_cells_bonus_range" = 0,
		"biodegrade_timer_mult" = 1,
		"biodegrade_chem_discount" = 0,
		"resonant_shriek_range_add" = 0,
		"resonant_shriek_confusion_mult" = 1,
		"dissonant_shriek_emp_range_add" = 0,
		"dissonant_shriek_structure_mult" = 1,
		"incoming_brute_damage_mult" = 1,
		"incoming_burn_damage_mult" = 1,
	)

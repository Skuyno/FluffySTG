#define CHANGELING_CELL_REGISTRY_NAME "name"
#define CHANGELING_CELL_REGISTRY_DESC "desc"
#define CHANGELING_CELL_REGISTRY_KEYWORDS "keywords"
#define CHANGELING_CELL_REGISTRY_TYPES "types"
#define CHANGELING_CELL_REGISTRY_SPECIES "species"

#define CHANGELING_CELL_ID_HUMAN "human"
#define CHANGELING_CELL_ID_VOX "vox"
#define CHANGELING_CELL_ID_TAJARAN "tajaran"
#define CHANGELING_CELL_ID_TESHARI "teshari"
#define CHANGELING_CELL_ID_CHICKEN "chicken"
#define CHANGELING_CELL_ID_COW "cow"
#define CHANGELING_CELL_ID_GOAT "goat"
#define CHANGELING_CELL_ID_RARE_PREDATOR "rare_predator"
#define CHANGELING_CELL_ID_COLOSSUS "colossus"

GLOBAL_LIST_INIT(changeling_cell_registry, list(
    CHANGELING_CELL_ID_HUMAN = list(
        CHANGELING_CELL_REGISTRY_NAME = "Human Crew",
        CHANGELING_CELL_REGISTRY_DESC = "Baseline Nanotrasen crew biomatter.",
        CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_HUMAN),
        CHANGELING_CELL_REGISTRY_KEYWORDS = list("human", "crew"),
        CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/carbon/human),
    ),
    CHANGELING_CELL_ID_VOX = list(
        CHANGELING_CELL_REGISTRY_NAME = "Vox",
        CHANGELING_CELL_REGISTRY_DESC = "Avian cortical cluster harvested from Vox biology.",
        CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_VOX, SPECIES_VOX_PRIMALIS),
        CHANGELING_CELL_REGISTRY_KEYWORDS = list("vox"),
    ),
    CHANGELING_CELL_ID_TAJARAN = list(
        CHANGELING_CELL_REGISTRY_NAME = "Tajaran",
        CHANGELING_CELL_REGISTRY_DESC = "Feline survival tissues gleaned from Tajaran hosts.",
        CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_TAJARAN),
        CHANGELING_CELL_REGISTRY_KEYWORDS = list("tajaran"),
    ),
    CHANGELING_CELL_ID_TESHARI = list(
        CHANGELING_CELL_REGISTRY_NAME = "Teshari",
        CHANGELING_CELL_REGISTRY_DESC = "Lightweight musculature adapted for Teshari sprinters.",
        CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_TESHARI),
        CHANGELING_CELL_REGISTRY_KEYWORDS = list("teshari"),
    ),
    CHANGELING_CELL_ID_CHICKEN = list(
        CHANGELING_CELL_REGISTRY_NAME = "Chicken",
        CHANGELING_CELL_REGISTRY_DESC = "Docile barnyard avian samples.",
        CHANGELING_CELL_REGISTRY_TYPES = list(
            /mob/living/basic/chicken,
            /obj/item/food/meat/slab/chicken,
            /obj/item/food/meat/rawcutlet/chicken,
            /obj/item/food/meat/cutlet/chicken,
            /obj/item/food/meat/steak/chicken,
        ),
        CHANGELING_CELL_REGISTRY_KEYWORDS = list("chicken", "hen"),
    ),
    CHANGELING_CELL_ID_COW = list(
        CHANGELING_CELL_REGISTRY_NAME = "Cow",
        CHANGELING_CELL_REGISTRY_DESC = "Heavy livestock tissue lattice.",
        CHANGELING_CELL_REGISTRY_TYPES = list(
            /mob/living/basic/cow,
            /obj/item/food/meat/slab/grassfed,
        ),
        CHANGELING_CELL_REGISTRY_KEYWORDS = list("cow", "cattle", "grassfed", "eco"),
    ),
    CHANGELING_CELL_ID_GOAT = list(
        CHANGELING_CELL_REGISTRY_NAME = "Goat",
        CHANGELING_CELL_REGISTRY_DESC = "Stubborn grazer tissues ideal for endurance grafts.",
        CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/basic/goat),
        CHANGELING_CELL_REGISTRY_KEYWORDS = list("goat"),
    ),
    CHANGELING_CELL_ID_RARE_PREDATOR = list(
        CHANGELING_CELL_REGISTRY_NAME = "Apex Predator",
        CHANGELING_CELL_REGISTRY_DESC = "Hyperdense combat fibers from rare predators.",
        CHANGELING_CELL_REGISTRY_TYPES = list(
            /mob/living/basic/carp,
            /mob/living/basic/carp/mega,
            /mob/living/simple_animal/hostile/megafauna,
        ),
        CHANGELING_CELL_REGISTRY_KEYWORDS = list("predator", "megafauna", "carp", "dragon", "goliath"),
    ),
    CHANGELING_CELL_ID_COLOSSUS = list(
        CHANGELING_CELL_REGISTRY_NAME = "Colossus",
        CHANGELING_CELL_REGISTRY_DESC = "Crystalline lattice fragments from a lavaland colossus.",
        CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/simple_animal/hostile/megafauna/colossus),
        CHANGELING_CELL_REGISTRY_KEYWORDS = list("colossus"),
    ),
))

/proc/changeling_get_cell_registry()
    return GLOB.changeling_cell_registry

/proc/changeling_normalize_match_text(text)
    var/value = trimtext(isnull(text) ? "" : "[text]")
    if(!length(value))
        return ""
    return lowertext(value)

/proc/changeling_text_matches(a, b)
    var/normalized_a = changeling_normalize_match_text(a)
    var/normalized_b = changeling_normalize_match_text(b)
    if(!length(normalized_a) || !length(normalized_b))
        return FALSE
    return normalized_a == normalized_b

/proc/changeling_cell_id_exists(cell_identifier)
    var/cell_id = changeling_normalize_cell_id(cell_identifier)
    return !isnull(cell_id)

/proc/changeling_normalize_cell_id(cell_identifier)
    if(isnull(cell_identifier))
        return null
    var/text_value = changeling_normalize_match_text(cell_identifier)
    if(!length(text_value))
        return null
    if(!(text_value in changeling_get_cell_registry()))
        return null
    return text_value

/proc/changeling_get_cell_metadata(cell_identifier)
    var/cell_id = changeling_normalize_cell_id(cell_identifier)
    if(isnull(cell_id))
        return null
    var/list/registry = changeling_get_cell_registry()
    var/list/entry = registry?[cell_id]
    return islist(entry) ? entry : null

/proc/changeling_get_cell_display_name(cell_identifier)
    var/list/entry = changeling_get_cell_metadata(cell_identifier)
    if(entry)
        var/name = entry[CHANGELING_CELL_REGISTRY_NAME]
        if(length(name))
            return "[name]"
    var/text_value = replacetext("[cell_identifier]", "_", " ")
    return capitalize(text_value)

/proc/changeling_registry_entry_matches_name(list/entry, normalized_name)
    if(!islist(entry) || !length(normalized_name))
        return FALSE
    var/entry_name = changeling_normalize_match_text(entry[CHANGELING_CELL_REGISTRY_NAME])
    if(length(entry_name) && findtext(normalized_name, entry_name))
        return TRUE
    var/list/keywords = entry[CHANGELING_CELL_REGISTRY_KEYWORDS]
    if(islist(keywords))
        for(var/keyword in keywords)
            var/normalized_keyword = changeling_normalize_match_text(keyword)
            if(!length(normalized_keyword))
                continue
            if(findtext(normalized_name, normalized_keyword))
                return TRUE
    return FALSE

/proc/changeling_registry_entry_matches_species(list/entry, species_id)
    var/list/species_ids = entry[CHANGELING_CELL_REGISTRY_SPECIES]
    if(!islist(species_ids) || !species_ids.len)
        return FALSE
    var/normalized_species = changeling_normalize_match_text(species_id)
    if(!length(normalized_species))
        return FALSE
    for(var/species_candidate in species_ids)
        if(changeling_text_matches(normalized_species, species_candidate))
            return TRUE
    return FALSE

/proc/changeling_registry_entry_matches_type(list/entry, atom/target)
       var/list/type_list = entry[CHANGELING_CELL_REGISTRY_TYPES]
       if(!islist(type_list) || !type_list.len)
               return FALSE
       for(var/path in type_list)
               if(ispath(path) && istype(target, path))
            return TRUE
    return FALSE

/proc/changeling_get_species_id_for_mob(mob/living/target)
    if(!target)
        return null
    if(ishuman(target))
        var/mob/living/carbon/human/human_target = target
        return human_target.dna?.species?.id
    if(iscarbon(target))
        var/mob/living/carbon/carbon_target = target
        return carbon_target.dna?.species?.id
    return null

/proc/changeling_get_match_names_for_mob(mob/living/target)
    var/list/names = list()
    if(!target)
        return names
    if(ishuman(target))
        var/mob/living/carbon/human/human_target = target
        if(length(human_target.real_name))
            var/normalized_real_name = changeling_normalize_match_text(human_target.real_name)
            if(length(normalized_real_name))
                names += normalized_real_name
    var/normalized_name = changeling_normalize_match_text(target.name)
    if(length(normalized_name))
        names += normalized_name
    return names

/proc/changeling_get_cell_ids_from_name(sample_name)
       var/list/results = list()
       var/normalized_name = changeling_normalize_match_text(sample_name)
       if(!length(normalized_name))
               return results
       var/list/registry = changeling_get_cell_registry()
       for(var/cell_id in registry)
               var/list/entry = registry[cell_id]
               if(!islist(entry))
                       continue
               if(changeling_registry_entry_matches_name(entry, normalized_name))
                       if(!(cell_id in results))
                               results += cell_id
       return results

/proc/changeling_get_cell_ids_from_atom(atom/target)
       var/list/results = list()
       if(!target)
               return results
       var/list/registry = changeling_get_cell_registry()
       for(var/cell_id as anything in changeling_get_cell_ids_from_name(target.name))
               if(!(cell_id in results))
                       results += cell_id
       for(var/cell_id in registry)
               var/list/entry = registry[cell_id]
               if(!islist(entry))
                       continue
               if(changeling_registry_entry_matches_type(entry, target))
                       if(!(cell_id in results))
                               results += cell_id
       return results

/proc/changeling_get_cell_ids_from_mob(mob/living/target)
       var/list/results = list()
       if(!target)
               return results
    var/list/registry = changeling_get_cell_registry()
    var/species_id = changeling_get_species_id_for_mob(target)
    var/list/match_names = changeling_get_match_names_for_mob(target)
    for(var/cell_id in registry)
        var/list/entry = registry[cell_id]
        if(!islist(entry))
            continue
        if(changeling_registry_entry_matches_species(entry, species_id))
            if(!(cell_id in results))
                results += cell_id
            continue
        if(changeling_registry_entry_matches_type(entry, target))
            if(!(cell_id in results))
                results += cell_id
            continue
        if(!islist(match_names))
            continue
        for(var/name_entry in match_names)
            if(!istext(name_entry))
                continue
            if(changeling_registry_entry_matches_name(entry, name_entry))
                if(!(cell_id in results))
                    results += cell_id
                break
    return results


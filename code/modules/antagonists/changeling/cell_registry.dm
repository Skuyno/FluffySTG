#define CHANGELING_CELL_REGISTRY_NAME "name"
#define CHANGELING_CELL_REGISTRY_DESC "desc"
#define CHANGELING_CELL_REGISTRY_KEYWORDS "keywords"
#define CHANGELING_CELL_REGISTRY_TYPES "types"
#define CHANGELING_CELL_REGISTRY_SPECIES "species"

#define CHANGELING_CELL_ID_HUMAN "human"
#define CHANGELING_CELL_ID_LIZARD "lizard"
#define CHANGELING_CELL_ID_UNATHI "unathi"
#define CHANGELING_CELL_ID_VOX "vox"
#define CHANGELING_CELL_ID_TAJARAN "tajaran"
#define CHANGELING_CELL_ID_TESHARI "teshari"
#define CHANGELING_CELL_ID_FELINID "felinid"
#define CHANGELING_CELL_ID_VULPKANIN "vulpkanin"
#define CHANGELING_CELL_ID_AKULA "akula"
#define CHANGELING_CELL_ID_SKRELL "skrell"
#define CHANGELING_CELL_ID_FLY "fly"
#define CHANGELING_CELL_ID_MOTH "moth"
#define CHANGELING_CELL_ID_PLASMAMAN "plasmaman"
#define CHANGELING_CELL_ID_ETHEREAL "ethereal"
#define CHANGELING_CELL_ID_SNAIL "snail"
#define CHANGELING_CELL_ID_MAMMAL "mammal"
#define CHANGELING_CELL_ID_HUMANOID "humanoid"
#define CHANGELING_CELL_ID_XENO "xeno"
#define CHANGELING_CELL_ID_SLIMEPERSON "slimeperson"
#define CHANGELING_CELL_ID_PODWEAK "podweak"
#define CHANGELING_CELL_ID_DWARF "dwarf"
#define CHANGELING_CELL_ID_SYNTH "synth"
#define CHANGELING_CELL_ID_AQUATIC "aquatic"
#define CHANGELING_CELL_ID_INSECT "insect"
#define CHANGELING_CELL_ID_INSECTOID "insectoid"
#define CHANGELING_CELL_ID_GHOUL "ghoul"
#define CHANGELING_CELL_ID_HEMOPHAGE "hemophage"
#define CHANGELING_CELL_ID_ABDUCTORWEAK "abductorweak"
#define CHANGELING_CELL_ID_KOBOLD "kobold"
#define CHANGELING_CELL_ID_NABBER "nabber"
#define CHANGELING_CELL_ID_SHADEKIN "shadekin"
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
        CHANGELING_CELL_ID_LIZARD = list(
                CHANGELING_CELL_REGISTRY_NAME = "Lizard",
                CHANGELING_CELL_REGISTRY_DESC = "Cold-blooded scales and temperature-bleeding musculature from lizardfolk.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_LIZARD, SPECIES_LIZARD_ASH, SPECIES_LIZARD_SILVER),
                CHANGELING_CELL_REGISTRY_KEYWORDS = list("lizard", "ashwalker", "silverscale"),
        ),
        CHANGELING_CELL_ID_UNATHI = list(
                CHANGELING_CELL_REGISTRY_NAME = "Unathi",
                CHANGELING_CELL_REGISTRY_DESC = "Saurian endocrine mesh and disciplined muscle fiber cultivated from Unathi hunters.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_UNATHI),
                CHANGELING_CELL_REGISTRY_KEYWORDS = list("unathi"),
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
        CHANGELING_CELL_ID_FELINID = list(
                CHANGELING_CELL_REGISTRY_NAME = "Felinid",
                CHANGELING_CELL_REGISTRY_DESC = "Feline balance organs and quick-twitch tendons from agile felinids.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_FELINE, SPECIES_FELINE_PRIMITIVE),
                CHANGELING_CELL_REGISTRY_KEYWORDS = list("felinid", "cat"),
        ),
        CHANGELING_CELL_ID_VULPKANIN = list(
                CHANGELING_CELL_REGISTRY_NAME = "Vulpkanin",
                CHANGELING_CELL_REGISTRY_DESC = "Canid olfactory bundles and endurance-ready musculature from vulpkanin scouts.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_VULP),
                CHANGELING_CELL_REGISTRY_KEYWORDS = list("vulpkanin", "fox"),
        ),
        CHANGELING_CELL_ID_AKULA = list(
                CHANGELING_CELL_REGISTRY_NAME = "Akula",
                CHANGELING_CELL_REGISTRY_DESC = "Hydrodynamic cartilage and saline-adapted musculature drawn from akula swimmers.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_AKULA),
                CHANGELING_CELL_REGISTRY_KEYWORDS = list("akula", "shark"),
        ),
        CHANGELING_CELL_ID_SKRELL = list(
                CHANGELING_CELL_REGISTRY_NAME = "Skrell",
                CHANGELING_CELL_REGISTRY_DESC = "Neural conduction gel and amphibious cartilage sourced from psionic skrell.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_SKRELL),
                CHANGELING_CELL_REGISTRY_KEYWORDS = list("skrell"),
        ),
        CHANGELING_CELL_ID_FLY = list(
                CHANGELING_CELL_REGISTRY_NAME = "Flyperson",
                CHANGELING_CELL_REGISTRY_DESC = "Proboscis musculature and hyperactive enzymes salvaged from hardy flypeople.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_FLYPERSON),
                CHANGELING_CELL_REGISTRY_KEYWORDS = list("fly", "flyperson"),
        ),
        CHANGELING_CELL_ID_MOTH = list(
                CHANGELING_CELL_REGISTRY_NAME = "Moth",
                CHANGELING_CELL_REGISTRY_DESC = "Powdered wing fibers and luminescent chitin drawn from mothkind.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_MOTH),
                CHANGELING_CELL_REGISTRY_KEYWORDS = list("moth", "mothman"),
        ),
        CHANGELING_CELL_ID_PLASMAMAN = list(
                CHANGELING_CELL_REGISTRY_NAME = "Plasmaman",
                CHANGELING_CELL_REGISTRY_DESC = "Encapsulated plasma membranes stabilized for plasmaman containment.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_PLASMAMAN),
                CHANGELING_CELL_REGISTRY_KEYWORDS = list("plasmaman", "plasma"),
        ),
        CHANGELING_CELL_ID_ETHEREAL = list(
                CHANGELING_CELL_REGISTRY_NAME = "Ethereal",
                CHANGELING_CELL_REGISTRY_DESC = "Ion-charged lattice and conductive nerve threads harvested from ethereals.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_ETHEREAL, SPECIES_ETHEREAL_LUSTROUS),
                CHANGELING_CELL_REGISTRY_KEYWORDS = list("ethereal", "luminescent"),
        ),
        CHANGELING_CELL_ID_SNAIL = list(
                CHANGELING_CELL_REGISTRY_NAME = "Snail",
                CHANGELING_CELL_REGISTRY_DESC = "Viscous regenerative tissue and calcified shell plates from gastropoid citizens.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_SNAIL),
                CHANGELING_CELL_REGISTRY_KEYWORDS = list("snail"),
        ),
        CHANGELING_CELL_ID_MAMMAL = list(
                CHANGELING_CELL_REGISTRY_NAME = "Mammal",
                CHANGELING_CELL_REGISTRY_DESC = "Baseline mammalian muscle weave and insulating follicle templates.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_MAMMAL),
                CHANGELING_CELL_REGISTRY_KEYWORDS = list("mammal"),
        ),
        CHANGELING_CELL_ID_HUMANOID = list(
                CHANGELING_CELL_REGISTRY_NAME = "Humanoid",
                CHANGELING_CELL_REGISTRY_DESC = "Generalist humanoid genome optimized for cross-compatible grafting.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_HUMANOID),
                CHANGELING_CELL_REGISTRY_KEYWORDS = list("humanoid"),
        ),
        CHANGELING_CELL_ID_XENO = list(
                CHANGELING_CELL_REGISTRY_NAME = "Xeno-Hybrid",
                CHANGELING_CELL_REGISTRY_DESC = "Acid-hardened sinew and adaptive chitin taken from xenobiological hybrids.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_XENO),
                CHANGELING_CELL_REGISTRY_KEYWORDS = list("xeno"),
        ),
        CHANGELING_CELL_ID_SLIMEPERSON = list(
                CHANGELING_CELL_REGISTRY_NAME = "Slimeperson",
                CHANGELING_CELL_REGISTRY_DESC = "Morphogenic cytoplasm and plasmid memory nodes siphoned from slime-derived crew.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_SLIMESTART, SPECIES_SLIMEPERSON),
                CHANGELING_CELL_REGISTRY_KEYWORDS = list("slime", "slimeperson"),
        ),
        CHANGELING_CELL_ID_PODWEAK = list(
                CHANGELING_CELL_REGISTRY_NAME = "Podperson",
                CHANGELING_CELL_REGISTRY_DESC = "Photosynthetic tendrils and plant-fiber musculature grown within pod sprouts.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_PODPERSON_WEAK, SPECIES_PODPERSON),
                CHANGELING_CELL_REGISTRY_KEYWORDS = list("podperson", "pod"),
        ),
        CHANGELING_CELL_ID_DWARF = list(
                CHANGELING_CELL_REGISTRY_NAME = "Dwarf",
                CHANGELING_CELL_REGISTRY_DESC = "Dense myofibrils and compact bone lattice recycled from dwarven miners.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_DWARF),
                CHANGELING_CELL_REGISTRY_KEYWORDS = list("dwarf"),
        ),
        CHANGELING_CELL_ID_SYNTH = list(
                CHANGELING_CELL_REGISTRY_NAME = "Synth",
                CHANGELING_CELL_REGISTRY_DESC = "Synthetic myomer bundles and polymer nerve sheaths refined from station synths.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_SYNTH, SPECIES_ANDROID),
                CHANGELING_CELL_REGISTRY_KEYWORDS = list("synth", "android"),
        ),
        CHANGELING_CELL_ID_AQUATIC = list(
                CHANGELING_CELL_REGISTRY_NAME = "Aquatic",
                CHANGELING_CELL_REGISTRY_DESC = "Pressure-tempered tissues and gill matrices taken from aquatic specialists.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_AQUATIC),
                CHANGELING_CELL_REGISTRY_KEYWORDS = list("aquatic"),
        ),
        CHANGELING_CELL_ID_INSECT = list(
                CHANGELING_CELL_REGISTRY_NAME = "Insect",
                CHANGELING_CELL_REGISTRY_DESC = "Segmented exoskeleton plating and rapid chitin regrowth of insect-folk.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_INSECT),
                CHANGELING_CELL_REGISTRY_KEYWORDS = list("insect"),
        ),
        CHANGELING_CELL_ID_INSECTOID = list(
                CHANGELING_CELL_REGISTRY_NAME = "Insectoid",
                CHANGELING_CELL_REGISTRY_DESC = "Hive-born chitin composites and pheromone glands from towering insectoids.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_INSECTOID),
                CHANGELING_CELL_REGISTRY_KEYWORDS = list("insectoid"),
        ),
        CHANGELING_CELL_ID_GHOUL = list(
                CHANGELING_CELL_REGISTRY_NAME = "Ghoul",
                CHANGELING_CELL_REGISTRY_DESC = "Radiation-stabilized marrow and regenerative necrotic tissue from ghoulish survivors.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_GHOUL),
                CHANGELING_CELL_REGISTRY_KEYWORDS = list("ghoul"),
        ),
        CHANGELING_CELL_ID_HEMOPHAGE = list(
                CHANGELING_CELL_REGISTRY_NAME = "Hemophage",
                CHANGELING_CELL_REGISTRY_DESC = "Hemovore assimilation glands and blood-filtering sacs cultivated from hemophages.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_HEMOPHAGE),
                CHANGELING_CELL_REGISTRY_KEYWORDS = list("hemophage", "blood"),
        ),
        CHANGELING_CELL_ID_ABDUCTORWEAK = list(
                CHANGELING_CELL_REGISTRY_NAME = "Abductor",
                CHANGELING_CELL_REGISTRY_DESC = "Altered nervous netting and psionic resonators appropriated from abductors.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_ABDUCTORWEAK, SPECIES_ABDUCTOR),
                CHANGELING_CELL_REGISTRY_KEYWORDS = list("abductor"),
        ),
        CHANGELING_CELL_ID_KOBOLD = list(
                CHANGELING_CELL_REGISTRY_NAME = "Kobold",
                CHANGELING_CELL_REGISTRY_DESC = "Burrowing tendons and pack-adaptive senses from industrious kobolds.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_KOBOLD),
                CHANGELING_CELL_REGISTRY_KEYWORDS = list("kobold"),
        ),
        CHANGELING_CELL_ID_NABBER = list(
                CHANGELING_CELL_REGISTRY_NAME = "Nabber",
                CHANGELING_CELL_REGISTRY_DESC = "Elastic spine cords and abyssal chromatophores from predatory nabbers.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_NABBER),
                CHANGELING_CELL_REGISTRY_KEYWORDS = list("nabber"),
        ),
        CHANGELING_CELL_ID_SHADEKIN = list(
                CHANGELING_CELL_REGISTRY_NAME = "Shadekin",
                CHANGELING_CELL_REGISTRY_DESC = "Shadow-aligned mycelia and reflexive photokinesis nodes gathered from shadekin.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_SHADEKIN),
                CHANGELING_CELL_REGISTRY_KEYWORDS = list("shadekin", "shade"),
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
        var/datum/species/species_datum
        if(ishuman(target))
                var/mob/living/carbon/human/human_target = target
                species_datum = human_target.dna?.species
        else if(iscarbon(target))
                var/mob/living/carbon/carbon_target = target
                species_datum = carbon_target.dna?.species
        if(!species_datum)
                return null
        var/species_id = species_datum.id
        if(!length(changeling_normalize_match_text(species_id)))
                var/species_type = species_datum.type
                if(species_type)
                        for(var/registered_id in GLOB.species_list)
                                if(!istext(registered_id))
                                        continue
                                if(GLOB.species_list[registered_id] == species_type)
                                        species_id = registered_id
                                        break
        return species_id

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
		var/list/entry_species = entry[CHANGELING_CELL_REGISTRY_SPECIES]
		var/entry_has_species = islist(entry_species) && entry_species.len
		if(changeling_registry_entry_matches_species(entry, species_id))
			if(!(cell_id in results))
				results += cell_id
			continue
		if((!entry_has_species || isnull(species_id)) && changeling_registry_entry_matches_type(entry, target))
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


#define CHANGELING_CELL_REGISTRY_NAME "name"
#define CHANGELING_CELL_REGISTRY_DESC "desc"
#define CHANGELING_CELL_REGISTRY_TYPES "types"
#define CHANGELING_CELL_REGISTRY_SPECIES "species"

#define CHANGELING_CELL_ID_HUMAN "human"
#define CHANGELING_CELL_ID_LIZARD "lizard"
#define CHANGELING_CELL_ID_VOX "vox"
#define CHANGELING_CELL_ID_TAJARAN "tajaran"
#define CHANGELING_CELL_ID_TESHARI "teshari"
#define CHANGELING_CELL_ID_FELINID "felinid"
#define CHANGELING_CELL_ID_VULPKANIN "vulpkanin"
#define CHANGELING_CELL_ID_AKULA "akula"
#define CHANGELING_CELL_ID_SKRELL "skrell"
#define CHANGELING_CELL_ID_INSECT "insectoid"
#define CHANGELING_CELL_ID_MOTH "moth"
#define CHANGELING_CELL_ID_PLASMAMAN "plasmaman"
#define CHANGELING_CELL_ID_ETHEREAL "ethereal"
#define CHANGELING_CELL_ID_SNAIL "snail"
#define CHANGELING_CELL_ID_XENO "xeno"
#define CHANGELING_CELL_ID_SLIMEPERSON "slimeperson"
#define CHANGELING_CELL_ID_PODWEAK "podweak"
#define CHANGELING_CELL_ID_DWARF "dwarf"
#define CHANGELING_CELL_ID_GHOUL "ghoul"
#define CHANGELING_CELL_ID_HEMOPHAGE "hemophage"
#define CHANGELING_CELL_ID_ABDUCTORWEAK "abductorweak"
#define CHANGELING_CELL_ID_KOBOLD "kobold"
#define CHANGELING_CELL_ID_NABBER "nabber"
#define CHANGELING_CELL_ID_SHADEKIN "shadekin"
#define CHANGELING_CELL_ID_CHICKEN "chicken"
#define CHANGELING_CELL_ID_COW "cow"
#define CHANGELING_CELL_ID_GOAT "goat"
#define CHANGELING_CELL_ID_PARROT "parrot"
#define CHANGELING_CELL_ID_BUTTERFLY "butterfly"
#define CHANGELING_CELL_ID_CAT "cat"
#define CHANGELING_CELL_ID_CORGI "corgi"
#define CHANGELING_CELL_ID_SHEEP "sheep"
#define CHANGELING_CELL_ID_PIG "pig"
#define CHANGELING_CELL_ID_PONY "pony"
#define CHANGELING_CELL_ID_CRAB "crab"
#define CHANGELING_CELL_ID_FOX "fox"
#define CHANGELING_CELL_ID_RABBIT "rabbit"
#define CHANGELING_CELL_ID_MOTHROACH "mothroach"
#define CHANGELING_CELL_ID_PUG "pug"
#define CHANGELING_CELL_ID_COLOSSUS "colossus"
#define CHANGELING_CELL_ID_SPACE_CARP "space_carp"
#define CHANGELING_CELL_ID_GIANT_SPIDER "giant_spider"
#define CHANGELING_CELL_ID_MORPH "morph"
#define CHANGELING_CELL_ID_REVENANT "revenant"
#define CHANGELING_CELL_ID_SLAUGHTER_DEMON "slaughter_demon"
#define CHANGELING_CELL_ID_COCKROACH "cockroach"
#define CHANGELING_CELL_ID_SPACE_DRAGON "space_dragon"
#define CHANGELING_CELL_ID_HERETIC_ROBE "heretic_robe"
#define CHANGELING_CELL_ID_BEE "bee"
#define CHANGELING_CELL_ID_NIGHTMARE "nightmare"
#define CHANGELING_CELL_ID_VOIDWALKER "voidwalker"
#define CHANGELING_CELL_ID_ASH_DRAKE "ash_drake"
#define CHANGELING_CELL_ID_BUBBLEGUM "bubblegum"
#define CHANGELING_CELL_ID_LEGION "legion"
#define CHANGELING_CELL_ID_WATCHER "watcher"
#define CHANGELING_CELL_ID_GOLIATH "goliath"

GLOBAL_LIST_INIT(changeling_cell_registry, list(
        CHANGELING_CELL_ID_HUMAN = list(
                CHANGELING_CELL_REGISTRY_NAME = "Human",
                CHANGELING_CELL_REGISTRY_DESC = "Baseline humanoid biomatter drawn from a crew.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_HUMAN, SPECIES_HUMANOID),
                CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/carbon/human),
        ),
        CHANGELING_CELL_ID_LIZARD = list(
                CHANGELING_CELL_REGISTRY_NAME = "Lizard",
                CHANGELING_CELL_REGISTRY_DESC = "Cold-blooded scales and disciplined musculature harvested from lizardfolk and Unathi hunters.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_LIZARD, SPECIES_LIZARD_ASH, SPECIES_LIZARD_SILVER, SPECIES_UNATHI),
        ),
        CHANGELING_CELL_ID_VOX = list(
                CHANGELING_CELL_REGISTRY_NAME = "Vox",
                CHANGELING_CELL_REGISTRY_DESC = "Avian cortical cluster harvested from Vox biology.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_VOX, SPECIES_VOX_PRIMALIS),
        ),
        CHANGELING_CELL_ID_TAJARAN = list(
                CHANGELING_CELL_REGISTRY_NAME = "Tajaran",
                CHANGELING_CELL_REGISTRY_DESC = "Feline survival tissues gleaned from Tajaran hosts.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_TAJARAN),
        ),
        CHANGELING_CELL_ID_TESHARI = list(
                CHANGELING_CELL_REGISTRY_NAME = "Teshari",
                CHANGELING_CELL_REGISTRY_DESC = "Lightweight musculature adapted for Teshari sprinters.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_TESHARI),
        ),
        CHANGELING_CELL_ID_FELINID = list(
                CHANGELING_CELL_REGISTRY_NAME = "Felinid",
                CHANGELING_CELL_REGISTRY_DESC = "Feline balance organs and quick-twitch tendons from agile felinids.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_FELINE, SPECIES_FELINE_PRIMITIVE),
        ),
        CHANGELING_CELL_ID_VULPKANIN = list(
                CHANGELING_CELL_REGISTRY_NAME = "Vulpkanin",
                CHANGELING_CELL_REGISTRY_DESC = "Canid olfactory bundles and endurance-ready musculature from vulpkanin scouts.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_VULP),
        ),
        CHANGELING_CELL_ID_AKULA = list(
                CHANGELING_CELL_REGISTRY_NAME = "Akula",
                CHANGELING_CELL_REGISTRY_DESC = "Hydrodynamic cartilage and saline-adapted musculature drawn from akula swimmers.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_AKULA),
        ),
        CHANGELING_CELL_ID_SKRELL = list(
                CHANGELING_CELL_REGISTRY_NAME = "Skrell",
                CHANGELING_CELL_REGISTRY_DESC = "Neural conduction gel and amphibious cartilage sourced from psionic skrell.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_SKRELL),
        ),
        CHANGELING_CELL_ID_INSECT = list(
                CHANGELING_CELL_REGISTRY_NAME = "Insectoid",
                CHANGELING_CELL_REGISTRY_DESC = "Proboscis musculature and hyperactive enzymes salvaged from flypeople and towering insectoids.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_FLYPERSON, SPECIES_INSECT, SPECIES_INSECTOID),
        ),
        CHANGELING_CELL_ID_MOTH = list(
                CHANGELING_CELL_REGISTRY_NAME = "Moth",
                CHANGELING_CELL_REGISTRY_DESC = "Powdered wing fibers and luminescent chitin drawn from mothkind.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_MOTH),
        ),
        CHANGELING_CELL_ID_PLASMAMAN = list(
                CHANGELING_CELL_REGISTRY_NAME = "Plasmaman",
                CHANGELING_CELL_REGISTRY_DESC = "Encapsulated plasma membranes stabilized for plasmaman containment.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_PLASMAMAN),
        ),
        CHANGELING_CELL_ID_ETHEREAL = list(
                CHANGELING_CELL_REGISTRY_NAME = "Ethereal",
                CHANGELING_CELL_REGISTRY_DESC = "Ion-charged lattice and conductive nerve threads harvested from ethereals.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_ETHEREAL, SPECIES_ETHEREAL_LUSTROUS),
        ),
        CHANGELING_CELL_ID_SNAIL = list(
                CHANGELING_CELL_REGISTRY_NAME = "Snail",
                CHANGELING_CELL_REGISTRY_DESC = "Viscous regenerative tissue and calcified shell plates from gastropoid citizens.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_SNAIL),
        ),
        CHANGELING_CELL_ID_XENO = list(
                CHANGELING_CELL_REGISTRY_NAME = "Xeno-Hybrid",
                CHANGELING_CELL_REGISTRY_DESC = "Acid-hardened sinew and adaptive chitin taken from xenobiological hybrids.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_XENO),
        ),
        CHANGELING_CELL_ID_SLIMEPERSON = list(
                CHANGELING_CELL_REGISTRY_NAME = "Slimeperson",
                CHANGELING_CELL_REGISTRY_DESC = "Morphogenic cytoplasm and plasmid memory nodes siphoned from slime-derived crew.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_SLIMESTART, SPECIES_SLIMEPERSON),
        ),
        CHANGELING_CELL_ID_PODWEAK = list(
                CHANGELING_CELL_REGISTRY_NAME = "Podperson",
                CHANGELING_CELL_REGISTRY_DESC = "Photosynthetic tendrils and plant-fiber musculature grown within pod sprouts.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_PODPERSON_WEAK, SPECIES_PODPERSON),
        ),
        CHANGELING_CELL_ID_DWARF = list(
                CHANGELING_CELL_REGISTRY_NAME = "Dwarf",
                CHANGELING_CELL_REGISTRY_DESC = "Dense myofibrils and compact bone lattice recycled from dwarven miners.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_DWARF),
        ),
        CHANGELING_CELL_ID_GHOUL = list(
                CHANGELING_CELL_REGISTRY_NAME = "Ghoul",
                CHANGELING_CELL_REGISTRY_DESC = "Radiation-stabilized marrow and regenerative necrotic tissue from ghoulish survivors.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_GHOUL),
        ),
        CHANGELING_CELL_ID_HEMOPHAGE = list(
                CHANGELING_CELL_REGISTRY_NAME = "Hemophage",
                CHANGELING_CELL_REGISTRY_DESC = "Hemovore assimilation glands and blood-filtering sacs cultivated from hemophages.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_HEMOPHAGE),
        ),
        CHANGELING_CELL_ID_ABDUCTORWEAK = list(
                CHANGELING_CELL_REGISTRY_NAME = "Abductor",
                CHANGELING_CELL_REGISTRY_DESC = "Altered nervous netting and psionic resonators appropriated from abductors.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_ABDUCTORWEAK, SPECIES_ABDUCTOR),
        ),
        CHANGELING_CELL_ID_KOBOLD = list(
                CHANGELING_CELL_REGISTRY_NAME = "Kobold",
                CHANGELING_CELL_REGISTRY_DESC = "Burrowing tendons and pack-adaptive senses from industrious kobolds.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_KOBOLD),
        ),
        CHANGELING_CELL_ID_NABBER = list(
                CHANGELING_CELL_REGISTRY_NAME = "Nabber",
                CHANGELING_CELL_REGISTRY_DESC = "Elastic spine cords and abyssal chromatophores from predatory nabbers.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_NABBER),
        ),
        CHANGELING_CELL_ID_SHADEKIN = list(
                CHANGELING_CELL_REGISTRY_NAME = "Shadekin",
                CHANGELING_CELL_REGISTRY_DESC = "Shadow-aligned mycelia and reflexive photokinesis nodes gathered from shadekin.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_SHADEKIN),
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
        ),
        CHANGELING_CELL_ID_COW = list(
                CHANGELING_CELL_REGISTRY_NAME = "Cow",
                CHANGELING_CELL_REGISTRY_DESC = "Heavy livestock tissue lattice.",
                CHANGELING_CELL_REGISTRY_TYPES = list(
                        /mob/living/basic/cow,
                        /obj/item/food/meat/slab/grassfed,
                ),
        ),
        CHANGELING_CELL_ID_GOAT = list(
                CHANGELING_CELL_REGISTRY_NAME = "Goat",
                CHANGELING_CELL_REGISTRY_DESC = "Stubborn grazer tissues ideal for endurance grafts.",
                CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/basic/goat),
        ),
        CHANGELING_CELL_ID_PARROT = list(
                CHANGELING_CELL_REGISTRY_NAME = "Parrot",
                CHANGELING_CELL_REGISTRY_DESC = "Polyglottal cords and mimic neurons sourced from cargo parrots.",
                CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/basic/parrot),
        ),
        CHANGELING_CELL_ID_BUTTERFLY = list(
                CHANGELING_CELL_REGISTRY_NAME = "Butterfly",
                CHANGELING_CELL_REGISTRY_DESC = "Gossamer wing fibers and powder glands taken from decorative butterflies.",
                CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/basic/butterfly),
        ),
        CHANGELING_CELL_ID_CAT = list(
                CHANGELING_CELL_REGISTRY_NAME = "Cat",
                CHANGELING_CELL_REGISTRY_DESC = "Responsive domestic feline musculature delivered in pet crates.",
                CHANGELING_CELL_REGISTRY_TYPES = list(
                        /mob/living/basic/pet/cat,
                        /mob/living/basic/pet/cat/_proc,
                ),
        ),
        CHANGELING_CELL_ID_CORGI = list(
                CHANGELING_CELL_REGISTRY_NAME = "Corgi",
                CHANGELING_CELL_REGISTRY_DESC = "Compact herding dog sinew and loyalty pheromones from cargo corgis.",
                CHANGELING_CELL_REGISTRY_TYPES = list(
                        /mob/living/basic/pet/dog/corgi,
                        /mob/living/basic/pet/dog/corgi/lisa,
                        /mob/living/basic/pet/dog/corgi/exoticcorgi,
                ),
        ),
        CHANGELING_CELL_ID_SHEEP = list(
                CHANGELING_CELL_REGISTRY_NAME = "Sheep",
                CHANGELING_CELL_REGISTRY_DESC = "Wool-rich musculature and insulating fat layers from docile sheep.",
                CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/basic/sheep),
        ),
        CHANGELING_CELL_ID_PIG = list(
                CHANGELING_CELL_REGISTRY_NAME = "Pig",
                CHANGELING_CELL_REGISTRY_DESC = "Dense farm-grown myofibers and hardy organs cultured from pigs.",
                CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/basic/pig),
        ),
        CHANGELING_CELL_ID_PONY = list(
                CHANGELING_CELL_REGISTRY_NAME = "Pony",
                CHANGELING_CELL_REGISTRY_DESC = "Sturdy equine tendons and balance nodes harvested from cargo ponies.",
                CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/basic/pony),
        ),
        CHANGELING_CELL_ID_CRAB = list(
                CHANGELING_CELL_REGISTRY_NAME = "Crab",
                CHANGELING_CELL_REGISTRY_DESC = "Armored crustacean plating and pincers from the famed crab rocket.",
                CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/basic/crab),
        ),
        CHANGELING_CELL_ID_FOX = list(
                CHANGELING_CELL_REGISTRY_NAME = "Fox",
                CHANGELING_CELL_REGISTRY_DESC = "Sly scavenger reflexes and scent trackers sourced from fox deliveries.",
                CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/basic/pet/fox),
        ),
        CHANGELING_CELL_ID_RABBIT = list(
                CHANGELING_CELL_REGISTRY_NAME = "Rabbit",
                CHANGELING_CELL_REGISTRY_DESC = "Rapid-fire twitch muscle and burrow instincts from shipping rabbits.",
                CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/basic/rabbit),
        ),
        CHANGELING_CELL_ID_MOTHROACH = list(
                CHANGELING_CELL_REGISTRY_NAME = "Mothroach",
                CHANGELING_CELL_REGISTRY_DESC = "Hybrid dust glands and clinging hairs gathered from novelty mothroaches.",
                CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/basic/mothroach),
        ),
        CHANGELING_CELL_ID_PUG = list(
                CHANGELING_CELL_REGISTRY_NAME = "Pug",
                CHANGELING_CELL_REGISTRY_DESC = "Squashed canine snouts and stubborn loyalty tissue packaged with cargo pugs.",
                CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/basic/pet/dog/pug),
        ),
        CHANGELING_CELL_ID_COLOSSUS = list(
                CHANGELING_CELL_REGISTRY_NAME = "Colossus",
                CHANGELING_CELL_REGISTRY_DESC = "Crystalline lattice fragments from a lavaland colossus.",
                CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/simple_animal/hostile/megafauna/colossus),
        ),
        CHANGELING_CELL_ID_SPACE_CARP = list(
                CHANGELING_CELL_REGISTRY_NAME = "Space Carp",
                CHANGELING_CELL_REGISTRY_DESC = "Hydrodynamic muscle bundles and predatory instincts from roaming space carp.",
                CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/basic/carp),
        ),
        CHANGELING_CELL_ID_GIANT_SPIDER = list(
                CHANGELING_CELL_REGISTRY_NAME = "Giant Spider",
                CHANGELING_CELL_REGISTRY_DESC = "Venom glands and tensile spinnerets salvaged from giant spiders loosed on stations.",
                CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/basic/spider/giant),
        ),
        CHANGELING_CELL_ID_MORPH = list(
                CHANGELING_CELL_REGISTRY_NAME = "Morph",
                CHANGELING_CELL_REGISTRY_DESC = "Adaptive protoplasm and mimicry nodules taken from shapeshifting morphs.",
                CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/basic/morph),
        ),
        CHANGELING_CELL_ID_REVENANT = list(
                CHANGELING_CELL_REGISTRY_NAME = "Revenant",
                CHANGELING_CELL_REGISTRY_DESC = "Spectral ectoplasm and phase anchors condensed from vengeful revenants.",
                CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/basic/revenant),
        ),
        CHANGELING_CELL_ID_SLAUGHTER_DEMON = list(
                CHANGELING_CELL_REGISTRY_NAME = "Slaughter Demon",
                CHANGELING_CELL_REGISTRY_DESC = "Warp-charged sinew and sanguine armor ripped from slaughter demons.",
                CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/basic/demon/slaughter),
        ),
        CHANGELING_CELL_ID_COCKROACH = list(
                CHANGELING_CELL_REGISTRY_NAME = "Cockroach",
                CHANGELING_CELL_REGISTRY_DESC = "Stubborn blattodean chitin reconstituted from the station's hardiest cockroaches, save for delicate mothroaches.",
                CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/basic/cockroach),
        ),
        CHANGELING_CELL_ID_SPACE_DRAGON = list(
                CHANGELING_CELL_REGISTRY_NAME = "Space Dragon",
                CHANGELING_CELL_REGISTRY_DESC = "Radiant scales and plasma furnaces taken from legendary space dragons.",
                CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/basic/space_dragon),
        ),
        CHANGELING_CELL_ID_HERETIC_ROBE = list(
                CHANGELING_CELL_REGISTRY_NAME = "Heretic Robe",
                CHANGELING_CELL_REGISTRY_DESC = "Eldritch fibers steeped in Mansus resonance from a heretic's vestments.",
                CHANGELING_CELL_REGISTRY_TYPES = list(
                        /obj/item/clothing/suit/hooded/cultrobes/eldritch,
                        /obj/item/clothing/head/hooded/cult_hoodie/eldritch,
                ),
        ),
        CHANGELING_CELL_ID_BEE = list(
                CHANGELING_CELL_REGISTRY_NAME = "Bee",
                CHANGELING_CELL_REGISTRY_DESC = "Honey-slick muscle strands and venom sacs harvested from buzzing station bees.",
                CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/basic/bee),
        ),
        CHANGELING_CELL_ID_NIGHTMARE = list(
                CHANGELING_CELL_REGISTRY_NAME = "Nightmare",
                CHANGELING_CELL_REGISTRY_DESC = "Shadow-dense sinew and void-cold ichor siphoned from nightmare hunters.",
                CHANGELING_CELL_REGISTRY_SPECIES = list(SPECIES_NIGHTMARE),
        ),
        CHANGELING_CELL_ID_VOIDWALKER = list(
                CHANGELING_CELL_REGISTRY_NAME = "Voidwalker",
                CHANGELING_CELL_REGISTRY_DESC = "Gravity-shearing tendons and spatial resonators pulled from voidwalkers.",
                CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/basic/voidwalker),
        ),
        CHANGELING_CELL_ID_ASH_DRAKE = list(
                CHANGELING_CELL_REGISTRY_NAME = "Ash Drake",
                CHANGELING_CELL_REGISTRY_DESC = "Cinder-hardened scales and thermal glands carved from ash drakes.",
                CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/simple_animal/hostile/megafauna/dragon),
        ),
        CHANGELING_CELL_ID_BUBBLEGUM = list(
                CHANGELING_CELL_REGISTRY_NAME = "Bubblegum",
                CHANGELING_CELL_REGISTRY_DESC = "Blood-saturated cartilage and demonic marrow reaped from Bubblegum.",
                CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/simple_animal/hostile/megafauna/bubblegum),
        ),
        CHANGELING_CELL_ID_LEGION = list(
                CHANGELING_CELL_REGISTRY_NAME = "Legion",
                CHANGELING_CELL_REGISTRY_DESC = "Fractured necropolis bone shards and hive masks split from Legion.",
                CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/simple_animal/hostile/megafauna/legion),
        ),
        CHANGELING_CELL_ID_WATCHER = list(
                CHANGELING_CELL_REGISTRY_NAME = "Watcher",
                CHANGELING_CELL_REGISTRY_DESC = "Crystalline ocular cores and frost-bitten wings lifted from cavern watchers.",
                CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/basic/mining/watcher),
        ),
        CHANGELING_CELL_ID_GOLIATH = list(
                CHANGELING_CELL_REGISTRY_NAME = "Goliath",
                CHANGELING_CELL_REGISTRY_DESC = "Stone-plated musculature and tether sinew ripped from goliath tendrils.",
                CHANGELING_CELL_REGISTRY_TYPES = list(/mob/living/basic/mining/goliath),
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


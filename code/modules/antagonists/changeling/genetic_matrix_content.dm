#define GENETIC_MATRIX_CATEGORY_KEY "key_active"
#define GENETIC_MATRIX_CATEGORY_PASSIVE "passive"
#define GENETIC_MATRIX_CATEGORY_UPGRADE "upgrade"

GLOBAL_LIST_INIT(changeling_genetic_matrix_recipes, list(
	"matrix_predatory_howl" = list(
		"id" = "matrix_predatory_howl",
		"name" = "Predatory Howl",
		"desc" = "Refocuses our technophagic shriek into a devastating execution note.",
		"module" = list(
			"id" = "matrix_predatory_howl",
			"name" = "Predatory Howl",
			"desc" = "Upgrades Technophagic Shriek with a razor-focused killing tone and heightened structure damage.",
			"helptext" = "Stacks with resonant shriek bonuses; incompatible with other key actives.",
			"category" = GENETIC_MATRIX_CATEGORY_KEY,
			"slotType" = BIO_INCUBATOR_SLOT_KEY,
			"tags" = list("sonic", "offense"),
			"exclusiveTags" = list("key_active"),
			"button_icon_state" = "dissonant_shriek",
		),
                "requiredCells" = list(
                        CHANGELING_CELL_ID_VOX,
                        CHANGELING_CELL_ID_TAJARAN,
                ),
		"requiredAbilities" = list(
			/datum/action/changeling/dissonant_shriek,
		),
	),
	"matrix_symbiotic_overgrowth" = list(
		"id" = "matrix_symbiotic_overgrowth",
		"name" = "Symbiotic Overgrowth",
		"desc" = "Cultivates regenerative tissues that keep working even while dormant.",
		"module" = list(
			"id" = "matrix_symbiotic_overgrowth",
			"name" = "Symbiotic Overgrowth",
			"desc" = "Grants a slow baseline regeneration and improves the potency of the Regenerate ability.",
			"category" = GENETIC_MATRIX_CATEGORY_PASSIVE,
			"slotType" = BIO_INCUBATOR_SLOT_FLEX,
			"tags" = list("healing", "sustain"),
			"exclusiveTags" = list("healing"),
			"button_icon_state" = "regenerate",
		),
                "requiredCells" = list(
                        CHANGELING_CELL_ID_HUMAN,
                        CHANGELING_CELL_ID_GOAT,
                ),
		"requiredAbilities" = list(
			/datum/action/changeling/regenerate,
		),
	),
	"matrix_feathered_veil" = list(
		"id" = "matrix_feathered_veil",
		"name" = "Feathered Veil",
		"desc" = "Blend avian camouflage with predatory cunning for near-perfect stillness.",
		"module" = list(
			"id" = "matrix_feathered_veil",
			"name" = "Feathered Veil",
			"desc" = "Bolsters Digital Camouflage with brief bursts of total visual suppression while moving.",
			"category" = GENETIC_MATRIX_CATEGORY_PASSIVE,
			"slotType" = BIO_INCUBATOR_SLOT_FLEX,
			"tags" = list("stealth", "mobility"),
			"exclusiveTags" = list("stealth"),
			"button_icon_state" = "digital_camo",
		),
                "requiredCells" = list(
                        CHANGELING_CELL_ID_TESHARI,
                        CHANGELING_CELL_ID_CHICKEN,
                ),
		"requiredAbilities" = list(
			/datum/action/changeling/digitalcamo,
		),
	),
	"matrix_predator_sinew" = list(
		"id" = "matrix_predator_sinew",
		"name" = "Predator's Sinew",
		"desc" = "Splice apex muscle fibers to tame our Strained Muscles technique.",
		"module" = list(
			"id" = "matrix_predator_sinew",
			"name" = "Predator's Sinew",
			"desc" = "Reduces stamina backlash from Strained Muscles and adds a short sprint on activation.",
			"category" = GENETIC_MATRIX_CATEGORY_UPGRADE,
			"slotType" = BIO_INCUBATOR_SLOT_FLEX,
			"tags" = list("mobility", "strength"),
			"exclusiveTags" = list("mobility"),
			"button_icon_state" = "strained_muscles",
		),
                "requiredCells" = list(
                        CHANGELING_CELL_ID_TAJARAN,
                        CHANGELING_CELL_ID_LIZARD,
                ),
		"requiredAbilities" = list(
			/datum/action/changeling/strained_muscles,
		),
	),
	"matrix_void_carapace" = list(
		"id" = "matrix_void_carapace",
		"name" = "Void Carapace",
		"desc" = "Crystallize void-borne armor across our frame without permanent penalties.",
		"module" = list(
			"id" = "matrix_void_carapace",
			"name" = "Void Carapace",
			"desc" = "Improves Void Adaption by shortening its chem slowdown and granting brief hazard immunity bursts.",
			"category" = GENETIC_MATRIX_CATEGORY_PASSIVE,
			"slotType" = BIO_INCUBATOR_SLOT_FLEX,
			"tags" = list("environment", "defense"),
			"exclusiveTags" = list("adaptation"),
			"button_icon_state" = null,
		),
                "requiredCells" = list(
                        CHANGELING_CELL_ID_VOX,
                        CHANGELING_CELL_ID_COLOSSUS,
                ),
		"requiredAbilities" = list(
			/datum/action/changeling/void_adaption,
		),
	),
	"matrix_adrenal_spike" = list(
		"id" = "matrix_adrenal_spike",
		"name" = "Adrenal Spike",
		"desc" = "Bottle barnyard endurance into a reusable combat stimulant.",
		"module" = list(
			"id" = "matrix_adrenal_spike",
			"name" = "Adrenal Spike",
			"desc" = "Upgrades Gene Stim with bonus stamina recovery and a reactive countershock when stunned.",
			"category" = GENETIC_MATRIX_CATEGORY_UPGRADE,
			"slotType" = BIO_INCUBATOR_SLOT_FLEX,
			"tags" = list("stamina", "burst"),
			"exclusiveTags" = list("stamina"),
			"button_icon_state" = "adrenaline",
		),
                "requiredCells" = list(
                        CHANGELING_CELL_ID_COW,
                        CHANGELING_CELL_ID_HUMAN,
                ),
		"requiredAbilities" = list(
			/datum/action/changeling/adrenaline,
		),
	),
))

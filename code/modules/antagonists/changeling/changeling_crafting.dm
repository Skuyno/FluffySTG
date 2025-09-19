#define CHANGELING_CRAFT_ID "id"
#define CHANGELING_CRAFT_NAME "name"
#define CHANGELING_CRAFT_DESC "description"
#define CHANGELING_CRAFT_BIOMATERIALS "biomaterials"
#define CHANGELING_CRAFT_ABILITIES "abilities"
#define CHANGELING_CRAFT_GRANTS "grants"
#define CHANGELING_CRAFT_OUTCOME "outcome"
#define CHANGELING_CRAFT_RESULT_TEXT "result_text"
#define CHANGELING_CRAFT_PASSIVES "passives"
#define CHANGELING_CRAFT_POWER "power"
#define CHANGELING_CRAFT_SLOT "slot"
#define CHANGELING_CRAFT_FORCE "force"
#define CHANGELING_CRAFT_BIO_CATEGORY "category"
#define CHANGELING_CRAFT_BIO_CATEGORY_NAME "category_name"
#define CHANGELING_CRAFT_BIO_ID "id"
#define CHANGELING_CRAFT_BIO_NAME "name"
#define CHANGELING_CRAFT_BIO_COUNT "count"
#define CHANGELING_CRAFT_BIO_DESC "description"

GLOBAL_LIST_INIT(changeling_crafting_recipes, list(
	list(
		CHANGELING_CRAFT_ID = "feral_reflex_lattice",
		CHANGELING_CRAFT_NAME = "Feral Reflex Lattice",
		CHANGELING_CRAFT_DESC = "Fuse predatory myofibrils with nimble vermin tissue to accelerate our musculature.",
		CHANGELING_CRAFT_BIOMATERIALS = list(
			list(
				CHANGELING_CRAFT_BIO_CATEGORY = CHANGELING_BIOMATERIAL_CATEGORY_PREDATORY,
				CHANGELING_CRAFT_BIO_CATEGORY_NAME = "Predatory Biomass",
				CHANGELING_CRAFT_BIO_ID = "felinid_myofibrils",
				CHANGELING_CRAFT_BIO_NAME = "Felinid Myofibrils",
				CHANGELING_CRAFT_BIO_COUNT = 1,
				CHANGELING_CRAFT_BIO_DESC = "Fast-twitch fibers harvested from a felinid hunter.",
			),
			list(
				CHANGELING_CRAFT_BIO_CATEGORY = CHANGELING_BIOMATERIAL_CATEGORY_ADAPTIVE,
				CHANGELING_CRAFT_BIO_CATEGORY_NAME = "Adaptive Tissue",
				CHANGELING_CRAFT_BIO_ID = "rodent_neurotissue",
				CHANGELING_CRAFT_BIO_NAME = "Rodent Neurotissue",
				CHANGELING_CRAFT_BIO_COUNT = 2,
				CHANGELING_CRAFT_BIO_DESC = "Reactive grey matter refined from laboratory vermin.",
			),
		),
		CHANGELING_CRAFT_ABILITIES = list(/datum/action/changeling/augmented_eyesight),
		CHANGELING_CRAFT_GRANTS = list(
			list(
				CHANGELING_CRAFT_POWER = /datum/action/changeling/strained_muscles,
				CHANGELING_CRAFT_SLOT = CHANGELING_SECONDARY_BUILD_SLOTS,
			),
		),
		CHANGELING_CRAFT_PASSIVES = list(
			"chem_recharge_slowdown" = -0.1,
		),
		CHANGELING_CRAFT_RESULT_TEXT = "Integrates the Strained Muscles sequence and refines our reflexive catalysts.",
	),
	list(
		CHANGELING_CRAFT_ID = "corrosive_biomantle",
		CHANGELING_CRAFT_NAME = "Corrosive Biomantle",
		CHANGELING_CRAFT_DESC = "Temper resilient cytology with predatory cartilage to exude controlled acid.",
		CHANGELING_CRAFT_BIOMATERIALS = list(
			list(
				CHANGELING_CRAFT_BIO_CATEGORY = CHANGELING_BIOMATERIAL_CATEGORY_RESILIENCE,
				CHANGELING_CRAFT_BIO_CATEGORY_NAME = "Resilience Samples",
				CHANGELING_CRAFT_BIO_ID = "plasmaman_colonids",
				CHANGELING_CRAFT_BIO_NAME = "Plasmaman Colonids",
				CHANGELING_CRAFT_BIO_COUNT = 1,
				CHANGELING_CRAFT_BIO_DESC = "Plasma-bathed organics collected from a plasmaman husk.",
			),
			list(
				CHANGELING_CRAFT_BIO_CATEGORY = CHANGELING_BIOMATERIAL_CATEGORY_RESILIENCE,
				CHANGELING_CRAFT_BIO_CATEGORY_NAME = "Resilience Samples",
				CHANGELING_CRAFT_BIO_ID = "moth_cytoplasm",
				CHANGELING_CRAFT_BIO_NAME = "Moth Cytoplasm",
				CHANGELING_CRAFT_BIO_COUNT = 1,
				CHANGELING_CRAFT_BIO_DESC = "Dust-laden cytoplasm radiating tenacious life.",
			),
			list(
				CHANGELING_CRAFT_BIO_CATEGORY = CHANGELING_BIOMATERIAL_CATEGORY_PREDATORY,
				CHANGELING_CRAFT_BIO_CATEGORY_NAME = "Predatory Biomass",
				CHANGELING_CRAFT_BIO_ID = "lizard_chondrocytes",
				CHANGELING_CRAFT_BIO_NAME = "Lizard Chondrocytes",
				CHANGELING_CRAFT_BIO_COUNT = 1,
				CHANGELING_CRAFT_BIO_DESC = "Regenerative cartilage cells stripped from a lizardperson.",
			),
		),
		CHANGELING_CRAFT_ABILITIES = list(/datum/action/changeling/fleshmend),
		CHANGELING_CRAFT_GRANTS = list(
			list(
				CHANGELING_CRAFT_POWER = /datum/action/changeling/biodegrade,
				CHANGELING_CRAFT_SLOT = CHANGELING_SECONDARY_BUILD_SLOTS,
			),
		),
		CHANGELING_CRAFT_PASSIVES = list(
			"chem_storage" = 10,
			"chem_charges" = 10,
		),
		CHANGELING_CRAFT_RESULT_TEXT = "Stabilizes corrosive secretions, granting the Biodegrade adaptation.",
	),
	list(
		CHANGELING_CRAFT_ID = "spectral_camo_weave",
		CHANGELING_CRAFT_NAME = "Spectral Camo Weave",
		CHANGELING_CRAFT_DESC = "Layer adaptive primate stem cells within an ethereal lattice to mask our presence.",
		CHANGELING_CRAFT_BIOMATERIALS = list(
			list(
				CHANGELING_CRAFT_BIO_CATEGORY = CHANGELING_BIOMATERIAL_CATEGORY_ADAPTIVE,
				CHANGELING_CRAFT_BIO_CATEGORY_NAME = "Adaptive Tissue",
				CHANGELING_CRAFT_BIO_ID = "human_cytoplasm",
				CHANGELING_CRAFT_BIO_NAME = "Human Cytoplasm",
				CHANGELING_CRAFT_BIO_COUNT = 1,
				CHANGELING_CRAFT_BIO_DESC = "Baseline human culture brimming with versatility.",
			),
			list(
				CHANGELING_CRAFT_BIO_CATEGORY = CHANGELING_BIOMATERIAL_CATEGORY_ADAPTIVE,
				CHANGELING_CRAFT_BIO_CATEGORY_NAME = "Adaptive Tissue",
				CHANGELING_CRAFT_BIO_ID = "primate_stem_cells",
				CHANGELING_CRAFT_BIO_NAME = "Primate Stem Cells",
				CHANGELING_CRAFT_BIO_COUNT = 1,
				CHANGELING_CRAFT_BIO_DESC = "Highly plastic stem cells extracted from simian specimens.",
			),
			list(
				CHANGELING_CRAFT_BIO_CATEGORY = CHANGELING_BIOMATERIAL_CATEGORY_ADAPTIVE,
				CHANGELING_CRAFT_BIO_CATEGORY_NAME = "Adaptive Tissue",
				CHANGELING_CRAFT_BIO_ID = "ethereal_plasma_lattice",
				CHANGELING_CRAFT_BIO_NAME = "Ethereal Plasma Lattice",
				CHANGELING_CRAFT_BIO_COUNT = 1,
				CHANGELING_CRAFT_BIO_DESC = "Plasma-stabilized membrane cultured from an ethereal.",
			),
		),
		CHANGELING_CRAFT_ABILITIES = list(/datum/action/changeling/mimicvoice),
		CHANGELING_CRAFT_GRANTS = list(
			list(
				CHANGELING_CRAFT_POWER = /datum/action/changeling/digitalcamo,
				CHANGELING_CRAFT_SLOT = CHANGELING_KEY_BUILD_SLOT,
			),
		),
		CHANGELING_CRAFT_PASSIVES = list(
			"chem_recharge_rate" = 0.2,
		),
		CHANGELING_CRAFT_RESULT_TEXT = "Spins a spectral camouflage mesh, preparing Digital Camouflage for deployment.",
	),
	list(
		CHANGELING_CRAFT_ID = "void_chrysalis",
		CHANGELING_CRAFT_NAME = "Void Chrysalis",
		CHANGELING_CRAFT_DESC = "Cultivate resilient plant cytology into a vacuum-hardened husk.",
		CHANGELING_CRAFT_BIOMATERIALS = list(
			list(
				CHANGELING_CRAFT_BIO_CATEGORY = CHANGELING_BIOMATERIAL_CATEGORY_RESILIENCE,
				CHANGELING_CRAFT_BIO_CATEGORY_NAME = "Resilience Samples",
				CHANGELING_CRAFT_BIO_ID = "pod_chloroplast_matrix",
				CHANGELING_CRAFT_BIO_NAME = "Pod Chloroplast Matrix",
				CHANGELING_CRAFT_BIO_COUNT = 2,
				CHANGELING_CRAFT_BIO_DESC = "Photosynthetic latticework sourced from podpeople biomass.",
			),
			list(
				CHANGELING_CRAFT_BIO_CATEGORY = CHANGELING_BIOMATERIAL_CATEGORY_RESILIENCE,
				CHANGELING_CRAFT_BIO_CATEGORY_NAME = "Resilience Samples",
				CHANGELING_CRAFT_BIO_ID = "jelly_vacuole_sample",
				CHANGELING_CRAFT_BIO_NAME = "Jelly Vacuole Sample",
				CHANGELING_CRAFT_BIO_COUNT = 1,
				CHANGELING_CRAFT_BIO_DESC = "Amorphous vacuoles capable of extreme pressure differentials.",
			),
		),
		CHANGELING_CRAFT_ABILITIES = list(/datum/action/changeling/adaptive_wardrobe),
		CHANGELING_CRAFT_GRANTS = list(
			list(
				CHANGELING_CRAFT_POWER = /datum/action/changeling/void_adaption,
				CHANGELING_CRAFT_SLOT = CHANGELING_SECONDARY_BUILD_SLOTS,
			),
		),
		CHANGELING_CRAFT_PASSIVES = list(
			"chem_storage" = 5,
		),
		CHANGELING_CRAFT_RESULT_TEXT = "Forms a vacuum chrysalis, unlocking Void Adaptation.",
	),
	list(
		CHANGELING_CRAFT_ID = "predatory_armory",
		CHANGELING_CRAFT_NAME = "Predatory Armory",
		CHANGELING_CRAFT_DESC = "Bind feral musculature with chitinous plating to weaponize our limbs.",
		CHANGELING_CRAFT_BIOMATERIALS = list(
			list(
				CHANGELING_CRAFT_BIO_CATEGORY = CHANGELING_BIOMATERIAL_CATEGORY_PREDATORY,
				CHANGELING_CRAFT_BIO_CATEGORY_NAME = "Predatory Biomass",
				CHANGELING_CRAFT_BIO_ID = "felinid_myofibrils",
				CHANGELING_CRAFT_BIO_NAME = "Felinid Myofibrils",
				CHANGELING_CRAFT_BIO_COUNT = 1,
			),
			list(
				CHANGELING_CRAFT_BIO_CATEGORY = CHANGELING_BIOMATERIAL_CATEGORY_PREDATORY,
				CHANGELING_CRAFT_BIO_CATEGORY_NAME = "Predatory Biomass",
				CHANGELING_CRAFT_BIO_ID = "fly_chitinous_cells",
				CHANGELING_CRAFT_BIO_NAME = "Fly Chitinous Cells",
				CHANGELING_CRAFT_BIO_COUNT = 1,
			),
			list(
				CHANGELING_CRAFT_BIO_CATEGORY = CHANGELING_BIOMATERIAL_CATEGORY_ADAPTIVE,
				CHANGELING_CRAFT_BIO_CATEGORY_NAME = "Adaptive Tissue",
				CHANGELING_CRAFT_BIO_ID = "rodent_neurotissue",
				CHANGELING_CRAFT_BIO_NAME = "Rodent Neurotissue",
				CHANGELING_CRAFT_BIO_COUNT = 1,
			),
		),
		CHANGELING_CRAFT_ABILITIES = list(/datum/action/changeling/strained_muscles),
		CHANGELING_CRAFT_GRANTS = list(
			list(
				CHANGELING_CRAFT_POWER = /datum/action/changeling/weapon/arm_blade,
				CHANGELING_CRAFT_SLOT = CHANGELING_SECONDARY_BUILD_SLOTS,
			),
		),
		CHANGELING_CRAFT_PASSIVES = list(
			"chem_charges" = 5,
		),
		CHANGELING_CRAFT_RESULT_TEXT = "Shapes a predatory armory, cultivating an Arm Blade weapon form.",
	),
	list(
		CHANGELING_CRAFT_ID = "synaptic_beacon",
		CHANGELING_CRAFT_NAME = "Synaptic Beacon",
		CHANGELING_CRAFT_DESC = "Tune adaptive cytoplasm with luminescent plasma to sharpen our battle instincts.",
		CHANGELING_CRAFT_BIOMATERIALS = list(
			list(
				CHANGELING_CRAFT_BIO_CATEGORY = CHANGELING_BIOMATERIAL_CATEGORY_ADAPTIVE,
				CHANGELING_CRAFT_BIO_CATEGORY_NAME = "Adaptive Tissue",
				CHANGELING_CRAFT_BIO_ID = "human_cytoplasm",
				CHANGELING_CRAFT_BIO_NAME = "Human Cytoplasm",
				CHANGELING_CRAFT_BIO_COUNT = 1,
			),
			list(
				CHANGELING_CRAFT_BIO_CATEGORY = CHANGELING_BIOMATERIAL_CATEGORY_RESILIENCE,
				CHANGELING_CRAFT_BIO_CATEGORY_NAME = "Resilience Samples",
				CHANGELING_CRAFT_BIO_ID = "plasmaman_colonids",
				CHANGELING_CRAFT_BIO_NAME = "Plasmaman Colonids",
				CHANGELING_CRAFT_BIO_COUNT = 1,
			),
			list(
				CHANGELING_CRAFT_BIO_CATEGORY = CHANGELING_BIOMATERIAL_CATEGORY_RESILIENCE,
				CHANGELING_CRAFT_BIO_CATEGORY_NAME = "Resilience Samples",
				CHANGELING_CRAFT_BIO_ID = "moth_cytoplasm",
				CHANGELING_CRAFT_BIO_NAME = "Moth Cytoplasm",
				CHANGELING_CRAFT_BIO_COUNT = 1,
			),
		),
		CHANGELING_CRAFT_ABILITIES = list(/datum/action/changeling/pheromone_receptors),
		CHANGELING_CRAFT_GRANTS = list(
			list(
				CHANGELING_CRAFT_POWER = /datum/action/changeling/adrenaline,
				CHANGELING_CRAFT_SLOT = CHANGELING_SECONDARY_BUILD_SLOTS,
			),
		),
		CHANGELING_CRAFT_PASSIVES = list(
			"chem_recharge_slowdown" = -0.15,
		),
		CHANGELING_CRAFT_RESULT_TEXT = "Crystallizes a synaptic beacon, enabling the Gene Stim surge.",
	),
))

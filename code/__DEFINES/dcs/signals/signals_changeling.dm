///Called when a changeling uses its transform ability (source = carbon), from /datum/action/changeling/transform/sting_action(mob/living/carbon/human/user)
#define COMSIG_CHANGELING_TRANSFORM "changeling_transform"

///Sent when a changeling bio incubator updates any tracked data.
#define COMSIG_CHANGELING_BIO_INCUBATOR_DIRTY "changeling_bio_incubator_dirty"
///Sent when the incubator's cell collection changes.
#define COMSIG_CHANGELING_BIO_INCUBATOR_CELLS_CHANGED "changeling_bio_incubator_cells_changed"
///Sent when the incubator's recipe collection changes.
#define COMSIG_CHANGELING_BIO_INCUBATOR_RECIPES_CHANGED "changeling_bio_incubator_recipes_changed"
///Sent when the incubator's crafted module list changes.
#define COMSIG_CHANGELING_BIO_INCUBATOR_MODULES_CHANGED "changeling_bio_incubator_modules_changed"
///Sent when build presets are added, removed, or modified.
#define COMSIG_CHANGELING_BIO_INCUBATOR_BUILDS_CHANGED "changeling_bio_incubator_builds_changed"

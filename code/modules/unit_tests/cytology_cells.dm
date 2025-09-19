/datum/antagonist/changeling/test_cytology
	create_bio_incubator()
		if(bio_incubator)
			return bio_incubator
		return ..()

/datum/unit_test/cytology_cell_ids
	Run()
		var/mob/living/carbon/human/consistent/collector = allocate(/mob/living/carbon/human/consistent)
		collector.mind_initialize()
		collector.mind.add_antag_datum(/datum/antagonist/changeling/test_cytology)
		var/datum/antagonist/changeling/test_cytology/changeling_datum = IS_CHANGELING(collector)
		TEST_ASSERT(istype(changeling_datum), "Failed to initialize test changeling datum.")
		changeling_datum.give_power(/datum/action/changeling/sting/harvest_cells)
		var/datum/action/changeling/sting/harvest_cells/harvest = locate(/datum/action/changeling/sting/harvest_cells) in collector.actions
		TEST_ASSERT(harvest, "Failed to grant Harvest Cells sting to test changeling.")
		var/list/species_cells = list(
			/datum/species/human = /datum/micro_organism/cell_line/human,
			/datum/species/vox = /datum/micro_organism/cell_line/vox,
			/datum/species/tajaran = /datum/micro_organism/cell_line/tajaran,
			/datum/species/teshari = /datum/micro_organism/cell_line/teshari,
		)
		for(var/datum/species/species_type as anything in species_cells)
			var/mob/living/carbon/human/consistent/target = allocate(/mob/living/carbon/human/consistent)
			target.set_species(species_type)
			var/list/cell_ids = target.get_cytology_cell_ids()
			TEST_ASSERT(cell_ids?.len, "Species [species_type] returned no cytology cell IDs.")
			var/list/seen_ids = list()
			for(var/id in cell_ids)
				TEST_ASSERT(!(id in seen_ids), "Species [species_type] produced duplicate cytology cell id [id].")
				seen_ids += id
			var/expected_id = species_cells[species_type]
			TEST_ASSERT(expected_id in cell_ids, "Species [species_type] missing expected cytology cell id [expected_id].")
			var/success = harvest.sting_action(collector, target)
			TEST_ASSERT(success, "Harvest Cells sting failed to gather cytology cells from [species_type].")
			TEST_ASSERT(changeling_datum.bio_incubator?.cell_ids && (expected_id in changeling_datum.bio_incubator.cell_ids), "Harvest Cells sting did not record expected cell id [expected_id] for [species_type].")
			var/repeat_success = harvest.sting_action(collector, target)
			TEST_ASSERT(!repeat_success, "Harvest Cells sting unexpectedly catalogued duplicate cells from [species_type].")

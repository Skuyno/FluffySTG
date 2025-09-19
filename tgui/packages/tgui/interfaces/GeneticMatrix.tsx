import { ReactNode, useEffect, useMemo, useState } from 'react';
import {
  Box,
  Button,
  Icon,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type typePath = string;

type Ability = {
  name: string;
  desc: string;
  helptext: string;
  path: typePath;
  genetic_point_required: number;
  absorbs_required: number;
  dna_required: number;
  chemical_cost: number;
  req_human: BooleanLike;
  req_stat: string | null;
  disabled_by_fire: BooleanLike;
};

type ActiveEffect = {
  name: string;
  desc: string;
  helptext: string;
  path: typePath;
  chemical_cost: number;
  dna_cost: number;
  req_absorbs: number;
  req_dna: number;
  innate: BooleanLike;
};

type SynergyTip = {
  title: string;
  description: string;
  abilities: string[];
};

type BuildSlot = {
  slot: string;
  index: number;
  path: typePath | null;
  name?: string;
  desc?: string;
  helptext?: string;
  dna_cost?: number;
  chemical_cost?: number;
};

type ActiveBuildState = {
  key: BuildSlot | null;
  secondary: BuildSlot[];
  secondary_capacity: number;
};

type BuildBlueprint = {
  key?: typePath | null;
  secondary?: typePath[];
};

type BiomaterialEntry = {
  id: string;
  name: string;
  count: number;
  category: string;
  category_name?: string;
  description?: string;
  quality?: string | number;
};

type SignatureCell = {
  id: string;
  name: string;
  count: number;
  description?: string;
};

type GeneticPreset = {
  id: number;
  name: string;
  primary: BuildSlot | null;
  secondaries: BuildSlot[];
  ability_count: number;
  blueprint?: BuildBlueprint;
};

type CraftingMaterialRequirement = {
  category: string;
  category_name: string;
  id: string;
  name: string;
  count: number;
  description?: string;
};

type CraftingAbilityRequirement = {
  path: typePath;
  name: string;
  desc?: string;
};

type CraftingGrant = {
  path: typePath;
  name: string;
  slot: string;
  slot_name?: string;
  desc?: string;
  force?: BooleanLike;
};

type CraftingRecipe = {
  id: string;
  name: string;
  description: string;
  result_text?: string;
  biomaterials: CraftingMaterialRequirement[];
  abilities: CraftingAbilityRequirement[];
  grants?: CraftingGrant[];
  passives?: Record<string, number>;
};

type CraftingGrantResult = CraftingGrant & {
  success: BooleanLike;
  message?: string | null;
};

type CraftingResult = {
  success: BooleanLike;
  message: string;
  name?: string;
  recipe?: string;
  timestamp?: number;
  errors?: string[];
  grants?: CraftingGrantResult[];
  passives?: Record<string, number>;
};

type GeneticMatrixData = {
  abilities: Ability[];
  can_readapt: BooleanLike;
  owned_abilities: typePath[];
  genetic_points_count: number;
  total_genetic_points: number;
  absorb_count: number;
  dna_count: number;
  chem_charges: number;
  chem_storage: number;
  chem_recharge_rate: number;
  chem_recharge_slowdown: number;
  active_effects: ActiveEffect[];
  synergy_tips: SynergyTip[];
  incompatibilities: string[];
  presets: GeneticPreset[];
  preset_limit: number;
  active_build: ActiveBuildState;
  biomaterials: BiomaterialEntry[];
  signature_cells: SignatureCell[];
  crafting_recipes?: CraftingRecipe[];
  crafting_result?: CraftingResult | null;
};

export const GeneticMatrix = () => {
  const { data } = useBackend<GeneticMatrixData>();
  const [searchQuery, setSearchQuery] = useState('');
  const abilities = data.abilities ?? [];

  const filteredAbilities = useMemo(() => {
    if (!searchQuery || searchQuery.length < 2) {
      return abilities;
    }

    const lowered = searchQuery.toLowerCase();
    return abilities.filter((ability) => {
      return (
        ability.name.toLowerCase().includes(lowered) ||
        ability.desc.toLowerCase().includes(lowered) ||
        ability.helptext.toLowerCase().includes(lowered)
      );
    });
  }, [abilities, searchQuery]);

  return (
    <Window width={1100} height={640} theme="syndicate">
      <Window.Content>
        <Stack fill>
          <Stack.Item grow basis="60%">
            <Stack fill vertical>
              <Stack.Item grow>
                <AbilityCatalogSection
                  filteredAbilities={filteredAbilities}
                  searchQuery={searchQuery}
                  setSearchQuery={setSearchQuery}
                  activeBuild={data.active_build}
                />
              </Stack.Item>
              <Stack.Item grow>
                <ActiveEffectsSection />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item grow basis="40%">
            <Stack fill vertical>
              <Stack.Item>
                <ResourceSection />
              </Stack.Item>
              <Stack.Item>
                <ActiveBuildSection />
              </Stack.Item>
              <Stack.Item grow>
                <PresetSection />
              </Stack.Item>
              <Stack.Item grow>
                <CraftingSection />
              </Stack.Item>
              <Stack.Item>
                <BiomaterialSection />
              </Stack.Item>
              <Stack.Item>
                <SignatureSection />
              </Stack.Item>
              <Stack.Item>
                <SynergySection />
              </Stack.Item>
              <Stack.Item>
                <WarningsSection />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const AbilityCatalogSection = (props: {
  filteredAbilities: Ability[];
  searchQuery: string;
  setSearchQuery: (value: string) => void;
  activeBuild: ActiveBuildState;
}) => {
  const { act, data } = useBackend<GeneticMatrixData>();
  const { filteredAbilities, searchQuery, setSearchQuery, activeBuild } = props;
  const {
    owned_abilities,
    genetic_points_count,
    absorb_count,
    dna_count,
  } = data;
  const abilities = data.abilities ?? [];

  return (
    <Section
      fill
      scrollable
      title="Genetic Catalog"
      buttons={
        <Stack align="center" spacing={1}>
          <Stack.Item>
            <Input
              width="220px"
              placeholder="Search genomes..."
              value={searchQuery}
              onChange={setSearchQuery}
            />
          </Stack.Item>
          <Stack.Item>
            <Box mr={1}>
              {genetic_points_count}
              &nbsp;
              <Icon name="dna" color="#DD66DD" />
            </Box>
          </Stack.Item>
        </Stack>
      }
    >
      {!filteredAbilities.length ? (
        <NoticeBox>
          {abilities.length
            ? 'No sequences matched those search terms.'
            : 'No evolutions are currently available.'}
        </NoticeBox>
      ) : (
        <Stack vertical spacing={1}>
          {filteredAbilities.map((ability) => {
            const owned = owned_abilities.includes(ability.path);
            const hasPoints =
              ability.genetic_point_required <= genetic_points_count;
            const hasAbsorbs = ability.absorbs_required <= absorb_count;
            const hasDna = ability.dna_required <= dna_count;
            const canEvolve = hasPoints && hasAbsorbs && hasDna && !owned;
            const keyAvailable = !activeBuild?.key;

            return (
              <Stack.Item
                key={String(ability.path)}
                className="candystripe"
              >
                <Stack vertical spacing={0.5}>
                  <Stack align="center">
                    <Stack.Item grow>
                      <Box bold color={owned ? 'good' : undefined}>
                        {ability.name}
                      </Box>
                    </Stack.Item>
                    <Stack.Item>
                      <Box mr={1}>
                        {ability.genetic_point_required}
                        &nbsp;
                        <Icon
                          name="dna"
                          color={hasPoints ? '#DD66DD' : 'gray'}
                        />
                      </Box>
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="arrow-up"
                        content={owned ? 'Integrated' : 'Evolve'}
                        disabled={!canEvolve}
                        tooltip={
                          owned
                            ? 'This sequence is already part of our genome.'
                            : !hasPoints
                            ? 'We lack the genetic points for this evolution.'
                            : !hasAbsorbs
                            ? 'We must absorb additional hosts first.'
                            : !hasDna
                            ? 'We require more harvested DNA.'
                            : undefined
                        }
                        onClick={() =>
                          act('evolve', {
                            path: ability.path,
                            slot: 'secondary',
                          })
                        }
                      />
                    </Stack.Item>
                    {!owned && (
                      <Stack.Item>
                        <Button
                          icon="star"
                          content="Primary"
                          disabled={!canEvolve || !keyAvailable}
                          tooltip={
                            !canEvolve
                              ? 'Meet the evolution requirements first.'
                              : keyAvailable
                              ? 'Bind this ability as our key adaptation.'
                              : 'Primary slot already occupied.'
                          }
                          onClick={() =>
                            act('evolve', {
                              path: ability.path,
                              slot: 'key',
                            })
                          }
                        />
                      </Stack.Item>
                    )}
                  </Stack>
                  <Box>{ability.desc}</Box>
                  {!!ability.helptext && (
                    <Box color="good">{ability.helptext}</Box>
                  )}
                  <LabeledList>
                    <LabeledList.Item label="Absorb Requirement">
                      <Box color={hasAbsorbs ? 'good' : 'bad'}>
                        {ability.absorbs_required}
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="DNA Requirement">
                      <Box color={hasDna ? 'good' : 'bad'}>
                        {ability.dna_required}
                      </Box>
                    </LabeledList.Item>
                    {ability.chemical_cost > 0 && (
                      <LabeledList.Item label="Chemical Cost">
                        <Box>{ability.chemical_cost}</Box>
                      </LabeledList.Item>
                    )}
                    {!!ability.req_human && (
                      <LabeledList.Item label="Restriction">
                        Requires humanoid form.
                      </LabeledList.Item>
                    )}
                    {!!ability.req_stat && (
                      <LabeledList.Item label="Status Gate">
                        {`Requires targets in the ${String(ability.req_stat).toLowerCase()} state.`}
                      </LabeledList.Item>
                    )}
                    {!!ability.disabled_by_fire && (
                      <LabeledList.Item label="Limitation">
                        Disabled while on fire.
                      </LabeledList.Item>
                    )}
                  </LabeledList>
                </Stack>
              </Stack.Item>
            );
          })}
        </Stack>
      )}
    </Section>
  );
};

const ActiveEffectsSection = () => {
  const { data } = useBackend<GeneticMatrixData>();
  const activeEffects = data.active_effects ?? [];

  return (
    <Section fill scrollable title="Active Effects">
      {!activeEffects.length ? (
        <NoticeBox>No evolutions are currently manifested.</NoticeBox>
      ) : (
        <Stack vertical spacing={1}>
          {activeEffects.map((effect) => (
            <Stack.Item
              key={String(effect.path ?? effect.name)}
              className="candystripe"
            >
              <Stack vertical spacing={0.5}>
                <Stack align="center">
                  <Stack.Item grow>
                    <Box bold>
                      {effect.name}
                      {effect.innate ? ' (Innate)' : ''}
                    </Box>
                  </Stack.Item>
                  <Stack.Item>
                    <Box mr={1}>
                      Cost: {effect.dna_cost}
                      &nbsp;
                      <Icon name="dna" color="#DD66DD" />
                    </Box>
                  </Stack.Item>
                </Stack>
                <Box>{effect.desc}</Box>
                {!!effect.helptext && (
                  <Box color="good">{effect.helptext}</Box>
                )}
                <LabeledList>
                  <LabeledList.Item label="Chemical Cost">
                    {effect.chemical_cost}
                  </LabeledList.Item>
                  <LabeledList.Item label="Absorb Gate">
                    {effect.req_absorbs}
                  </LabeledList.Item>
                  <LabeledList.Item label="DNA Gate">
                    {effect.req_dna}
                  </LabeledList.Item>
                </LabeledList>
              </Stack>
            </Stack.Item>
          ))}
        </Stack>
      )}
    </Section>
  );
};

const ResourceSection = () => {
  const { act, data } = useBackend<GeneticMatrixData>();
  const {
    can_readapt,
    genetic_points_count,
    total_genetic_points,
    absorb_count,
    dna_count,
    chem_charges,
    chem_storage,
    chem_recharge_rate,
    chem_recharge_slowdown,
  } = data;

  const slowdown = Number(chem_recharge_slowdown);
  const rechargeText =
    slowdown === 0
      ? `${chem_recharge_rate}`
      : `${chem_recharge_rate} (${slowdown > 0 ? '-' : '+'}${Math.abs(slowdown)})`;

  return (
    <Section
      title="Matrix Resources"
      buttons={
        <Button
          icon="undo"
          color="good"
          disabled={!Boolean(can_readapt)}
          tooltip={
            can_readapt
              ? 'Reabsorb and reallocate all genetic points.'
              : 'Absorb more genomes to enable readaptation.'
          }
          onClick={() => act('readapt')}
        >
          Readapt
        </Button>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Genetic Points">
          <Box bold>
            {genetic_points_count} / {total_genetic_points}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Absorbed Hosts">
          {absorb_count}
        </LabeledList.Item>
        <LabeledList.Item label="DNA Samples">
          {dna_count}
        </LabeledList.Item>
        <LabeledList.Item label="Chemical Reserves">
          {chem_charges} / {chem_storage}
        </LabeledList.Item>
        <LabeledList.Item label="Recharge Rate">
          {rechargeText}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const ActiveBuildSection = () => {
  const { act, data } = useBackend<GeneticMatrixData>();
  const { active_build } = data;
  const keySlot = active_build?.key;
  const secondary = active_build?.secondary || [];
  const capacity = active_build?.secondary_capacity || 0;

  return (
    <Section title="Active Genome" scrollable>
      <Stack vertical spacing={1}>
        <Stack.Item>
          <BuildSlotCard
            title="Primary Adaptation"
            slot={keySlot}
            actions={
              keySlot?.path ? (
                <Button.Confirm
                  icon="trash"
                  color="bad"
                  onClick={() => act('retire_power', { path: keySlot.path })}
                >
                  Retire
                </Button.Confirm>
              ) : undefined
            }
          />
        </Stack.Item>
        <Stack.Item>
          <Box bold>
            Secondary Sequences ({secondary.length}/{capacity})
          </Box>
          {!secondary.length ? (
            <NoticeBox>Manifest secondary evolutions to fill this matrix.</NoticeBox>
          ) : (
            <Stack vertical spacing={1}>
              {secondary.map((slot) => (
                <Stack.Item key={`${slot.path}-${slot.index}`}>
                  <BuildSlotCard
                    title={`Secondary #${slot.index}`}
                    slot={slot}
                    actions={
                      <Stack align="center" spacing={0.5}>
                        <Stack.Item>
                          <Button
                            icon="star"
                            disabled={!slot.path}
                            tooltip="Promote to primary slot."
                            onClick={() =>
                              act('set_primary', {
                                path: slot.path,
                              })
                            }
                          >
                            Promote
                          </Button>
                        </Stack.Item>
                        <Stack.Item>
                          <Button.Confirm
                            icon="trash"
                            color="bad"
                            disabled={!slot.path}
                            onClick={() =>
                              act('retire_power', {
                                path: slot.path,
                              })
                            }
                          />
                        </Stack.Item>
                      </Stack>
                    }
                  />
                </Stack.Item>
              ))}
            </Stack>
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const BuildSlotCard = (props: {
  title: string;
  slot: BuildSlot | null;
  actions?: ReactNode;
}) => {
  const { title, slot, actions } = props;

  return (
    <Stack vertical spacing={0.5} className="candystripe">
      <Stack align="center">
        <Stack.Item grow>
          <Box bold>{title}</Box>
        </Stack.Item>
        {actions && <Stack.Item>{actions}</Stack.Item>}
      </Stack>
      {slot?.name ? (
        <Box>{slot.name}</Box>
      ) : (
        <Box italic color="label">
          No adaptation slotted.
        </Box>
      )}
      {slot?.desc && <Box>{slot.desc}</Box>}
      {slot?.helptext && <Box color="good">{slot.helptext}</Box>}
      {slot && (slot.dna_cost || slot.chemical_cost) ? (
        <LabeledList>
          {slot.dna_cost ? (
            <LabeledList.Item label="DNA Cost">
              {slot.dna_cost}
            </LabeledList.Item>
          ) : null}
          {slot.chemical_cost ? (
            <LabeledList.Item label="Chemical Cost">
              {slot.chemical_cost}
            </LabeledList.Item>
          ) : null}
        </LabeledList>
      ) : null}
    </Stack>
  );
};

const CraftingSection = () => {
  const { act, data } = useBackend<GeneticMatrixData>();
  const recipes = data.crafting_recipes ?? [];
  const biomaterials = data.biomaterials ?? [];
  const ownedAbilities = data.owned_abilities ?? [];
  const abilityCatalog = data.abilities ?? [];
  const activeEffects = data.active_effects ?? [];
  const craftingResult = data.crafting_result ?? null;

  const abilityMetadata = useMemo(() => {
    const map = new Map<typePath, { name: string; desc?: string }>();
    abilityCatalog.forEach((ability) => {
      map.set(ability.path, { name: ability.name, desc: ability.desc });
    });
    activeEffects.forEach((effect) => {
      if (effect.path) {
        map.set(effect.path, { name: effect.name, desc: effect.desc });
      }
    });
    return map;
  }, [abilityCatalog, activeEffects]);

  const abilityOptions = useMemo(() => {
    const options: Array<{ path: typePath; name: string; desc?: string }> = [];
    const seen = new Set<typePath>();
    const add = (path: typePath | null | undefined) => {
      if (!path || seen.has(path)) {
        return;
      }
      seen.add(path);
      const meta = abilityMetadata.get(path);
      options.push({
        path,
        name: meta?.name ?? String(path),
        desc: meta?.desc,
      });
    };
    ownedAbilities.forEach(add);
    activeEffects
      .filter((effect) => Boolean(effect.innate))
      .forEach((effect) => add(effect.path));
    options.sort((a, b) => a.name.localeCompare(b.name));
    return options;
  }, [abilityMetadata, ownedAbilities, activeEffects]);

  const biomaterialLookup = useMemo(() => {
    const lookup = new Map<
      string,
      { categoryName: string; itemMap: Map<string, BiomaterialEntry> }
    >();
    biomaterials.forEach((entry) => {
      const categoryId = entry.category;
      if (!categoryId) {
        return;
      }
      let bucket = lookup.get(categoryId);
      if (!bucket) {
        bucket = {
          categoryName: entry.category_name ?? categoryId,
          itemMap: new Map<string, BiomaterialEntry>(),
        };
        lookup.set(categoryId, bucket);
      } else if (entry.category_name && bucket.categoryName !== entry.category_name) {
        bucket.categoryName = entry.category_name;
      }
      bucket.itemMap.set(entry.id, entry);
    });
    return lookup;
  }, [biomaterials]);

  const [selectedRecipeId, setSelectedRecipeId] = useState<string | null>(null);
  useEffect(() => {
    if (!recipes.length) {
      setSelectedRecipeId(null);
      return;
    }
    setSelectedRecipeId((prev) => {
      if (prev && recipes.some((recipe) => recipe.id === prev)) {
        return prev;
      }
      return recipes[0].id;
    });
  }, [recipes]);

  const selectedRecipe = useMemo(() => {
    if (!recipes.length) {
      return null;
    }
    if (!selectedRecipeId) {
      return recipes[0];
    }
    return recipes.find((recipe) => recipe.id === selectedRecipeId) ?? recipes[0];
  }, [recipes, selectedRecipeId]);

  const [materialSelection, setMaterialSelection] = useState<
    Record<string, Record<string, number>>
  >({});
  const [abilitySelection, setAbilitySelection] = useState<typePath[]>([]);

  useEffect(() => {
    setAbilitySelection((prev) =>
      prev.filter((path) => abilityOptions.some((option) => option.path === path)),
    );
  }, [abilityOptions]);

  useEffect(() => {
    setMaterialSelection((prev) => {
      let changed = false;
      const next: Record<string, Record<string, number>> = {};
      for (const [categoryId, items] of Object.entries(prev)) {
        const lookupEntry = biomaterialLookup.get(categoryId);
        if (!lookupEntry) {
          changed = true;
          continue;
        }
        for (const [itemId, count] of Object.entries(items)) {
          const available = lookupEntry.itemMap.get(itemId)?.count ?? 0;
          if (available <= 0) {
            if (count > 0) {
              changed = true;
            }
            continue;
          }
          const clamped = Math.min(count, available);
          if (clamped <= 0) {
            if (count > 0) {
              changed = true;
            }
            continue;
          }
          if (!next[categoryId]) {
            next[categoryId] = {};
          }
          next[categoryId][itemId] = clamped;
          if (clamped !== count) {
            changed = true;
          }
        }
      }
      return changed ? next : prev;
    });
  }, [biomaterialLookup]);

  const updateMaterialSelection = (
    categoryId: string,
    itemId: string,
    compute: (current: number, available: number) => number,
  ) => {
    const lookupEntry = biomaterialLookup.get(categoryId);
    const available = lookupEntry?.itemMap.get(itemId)?.count ?? 0;
    setMaterialSelection((prev) => {
      const current = prev[categoryId]?.[itemId] ?? 0;
      const target = Math.max(0, Math.min(compute(current, available), available));
      if (target === current) {
        return prev;
      }
      const next = { ...prev };
      const categoryEntries = { ...(next[categoryId] ?? {}) };
      if (target <= 0) {
        delete categoryEntries[itemId];
      } else {
        categoryEntries[itemId] = target;
      }
      if (Object.keys(categoryEntries).length) {
        next[categoryId] = categoryEntries;
      } else {
        delete next[categoryId];
      }
      return next;
    });
  };

  const incrementMaterial = (categoryId: string, itemId: string, delta: number) => {
    updateMaterialSelection(categoryId, itemId, (current) => current + delta);
  };

  const setMaterialAmount = (categoryId: string, itemId: string, amount: number) => {
    updateMaterialSelection(categoryId, itemId, () => amount);
  };

  const clearMaterial = (categoryId: string, itemId: string) => {
    updateMaterialSelection(categoryId, itemId, () => 0);
  };

  const toggleAbility = (path: typePath) => {
    if (!abilityOptions.some((option) => option.path === path)) {
      return;
    }
    setAbilitySelection((prev) => {
      if (prev.includes(path)) {
        return prev.filter((entry) => entry !== path);
      }
      return [...prev, path];
    });
  };

  const selectedMaterials = useMemo(() => {
    const entries: Array<{
      categoryId: string;
      itemId: string;
      count: number;
      categoryName: string;
      itemName: string;
    }> = [];
    for (const [categoryId, items] of Object.entries(materialSelection)) {
      const lookupEntry = biomaterialLookup.get(categoryId);
      const categoryName = lookupEntry?.categoryName ?? categoryId;
      for (const [itemId, count] of Object.entries(items)) {
        if (count <= 0) {
          continue;
        }
        const itemName = lookupEntry?.itemMap.get(itemId)?.name ?? itemId;
        entries.push({
          categoryId,
          itemId,
          count,
          categoryName,
          itemName,
        });
      }
    }
    return entries;
  }, [materialSelection, biomaterialLookup]);

  const hasMaterials = selectedMaterials.length > 0;
  const abilitySelectionSet = useMemo(() => new Set(abilitySelection), [abilitySelection]);

  const clearSelection = () => {
    setMaterialSelection({});
    setAbilitySelection([]);
  };

  const loadRequirements = () => {
    if (!selectedRecipe) {
      clearSelection();
      return;
    }
    const nextMaterials: Record<string, Record<string, number>> = {};
    selectedRecipe.biomaterials.forEach((requirement) => {
      const lookupEntry = biomaterialLookup.get(requirement.category);
      const available = lookupEntry?.itemMap.get(requirement.id)?.count ?? 0;
      const amount = Math.min(available, requirement.count);
      if (amount > 0) {
        if (!nextMaterials[requirement.category]) {
          nextMaterials[requirement.category] = {};
        }
        nextMaterials[requirement.category][requirement.id] = amount;
      }
    });
    setMaterialSelection(nextMaterials);
    const requiredAbilities =
      selectedRecipe.abilities
        .map((ability) => ability.path)
        .filter((path) => abilityOptions.some((option) => option.path === path)) ?? [];
    setAbilitySelection(requiredAbilities);
  };

  const attemptCraft = () => {
    if (!hasMaterials) {
      return;
    }
    const materialPayload = selectedMaterials.map((entry) => ({
      category: entry.categoryId,
      id: entry.itemId,
      count: entry.count,
    }));
    const abilityPayload = abilitySelection.map((path) => String(path));
    act('craft', {
      materials: JSON.stringify(materialPayload),
      abilities: JSON.stringify(abilityPayload),
    });
  };

  const resultTimestamp = craftingResult?.timestamp ?? 0;
  useEffect(() => {
    if (craftingResult && Boolean(craftingResult.success)) {
      setMaterialSelection({});
      setAbilitySelection([]);
    }
  }, [craftingResult?.success, resultTimestamp]);

  const getAvailableMaterialCount = (categoryId: string, itemId: string) => {
    return biomaterialLookup.get(categoryId)?.itemMap.get(itemId)?.count ?? 0;
  };

  const formatPassiveLabel = (key: string) => {
    switch (key) {
      case 'chem_storage':
        return 'Chemical Storage';
      case 'chem_charges':
        return 'Chemical Charges';
      case 'chem_recharge_rate':
        return 'Recharge Rate';
      case 'chem_recharge_slowdown':
        return 'Recharge Slowdown';
      default:
        return key.replace(/_/g, ' ');
    }
  };

  const craftingButtons = (
    <Stack spacing={1} align="center">
      <Stack.Item>
        <Button
          icon="magic"
          content="Load Requirements"
          disabled={!selectedRecipe}
          onClick={loadRequirements}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="trash"
          color="bad"
          content="Clear"
          disabled={!hasMaterials && !abilitySelection.length}
          onClick={clearSelection}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="flask"
          color="good"
          content="Weave"
          disabled={!hasMaterials}
          tooltip={
            hasMaterials
              ? 'Weave the configured genome pattern.'
              : 'Select biomaterials to begin weaving.'
          }
          onClick={attemptCraft}
        />
      </Stack.Item>
    </Stack>
  );

  return (
    <Section fill scrollable title="Genome Crafting" buttons={craftingButtons}>
      {!recipes.length ? (
        <NoticeBox>No genome weaving patterns have been recorded.</NoticeBox>
      ) : (
        <Stack spacing={1} fill>
          <Stack.Item grow basis="45%">
            <Stack vertical spacing={1}>
              {recipes.map((recipe) => {
                const inventoryReady = recipe.biomaterials.every((requirement) => {
                  return (
                    getAvailableMaterialCount(requirement.category, requirement.id) >=
                    requirement.count
                  );
                });
                const abilityReady = recipe.abilities.every((requirement) =>
                  abilityOptions.some((option) => option.path === requirement.path),
                );
                const selected = selectedRecipe
                  ? recipe.id === selectedRecipe.id
                  : recipe.id === recipes[0].id;
                return (
                  <Stack.Item key={recipe.id} className="candystripe">
                    <Stack vertical spacing={0.5}>
                      <Button
                        fluid
                        selected={selected}
                        onClick={() => setSelectedRecipeId(recipe.id)}
                      >
                        {recipe.name}
                      </Button>
                      <Box>{recipe.description}</Box>
                      <Stack spacing={1} wrap>
                        <Stack.Item>
                          <Box color={inventoryReady ? 'good' : 'bad'}>
                            Materials {inventoryReady ? 'ready' : 'insufficient'}
                          </Box>
                        </Stack.Item>
                        <Stack.Item>
                          <Box
                            color={
                              recipe.abilities.length
                                ? abilityReady
                                  ? 'good'
                                  : 'bad'
                                : 'label'
                            }
                          >
                            {recipe.abilities.length
                              ? abilityReady
                                ? 'Catalysts prepared'
                                : 'Catalysts missing'
                              : 'No catalysts required'}
                          </Box>
                        </Stack.Item>
                      </Stack>
                    </Stack>
                  </Stack.Item>
                );
              })}
            </Stack>
          </Stack.Item>
          <Stack.Item grow basis="55%">
            {!selectedRecipe ? (
              <NoticeBox>Select a pattern to review its requirements.</NoticeBox>
            ) : (
              <Stack vertical spacing={1}>
                <Stack.Item>
                  <Stack vertical spacing={0.5}>
                    <Box bold>{selectedRecipe.name}</Box>
                    <Box>{selectedRecipe.description}</Box>
                    {selectedRecipe.result_text ? (
                      <Box color="good">{selectedRecipe.result_text}</Box>
                    ) : null}
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Box bold>Material Requirements</Box>
                  {!selectedRecipe.biomaterials.length ? (
                    <Box italic color="label">
                      No biomaterials required.
                    </Box>
                  ) : (
                    <Stack vertical spacing={0.5}>
                      {selectedRecipe.biomaterials.map((requirement) => {
                        const available = getAvailableMaterialCount(
                          requirement.category,
                          requirement.id,
                        );
                        const selectedAmount =
                          materialSelection[requirement.category]?.[requirement.id] ?? 0;
                        const requirementMet = selectedAmount === requirement.count;
                        const color = requirementMet
                          ? 'good'
                          : available >= requirement.count
                          ? 'average'
                          : 'bad';
                        return (
                          <Stack.Item
                            key={`${requirement.category}-${requirement.id}`}
                            className="candystripe"
                          >
                            <Stack vertical spacing={0.5}>
                              <Stack align="baseline" justify="space-between">
                                <Stack.Item grow>
                                  <Box>
                                    {requirement.name}{' '}
                                    <Box as="span" color="label">
                                      ({requirement.category_name})
                                    </Box>
                                  </Box>
                                </Stack.Item>
                                <Stack.Item>
                                  <Box color={color}>
                                    {selectedAmount}/{requirement.count} selected — {available}{' '}
                                    available
                                  </Box>
                                </Stack.Item>
                              </Stack>
                              {requirement.description ? (
                                <Box color="label">{requirement.description}</Box>
                              ) : null}
                              <Stack spacing={1} align="center">
                                <Stack.Item>
                                  <Button
                                    icon="minus"
                                    disabled={selectedAmount <= 0}
                                    onClick={() =>
                                      incrementMaterial(
                                        requirement.category,
                                        requirement.id,
                                        -1,
                                      )
                                    }
                                  />
                                </Stack.Item>
                                <Stack.Item>
                                  <Button
                                    icon="plus"
                                    disabled={available <= selectedAmount}
                                    onClick={() =>
                                      incrementMaterial(
                                        requirement.category,
                                        requirement.id,
                                        1,
                                      )
                                    }
                                  />
                                </Stack.Item>
                                <Stack.Item>
                                  <Button
                                    icon="bullseye"
                                    content="Match"
                                    disabled={!available}
                                    onClick={() =>
                                      setMaterialAmount(
                                        requirement.category,
                                        requirement.id,
                                        requirement.count,
                                      )
                                    }
                                  />
                                </Stack.Item>
                              </Stack>
                            </Stack>
                          </Stack.Item>
                        );
                      })}
                    </Stack>
                  )}
                </Stack.Item>
                <Stack.Item>
                  <Box bold>Selected Biomaterials</Box>
                  {!selectedMaterials.length ? (
                    <Box italic color="label">
                      No biomaterials selected.
                    </Box>
                  ) : (
                    <Stack vertical spacing={0.5}>
                      {selectedMaterials.map((entry) => (
                        <Stack.Item
                          key={`${entry.categoryId}-${entry.itemId}`}
                          className="candystripe"
                        >
                          <Stack align="center" spacing={1} justify="space-between">
                            <Stack.Item grow>
                              <Box>
                                {entry.itemName}{' '}
                                <Box as="span" color="label">
                                  ({entry.categoryName})
                                </Box>
                              </Box>
                            </Stack.Item>
                            <Stack.Item>
                              <Box bold>{entry.count}</Box>
                            </Stack.Item>
                            <Stack.Item>
                              <Button
                                icon="times"
                                color="bad"
                                onClick={() => clearMaterial(entry.categoryId, entry.itemId)}
                              />
                            </Stack.Item>
                          </Stack>
                        </Stack.Item>
                      ))}
                    </Stack>
                  )}
                </Stack.Item>
                <Stack.Item>
                  <Stack vertical spacing={0.5}>
                    <Box bold>Ability Catalysts</Box>
                    {!selectedRecipe.abilities.length ? (
                      <Box italic color="label">
                        No ability catalysts required.
                      </Box>
                    ) : (
                      <Stack vertical spacing={0.5}>
                        {selectedRecipe.abilities.map((requirement) => {
                          const option = abilityOptions.find(
                            (entry) => entry.path === requirement.path,
                          );
                          const owned = Boolean(option);
                          const selected = abilitySelectionSet.has(requirement.path);
                          const color = selected ? 'good' : owned ? 'average' : 'bad';
                          return (
                            <Stack.Item
                              key={String(requirement.path)}
                              className="candystripe"
                            >
                              <Stack vertical spacing={0.5}>
                                <Box color={color}>
                                  {requirement.name}
                                  {!owned
                                    ? ' — Missing'
                                    : selected
                                    ? ' — Selected'
                                    : ' — Available'}
                                </Box>
                                {requirement.desc ? (
                                  <Box color="label">{requirement.desc}</Box>
                                ) : null}
                              </Stack>
                            </Stack.Item>
                          );
                        })}
                      </Stack>
                    )}
                    {!abilityOptions.length ? (
                      <Box italic color="label">
                        No evolutions available for catalysis.
                      </Box>
                    ) : (
                      <Stack wrap spacing={0.5}>
                        {abilityOptions.map((option) => (
                          <Stack.Item key={String(option.path)}>
                            <Button.Checkbox
                              checked={abilitySelectionSet.has(option.path)}
                              onClick={() => toggleAbility(option.path)}
                              tooltip={option.desc}
                            >
                              {option.name}
                            </Button.Checkbox>
                          </Stack.Item>
                        ))}
                      </Stack>
                    )}
                  </Stack>
                </Stack.Item>
                {selectedRecipe.grants?.length ? (
                  <Stack.Item>
                    <Box bold>Potential Grants</Box>
                    <Stack vertical spacing={0.5}>
                      {selectedRecipe.grants.map((grant) => (
                        <Stack.Item key={String(grant.path)} className="candystripe">
                          <Stack vertical spacing={0.5}>
                            <Box>
                              {grant.name}{' '}
                              <Box as="span" color="label">
                                ({grant.slot_name ?? grant.slot})
                              </Box>
                            </Box>
                            {grant.desc ? <Box color="label">{grant.desc}</Box> : null}
                          </Stack>
                        </Stack.Item>
                      ))}
                    </Stack>
                  </Stack.Item>
                ) : null}
                {selectedRecipe.passives && Object.keys(selectedRecipe.passives).length ? (
                  <Stack.Item>
                    <Box bold>Passive Adjustments</Box>
                    <LabeledList>
                      {Object.entries(selectedRecipe.passives).map(([key, value]) => (
                        <LabeledList.Item key={key} label={formatPassiveLabel(key)}>
                          {value > 0 ? `+${value}` : value}
                        </LabeledList.Item>
                      ))}
                    </LabeledList>
                  </Stack.Item>
                ) : null}
                <Stack.Item>
                  <Box bold>Crafting Outcome</Box>
                  {!craftingResult ? (
                    <NoticeBox color="label">
                      Configure biomaterials and weave to review outcomes.
                    </NoticeBox>
                  ) : (
                    <Stack vertical spacing={0.5}>
                      <NoticeBox color={Boolean(craftingResult.success) ? 'good' : 'bad'}>
                        {craftingResult.message}
                      </NoticeBox>
                      {craftingResult.grants?.length ? (
                        <Stack vertical spacing={0.5}>
                          {craftingResult.grants.map((grant, index) => (
                            <Stack.Item
                              key={`${grant.path}-${grant.slot}-${index}`}
                              className="candystripe"
                            >
                              <Stack vertical spacing={0.5}>
                                <Box color={Boolean(grant.success) ? 'good' : 'bad'}>
                                  {grant.name}
                                  {grant.slot_name ? ` — ${grant.slot_name}` : ''}
                                </Box>
                                {grant.message ? (
                                  <Box color="label">{grant.message}</Box>
                                ) : null}
                              </Stack>
                            </Stack.Item>
                          ))}
                        </Stack>
                      ) : null}
                      {craftingResult.passives &&
                      Object.keys(craftingResult.passives).length ? (
                        <LabeledList>
                          {Object.entries(craftingResult.passives).map(([key, value]) => (
                            <LabeledList.Item key={key} label={formatPassiveLabel(key)}>
                              {value}
                            </LabeledList.Item>
                          ))}
                        </LabeledList>
                      ) : null}
                      {craftingResult.errors?.length ? (
                        <Stack vertical spacing={0.5}>
                          {craftingResult.errors.map((error, index) => (
                            <NoticeBox key={`${error}-${index}`} color="bad">
                              {error}
                            </NoticeBox>
                          ))}
                        </Stack>
                      ) : null}
                    </Stack>
                  )}
                </Stack.Item>
              </Stack>
            )}
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
};

const BiomaterialSection = () => {
  const { data } = useBackend<GeneticMatrixData>();
  const biomaterials = data.biomaterials ?? [];
  const [searchQuery, setSearchQuery] = useState('');

  const filteredBiomaterials = useMemo(() => {
    const query = searchQuery.trim().toLowerCase();
    const matches = biomaterials.filter((entry) => {
      if (!query) {
        return true;
      }
      const name = entry.name.toLowerCase();
      const description = entry.description?.toLowerCase() ?? '';
      const category = (entry.category_name ?? entry.category ?? '').toLowerCase();
      return (
        name.includes(query) ||
        description.includes(query) ||
        category.includes(query)
      );
    });
    return matches
      .slice()
      .sort((a, b) => {
        const categoryA = (a.category_name ?? a.category ?? '').toLowerCase();
        const categoryB = (b.category_name ?? b.category ?? '').toLowerCase();
        if (categoryA !== categoryB) {
          return categoryA.localeCompare(categoryB);
        }
        const nameA = a.name.toLowerCase();
        const nameB = b.name.toLowerCase();
        if (nameA !== nameB) {
          return nameA.localeCompare(nameB);
        }
        return a.id.localeCompare(b.id);
      });
  }, [biomaterials, searchQuery]);

  const hasBiomaterials = biomaterials.length > 0;
  const trimmedQuery = searchQuery.trim();

  return (
    <Section
      title="Biomaterial Stores"
      scrollable
      buttons={
        <Input
          width="220px"
          placeholder="Search samples..."
          value={searchQuery}
          onChange={setSearchQuery}
        />
      }
    >
      {!hasBiomaterials ? (
        <NoticeBox>No biomaterial harvested.</NoticeBox>
      ) : !filteredBiomaterials.length ? (
        <NoticeBox>
          {trimmedQuery.length
            ? 'No biomaterial matched those search terms.'
            : 'No biomaterial catalogued.'}
        </NoticeBox>
      ) : (
        <Stack vertical spacing={1}>
          {filteredBiomaterials.map((entry) => (
            <Stack.Item
              key={`${entry.category}-${entry.id}`}
              className="candystripe"
            >
              <Stack vertical spacing={0.5}>
                <Stack align="baseline" justify="space-between">
                  <Stack.Item grow>
                    <Box>
                      {entry.name}{' '}
                      <Box as="span" color="label">
                        ({entry.category_name ?? entry.category})
                      </Box>
                    </Box>
                  </Stack.Item>
                  <Stack.Item>
                    <Box bold>{entry.count}</Box>
                  </Stack.Item>
                </Stack>
                {entry.description ? (
                  <Box color="label">{entry.description}</Box>
                ) : null}
                {entry.quality ? (
                  <Box color="good">Quality: {String(entry.quality)}</Box>
                ) : null}
              </Stack>
            </Stack.Item>
          ))}
        </Stack>
      )}
    </Section>
  );
};

const SignatureSection = () => {
  const { data } = useBackend<GeneticMatrixData>();
  const signatureCells = data.signature_cells ?? [];

  return (
    <Section title="Signature Cells" scrollable>
      {!signatureCells.length ? (
        <NoticeBox>No harvested signatures stored.</NoticeBox>
      ) : (
        <Stack vertical spacing={1}>
          {signatureCells.map((cell) => (
            <Stack.Item key={cell.id} className="candystripe">
              <Stack vertical spacing={0.5}>
                <Stack align="baseline" justify="space-between">
                  <Stack.Item grow>
                    <Box bold>{cell.name}</Box>
                  </Stack.Item>
                  <Stack.Item>
                    <Box bold>{cell.count}</Box>
                  </Stack.Item>
                </Stack>
                {cell.description && (
                  <Box color="label">{cell.description}</Box>
                )}
              </Stack>
            </Stack.Item>
          ))}
        </Stack>
      )}
    </Section>
  );
};

const SynergySection = () => {
  const { data } = useBackend<GeneticMatrixData>();
  const synergyTips = data.synergy_tips ?? [];

  return (
    <Section title="Synergy Guidance" scrollable>
      {!synergyTips.length ? (
        <NoticeBox>
          Integrate additional genomes to unlock synergy insights.
        </NoticeBox>
      ) : (
        <Stack vertical spacing={1}>
          {synergyTips.map((tip) => (
            <Stack.Item key={tip.title} className="candystripe">
              <Stack vertical spacing={0.5}>
                <Box bold>{tip.title}</Box>
                <Box>{tip.description}</Box>
                {!!tip.abilities?.length && (
                  <Box italic color="label">
                    {tip.abilities.join(', ')}
                  </Box>
                )}
              </Stack>
            </Stack.Item>
          ))}
        </Stack>
      )}
    </Section>
  );
};

const WarningsSection = () => {
  const { data } = useBackend<GeneticMatrixData>();
  const incompatibilities = data.incompatibilities ?? [];

  return (
    <Section title="Incompatibilities" scrollable>
      {!incompatibilities.length ? (
        <NoticeBox color="good">
          No incompatibilities detected.
        </NoticeBox>
      ) : (
        <Stack vertical spacing={1}>
          {incompatibilities.map((warning, index) => (
            <Stack.Item key={`${warning}-${index}`}>
              <NoticeBox color="bad">{warning}</NoticeBox>
            </Stack.Item>
          ))}
        </Stack>
      )}
    </Section>
  );
};

const PresetSection = () => {
  const { act, data } = useBackend<GeneticMatrixData>();
  const presets = data.presets ?? [];
  const { preset_limit } = data;
  const [newPresetName, setNewPresetName] = useState('');

  const presetsFull = presets.length >= preset_limit && preset_limit > 0;

  const savePreset = () => {
    act('save_preset', {
      name: newPresetName,
    });
    setNewPresetName('');
  };

  return (
    <Section
      fill
      scrollable
      title="Genome Presets"
      buttons={
        <Stack align="center" spacing={1}>
          <Stack.Item textColor="label">
            {presets.length}/{preset_limit || '∞'}
          </Stack.Item>
          <Stack.Item>
            <Input
              width="180px"
              placeholder="Name new preset"
              value={newPresetName}
              disabled={presetsFull}
              onChange={setNewPresetName}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="save"
              content="Store"
              disabled={presetsFull}
              onClick={savePreset}
            />
          </Stack.Item>
        </Stack>
      }
    >
      {!presets.length ? (
        <NoticeBox>
          Save evolved kits here for rapid reassignment.
        </NoticeBox>
      ) : (
        <Stack vertical spacing={1}>
          {presets.map((preset) => (
            <Stack.Item key={preset.id} className="candystripe">
              <PresetRow preset={preset} />
            </Stack.Item>
          ))}
        </Stack>
      )}
      {presetsFull && (
        <Box mt={1} color="bad">
          Memory saturated — delete a preset before storing another.
        </Box>
      )}
    </Section>
  );
};

const PresetRow = (props: { preset: GeneticPreset }) => {
  const { act } = useBackend<GeneticMatrixData>();
  const { preset } = props;
  const [editing, setEditing] = useState(false);
  const [draftName, setDraftName] = useState(preset.name);
  const { primary } = preset;
  const secondaries = preset.secondaries ?? [];

  useEffect(() => {
    setDraftName(preset.name);
  }, [preset.name]);

  const confirmRename = () => {
    act('rename_preset', {
      id: preset.id,
      name: draftName,
    });
    setEditing(false);
  };

  const blueprintSummary = useMemo(() => {
    const lines: string[] = [];
    if (primary) {
      lines.push(`Primary: ${primary.name ?? 'Uncatalogued sequence'}`);
    }
    if (secondaries.length) {
      for (const slot of secondaries) {
        lines.push(
          `Secondary #${slot.index}: ${slot.name ?? 'Uncatalogued sequence'}`,
        );
      }
    }
    return lines;
  }, [primary, secondaries]);

  return (
    <Stack vertical spacing={0.5}>
      <Stack align="center" spacing={1}>
        <Stack.Item grow>
          {editing ? (
            <Input value={draftName} onChange={setDraftName} />
          ) : (
            <Box bold>{preset.name}</Box>
          )}
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="play"
            content="Apply"
            onClick={() => act('apply_preset', { id: preset.id })}
          />
        </Stack.Item>
        <Stack.Item>
          {editing ? (
            <Stack align="center" spacing={0.5}>
              <Stack.Item>
                <Button
                  icon="check"
                  color="good"
                  disabled={!draftName.trim()}
                  onClick={confirmRename}
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="times"
                  color="bad"
                  onClick={() => {
                    setEditing(false);
                    setDraftName(preset.name);
                  }}
                />
              </Stack.Item>
            </Stack>
          ) : (
            <Button icon="edit" onClick={() => setEditing(true)} />
          )}
        </Stack.Item>
        <Stack.Item>
          <Button.Confirm
            icon="trash"
            color="bad"
            onClick={() => act('delete_preset', { id: preset.id })}
          />
        </Stack.Item>
      </Stack>
      {blueprintSummary.length ? (
        <Stack vertical spacing={0.25}>
          {blueprintSummary.map((line, index) => (
            <Box key={`${preset.id}-summary-${index}`} color="label">
              {line}
            </Box>
          ))}
        </Stack>
      ) : (
        <Box italic color="label">
          No sequences imprinted.
        </Box>
      )}
    </Stack>
  );
};

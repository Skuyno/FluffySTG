import { ReactNode, useEffect, useMemo, useState } from 'react';
import {
  Box,
  Button,
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

type ActiveEffect = {
  name: string;
  desc: string;
  helptext: string;
  path: typePath;
  chemical_cost: number;
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

type RecipeRequirement = {
  type: 'biomaterial' | 'signature' | 'signature_any';
  category?: string;
  name: string;
  required: number;
  available: number;
};

type Recipe = {
  id: string;
  name: string;
  description: string;
  result_type: string;
  repeatable: BooleanLike;
  ability_path?: typePath | null;
  ability_name?: string;
  ability_desc?: string;
  ability_helptext?: string;
  owned?: BooleanLike;
  requirements: RecipeRequirement[];
  req_absorbs?: number;
  req_dna?: number;
  chemical_cost?: number;
  req_human?: BooleanLike;
  req_stat?: string | null;
  disabled_by_fire?: BooleanLike;
};

type BiomaterialItem = {
  id: string;
  name: string;
  count: number;
  description?: string;
  quality?: string | number;
};

type BiomaterialCategory = {
  id: string;
  name: string;
  items: BiomaterialItem[];
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

type GeneticMatrixData = {
  can_readapt: BooleanLike;
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
  recipes: Recipe[];
  biomaterials: BiomaterialCategory[];
  signature_cells: SignatureCell[];
};

export const GeneticMatrix = () => {
  const { data } = useBackend<GeneticMatrixData>();
  const [searchQuery, setSearchQuery] = useState('');
  const recipes = data.recipes ?? [];
  const activeBuild =
    data.active_build ?? ({
      key: null,
      secondary: [],
      secondary_capacity: 0,
    } as ActiveBuildState);

  const filteredRecipes = useMemo(() => {
    if (!searchQuery || searchQuery.length < 2) {
      return recipes;
    }

    const lowered = searchQuery.toLowerCase();
    return recipes.filter((recipe) => {
      const name = recipe.ability_name || recipe.name;
      const desc = recipe.ability_desc || recipe.description || '';
      const help = recipe.ability_helptext || '';
      return (
        name.toLowerCase().includes(lowered) ||
        desc.toLowerCase().includes(lowered) ||
        help.toLowerCase().includes(lowered)
      );
    });
  }, [recipes, searchQuery]);

  return (
    <Window width={1100} height={640} theme="syndicate">
      <Window.Content>
        <Stack fill>
          <Stack.Item grow basis="60%">
            <Stack fill vertical>
              <Stack.Item grow>
                <RecipeCatalogSection
                  recipes={filteredRecipes}
                  searchQuery={searchQuery}
                  setSearchQuery={setSearchQuery}
                  activeBuild={activeBuild}
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

const RecipeCatalogSection = (props: {
  recipes: Recipe[];
  searchQuery: string;
  setSearchQuery: (value: string) => void;
  activeBuild: ActiveBuildState;
}) => {
  const { act, data } = useBackend<GeneticMatrixData>();
  const { recipes, searchQuery, setSearchQuery, activeBuild } = props;
  const absorbCount = Number(data.absorb_count) || 0;
  const dnaCount = Number(data.dna_count) || 0;
  const keySlot = activeBuild?.key;
  const secondary = activeBuild?.secondary || [];
  const secondaryCapacity = activeBuild?.secondary_capacity || 0;
  const secondaryFull =
    secondaryCapacity > 0 && secondary.length >= secondaryCapacity;

  const formatLabel = (value?: string) => {
    if (!value) {
      return '';
    }
    return value
      .split('_')
      .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
      .join(' ');
  };

  const describeRequirement = (requirement: RecipeRequirement) => {
    switch (requirement.type) {
      case 'biomaterial':
        return requirement.category
          ? `Biomaterial • ${formatLabel(requirement.category)}`
          : 'Biomaterial';
      case 'signature':
        return 'Signature Cell';
      case 'signature_any':
        return 'Signature Cell (Any)';
      default:
        return 'Requirement';
    }
  };

  const formatDeficit = (requirement: RecipeRequirement) => {
    const required = Number(requirement.required) || 0;
    const available = Number(requirement.available) || 0;
    const missing = required - available;
    if (missing <= 0) {
      return null;
    }
    const name = requirement.name || describeRequirement(requirement);
    return `${missing} ${name}`;
  };

  return (
    <Section
      fill
      scrollable
      title="Cytology Catalog"
      buttons={
        <Stack align="center" spacing={1}>
          <Stack.Item>
            <Input
              width="220px"
              placeholder="Search sequences..."
              value={searchQuery}
              onChange={setSearchQuery}
            />
          </Stack.Item>
        </Stack>
      }
    >
      {!recipes.length ? (
        <NoticeBox>No cytology sequences are currently available.</NoticeBox>
      ) : (
        <Stack vertical spacing={1}>
          {recipes.map((recipe) => {
            const resultType = (recipe.result_type || 'ability').toLowerCase();
            const requirements = recipe.requirements ?? [];
            const requirementDeficits = requirements
              .map(formatDeficit)
              .filter(Boolean) as string[];
            const requirementsMet = requirementDeficits.length === 0;
            const repeatable = Boolean(recipe.repeatable);
            const owned = Boolean(recipe.owned);
            const abilityName = recipe.ability_name || recipe.name;
            const description = recipe.ability_desc || recipe.description;
            const helptext = recipe.ability_helptext || '';
            const chemicalCost = Number(recipe.chemical_cost) || 0;
            const absorbReq = Number(recipe.req_absorbs) || 0;
            const dnaReq = Number(recipe.req_dna) || 0;
            const hasAbsorbs = absorbCount >= absorbReq;
            const hasDna = dnaCount >= dnaReq;
            const keyAvailable =
              !keySlot?.path || keySlot.path === recipe.ability_path;
            const canCraftAbility =
              requirementsMet && (repeatable || !owned) && hasAbsorbs && hasDna;
            const canCraftSecondary =
              canCraftAbility && !secondaryFull;
            const canCraftPrimary = canCraftAbility && keyAvailable;

            const buildAbilityTooltip = (target: 'primary' | 'secondary') => {
              const parts: string[] = [];
              if (owned && !repeatable) {
                parts.push('Sequence already integrated.');
              }
              if (!requirementsMet) {
                if (requirementDeficits.length) {
                  parts.push(`Missing ${requirementDeficits.join(', ')}.`);
                } else {
                  parts.push('Missing required materials.');
                }
              }
              if (absorbReq > 0 && !hasAbsorbs) {
                parts.push(
                  `Requires ${absorbReq} absorbed host${
                    absorbReq === 1 ? '' : 's'
                  }.`,
                );
              }
              if (dnaReq > 0 && !hasDna) {
                parts.push(
                  `Requires ${dnaReq} stored DNA profile${
                    dnaReq === 1 ? '' : 's'
                  }.`,
                );
              }
              if (target === 'secondary' && secondaryFull) {
                parts.push('Secondary slots at capacity.');
              }
              if (target === 'primary' && !keyAvailable) {
                parts.push('Primary slot already occupied.');
              }
              return parts.length ? parts.join(' ') : undefined;
            };

            const integrateLabel = owned
              ? repeatable
                ? 'Imprint Again'
                : 'Integrated'
              : 'Imprint';
            const integrateTooltip = buildAbilityTooltip('secondary');
            const primaryTooltip = buildAbilityTooltip('primary');

            const synthTooltip = !requirementsMet
              ? requirementDeficits.length
                ? `Missing ${requirementDeficits.join(', ')}.`
                : 'Missing required materials.'
              : undefined;

            const rowKeyBase = recipe.id || recipe.name;
            const rows: ReactNode[] = [];
            if (resultType === 'ability' && absorbReq > 0) {
              rows.push(
                <LabeledList.Item
                  key={`${rowKeyBase}-absorb`}
                  label="Absorb Threshold"
                >
                  <Box color={hasAbsorbs ? 'good' : 'bad'}>
                    {absorbCount} / {absorbReq}
                  </Box>
                </LabeledList.Item>,
              );
            }
            if (resultType === 'ability' && dnaReq > 0) {
              rows.push(
                <LabeledList.Item
                  key={`${rowKeyBase}-dna`}
                  label="DNA Threshold"
                >
                  <Box color={hasDna ? 'good' : 'bad'}>
                    {dnaCount} / {dnaReq}
                  </Box>
                </LabeledList.Item>,
              );
            }
            if (resultType === 'ability' && chemicalCost > 0) {
              rows.push(
                <LabeledList.Item
                  key={`${rowKeyBase}-chem`}
                  label="Chemical Drain"
                >
                  {chemicalCost}
                </LabeledList.Item>,
              );
            }
            if (resultType === 'ability' && Boolean(recipe.req_human)) {
              rows.push(
                <LabeledList.Item
                  key={`${rowKeyBase}-human`}
                  label="Restriction"
                >
                  Requires humanoid form.
                </LabeledList.Item>,
              );
            }
            if (resultType === 'ability' && recipe.req_stat) {
              rows.push(
                <LabeledList.Item
                  key={`${rowKeyBase}-stat`}
                  label="Status Gate"
                >
                  {`Requires targets in the ${String(
                    recipe.req_stat,
                  ).toLowerCase()} state.`}
                </LabeledList.Item>,
              );
            }
            if (resultType === 'ability' && Boolean(recipe.disabled_by_fire)) {
              rows.push(
                <LabeledList.Item
                  key={`${rowKeyBase}-fire`}
                  label="Limitation"
                >
                  Disabled while on fire.
                </LabeledList.Item>,
              );
            }
            requirements.forEach((requirement, index) => {
              const required = Number(requirement.required) || 0;
              const available = Number(requirement.available) || 0;
              const met = available >= required;
              const label = requirement.name || describeRequirement(requirement);
              const descriptor = describeRequirement(requirement);
              rows.push(
                <LabeledList.Item
                  key={`${rowKeyBase}-req-${index}`}
                  label={label}
                >
                  <Stack align="baseline" justify="space-between">
                    <Stack.Item>
                      <Box color="label">{descriptor}</Box>
                    </Stack.Item>
                    <Stack.Item>
                      <Box bold color={met ? 'good' : 'bad'}>
                        {available} / {required}
                      </Box>
                    </Stack.Item>
                  </Stack>
                </LabeledList.Item>,
              );
            });

            const statusLines: ReactNode[] = [];
            if (owned) {
              statusLines.push(
                <Box key={`${rowKeyBase}-owned`} color="good">
                  Sequence integrated
                  {repeatable ? ' — additional syntheses available.' : '.'}
                </Box>,
              );
            } else if (repeatable) {
              statusLines.push(
                <Box key={`${rowKeyBase}-repeatable`} color="label">
                  Repeatable synthesis.
                </Box>,
              );
            }

            return (
              <Stack.Item key={recipe.id || abilityName} className="candystripe">
                <Stack vertical spacing={0.5}>
                  <Stack align="center" spacing={1}>
                    <Stack.Item grow>
                      <Box bold>{abilityName}</Box>
                    </Stack.Item>
                    {resultType === 'ability' ? (
                      <Stack.Item>
                        <Button
                          icon={owned && !repeatable ? 'check' : 'flask'}
                          color={owned && !repeatable ? 'good' : undefined}
                          content={integrateLabel}
                          disabled={!canCraftSecondary || (owned && !repeatable)}
                          tooltip={integrateTooltip}
                          onClick={() =>
                            act('craft', {
                              id: recipe.id,
                              slot: 'secondary',
                            })
                          }
                        />
                      </Stack.Item>
                    ) : (
                      <Stack.Item>
                        <Button
                          icon="flask"
                          content={repeatable ? 'Synthesize' : 'Distill'}
                          disabled={!requirementsMet}
                          tooltip={synthTooltip}
                          onClick={() => act('craft', { id: recipe.id })}
                        />
                      </Stack.Item>
                    )}
                    {resultType === 'ability' && !owned ? (
                      <Stack.Item>
                        <Button
                          icon="star"
                          content="Primary"
                          disabled={!canCraftPrimary}
                          tooltip={primaryTooltip}
                          onClick={() =>
                            act('craft', {
                              id: recipe.id,
                              slot: 'primary',
                            })
                          }
                        />
                      </Stack.Item>
                    ) : null}
                  </Stack>
                  {statusLines}
                  <Box>{description}</Box>
                  {!!helptext && <Box color="good">{helptext}</Box>}
                  {rows.length ? <LabeledList>{rows}</LabeledList> : null}
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
                </Stack>
                <Box>{effect.desc}</Box>
                {!!effect.helptext && (
                  <Box color="good">{effect.helptext}</Box>
                )}
                <LabeledList>
                  {effect.chemical_cost > 0 && (
                    <LabeledList.Item label="Chemical Drain">
                      {effect.chemical_cost}
                    </LabeledList.Item>
                  )}
                  {effect.req_absorbs > 0 && (
                    <LabeledList.Item label="Absorb Threshold">
                      {effect.req_absorbs}
                    </LabeledList.Item>
                  )}
                  {effect.req_dna > 0 && (
                    <LabeledList.Item label="DNA Threshold">
                      {effect.req_dna}
                    </LabeledList.Item>
                  )}
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
  const recombinaseCharges = Number(data.can_readapt) || 0;
  const absorbCount = Number(data.absorb_count) || 0;
  const dnaCount = Number(data.dna_count) || 0;
  const chemCharges = Number(data.chem_charges) || 0;
  const chemStorage = Number(data.chem_storage) || 0;
  const chemRechargeRate = Number(data.chem_recharge_rate) || 0;
  const chemRechargeSlowdown = Number(data.chem_recharge_slowdown) || 0;
  const signatureTotal = (data.signature_cells ?? []).reduce(
    (total, cell) => total + Number(cell.count || 0),
    0,
  );
  const biomaterialTotal = (data.biomaterials ?? []).reduce((total, category) => {
    const items = category.items ?? [];
    return (
      total +
      items.reduce((categoryTotal, item) => categoryTotal + Number(item.count || 0), 0)
    );
  }, 0);

  const rechargeText =
    chemRechargeSlowdown === 0
      ? `${chemRechargeRate}`
      : `${chemRechargeRate} (${chemRechargeSlowdown > 0 ? '-' : '+'}${Math.abs(
          chemRechargeSlowdown,
        )})`;

  const readaptDisabled = recombinaseCharges <= 0;
  const readaptTooltip = readaptDisabled
    ? 'Distill a recombinase charge to enable readaptation.'
    : 'Consume a recombinase charge to shed integrated adaptations.';

  return (
    <Section
      title="Matrix Resources"
      buttons={
        <Button
          icon="undo"
          color="good"
          disabled={readaptDisabled}
          tooltip={readaptTooltip}
          onClick={() => act('readapt')}
        >
          Readapt
        </Button>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Recombinase Charges">
          <Box bold color={readaptDisabled ? 'bad' : 'good'}>
            {recombinaseCharges}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Absorbed Hosts">
          {absorbCount}
        </LabeledList.Item>
        <LabeledList.Item label="DNA Profiles Archived">
          {dnaCount}
        </LabeledList.Item>
        <LabeledList.Item label="Signature Cells Archived">
          {signatureTotal}
        </LabeledList.Item>
        <LabeledList.Item label="Biomaterial Samples">
          {biomaterialTotal}
        </LabeledList.Item>
        <LabeledList.Item label="Chemical Reserves">
          {chemCharges} / {chemStorage}
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
      {slot?.chemical_cost ? (
        <LabeledList>
          <LabeledList.Item label="Chemical Drain">
            {slot.chemical_cost}
          </LabeledList.Item>
        </LabeledList>
      ) : null}
    </Stack>
  );
};

const BiomaterialSection = () => {
  const { data } = useBackend<GeneticMatrixData>();
  const biomaterials = data.biomaterials ?? [];

  return (
    <Section title="Biomaterial Stores" scrollable>
      {!biomaterials.length ? (
        <NoticeBox>No biomaterial harvested.</NoticeBox>
      ) : (
        <Stack vertical spacing={1}>
          {biomaterials.map((category) => (
            <Stack.Item key={category.id} className="candystripe">
              <Stack vertical spacing={0.5}>
                <Box bold>{category.name}</Box>
                {!category.items.length ? (
                  <Box italic color="label">
                    No samples catalogued.
                  </Box>
                ) : (
                  <Stack vertical spacing={0.5}>
                    {category.items.map((item) => (
                      <Stack.Item key={`${category.id}-${item.id}`}>
                        <Stack align="baseline" justify="space-between">
                          <Stack.Item grow>
                            <Box>{item.name}</Box>
                          </Stack.Item>
                          <Stack.Item>
                            <Box bold>{item.count}</Box>
                          </Stack.Item>
                        </Stack>
                        {item.description && (
                          <Box color="label">{item.description}</Box>
                        )}
                        {item.quality && (
                          <Box color="good">
                            Quality: {String(item.quality)}
                          </Box>
                        )}
                      </Stack.Item>
                    ))}
                  </Stack>
                )}
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

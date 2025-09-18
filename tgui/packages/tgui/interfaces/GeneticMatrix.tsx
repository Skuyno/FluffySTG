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
  biomaterials: BiomaterialCategory[];
  signature_cells: SignatureCell[];
};

export const GeneticMatrix = () => {
  const { data } = useBackend<GeneticMatrixData>();
  const [searchQuery, setSearchQuery] = useState('');

  const filteredAbilities = useMemo(() => {
    if (!searchQuery || searchQuery.length < 2) {
      return data.abilities;
    }

    const lowered = searchQuery.toLowerCase();
    return data.abilities.filter((ability) => {
      return (
        ability.name.toLowerCase().includes(lowered) ||
        ability.desc.toLowerCase().includes(lowered) ||
        ability.helptext.toLowerCase().includes(lowered)
      );
    });
  }, [data.abilities, searchQuery]);

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
          {data.abilities.length
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
  const { active_effects } = data;

  return (
    <Section fill scrollable title="Active Effects">
      {!active_effects.length ? (
        <NoticeBox>No evolutions are currently manifested.</NoticeBox>
      ) : (
        <Stack vertical spacing={1}>
          {active_effects.map((effect) => (
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

const BiomaterialSection = () => {
  const { data } = useBackend<GeneticMatrixData>();
  const { biomaterials } = data;

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
  const { signature_cells } = data;

  return (
    <Section title="Signature Cells" scrollable>
      {!signature_cells.length ? (
        <NoticeBox>No harvested signatures stored.</NoticeBox>
      ) : (
        <Stack vertical spacing={1}>
          {signature_cells.map((cell) => (
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
  const { synergy_tips } = data;

  return (
    <Section title="Synergy Guidance" scrollable>
      {!synergy_tips.length ? (
        <NoticeBox>
          Integrate additional genomes to unlock synergy insights.
        </NoticeBox>
      ) : (
        <Stack vertical spacing={1}>
          {synergy_tips.map((tip) => (
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
  const { incompatibilities } = data;

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
  const { presets, preset_limit } = data;
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
  const { primary, secondaries } = preset;

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
    if (secondaries?.length) {
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

import { useEffect, useMemo, useState } from 'react';
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

type GeneticPreset = {
  id: number;
  name: string;
  abilities: typePath[];
  ability_names: string[];
  ability_count: number;
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
                <SynergySection />
              </Stack.Item>
              <Stack.Item>
                <WarningsSection />
              </Stack.Item>
              <Stack.Item grow>
                <PresetSection />
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
}) => {
  const { act, data } = useBackend<GeneticMatrixData>();
  const { filteredAbilities, searchQuery, setSearchQuery } = props;
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
                          })
                        }
                      />
                    </Stack.Item>
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
      <Box italic color="label">
        {preset.ability_count > 0
          ? preset.ability_names.join(', ')
          : 'No sequences imprinted.'}
      </Box>
    </Stack>
  );
};

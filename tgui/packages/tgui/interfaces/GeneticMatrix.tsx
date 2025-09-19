import { useCallback, useEffect, useMemo, useState } from 'react';
import type { DragEvent } from 'react';
import {
  Box,
  Button,
  Divider,
  Icon,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';

const DRAG_DATA_KEY = 'application/x-genetic-matrix';

const asBoolean = (value: BooleanLike | undefined): boolean => {
  if (typeof value === 'boolean') {
    return value;
  }
  if (typeof value === 'number') {
    return value !== 0;
  }
  if (typeof value === 'string') {
    const lowered = value.toLowerCase();
    return lowered !== '0' && lowered !== 'false' && lowered !== '';
  }
  return Boolean(value);
};

const formatValue = (value: unknown, fallback = 'Unknown') => {
  if (value === undefined || value === null || value === '') {
    return fallback;
  }
  return String(value);
};

const formatCategoryLabel = (category?: string) => {
  if (!category) {
    return '';
  }
  const lowered = category.toLowerCase();
  switch (lowered) {
    case 'key_active':
      return 'Key Active';
    case 'passive':
      return 'Passive';
    case 'upgrade':
      return 'Upgrade';
    case 'ability':
      return 'Standard Ability';
    default:
      return lowered
        .split(/[_\s]+/)
        .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
        .join(' ');
  }
};

const getCategoryColor = (category?: string) => {
  if (!category) {
    return 'label';
  }
  switch (category.toLowerCase()) {
    case 'key_active':
      return 'good';
    case 'upgrade':
      return 'average';
    default:
      return 'label';
  }
};

const formatIdentifier = (value: string) => {
  const text = String(value);
  const parts = text.split('/');
  const last = parts[parts.length - 1] || text;
  return last.replace(/_/g, ' ');
};

export type ProfileEntry = {
  id: string;
  name: string;
  protected: BooleanLike;
  age: number | string | null;
  physique: string | null;
  voice: string | null;
  quirks: string[];
  quirk_count: number;
  skillchips: string[];
  skillchip_count: number;
  scar_count: number;
  id_icon: string | null;
};

export type ModuleEntry = {
  id: string;
  name: string;
  desc?: string | null;
  helptext?: string | null;
  chemical_cost?: number;
  dna_cost?: number;
  req_dna?: number;
  req_absorbs?: number;
  dna_required?: number;
  absorbs_required?: number;
  genetic_point_required?: number;
  button_icon_state: string | null;
  source?: string;
  slot?: number;
  slotType?: string;
  category?: string;
  tags?: string[];
  conflictTags?: string[];
  conflicts?: string[];
  path?: string;
};

export type BuildEntry = {
  id: string;
  name: string;
  profile: ProfileEntry | null;
  modules: (ModuleEntry | null)[];
};

export type AbilityEntry = ModuleEntry & {
  genetic_point_required?: number;
  absorbs_required?: number;
  dna_required?: number;
};

export type CytologyCellEntry = {
  id: string;
  name: string;
  desc: string | null;
};

export type RecipeEntry = {
  id: string;
  name: string;
};

export type RecipeMatch = {
  recipeId: string;
  name: string;
  module: ModuleEntry;
  alreadyUnlocked: BooleanLike;
  crafted?: BooleanLike;
};

export type StandardSkillEntry = AbilityEntry;

export type StandardSkillState = {
  can_readapt?: BooleanLike;
  genetic_points?: number;
  absorb_count?: number;
  dna_count?: number;
  owned?: string[];
};

type GeneticMatrixData = {
  maxAbilitySlots?: number;
  maxModuleSlots?: number;
  maxBuilds: number;
  builds: BuildEntry[];
  profiles: ProfileEntry[];
  abilityCatalog?: AbilityEntry[];
  moduleCatalog?: ModuleEntry[];
  cytologyCells?: CytologyCellEntry[];
  abilities?: AbilityEntry[];
  modules?: ModuleEntry[];
  recipes?: RecipeEntry[];
  composerMatches?: RecipeMatch[];
  standardSkills?: StandardSkillEntry[];
  standardSkillState?: StandardSkillState;
  canAddBuild: BooleanLike;
};

type DragPayload =
  | { type: 'profile'; id: string }
  | { type: 'profile-slot'; id: string; buildId: string }
  | { type: 'module'; id: string }
  | { type: 'module-slot'; id: string; buildId: string; slot: number }
  | { type: 'ability'; id: string }
  | { type: 'ability-slot'; id: string; buildId: string; slot: number };

export const GeneticMatrix = () => {
  const { act, data } = useBackend<GeneticMatrixData>();
  const {
    builds = [],
    profiles = [],
    moduleCatalog = [],
    abilityCatalog = [],
    cytologyCells = [],
    modules = [],
    abilities = [],
    recipes = [],
    composerMatches = [],
    standardSkills = [],
    standardSkillState = {},
    canAddBuild,
    maxModuleSlots,
    maxAbilitySlots = 0,
    maxBuilds = 0,
  } = data;

  const maxSlots = maxModuleSlots ?? maxAbilitySlots ?? 0;

  const [activeTab, setActiveTab] = useLocalState<
    'matrix' | 'cells' | 'abilities' | 'standard'
  >('genetic-matrix/tab', 'matrix');
  const [selectedBuildId, setSelectedBuildId] = useLocalState<string | undefined>(
    'genetic-matrix/selected-build',
    undefined,
  );

  useEffect(() => {
    if (!builds.length) {
      if (selectedBuildId !== undefined) {
        setSelectedBuildId(undefined);
      }
      return;
    }

    const stillExists = builds.some((build) => build.id === selectedBuildId);
    if (!selectedBuildId || !stillExists) {
      setSelectedBuildId(builds[0].id);
    }
  }, [builds, selectedBuildId, setSelectedBuildId]);

  const selectedBuild = useMemo(
    () => builds.find((build) => build.id === selectedBuildId),
    [builds, selectedBuildId],
  );

  return (
    <Window width={1024} height={720}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={activeTab === 'matrix'}
                onClick={() => setActiveTab('matrix')}
              >
                Matrix
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === 'cells'}
                onClick={() => setActiveTab('cells')}
              >
                DNA Storage
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === 'abilities'}
                onClick={() => setActiveTab('abilities')}
              >
                Abilities Storage
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === 'standard'}
                onClick={() => setActiveTab('standard')}
              >
                Standard Skills
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {activeTab === 'matrix' && (
              <MatrixTab
                act={act}
                builds={builds}
                selectedBuild={selectedBuild}
                selectedBuildId={selectedBuildId}
                onSelectBuild={setSelectedBuildId}
                moduleCatalog={moduleCatalog}
                abilityCatalog={abilityCatalog}
                cells={cytologyCells}
                composerMatches={composerMatches}
                profiles={profiles}
                maxModuleSlots={maxSlots}
                canAddBuild={asBoolean(canAddBuild)}
                maxBuilds={maxBuilds}
              />
            )}
            {activeTab === 'cells' && (
              <CellsTab
                profiles={profiles}
                cytologyCells={cytologyCells}
                recipes={recipes}
              />
            )}
            {activeTab === 'abilities' && (
              <AbilityStorageTab abilities={abilities} />
            )}
            {activeTab === 'standard' && (
              <StandardSkillsTab
                act={act}
                abilities={standardSkills}
                state={standardSkillState}
              />
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type MatrixTabProps = {
  act: (action: string, payload?: Record<string, unknown>) => void;
  builds: BuildEntry[];
  selectedBuild: BuildEntry | undefined;
  selectedBuildId: string | undefined;
  onSelectBuild: (id: string) => void;
  moduleCatalog: ModuleEntry[];
  abilityCatalog: AbilityEntry[];
  cells: CytologyCellEntry[];
  composerMatches: RecipeMatch[];
  profiles: ProfileEntry[];
  maxModuleSlots: number;
  canAddBuild: boolean;
  maxBuilds: number;
};

const MatrixTab = ({
  act,
  builds,
  selectedBuild,
  selectedBuildId,
  onSelectBuild,
  moduleCatalog,
  abilityCatalog,
  cells,
  composerMatches,
  profiles,
  maxModuleSlots,
  canAddBuild,
  maxBuilds,
}: MatrixTabProps) => {
  const [dragPayload, setDragPayload] = useState<DragPayload | null>(null);

  const beginDrag = useCallback(
    (event: DragEvent, payload: DragPayload) => {
      setDragPayload(payload);
      try {
        event.dataTransfer.setData(DRAG_DATA_KEY, JSON.stringify(payload));
      } catch {
        // ignore errors writing drag payload
      }
      event.dataTransfer.setData('text/plain', payload.id);
      event.dataTransfer.effectAllowed = 'move';
    },
    [],
  );

  const endDrag = useCallback(() => {
    setDragPayload(null);
  }, []);

  const parsePayload = useCallback(
    (event: DragEvent): DragPayload | null => {
      const raw = event.dataTransfer.getData(DRAG_DATA_KEY);
      if (raw) {
        try {
          return JSON.parse(raw) as DragPayload;
        } catch {
          // ignore malformed payloads
        }
      }
      return dragPayload;
    },
    [dragPayload],
  );

  const handleAssignProfile = useCallback(
    (buildId: string, profileId: string | null) => {
      if (!profileId) {
        act('clear_build_profile', { build: buildId });
        return;
      }
      act('set_build_profile', { build: buildId, profile: profileId });
    },
    [act],
  );

  const handleAssignModule = useCallback(
    (buildId: string, slot: number, moduleId: string | null) => {
      if (!moduleId) {
        act('clear_build_module', { build: buildId, slot });
        return;
      }
      act('set_build_module', { build: buildId, slot, module: moduleId });
    },
    [act],
  );

  const handleClearBuild = useCallback(
    (buildId: string) => {
      act('clear_build', { build: buildId });
    },
    [act],
  );

  const handleRenameBuild = useCallback(
    (buildId: string) => {
      act('rename_build', { build: buildId });
    },
    [act],
  );

  const handleDeleteBuild = useCallback(
    (buildId: string) => {
      act('delete_build', { build: buildId });
    },
    [act],
  );

  const handleCreateBuild = useCallback(() => {
    act('create_build');
  }, [act]);

  const assignedModuleIds = useMemo(() => {
    if (!selectedBuild) {
      return new Set<string>();
    }
    return new Set(
      selectedBuild.modules
        .filter((entry): entry is ModuleEntry => Boolean(entry))
        .map((entry) => entry.id),
    );
  }, [selectedBuild]);

  const handleProfileDrop = useCallback(
    (payload: DragPayload, targetBuild: BuildEntry) => {
      if (payload.type === 'profile') {
        handleAssignProfile(targetBuild.id, payload.id);
        return;
      }
      if (payload.type === 'profile-slot') {
        if (payload.buildId === targetBuild.id) {
          return;
        }
        handleAssignProfile(targetBuild.id, payload.id);
        act('clear_build_profile', { build: payload.buildId });
      }
    },
    [act, handleAssignProfile],
  );

  const handleModuleDrop = useCallback(
    (payload: DragPayload, targetBuild: BuildEntry, slot: number) => {
      if (payload.type === 'module' || payload.type === 'ability') {
        handleAssignModule(targetBuild.id, slot, payload.id);
        return;
      }
      if (payload.type === 'module-slot' || payload.type === 'ability-slot') {
        if (payload.buildId === targetBuild.id && payload.slot === slot) {
          return;
        }
        handleAssignModule(targetBuild.id, slot, payload.id);
        act('clear_build_module', { build: payload.buildId, slot: payload.slot });
      }
    },
    [act, handleAssignModule],
  );

  const handleProfileDoubleClick = useCallback(
    (profile: ProfileEntry) => {
      if (!selectedBuild) {
        return;
      }
      handleAssignProfile(selectedBuild.id, profile.id);
    },
    [handleAssignProfile, selectedBuild],
  );

  const handleModuleDoubleClick = useCallback(
    (module: ModuleEntry) => {
      if (!selectedBuild || maxModuleSlots <= 0) {
        return;
      }
      const openIndex =
        selectedBuild.modules.findIndex((entry) => !entry) + 1;
      const slot =
        openIndex > 0
          ? openIndex
          : selectedBuild.modules.length > 0
            ? 1
            : 0;
      if (slot > 0) {
        handleAssignModule(selectedBuild.id, slot, module.id);
      }
    },
    [handleAssignModule, maxModuleSlots, selectedBuild],
  );

  return (
    <Stack vertical fill gap={1}>
      <Stack.Item>
        <Stack fill gap={1}>
          <Stack.Item width="320px">
            <CraftComposer
              act={act}
              cells={cells}
              abilities={abilityCatalog}
              matches={composerMatches}
            />
          </Stack.Item>
          <Stack.Item grow>
            <ModuleList
              title="Result Catalog"
              modules={moduleCatalog}
              allowDrag
              onDragStart={(module, event) =>
                beginDrag(event, { type: 'module', id: module.id })
              }
              onDragEnd={endDrag}
              onDoubleClick={handleModuleDoubleClick}
              assignedModuleIds={assignedModuleIds}
              emptyMessage="We do not possess any modules to assign."
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        <Stack fill gap={1}>
          <Stack.Item width="280px">
            <BuildList
              builds={builds}
              selectedBuildId={selectedBuildId}
              onSelect={onSelectBuild}
              onCreate={handleCreateBuild}
              onRename={handleRenameBuild}
              onClear={handleClearBuild}
              onDelete={handleDeleteBuild}
              canAddBuild={canAddBuild}
              maxBuilds={maxBuilds}
            />
          </Stack.Item>
          <Stack.Item grow>
            <Stack vertical fill gap={1}>
              <Stack.Item>
                <BuildEditor
                  build={selectedBuild}
                  maxModuleSlots={maxModuleSlots}
                  dragPayload={dragPayload}
                  beginDrag={beginDrag}
                  endDrag={endDrag}
                  parsePayload={parsePayload}
                  onClearProfile={(buildId) => handleAssignProfile(buildId, null)}
                  onClearModule={(buildId, slot) =>
                    handleAssignModule(buildId, slot, null)
                  }
                  onClearBuild={handleClearBuild}
                  onProfileDropped={handleProfileDrop}
                  onModuleDropped={handleModuleDrop}
                />
              </Stack.Item>
              <Stack.Item grow>
                <ProfileCatalog
                  title="DNA Profiles"
                  profiles={profiles}
                  allowDrag
                  onDragStart={(profile, event) =>
                    beginDrag(event, { type: 'profile', id: profile.id })
                  }
                  onDragEnd={endDrag}
                  onDoubleClick={handleProfileDoubleClick}
                  highlightId={selectedBuild?.profile?.id}
                  emptyMessage="We have not stored any DNA samples yet."
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

type CraftComposerProps = {
  act: (action: string, payload?: Record<string, unknown>) => void;
  cells: CytologyCellEntry[];
  abilities: AbilityEntry[];
  matches: RecipeMatch[];
};

const CraftComposer = ({ act, cells, abilities, matches }: CraftComposerProps) => {
  const [cellSearch, setCellSearch] = useState('');
  const [abilitySearch, setAbilitySearch] = useState('');
  const [selectedCells, setSelectedCells] = useLocalState<string[]>(
    'genetic-matrix/composer/cells',
    [],
  );
  const [selectedAbilities, setSelectedAbilities] = useLocalState<string[]>(
    'genetic-matrix/composer/abilities',
    [],
  );

  useEffect(() => {
    setSelectedCells((previous) => {
      const filtered = previous.filter((id) =>
        cells.some((cell) => cell.id === id),
      );
      return filtered.length === previous.length ? previous : filtered;
    });
  }, [cells, setSelectedCells]);

  useEffect(() => {
    setSelectedAbilities((previous) => {
      const filtered = previous.filter((id) =>
        abilities.some((ability) => ability.id === id),
      );
      return filtered.length === previous.length ? previous : filtered;
    });
  }, [abilities, setSelectedAbilities]);

  const cellLookup = useMemo(() => {
    const lookup = new Map<string, CytologyCellEntry>();
    for (const cell of cells) {
      lookup.set(cell.id, cell);
    }
    return lookup;
  }, [cells]);

  const abilityLookup = useMemo(() => {
    const lookup = new Map<string, AbilityEntry>();
    for (const ability of abilities) {
      lookup.set(ability.id, ability);
    }
    return lookup;
  }, [abilities]);

  const filteredCells = useMemo(() => {
    const query = cellSearch.trim().toLowerCase();
    if (!query) {
      return cells;
    }
    return cells.filter((cell) => {
      const name = cell.name?.toLowerCase?.() ?? '';
      const desc = cell.desc?.toLowerCase?.() ?? '';
      return (
        name.includes(query) ||
        desc.includes(query) ||
        cell.id.toLowerCase().includes(query)
      );
    });
  }, [cells, cellSearch]);

  const filteredAbilities = useMemo(() => {
    const query = abilitySearch.trim().toLowerCase();
    if (!query) {
      return abilities;
    }
    return abilities.filter((ability) => {
      const name = ability.name?.toLowerCase?.() ?? '';
      const desc = ability.desc?.toLowerCase?.() ?? '';
      const help = ability.helptext?.toLowerCase?.() ?? '';
      const tags = ability.tags ? ability.tags.join(' ').toLowerCase() : '';
      return (
        name.includes(query) ||
        desc.includes(query) ||
        help.includes(query) ||
        tags.includes(query) ||
        ability.id.toLowerCase().includes(query)
      );
    });
  }, [abilities, abilitySearch]);

  const selectedCellEntries = useMemo(
    () =>
      selectedCells
        .map((id) => cellLookup.get(id))
        .filter((entry): entry is CytologyCellEntry => Boolean(entry)),
    [cellLookup, selectedCells],
  );

  const selectedAbilityEntries = useMemo(
    () =>
      selectedAbilities
        .map((id) => abilityLookup.get(id))
        .filter((entry): entry is AbilityEntry => Boolean(entry)),
    [abilityLookup, selectedAbilities],
  );

  const hasSelection =
    selectedCells.length > 0 || selectedAbilities.length > 0;

  const handleAddCell = useCallback(
    (id: string) => {
      setSelectedCells((previous) =>
        previous.includes(id) ? previous : [...previous, id],
      );
    },
    [setSelectedCells],
  );

  const handleRemoveCell = useCallback(
    (id: string) => {
      setSelectedCells((previous) => previous.filter((entry) => entry !== id));
    },
    [setSelectedCells],
  );

  const handleAddAbility = useCallback(
    (id: string) => {
      setSelectedAbilities((previous) =>
        previous.includes(id) ? previous : [...previous, id],
      );
    },
    [setSelectedAbilities],
  );

  const handleRemoveAbility = useCallback(
    (id: string) => {
      setSelectedAbilities((previous) =>
        previous.filter((entry) => entry !== id),
      );
    },
    [setSelectedAbilities],
  );

  const handleCheck = useCallback(() => {
    act('composer_check', {
      cells: JSON.stringify(selectedCells),
      abilities: JSON.stringify(selectedAbilities),
    });
  }, [act, selectedAbilities, selectedCells]);

  const handleCraft = useCallback(() => {
    act('composer_craft', {
      cells: JSON.stringify(selectedCells),
      abilities: JSON.stringify(selectedAbilities),
    });
  }, [act, selectedAbilities, selectedCells]);

  const handleClear = useCallback(() => {
    setSelectedCells([]);
    setSelectedAbilities([]);
    act('composer_check', {
      cells: JSON.stringify([]),
      abilities: JSON.stringify([]),
    });
  }, [act, setSelectedAbilities, setSelectedCells]);

  const craftDisabled = !hasSelection;

  return (
    <Section title="Craft Composer" fill scrollable>
      <Stack vertical gap={1}>
        <Stack.Item>
          <Box bold>Available Cells</Box>
          <Input
            fluid
            value={cellSearch}
            onChange={setCellSearch}
            placeholder="Search cells..."
          />
          <Stack
            vertical
            gap={0.5}
            style={{ maxHeight: '160px', overflowY: 'auto', marginTop: '4px' }}
          >
            {filteredCells.length === 0 ? (
              <NoticeBox>
                {cells.length === 0
                  ? 'We have not catalogued any cells yet.'
                  : 'No cells match that search.'}
              </NoticeBox>
            ) : (
              filteredCells.map((cell) => {
                const selected = selectedCells.includes(cell.id);
                return (
                  <Box key={cell.id} className="candystripe" p={0.5}>
                    <Stack justify="space-between" align="center" gap={0.5}>
                      <Stack.Item grow>
                        <Box bold>{cell.name}</Box>
                        {cell.desc && <Box color="label">{cell.desc}</Box>}
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          icon={selected ? 'check' : 'plus'}
                          tooltip={
                            selected
                              ? 'This cell is already in the composer.'
                              : 'Add this cell to the composer.'
                          }
                          disabled={selected}
                          onClick={() => handleAddCell(cell.id)}
                        />
                      </Stack.Item>
                    </Stack>
                  </Box>
                );
              })
            )}
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Box bold>Available Abilities</Box>
          <Input
            fluid
            value={abilitySearch}
            onChange={setAbilitySearch}
            placeholder="Search abilities..."
          />
          <Stack
            vertical
            gap={0.5}
            style={{ maxHeight: '200px', overflowY: 'auto', marginTop: '4px' }}
          >
            {filteredAbilities.length === 0 ? (
              <NoticeBox>
                {abilities.length === 0
                  ? 'We have not catalogued any standard abilities yet.'
                  : 'No abilities match that search.'}
              </NoticeBox>
            ) : (
              filteredAbilities.map((ability) => {
                const selected = selectedAbilities.includes(ability.id);
                return (
                  <Box key={ability.id} className="candystripe" p={0.5}>
                    <Stack align="start" gap={0.5}>
                      <Stack.Item grow>
                        <ModuleSummary module={ability} />
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          icon={selected ? 'check' : 'plus'}
                          tooltip={
                            selected
                              ? 'This ability is already in the composer.'
                              : 'Add this ability to the composer.'
                          }
                          disabled={selected}
                          onClick={() => handleAddAbility(ability.id)}
                        />
                      </Stack.Item>
                    </Stack>
                  </Box>
                );
              })
            )}
          </Stack>
        </Stack.Item>
        <Divider />
        <Stack.Item>
          <Stack gap={1} align="start">
            <Stack.Item grow>
              <Box bold>Selected Cells</Box>
              {selectedCellEntries.length === 0 ? (
                <Box color="label">No cells selected.</Box>
              ) : (
                <Stack vertical gap={0.5}>
                  {selectedCellEntries.map((cell) => (
                    <Box key={cell.id} className="candystripe" p={0.5}>
                      <Stack justify="space-between" align="center" gap={0.5}>
                        <Stack.Item grow>
                          <Box bold>{cell.name}</Box>
                          {cell.desc && <Box color="label">{cell.desc}</Box>}
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            icon="times"
                            tooltip="Remove this cell from the composer."
                            onClick={() => handleRemoveCell(cell.id)}
                          />
                        </Stack.Item>
                      </Stack>
                    </Box>
                  ))}
                </Stack>
              )}
            </Stack.Item>
            <Stack.Item grow>
              <Box bold>Selected Abilities</Box>
              {selectedAbilityEntries.length === 0 ? (
                <Box color="label">No abilities selected.</Box>
              ) : (
                <Stack vertical gap={0.5}>
                  {selectedAbilityEntries.map((ability) => (
                    <Box key={ability.id} className="candystripe" p={0.5}>
                      <Stack align="start" gap={0.5}>
                        <Stack.Item grow>
                          <ModuleSummary module={ability} />
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            icon="times"
                            tooltip="Remove this ability from the composer."
                            onClick={() => handleRemoveAbility(ability.id)}
                          />
                        </Stack.Item>
                      </Stack>
                    </Box>
                  ))}
                </Stack>
              )}
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack gap={1} wrap>
            <Stack.Item>
              <Button
                icon="search"
                tooltip="Preview genetic modules unlocked by this combination."
                disabled={!hasSelection}
                onClick={handleCheck}
              >
                Check Recipes
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="flask"
                color="good"
                tooltip="Weave new genetic modules using the selected ingredients."
                disabled={craftDisabled}
                onClick={handleCraft}
              >
                Craft
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="eraser"
                tooltip="Clear the composer and preview."
                disabled={!hasSelection && matches.length === 0}
                onClick={handleClear}
              >
                Clear
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Box bold>Recipe Matches</Box>
          {matches.length === 0 ? (
            <NoticeBox>
              Select cells and abilities, then check recipes to discover new
              modules.
            </NoticeBox>
          ) : (
            <Stack vertical gap={0.5}>
              {matches.map((match) => {
                const key = match.recipeId || match.module.id || match.name;
                const alreadyUnlocked = asBoolean(match.alreadyUnlocked);
                const crafted = asBoolean(match.crafted);
                const statusText = crafted
                  ? 'Crafted!'
                  : alreadyUnlocked
                    ? 'Already catalogued'
                    : 'Available to craft';
                const statusColor = crafted
                  ? 'good'
                  : alreadyUnlocked
                    ? 'average'
                    : 'good';
                return (
                  <Box key={key} className="candystripe" p={0.5}>
                    <Stack vertical gap={0.5}>
                      <Stack.Item>
                        <Stack justify="space-between" align="center" gap={0.5}>
                          <Stack.Item>
                            <Box bold>{match.name || match.module.name}</Box>
                          </Stack.Item>
                          <Stack.Item>
                            <Box color={statusColor}>{statusText}</Box>
                          </Stack.Item>
                        </Stack>
                      </Stack.Item>
                      <Stack.Item>
                        <ModuleSummary module={match.module} showSource={false} />
                      </Stack.Item>
                    </Stack>
                  </Box>
                );
              })}
            </Stack>
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

type BuildListProps = {
  builds: BuildEntry[];
  selectedBuildId: string | undefined;
  onSelect: (id: string) => void;
  onCreate: () => void;
  onRename: (id: string) => void;
  onClear: (id: string) => void;
  onDelete: (id: string) => void;
  canAddBuild: boolean;
  maxBuilds: number;
};

const BuildList = ({
  builds,
  selectedBuildId,
  onSelect,
  onCreate,
  onRename,
  onClear,
  onDelete,
  canAddBuild,
  maxBuilds,
}: BuildListProps) => (
  <Section
    title="Builds"
    fill
    scrollable
    buttons={
      <Stack align="center" gap={1}>
        <Stack.Item textColor="label">
          {builds.length}/{maxBuilds}
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="plus"
            tooltip="Create a new build"
            disabled={!canAddBuild}
            onClick={onCreate}
          >
            New
          </Button>
        </Stack.Item>
      </Stack>
    }
  >
    {builds.length === 0 ? (
      <NoticeBox>
        No builds configured yet. Create a build to start composing the matrix.
      </NoticeBox>
    ) : (
      <Stack vertical gap={1}>
        {builds.map((build) => {
          const isSelected = selectedBuildId === build.id;
          const hasAssignments =
            Boolean(build.profile) || build.modules.some((module) => module);
          return (
            <Box
              key={build.id}
              className="candystripe"
              p={1}
              style={{
                border: `1px solid ${
                  isSelected ? '#7fc' : 'rgba(255, 255, 255, 0.1)'
                }`,
                borderRadius: '6px',
                backgroundColor: isSelected
                  ? 'rgba(64, 160, 255, 0.08)'
                  : 'rgba(255,255,255,0.03)',
              }}
            >
              <Stack vertical gap={0.5}>
                <Stack.Item>
                  <Button
                    fluid
                    selected={isSelected}
                    onClick={() => onSelect(build.id)}
                  >
                    {build.name}
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Stack gap={1} wrap>
                    <Stack.Item>
                      <Button
                        icon="pen"
                        tooltip="Rename this build"
                        onClick={() => onRename(build.id)}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="eraser"
                        tooltip="Clear all assignments"
                        disabled={!hasAssignments}
                        onClick={() => onClear(build.id)}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="trash"
                        color="bad"
                        tooltip="Delete this build"
                        onClick={() => onDelete(build.id)}
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                {build.profile && (
                  <Stack.Item color="label">
                    Profile: {build.profile.name}
                  </Stack.Item>
                )}
              </Stack>
            </Box>
          );
        })}
      </Stack>
    )}
  </Section>
);

type BuildEditorProps = {
  build: BuildEntry | undefined;
  maxModuleSlots: number;
  dragPayload: DragPayload | null;
  beginDrag: (event: DragEvent, payload: DragPayload) => void;
  endDrag: () => void;
  parsePayload: (event: DragEvent) => DragPayload | null;
  onClearProfile: (buildId: string) => void;
  onClearModule: (buildId: string, slot: number) => void;
  onClearBuild: (buildId: string) => void;
  onProfileDropped: (payload: DragPayload, build: BuildEntry) => void;
  onModuleDropped: (payload: DragPayload, build: BuildEntry, slot: number) => void;
};

const BuildEditor = ({
  build,
  maxModuleSlots,
  dragPayload,
  beginDrag,
  endDrag,
  parsePayload,
  onClearProfile,
  onClearModule,
  onClearBuild,
  onProfileDropped,
  onModuleDropped,
}: BuildEditorProps) => {
  if (!build) {
    return (
      <Section title="Build Editor">
        <NoticeBox>
          Select or create a build to begin editing your genetic matrix.
        </NoticeBox>
      </Section>
    );
  }

  const profile = build.profile;
  const profileActive =
    dragPayload?.type === 'profile' || dragPayload?.type === 'profile-slot';

  return (
    <Section
      title={`Build Editor — ${build.name}`}
      buttons={
        <Button icon="eraser" tooltip="Clear all assignments" onClick={() => onClearBuild(build.id)}>
          Clear Build
        </Button>
      }
    >
      <Stack vertical gap={1}>
        <Stack.Item>
          <Stack align="center" gap={1}>
            <Stack.Item grow>
              <Box
                p={1}
                draggable={Boolean(profile)}
                onDragStart={(event) => {
                  if (!profile) {
                    return;
                  }
                  beginDrag(event, {
                    type: 'profile-slot',
                    id: profile.id,
                    buildId: build.id,
                  });
                }}
                onDragEnd={endDrag}
                onDragOver={(event) => {
                  const payload = parsePayload(event);
                  if (!payload) {
                    return;
                  }
                  if (payload.type === 'profile' || payload.type === 'profile-slot') {
                    event.preventDefault();
                    event.dataTransfer.dropEffect = 'move';
                  }
                }}
                onDrop={(event) => {
                  const payload = parsePayload(event);
                  if (!payload) {
                    return;
                  }
                  if (payload.type === 'profile' || payload.type === 'profile-slot') {
                    event.preventDefault();
                    onProfileDropped(payload, build);
                    endDrag();
                  }
                }}
                style={{
                  border: `1px dashed ${
                    profileActive ? '#7fc' : 'rgba(255, 255, 255, 0.2)'
                  }`,
                  borderRadius: '6px',
                  minHeight: '96px',
                  backgroundColor: profileActive
                    ? 'rgba(64, 160, 255, 0.1)'
                    : 'rgba(255,255,255,0.03)',
                }}
              >
                {profile ? (
                  <ProfileSummary profile={profile} />
                ) : (
                  <Box color="label">
                    Drag a DNA profile from the catalog to assign it to this build.
                  </Box>
                )}
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="times"
                disabled={!profile}
                tooltip="Remove the assigned profile"
                onClick={() => onClearProfile(build.id)}
                onDragOver={(event) => {
                  const payload = parsePayload(event);
                  if (
                    payload &&
                    payload.type === 'profile-slot' &&
                    payload.buildId === build.id
                  ) {
                    event.preventDefault();
                    event.dataTransfer.dropEffect = 'move';
                  }
                }}
                onDrop={(event) => {
                  const payload = parsePayload(event);
                  if (
                    payload &&
                    payload.type === 'profile-slot' &&
                    payload.buildId === build.id
                  ) {
                    event.preventDefault();
                    onClearProfile(build.id);
                    endDrag();
                  }
                }}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Divider />
        <Stack.Item>
          <Stack vertical gap={1}>
            {Array.from({ length: maxModuleSlots }, (_, index) => {
              const slot = index + 1;
              const moduleEntry = build.modules[index] ?? null;
              const highlight =
                dragPayload &&
                (dragPayload.type === 'module' ||
                  dragPayload.type === 'ability' ||
                  ((dragPayload.type === 'module-slot' ||
                    dragPayload.type === 'ability-slot') &&
                    (dragPayload.buildId !== build.id ||
                      dragPayload.slot !== slot)));
              return (
                <Stack align="center" gap={1} key={slot}>
                  <Stack.Item width="64px">
                    <Box textAlign="center" bold>
                      {slot === 1 ? 'Key Active' : `Module ${slot}`}
                    </Box>
                  </Stack.Item>
                  <Stack.Item grow>
                    <Box
                      p={1}
                      draggable={Boolean(moduleEntry)}
                      onDragStart={(event) => {
                        if (!moduleEntry) {
                          return;
                        }
                        beginDrag(event, {
                          type: 'module-slot',
                          id: moduleEntry.id,
                          buildId: build.id,
                          slot,
                        });
                      }}
                      onDragEnd={endDrag}
                      onDragOver={(event) => {
                        const payload = parsePayload(event);
                        if (!payload) {
                          return;
                        }
                        if (
                          payload.type === 'module' ||
                          payload.type === 'ability' ||
                          payload.type === 'module-slot' ||
                          payload.type === 'ability-slot'
                        ) {
                          event.preventDefault();
                          event.dataTransfer.dropEffect = 'move';
                        }
                      }}
                      onDrop={(event) => {
                        const payload = parsePayload(event);
                        if (!payload) {
                          return;
                        }
                        if (
                          payload.type === 'module' ||
                          payload.type === 'ability' ||
                          payload.type === 'module-slot' ||
                          payload.type === 'ability-slot'
                        ) {
                          event.preventDefault();
                          onModuleDropped(payload, build, slot);
                          endDrag();
                        }
                      }}
                      style={{
                        border: `1px dashed ${
                          highlight ? '#7fc' : 'rgba(255, 255, 255, 0.2)'
                        }`,
                        borderRadius: '6px',
                        minHeight: '72px',
                        backgroundColor: highlight
                          ? 'rgba(64, 160, 255, 0.1)'
                          : 'rgba(255,255,255,0.03)',
                      }}
                    >
                      {moduleEntry ? (
                        <ModuleSummary module={moduleEntry} showSource={false} />
                      ) : (
                        <Box color="label">Drop a module here.</Box>
                      )}
                    </Box>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="times"
                      disabled={!moduleEntry}
                      tooltip="Clear this slot"
                      onClick={() => onClearModule(build.id, slot)}
                    />
                  </Stack.Item>
                </Stack>
              );
            })}
            {maxModuleSlots === 0 && (
              <NoticeBox>
                This build has no module slots available.
              </NoticeBox>
            )}
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

type ProfileCatalogProps = {
  title: string;
  profiles: ProfileEntry[];
  allowDrag?: boolean;
  onDragStart?: (profile: ProfileEntry, event: DragEvent) => void;
  onDragEnd?: () => void;
  onDoubleClick?: (profile: ProfileEntry) => void;
  highlightId?: string;
  emptyMessage?: string;
};

const ProfileCatalog = ({
  title,
  profiles,
  allowDrag = false,
  onDragStart,
  onDragEnd,
  onDoubleClick,
  highlightId,
  emptyMessage,
}: ProfileCatalogProps) => (
  <Section title={title} fill scrollable>
    {profiles.length === 0 ? (
      <NoticeBox>{emptyMessage ?? 'No DNA profiles available.'}</NoticeBox>
    ) : (
      <Stack vertical gap={1}>
        {profiles.map((profile) => {
          const isSelected = highlightId === profile.id;
          return (
            <Box
              key={profile.id}
              className="candystripe"
              p={1}
              draggable={allowDrag}
              onDragStart={
                allowDrag
                  ? (event) => onDragStart?.(profile, event)
                  : undefined
              }
              onDragEnd={allowDrag ? onDragEnd : undefined}
              onDoubleClick={
                onDoubleClick ? () => onDoubleClick(profile) : undefined
              }
              style={{
                border: `1px solid ${
                  isSelected ? '#7fc' : 'rgba(255, 255, 255, 0.1)'
                }`,
                borderRadius: '6px',
                backgroundColor: isSelected
                  ? 'rgba(64, 160, 255, 0.08)'
                  : 'rgba(255,255,255,0.03)',
              }}
            >
              <ProfileSummary profile={profile} />
            </Box>
          );
        })}
      </Stack>
    )}
  </Section>
);

type ModuleListProps = {
  title: string;
  modules: ModuleEntry[];
  allowDrag?: boolean;
  onDragStart?: (module: ModuleEntry, event: DragEvent) => void;
  onDragEnd?: () => void;
  onDoubleClick?: (module: ModuleEntry) => void;
  assignedModuleIds?: Set<string>;
  emptyMessage?: string;
};

const ModuleList = ({
  title,
  modules,
  allowDrag = false,
  onDragStart,
  onDragEnd,
  onDoubleClick,
  assignedModuleIds,
  emptyMessage,
}: ModuleListProps) => (
  <Section title={title} fill scrollable>
    {modules.length === 0 ? (
      <NoticeBox>{emptyMessage ?? 'No modules available.'}</NoticeBox>
    ) : (
      <Stack vertical gap={1}>
        {modules.map((module) => {
          const isAssigned = assignedModuleIds?.has(module.id);
          return (
            <Box
              key={module.id}
              className="candystripe"
              p={1}
              draggable={allowDrag}
              onDragStart={
                allowDrag
                  ? (event) => onDragStart?.(module, event)
                  : undefined
              }
              onDragEnd={allowDrag ? onDragEnd : undefined}
              onDoubleClick={
                onDoubleClick ? () => onDoubleClick(module) : undefined
              }
              style={{
                border: `1px solid ${
                  isAssigned ? '#7fc' : 'rgba(255, 255, 255, 0.1)'
                }`,
                borderRadius: '6px',
                backgroundColor: isAssigned
                  ? 'rgba(64, 160, 255, 0.08)'
                  : 'rgba(255,255,255,0.03)',
              }}
            >
              <ModuleSummary module={module} />
            </Box>
          );
        })}
      </Stack>
    )}
  </Section>
);

const formatSource = (source?: string) => {
  if (!source) {
    return '';
  }
  const lowered = source.toLowerCase();
  if (lowered === 'innate') {
    return 'Innate';
  }
  if (lowered === 'purchased') {
    return 'Purchased';
  }
  return source;
};

type ProfileSummaryProps = {
  profile: ProfileEntry;
};

const ProfileSummary = ({ profile }: ProfileSummaryProps) => {
  const protectedProfile = asBoolean(profile.protected);
  const quirks = profile.quirks ?? [];
  const skillchips = profile.skillchips ?? [];
  return (
    <Stack vertical gap={0.5}>
      <Stack.Item>
        <Stack align="center" gap={0.5}>
          <Stack.Item>
            <Box bold>{profile.name}</Box>
          </Stack.Item>
          {protectedProfile && (
            <Stack.Item>
              <Icon name="shield-alt" color="good" />
            </Stack.Item>
          )}
        </Stack>
      </Stack.Item>
      <Stack.Item color="label">
        Age: {formatValue(profile.age)} | Physique: {formatValue(profile.physique)} |
        {' '}
        Voice: {formatValue(profile.voice)}
      </Stack.Item>
      {quirks.length > 0 && (
        <Stack.Item color="label">
          Quirks: {quirks.join(', ')}
        </Stack.Item>
      )}
      {skillchips.length > 0 && (
        <Stack.Item color="label">
          Skillchips: {skillchips.join(', ')}
        </Stack.Item>
      )}
      <Stack.Item color="label">Scars: {profile.scar_count}</Stack.Item>
    </Stack>
  );
};

type ModuleSummaryProps = {
  module: ModuleEntry;
  showSource?: boolean;
};

const ModuleSummary = ({ module, showSource = true }: ModuleSummaryProps) => {
  const sourceLabel = showSource ? formatSource(module.source) : '';
  const sourceColor = module.source?.toLowerCase() === 'innate' ? 'good' : 'average';
  const chemicalCost = module.chemical_cost ?? 0;
  const dnaCost = module.dna_cost ?? 0;
  const reqDna = module.req_dna ?? module.dna_required ?? 0;
  const reqAbsorbs = module.req_absorbs ?? module.absorbs_required ?? 0;
  const geneticPoints = module.genetic_point_required;
  const isKeyModule =
    module.slotType?.toLowerCase() === 'key' ||
    module.category?.toLowerCase() === 'key_active';
  const categoryLabel = formatCategoryLabel(module.category);
  const categoryColor = getCategoryColor(module.category);
  const tags = module.tags ?? [];
  const conflictTags = module.conflictTags ?? [];
  const conflicts = module.conflicts ?? [];
  return (
    <Stack vertical gap={0.5}>
      <Stack.Item>
        <Stack justify="space-between" align="center" gap={0.5}>
          <Stack.Item>
            <Box bold>{module.name}</Box>
          </Stack.Item>
          {sourceLabel && (
            <Stack.Item>
              <Box color={sourceColor}>{sourceLabel}</Box>
            </Stack.Item>
          )}
        </Stack>
      </Stack.Item>
      <Stack.Item color="label">
        Chems: {chemicalCost} | DNA: {dnaCost} | Required DNA: {reqDna} | Required
        Absorbs: {reqAbsorbs}
      </Stack.Item>
      {geneticPoints !== undefined && (
        <Stack.Item color="label">Genetic Points: {geneticPoints}</Stack.Item>
      )}
      {isKeyModule && <Stack.Item color="good">Key Active Module</Stack.Item>}
      {categoryLabel && (
        <Stack.Item color={categoryColor}>Category: {categoryLabel}</Stack.Item>
      )}
      {tags.length > 0 && (
        <Stack.Item color="label">Tags: {tags.join(', ')}</Stack.Item>
      )}
      {conflictTags.length > 0 && (
        <Stack.Item color="bad">
          Conflict Tags: {conflictTags.join(', ')}
        </Stack.Item>
      )}
      {conflicts.length > 0 && (
        <Stack.Item color="bad">
          Conflicts With: {conflicts.map((entry) => formatIdentifier(String(entry))).join(', ')}
        </Stack.Item>
      )}
      {module.desc && <Stack.Item>{module.desc}</Stack.Item>}
      {module.helptext && <Stack.Item color="good">{module.helptext}</Stack.Item>}
    </Stack>
  );
};

type CellsTabProps = {
  profiles: ProfileEntry[];
  cytologyCells: CytologyCellEntry[];
  recipes: RecipeEntry[];
};

const CellsTab = ({ profiles, cytologyCells, recipes }: CellsTabProps) => {
  const [search, setSearch] = useState('');
  const filteredCells = useMemo(() => {
    const query = search.trim().toLowerCase();
    if (!query) {
      return cytologyCells;
    }
    return cytologyCells.filter((cell) => {
      const name = cell.name?.toLowerCase?.() ?? '';
      const desc = cell.desc?.toLowerCase?.() ?? '';
      return (
        name.includes(query) || desc.includes(query) || cell.id.toLowerCase().includes(query)
      );
    });
  }, [cytologyCells, search]);

  return (
    <Stack vertical fill gap={1}>
      <Stack.Item>
        <ProfileCatalog
          title="DNA Profiles"
          profiles={profiles}
          allowDrag={false}
          emptyMessage="We have no stored DNA samples."
        />
      </Stack.Item>
      <Stack.Item>
        <Section
          title="Cytology Cells"
          fill
          scrollable
          buttons={
            <Input
              width="200px"
              value={search}
              onChange={setSearch}
              placeholder="Search cells..."
            />
          }
        >
          {filteredCells.length === 0 ? (
            <NoticeBox>
              {cytologyCells.length === 0
                ? 'No cytology cells catalogued.'
                : 'No cells match that search.'}
            </NoticeBox>
          ) : (
            <Stack vertical gap={1}>
              {filteredCells.map((cell) => (
                <Box key={cell.id} className="candystripe" p={1}>
                  <Box bold>{cell.name}</Box>
                  {cell.desc && <Box color="label">{cell.desc}</Box>}
                </Box>
              ))}
            </Stack>
          )}
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Known Recipes" fill scrollable>
          {recipes.length === 0 ? (
            <NoticeBox>No crafting recipes learned.</NoticeBox>
          ) : (
            <Stack vertical gap={1}>
              {recipes.map((recipe) => (
                <Box key={recipe.id} className="candystripe" p={1}>
                  {recipe.name}
                </Box>
              ))}
            </Stack>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

type AbilityStorageTabProps = {
  abilities: AbilityEntry[];
};

const AbilityStorageTab = ({ abilities }: AbilityStorageTabProps) => {
  const [search, setSearch] = useState('');
  const filteredAbilities = useMemo(() => {
    const query = search.trim().toLowerCase();
    if (!query) {
      return abilities;
    }
    return abilities.filter((ability) => {
      const name = ability.name?.toLowerCase?.() ?? '';
      const desc = ability.desc?.toLowerCase?.() ?? '';
      const help = ability.helptext?.toLowerCase?.() ?? '';
      const tags = ability.tags ? ability.tags.join(' ').toLowerCase() : '';
      return (
        name.includes(query) ||
        desc.includes(query) ||
        help.includes(query) ||
        tags.includes(query) ||
        ability.id.toLowerCase().includes(query)
      );
    });
  }, [abilities, search]);

  return (
    <Section
      title="Ability Storage"
      fill
      scrollable
      buttons={
        <Input
          width="200px"
          value={search}
          onChange={setSearch}
          placeholder="Search abilities..."
        />
      }
    >
      {filteredAbilities.length === 0 ? (
        <NoticeBox>
          {abilities.length === 0
            ? 'We have not catalogued any standard abilities.'
            : 'No abilities match that search.'}
        </NoticeBox>
      ) : (
        <Stack vertical gap={1}>
          {filteredAbilities.map((ability) => (
            <Box key={ability.id} className="candystripe" p={1}>
              <ModuleSummary module={ability} />
            </Box>
          ))}
        </Stack>
      )}
    </Section>
  );
};

type StandardSkillsTabProps = {
  act: (action: string, payload?: Record<string, unknown>) => void;
  abilities: StandardSkillEntry[];
  state?: StandardSkillState;
};

const StandardSkillsTab = ({
  act,
  abilities,
  state = {},
}: StandardSkillsTabProps) => {
  const [search, setSearch] = useState('');
  const ownedSet = useMemo(() => {
    const set = new Set<string>();
    const owned = state.owned ?? [];
    for (const entry of owned) {
      if (entry) {
        set.add(String(entry));
      }
    }
    return set;
  }, [state.owned]);
  const canReadapt = asBoolean(state.can_readapt);
  const rawReadapt = state.can_readapt;
  const readaptLabel =
    typeof rawReadapt === 'number' ? `Readapt(${rawReadapt})` : 'Readapt';
  const geneticPoints = state.genetic_points ?? 0;
  const absorbCount = state.absorb_count ?? 0;
  const dnaCount = state.dna_count ?? 0;

  const filteredAbilities = useMemo(() => {
    const query = search.trim().toLowerCase();
    if (!query) {
      return abilities;
    }
    return abilities.filter((ability) => {
      const name = ability.name?.toLowerCase?.() ?? '';
      const desc = ability.desc?.toLowerCase?.() ?? '';
      const help = ability.helptext?.toLowerCase?.() ?? '';
      return (
        name.includes(query) ||
        desc.includes(query) ||
        help.includes(query) ||
        ability.id.toLowerCase().includes(query)
      );
    });
  }, [abilities, search]);

  return (
    <Section
      title="Standard Skills"
      fill
      scrollable
      buttons={
        <Stack align="center" gap={1} wrap>
          <Stack.Item fontSize="16px">
            {geneticPoints} <Icon name="dna" color="#DD66DD" />
          </Stack.Item>
          <Stack.Item>
            <Box color="label">Absorbs: {absorbCount}</Box>
          </Stack.Item>
          <Stack.Item>
            <Box color="label">DNA: {dnaCount}</Box>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="undo"
              color="good"
              disabled={!canReadapt}
              tooltip={
                canReadapt
                  ? 'We readapt, un-evolving all evolved abilities and refunding our genetic points.'
                  : 'We cannot readapt until we absorb more DNA.'
              }
              onClick={() => act('standard_readapt')}
            >
              {readaptLabel}
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Input
              width="200px"
              value={search}
              onChange={setSearch}
              placeholder="Search abilities..."
            />
          </Stack.Item>
        </Stack>
      }
    >
      {filteredAbilities.length === 0 ? (
        <NoticeBox>
          {abilities.length === 0
            ? 'No abilities available to purchase. This is in error, contact the hive.'
            : 'No abilities match that search.'}
        </NoticeBox>
      ) : (
        <LabeledList>
          {filteredAbilities.map((ability) => {
            const owned = ability.id && ownedSet.has(ability.id);
            const geneticCost = ability.genetic_point_required ?? 0;
            const absorbRequired = ability.absorbs_required ?? ability.req_absorbs ?? 0;
            const dnaRequired = ability.dna_required ?? ability.req_dna ?? 0;
            const canPurchase =
              !owned &&
              Boolean(ability.path) &&
              geneticCost <= geneticPoints &&
              absorbRequired <= absorbCount &&
              dnaRequired <= dnaCount;
            return (
              <LabeledList.Item
                key={ability.id}
                className="candystripe"
                label={ability.name}
                buttons={
                  <Stack align="center" gap={1}>
                    <Stack.Item>{geneticCost}</Stack.Item>
                    <Stack.Item>
                      <Icon
                        name="dna"
                        color={owned ? '#DD66DD' : 'gray'}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="dna"
                        content="Evolve"
                        disabled={!canPurchase}
                        onClick={() =>
                          ability.path && act('standard_evolve', { path: ability.path })
                        }
                      />
                    </Stack.Item>
                  </Stack>
                }
              >
                {ability.desc && <Box>{ability.desc}</Box>}
                {ability.helptext && <Box color="good">{ability.helptext}</Box>}
                <Box color="label">
                  Absorbs required: {absorbRequired} | DNA required: {dnaRequired}
                </Box>
              </LabeledList.Item>
            );
          })}
        </LabeledList>
      )}
    </Section>
  );
};

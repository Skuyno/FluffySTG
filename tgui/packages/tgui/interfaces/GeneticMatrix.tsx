import { useCallback, useEffect, useMemo, useState } from 'react';
import type { DragEvent } from 'react';
import {
  Box,
  Button,
  Divider,
  Icon,
  Input,
  NoticeBox,
  Section,
  Stack,
  Tabs,
  Table,
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
  button_icon_state?: string | null;
  source?: string;
  slot?: number;
  slotType?: string;
  category?: string;
  tags?: string[];
  exclusiveTags?: string[];
  crafted?: BooleanLike;
};

export type BuildEntry = {
  id: string;
  name: string;
  profile: ProfileEntry | null;
  modules: (ModuleEntry | null)[];
};

export type CytologyCellEntry = {
  id: string;
  name: string;
  desc: string | null;
};

export type RecipeCellRequirement = {
  id: string;
  name: string;
  have: BooleanLike;
};

export type RecipeAbilityRequirement = {
  id: string;
  name: string;
  desc?: string | null;
  have: BooleanLike;
};

export type RecipeEntry = {
  id: string;
  name: string;
  desc?: string | null;
  module?: ModuleEntry | null;
  requiredCells: RecipeCellRequirement[];
  requiredAbilities: RecipeAbilityRequirement[];
  unlocked: BooleanLike;
  learned: BooleanLike;
  crafted: BooleanLike;
};

export type StandardAbilityEntry = {
  id: string;
  name: string;
  desc: string;
  helptext?: string | null;
  dnaCost: number;
  absorbsRequired: number;
  dnaRequired: number;
  chemicalCost: number;
  button_icon_state?: string | null;
  owned: BooleanLike;
  hasPoints: BooleanLike;
  hasAbsorbs: BooleanLike;
  hasDNA: BooleanLike;
};

type GeneticMatrixData = {
  maxModuleSlots?: number;
  maxBuilds: number;
  builds: BuildEntry[];
  profiles: ProfileEntry[];
  modules: ModuleEntry[];
  abilities: ModuleEntry[];
  cells: CytologyCellEntry[];
  recipes: RecipeEntry[];
  standardAbilities: StandardAbilityEntry[];
  geneticPoints: number;
  absorbs: number;
  dnaSamples: number;
  canReadapt: BooleanLike;
  canAddBuild: BooleanLike;
};

type DragPayload =
  | { type: 'profile'; id: string }
  | { type: 'profile-slot'; id: string; buildId: string }
  | { type: 'module'; id: string }
  | { type: 'module-slot'; id: string; buildId: string; slot: number }
  | { type: 'ability'; id: string }
  | { type: 'ability-slot'; id: string; buildId: string; slot: number }
  | { type: 'cell'; id: string }
  | { type: 'composer-cell'; id: string }
  | { type: 'composer-ability'; id: string };

export const GeneticMatrix = () => {
  const { act, data } = useBackend<GeneticMatrixData>();
  const {
    builds = [],
    profiles = [],
    modules = [],
    abilities = [],
    cells = [],
    recipes = [],
    standardAbilities = [],
    geneticPoints = 0,
    absorbs = 0,
    dnaSamples = 0,
    canReadapt,
    canAddBuild,
    maxModuleSlots = 0,
    maxBuilds = 0,
  } = data;

  const [activeTab, setActiveTab] = useLocalState<
    'matrix' | 'cells' | 'abilities' | 'skills'
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
    <Window width={1060} height={720}>
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
                Cells Storage
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === 'abilities'}
                onClick={() => setActiveTab('abilities')}
              >
                Abilities Storage
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === 'skills'}
                onClick={() => setActiveTab('skills')}
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
                profiles={profiles}
                modules={modules}
                abilities={abilities}
                cells={cells}
                recipes={recipes}
                selectedBuild={selectedBuild}
                selectedBuildId={selectedBuildId}
                onSelectBuild={setSelectedBuildId}
                maxModuleSlots={maxModuleSlots}
                canAddBuild={asBoolean(canAddBuild)}
                maxBuilds={maxBuilds}
              />
            )}
            {activeTab === 'cells' && (
              <CellsTab profiles={profiles} cells={cells} recipes={recipes} />
            )}
            {activeTab === 'abilities' && (
              <AbilityStorageTab abilities={abilities} />
            )}
            {activeTab === 'skills' && (
              <StandardSkillsTab
                act={act}
                abilities={standardAbilities}
                geneticPoints={geneticPoints}
                absorbs={absorbs}
                dnaSamples={dnaSamples}
                canReadapt={asBoolean(canReadapt)}
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
  profiles: ProfileEntry[];
  modules: ModuleEntry[];
  abilities: ModuleEntry[];
  cells: CytologyCellEntry[];
  recipes: RecipeEntry[];
  selectedBuild: BuildEntry | undefined;
  selectedBuildId: string | undefined;
  onSelectBuild: (id: string) => void;
  maxModuleSlots: number;
  canAddBuild: boolean;
  maxBuilds: number;
};

const MatrixTab = ({
  act,
  builds,
  profiles,
  modules,
  abilities,
  cells,
  recipes,
  selectedBuild,
  selectedBuildId,
  onSelectBuild,
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

  const [selectedCells, setSelectedCells] = useState<string[]>([]);
  const [selectedAbilities, setSelectedAbilities] = useState<string[]>([]);
  const [checkedRecipeIds, setCheckedRecipeIds] = useState<string[]>([]);
  const [selectedRecipeId, setSelectedRecipeId] = useState<string | null>(null);

  const matchingRecipes = useMemo(() => {
    if (!selectedCells.length && !selectedAbilities.length) {
      return [];
    }
    const cellSet = new Set(selectedCells);
    const abilitySet = new Set(selectedAbilities);
    return recipes.filter((recipe) => {
      if (recipe.requiredCells.length !== cellSet.size) {
        return false;
      }
      if (recipe.requiredAbilities.length !== abilitySet.size) {
        return false;
      }
      if (!recipe.requiredCells.every((req) => cellSet.has(req.id))) {
        return false;
      }
      if (!recipe.requiredAbilities.every((req) => abilitySet.has(req.id))) {
        return false;
      }
      return true;
    });
  }, [recipes, selectedCells, selectedAbilities]);

  useEffect(() => {
    setCheckedRecipeIds((previous) =>
      previous.filter((id) => matchingRecipes.some((recipe) => recipe.id === id)),
    );
    if (
      selectedRecipeId &&
      !matchingRecipes.some((recipe) => recipe.id === selectedRecipeId)
    ) {
      setSelectedRecipeId(null);
    }
  }, [matchingRecipes, selectedRecipeId]);

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
      if (payload.type === 'module') {
        handleAssignModule(targetBuild.id, slot, payload.id);
        return;
      }
      if (payload.type === 'module-slot') {
        if (payload.buildId === targetBuild.id && payload.slot === slot) {
          return;
        }
        handleAssignModule(targetBuild.id, slot, payload.id);
        act('clear_build_module', { build: payload.buildId, slot: payload.slot });
      }
    },
    [act, handleAssignModule],
  );

  const handleModuleDoubleClick = useCallback(
    (module: ModuleEntry) => {
      if (!selectedBuild || maxModuleSlots <= 0) {
        return;
      }
      const slotType = module.slotType?.toLowerCase();
      const isKeySlot = slotType === 'key' || slotType === 'key_active';
      const validSlots: number[] = [];
      for (let slot = 1; slot <= maxModuleSlots; slot += 1) {
        if (slot === 1) {
          if (isKeySlot) {
            validSlots.push(slot);
          }
        } else if (!isKeySlot) {
          validSlots.push(slot);
        }
      }
      if (!validSlots.length) {
        return;
      }
      const targetSlot =
        validSlots.find((slot) => !selectedBuild.modules?.[slot - 1]) ??
        validSlots[0];
      handleAssignModule(selectedBuild.id, targetSlot, module.id);
    },
    [handleAssignModule, maxModuleSlots, selectedBuild],
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

  const handleAddCell = useCallback((id: string) => {
    setSelectedCells((previous) =>
      previous.includes(id) ? previous : [...previous, id],
    );
    setCheckedRecipeIds([]);
    setSelectedRecipeId(null);
  }, []);

  const handleRemoveCell = useCallback((id: string) => {
    setSelectedCells((previous) => previous.filter((entry) => entry !== id));
    setCheckedRecipeIds([]);
    setSelectedRecipeId(null);
  }, []);

  const handleAddAbility = useCallback((id: string) => {
    setSelectedAbilities((previous) =>
      previous.includes(id) ? previous : [...previous, id],
    );
    setCheckedRecipeIds([]);
    setSelectedRecipeId(null);
  }, []);

  const handleRemoveAbility = useCallback((id: string) => {
    setSelectedAbilities((previous) => previous.filter((entry) => entry !== id));
    setCheckedRecipeIds([]);
    setSelectedRecipeId(null);
  }, []);

  const handleClearComposer = useCallback(() => {
    setSelectedCells([]);
    setSelectedAbilities([]);
    setCheckedRecipeIds([]);
    setSelectedRecipeId(null);
  }, []);

  const handleCheckRecipes = useCallback(() => {
    const ids = matchingRecipes.map((recipe) => recipe.id);
    setCheckedRecipeIds(ids);
    if (ids.length === 1) {
      setSelectedRecipeId(ids[0]);
    } else if (!ids.includes(selectedRecipeId ?? '')) {
      setSelectedRecipeId(null);
    }
  }, [matchingRecipes, selectedRecipeId]);

  const selectedRecipe = useMemo(
    () => recipes.find((recipe) => recipe.id === selectedRecipeId) ?? null,
    [recipes, selectedRecipeId],
  );

  const handleCraft = useCallback(() => {
    if (!selectedRecipe) {
      return;
    }
    act('craft_module', { recipe: selectedRecipe.id });
  }, [act, selectedRecipe]);

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

  const canCraft =
    !!selectedRecipe &&
    asBoolean(selectedRecipe.unlocked) &&
    !asBoolean(selectedRecipe.crafted);
  const craftDisabledReason = !selectedRecipe
    ? 'Select a recipe to synthesize.'
    : !asBoolean(selectedRecipe.unlocked)
      ? 'We lack the proper cells or abilities.'
      : asBoolean(selectedRecipe.crafted)
        ? 'This module already exists in our catalog.'
        : '';

  return (
    <Stack vertical fill gap={1}>
      <Stack.Item>
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
        <Stack fill gap={1}>
          <Stack.Item width="320px">
            <CraftComposer
              cells={cells}
              abilities={abilities}
              recipes={recipes}
              selectedCells={selectedCells}
              selectedAbilities={selectedAbilities}
              matchingRecipes={matchingRecipes}
              checkedRecipeIds={checkedRecipeIds}
              selectedRecipeId={selectedRecipeId}
              selectedRecipe={selectedRecipe}
              canCraft={canCraft}
              craftDisabledReason={craftDisabledReason}
              onAddCell={handleAddCell}
              onRemoveCell={handleRemoveCell}
              onAddAbility={handleAddAbility}
              onRemoveAbility={handleRemoveAbility}
              onClear={handleClearComposer}
              onCheck={handleCheckRecipes}
              onSelectRecipe={setSelectedRecipeId}
              onCraft={handleCraft}
              dragPayload={dragPayload}
              beginDrag={beginDrag}
              endDrag={endDrag}
              parsePayload={parsePayload}
            />
          </Stack.Item>
          <Stack.Item grow>
            <ModuleList
              title="Result Catalog"
              modules={modules}
              allowDrag
              onDragStart={(module, event) =>
                beginDrag(event, { type: 'module', id: module.id })
              }
              onDragEnd={endDrag}
              onDoubleClick={handleModuleDoubleClick}
              assignedModuleIds={assignedModuleIds}
              emptyMessage="We have not crafted any modules yet."
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
  cells: CytologyCellEntry[];
  abilities: ModuleEntry[];
  recipes: RecipeEntry[];
  selectedCells: string[];
  selectedAbilities: string[];
  matchingRecipes: RecipeEntry[];
  checkedRecipeIds: string[];
  selectedRecipeId: string | null;
  selectedRecipe: RecipeEntry | null;
  canCraft: boolean;
  craftDisabledReason: string;
  onAddCell: (id: string) => void;
  onRemoveCell: (id: string) => void;
  onAddAbility: (id: string) => void;
  onRemoveAbility: (id: string) => void;
  onClear: () => void;
  onCheck: () => void;
  onSelectRecipe: (id: string | null) => void;
  onCraft: () => void;
  dragPayload: DragPayload | null;
  beginDrag: (event: DragEvent, payload: DragPayload) => void;
  endDrag: () => void;
  parsePayload: (event: DragEvent) => DragPayload | null;
};

const CraftComposer = ({
  cells,
  abilities,
  recipes,
  selectedCells,
  selectedAbilities,
  matchingRecipes,
  checkedRecipeIds,
  selectedRecipeId,
  selectedRecipe,
  canCraft,
  craftDisabledReason,
  onAddCell,
  onRemoveCell,
  onAddAbility,
  onRemoveAbility,
  onClear,
  onCheck,
  onSelectRecipe,
  onCraft,
  dragPayload,
  beginDrag,
  endDrag,
  parsePayload,
}: CraftComposerProps) => {
  const [cellSearch, setCellSearch] = useState('');
  const [abilitySearch, setAbilitySearch] = useState('');

  const filteredCells = useMemo(() => {
    const query = cellSearch.toLowerCase();
    if (!query) {
      return cells;
    }
    return cells.filter((cell) =>
      cell.name.toLowerCase().includes(query) ||
      (cell.desc ? cell.desc.toLowerCase().includes(query) : false),
    );
  }, [cells, cellSearch]);

  const filteredAbilities = useMemo(() => {
    const query = abilitySearch.toLowerCase();
    if (!query) {
      return abilities;
    }
    return abilities.filter((ability) =>
      ability.name.toLowerCase().includes(query) ||
      (ability.desc ? ability.desc.toLowerCase().includes(query) : false),
    );
  }, [abilities, abilitySearch]);

  const cellDropActive = dragPayload?.type === 'cell';
  const abilityDropActive = dragPayload?.type === 'ability';

  return (
    <Stack vertical fill gap={1}>
      <Stack.Item>
        <Section title="Cells" fill>
          <Stack vertical gap={1}>
            <Stack.Item>
              <Input
                value={cellSearch}
                onInput={(_, value) => setCellSearch(value)}
                placeholder="Search cells..."
              />
            </Stack.Item>
            <Stack.Item>
              <Stack vertical gap={1} style={{ maxHeight: '180px', overflowY: 'auto' }}>
                {filteredCells.length === 0 ? (
                  <Box color="label">No matching cells.</Box>
                ) : (
                  filteredCells.map((cell) => (
                    <Box
                      key={cell.id}
                      className="candystripe"
                      p={1}
                      draggable
                      onDragStart={(event) =>
                        beginDrag(event, { type: 'cell', id: cell.id })
                      }
                      onDragEnd={endDrag}
                      onDoubleClick={() => onAddCell(cell.id)}
                    >
                      <Box bold>{cell.name}</Box>
                      {cell.desc && <Box color="label">{cell.desc}</Box>}
                    </Box>
                  ))
                )}
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Abilities" fill>
          <Stack vertical gap={1}>
            <Stack.Item>
              <Input
                value={abilitySearch}
                onInput={(_, value) => setAbilitySearch(value)}
                placeholder="Search abilities..."
              />
            </Stack.Item>
            <Stack.Item>
              <Stack vertical gap={1} style={{ maxHeight: '180px', overflowY: 'auto' }}>
                {filteredAbilities.length === 0 ? (
                  <Box color="label">No matching abilities.</Box>
                ) : (
                  filteredAbilities.map((ability) => (
                    <Box
                      key={ability.id}
                      className="candystripe"
                      p={1}
                      draggable
                      onDragStart={(event) =>
                        beginDrag(event, { type: 'ability', id: ability.id })
                      }
                      onDragEnd={endDrag}
                      onDoubleClick={() => onAddAbility(ability.id)}
                    >
                      <Box bold>{ability.name}</Box>
                      {ability.source && (
                        <Box color="average">Source: {formatSource(ability.source)}</Box>
                      )}
                      {ability.desc && <Box color="label">{ability.desc}</Box>}
                    </Box>
                  ))
                )}
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Selected Inputs" fill>
          <Stack vertical gap={1}>
            <Stack.Item>
              <Box
                p={1}
                style={{
                  border: `1px dashed ${
                    cellDropActive ? '#7fc' : 'rgba(255, 255, 255, 0.2)'
                  }`,
                  borderRadius: '6px',
                  minHeight: '64px',
                  backgroundColor: cellDropActive
                    ? 'rgba(64, 160, 255, 0.08)'
                    : 'rgba(255,255,255,0.03)',
                }}
                onDragOver={(event) => {
                  const payload = parsePayload(event);
                  if (payload?.type === 'cell') {
                    event.preventDefault();
                    event.dataTransfer.dropEffect = 'move';
                  }
                }}
                onDrop={(event) => {
                  const payload = parsePayload(event);
                  if (payload?.type === 'cell') {
                    event.preventDefault();
                    onAddCell(payload.id);
                    endDrag();
                  }
                }}
              >
                {selectedCells.length === 0 ? (
                  <Box color="label">Drop or select cells to include them.</Box>
                ) : (
                  <Stack wrap="wrap" gap={0.5}>
                    {selectedCells.map((id) => {
                      const cell = cells.find((entry) => entry.id === id);
                      return (
                        <Stack.Item key={id}>
                          <Box className="candystripe" p={0.5}>
                            <Stack align="center" gap={0.5}>
                              <Stack.Item grow>{cell?.name ?? id}</Stack.Item>
                              <Stack.Item>
                                <Button
                                  icon="times"
                                  compact
                                  tooltip="Remove cell"
                                  onClick={() => onRemoveCell(id)}
                                />
                              </Stack.Item>
                            </Stack>
                          </Box>
                        </Stack.Item>
                      );
                    })}
                  </Stack>
                )}
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Box
                p={1}
                style={{
                  border: `1px dashed ${
                    abilityDropActive ? '#7fc' : 'rgba(255, 255, 255, 0.2)'
                  }`,
                  borderRadius: '6px',
                  minHeight: '64px',
                  backgroundColor: abilityDropActive
                    ? 'rgba(64, 160, 255, 0.08)'
                    : 'rgba(255,255,255,0.03)',
                }}
                onDragOver={(event) => {
                  const payload = parsePayload(event);
                  if (payload?.type === 'ability') {
                    event.preventDefault();
                    event.dataTransfer.dropEffect = 'move';
                  }
                }}
                onDrop={(event) => {
                  const payload = parsePayload(event);
                  if (payload?.type === 'ability') {
                    event.preventDefault();
                    onAddAbility(payload.id);
                    endDrag();
                  }
                }}
              >
                {selectedAbilities.length === 0 ? (
                  <Box color="label">Drop or select abilities to include them.</Box>
                ) : (
                  <Stack wrap="wrap" gap={0.5}>
                    {selectedAbilities.map((id) => {
                      const ability = abilities.find((entry) => entry.id === id);
                      return (
                        <Stack.Item key={id}>
                          <Box className="candystripe" p={0.5}>
                            <Stack align="center" gap={0.5}>
                              <Stack.Item grow>{ability?.name ?? id}</Stack.Item>
                              <Stack.Item>
                                <Button
                                  icon="times"
                                  compact
                                  tooltip="Remove ability"
                                  onClick={() => onRemoveAbility(id)}
                                />
                              </Stack.Item>
                            </Stack>
                          </Box>
                        </Stack.Item>
                      );
                    })}
                  </Stack>
                )}
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Stack justify="space-between">
                <Stack.Item>
                  <Button icon="redo" onClick={onClear}>
                    Clear
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="search"
                    onClick={onCheck}
                    disabled={!selectedCells.length && !selectedAbilities.length}
                  >
                    Check Recipes
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="flask"
                    color="good"
                    disabled={!canCraft}
                    tooltip={craftDisabledReason}
                    onClick={onCraft}
                  >
                    Craft
                  </Button>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section title="Recipe Results" fill scrollable>
          {checkedRecipeIds.length === 0 ? (
            <NoticeBox>
              Select inputs and press Check Recipes to preview potential modules.
            </NoticeBox>
          ) : matchingRecipes.length === 0 ? (
            <NoticeBox>No recipes match this combination.</NoticeBox>
          ) : (
            <Stack vertical gap={1}>
              {matchingRecipes.map((recipe) => {
                const module = recipe.module;
                const learned = asBoolean(recipe.learned);
                const unlocked = asBoolean(recipe.unlocked);
                const crafted = asBoolean(recipe.crafted);
                const isSelected = selectedRecipeId === recipe.id;
                return (
                  <Box
                    key={recipe.id}
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
                      cursor: 'pointer',
                    }}
                    onClick={() => onSelectRecipe(recipe.id)}
                  >
                    <Stack vertical gap={0.5}>
                      <Stack.Item>
                        <Stack justify="space-between" align="center">
                          <Stack.Item>
                            <Box bold>{module?.name ?? recipe.name}</Box>
                          </Stack.Item>
                          <Stack.Item>
                            {crafted ? (
                              <Box color="average">
                                <Icon name="check" mr={0.5} /> Synthesized
                              </Box>
                            ) : unlocked ? (
                              <Box color="good">
                                <Icon name="check" mr={0.5} /> Ready
                              </Box>
                            ) : learned ? (
                              <Box color="average">
                                <Icon name="hourglass-half" mr={0.5} /> Missing
                              </Box>
                            ) : (
                              <Box color="bad">
                                <Icon name="question" mr={0.5} /> Unknown
                              </Box>
                            )}
                          </Stack.Item>
                        </Stack>
                      </Stack.Item>
                      {module?.category && (
                        <Stack.Item>
                          <Box color="average">
                            Category: {formatCategory(module.category)}
                          </Box>
                        </Stack.Item>
                      )}
                      {module?.tags && module.tags.length > 0 && (
                        <Stack.Item>
                          <Box color="average">Tags: {module.tags.join(', ')}</Box>
                        </Stack.Item>
                      )}
                      {module?.exclusiveTags && module.exclusiveTags.length > 0 && (
                        <Stack.Item>
                          <Box color="bad">
                            Exclusive: {module.exclusiveTags.join(', ')}
                          </Box>
                        </Stack.Item>
                      )}
                      {module?.desc && (
                        <Stack.Item>
                          <Box color="label">{module.desc}</Box>
                        </Stack.Item>
                      )}
                      {module?.helptext && (
                        <Stack.Item>
                          <Box color="good">{module.helptext}</Box>
                        </Stack.Item>
                      )}
                      {recipe.desc && (
                        <Stack.Item>
                          <Box color="label">{recipe.desc}</Box>
                        </Stack.Item>
                      )}
                      <Stack.Item>
                        <Box color="label">
                          Cells: {' '}
                          {recipe.requiredCells
                            .map((req) => req.name)
                            .join(', ') || 'None'}
                        </Box>
                      </Stack.Item>
                      <Stack.Item>
                        <Box color="label">
                          Abilities: {' '}
                          {recipe.requiredAbilities
                            .map((req) => req.name)
                            .join(', ') || 'None'}
                        </Box>
                      </Stack.Item>
                    </Stack>
                  </Box>
                );
              })}
            </Stack>
          )}
        </Section>
      </Stack.Item>
    </Stack>
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
    buttons={
      <Button
        icon="plus"
        disabled={!canAddBuild}
        tooltip={canAddBuild ? undefined : 'Bio-incubator build slots full.'}
        onClick={onCreate}
      >
        New Build
      </Button>
    }
    fill
    scrollable
  >
    {builds.length === 0 ? (
      <NoticeBox>No builds configured.</NoticeBox>
    ) : (
      <Stack vertical gap={0.5}>
        {builds.map((build) => (
          <Box
            key={build.id}
            className="candystripe"
            p={1}
            style={{
              border: `1px solid ${
                build.id === selectedBuildId ? '#7fc' : 'rgba(255,255,255,0.1)'
              }`,
              borderRadius: '6px',
              cursor: 'pointer',
            }}
            onClick={() => onSelect(build.id)}
          >
            <Stack justify="space-between" align="center" gap={1}>
              <Stack.Item grow>
                <Box bold>{build.name}</Box>
              </Stack.Item>
              <Stack.Item>
                <Stack gap={0.5}>
                  <Stack.Item>
                    <Button icon="edit" compact tooltip="Rename" onClick={() => onRename(build.id)} />
                  </Stack.Item>
                  <Stack.Item>
                    <Button icon="eraser" compact tooltip="Clear" onClick={() => onClear(build.id)} />
                  </Stack.Item>
                  <Stack.Item>
                    <Button icon="trash" compact tooltip="Delete" onClick={() => onDelete(build.id)} />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Box>
        ))}
      </Stack>
    )}
    <Box color="label" mt={1}>
      Slots used: {builds.length}/{maxBuilds}
    </Box>
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
        <NoticeBox>Select or create a build to begin editing your genetic matrix.</NoticeBox>
      </Section>
    );
  }

  const profile = build.profile;
  const profileActive =
    dragPayload?.type === 'profile' || dragPayload?.type === 'profile-slot';

  const exclusiveCounts = useMemo(() => {
    const counts = new Map<string, number>();
    build.modules.forEach((entry) => {
      if (!entry?.exclusiveTags) {
        return;
      }
      entry.exclusiveTags.forEach((tag) => {
        const key = tag.toLowerCase();
        counts.set(key, (counts.get(key) ?? 0) + 1);
      });
    });
    return counts;
  }, [build.modules]);

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
                    ? 'rgba(64, 160, 255, 0.08)'
                    : 'rgba(255,255,255,0.03)',
                }}
              >
                {profile ? (
                  <ProfileSummary profile={profile} />
                ) : (
                  <Box color="label">
                    Drag a DNA profile from the list to assign it to this build.
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
                  (dragPayload.type === 'module-slot' &&
                    (dragPayload.buildId !== build.id || dragPayload.slot !== slot)));
              const conflictTags =
                moduleEntry?.exclusiveTags?.filter(
                  (tag) => (exclusiveCounts.get(tag.toLowerCase()) ?? 0) > 1,
                ) ?? [];
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
                          payload.type === 'module-slot'
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
                          payload.type === 'module-slot'
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
                          ? 'rgba(64, 160, 255, 0.08)'
                          : 'rgba(255,255,255,0.03)',
                      }}
                    >
                      {moduleEntry ? (
                        <ModuleSummary
                          module={moduleEntry}
                          showSource={false}
                          conflictTags={conflictTags}
                        />
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
              <NoticeBox>This build has no module slots available.</NoticeBox>
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

type ProfileSummaryProps = {
  profile: ProfileEntry;
};

const ProfileSummary = ({ profile }: ProfileSummaryProps) => {
  const isProtected = asBoolean(profile.protected);
  const basicDetails = [
    profile.age !== null && profile.age !== undefined
      ? `Age: ${formatValue(profile.age)}`
      : null,
    profile.physique ? `Physique: ${profile.physique}` : null,
    profile.voice ? `Voice: ${profile.voice}` : null,
  ].filter((entry): entry is string => Boolean(entry));

  return (
    <Stack vertical gap={0.25}>
      <Stack.Item>
        <Stack justify="space-between" align="center">
          <Stack.Item>
            <Box bold>{profile.name}</Box>
          </Stack.Item>
          {isProtected && (
            <Stack.Item>
              <Box color="average">
                <Icon name="shield-alt" mr={0.5} /> Protected
              </Box>
            </Stack.Item>
          )}
        </Stack>
      </Stack.Item>
      {basicDetails.length > 0 && (
        <Stack.Item color="label">{basicDetails.join(' • ')}</Stack.Item>
      )}
      {profile.quirks.length > 0 && (
        <Stack.Item color="average">
          Quirks: {profile.quirks.join(', ')}
        </Stack.Item>
      )}
      {profile.skillchips.length > 0 && (
        <Stack.Item color="average">
          Skillchips: {profile.skillchips.join(', ')}
        </Stack.Item>
      )}
      {profile.scar_count > 0 && (
        <Stack.Item color="label">
          Scars recorded: {profile.scar_count}
        </Stack.Item>
      )}
    </Stack>
  );
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
  allowDrag: boolean;
  onDragStart?: (module: ModuleEntry, event: DragEvent) => void;
  onDragEnd?: () => void;
  onDoubleClick?: (module: ModuleEntry) => void;
  assignedModuleIds?: Set<string>;
  emptyMessage?: string;
};

const ModuleList = ({
  title,
  modules,
  allowDrag,
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
                allowDrag ? (event) => onDragStart?.(module, event) : undefined
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
                  ? 'rgba(64, 160, 255, 0.06)'
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

type ModuleSummaryProps = {
  module: ModuleEntry;
  showSource?: boolean;
  conflictTags?: string[];
};

const ModuleSummary = ({ module, showSource = true, conflictTags = [] }: ModuleSummaryProps) => {
  const sourceLabel = showSource ? formatSource(module.source) : '';
  const sourceColor = module.source?.toLowerCase() === 'innate' ? 'good' : 'average';
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
      {module.category && (
        <Stack.Item color="average">Category: {formatCategory(module.category)}</Stack.Item>
      )}
      {module.tags && module.tags.length > 0 && (
        <Stack.Item color="average">Tags: {module.tags.join(', ')}</Stack.Item>
      )}
      {module.exclusiveTags && module.exclusiveTags.length > 0 && (
        <Stack.Item color="bad">Exclusive: {module.exclusiveTags.join(', ')}</Stack.Item>
      )}
      {conflictTags.length > 0 && (
        <Stack.Item color="bad">
          Conflict with: {conflictTags.join(', ')}
        </Stack.Item>
      )}
      {module.desc && <Stack.Item>{module.desc}</Stack.Item>}
      {module.helptext && <Stack.Item color="good">{module.helptext}</Stack.Item>}
      {(module.chemical_cost !== undefined ||
        module.dna_cost !== undefined ||
        module.req_dna !== undefined ||
        module.req_absorbs !== undefined) && (
        <Stack.Item color="label">
          {module.chemical_cost !== undefined && `Chems: ${module.chemical_cost} `}
          {module.dna_cost !== undefined && `DNA Cost: ${module.dna_cost} `}
          {module.req_dna !== undefined && `Required DNA: ${module.req_dna} `}
          {module.req_absorbs !== undefined && `Required Absorbs: ${module.req_absorbs}`}
        </Stack.Item>
      )}
    </Stack>
  );
};

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
  if (lowered === 'crafted') {
    return 'Crafted';
  }
  return source;
};

const formatCategory = (category?: string) => {
  if (!category) {
    return '';
  }
  const lowered = category.toLowerCase();
  if (lowered === 'key_active') {
    return 'Key Active';
  }
  if (lowered === 'passive') {
    return 'Passive';
  }
  if (lowered === 'upgrade') {
    return 'Upgrade';
  }
  return category;
};

type CellsTabProps = {
  profiles: ProfileEntry[];
  cells: CytologyCellEntry[];
  recipes: RecipeEntry[];
};

const CellsTab = ({ profiles, cells, recipes }: CellsTabProps) => {
  const [cellSearch, setCellSearch] = useState('');

  const filteredCells = useMemo(() => {
    const query = cellSearch.toLowerCase();
    if (!query) {
      return cells;
    }
    return cells.filter((cell) =>
      cell.name.toLowerCase().includes(query) ||
      (cell.desc ? cell.desc.toLowerCase().includes(query) : false),
    );
  }, [cells, cellSearch]);

  return (
    <Stack vertical fill gap={1}>
      <Stack.Item>
        <ProfileCatalog
          title="DNA Profiles"
          profiles={profiles}
          allowDrag={false}
          emptyMessage="No stored DNA profiles."
        />
      </Stack.Item>
      <Stack.Item>
        <Section title="Cytology Cells" fill scrollable>
          <Stack vertical gap={1}>
            <Stack.Item>
              <Input
                value={cellSearch}
                onInput={(_, value) => setCellSearch(value)}
                placeholder="Search cytology cells..."
              />
            </Stack.Item>
            <Stack.Item>
              {filteredCells.length === 0 ? (
                <NoticeBox>No cells catalogued.</NoticeBox>
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
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section title="Known Recipes" fill scrollable>
          {recipes.length === 0 ? (
            <NoticeBox>No genetic recipes known.</NoticeBox>
          ) : (
            <Stack vertical gap={1}>
              {recipes.map((recipe) => (
                <Box key={recipe.id} className="candystripe" p={1}>
                  <Stack justify="space-between" align="center">
                    <Stack.Item>
                      <Box bold>{recipe.module?.name ?? recipe.name}</Box>
                    </Stack.Item>
                    <Stack.Item>
                      {asBoolean(recipe.crafted) ? (
                        <Box color="average">
                          <Icon name="check" mr={0.5} /> Synthesized
                        </Box>
                      ) : asBoolean(recipe.unlocked) ? (
                        <Box color="good">
                          <Icon name="check" mr={0.5} /> Ready
                        </Box>
                      ) : asBoolean(recipe.learned) ? (
                        <Box color="average">
                          <Icon name="hourglass-half" mr={0.5} /> Missing Inputs
                        </Box>
                      ) : (
                        <Box color="bad">
                          <Icon name="question" mr={0.5} /> Locked
                        </Box>
                      )}
                    </Stack.Item>
                  </Stack>
                  <Box color="label">
                    Cells: {recipe.requiredCells.map((req) => req.name).join(', ') || 'None'}
                  </Box>
                  <Box color="label">
                    Abilities: {recipe.requiredAbilities.map((req) => req.name).join(', ') || 'None'}
                  </Box>
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
  abilities: ModuleEntry[];
};

const AbilityStorageTab = ({ abilities }: AbilityStorageTabProps) => (
  <Section title="Abilities Storage" fill scrollable>
    {abilities.length === 0 ? (
      <NoticeBox>No abilities catalogued.</NoticeBox>
    ) : (
      <Stack vertical gap={1}>
        {abilities.map((ability) => (
          <Box key={ability.id} className="candystripe" p={1}>
            <ModuleSummary module={ability} />
          </Box>
        ))}
      </Stack>
    )}
  </Section>
);

type StandardSkillsTabProps = {
  act: (action: string, payload?: Record<string, unknown>) => void;
  abilities: StandardAbilityEntry[];
  geneticPoints: number;
  absorbs: number;
  dnaSamples: number;
  canReadapt: boolean;
};

const StandardSkillsTab = ({
  act,
  abilities,
  geneticPoints,
  absorbs,
  dnaSamples,
  canReadapt,
}: StandardSkillsTabProps) => (
  <Stack vertical fill gap={1}>
    <Stack.Item>
      <Section title="Genetic Resources">
        <Table>
          <Table.Row>
            <Table.Cell>Genetic Points</Table.Cell>
            <Table.Cell>{geneticPoints}</Table.Cell>
          </Table.Row>
          <Table.Row>
            <Table.Cell>Absorbed Genomes</Table.Cell>
            <Table.Cell>{absorbs}</Table.Cell>
          </Table.Row>
          <Table.Row>
            <Table.Cell>Stored DNA Samples</Table.Cell>
            <Table.Cell>{dnaSamples}</Table.Cell>
          </Table.Row>
        </Table>
        <Button
          icon="undo"
          disabled={!canReadapt}
          tooltip={canReadapt ? undefined : 'No readapt charges available.'}
          onClick={() => act('readapt_standard')}
        >
          Readapt
        </Button>
      </Section>
    </Stack.Item>
    <Stack.Item grow>
      <Section title="Standard Abilities" fill scrollable>
        {abilities.length === 0 ? (
          <NoticeBox>No abilities available for purchase.</NoticeBox>
        ) : (
          <Table>
            <Table.Row header>
              <Table.Cell>Ability</Table.Cell>
              <Table.Cell>DNA Cost</Table.Cell>
              <Table.Cell>DNA Required</Table.Cell>
              <Table.Cell>Absorbs Required</Table.Cell>
              <Table.Cell>Chemical Cost</Table.Cell>
              <Table.Cell textAlign="right">Action</Table.Cell>
            </Table.Row>
            {abilities.map((ability) => {
              const owned = asBoolean(ability.owned);
              const hasPoints = asBoolean(ability.hasPoints);
              const hasAbsorbs = asBoolean(ability.hasAbsorbs);
              const hasDNA = asBoolean(ability.hasDNA);
              const canPurchase = !owned && hasPoints && hasAbsorbs && hasDNA;
              const disabledReason = owned
                ? 'Already owned.'
                : !hasPoints
                  ? 'Not enough genetic points.'
                  : !hasAbsorbs
                    ? 'Insufficient absorbed genomes.'
                    : !hasDNA
                      ? 'Insufficient DNA samples.'
                      : '';
              return (
                <Table.Row key={ability.id} className="candystripe">
                  <Table.Cell>
                    <Stack vertical gap={0.5}>
                      <Stack.Item>
                        <Box bold>{ability.name}</Box>
                      </Stack.Item>
                      <Stack.Item>{ability.desc}</Stack.Item>
                      {ability.helptext && (
                        <Stack.Item color="good">{ability.helptext}</Stack.Item>
                      )}
                    </Stack>
                  </Table.Cell>
                  <Table.Cell>{ability.dnaCost}</Table.Cell>
                  <Table.Cell>{ability.dnaRequired}</Table.Cell>
                  <Table.Cell>{ability.absorbsRequired}</Table.Cell>
                  <Table.Cell>{ability.chemicalCost}</Table.Cell>
                  <Table.Cell textAlign="right">
                    <Button
                      icon={owned ? 'check' : 'plus'}
                      color={owned ? 'average' : 'good'}
                      disabled={!canPurchase}
                      tooltip={disabledReason}
                      onClick={() => act('purchase_standard', { ability: ability.id })}
                    >
                      {owned ? 'Owned' : 'Purchase'}
                    </Button>
                  </Table.Cell>
                </Table.Row>
              );
            })}
          </Table>
        )}
      </Section>
    </Stack.Item>
  </Stack>
);

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
  active?: BooleanLike;
};

export type BuildEntry = {
  id: string;
  name: string;
  modules: (ModuleEntry | null)[];
  activeModuleIds?: (string | null)[];
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
  builds: BuildEntry[];
  modules: ModuleEntry[];
  abilities: ModuleEntry[];
  cells: CytologyCellEntry[];
  recipes: RecipeEntry[];
  standardAbilities: StandardAbilityEntry[];
  geneticPoints: number;
  absorbs: number;
  dnaSamples: number;
  canReadapt: BooleanLike;
  isReconfiguring?: BooleanLike;
};

type DragPayload =
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
    modules = [],
    abilities = [],
    cells = [],
    recipes = [],
    standardAbilities = [],
    geneticPoints = 0,
    absorbs = 0,
    dnaSamples = 0,
    canReadapt,
    maxModuleSlots = 0,
    isReconfiguring,
  } = data;

  const [activeTab, setActiveTab] = useLocalState<
    'matrix' | 'cells' | 'abilities' | 'skills'
  >('genetic-matrix/tab', 'matrix');
  const reconfiguring = asBoolean(isReconfiguring);

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
                Recipes
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
                modules={modules}
                abilities={abilities}
                cells={cells}
                recipes={recipes}
                maxModuleSlots={maxModuleSlots}
                reconfiguring={reconfiguring}
              />
            )}
            {activeTab === 'cells' && <RecipesTab recipes={recipes} />}
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
  modules: ModuleEntry[];
  abilities: ModuleEntry[];
  cells: CytologyCellEntry[];
  recipes: RecipeEntry[];
  maxModuleSlots: number;
  reconfiguring: boolean;
};

const MatrixTab = ({
  act,
  builds,
  modules,
  abilities,
  cells,
  recipes,
  maxModuleSlots,
  reconfiguring,
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

  const selectedBuild = builds[0];

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

  const hasPendingChanges = useMemo(() => {
    if (!selectedBuild) {
      return false;
    }
    const modulesList = selectedBuild.modules ?? [];
    const activeIds = selectedBuild.activeModuleIds ?? [];
    const slotCount = Math.max(maxModuleSlots, modulesList.length, activeIds.length);
    for (let index = 0; index < slotCount; index += 1) {
      const assignedId = modulesList[index]?.id ?? null;
      const activeId = activeIds[index] ?? null;
      if (assignedId !== activeId) {
        return true;
      }
    }
    return false;
  }, [maxModuleSlots, selectedBuild]);

  const commitDisabledReason = !selectedBuild
    ? 'We lack a genetic configuration to edit.'
    : reconfiguring
      ? 'We are already reconfiguring our genome.'
      : !hasPendingChanges
        ? 'No changes to save.'
        : undefined;

  const handleCommitBuild = useCallback(() => {
    if (!selectedBuild) {
      return;
    }
    act('commit_build', { build: selectedBuild.id });
  }, [act, selectedBuild]);

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
        <Section
          title="Genome Configuration"
          buttons={
            <Button
              icon="save"
              disabled={!selectedBuild || reconfiguring || !hasPendingChanges}
              tooltip={commitDisabledReason}
              onClick={handleCommitBuild}
            >
              {reconfiguring ? 'Reconfiguring…' : 'Save Configuration'}
            </Button>
          }
        >
          <Stack vertical gap={0.5}>
            <Stack.Item>
              <Box color="label">
                Arrange our genetic modules below, then save to reshape our passive
                adaptations.
              </Box>
            </Stack.Item>
            {reconfiguring && (
              <Stack.Item>
                <NoticeBox type="info">
                  Our genome is in flux. Hold still while the reconfiguration finishes.
                </NoticeBox>
              </Stack.Item>
            )}
            {!reconfiguring && hasPendingChanges && (
              <Stack.Item>
                <NoticeBox type="warning">
                  Pending changes detected. Save to finalize our new configuration.
                </NoticeBox>
              </Stack.Item>
            )}
          </Stack>
        </Section>
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
                  onClearModule={(buildId, slot) =>
                    handleAssignModule(buildId, slot, null)
                  }
                  onClearBuild={handleClearBuild}
                  onModuleDropped={handleModuleDrop}
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
    const query = cellSearch.trim().toLowerCase();
    if (!query) {
      return cells;
    }
    return cells.filter((cell) =>
      cell.name.toLowerCase().includes(query) ||
      (cell.desc ? cell.desc.toLowerCase().includes(query) : false),
    );
  }, [cells, cellSearch]);

  const filteredAbilities = useMemo(() => {
    const query = abilitySearch.trim().toLowerCase();
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
                onChange={(value) => setCellSearch(value ?? '')}
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
                onChange={(value) => setAbilitySearch(value ?? '')}
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


type BuildEditorProps = {
  build: BuildEntry | undefined;
  maxModuleSlots: number;
  dragPayload: DragPayload | null;
  beginDrag: (event: DragEvent, payload: DragPayload) => void;
  endDrag: () => void;
  parsePayload: (event: DragEvent) => DragPayload | null;
  onClearModule: (buildId: string, slot: number) => void;
  onClearBuild: (buildId: string) => void;
  onModuleDropped: (payload: DragPayload, build: BuildEntry, slot: number) => void;
};

const BuildEditor = ({
  build,
  maxModuleSlots,
  dragPayload,
  beginDrag,
  endDrag,
  parsePayload,
  onClearModule,
  onClearBuild,
  onModuleDropped,
}: BuildEditorProps) => {
  if (!build) {
    return (
      <Section title="Matrix Editor">
        <NoticeBox>No genetic configuration is available.</NoticeBox>
      </Section>
    );
  }

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

  const activeModuleIds = build.activeModuleIds ?? [];

  return (
    <Section
      title={`Matrix Editor — ${build.name}`}
      buttons={
        <Button icon="eraser" tooltip="Clear all assignments" onClick={() => onClearBuild(build.id)}>
          Clear Matrix
        </Button>
      }
    >
      <Stack vertical gap={1}>
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
              const activeModuleId = activeModuleIds[slot - 1] ?? null;
              const pendingChange = Boolean(
                moduleEntry && moduleEntry.active !== undefined && !asBoolean(moduleEntry.active),
              );
              const pendingRemoval = !moduleEntry && Boolean(activeModuleId);
              const borderColor = highlight
                ? '#7fc'
                : pendingChange || pendingRemoval
                  ? '#f88'
                  : 'rgba(255, 255, 255, 0.2)';
              const backgroundColor = highlight
                ? 'rgba(64, 160, 255, 0.08)'
                : pendingChange || pendingRemoval
                  ? 'rgba(255, 120, 120, 0.08)'
                  : 'rgba(255,255,255,0.03)';
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
                        border: `1px dashed ${borderColor}`,
                        borderRadius: '6px',
                        minHeight: '72px',
                        backgroundColor: backgroundColor,
                      }}
                    >
                      {moduleEntry ? (
                        <ModuleSummary
                          module={moduleEntry}
                          showSource={false}
                          conflictTags={conflictTags}
                        />
                      ) : pendingRemoval ? (
                        <Box color="bad">Active module will be removed after saving.</Box>
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
  const statusDefined = module.active !== undefined;
  const isActive = statusDefined ? asBoolean(module.active) : false;
  const statusLabel = statusDefined ? (isActive ? 'Equipped' : 'Pending Save') : '';
  const statusColor = isActive ? 'good' : 'average';
  return (
    <Stack vertical gap={0.5}>
      <Stack.Item>
        <Stack justify="space-between" align="center" gap={0.5}>
          <Stack.Item>
            <Box bold>{module.name}</Box>
          </Stack.Item>
          {(statusDefined || sourceLabel) && (
            <Stack.Item>
              <Stack gap={0.5} align="center">
                {statusDefined && (
                  <Stack.Item>
                    <Box color={statusColor}>{statusLabel}</Box>
                  </Stack.Item>
                )}
                {sourceLabel && (
                  <Stack.Item>
                    <Box color={sourceColor}>{sourceLabel}</Box>
                  </Stack.Item>
                )}
              </Stack>
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

type RecipesTabProps = {
  recipes: RecipeEntry[];
};

const RecipesTab = ({ recipes }: RecipesTabProps) => {
  const [recipeSearch, setRecipeSearch] = useState('');

  const filteredRecipes = useMemo(() => {
    const query = recipeSearch.trim().toLowerCase();
    if (!query) {
      return recipes;
    }
    return recipes.filter((recipe) => {
      const name = (recipe.module?.name ?? recipe.name).toLowerCase();
      const desc = recipe.module?.desc ?? recipe.desc ?? '';
      return (
        name.includes(query) ||
        (desc ? desc.toLowerCase().includes(query) : false)
      );
    });
  }, [recipes, recipeSearch]);

  return (
    <Section title="Known Recipes" fill scrollable>
      <Stack vertical gap={1}>
        <Stack.Item>
          <Input
            value={recipeSearch}
            onChange={(value) => setRecipeSearch(value ?? '')}
            placeholder="Search recipes..."
          />
        </Stack.Item>
        <Stack.Item>
          {filteredRecipes.length === 0 ? (
            <NoticeBox>No genetic recipes known.</NoticeBox>
          ) : (
            <Stack vertical gap={1}>
              {filteredRecipes.map((recipe) => (
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
                    Abilities: {recipe.requiredAbilities
                      .map((req) => req.name)
                      .join(', ') || 'None'}
                  </Box>
                </Box>
              ))}
            </Stack>
          )}
        </Stack.Item>
      </Stack>
    </Section>
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

import { useCallback, useEffect, useMemo, useState } from 'react';
import type { DragEvent } from 'react';
import {
  Box,
  Button,
  Divider,
  Icon,
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
  desc: string;
  helptext: string;
  chemical_cost: number;
  dna_cost: number;
  req_dna: number;
  req_absorbs: number;
  button_icon_state: string | null;
  source?: string;
  slot?: number;
  slotType?: string;
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

export type RecipeEntry = {
  id: string;
  name: string;
};

export type SkillEntry = {
  id: string;
  name: string;
  level: number;
  levelName: string;
  exp: number;
  desc: string;
};

type GeneticMatrixData = {
  maxAbilitySlots?: number;
  maxModuleSlots?: number;
  maxBuilds: number;
  builds: BuildEntry[];
  resultCatalog: ProfileEntry[];
  abilityCatalog?: ModuleEntry[];
  moduleCatalog?: ModuleEntry[];
  cells: ProfileEntry[];
  cytologyCells?: CytologyCellEntry[];
  abilities?: ModuleEntry[];
  modules?: ModuleEntry[];
  recipes?: RecipeEntry[];
  skills: SkillEntry[];
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
    resultCatalog = [],
    moduleCatalog = [],
    abilityCatalog = [],
    cells = [],
    cytologyCells = [],
    modules = [],
    abilities = [],
    recipes = [],
    skills = [],
    canAddBuild,
    maxModuleSlots,
    maxAbilitySlots = 0,
    maxBuilds = 0,
  } = data;

  const availableCatalog = moduleCatalog.length ? moduleCatalog : abilityCatalog;
  const availableModules = modules.length ? modules : abilities;
  const maxSlots = maxModuleSlots ?? maxAbilitySlots ?? 0;

  const [activeTabRaw, setActiveTabRaw] = useLocalState<
    'matrix' | 'cells' | 'modules' | 'skills' | 'abilities'
  >('genetic-matrix/tab', 'matrix');
  const activeTab = activeTabRaw === 'abilities' ? 'modules' : activeTabRaw;
  const setActiveTab = useCallback(
    (tab: 'matrix' | 'cells' | 'modules' | 'skills') => setActiveTabRaw(tab),
    [setActiveTabRaw],
  );
  useEffect(() => {
    if (activeTabRaw === 'abilities') {
      setActiveTabRaw('modules');
    }
  }, [activeTabRaw, setActiveTabRaw]);
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
                selected={activeTab === 'modules'}
                onClick={() => setActiveTab('modules')}
              >
                Module Storage
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
                selectedBuild={selectedBuild}
                selectedBuildId={selectedBuildId}
                onSelectBuild={setSelectedBuildId}
                resultCatalog={resultCatalog}
                moduleCatalog={availableCatalog}
                maxModuleSlots={maxSlots}
                canAddBuild={asBoolean(canAddBuild)}
                maxBuilds={maxBuilds}
              />
            )}
            {activeTab === 'cells' && (
              <CellsTab
                profiles={cells}
                cytologyCells={cytologyCells}
                recipes={recipes}
              />
            )}
            {activeTab === 'modules' && (
              <ModuleStorageTab modules={availableModules} />
            )}
            {activeTab === 'skills' && <SkillsTab skills={skills} />}
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
  resultCatalog: ProfileEntry[];
  moduleCatalog: ModuleEntry[];
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
  resultCatalog,
  moduleCatalog,
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
              onClearModule={(buildId, slot) => handleAssignModule(buildId, slot, null)}
              onClearBuild={handleClearBuild}
              onProfileDropped={handleProfileDrop}
              onModuleDropped={handleModuleDrop}
            />
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill gap={1}>
              <Stack.Item grow>
                <ProfileCatalog
                  title="Result Catalog"
                  profiles={resultCatalog}
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
              <Stack.Item grow>
                <ModuleList
                  title="Module Catalog"
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
        </Stack>
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
        Chems: {module.chemical_cost} | DNA: {module.dna_cost} | Required DNA:{' '}
        {module.req_dna} | Required Absorbs: {module.req_absorbs}
      </Stack.Item>
      {module.slotType === 'key' && (
        <Stack.Item color="good">Key Active Module</Stack.Item>
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

const CellsTab = ({ profiles, cytologyCells, recipes }: CellsTabProps) => (
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
      <Section title="Cytology Cells" fill scrollable>
        {cytologyCells.length === 0 ? (
          <NoticeBox>No cytology cells catalogued.</NoticeBox>
        ) : (
          <Stack vertical gap={1}>
            {cytologyCells.map((cell) => (
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

type ModuleStorageTabProps = {
  modules: ModuleEntry[];
};

const ModuleStorageTab = ({ modules }: ModuleStorageTabProps) => (
  <ModuleList
    title="Module Storage"
    modules={modules}
    allowDrag={false}
    emptyMessage="We have not catalogued any modules."
  />
);

type SkillsTabProps = {
  skills: SkillEntry[];
};

const SkillsTab = ({ skills }: SkillsTabProps) => (
  <Section title="Standard Skills" fill scrollable>
    {skills.length === 0 ? (
      <NoticeBox>No skills recorded for this changeling.</NoticeBox>
    ) : (
      <Table>
        <Table.Row header>
          <Table.Cell>Skill</Table.Cell>
          <Table.Cell>Level</Table.Cell>
          <Table.Cell>Experience</Table.Cell>
          <Table.Cell>Description</Table.Cell>
        </Table.Row>
        {skills.map((skill) => (
          <Table.Row key={skill.id} className="candystripe">
            <Table.Cell>{skill.name}</Table.Cell>
            <Table.Cell>
              {skill.levelName} (Level {skill.level})
            </Table.Cell>
            <Table.Cell>{skill.exp}</Table.Cell>
            <Table.Cell>{skill.desc}</Table.Cell>
          </Table.Row>
        ))}
      </Table>
    )}
  </Section>
);

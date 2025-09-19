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

type ProfileEntry = {
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

type AbilityEntry = {
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
  abilityId?: string;
  moduleId?: string;
  moduleCategory?: string;
  moduleSource?: string;
  allowsDuplicates?: BooleanLike;
  allowKeySlot?: BooleanLike;
};

type BuildEntry = {
  id: string;
  name: string;
  profile: ProfileEntry | null;
  abilities: (AbilityEntry | null)[];
};

type SkillEntry = {
  id: string;
  name: string;
  level: number;
  levelName: string;
  exp: number;
  desc: string;
};

type RecipeEntry = {
  id: string;
  name: string;
};

type GeneticMatrixData = {
  maxAbilitySlots: number;
  maxBuilds: number;
  builds: BuildEntry[];
  resultCatalog: ProfileEntry[];
  abilityCatalog: AbilityEntry[];
  cells: ProfileEntry[];
  abilities: AbilityEntry[];
  skills: SkillEntry[];
  recipes?: RecipeEntry[];
  canAddBuild: BooleanLike;
};

type DragPayload =
  | { type: 'profile'; id: string }
  | { type: 'profile-slot'; id: string; buildId: string }
  | { type: 'ability'; id: string }
  | { type: 'ability-slot'; id: string; buildId: string; slot: number };

export const GeneticMatrix = () => {
  const { act, data } = useBackend<GeneticMatrixData>();
  const {
    builds = [],
    resultCatalog = [],
    abilityCatalog = [],
    cells = [],
    abilities = [],
    skills = [],
    canAddBuild,
    maxAbilitySlots = 0,
    maxBuilds = 0,
  } = data;

  const [activeTab, setActiveTab] = useLocalState<'matrix' | 'cells' | 'abilities' | 'skills'>(
    'genetic-matrix/tab',
    'matrix',
  );
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
                selectedBuild={selectedBuild}
                selectedBuildId={selectedBuildId}
                onSelectBuild={setSelectedBuildId}
                resultCatalog={resultCatalog}
                abilityCatalog={abilityCatalog}
                maxAbilitySlots={maxAbilitySlots}
                canAddBuild={asBoolean(canAddBuild)}
                maxBuilds={maxBuilds}
              />
            )}
            {activeTab === 'cells' && <CellsTab profiles={cells} />}
            {activeTab === 'abilities' && (
              <AbilitiesStorageTab abilities={abilities} />
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
  abilityCatalog: AbilityEntry[];
  maxAbilitySlots: number;
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
  abilityCatalog,
  maxAbilitySlots,
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

  const handleAssignAbility = useCallback(
    (buildId: string, slot: number, abilityId: string | null) => {
      if (!abilityId) {
        act('clear_build_ability', { build: buildId, slot });
        return;
      }
      act('set_build_ability', { build: buildId, slot, ability: abilityId });
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

  const assignedAbilityIds = useMemo(() => {
    if (!selectedBuild) {
      return new Set<string>();
    }
    return new Set(
      selectedBuild.abilities
        .filter((entry): entry is AbilityEntry => Boolean(entry))
        .filter((entry) => !asBoolean(entry.allowsDuplicates))
        .map((entry) => entry.moduleId ?? entry.id)
        .filter((id): id is string => Boolean(id)),
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

  const handleAbilityDrop = useCallback(
    (payload: DragPayload, targetBuild: BuildEntry, slot: number) => {
      if (payload.type === 'ability') {
        handleAssignAbility(targetBuild.id, slot, payload.id);
        return;
      }
      if (payload.type === 'ability-slot') {
        if (payload.buildId === targetBuild.id && payload.slot === slot) {
          return;
        }
        handleAssignAbility(targetBuild.id, slot, payload.id);
        act('clear_build_ability', { build: payload.buildId, slot: payload.slot });
      }
    },
    [act, handleAssignAbility],
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

  const handleAbilityDoubleClick = useCallback(
    (ability: AbilityEntry) => {
      if (!selectedBuild || maxAbilitySlots <= 0) {
        return;
      }
      const openIndex =
        selectedBuild.abilities.findIndex((entry) => !entry) + 1;
      const slot =
        openIndex > 0
          ? openIndex
          : selectedBuild.abilities.length > 0
            ? 1
            : 0;
      if (slot > 0) {
        handleAssignAbility(selectedBuild.id, slot, ability.id);
      }
    },
    [handleAssignAbility, maxAbilitySlots, selectedBuild],
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
              maxAbilitySlots={maxAbilitySlots}
              dragPayload={dragPayload}
              beginDrag={beginDrag}
              endDrag={endDrag}
              parsePayload={parsePayload}
              onClearProfile={(buildId) => handleAssignProfile(buildId, null)}
              onClearAbility={(buildId, slot) => handleAssignAbility(buildId, slot, null)}
              onClearBuild={handleClearBuild}
              onProfileDropped={handleProfileDrop}
              onAbilityDropped={handleAbilityDrop}
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
                <AbilityList
                  title="Ability Catalog"
                  abilities={abilityCatalog}
                  allowDrag
                  onDragStart={(ability, event) =>
                    beginDrag(event, { type: 'ability', id: ability.id })
                  }
                  onDragEnd={endDrag}
                  onDoubleClick={handleAbilityDoubleClick}
                  assignedAbilityIds={assignedAbilityIds}
                  emptyMessage="We do not possess any abilities to assign."
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
            Boolean(build.profile) || build.abilities.some((ability) => ability);
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
  maxAbilitySlots: number;
  dragPayload: DragPayload | null;
  beginDrag: (event: DragEvent, payload: DragPayload) => void;
  endDrag: () => void;
  parsePayload: (event: DragEvent) => DragPayload | null;
  onClearProfile: (buildId: string) => void;
  onClearAbility: (buildId: string, slot: number) => void;
  onClearBuild: (buildId: string) => void;
  onProfileDropped: (payload: DragPayload, build: BuildEntry) => void;
  onAbilityDropped: (payload: DragPayload, build: BuildEntry, slot: number) => void;
};

const BuildEditor = ({
  build,
  maxAbilitySlots,
  dragPayload,
  beginDrag,
  endDrag,
  parsePayload,
  onClearProfile,
  onClearAbility,
  onClearBuild,
  onProfileDropped,
  onAbilityDropped,
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
            {Array.from({ length: maxAbilitySlots }, (_, index) => {
              const slot = index + 1;
              const ability = build.abilities[index] ?? null;
              const highlight =
                dragPayload &&
                (dragPayload.type === 'ability' ||
                  (dragPayload.type === 'ability-slot' &&
                    (dragPayload.buildId !== build.id ||
                      dragPayload.slot !== slot)));
              return (
                <Stack align="center" gap={1} key={slot}>
                  <Stack.Item width="64px">
                    <Box textAlign="center" bold>
                      Slot {slot}
                    </Box>
                  </Stack.Item>
                  <Stack.Item grow>
                    <Box
                      p={1}
                      draggable={Boolean(ability)}
                      onDragStart={(event) => {
                        if (!ability) {
                          return;
                        }
                        beginDrag(event, {
                          type: 'ability-slot',
                          id: ability.id,
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
                          payload.type === 'ability' ||
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
                          payload.type === 'ability' ||
                          payload.type === 'ability-slot'
                        ) {
                          event.preventDefault();
                          onAbilityDropped(payload, build, slot);
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
                      {ability ? (
                        <AbilitySummary ability={ability} showSource={false} />
                      ) : (
                        <Box color="label">Drop an ability here.</Box>
                      )}
                    </Box>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="times"
                      disabled={!ability}
                      tooltip="Clear this slot"
                      onClick={() => onClearAbility(build.id, slot)}
                    />
                  </Stack.Item>
                </Stack>
              );
            })}
            {maxAbilitySlots === 0 && (
              <NoticeBox>
                This build has no ability slots available.
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

type AbilityListProps = {
  title: string;
  abilities: AbilityEntry[];
  allowDrag?: boolean;
  onDragStart?: (ability: AbilityEntry, event: DragEvent) => void;
  onDragEnd?: () => void;
  onDoubleClick?: (ability: AbilityEntry) => void;
  assignedAbilityIds?: Set<string>;
  emptyMessage?: string;
};

const AbilityList = ({
  title,
  abilities,
  allowDrag = false,
  onDragStart,
  onDragEnd,
  onDoubleClick,
  assignedAbilityIds,
  emptyMessage,
}: AbilityListProps) => (
  <Section title={title} fill scrollable>
    {abilities.length === 0 ? (
      <NoticeBox>{emptyMessage ?? 'No abilities available.'}</NoticeBox>
    ) : (
      <Stack vertical gap={1}>
        {abilities.map((ability) => {
          const isAssigned = assignedAbilityIds?.has(ability.id);
          return (
            <Box
              key={ability.id}
              className="candystripe"
              p={1}
              draggable={allowDrag}
              onDragStart={
                allowDrag
                  ? (event) => onDragStart?.(ability, event)
                  : undefined
              }
              onDragEnd={allowDrag ? onDragEnd : undefined}
              onDoubleClick={
                onDoubleClick ? () => onDoubleClick(ability) : undefined
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
              <AbilitySummary ability={ability} />
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

type AbilitySummaryProps = {
  ability: AbilityEntry;
  showSource?: boolean;
};

const AbilitySummary = ({ ability, showSource = true }: AbilitySummaryProps) => {
  const sourceLabel = showSource ? formatSource(ability.source) : '';
  const sourceColor = ability.source?.toLowerCase() === 'innate' ? 'good' : 'average';
  return (
    <Stack vertical gap={0.5}>
      <Stack.Item>
        <Stack justify="space-between" align="center" gap={0.5}>
          <Stack.Item>
            <Box bold>{ability.name}</Box>
          </Stack.Item>
          {sourceLabel && (
            <Stack.Item>
              <Box color={sourceColor}>{sourceLabel}</Box>
            </Stack.Item>
          )}
        </Stack>
      </Stack.Item>
      <Stack.Item color="label">
        Chems: {ability.chemical_cost} | DNA: {ability.dna_cost} | Required DNA:{' '}
        {ability.req_dna} | Required Absorbs: {ability.req_absorbs}
      </Stack.Item>
      {ability.desc && <Stack.Item>{ability.desc}</Stack.Item>}
      {ability.helptext && <Stack.Item color="good">{ability.helptext}</Stack.Item>}
    </Stack>
  );
};

type CellsTabProps = {
  profiles: ProfileEntry[];
};

const CellsTab = ({ profiles }: CellsTabProps) => (
  <ProfileCatalog
    title="Cells Storage"
    profiles={profiles}
    allowDrag={false}
    emptyMessage="We have no stored DNA samples."
  />
);

type AbilitiesStorageTabProps = {
  abilities: AbilityEntry[];
};

const AbilitiesStorageTab = ({ abilities }: AbilitiesStorageTabProps) => (
  <AbilityList
    title="Abilities Storage"
    abilities={abilities}
    allowDrag={false}
    emptyMessage="We have not acquired any abilities."
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

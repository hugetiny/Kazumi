---

description: "Task list template for feature implementation"
---

# Tasks: [FEATURE NAME]

**Input**: Design documents from `/specs/[###-feature-name]/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Principle V requires acceptance evidence. Include automated `flutter test` / integration tests or clearly labeled manual scripts whenever the spec marks them mandatory for a user story.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Single project**: `src/`, `tests/` at repository root
- **Web app**: `backend/src/`, `frontend/src/`
- **Mobile**: `api/src/`, `ios/src/` or `android/src/`
- Paths shown below assume single project - adjust based on plan.md structure

<!--
  ============================================================================
  IMPORTANT: The tasks below are SAMPLE TASKS for illustration purposes only.

  The /speckit.tasks command MUST replace these with actual tasks based on:
  - User stories from spec.md (with their priorities P1, P2, P3...)
  - Feature requirements from plan.md
  - Entities from data-model.md
  - Endpoints from contracts/

  Tasks MUST be organized by user story so each story can be:
  - Implemented independently
  - Tested independently
  - Delivered as an MVP increment

  DO NOT keep these sample tasks in the generated tasks.md file.
  ============================================================================
-->

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Flutter module initialization and baseline tooling

- [ ] T001 Run `flutter pub get` and ensure dependencies resolve across Windows and Android targets
- [ ] T002 Scaffold feature folders per implementation plan (`lib/pages/...`, `providers.dart`, tests)
- [ ] T003 [P] Configure analyzer rules, `flutter format`, and update `analysis_options.yaml` if new lints needed
- [ ] T004 [P] Add build runner watch scripts if new generated files are introduced

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

Examples of foundational tasks (adjust based on your feature scope):

- [ ] T010 Define Hive box schema updates, write migrations, and update WebDAV sync rules
- [ ] T011 [P] Extend `Request` wrappers or interceptors needed for new plugin interactions
- [ ] T012 [P] Update shared providers/controllers consumed by multiple user stories
- [ ] T013 Establish logging hooks via `KazumiLogger` and ensure privacy constraints are met
- [ ] T014 Document platform guards or feature flags for targeted devices

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - [Title] (Priority: P1) 🎯 MVP

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 1 (Acceptance Evidence) ⚠️

> **Write these tests first (or document manual scripts) and ensure they FAIL before implementation.**

- [ ] T020 [P] [US1] Widget/integration test covering user journey in `test/`
- [ ] T021 [P] [US1] Golden or screenshot test if UI changes are significant
- [ ] T022 [US1] Manual playback checklist (Windows + Android) if automated coverage unavailable

### Implementation for User Story 1

- [ ] T023 [P] [US1] Define Riverpod providers/state in `lib/pages/[feature]/providers.dart`
- [ ] T024 [P] [US1] Implement feature logic in `lib/pages/[feature]/[feature]_controller.dart`
- [ ] T025 [US1] Update UI in `lib/pages/[feature]/view.dart` ensuring fallback UI for errors
- [ ] T026 [US1] Wire networking through `Request` and update plugin fixtures in `assets/plugins/`
- [ ] T027 [US1] Persist state changes via `GStorage` if required and document retention
- [ ] T028 [US1] Add structured logging via `KazumiLogger`

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - [Title] (Priority: P2)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 2 (Acceptance Evidence) ⚠️

- [ ] T029 [P] [US2] Widget/integration test exercising new flow in `test/`
- [ ] T030 [US2] Manual platform checklist if device-specific behaviour introduced

### Implementation for User Story 2

- [ ] T031 [P] [US2] Extend providers/state in `lib/pages/[feature]/providers.dart`
- [ ] T032 [US2] Update controllers/services ensuring shared logic remains platform-neutral
- [ ] T033 [US2] Update UI with guarded feature flags and fallbacks
- [ ] T034 [US2] Adjust Hive/WebDAV syncing if additional data stored

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - [Title] (Priority: P3)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 3 (Acceptance Evidence) ⚠️

- [ ] T035 [P] [US3] Widget/integration test in `test/`
- [ ] T036 [US3] Manual playback or platform regression checklist if necessary

### Implementation for User Story 3

- [ ] T037 [P] [US3] Update providers/state in `lib/pages/[feature]/providers.dart`
- [ ] T038 [US3] Implement controllers ensuring playback integrations remain stable
- [ ] T039 [US3] Update UI and platform guards as needed

**Checkpoint**: All user stories should now be independently functional

---

[Add more user story phases as needed, following the same pattern]

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] TXXX [P] Documentation updates in `docs/` and release notes, including privacy notices
- [ ] TXXX Code cleanup and refactoring without breaking plugin interfaces
- [ ] TXXX Performance optimization and shader tuning across all stories
- [ ] TXXX [P] Additional unit/integration tests in `test/`
- [ ] TXXX Security and privacy hardening (network headers, consent flows)
- [ ] TXXX Validate quickstart/manual checklists for each supported platform

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - May integrate with US1 but should be independently testable
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - May integrate with US1/US2 but should be independently testable

### Within Each User Story

- Tests (if included) MUST be written and FAIL before implementation
- Models before services
- Services before endpoints
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All tests for a user story marked [P] can run in parallel
- Models within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together (if tests requested):
Task: "Contract test for [endpoint] in tests/contract/test_[name].py"
Task: "Integration test for [user journey] in tests/integration/test_[name].py"

# Launch all models for User Story 1 together:
Task: "Create [Entity1] model in src/models/[entity1].py"
Task: "Create [Entity2] model in src/models/[entity2].py"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 3 → Test independently → Deploy/Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence

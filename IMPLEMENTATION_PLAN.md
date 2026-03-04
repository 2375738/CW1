# IMPLEMENTATION_PLAN.md

Last updated: 2026-02-07

## Purpose
Track active work and closure criteria. Historical completed work is retained as summary; open work is prioritized.

## Status Key
- `Not Started`
- `In Progress`
- `Done`
- `Blocked`

## Current Snapshot
- Core tabs and major screens are implemented in Flutter.
- Routing shell is wired and tab highlighting is correct.
- Analyzer baseline is clean (`flutter analyze` no issues).
- Main active area: SOS behavior realism and recipient semantics.
- Local database persistence is now implemented with `sembast` (web/mobile-compatible), with provider hydration/autosave for core app state.

## Active Tasks
1. SOS notification taxonomy and action policy
   - Status: Done
   - Completion criteria:
   - Split urgent SOS vs location updates vs resolved updates into distinct notification types.
   - Show `Call`/`Navigate` actions only for urgent SOS alerts.
2. SOS recipient targeting
   - Status: Done
   - Completion criteria:
   - Exclude sender from SOS recipient notifications.
   - Ensure recipient notifications carry source member metadata.
3. SOS lifecycle ownership
   - Status: Done
   - Completion criteria:
   - Move SOS active lifecycle and periodic location update timer to provider-level state.
   - Stop timer on resolution/sign out/dispose.
4. SOS UX parity validation
   - Status: Done
   - Completion criteria:
   - Create a concrete QA checklist document for sender/recipient validation.
   - Checklist location: `docs/SOS_QA_CHECKLIST.md`.
5. Persistence foundation (local database/state)
   - Status: Done
   - Completion criteria:
   - Persist auth/session, active SOS state, notifications, and core tasks/events across app restarts.
   - Implement storage with a cross-platform local database and startup hydration.
   - Implemented with `sembast` (`family_hub/lib/data/local_database.dart`) and provider state serialization.

## Completed Summary
1. Parity audit between design reference and Flutter app
   - Status: Done
2. Missing screens in Flutter (Family, Login, Profile, Notification Settings, Privacy & Security)
   - Status: Done
3. Calendar flow parity
   - Status: Done
4. Tasks and Shopping parity
   - Status: Done
5. Map privacy UX parity
   - Status: Done
6. SOS flow parity (baseline states and UI)
   - Status: Done
7. Assets and media requirements
   - Status: Done
8. Documentation hygiene
   - Status: In Progress
9. Mobile platform submission readiness audit and scaffolding
   - Status: Done
10. Repository version-control bootstrap (local git init and baseline tracking)
   - Status: Done

## SOS Real-life Use Case (Target)
- Sender triggers SOS with deliberate hold.
- Only close-family recipients get urgent alert cards with `Call` and `Navigate` actions.
- Sender sees local status only (no self-alert card in notifications).
- While SOS is active, recipients receive periodic location updates (informational cards, no urgent action buttons).
- Sender taps `I'm safe`; recipients get a single SOS-resolved update and periodic updates stop.
- Sender switching account or logging out should not mutate SOS sender identity in recipient notifications.

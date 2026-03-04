# AGENTS.md

Purpose: Provide a shared, always-up-to-date source of truth for all agents working on this project.

## Start Here
- Read this file first.
- Review `IMPLEMENTATION_PLAN.md` before starting work.
- Append all changes to `AGENT_LOG.md`.

## Project Overview
FamilyHub is a Flutter app prototype for a private family coordination + safety app. It supports schedules, chores, shopping, location sharing, and SOS. There is also a design reference implementation in a separate folder.

## Task Clarification (2026-02-06)
- The only implementation target is the Flutter/Dart app in `family_hub/`.
- The Figma-exported web prototype in `FamilyHub App Design/` is a visual/flow reference, not a React implementation target.
- Current priority: finish missing settings screens and route wiring, then continue parity work per `IMPLEMENTATION_PLAN.md`.

## Product Brief (Condensed)
- Purpose: private family coordination + safety app for schedules, chores, shopping, location sharing, and SOS.
- Platforms: Android + iOS with native-feeling UI (Material 3 vs Cupertino patterns) but shared information architecture.
- MVP scope: UI flows + placeholder state only; no real-time chat, background tracking, or complex accounts.

## Repo Layout
- `family_hub/` Flutter implementation attempt (primary target for development).
- `FamilyHub App Design/` Web-based design reference (Figma-exported style prototype).
- `Coursework 1-1.pdf` Coursework brief and requirements.

## Source Of Truth
- Design reference: `FamilyHub App Design/`
- App implementation: `family_hub/`
- Requirements: `Coursework 1-1.pdf`

## Current Status Summary
- Flutter app implements 5 core tabs: Home, Calendar, Tasks, Map, SOS.
- Missing screens are now implemented: Family, Login, Profile, Notification Settings, Privacy & Security.
- Remaining parity gaps: none (parity tasks complete).

## Working Rules
- All work must be logged in `AGENT_LOG.md` with what changed and why.
- Each task must map to `IMPLEMENTATION_PLAN.md` and update its status.
- Keep files in ASCII unless the file already uses Unicode.
- Use `rg` for searches when possible.
- Do not delete or revert unrelated changes.

## Workflow
1. Pick a task from `IMPLEMENTATION_PLAN.md`.
2. Do the work.
3. Update the task status in `IMPLEMENTATION_PLAN.md`.
4. Add a log entry in `AGENT_LOG.md`.

## Decision Log
- The Flutter app is the primary implementation target.
- The web design prototype is a reference for parity checks.

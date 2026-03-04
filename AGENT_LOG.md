# AGENT_LOG.md

## 2026-02-05
- Created `AGENTS.md` to define shared project context, rules, and status summary for all agents.
- Created `AGENT.md` as a quick-start guide for new contributors.
- Created `IMPLEMENTATION_PLAN.md` with tasks, statuses, and completion criteria.
- Initialized documentation hygiene task as In Progress.
## 2026-02-05
- Logged parity audit results in `AGENTS.md` status summary and marked task 1 in `IMPLEMENTATION_PLAN.md` as Done.
## 2026-02-05
- Merged `AGENT.md` into `AGENTS.md` to follow a single, current convention.
- Removed `AGENT.md` to avoid duplicate guidance.
## 2026-02-05
- Implemented Flutter Login screen and added `/login` route to GoRouter.
- Marked missing-screens task as In Progress in `IMPLEMENTATION_PLAN.md`.
## 2026-02-05
- Added `family_hub/lib/screens/family_screen.dart` with a family list and basic actions.
- Added `/family` route in `family_hub/lib/main.dart`.
## 2026-02-05
- Added `family_hub/lib/screens/profile_screen.dart` with basic profile info and settings entry points.
- Added `/profile` route in `family_hub/lib/main.dart`.
## 2026-02-06
- Clarified Flutter-only implementation target and product brief in `AGENTS.md`.
- Added Notification Settings and Privacy & Security screens with routes.
- Wired Profile settings tiles to navigate to the new settings routes.
- Marked missing-screens task as Done in `IMPLEMENTATION_PLAN.md`.
## 2026-02-06
- Implemented calendar parity features: invite/edit/cancel flows, multi-member availability, and suggested times.
- Expanded calendar event model with invitation status and duration, and updated mock events and provider actions.
- Marked calendar parity task as Done in `IMPLEMENTATION_PLAN.md`.
## 2026-02-06
- Implemented tasks/shopping parity: richer task fields, status/accept/decline, reassignment, notes, and shopping item details.
- Updated task model and provider helpers, and refreshed Home/Tasks UI to match new flows.
- Marked tasks/shopping parity task as Done in `IMPLEMENTATION_PLAN.md`.
## 2026-02-06
- Implemented map privacy parity: sharing duration UI, sharing count, last-updated labels, and navigation action.
- Added provider support for sharing duration labels and end times.
- Marked map privacy parity task as Done in `IMPLEMENTATION_PLAN.md`.
## 2026-02-06
- Implemented SOS flow parity states (activating/sending/sent/failed) with notified members and retry actions.
- Updated `sos_screen.dart` to include status UI and placeholders for send failures.
- Marked SOS flow parity task as Done in `IMPLEMENTATION_PLAN.md`.
## 2026-02-06
- Added placeholder avatar, group cover, and notification sound assets, and registered them in `pubspec.yaml`.
- Updated Family and Notification Settings screens to reference the new assets.
- Marked assets/media requirements as Done in `IMPLEMENTATION_PLAN.md`.
## 2026-02-06
- Replaced cover asset with higher-fidelity SVG and added `flutter_svg` for rendering.
- Generated a simple 440Hz notification tone WAV and refreshed assets.
- Ran `flutter pub get` to resolve new dependencies.
## 2026-02-06
- Swapped member avatars to SVG and added a shared `AvatarView` widget for asset/remote avatars.
## 2026-02-06
- Added detailed gap report and next-step actions to `IMPLEMENTATION_PLAN.md`.
## 2026-02-06
- Started gap closure: implemented Family relationship management (grouping, add/edit/remove, SOS-enabled toggle).
## 2026-02-06
- Added Home notifications panel with accept/decline actions and mock notifications.
## 2026-02-06
- Added Calendar invite accept/decline actions for pending invites.
## 2026-02-06
- Added task priority field and delete action for chores, updated creation/edit flows and UI.
## 2026-02-06
- Added Map “Your Location” section with share toggle, duration shortcuts, and privacy notice.
## 2026-02-06
- Added SOS explainer panel and CTA buttons (Call 911, Manage Family Relationships).
## 2026-02-06
- Added map member address, role, and sharing-until metadata to location list.
## 2026-02-06
- Expanded shopping list cards/details with priority and assignee metadata.
## 2026-02-06
- Polished Home notifications: added event update/task completed notifications, timestamps, dismiss actions, and styles.
## 2026-02-06
- Wired notification bell to open a notifications sheet with actions.
## 2026-02-06
- Updated Home shopping tasks section to show the most recent items.
## 2026-02-06
- Fixed Home notification Accept/Decline for task assignments to dismiss after action.
## 2026-02-06
- Scoped notifications to recipient user to avoid showing other members’ alerts.
## 2026-02-06
- Wired Profile settings to Family & Relationships and reordered settings items to match sample.
## 2026-02-06
- Added Profile tab to bottom navigation and moved Profile route into shell; avatar tap now opens Profile.
## 2026-02-06
- Added demo account “Use” buttons to the Login screen.
## 2026-02-06
- Wired demo account “Use” buttons to auto-sign-in.
## 2026-02-06
- Moved `/family` and settings routes under the shell so bottom nav is visible on those screens.
## 2026-02-06
- Added auth guard with login state, login redirect, and sign-out handling.
## 2026-02-06
- Added a lightweight “Skip login (dev)” toggle on the Login screen.
## 2026-02-06
- Made demo/skip login navigate immediately to Home.
## 2026-02-06
- Added a new shopping task creation dialog/button in the Shopping tab.
## 2026-02-06
- Updated shopping add flow to use item picker with selectable items and add-new support.
## 2026-02-06
- Added shopping task assignee selection and fixed item IDs to prevent checkbox fan-out.
## 2026-02-06
- Removed floating shopping add button, added shopping reassignment + progress bar, and hid completed chores on Home.
## 2026-02-06
- Set app start route to `/login` and wired login sign-in to navigate to home.
## 2026-02-07
- Fixed notifications sheet builder in amily_hub/lib/screens/home_screen.dart to avoid invalid inal inside widget list (restored compile).
## 2026-02-07
- Wired Home "View All" in Family section to /family route.
- Added placeholder external app shortcuts (WhatsApp/Telegram/Messenger/Instagram) on Family member cards with snackbars.
## 2026-02-07
- Added Font Awesome dependency and swapped family contact shortcuts to brand-relevant icons/colors in Home and Family screens.
## 2026-02-07
- Fixed shopping details bottom sheet overflow by making content scrollable and height-bounded.
## 2026-02-07
- Added per-item assignment for shopping items, with item-level reassignment menu and notifications for reassigned items.
## 2026-02-07
- Fixed shopping item reassignment notification insertion to use provider notifications list.
## 2026-03-04
- Initialized git repository at `CW1` to enable project-wide version control.
- Added root `.gitignore` for editor/OS/build artifacts.
- Updated `IMPLEMENTATION_PLAN.md` to record repository version-control bootstrap as Done.
## 2026-02-07
- Updated shopping item reassignment to remove the item from the current list and create a new shopping task for the assignee (with notification).
## 2026-02-07
- Added shared shopping notifications for close family and item-purchased notifications; removed top-level shopping task reassignment control in details sheet.
## 2026-02-07
- Fixed map share duration bottom sheet overflow with SafeArea + scroll and aligned duration options to 1h/4h/All Day.
## 2026-02-07
- Aligned map center and member locations to Swansea and replaced map/list initials with profile avatars in Map screen.
## 2026-02-07
- Reworked Map screen layout to match Figma: header + sharing pill, fixed-height map card, Your Location card, privacy notice, and family list (removed draggable sheet).
## 2026-02-07
- Tuned map markers to Swansea Bay Campus/Marina coordinates and aligned sharing count/marker visibility with member location labels.
## 2026-02-07
- Updated map marker coordinates to match displayed Swansea addresses (Bay Campus SA1 8EP and SA1 3XG).
## 2026-02-07
- Fixed SOS screen overflow by making content scrollable and removing center-only layout constraints.
## 2026-02-07
- Matched SOS tab layout to Figma: header/subtitle, SOS card with hold button + progress, notified members list with avatars, status cards for sending/sent/failed, and action CTAs.
## 2026-02-07
- Closed SOS gaps vs Figma: added per-member sending/notified badges, accurate sending count, hold progress only while holding, close-family list, and wired Manage Family Relationships navigation.
## 2026-02-07
- Added missing models import in SOS screen to resolve FamilyMember type.
## 2026-02-07
- Added SOS alert/cancel notifications to close family + current user, updated Home decoration for resolved alerts, and switched emergency CTA to Call 999.
## 2026-02-07
- Adjusted SOS sent state: removed black background, changed Dismiss to I'm safe, and added Call 999 CTA in sent view.
## 2026-02-07
- Added SOS location update notifications every 3 minutes until resolved, call/navigate buttons for SOS recipient cards and notifications, and blinking emergency notifications.
## 2026-02-07
- Added shared assignee option for shopping tasks, item bought-by attribution, demo account switching, and SOS notification actions/blinking in the notifications sheet.
## 2026-02-07
- Scoped blinking behavior to first SOS alert only (Emergency SOS), while SOS location update notifications remain static.
## 2026-02-07
- Fixed bottom-tab selection mapping: /family and /settings/* now correctly highlight Profile tab in shell navigation.
## 2026-02-07
- Fixed actionable analyzer issues: corrected widget test bootstrap (FamilyHubApp), removed duplicate/unused imports, removed unused vars/dead helper, and cleaned minor lint items (spread/toList, interpolation).
## 2026-02-07`n- Completed deprecation-focused cleanup pass: migrated deprecated color opacity APIs, replaced deprecated DropdownButtonFormField value with initialValue, removed unreachable switch defaults, updated deprecated theme color fields, removed deprecated useTextTheme, and resolved remaining lint warnings. flutter analyze now reports no issues.
## 2026-02-07
- Performed SOS logic audit and updated IMPLEMENTATION_PLAN.md: re-opened SOS task to In Progress, documented real-life emergency scenario, identified current behavior gaps, and added concrete closure tasks.
## 2026-02-07
- Closed major SOS logic gaps: replaced generic emergency notification types with sosAlert/sosLocationUpdate/sosResolved, restricted Call/Navigate actions to sosAlert, and scoped blinking to sosAlert only.
- Moved SOS active lifecycle to provider state (start/stop methods + provider-owned 3-minute location update timer), excluding sender from recipient notifications and stopping updates on resolution/sign-out/dispose.
- Reworked IMPLEMENTATION_PLAN.md to a logical active-work structure and updated SOS closure statuses.
## 2026-02-07
- Added concrete SOS QA checklist at docs/SOS_QA_CHECKLIST.md (sender/recipient scenarios, expected outcomes, pass/fail tracking).
- Updated IMPLEMENTATION_PLAN.md: marked SOS UX parity validation task as Done with checklist reference.
## 2026-02-07
- Clarified SOS recipient testing in login flow: added demo buttons for Dad/Mom/Alex/Sarah and labeled accounts; added explicit note that SOS targets close-family users only.
- Verified code health after changes (`flutter analyze` in `family_hub/`: no issues).
## 2026-02-07
- Implemented SOS-aware Map behavior for recipients: emergency banner with Call/Navigate actions, pulsing red SOS initiator marker, SOS-active badge in family list, and one-time map auto-focus to initiator.
- Kept sender experience non-SOS-highlighted on Map to avoid self-alert noise.
- Verified code health after map changes (`flutter analyze` in `family_hub/`: no issues).
## 2026-02-07
- Replaced placeholder Call/Navigate actions with real external intents using `url_launcher` across Home SOS notifications, Map SOS banner/family navigation, and SOS recipient cards.
- Wired emergency CTA to real dialer action (`Call 999`) instead of placeholder snackbar.
- Added shared launcher utility in `family_hub/lib/utils/external_actions.dart` and updated dependencies in `family_hub/pubspec.yaml`.
- Verified dependency resolution (`flutter pub get`) and code health (`flutter analyze` in `family_hub/`: no issues).
## 2026-02-07
- Fixed SOS cross-account behavior: logout no longer cancels active SOS automatically, and SOS sender identity is now pinned to the original initiator for alert/update/resolve notifications.
- Updated demo login aliases to accept `dad@example.com` and `mom@example.com` in addition to existing demo emails.
- Updated `IMPLEMENTATION_PLAN.md` with an explicit local persistence/database task and SOS sender-identity closure criterion.
- Verified code health after provider changes (`flutter analyze` in `family_hub/`: no issues).
## 2026-02-07
- Implemented local database persistence foundation using `sembast` with web/mobile adapters (`family_hub/lib/data/local_database.dart`, `family_hub/lib/data/db_platform_io.dart`, `family_hub/lib/data/db_platform_web.dart`).
- Wired `FamilyProvider` startup hydration + automatic state persistence for auth/session, members, events, tasks, notifications, SOS state, and location-sharing metadata.
- Updated app startup routing to use a shared provider instance with GoRouter `refreshListenable`, so persisted login state redirects correctly after hydration.
- Added DB dependencies in `family_hub/pubspec.yaml` and validated integration (`flutter pub get`, `flutter analyze`: no issues).
- Updated `family_hub/test/widget_test.dart` login-screen assertion text to match current UI copy and revalidated tests (`flutter test`: all passed).
## 2026-02-07
- Fixed Map user marker placement bug: current-user marker now uses ID-based member coordinates instead of hardcoded Dad location.
- Removed static home marker from map layer to avoid visual overlap/misidentification of SOS initiator markers.
- Revalidated after map fix (`flutter analyze` in `family_hub/`: no issues).
## 2026-02-07
- Refactored Map location rendering to use a single resolved location source (`_ResolvedLocation`) for both map markers and family list rows.
- Updated SOS initiator marker/list highlighting and navigation actions to use the same resolved location data path, reducing marker/list drift.
- Revalidated map refactor with `flutter analyze` and `flutter test` (all passing).
## 2026-02-07
- Fixed Home shopping card action wiring: shopping task button is now always actionable and navigates to `/tasks`; it still performs `Accept` first when task is pending and assigned to current user.
- This resolves disabled `Open` behavior for shared/unassigned pending shopping tasks shown on Home.
- Revalidated after change (`flutter analyze` in `family_hub/`: no issues).
## 2026-02-07
- Fixed persistence restore behavior for list fields in `FamilyProvider`: saved empty lists (`members`, `upcomingEvents`, `pendingTasks`, `notifications`) are now restored correctly instead of falling back to default seeded mock data.
- This prevents dismissed notifications from reappearing purely due to restore conditions.
- Revalidated after fix (`flutter analyze` in `family_hub/`: no issues).
## 2026-03-04
- Performed Android/iOS submission-readiness audit for `family_hub/` after confirming web run success.
- Added missing iOS CocoaPods scaffolding (`ios/Podfile`) and restored Pods includes in `ios/Flutter/Debug.xcconfig` and `ios/Flutter/Release.xcconfig` so iOS plugin integration can be installed via `pod install`.
- Added `android.permission.INTERNET` to `android/app/src/main/AndroidManifest.xml` to ensure release Android builds can access network resources (map tiles/external URL actions).
- Ran validation checks: `flutter analyze` (2 deprecation infos), `flutter build apk --debug` (blocked by missing local Android SDK), and `flutter doctor -v` (confirms local env issue, not project source layout).
- Installed Android Studio (`Google.AndroidStudio`) and Android SDK command-line tools locally; configured Flutter SDK path to `C:\Users\kadet\AppData\Local\Android\Sdk`; accepted Android licenses.
- Installed required SDK components (`platform-tools`, `platforms;android-35`, `build-tools;35.0.0`) and verified Android toolchain detection via `flutter doctor -v`.
- Fixed Android build compatibility for `flutter_local_notifications` by enabling core library desugaring and adding `desugar_jdk_libs` in `android/app/build.gradle.kts`.

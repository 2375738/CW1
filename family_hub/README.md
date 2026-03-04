# Family Hub

A Flutter application designed to help families share tasks, sync their calendars, and stay safe with quick SOS alerts. 

This project was developed as an MVP (Minimum Viable Product) for Coursework 2, successfully implementing 11 out of the 15 required Flutter rubric features.

## 🚀 Features Implemented (11/15 Rubric Features)
This application successfully demonstrates the following technical requirements from the coursework rubric:
1. **Widgets:** Deeply nested UI components (Rows, Columns, Stacks) mirroring original Figma prototypes.
2. **Navigable Screens:** Sophisticated routing and argument passing utilizing `go_router`.
3. **Forms:** Robust text input and validation across the app (Creating Chores, Calendar Events, etc.).
4. **App Gestures:** Long-press interactions (e.g., Hold-to-activate SOS button to prevent accidental triggers).
5. **Animations:** Looping alert pulses and screen transitions.
6. **Various Media Assets:** Integration of scalable vector graphics (`flutter_svg`) and local image assets.
7. **Dialog Boxes:** Native modal popups for destructive actions (e.g., "Cancel Event") and snappy data entry.
8. **Data Persistence Across Screens:** Local NoSQL database integration using `sembast` to persist chores, events, and shopping lists across sessions.
9. **Testing:** Automated Widget Tests to guarantee reliable UI rendering.
10. **Device Features:** Integration with native device capabilities for SOS Map locations.
11. **Launching URLS:** Utilization of `url_launcher` to redirect to native phone apps (Calls, Messages, external maps).

## 🛠 Tech Stack
*   **Framework:** Flutter (Dart)
*   **State Management:** `provider`
*   **Routing:** `go_router`
*   **Database:** `sembast` (Local NoSQL MVP)
*   **Maps & Geolocation:** `flutter_map` / `latlong2`
*   **Styling:** `flex_color_scheme`, `google_fonts`
*   **Date/Time Handling:** `intl`, `table_calendar`

## ⚠️ Limitations (MVP Scope)
As this is a Coursework MVP, certain architectural shortcuts were deliberately made:
*   **Local Database:** `sembast` is used to satisfy the *Data Persistence* requirement. Because it is a local NoSQL database, family data is synced across screens locally, but it does NOT sync to a remote cloud server. A production release would migrate this architecture to a solution like Firebase Firestore.
*   **Mocked Authentication:** The login flow is currently simulated for UX purposes and does not connect to a real identity provider (like FirebaseAuth).
*   **Simulated Real-time Location:** The Map/SOS feature utilizes static mocked coordinates or simplified device locations rather than live background socket tracking, which would heavily impact device battery.

## 💻 How to Run the App
Ensure you have the Flutter SDK installed on your system.
1. Navigate to the project directory:
   ```bash
   cd family_hub
   ```
2. Install all dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   # Run on an attached device or emulator
   flutter run

   # Or, specifically run as a web application (Recommended for UI review)
   flutter run -d chrome
   ```

## 🧪 How to Test
Basic automated tests have been written against the core application widgets to verify their layout and rendering stability.
To run the automated test suite, execute the following command in your terminal:
```bash
flutter test
```

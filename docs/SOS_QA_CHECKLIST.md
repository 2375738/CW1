# SOS_QA_CHECKLIST.md

Last updated: 2026-02-07

## Purpose
Validate SOS behavior against the intended emergency flow using current demo accounts.

## Test Personas
- Sender: `mike@example.com` (Dad)
- Recipient A: `mary@example.com` (Mom)
- Recipient B: `emma@example.com` (Alex)
- Non-close-family control: `sarah@example.com` (Friend)

## Preconditions
- App builds and runs.
- Start from a clean session when possible.
- Use one account at a time in the same app instance (current demo setup).
- Open Home notification panel for recipient verification after each SOS action.

## Pass/Fail Legend
- `Pass`: observed behavior matches expected result.
- `Fail`: behavior deviates from expected result.

## Checklist

### A. Trigger and Recipient Targeting
1. Sign in as Sender (`mike@example.com`), trigger SOS with press-and-hold.
- Expected: SOS screen moves `idle -> sending -> sent`.
- Expected: Sender does not receive recipient-facing SOS notification card with Call/Navigate in Home notifications.
- Result: [ ] Pass [ ] Fail

2. Switch to Recipient A (`mary@example.com`) and open notifications.
- Expected: One urgent `Emergency SOS` notification is present.
- Expected: Notification has `Call` and `Navigate` actions.
- Result: [ ] Pass [ ] Fail

3. Switch to Recipient B (`emma@example.com`) and open notifications.
- Expected: One urgent `Emergency SOS` notification is present with `Call` and `Navigate`.
- Result: [ ] Pass [ ] Fail

4. Switch to Non-close-family control (`sarah@example.com`) and open notifications.
- Expected: No SOS alert notification received.
- Result: [ ] Pass [ ] Fail

### B. SOS Location Updates
5. Keep SOS active for at least one update interval cycle.
- Expected: `Location Update` notification appears for close-family recipients.
- Expected: `Location Update` is informational (no Call/Navigate action buttons).
- Expected: `Location Update` does not blink.
- Result: [ ] Pass [ ] Fail

### C. Visual Priority and Action Policy
6. Recipient Home notification list visual check.
- Expected: `Emergency SOS` card blinks.
- Expected: Only urgent `Emergency SOS` card blinks.
- Expected: `Location Update` and `SOS Cancelled` cards do not blink.
- Result: [ ] Pass [ ] Fail

7. Recipient notification action check.
- Expected: `Call` and `Navigate` appear only for urgent `Emergency SOS` cards.
- Expected: No urgent action buttons on `Location Update` and `SOS Cancelled` cards.
- Result: [ ] Pass [ ] Fail

### D. Resolution / Reverse SOS
8. Return to Sender and press `I'm safe`.
- Expected: SOS is resolved in sender flow.
- Expected: Periodic location updates stop.
- Result: [ ] Pass [ ] Fail

9. Switch to Recipient A and Recipient B notifications.
- Expected: `SOS Cancelled` (or equivalent safe/resolved message) appears once.
- Expected: No new `Location Update` notifications after resolution.
- Result: [ ] Pass [ ] Fail

### E. Regression Checks
10. Non-SOS notifications still function.
- Expected: Event/task notifications still render and actions still work.
- Result: [ ] Pass [ ] Fail

11. App stability after SOS cycle.
- Expected: No crashes, no stuck SOS state after sign-out/sign-in.
- Result: [ ] Pass [ ] Fail

## Defect Notes Template
- Case ID:
- Observed behavior:
- Expected behavior:
- Account used:
- Screenshot/path:
- Severity: `High` / `Medium` / `Low`

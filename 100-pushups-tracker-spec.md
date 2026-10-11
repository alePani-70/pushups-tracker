# App Specification — "Hundred Pushups Tracker"
**Version:** 1.2 · **Type:** Mobile app (iOS & Android) · **Offline-first, no account required**

> **Changelog 1.2 (2026-10-11):** registration step (name, age, weight, sex) before the initial test; workout preview before starting a workout; browsable program detail (all weeks/days/columns and test gates); profile editable in Settings.

---

## 1. Overview

A single-purpose training companion for the *One Hundred Pushups* 6-week program (source data: `100-pushups-program.md`). The app:

1. Holds the complete program data (initial test, 6 weeks × 3 days × 3 columns, exhaustion tests between weeks, final test).
2. Walks the user through the correct progression (including week-repeats and test gates).
3. Lets the user schedule their 3 weekly workout days and notifies them locally when a workout is due.
4. Runs the workout session: shows the current set, counts reps, and times the rest period between sets.
5. Tracks all progress in a local database (tests, complete workouts, incomplete workouts, missed workouts) and reprograms unfinished work onto the next workout day.
6. Shows progress at any time, including a progress graph.

**Non-goals (v1):** social features, cloud sync, wearable integration, exercise-form camera analysis, other exercises.

---

## 2. Core concepts & rules

- **Program flow:** Initial Test → Week 1 → Week 2 → Exhaustion Test #1 → Week 3 → Week 4 → Exhaustion Test #2 → Week 5 → (Exhaustion Test #3 / gate) → Week 6 → Final Test.
- **Workout days:** 3 per week, with ≥1 rest day between them. Default suggestion: Mon / Wed / Fri. User-configurable.
- **Columns:** Each workout day has 3 columns. Column selection is driven by test results, never chosen freely by the user (except an optional manual override in Settings).
- **Set notation:** A set is a fixed number (e.g. `12`) or a `+` set (e.g. `12+`): *at least* that many reps, then as many more good-form reps as comfortably possible.
- **Rest between sets:** fixed per workout day (45 / 60 / 90 / 120 s). The rest timer may be extended ("longer if required"), never shortened below the prescribed minimum in v1.
- **Repeats:** If the user fails or struggles with a week, they can repeat it. Failing an exhaustion-test gate routes them back to repeat the appropriate week.
- **Rank table** (initial test, by age) is display-only context; the app uses the raw pushup count for column selection. The user's registered **age** selects the rank band (<40 / 40–55 / >55).
- **Profile:** name, age, weight and sex are collected at registration. Only age influences anything (rank band); weight and sex are stored for the user's own records and export, never for routing.
- **Transparency:** the full program (every week, day, column, rest time and test gate) is browsable at any time, and the next workout's sets are shown before it is started.

---

## 3. Screens & user flows

### 3.1 Onboarding
1. Disclaimer screen (medical clearance advice, "consult your doctor").
2. **Registration** (collected before the initial test):
   - **Name** — required, 1–40 characters; used for greetings ("Hi Ana") and the export.
   - **Age** — required integer, 10–100; selects the rank band shown after tests.
   - **Weight** — optional, kg (one decimal), 20–300; stored for the user's records only.
   - **Sex** — one of Female / Male / Other / Prefer not to say; stored only.
   - All fields are editable later in Settings → Profile. Nothing is sent anywhere.
3. "Take the Initial Test" screen: instructions + big **START TEST** button → single-tap counter (tap per pushup, or +/- buttons; undo supported) → **FINISH** → enter result.
4. App computes starting point and shows the planned schedule:
   - Result ≤5 → Week 1, Col 1 · 6–10 → Col 2 · 11–20 → Col 3 · >20 → Week 3 (Col 2 if ≤30, Col 3 if >30).
   - The summary shows the rank for the user's own age band and a **preview of Week X · Day 1** in the assigned column (sets, reps, rest), plus a link to the full program.
5. **Registration-time schedule choice:** the user picks exactly **3 days per week** and **one time of day** for workouts (default Mon/Wed/Fri, 18:00). The picker enforces ≥1 rest day between chosen days (warn if violated). Optional: enable notifications.
6. After registration, the app generates the user's personal workout calendar: the next 6 weeks of workout/test slots from the chosen days+time, plus the initial-test rest days.

### 3.2 Home (dashboard)
- Current position: "Week 3 · Day 2 · Column 2".
- Next scheduled workout with date/time; countdown to it.
- Progress bar: % of program completed; total pushups done to date.
- **Catch-up card** (when applicable): "You missed Week 3 · Day 1 — it has been moved to your next workout slot (Thu 18:00)" or "Resume incomplete workout — 3 of 5 sets done."
- **Next Up card shows the workout content inline**: the set list for the assigned column (e.g. "10 · 12 · 7 · 7 · 9+ · rest 60 s · ~9 min"). Tapping the card or **Preview** opens the Workout Preview (§3.8). Upcoming slots in the list open the preview read-only.
- Quick actions: **Start workout** · **Resume incomplete** · **Preview** · **Reschedule** · **Take exhaustion test** (when due) · **View progress** · **View program** (§3.9).
- Greeting uses the registered name.

### 3.3 Test screens (initial / exhaustion / final)
- Same single-tap counter UI, with safety instruction text ("stop when you physically can't do another good-form rep").
- After an exhaustion test, the app shows the computed routing (e.g. "21–25 → Week 3, Column 2") and asks to confirm.
- After the final test, result screen: success (≥100) with celebration + summary, or "repeat Week 5/6" guidance.

### 3.4 Workout session screen (core screen)
Layout:
- **Header:** Week X · Day Y · current set n/N · prescribed reps for this set (`12` or `12+`).
- **Rep counter:** large tap zone counts reps (also volume-button tap optional). Vibrates/haptics on each rep (toggleable); screen stays awake.
- **Set complete** → rest timer auto-starts: big countdown ring, remaining sets previewed below ("Next: Set 3 — 7 reps").
- **Rest controls:** **+15 s** button (extend, unlimited), **Skip** (allowed only after the prescribed rest has elapsed).
- At the end of a `+` set: prompt "How many extra reps beyond the minimum?" (prefilled with count) — stored for stats.
- **Pause / abandon mid-workout:** user can save-and-exit at any point. The workout is saved as **incomplete** with the sets done so far (sets not yet attempted are stored as `null`). Resume is offered next time from the exact point of interruption (rest timer recomputed from wall clock).
- **End-of-workout summary:** sets done, total reps, min extras achieved, "mark week complete" (or "repeat this week" flag).

### 3.5 Schedule & notifications screen
- Pick 3 weekday slots + time per slot.
- Toggles: workout reminder, day-before reminder, rest-day recovery reminder (optional).
- Request OS notification permission here and at onboarding.

### 3.6 History & stats
- Log of every test and workout (date, result, column).
- Chart: max consecutive pushups over time; total reps per week.

### 3.7 Settings
- **Profile:** view and edit name, age, weight, sex (same validation as registration).
- Sound/haptics toggles, keep-screen-awake toggle, manual column override (advanced), reset program, export log as CSV.

### 3.8 Workout preview
Shown before any workout is started (from the Next Up card, the upcoming list, the program browser, and the onboarding summary).
- **Header:** Week X · Day Y · Column Z (with the column's test-result label, e.g. "Column 2 · 6–10").
- **Set table:** one row per set — set number, prescribed reps (`12` or `12+`), and for a resumed workout the reps already performed. Total minimum reps, rest between sets, and an estimated duration (≈ 2 s per rep + rest × (sets − 1), rounded up to the minute).
- **Explanations:** what `+` means; "rest longer if required"; reminder that the column is fixed for the week.
- **Actions:** **START WORKOUT** (only when this is the user's next pending slot or a resume slot; otherwise the button is hidden and a note says when it becomes available) · **Back**.
- Read-only previews of future slots never change state.

### 3.9 Program browser
A reference view of the entire program, reachable from Home and Settings.
- Week selector (1–6) and column selector (1–3, defaulting to the user's current column, with each column's test-result label).
- For the selected week: the three days with their set lists and rest time; days already completed are marked, the next due day is highlighted.
- Test gates between weeks: which test, when it is due, and the routing thresholds (e.g. "ET1 after Week 2: <16 repeat · 16–20 → Col 1 · 21–25 → Col 2 · >25 → Col 3").
- Initial-test routing and the rank table (with the user's own band highlighted).
- Tapping a day opens the Workout Preview (§3.8) for that day/column (read-only unless it is the next due slot).

---

## 4. Program data model

All program content is bundled as a versioned JSON asset (`program_v1.json`) so it can be corrected without an app update. No network needed.

```jsonc
{
  "version": 1,
  "initialTest": {
    "type": "max_reps",
    "instruction": "Perform as many good-form pushups as you can.",
    "ranks": [                                  // display-only context
      {"rank": 1, "age_<40": "0-5",   "age_40_55": "0-5",   "age_>55": "0-5"},
      {"rank": 2, "age_<40": "6-14",  "age_40_55": "6-12",  "age_>55": "6-10"},
      {"rank": 3, "age_<40": "15-29", "age_40_55": "13-24", "age_>55": "11-19"},
      {"rank": 4, "age_<40": "30-49", "age_40_55": "25-44", "age_>55": "20-34"},
      {"rank": 5, "age_<40": "50-99", "age_40_55": "45-74", "age_>55": "35-64"},
      {"rank": 6, "age_<40": "100-150","age_40_55": "75-124","age_>55": "65-99"},
      {"rank": 7, "age_<40": ">150",  "age_40_55": ">125",  "age_>55": ">100"}
    ],
    "startRouting": [
      {"max": 5,  "goto": {"week": 1, "column": 1}},
      {"max": 10, "goto": {"week": 1, "column": 2}},
      {"max": 20, "goto": {"week": 1, "column": 3}},
      {"max": 30, "goto": {"week": 3, "column": 2}},
      {"max": 99999, "goto": {"week": 3, "column": 3}}
    ]
  },
  "weeks": [ /* see Appendix A — one entry per week:
      { "week": 1,
        "columnLabels": ["< 5", "6-10", "11-20"],
        "days": [ { "restSeconds": 60,
                    "sets": [[2,6,10],[3,6,12],[2,4,7],[2,4,7],[3,5,9]],
                    "isPlus": [false,false,false,false,true] }, ... ] } */ ],
  "exhaustionTests": [
    {"id": "ET1", "afterWeek": 2, "windowDays": 2,
     "routing": [{"max": 15, "action": "repeat", "targetWeek": 2},
                 {"max": 20, "goto": {"week": 3, "column": 1}},
                 {"max": 25, "goto": {"week": 3, "column": 2}},
                 {"max": 99999, "goto": {"week": 3, "column": 3}}]},
    {"id": "ET2", "afterWeek": 4, "windowDays": 2,
     "routing": [{"max": 30, "action": "repeat", "targetWeek": 4},
                 {"max": 35, "goto": {"week": 5, "column": 1}},
                 {"max": 40, "goto": {"week": 5, "column": 2}},
                 {"max": 99999, "goto": {"week": 5, "column": 3}}]},
    {"id": "ET3", "afterWeek": 5, "windowDays": 2,
     "routing": [{"max": 45, "action": "repeat", "targetWeek": 5},
                 {"max": 50, "goto": {"week": 6, "column": 1}},
                 {"max": 60, "goto": {"week": 6, "column": 2}},
                 {"max": 99999, "goto": {"week": 6, "column": 3}}]}
  ],
  "finalTest": {"afterWeek": 6, "restDaysBefore": 2, "goal": 100,
    "advice": "Do ten at a time; good form; don't hold your breath.",
    "onFail": "Repeat Week 5 or 6, then retest."}
}
```

*Note: sets are stored as `[col1, col2, col3]` per set row; `isPlus` marks the `+` sets (always the last set of a day).*

### 4.1 Local state (persisted)
- `profile`: `{name, age, weightKg?, sex}` collected at registration (§3.1 step 2), editable in Settings.
- `programState`: current `{week, day, column}`, list of completed workouts/tests, flags for repeated weeks.
- `schedule`: 3 `{weekday, hour, minute}` slots + notification prefs.
- `session` (transient + crash-recoverable): current set index, rep count, rest-timer remaining.
- History records: `{type: workout|test, date, week?, day?, column?, sets:[...], totalReps, maxReps}`.

---

## 5. Local notifications

Requirement: notify the user **locally** (no server) when a workout (or due test) is scheduled.

- **Scheduling:** when a workout is completed or the schedule changes, (re)compute the next 3 event datetimes (next occurrences of the user's weekday slots, skipping rest periods) and register them. Also register a day-before evening reminder if enabled.
- **iOS:** `UNUserNotificationCenter` with `UNCalendarNotificationTrigger`. Request `.provisional` then full authorization. Handle delivery in foreground via `willPresent`.
- **Android:** `AlarmManager` with `setExactAndAllowWhileIdle` → `BroadcastReceiver` → Notification (needs `SCHEDULE_EXACT_ALARM` on 12+, `POST_NOTIFICATIONS` runtime permission on 13+, `RECEIVE_BOOT_COMPLETED` to re-register after reboot). Do **not** rely on FCM.
- **Content examples:** "💪 Workout due: Week 3 · Day 2 — 14 minutes estimated." / "Exhaustion test due — it decides your Week 5 column."
- **Tap action:** deep-link into the workout/test screen.
- **Re-registration triggers:** app launch, schedule edit, workout completion, device reboot (BootReceiver), timezone change (`ACTION_TIMEZONE_CHANGED`), and every reprogramming event (missed/incomplete workout moved to a new slot — see §10).
- Reschedule silently if the user missed a slot by >24 h (move to next slot, no nagging); a "missed workout" card appears on Home instead.

---

## 6. Rest timer & session timing

- Timer runs **on-device**, foreground-first; keep the session screen with a foreground service / `WKExtendedRuntimeSession`-style keep-alive so the timer survives screen-off on both platforms (declare as fitness session).
- Countdown display + optional ticking sound in the last 3 s; vibrate at 0.
- Presets come from the day data (45/60/90/120 s). **+15 s** extends; **Skip** enabled only after the prescribed time has elapsed. Extensions are logged (for stats, optional).
- Screen wake-lock during active session; auto-lock allowed only between sets if the user enables it.
- Crash/interruption: persist `session` every rep; on relaunch offer **Resume** (remaining rest time recomputed from wall clock) or **Restart set**.

---

## 7. Validation rules (must not allow)

- Scheduling two workouts on consecutive days (warn, don't block).
- Advancing to the next week without completing all 3 days of the current week (must offer "repeat week" flow instead).
- Advancing past Week 2 / 4 / 5 without recording the exhaustion test result.
- Column changes mid-week (fixed per week; changes only at week boundaries via test routing or manual override).

---

## 8. Edge cases

- User does the initial test mid-week: schedule from the next chosen slot.
- Repeating a week N times: allowed; history keeps all attempts; stats show best attempt.
- Exhaustion test taken outside the 2-day window: allowed, but show a hint that results map better within the window.
- Final test <100: offer "Repeat Week 5" / "Repeat Week 6" / "Retest now".
- Timezone/travel: all datetimes stored in local time; recompute on timezone change.
- Program data update (`program_v2.json`): migrate user's current position; never silently change completed history.

---

## 9. Tech & implementation notes

- **Framework:** Flutter or React Native acceptable; native modules needed for exact alarms (Android) and extended runtime (iOS watch/phone). Recommended: Flutter + `flutter_local_notifications`, `android_alarm_manager_plus`, `wakelock`.
- **Storage:** SQLite (drift/sqflite) or Hive for state + history; JSON asset for program data.
- **Permissions to declare:** notifications, exact alarms (Android 12+), POST_NOTIFICATIONS (Android 13+), RECEIVE_BOOT_COMPLETED, foreground service (type `health`/`dataSync`).
- **Accessibility:** minimum tap target 48dp, haptic + audio feedback optional, dynamic type support.
- **Testing:** unit tests for routing logic (all test result → column mappings), timer accuracy, reschedule-on-reboot; widget tests for session screen.

---

## 10. Progress tracking, missed/incomplete workouts & reprogramming

### 10.1 Persistence

All progress is stored **locally only** (no account, no cloud), in a relational database:

- **iOS/Android:** SQLite (drift/sqflite in Flutter). Export/import of the whole DB as a file is offered in Settings (CSV per table and a full JSON backup).
- Every mutation is written immediately (transactional), so force-killing the app never loses more than the current rep tap.

**Schema (core tables):**

```
user(id, created_at, name TEXT, age INT, weight_kg REAL NULL, sex TEXT /* female|male|other|unspecified */,
     days_of_week TEXT /* e.g. "[1,3,5]" */, time_of_day TEXT /* "18:00" */, notif_enabled INT)

scheduled_slot(id, due_at, week INT, day INT, kind TEXT /* workout|exhaustion|final_test */, status TEXT /* pending|done|missed|rescheduled|skipped */, attempt_of_day INT)

workout(id, scheduled_slot_id, week INT, day INT, column INT, status TEXT /* completed|incomplete|abandoned */, started_at, finished_at, repeat_flag INT)

workout_set(id, workout_id, set_index INT, prescribed INT, is_plus INT, performed INT NULL /* null = not attempted */, rest_extended_sec INT DEFAULT 0)

test(id, kind TEXT /* initial|exhaustion|final */, scheduled_slot_id NULL, result INT, taken_at, routing TEXT /* JSON: computed next week/column or repeat */)
```

### 10.2 Workout outcomes & how each is saved

| Outcome | How it's saved | What happens next |
|---|---|---|
| All sets finished | `workout.status = completed`; day marked done in slot | Next day of the week is scheduled; after Day 3 → exhaustion-test slot if due |
| User saves and exits mid-workout | `status = incomplete`, finished sets recorded, remaining sets `performed = null` | The **same** workout is reprogrammed into the next workout slot; "Resume" offered from that slot (skip sets already done, or option to redo the day from scratch) |
| Slot passes with no activity (no start by slot end + 12 h grace) | Slot marked `missed`; no workout row created (or `abandoned` if started and never saved) | The **same** workout day is reprogrammed into the next workout slot; a catch-up card appears on Home |
| User explicitly skips a slot | Slot marked `skipped` | Same reprogramming as missed; one-tap "undo skip" within 24 h |
| Week failed/struggled | `repeat_flag = 1` on completed workouts of that week | User confirms repeat → same week is re-generated with `attempt_of_day` incremented |

**Reprogramming rules:**
1. Missed/incomplete work always moves to the **next scheduled workout slot** of the user's chosen days (never the same day, never a rest day).
2. If the next slot already has pending work, the queue is FIFO: the app shows "2 workouts queued" and works them off in order (oldest first). A slot can hold at most one queued backlog item visibly; deeper backlog collapses into a count.
3. Reprogramming **shifts the whole plan**, not just one day: subsequent days/weeks and any due exhaustion test move along with it. The 6-week program becomes "6 weeks of workouts", calendar-time decoupled.
4. Every reprogramming re-registers local notifications (see §5) and updates the Home countdown.
5. Exhaustion-test slots are reprogrammed the same way, with a hint that results map best within the 2-day window.
6. History never rewrites itself: missed/incomplete records stay in the log; only future slots move.

### 10.3 Progress screen (available at any time)

Entry points: Home ("View progress"), nav bar, and end-of-workout summary. Shows:

- **Header stats:** program % complete (workouts done / total workouts incl. repeats), current week/day/column, total pushups all-time, best single set, best max-reps test.
- **Progress graph** (required): line chart of **max consecutive pushups over time** — one point per recorded test (initial, exhaustion ×3, final) plus best `+` set per workout shown as secondary dots; week gridlines. Tap a point for details (date, context, week/day).
- Secondary chart (toggle): total reps per calendar week (bar).
- **Timeline/log:** reverse-chronological list of every event — tests, completed days, incomplete days (with "3/5 sets"), missed slots, repeats — each row filterable by type.
- Incomplete/missed items link directly to their reprogrammed slot ("do it Thu 18:00 → Start").

Implementation notes: charts from `workout_set` + `test` tables; both charts must render from local data with zero network. Screenshot/share of the graph image is a nice-to-have (native share sheet).

---

## Appendix A — Full program tables

*(Canonical data; mirrors `100-pushups-program.md`. "+" = minimum reps, then as many more as comfortable. Rest = seconds between sets.)*

### Initial test → Week 1 column
≤5 → C1 · 6–10 → C2 · 11–20 → C3 · >20 → start Week 3 (C2 if ≤30, C3 if >30)

**Week 1** (columns: <5 / 6–10 / 11–20)
- Day 1, rest 60s: 2/6/10 · 3/6/12 · 2/4/7 · 2/4/7 · **3+/5+/9+**
- Day 2, rest 60s: 3/6/10 · 4/8/12 · 2/6/8 · 3/6/8 · **4+/7+/12+**
- Day 3, rest 60s: 4/8/11 · 5/10/15 · 4/7/9 · 4/7/9 · **5+/10+/13+**

**Week 2** (columns: <5 / 6–10 / 11–20)
- Day 1, rest 60s: 4/9/14 · 6/11/14 · 4/8/10 · 4/8/10 · **6+/11+/15+**
- Day 2, rest 90s: 5/10/14 · 6/12/16 · 4/9/12 · 4/9/12 · **7+/13+/17+**
- Day 3, rest 120s: 5/12/16 · 7/13/17 · 5/10/14 · 5/10/14 · **8+/15+/20+**

**Exhaustion Test #1** (after Week 2): 16–20 → W3C1 · 21–25 → W3C2 · >25 → W3C3 · <16 → repeat.

**Week 3** (columns: 16–20 / 21–25 / >25)
- Day 1, rest 60s: 10/12/14 · 12/17/18 · 7/13/14 · 7/13/14 · **9+/17+/20+**
- Day 2, rest 90s: 10/14/20 · 12/19/25 · 8/14/15 · 8/14/15 · **12+/19+/25+**
- Day 3, rest 120s: 11/16/22 · 13/21/30 · 9/15/20 · 9/15/20 · **13+/21+/28+**

**Week 4** (columns: 16–20 / 21–25 / >25)
- Day 1, rest 60s: 12/18/21 · 14/22/25 · 11/16/21 · 10/16/21 · **16+/25+/32+**
- Day 2, rest 90s: 14/20/25 · 16/25/29 · 12/20/25 · 12/20/25 · **18+/28+/36+**
- Day 3, rest 120s: 16/23/29 · 18/28/33 · 13/23/29 · 13/23/29 · **20+/33+/40+**

**Exhaustion Test #2** (after Week 4): 31–35 → W5C1 · 36–40 → W5C2 · >40 → W5C3 · <31 → repeat W3/W4.

**Week 5** (columns: 31–35 / 36–40 / >40)
- Day 1, rest 60s: 17/28/36 · 19/35/40 · 15/25/30 · 15/22/24 · **20+/35+/40+**
- Day 2, rest 45s: 10/18/19 · 10/18/19 · 13/20/22 · 13/20/22 · 10/14/18 · 10/14/18 · 9/16/22 · **25+/40+/45+**
- Day 3, rest 45s: 13/18/20 · 13/18/20 · 15/20/24 · 15/20/24 · 12/17/20 · 12/17/20 · 10/20/22 · **30+/45+/50+**

**Gate to Week 6** (after Week 5 test): >45 → proceed; else repeat Week 5.
**Exhaustion Test #3 routing (into Week 6):** 46–50 → W6C1 · 51–60 → W6C2 · >60 → W6C3 · ≤45 → repeat.

**Week 6** (columns: 46–50 / 51–60 / >60)
- Day 1, rest 60s: 25/40/45 · 30/50/55 · 20/25/35 · 15/25/30 · **40+/50+/55+**
- Day 2, rest 45s: 14/20/22 · 14/20/22 · 15/23/30 · 15/23/30 · 14/20/24 · 14/20/24 · 10/18/18 · 10/18/18 · **44+/53+/58+**
- Day 3, rest 45s: 13/22/26 · 13/22/26 · 17/30/33 · 17/30/33 · 16/25/26 · 16/25/26 · 14/18/22 · 14/18/22 · **50+/55+/60+**

**Final Test** (after Week 6, 1–2 rest days before): max good-form pushups; goal 100. On failure: repeat Week 5 or 6 and retest.

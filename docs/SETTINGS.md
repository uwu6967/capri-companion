# All companion settings and controls

Open the CET overlay, then **Capri Companion**. Edits save automatically. Settings live at `bin/x64/plugins/cyber_engine_tweaks/mods/CapriCompanionQoL/settings.json` relative to the game root.

## Adjustable in the panel

- **Random Capri chatter (subtitles)** — default **ON**. Toggles the add-on's extra exploration lines. It does not disable all original Capricorn dialogue or add voice recordings.
- **Overhead portraits and health bars** — default **ON**. Toggles the custom above-head panel. It does not switch the separate minimap marker off.
- **Helper healing (capped at 85%)** — default **ON**. Toggles this add-on's repair. Native healing from the NPC or other mods is separate.
- **Helper combat speed bursts** — default **ON**. Toggles extra short bursts. It does not remove native MaxTac abilities, permanent movement modifiers, or Sandevistan slow-motion linking.
- **Automatic attacks on ordinary combat enemies** — default **OFF**. Toggles extra automatic attacks while V's Sandevistan is active. Turning this off leaves helper speed linking enabled. Earlier preference files migrate this option to OFF after the mission-ally regression. Keep it off during missions until that fix is tested.
- **Shortest upload (seconds)** — default **1.0**, adjustable **0.5–5.0**. The lower bound for a newly selected automatic attack.
- **Longest upload (seconds)** — default **3.0**, adjustable **0.5–5.0**. The upper bound; it is raised to the lower bound if necessary. Each new automatic upload chooses a random duration within the range, using real elapsed time. Changing bounds does not retime an upload already underway.

## Buttons and optional inputs

- **Regroup / unstick:** resets only the add-on's own movement commands and target assignment; resumes following. Five-second recovery between uses. Does not teleport.
- **Pause / resume following:** a session control. Helpers can still defend V and use native AI. This is not a saved switch or a command to stand motionless.
- **Talk to Capri:** requests one subtitle when allowed by the dialogue gates.
- **Restore QoL defaults:** restores the five saved switches and both upload bounds. It does not reset your operating-system item, RAM, helper health, key bindings or inventory.

All four optional inputs are listed under CET Bindings. E and Tab remain normal game bindings. This add-on assigns none of its optional inputs automatically.

## Built-in tuning, not panel sliders

- Maximum helper count: **3**. Manual possession: **4 RAM**, **0.25-second base upload**, then **0.25-second ready delay**.
- Natural death transfer: up to **2** available replacement bodies within **30 metres** of the old body's position, limited by the three-helper total.
- Custom outgoing helper damage: **8×**. Movement-stat multiplier: **2.25×**, or **3×** for MaxTac. Attack-speed-stat multiplier: **1.75×**. Engine archetype behavior can affect the apparent result.
- Repair: wait at least **3 seconds** after observed damage, then up to **3 percentage points per update in combat**, or **6 outside combat**, capped at **85%**. Main updates are ordinarily one second apart. This does not add maximum health, armor or resurrection.
- Extra speed bursts: approximately **2 seconds**, normally **6 seconds** apart. Dilation factor **1.5**, or **1.8** for MaxTac, when another native setting does not take priority.
- Guard: return toward V beyond **14 metres**; consider combat threats within **16 metres** of V.
- Hunters: consider eligible combat NPCs within **60 metres** of themselves and **120 metres** of V, using loaded/recent references.
- Custom chatter: first idle line normally after **45–90 seconds**, then **60–120 seconds** between opportunities, subject to combat/dialogue checks.
- Apogee base duration **60 seconds**, recharge duration **5 seconds** for the tuned variants. Bonuses and other mods can change final values. See `src/apogee_capri.yaml`.

Changing built-in tuning requires editing source/tweak files and restarting; there are no hidden panel sliders for it. Some values belong to the original Capricorn mod rather than this panel. Do not assume this guide lists every upstream setting.

## Preferences and reset

The default behavior is built into `init.lua`; an example copy is unnecessary for installation. Malformed settings fall back to defaults. To reset manually, close the game, move the companion's `settings.json` aside, and restart. Keep `safetyVersion` managed by the mod; it is a migration marker, not a gameplay slider.

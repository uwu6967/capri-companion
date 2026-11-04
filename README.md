# Capri Companion QoL

Private development snapshot for the custom Capricorn possession and Apogee Sandevistan integration. **Experimental: mission-target safety is not yet verified in-game.**

Current candidate: **0.1.2-private**. The user chose private preparation after the original author's sharing permissions were checked. Nothing has been submitted to Nexus.

History: [CHANGELOG.md](CHANGELOG.md). Current limitations: [docs/KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md). Validation: [docs/VALIDATION.md](docs/VALIDATION.md).

Player documentation: [tutorial](docs/PLAYER_GUIDE.md), [every exposed setting](docs/SETTINGS.md), [FAQ](docs/FAQ.md), and [credits](docs/CREDITS.md). The [Nexus page draft](docs/NEXUS_DRAFT.md) is a preview, not a published Nexus listing. The private ZIP includes these documents.

Installed extension for this Cyberpunk 2077 setup, built November 3, 2026.

Fully quit and restart Cyberpunk after installation. Load a save, then open the CET overlay with **F11**. The **Capri Companion** window appears alongside it. This key was verified from this installation's bindings file.

## Controls

- **Regroup / unstick:** refreshes the mod's own movement orders and target selection. Helpers regroup on foot when nearby combat is over. Five-second cooldown; does not teleport or replace their native combat roles.
- **Pause / resume following:** pauses idle following. Helpers can still defend you and use their native AI; this is not an order to stand motionless.
- **Talk to Capri:** requests an original subtitle line. Respects the existing dialogue gates and cooldowns. No new voice recordings.
- **Random chatter:** enable or disable the extra exploration chatter.
- **Overhead portraits and health bars:** show or hide the custom helper display. Minimap markers stay available.
- **Helper healing:** toggle the custom repair that pauses after damage and stops at 85% health. Native NPC healing, if any, is separate.
- **Combat speed bursts:** toggle the custom bursts. Native MaxTac powers and normal movement boosts remain.
- **Automatic attacks during Sandevistan:** OFF by default. Older saved preferences migrate to OFF following the mission-character incident. If explicitly enabled again, attacks require a hostile NPC actually fighting V; civilians, companions, bosses, quest-marked and immortal/invulnerable characters are excluded. The automatic force-kill fallback has been removed. Helper slow-motion immunity remains enabled independently.
- **Upload timing:** select the random automatic attack upload range, 0.5–5 seconds. Defaults remain 1–3 real seconds. New timing applies to the next upload.
- **Restore QoL defaults:** restores these switches and timings; does not change your inventory, save, or key bindings.

The panel shows candidate version, helper count, health, distance, follow mode and whether Sandevistan is active. Each living helper also reports engaging, following/guarding, waiting for a safe target, or pausing for a story scene. Drone/mech bodies are labeled separately. It draws only while the overlay is open.

## Automatic squad roles

With two or three helpers, the strongest living helper becomes the **Guard**. It returns toward you when more than 14 metres away and engages combat enemies within 16 metres of you. The other helpers become **Hunters**: they retain living combat targets and seek the next enemy after a defeat, instead of all being forced to share the guard's target.

Hunters consider actual combat enemies in the loaded area, up to 60 metres from themselves and 120 metres from you. They return on foot when no eligible targets remain. They do not search the entire world map or teleport to you. With just one helper, it acts as a hunter and follows whenever combat is clear.

Roles are chosen automatically again when bodies are gained or lost. The overhead health displays and panel show Guard/Hunter. Pausing following also suspends the guard's return-to-player behavior; combat remains available. These roles still require in-game verification after restarting.

Your bullets and melee hits deal normal weapon damage to your own eligible possessed bodies. The exception is scoped to those owned bodies and weapon hits; it does not enable automatic attacks against allies or story characters. Deaths credited to V free the helper slot without triggering a possession split. Enemy kills retain the split behavior.

Optional inputs are available under **CET > Bindings > CapriCompanionQoL**: regroup, follow toggle, talk and automatic-kill toggle. No gameplay keys are assigned automatically. Existing E, Tab and F10 controls remain available.

Settings save automatically in the installed mod's `settings.json`. OFF preferences survive restarts; malformed settings fall back to defaults.

## Files

- `src/init.lua`: the new independent CET panel.
- `src/capri_summon.reds`: snapshot of the existing possession mod plus the QoL methods and integration.
- `src/CapricornDialogue.reds`: original installed dialogue/Project Capricorn script with protection checks added to Blackwall spread and damage application.
- `src/capri_possess.yaml`: possession action and quick-upload records.
- `src/apogee_capri.yaml`: existing Apogee duration/recharge overrides (60-second base duration, 5-second recharge).
- `Install.ps1`: backs up affected files and installs this snapshot to the named game root. Existing panel preferences are preserved.
- `package-map.json`: shared source-to-game layout for the installer and archive builder.
- `tools/build_private.py`: builds a verified private test ZIP; it does not support public publishing.
- `tests/test_panel.py`: LuaJIT checks with a mocked game API.

This project depends on the installed original Capricorn scripts, custom green archives, redscript, TweakXL, CET and this setup's existing frameworks. It is not a standalone replacement for the original mod. Keep all active companion sources synchronized with this project when making later changes.

The snapshot now includes the modified Capricorn YAML, Call Capri script, upstream CET integration, and the two custom green archives, in addition to the companion script and panel. Install the original Capricorn mod and required frameworks first. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for attribution and scope.

## Validation

The complete installed redscript set compiled successfully with the new QoL methods. The panel passed LuaJIT checks for loading, saved false values, range bounds, UI edits, input press/release handling, overlay input guards, reload, missing player and malformed JSON. Installed files were compared with the project source.

These checks do not verify the in-game UI or NPC behavior. A full restart and fresh possession are still required. No game launch or live input was performed for this update.

### Mission-character fix

Automatic attacks previously used a force-kill fallback and could select a mission ally through helper combat relationships. After the report that E killed the president, the fallback was removed and the automatic attack default was changed to OFF. Extra target checks now apply at selection and completion, to helper targeting/damage, possession, and Project Capricorn spread/damage. These checks rely on the game's flags, allegiance and protection states; the fix is compiled but is not yet mission-tested.

This update does not undo any NPC death already recorded in a save. Restart and load a checkpoint from before that death. Do not overwrite that checkpoint while checking the fix.

A subsequent report that helpers were shooting the president prompted record-level identity and mission checks, Myers/Rosalind/president identity exclusions, threat cleanup, and a final helper damage-stage check. The November 4 candidate separates weapon combat from possession: generic hostile mission enemies may be helper weapon targets during an active fight even when quest-marked. Persistent story identities, companions, civilians, children, immortality/invulnerability and current friendly allegiance still block helper attacks. Possession and automatic Blackwall keep their stricter quest exclusions. Protection alone no longer makes an enemy friendly. This is compiled but still requires an in-mission replay after restart and fresh possessions.

Run panel checks with:

```powershell
uv run --with lupa python .\tests\test_panel.py
```

Other checks and the private build:

```powershell
python -m unittest discover -s tests -p test_package.py -v
.\tests\test_installer.ps1
.\Install.ps1 -WhatIf
python .\tools\build_private.py
```

The installer fixture tests use a temporary fake game folder; they do not launch a game. The private ZIP is written under `dist/private/` with an adjacent checksum file. A real installation requires the original Capricorn archive and installed frameworks, stops if Cyberpunk is running, backs up all affected files first, and verifies each written file. A failed write triggers rollback of files already touched. See [docs/PERFORMANCE.md](docs/PERFORMANCE.md) and the unpublished [Nexus description draft](docs/NEXUS_DRAFT.md).

Pre-update companion backup:
`E:\SteamLibrary\steamapps\common\Cyberpunk 2077\_redscript_update\capri-qol-backup-20261103-023814\capri_summon.reds`

To roll back this addition, close the game, restore that script and move the `CapriCompanionQoL` CET folder out of `mods`. Preserve its settings if you plan to reinstall. Do not remove the original Capricorn mod or its assets.

The panel follows CET's official [overlay UI](https://wiki.redmodding.org/scripting-cyberpunk/cyber-engine-tweaks/cet-functions/events/onoverlayopen) and [input registration](https://wiki.redmodding.org/scripting-cyberpunk/cyber-engine-tweaks/cet-functions/hotkeys/registerinput) APIs.

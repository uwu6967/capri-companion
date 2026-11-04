# Unpublished Nexus description draft

**Status: private preparation only. Do not submit this page or archive.** The user confirmed that the original author's permission has not been obtained. Mission safety also remains unverified.

## Working title

Capri Companion — Possession Squad and Sandevistan QoL

## Short description

An experimental add-on for Project Capricorn with up to three possessed helpers, guard/hunter squad roles, green companion displays, and Sandevistan integration with adjustable controls.

Player documentation: [step-by-step tutorial](PLAYER_GUIDE.md), [all settings](SETTINGS.md), [FAQ](FAQ.md), and [credits](CREDITS.md).

## Description draft

Build a small Capri-controlled squad from eligible enemy bodies. Helpers can act as a guard or hunters, regroup on foot, recover from stalled movement, and keep pace during V's Sandevistan. A separate companion panel provides follow controls, subtitle chatter, health information and adjustable automatic-attack timing.

The current private build contains:

- Up to three helpers; natural deaths can transfer into up to two available enemy bodies.
- Automatic guard/hunter assignment and on-foot following.
- Damage and movement boosts, capped repair, and combat speed bursts.
- Green overhead portraits, live health bars, aura and minimap integration.
- Player weapon damage to owned eligible helpers, without death-transfer splitting on V's kills.
- Apogee duration/recharge overrides and helper slow-motion linking.
- A CET control panel with optional inputs and saved preferences.

Automatic Sandevistan attacks default OFF following a mission-ally targeting regression. Current protections are compiled but have not yet been verified by replaying the affected mission. This draft must not describe the build as mission-safe or stable.

## Dependencies and credits

Requires the original [Capricorn — Your AI powered Cyberdeck](https://www.nexusmods.com/cyberpunk2077/mods/36701) by ARandomSomeone22 and the frameworks required by the installed version, plus this setup's multi-operating-system support where applicable. The original mod's scripts/artwork are not presented as newly authored here.

## Installation and first helper

1. Fully close the game. Preserve a known working checkpoint and back up the files that will be replaced.
2. Install the original Capricorn mod and required frameworks. Confirm the base setup works first. The full dependency links are in the tutorial.
3. For the current personal-test snapshot, use the backing-up installer from the project. The alternative ZIP has `archive`, `bin` and `r6` folders that merge into the game root; manual extraction does not back files up.
4. Restart and equip Capricorn. For simultaneous Sandevistan use, configure compatible extra operating-system slots separately; they are not included here.
5. Scan a living eligible enemy and choose **Capri: Possess** with at least four RAM. Test outside missions first. The current cap is three helpers.
6. Open the CET overlay and find **Capri Companion**. Use your assigned CET overlay key; F11 is the original owner's setting, not a universal default.

This snapshot replaces matching upstream files. A clean mod-manager installation is not certified. Updating requires a full restart and fresh possessions. Restoring an earlier checkpoint is necessary for mission deaths already saved.

## Every adjustable panel setting

- **Random Capri chatter:** ON by default; extra exploration subtitles, not recorded voice audio.
- **Overhead portraits and health bars:** ON by default; does not toggle minimap markers.
- **Helper healing:** ON by default; custom repair pauses after damage and caps at 85% health.
- **Helper combat speed bursts:** ON by default; native powers and the slow-motion link are separate.
- **Automatic Sandevistan attacks:** OFF by default after the mission-ally regression. Keep OFF for missions until protections have been tested. Disabling it does not disable helper slow-motion immunity.
- **Shortest automatic upload:** 1.0 seconds by default; adjustable from 0.5 to 5.0.
- **Longest automatic upload:** 3.0 seconds by default; adjustable from 0.5 to 5.0 and never below the shorter bound. Each new upload picks a random real-time duration within the selected range.

Settings save automatically. The panel includes **Restore QoL defaults**. No advanced health, damage, duration or recharge sliders are implied; the next section describes fixed tuning.

## Companion buttons and bindings

- **Regroup / unstick:** refresh movement orders, resume following and return on foot when combat clears. Five-second cooldown; no teleport.
- **Pause / resume following:** stop idle following while retaining defensive/native combat. This is not a rigid stand-still command.
- **Talk to Capri:** request an original subtitle line subject to dialogue cooldowns.
- Optional bindings: regroup, follow toggle, talk and automatic-attack toggle under CET Bindings. No E/Tab/F10 replacement is assigned automatically.

## Built-in balance and behavior

- Manual possession costs four RAM with a 0.25-second base upload and 0.25-second ready delay.
- Three helpers maximum. Natural deaths can transfer into two nearby eligible bodies if slots are free; V's kills do not split.
- Strongest eligible helper guards V when the squad has two or three members. Other helpers hunt nearby combat enemies. A single helper fights first, then follows.
- Guard return range: 14 metres. Nearby guard threats: within 16 metres of V. Hunter limits: 60 metres from the helper and 120 from V, using loaded/recent enemies.
- Damage multiplier: 8×. Movement stat: 2.25×, or 3× for MaxTac. Attack-speed stat: 1.75×. Native archetype behavior affects the apparent result.
- Repair waits three seconds after observed damage, then restores up to three percentage points per combat update or six outside combat, capped at 85%. No added maximum health or armor.
- Short extra combat bursts last about two seconds, normally six seconds apart, subject to native time-dilation settings.
- The Apogee tweak sets a 60-second base duration and five-second recharge duration. Perks/attributes/other mods can affect final values. These are file settings, not companion-menu sliders.

## Compatibility and known limitations

The current candidate has passed script compilation and panel/package/installer logic checks on the development setup. That is not certification across game patches or proof of live mission safety.

The president was killed by an earlier automatic attack version and was later attacked by helpers. The direct automatic force-kill fallback was removed, target checks were tightened, protected ally threats are cleared and helper damage is checked again at the final damage stage. The November 4 candidate permits weapon combat against ordinary hostile quest-affiliated enemies while retaining the stricter possession/automatic Blackwall filters and persistent-identity protections. Protection no longer assigns friendship. These changes remain unverified in the affected mission; named/persistent enemies may still be excluded.

Native NPC pathfinding can still stall. The add-on has recovery and regroup controls, but not every archetype is a purpose-built companion. The final aura/minimap presentation, weapon-safe behavior and combined-OS timing require fresh runtime checks. Read the linked FAQ before testing.

## Uninstall and reporting

Close the game and restore overwritten upstream files from your backup. Remove only addon files identified in the package map. Do not delete shared frameworks or entire unrelated mod folders. The tutorial contains the detailed sequence.

For a bug report, provide game/framework versions, steps to reproduce, fresh versus existing possession, whether Sandevistan was active, and a screenshot or clip. Do not include credentials or entire personal game folders.

## Credits

Original Capricorn code, systems and artwork: **ARandomSomeone22**. Custom direction and testing reports: **uwu6967**. Companion/QoL additions, generated green visual variant, packaging and documentation: AI-assisted development with Codex/ChatGPT. Cyberpunk 2077 and its native resources: **CD PROJEKT RED**. Framework authors and WolvenKit contributors are linked in [CREDITS.md](CREDITS.md).

The work is unofficial. Newly written chatter is fan text, not official anime dialogue. Attribution is not a substitute for permission; the current combined files are not cleared for redistribution.

## Permissions status

The original Nexus page requires author permission for modification and asset reuse. The user has not obtained that permission and requested private preparation. The current archive includes modified upstream files and derived visual materials, so it must remain private. No Donation Points or redistribution rights are asserted.

## Before a public release

Obtain the required upstream permissions or rebuild the package around independently distributable material. Replay the president mission, verify helper and automatic-target exclusion, test own-helper shooting/melee, validate fresh installation and rollback on a supported game version, and capture real gameplay screenshots. Update this draft using those results, including any remaining limitations.

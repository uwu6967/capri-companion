# Change log

This log documents the custom Cyberpunk mod work discussed before this repository was created, followed by current updates. Earlier entries are reconstructed from the conversation and available source snapshots; they are not a fabricated sequence of Git commits. `0.1.0-dev` names the first repository snapshot, not a stable release.

## 2026-11-03 — President/mission-ally targeting mitigation

**Reported:** E-triggered automatic attacks killed the president during a mission. A later report showed helpers also shooting her. Both are real regressions; previous compilation success did not prove mission safety.

- Removed the automatic Sandevistan action's direct force-kill fallback.
- Automatic attacks now default to OFF. Old preference files that enabled them migrate to OFF through safety-settings version 2.
- Automatic selection and completion require a hostile NPC actively fighting V; bosses, companions, civilians and protected NPCs are excluded.
- Added quest flag, immortality, invulnerability and companion checks to possession, helper targeting and Project Capricorn spread/damage.
- Added record-level persistent identity and main/side-quest affiliation exclusions after the separate helper-targeting report.
- Added identity checks containing Myers, Rosalind or president in available character record information.
- Protected nearby allies are removed from helpers' threat trackers; their pairwise attitudes become friendly, and invalid combat targets are cleared.
- Added a second damage check immediately before helper damage is dealt, so a retained native shoot order does not bypass target eligibility.
- Preserved targeted player weapon damage to owned summons while keeping story characters protected.

**Validation:** complete installed redscript compilation passed; LuaJIT panel tests passed, including old preference migration. **Not verified:** president mission, retained AI shoot orders in live play, or NPC allegiance after loading an affected save. An earlier checkpoint is required for deaths already saved. Conservative filtering may also exclude mission enemies.

## 2026-11-03 — Player shots and melee against summons

- Changed player weapon hits on owned, eligible possessed bodies to use the normal damage pipeline and their health bars, rather than instant dismissal on any hit.
- Scoped the friendly-fire exception to player ranged, melee and thrown weapon hits on a body recorded as eligible when possessed.
- Kept story-character exclusions; did not enable global damage to allies.
- Use the game's recorded killer to distinguish V's helper kills from enemy kills. V's kills free the slot without death-transfer multiplication.
- Existing prevention hooks remain scoped to the helper attitude group.

**Validation:** compiled. Weapon-safe animation behavior, damage and kill attribution still need a fresh in-game test.

## 2026-11-03 — Automatic guard and hunter roles

- With at least two living helpers, the strongest eligible body becomes the Guard.
- The Guard returns toward V beyond 14 metres and considers combat enemies within 16 metres of V.
- Other bodies act as Hunters with independent targets. They finish eligible fights rather than sharing the guard's target.
- Hunters consider actual combat enemies within 60 metres of themselves and 120 metres of V, using loaded NPCs and recent enemy references.
- With one helper, it fights first and follows when combat is clear.
- Added Guard/Hunter labels to overhead displays and the control panel. Widened the label text area.
- Pause-following mode also suspends guard return behavior.

**Validation:** compiled; squad behavior and distances not yet tested in-game.

## 2026-11-03 — Capri Companion QoL panel and project

- Created this project and an independent `CapriCompanionQoL` CET mod.
- Added Regroup/unstick, pause/resume following and Talk to Capri controls.
- Added a live helper count, health, distance, following and Sandevistan summary.
- Added switches for exploration chatter, overhead displays, custom healing, speed bursts and automatic Sandevistan attacks.
- Added adjustable automatic upload bounds, persisted preferences, defaults restoration and validation of damaged/out-of-range settings.
- Added optional inputs without assigning or replacing gameplay keys. Inputs ignore release events and are suppressed while editing the overlay.
- Added a backing-up installer, LuaJIT tests, usage documentation and a project snapshot.
- Verified the installed overlay binding was F11. This is specific to the original installation.

**Validation:** redscript compiled. LuaJIT tests cover loading, saved OFF values, bounds, controls, preference reload, missing player, damaged JSON and later safety migration. Installer syntax checked; panel source matched its installed copy. In-game UI appearance remains unverified.

## 2026-11-03 — Following and stuck-helper recovery

- Added idle on-foot following, with teleport disabled and explicit command ownership/cleanup.
- Removed the five-minute idle timeout that previously killed idle helpers.
- Corrected follow commands so a stale combat flag does not permanently block following.
- Stopped rewriting an unchanged combat target every second.
- Added recovery after stalled movement: retry following or issue a brief navigated approach, then return control to native combat AI.
- Added an inactivity allowance for ranged helpers; holding position while dealing damage is not treated as a stall.
- Excluded defeated/unconscious/otherwise finished targets from enemy selection.
- Skip ordinary companion updates while dead or in menus.

**Validation:** compiled; navigation, recovery and authored AI conflicts remain runtime checks.

## 2026-11-03 — Sandevistan helper synchronization and pacing

- Added short real-time helper dilation overrides during V's Sandevistan.
- Corrected the link to examine actual slowdown/global-dilation immunity rather than skipping every NPC with an existing individual setting.
- Preserve already-fast immune bursts and reapply the normal-speed link when needed.
- Corrected owned dilation cleanup to use the native ease-out parameter correctly.
- Replaced rapid automatic attack application with native Project Capricorn-style upload effects.
- Subsequently shortened automatic uploads to a random 1–3 real seconds, removing the extra one-second inter-target pause.
- Drive the upload's displayed progress and deadline from real elapsed time so Sandevistan does not stretch it into a long wait.
- Added completion/cancellation guards and pending-action ownership checks.
- Removed the later direct automatic force-kill fallback after the president incident; ordinary effect outcomes can therefore differ from the old instant-kill version.

**Validation:** compiled. Timing, effects, queue cleanup and ally exclusion need in-game verification.

## 2026-11-03 — Fast possession, split transfer and power balance

- Set Capri: Possess to a 0.25-second base upload and a 0.25-second ready delay.
- Set the current Capri helper cap to three across the supported deck records.
- Natural helper death can take over up to two eligible nearby enemies, filling available slots without exceeding three.
- Rank replacement bodies by MaxTac/boss preference and native health/armor, with distance as a tie-breaker. Keep living helpers.
- Damage boost remains 8×. Increased movement boosts to 2.25× generally and 3× for MaxTac; attack-speed boost to 1.75×.
- Added short two-second combat speed bursts, normally six seconds apart, preserving native abilities when another dilation is active.
- Removed the earlier huge bonus health/armor and continuous healing.
- Added repair after a three-second damage pause: 3 percentage points per tick in combat or 6 outside it, capped at 85% health. No resurrection or bonus maximum health.
- Retained native combat roles and MaxTac loadouts instead of replacing roles or equipping a fallback pistol on MaxTac.

**Validation:** compiled. NPC attack-speed response, native abilities, split transfer, repair and killability remain runtime checks.

## 2026-11-03 — Apogee configuration and dialogue integration

- Identified the equipped item as Militech Apogee, including Plus and PlusPlus records.
- Set its base duration records to 60 seconds and recharge-duration records to 5 seconds, keeping partial-charge activation behavior.
- Reverted an earlier broad duration multiplier on the separate custom 99% Sandevistan.
- Added multi-operating-system Capricorn lookup so deck abilities remain discoverable alongside Sandevistan through the installed CyberwareEx setup.
- Added fan-written Capri subtitles for possession, multiple bodies, death transfer, Sandevistan linking and dismissal.
- Added randomized exploration chatter, dialogue cooldown checks and a manual request in the later panel. New dialogue is text, not newly recorded voice audio.

**Validation:** record names/types were checked against the installed tweak database; scripts compiled. Attribute bonuses may affect displayed final duration. Combined-OS behavior remains an in-game check.

## Earlier development — Possession and visual parity

- Implemented Capri: Possess in the scanner, initially correcting a missing scanner entry.
- Kept manual possession targeted to the selected NPC, with four RAM per cast and helper capacity reporting.
- Added separate helper attitudes, mutual friendship, friendly-fire prevention and threat cleanup to address summons shooting each other.
- Replaced an ineffective NPC damage-stat approach with multiplication of resolved outgoing helper damage.
- Added green Capri portrait assets based on the supplied/reference Capricorn artwork.
- Implemented an always-visible overhead portrait, name and live health bar using the existing NPC stealth marker. User screenshots confirmed this display appeared outside Tab.
- Added a green looping body aura based on a native Blackwall upload effect and moved its origin upward after observing it at the feet.
- Added custom green minimap portraits through existing minimap markers.
- Fixed unsupported minimap API usage during compilation by using a separate child image instead of reading back an unsupported atlas property.
- Parked an earlier generic-effect/custom-world-mappin attempt after a save-load crash. That rolled-back archive is not part of this project.

**Validation boundary:** some overhead display appearance was demonstrated by screenshots; the final aura, minimap and later changes are not collectively verified by those older screenshots.

## Related installation maintenance recorded in the conversation

- Restored base Virtual Car Dealer and Enhanced Craft resource archives/XL files after missing-resource warnings; did not restore all addons.
- Kept incompatible NamedSaves components disabled for the installed patch.
- Kept a quest/world archive pack parked after mission freezes; did not restore it wholesale.
- Preserved the redscript compiler stack-size patch and compiled into temporary caches rather than replacing the vanilla cache during checks.
- These installation-level changes are context only; this repository does not include those third-party mods, the game cache/compiler, whole saves, crash reports, account credentials or the complete game directory.

## Ongoing logging

Every future change should add a dated entry describing behavior, reason, verification and remaining runtime checks. Record regressions and reversals as well as additions. Use Git commits for actual changes from repository creation onward; do not invent historical commits for earlier work.

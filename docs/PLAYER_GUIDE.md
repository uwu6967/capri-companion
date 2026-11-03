# Capri Companion — player tutorial

**0.1.1-private: personal test candidate, not a public release.** Mission-ally protection is implemented but not verified in the president mission. Automatic Sandevistan attacks default OFF. Do not treat this as a stable, mission-tested download.

## What you need

Cyberpunk 2077 with Phantom Liberty, the original [Capricorn mod](https://www.nexusmods.com/cyberpunk2077/mods/36701), and its required frameworks. Install framework versions that support your game version, following their own instructions. This snapshot was compiled against the owner's installed setup; it does not claim compatibility across all patches.

The upstream requirements page lists [RED4ext](https://www.nexusmods.com/cyberpunk2077/mods/2380), [redscript](https://www.nexusmods.com/cyberpunk2077/mods/1511), [TweakXL](https://www.nexusmods.com/cyberpunk2077/mods/4197), [ArchiveXL](https://www.nexusmods.com/cyberpunk2077/mods/4198), [Codeware](https://www.nexusmods.com/cyberpunk2077/mods/7780), [Cyber Engine Tweaks](https://www.nexusmods.com/cyberpunk2077/mods/107), [Input Loader](https://www.nexusmods.com/cyberpunk2077/mods/4575), [Mod Settings](https://www.nexusmods.com/cyberpunk2077/mods/4885), and [Audioware](https://www.nexusmods.com/cyberpunk2077/mods/12001). Check the current upstream page for changes.

Having Capricorn and a Sandevistan equipped together also requires a working multi-operating-system setup such as the owner's installed CyberwareEx. This package does not include that mod or enable extra equipment slots by itself.

## 1. Back up and install

1. Fully quit Cyberpunk. Keep a save from before testing these changes. If a mission character was already harmed, use an earlier checkpoint; installing files cannot undo a saved NPC death.
2. Install the original Capricorn mod and its dependencies first. Check that the unmodified base mod works before adding this snapshot.
3. Locate your game root: the folder containing `archive`, `bin`, `engine` and `r6`. For Steam, use the game's **Manage > Browse local files** option.
4. Prefer the project's `Install.ps1` for personal testing. It checks prerequisites, backs up matching files before overwriting, preserves the companion settings file and verifies the installed files. A failed write triggers rollback. If you use a different game location, pass it through `-GameRoot`.
5. The private game-layout ZIP is an alternative: back up every matching file first, then merge its `archive`, `bin` and `r6` folders into the game root. Do not extract them inside another `r6` folder. This manual route does not create backups for you.
6. Launch normally and let scripts compile. If a compilation error appears, stop and restore the backed-up files rather than saving a session without working scripts.

This build replaces matching Capricorn scripts/configuration. Other mods or future upstream updates replacing the same files can conflict. Do not install multiple copies of the companion script. A clean Vortex install has not been verified; the original Capricorn author recommends manual installation.

## 2. Equip Capri

Obtain and equip the Capricorn cyberdeck using the original mod's acquisition instructions. This add-on does not bypass the base mod's quest requirements automatically. The installed snapshot recognizes Capricorn, Capricorn Plus and Capricorn PlusPlus, with a hard three-helper cap.

For the Sandevistan link, keep Capricorn equipped alongside the Sandevistan using the supported multi-OS setup. A Sandevistan by itself does not give the player this add-on's possession ability.

## 3. Possess your first helper

1. In ordinary free gameplay, hold the scanner key (Tab with the owner's keyboard bindings).
2. Select a living eligible enemy and choose **Capri: Possess**. The action costs four RAM and has a 0.25-second base upload.
3. Allow a short ready delay, then release the scanner. The helper is designed to show a green Capri portrait, role label and health bar. The green aura/minimap presentation still needs validation on a fresh game session.
4. If the action is locked, read its reason: lack of RAM, all three slots occupied, an already possessed body, or a protected/civilian target.

Do not test possession on important mission characters. The current conservative filter can also exclude some enemies used by main or side quests.

## 4. Let the squad work

With two or three helpers, the strongest eligible body is assigned **Guard**. It stays closer to V and engages nearby combat threats. Other helpers become **Hunters** and retain their own targets, looking for another combat enemy when one is defeated. Hunters follow when no eligible nearby fight remains.

With a single helper, it fights first and follows when clear. Hunters search loaded/recent combat NPCs within configured local ranges, not the entire world map. There is no teleport-to-player fallback.

On a natural helper death, Capri can transfer into up to two eligible nearby enemies, with the total still capped at three. Selection favors stronger bodies. If none are available, the slot stays empty. An NPC streaming out is not treated as a death to multiply bodies.

Your own bullets and melee hits are configured to deal normal damage to eligible helpers. Deaths credited to V free the slot without splitting. Damage, kill credit and weapon-safe behavior still require a fresh in-game test.

## 5. Open the companion controls

Open the **CET overlay** with the key you assigned when setting up CET. It is **F11 on the owner's installation**, not a universal default. Look for the **Capri Companion** window alongside the overlay.

- **Regroup / unstick:** refresh owned movement orders and targets. Helpers regroup on foot when combat clears; five-second cooldown.
- **Pause / resume following:** pause idle following without disabling combat. Native AI can still move, so this is not a rigid stand-still command.
- **Talk to Capri:** request an original subtitle line. It waits for dialogue and cooldown gates; this does not add recorded voice audio.
- **Restore QoL defaults:** restore panel switches and upload timing without changing inventory, saves or key bindings.

Optional inputs can be assigned under **CET > Bindings > CapriCompanionQoL**: regroup, following, talk and automatic-attack toggle. No key is automatically taken from E, Tab or F10. See [SETTINGS.md](SETTINGS.md) for every exposed setting and default.

## 6. Sandevistan controls

Use your normal operating-system activation binding (E in the owner's setup). The helper link is designed to keep your helpers moving at normal speed during V's Sandevistan, preserving faster immune bursts when applicable.

**Automatic Capri attacks remain OFF by default.** This is independent of helper speed linking. If enabled for controlled testing, the script selects ordinary combat enemies and uses the configured randomized upload time, followed by the native Blackwall completion effect. The old direct force-kill fallback was removed, so protected/strong targets are not promised instant death.

The included Apogee tweak uses a 60-second base duration and five-second recharge duration. Perks, attribute bonuses and other mods can affect displayed behavior. These values are not sliders in the companion panel.

## Updating

Close the game, preserve your checkpoint and settings, then use the backing-up installer. It does not replace `CapriCompanionQoL/settings.json`. A full restart and fresh possessions are required after script/asset updates. Existing creatures in an already running session are not updated merely by changing files.

## Uninstalling this snapshot

1. Unequip the modded operating system/quickhacks as directed by the original Capricorn mod, then save separately and close the game.
2. Restore overwritten Capricorn files from the installer backup under `_redscript_update/capri-qol-install-*`. Deleting the modified files without restoring the original ones can break the base mod.
3. Remove only addon files that were newly introduced: the `capri_summon` script folder, `CapriCompanionQoL` CET folder, the two `capri_*.archive` files listed in `package-map.json`, and the custom possession/Apogee tweak files when they were not present before installation.
4. Do not remove shared frameworks or unrelated mod folders. Restart and use a suitable pre-test save if needed.

## Help and troubleshooting

See [FAQ.md](FAQ.md), [KNOWN_ISSUES.md](KNOWN_ISSUES.md) and [CREDITS.md](CREDITS.md). When reporting a bug, include game/framework versions, the action taken, whether this was a fresh possession, whether V's Sandevistan was active, and a screenshot or short clip. Do not share account tokens or entire personal game folders.

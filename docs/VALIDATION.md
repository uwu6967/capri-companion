# Validation record

Private candidate: **0.1.1-private**. Full installed-script compilation of the optimized candidate succeeded on November 3, 2026. The output was written into a dedicated temporary cache. Existing warnings were Codeware's duplicate inkScrollArea field and a redundant cast in StealthRC; no new compile errors remained.

Panel logic runs in LuaJIT with a mocked game API, using `uv run --with lupa python tests/test_panel.py`. Tests passed for settings defaults, persisted booleans, range clamping, malformed JSON, missing player, button/input behavior, input press/release guards, overlay guards, reload, and migration of old automatic-attack settings to OFF.

Installer tests now execute against a fake game folder: no-write preview, complete installation, payload hashes, original-file backup and preference preservation passed. An injected failure in the fourth copy verified restoration of an earlier overwritten file and removal of a newly created file. Only `-WhatIf` was run against the actual installation; the optimized main script was backed up and synchronized explicitly for compilation.

Private package tests passed for source/archive round-trip integrity, identical repeated-build bytes/checksums, unsafe path rejection and rejecting public mode. The package is not a Nexus release.

These are compile/logic/package checks. They are not an in-game test of NPC behavior, mission progression, graphics or the actual overlay rendering.

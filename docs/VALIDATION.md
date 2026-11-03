# Validation record

Latest full installed-script compilation: **2026-11-03 03:26 Europe/Oslo**, succeeded. The latest output was written into a dedicated temporary cache. Existing warnings were Codeware's duplicate inkScrollArea field and a redundant cast in StealthRC; no new compile errors remained.

Panel logic runs in LuaJIT with a mocked game API, using `uv run --with lupa python tests/test_panel.py`. Tests passed for settings defaults, persisted booleans, range clamping, malformed JSON, missing player, button/input behavior, input press/release guards, overlay guards, reload, and migration of old automatic-attack settings to OFF.

PowerShell installer syntax was checked with the PowerShell parser. The installer itself was not run against the active installation during this validation. Installed source files were synchronized explicitly from the tested snapshot.

These are compile/logic/package checks. They are not an in-game test of NPC behavior, mission progression, graphics or the actual overlay rendering.

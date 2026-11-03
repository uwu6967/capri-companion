# Known issues and current boundaries

- **Mission allies:** E-triggered automatic attacks killed the president, and helpers were later reported shooting her. Mitigations are compiled and installed, but the mission has not been replayed to verify them. Automatic attacks remain OFF by default, including migration of older preferences. Restart before testing. Load a checkpoint before any recorded death.
- **Conservative targeting:** persistent character identity and main/side-quest affiliation exclusions may also prevent helpers attacking some mission enemies. This is deliberate until target classification is checked in-game.
- **Stale native AI:** threat cleanup and final damage checks reduce consequences of old shoot orders, but native NPC AI may still briefly aim or animate shooting. Actual mission behavior is unverified.
- **Existing game session:** scripts and archives already loaded do not update merely because files change. Use a full restart and fresh possessions.
- **Own helper damage:** player weapon hits are allowed on owned eligible bodies; native weapon-safe aiming behavior and final kill credit need live verification. Story bodies remain excluded.
- **Squad behavior:** guard/hunter roles, following, pathfinding and recovery are compiled rather than proven across the game's different NPC archetypes. No teleport fallback is used.
- **Visuals:** overhead health display was seen in earlier user screenshots. Final green aura, minimap and newer role labels still need fresh checks.
- **Sandevistan:** normal-speed linking, helper bursts, real-time automatic uploads and native upload cleanup require play testing. Attribute bonuses may add to the configured 60-second Apogee base duration.
- **Dependencies:** this snapshot requires the original Capricorn mod and installed supporting frameworks. It is not a standalone mod release.

Keep a working checkpoint separate while testing. Do not mark any of these as resolved from compilation alone.

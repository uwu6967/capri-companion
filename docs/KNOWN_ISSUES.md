# Known issues and current boundaries

- **Mission allies:** E-triggered automatic attacks killed the president, and helpers were later reported shooting her. Mitigations are compiled and installed, but the mission has not been replayed to verify them. Automatic attacks remain OFF by default, including migration of older preferences. Restart before testing. Load a checkpoint before any recorded death.
- **Mission enemy targeting:** the November 4 candidate removes quest affiliation/runtime quest flags as blanket exclusions for helper weapon targets, while retaining persistent identity, ally, civilian, child and damage-protection checks. Possession and automatic Blackwall remain stricter. The targeting/friendship/damage changes compile but need an actual mission combat replay. Named/persistent enemies can still be excluded intentionally.
- **Already affected bodies:** previous builds may already have changed pairwise attitudes or left native orders behind. Changing source files cannot repair the current running session; restart and use fresh possessions or reload an earlier encounter checkpoint when validating.
- **Stale native AI:** threat cleanup and final damage checks reduce consequences of old shoot orders, but native NPC AI may still briefly aim or animate shooting. Actual mission behavior is unverified.
- **Existing game session:** scripts and archives already loaded do not update merely because files change. Use a full restart and fresh possessions.
- **Reload/defeat/transfers:** November 4 adds runtime/squad generation checks, completed-body rejection, NPC defeat attribution, temporary faction assignment/restoration, and pending automatic-attack cancellation. These are reviewed and compiled changes, not proof of save/load, nonlethal defeat, faction restoration or queue behavior in-game. Earlier saved faction changes are not automatically repaired.
- **Own helper damage:** player weapon hits are allowed on owned eligible bodies; native weapon-safe aiming behavior and final kill credit need live verification. Story bodies remain excluded.
- **Squad behavior:** guard/hunter roles, following, pathfinding and recovery are compiled rather than proven across the game's different NPC archetypes. No teleport fallback is used.
- **Visuals:** overhead health display was seen in earlier user screenshots. Final green aura, minimap and newer role labels still need fresh checks.
- **Sandevistan:** normal-speed linking, helper bursts, real-time automatic uploads and native upload cleanup require play testing. Attribute bonuses may add to the configured 60-second Apogee base duration.
- **Dependencies:** this snapshot requires the original Capricorn mod and installed supporting frameworks. It is not a standalone mod release.

Keep a working checkpoint separate while testing. Do not mark any of these as resolved from compilation alone.

See [SCENARIOS.md](SCENARIOS.md) for the reviewed edge cases and remaining live checks.

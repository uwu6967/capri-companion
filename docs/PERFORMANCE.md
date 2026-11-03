# Private optimization pass

The improvements below reduce repeated work by code inspection. No FPS gain or frame-time measurement is claimed.

- Nearby NPC enumeration is shared through a one-second snapshot instead of being repeated separately by every helper and ally-cleanup pass. A different player instance or movement over 25 metres forces an early refresh. Snapshot membership is cached; target death, attachment, allegiance and protection are rechecked when used.
- Guard ranking runs on the squad tick and when a body joins, instead of on each helper's target-selection call.
- The recent-enemy list is pruned on squad ticks and bounded to 96 weak references. Dead, detached and farther-than-150-metre references are removed.
- Idle Sandevistan checks run every 0.25 seconds rather than every 0.1 seconds. Active linking and automatic uploads keep 0.1-second checks. Actual activation can therefore take up to one idle interval to be noticed.
- NPC stream-out is distinguished from death so it does not create death-transfer duplicates.
- Temporary invulnerability is still respected as protection, but is not used to permanently assign friendly attitudes to an enemy.

The aura still updates at its existing rate. The health display and panel retain their existing refresh rates. No global AI roles, engine timings or graphics settings were changed for this pass.

Pending runtime checks: NPC scanning around fast travel/dashes, missions and crowds; time-dilation activation latency; body streaming; reference cleanup across saves; frame-time measurements with zero, one and three helpers.

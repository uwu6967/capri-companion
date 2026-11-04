# Player FAQ

## Is this a standalone replacement for Capricorn?

No. Install the original mod and frameworks first. This customized snapshot replaces some upstream files; it is not ready for redistribution without the author's permission.

## Is it safe to use in the president mission now?

Not established. Earlier versions killed or attacked the president. New target, threat and damage checks compile, but the affected mission has not been replayed to verify them. Keep automatic attacks OFF, restart, and use a checkpoint from before any harm. Installing the fix cannot resurrect a character in a saved state.

## Why does an enemy refuse possession?

The current filter excludes civilians, children, companions, quest/protected characters, some persistent identities and main/side-quest affiliations. This can exclude enemies you expected to hack. Other reasons are insufficient RAM, full helper slots, or a body already possessed.

## Why do helpers ignore mission enemies or shoot without dealing damage?

Earlier protection treated main/side-quest affiliation as a blanket weapon-target exclusion and made those NPCs friendly to helpers. It also required an enemy-versus-player/squad combat flag at damage resolution. The November 4 candidate separates weapon targeting from the stricter possession/automatic Blackwall checks, stops protection from assigning friendship, and lets helpers acquire hostile enemies during an active fight. Damage still rechecks allegiance, protected identities, immortality and scene tier. Restart and use fresh possessions to validate; this has compiled but has not yet been verified in mission combat.

## Why are some attacks no longer instant kills?

The automatic force-kill fallback was removed after the mission regression. Native Blackwall damage/effects now determine the result. This build does not promise one-hit kills on every enemy.

## Do I need to hold Tab to see the helper display?

The custom overhead display is designed to remain visible outside the scanner. Check the panel's portrait toggle, fully restart and use a fresh possession. Green aura/minimap rendering still needs current-build verification; old screenshots do not validate every later change.

## How do I open the menu?

Use the overlay key you assigned to CET. The original owner's key is F11. The companion controls are an extra CET window, not the normal pause menu's Mod Settings page.

## The helper stands still. What can I try?

Give native combat/pathfinding a moment. Check whether following is paused or the helper is holding a ranged position. Try **Regroup / unstick**, then test a fresh possession outside a mission. Recovery logic cannot guarantee every NPC archetype will behave like a purpose-built companion.

## Can I shoot and melee my own helper?

The code allows normal player weapon damage to eligible owned bodies and uses the game's killer attribution to suppress splitting on V's kills. Engine weapon-safe aiming behavior and kill credit still need live testing. This is not global friendly fire against story characters.

## Will natural death always create two more helpers?

Only if there are two eligible enemy bodies nearby and enough slots. The hard total stays three. If only one slot or one body is available, it adds one. If none are available, it adds none. Streaming out is not treated as a natural death.

## Can I use Capri and Sandevistan together?

The snapshot includes lookup support for the owner's multi-OS setup, but does not provide extra slots. Install and configure compatible multi-operating-system support separately. E uses the normal game's operating-system activation; it is not a separate summon key.

## Apogee is not showing exactly 60 seconds.

The tweak sets its base duration, not every possible final value. Attribute bonuses, perks, other tweaks and item-refresh behavior can affect the display. Fully restart before checking; compatibility beyond the installed setup is not certified.

## Compilation failed or my save will not load.

Restore this installation's backed-up files and return to the known working configuration. Do not keep layering extra copies of scripts onto a failed compile. Record the first relevant error, game version and framework versions before asking for help. Do not delete all saves or shared framework folders.

## Is Vortex supported?

A clean manager installation has not been tested. The archive uses game-root paths, but this snapshot overwrites upstream files and requires intentional conflict management. The base Capricorn author's page recommends manual installation.

## Where are credits and update history?

See [CREDITS.md](CREDITS.md), [CHANGELOG.md](../CHANGELOG.md), and [THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md). Credits do not replace the upstream author's modification/asset-use permission.

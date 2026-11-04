# Companion scenario review — 0.1.2-private

This is an offline code/data review and a plan for the next live tests. It does not certify the gameplay outcomes below. The candidate has to be loaded by a full game restart; use fresh possessions and preserve an earlier checkpoint. No quest facts, save files or native AI roles were changed during this work.

## Mission combat and protection

1. **Generic mission soldier:** hostile, active combat, MainQuest/SideQuest affiliation, no persistent identity or damage protection. Helper weapon selection/damage now allow the body. The separate possession/automatic Blackwall gates remain stricter. Code/data reviewed; actual damage and mission progression pending.
2. **Enemy not yet targeting V personally:** V is already fighting, but this enemy has no V threat entry yet. Current hostility can qualify it for helper targeting without the former circular threat requirement. Code reviewed; target acquisition pending.
3. **President, companion or persistent character:** helper weapon damage, target selection and threat cleanup retain exclusions. Friendship is assigned only for actual allies; protection alone is not allegiance. Code reviewed; president replay still mandatory.
4. **Temporarily invulnerable enemy:** do not attack through protection or assign friendliness. When the protection ends, a currently hostile combat enemy can become eligible again. Code reviewed; native phase transitions pending.
5. **Enemy becomes friendly while a bullet is in flight:** damage checks current allegiance, not the old assigned target. Friendly bodies remain excluded. Conversely, a hostile enemy does not lose all damage merely because a transient combat flag clears. Code reviewed; projectile/attitude timing pending.
6. **Story dialogue, vehicle scene or cinematic:** helper-owned follow/approach orders pause and helper damage is gated outside free gameplay. No quest command or native AI role is cancelled. Code reviewed; transitions and resumption pending.
7. **Mission says clear the area while possessed bodies remain alive:** do not change quest facts or fabricate objective completion. Native mission requirements may still depend on those original bodies. Check normal player weapon dismissal and progression on a separate checkpoint. Not established in-game.

## Bodies, damage and lifecycle

8. **Human/android without a weapon:** fallback pistol equip remains available. **Drone/mech without a handheld item:** never issue that human equip command; retain built-in weapons. Code reviewed; flying AI/navigation and combat pending.
9. **Unconscious, defeated, disabled or zero-health target:** reject before RAM charging or health refill. Do not turn a nonfunctional body into a counted, idle helper. Code reviewed; scanner/upload race pending.
10. **Owned body becomes defeated without IsDead:** remove it from living capacity, stop repair/engage work, and run terminal-body cleanup without a second forced kill. Native killer/potential-death attribution distinguishes V where available. Code reviewed; nonlethal player versus enemy defeat attribution pending.
11. **V shoots/melees a helper:** preserve normal weapon damage and the no-split path for V-attributed death/defeat. Do not infer that arbitrary quickhacks or explosions are also authorized helper-damage paths. Existing implementation plus attribution update reviewed; live final kill credit pending.
12. **Two helpers die together:** delayed attempts use current capacity and retain the maximum of three living bodies. Death transfer still rejects possession-protected mission bodies. Code reviewed; simultaneous event timing pending.
13. **Release, then start a new squad before an old transfer fires:** a squad-generation mismatch rejects the old callback. Code reviewed; live sequence pending.
14. **Body streams out:** remove ownership/modifiers and restore original faction/player attitudes when the handle remains available; do not count streaming as death or schedule multiplication. Code reviewed; streaming/reappearance and save round-trip pending.
15. **Body gains protection or another mod changes its faction:** a new durable story/quest identity relinquishes possession alive without a split; temporary immortality alone does not. Cleanup only restores the captured faction/player attitudes while it still owns the helper group. Do not overwrite a different current faction. Old builds' already-saved changes cannot be assumed repaired. Code reviewed; interoperability pending.

## Movement and time dilation

16. **No enemies:** idle following/guarding resumes within the existing distance thresholds. **Ranged helper holding a firing position:** movement alone is not proof of a stall. Code reviewed; human, MaxTac, drone and mech navigation pending.
17. **Melee helper far from its target:** keep bounded approach/recovery commands and hand control back to native combat. No teleport fallback or replacement follower AI role. Code reviewed; melee burst/chase effectiveness pending.
18. **Pause following immediately after combat:** stale combat approach cancellation runs before the paused-idle return. Code reviewed; command cancellation pending.
19. **Sandevistan starts/stops quickly:** helper speed linking remains independent from automatic attacks, which still default OFF. Link effects expire; the patch does not claim every native MaxTac dilation/burst interaction is verified. Live timing pending.
20. **Automatic upload when Sandevistan ends, a menu opens, V dies, equipment changes or the toggle is disabled:** cancellation/completion rechecks the current conditions. No queued completion should silently keep attacking afterward. Code reviewed; native upload/listener behavior pending.
21. **Another hack takes over the target upload:** do not complete or clean up the foreign upload. Code reviewed; queued/manual hack interaction pending.

## Reloads, controls and performance

22. **Player reattaches or another save loads:** startup waits for the script system and uses a new runtime generation; old polling/strike callbacks retire. Code reviewed and compiled; actual reload timing pending.
23. **CET system temporarily absent or replaced:** mocked LuaJIT checks exercise the real panel's loading gap, no-command behavior, recovery, one-time preference application, false-value persistence and restore-defaults behavior. Automated panel checks passed; this does not execute the game's NPC AI.
24. **Crowd, fast dash, three helpers or no helpers:** the NPC query is bounded to 150 metres, cached for one second, refreshed after movement over 25 metres, and recent targets remain capped at 96. Code reviewed; frame-time measurements and real streaming costs are still pending.

The panel displays `Capri 0.1.2` and a plain activity for each living body. Record that activity, the NPC archetype, mission, Sandevistan state and whether a fresh possession was used when reproducing a failure. There is no automatic diagnostic upload.

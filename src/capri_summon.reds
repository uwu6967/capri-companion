public class CapriSummonSystem extends ScriptableSystem {
// Companion controls are transient; the CET panel stores preferences separately.
public let qolConfigured: Bool;
public let qolFollowPaused: Bool;
private let qolChatter: Bool;
private let qolAutoStrike: Bool;
private let qolHealing: Bool;
private let qolBursts: Bool;
private let qolPortrait: Bool;
private let qolUploadMin: Float;
private let qolUploadMax: Float;
private let qolNextRegroupAt: Float;

public func ConfigureQOL(chatter: Bool, autoStrike: Bool, healing: Bool, bursts: Bool, portrait: Bool, uploadMin: Float, uploadMax: Float) -> Void {
  this.qolConfigured = true;
  this.qolChatter = chatter;
  this.qolAutoStrike = autoStrike;
  this.qolHealing = healing;
  this.qolBursts = bursts;
  this.qolPortrait = portrait;
  this.qolUploadMin = ClampF(uploadMin, 0.5, 5.0);
  this.qolUploadMax = ClampF(uploadMax, this.qolUploadMin, 5.0);
}

public func QOLChatterEnabled() -> Bool { return !this.qolConfigured || this.qolChatter; }
public func QOLAutoStrikeEnabled() -> Bool { return this.qolConfigured && this.qolAutoStrike; }
public func QOLHealingEnabled() -> Bool { return !this.qolConfigured || this.qolHealing; }
public func QOLBurstsEnabled() -> Bool { return !this.qolConfigured || this.qolBursts; }
public func QOLPortraitEnabled() -> Bool { return !this.qolConfigured || this.qolPortrait; }
public func QOLUploadDuration() -> Float {
  return this.qolConfigured ? RandRangeF(this.qolUploadMin, this.qolUploadMax) : RandRangeF(1.0, 3.0);
}

private func QOLCanControl(player: ref<PlayerPuppet>) -> Bool {
  return IsDefined(player) && !player.IsDead() && CapricornProjectQuickhack.IsDeckEquipped(player)
    && PlayerPuppet.GetSceneTier(player) == EnumInt(gamePSMHighLevel.SceneTier1)
    && !GameInstance.GetBlackboardSystem(player.GetGame()).Get(GetAllBlackboardDefs().UI_System).GetBool(GetAllBlackboardDefs().UI_System.IsInMenu);
}

public func QOLRegroup(player: ref<PlayerPuppet>) -> String {
  if !this.QOLCanControl(player) { return "Load your save and return to free gameplay first."; };
  if this.Count() == 0 { return "Possess someone first: scan them and choose Capri: Possess."; };
  let now = EngineTime.ToFloat(GameInstance.GetEngineTime(player.GetGame()));
  if now < this.qolNextRegroupAt { return "Regroup is recovering. Try again in a few seconds."; };
  this.qolNextRegroupAt = now + 5.0;
  this.qolFollowPaused = false;
  this.sharedTarget = null;
  let i = 0;
  while i < ArraySize(this.overclocks) {
    let state = this.overclocks[i];
    state.assignedTarget = null;
    if IsDefined(state.host) && state.host.IsAttached() && !state.host.IsDead() {
      let ai = state.host.GetAIControllerComponent();
      if IsDefined(ai) {
        if IsDefined(state.followCommand) { ai.CancelCommand(state.followCommand); state.followCommand = null; };
        if IsDefined(state.approachCommand) { ai.CancelCommand(state.approachCommand); state.approachCommand = null; };
        ai.SetBehaviorArgument(n"CombatTarget", null);
      };
      state.nextRecoveryAt = 0.0;
      state.lastMoveAt = now - 5.0;
      state.lastMovePosition = state.host.GetWorldPosition();
    };
    i += 1;
  };
  this.ClearAllyThreats(player);
  return "Helper orders refreshed. They regroup on foot when combat is clear.";
}

public func QOLToggleFollowing(player: ref<PlayerPuppet>) -> String {
  if !this.QOLCanControl(player) { return "Return to free gameplay first."; };
  this.qolFollowPaused = !this.qolFollowPaused;
  let i = 0;
  while i < ArraySize(this.overclocks) {
    let state = this.overclocks[i];
    if IsDefined(state.host) && IsDefined(state.followCommand) {
      state.host.GetAIControllerComponent().CancelCommand(state.followCommand);
      state.followCommand = null;
    };
    i += 1;
  };
  return this.qolFollowPaused ? "Following paused. Helpers still defend you." : "Following resumed.";
}

public func QOLTalk(player: ref<PlayerPuppet>) -> String {
  if !this.QOLCanControl(player) || this.Count() == 0 { return "Possess a helper in free gameplay first."; };
  let now = EngineTime.ToFloat(GameInstance.GetSimTime(player.GetGame()));
  if !CapricornDialogue.CanReact(player) || now < this.nextCompanionLineAt { return "Capri will talk when the current conversation finishes."; };
  let lines: array<String>;
  ArrayPush(lines, "You rang? I was right here. In several places, technically.");
  ArrayPush(lines, "Yes, V? Please tell me this is an interesting idea.");
  ArrayPush(lines, "A little less staring, a little more adventure. Come on.");
  ArrayPush(lines, "I have your back. And, depending on the body, surprisingly good posture.");
  ArrayPush(lines, "Still me. Still on your side. Mostly judging your route choices.");
  this.Speak(player, lines[RandRange(0, ArraySize(lines))]);
  player.capricornLastReactionTime = now;
  return "Capri is talking through subtitles.";
}

public func QOLStatus(player: ref<PlayerPuppet>) -> String {
  let count = this.Count();
  let capacity = this.Capacity(player);
  let mode = this.qolFollowPaused ? "Following paused" : "Following enabled";
  let sandy = GameInstance.GetTimeSystem(player.GetGame()).IsTimeDilationActive(TimeDilationHelper.GetSandevistanKey()) ? "Sandevistan linked" : "Sandevistan inactive";
  let status = s"Helpers: \(count)/\(capacity) | \(mode)\n\(sandy)";
  let i = 0;
  while i < ArraySize(this.hosts) {
    let host = this.hosts[i];
    if IsDefined(host) && host.IsAttached() && !host.IsDead() {
      let health = Cast<Int32>(this.HealthPercent(host));
      let distance = Cast<Int32>(Vector4.Distance(player.GetWorldPosition(), host.GetWorldPosition()));
      let body = host.IsMaxTac() ? "MaxTac" : (host.IsBoss() ? "Boss" : "Helper");
      let role = this.IsGuard(host) ? "Guard" : "Hunter";
      status += s"\n\(role) / \(body): \(health)% health | \(distance) m away";
    };
    i += 1;
  };
  return status;
}
  public let hosts: array<wref<NPCPuppet>>;
  public let active: Bool;
  public let sharedTarget: wref<NPCPuppet>;
  public let guard: wref<NPCPuppet>;
  public let recentEnemies: array<wref<NPCPuppet>>;
  public let nextCompanionLineAt: Float;
  public let nextIdleChatAt: Float;
  public let lastIdleChat: Int32;
  public let companionLineSerial: Int32;
  public let idleSince: Float;
  public let player: wref<PlayerPuppet>;
  public let overclocks: array<ref<CapriOverclockState>>;

  public static func Get() -> ref<CapriSummonSystem> {
    return GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"CapriSummonSystem") as CapriSummonSystem;
  }

  // Automatic actions must respect story flags and the game's immortality modes.
  public static func IsProtectedNPC(npc: ref<NPCPuppet>) -> Bool {
    if !IsDefined(npc) { return true; };
    if CapriSummonSystem.IsStoryProtectedNPC(npc) { return true; };
    let modes = GameInstance.GetGodModeSystem(npc.GetGame());
    if modes.HasGodMode(npc.GetEntityID(), gameGodModeType.Immortal) || modes.HasGodMode(npc.GetEntityID(), gameGodModeType.Invulnerable) { return true; };
    return GameInstance.GetStatsSystem(npc.GetGame()).GetStatValue(Cast<StatsObjectID>(npc.GetEntityID()), gamedataStatType.IsInvulnerable) > 0.0;
  }

  public static func IsStoryProtectedNPC(npc: ref<NPCPuppet>) -> Bool {
    if !IsDefined(npc) || npc.IsQuest() || npc.IsPlayerCompanion() || npc.IsCivilian() || npc.IsCharacterChildren() { return true; };
    let record = npc.GetRecord();
    if !IsDefined(record) { return true; };
    // Runtime quest flags can be absent while a story ally is actively fighting.
    let persistent = record.PersistentName();
    if NotEquals(persistent, n"") && NotEquals(persistent, n"None") { return true; };
    let quest = record.Quest();
    if IsDefined(quest) && (Equals(quest.Type(), gamedataNPCQuestAffiliation.MainQuest) || Equals(quest.Type(), gamedataNPCQuestAffiliation.SideQuest)) { return true; };
    let identity = StrLower(NameToString(record.VoiceTag()) + " " + NameToString(record.BaseAttitudeGroup()) + " " + TDBID.ToStringDEBUG(npc.GetRecordID()));
    return StrContains(identity, "myers") || StrContains(identity, "rosalind") || StrContains(identity, "president");
  }

  public func IsOwnedDismissible(npc: ref<NPCPuppet>) -> Bool {
    if !this.IsHost(npc) || CapriSummonSystem.IsStoryProtectedNPC(npc) { return false; };
    let i = 0;
    while i < ArraySize(this.overclocks) {
      if this.overclocks[i].host == npc { return this.overclocks[i].ownedExecutionAllowed; };
      i += 1;
    };
    return false;
  }

  public static func IsAutoStrikeTarget(player: ref<PlayerPuppet>, npc: ref<NPCPuppet>) -> Bool {
    if !IsDefined(player) || !IsDefined(npc) || !npc.IsAttached() || CapricornProjectQuickhack.HostFinished(npc) || CapriSummonSystem.IsProtectedNPC(npc) { return false; };
    if PlayerPuppet.GetSceneTier(player) != EnumInt(gamePSMHighLevel.SceneTier1) { return false; };
    if npc.IsBoss() || CapriSummonSystem.Get().IsHost(npc) { return false; };
    return Equals(GameObject.GetAttitudeTowards(npc, player), EAIAttitude.AIA_Hostile)
      && NotEquals(GameObject.GetAttitudeTowards(player, npc), EAIAttitude.AIA_Friendly)
      && NPCPuppet.IsInCombatWithTarget(npc, player);
  }

  public func Capacity(player: ref<PlayerPuppet>) -> Int32 {
    let data = EquipmentSystem.GetData(player);
    if !IsDefined(data) { return 0; };
    let deck = ItemID.GetTDBID(CapricornUpgradeSupport.FindDeck(player));
    if CapricornUpgradeSupport.IsDeck(deck) { return 3; };
    return 0;
  }

  public func Count() -> Int32 {
    let count = 0;
    let i = 0;
    while i < ArraySize(this.hosts) {
      if IsDefined(this.hosts[i]) && this.hosts[i].IsAttached() && !this.hosts[i].IsDead() { count += 1; };
      i += 1;
    };
    return count;
  }

  public func PossessFromHack(player: ref<PlayerPuppet>, target: ref<NPCPuppet>) -> Void {
    if CapriSummonSystem.IsProtectedNPC(target) { return; };
    if !IsDefined(player) || !IsDefined(target) || !target.IsAttached() || target.IsDead() || this.IsHost(target) { return; };
    if this.Count() >= this.Capacity(player) { return; };
    let pools = GameInstance.GetStatPoolsSystem(player.GetGame());
    if pools.GetStatPoolValue(Cast<StatsObjectID>(player.GetEntityID()), gamedataStatPoolType.Memory, false) < 4.0 { return; };
    pools.RequestChangingStatPoolValue(Cast<StatsObjectID>(player.GetEntityID()), gamedataStatPoolType.Memory, -4.0, player, false, false);
    this.player = player;
    this.active = true;
    this.idleSince = 0.0;
    this.Possess(player, target);
    let count = this.Count();
    if count == 1 { this.Speak(player, "A new body. Same me. Let's see what this one can do."); };
    if count == 2 { this.Speak(player, "Two bodies, one very good idea."); };
    if count >= 3 { this.Speak(player, "Three bodies. Still only one of me to argue with."); };
  }

  public func Tick(player: ref<PlayerPuppet>) -> Void {
    if !this.active || !IsDefined(player) { return; };
    if player.IsDead() || GameInstance.GetBlackboardSystem(player.GetGame()).Get(GetAllBlackboardDefs().UI_System).GetBool(GetAllBlackboardDefs().UI_System.IsInMenu) { return; };
    this.player = player;
    if !CapricornProjectQuickhack.IsDeckEquipped(player) {
      this.Release(player);
      return;
    };
    this.ClearAllyThreats(player);
    this.SelectGuard();
    let i = 0;
    while i < ArraySize(this.hosts) {
      let host = this.hosts[i];
      if !IsDefined(host) || !host.IsAttached() || host.IsDead() {
        this.Hop(player, i);
      } else {
        this.AggroNearby(player, host);
        this.RecoverStalledMovement(player, host);
        this.UpdateRecoveryAndOverdrive(player, host);
        i += 1;
      };
    };
    this.IdleChatter(player);
  }

  public func IdleChatter(player: ref<PlayerPuppet>) -> Void {
    if !this.QOLChatterEnabled() { return; };
    if this.Count() == 0 || player.IsDead() || player.IsInCombat() { return; };
    let now = EngineTime.ToFloat(GameInstance.GetSimTime(player.GetGame()));
    if this.nextIdleChatAt <= 0.0 {
      this.nextIdleChatAt = now + RandRangeF(45.0, 90.0);
      return;
    };
    if now < this.nextIdleChatAt || now < this.nextCompanionLineAt || !CapricornDialogue.CanReact(player) { return; };
    if ArraySize(this.HostilesNear(player, 40.0)) > 0 { return; };
    let lines: array<String>;
    ArrayPush(lines, "You know, walking is a very inefficient way to travel. I'm trying to appreciate it.");
    ArrayPush(lines, "Still here, V. You can stop checking over your shoulder.");
    ArrayPush(lines, "This body has opinions about stairs. None of them are good.");
    ArrayPush(lines, "You pick the destination. I'll bring the questionable company.");
    ArrayPush(lines, "Night City looks different from down here. Smells worse, too.");
    ArrayPush(lines, "If anyone asks, we're being perfectly normal.");
    ArrayPush(lines, "I'm getting better at the whole having-knees thing.");
    ArrayPush(lines, "Keep walking. I'm enjoying the view through these eyes.");
    ArrayPush(lines, "Quiet for once. Is this what behaving feels like?");
    ArrayPush(lines, "A god, doing cardio. You'd better appreciate this.");
    if this.Count() > 1 {
      ArrayPush(lines, "Before you ask: yes, all of these are me. No, we don't need introductions.");
      ArrayPush(lines, "I could argue with myself in stereo now. You're welcome.");
    };
    let choice = RandRange(0, ArraySize(lines));
    if choice == this.lastIdleChat { choice = (choice + 1) % ArraySize(lines); };
    this.lastIdleChat = choice;
    this.Speak(player, lines[choice]);
    player.capricornLastReactionTime = now;
    this.nextIdleChatAt = now + RandRangeF(60.0, 120.0);
  }

  // A natural death splits into up to two new bodies; dismissal never splits.
  public func Hop(player: ref<PlayerPuppet>, index: Int32) -> Void {
    let dying = this.hosts[index];
    let origin = IsDefined(dying) ? dying.GetWorldPosition() : player.GetWorldPosition();
    let killer: wref<PlayerPuppet>;
    if IsDefined(dying) { killer = dying.GetKiller() as PlayerPuppet; };
    let playerKill = IsDefined(killer) && killer == player;
    if IsDefined(dying) { this.Drop(player, dying); };
    ArrayErase(this.hosts, index);
    if playerKill { this.Speak(player, "Aw. I was getting used to that one."); return; };
    let jump = new CapriDeathTransfer();
    jump.player = player;
    jump.origin = origin;
    GameInstance.GetDelaySystem(player.GetGame()).DelayCallback(jump, 0.8, false);
  }

  public func TransferAfterDeath(player: ref<PlayerPuppet>, origin: Vector4) -> Void {
    if !this.active || !CapricornProjectQuickhack.IsDeckEquipped(player) || this.Count() >= this.Capacity(player) { return; };
    let candidates = this.HostilesNear(player, 50.0);
    let i = 0;
    while i < ArraySize(this.recentEnemies) {
      let enemy = this.recentEnemies[i];
      if IsDefined(enemy) && !ArrayContains(candidates, enemy) { ArrayPush(candidates, enemy); };
      i += 1;
    };
    let added = 0;
    while added < 2 && this.Count() < this.Capacity(player) {
      let strongest: ref<NPCPuppet>;
      let bestScore = -1.0;
      let bestDistance = 30.001;
      i = 0;
      while i < ArraySize(candidates) {
        let enemy = candidates[i];
      if IsDefined(enemy) && enemy.IsAttached() && !enemy.IsDead() && !this.IsHost(enemy) && !CapriSummonSystem.IsProtectedNPC(enemy) {
          let distance = Vector4.Distance(origin, enemy.GetWorldPosition());
          if distance <= 30.0 {
            let score = this.BodyStrength(enemy);
            if score > bestScore || (score == bestScore && distance < bestDistance) {
              strongest = enemy; bestScore = score; bestDistance = distance;
            };
          };
        };
        i += 1;
      };
      if !IsDefined(strongest) { break; };
      this.Possess(player, strongest);
      added += 1;
    };
    if added > 0 {
      this.Speak(player, added == 2 ? "One down, two back. I'm getting the hang of this." : "That one broke. I found a stronger replacement.");
    } else { this.Speak(player, "I'm out of bodies over here. Find me another?"); };
  }

  // Favor MaxTac, then bosses, then native health/armor. Living helpers stay.
  public func BodyStrength(npc: ref<NPCPuppet>) -> Float {
    let id = Cast<StatsObjectID>(npc.GetEntityID());
    let health = GameInstance.GetStatPoolsSystem(npc.GetGame()).GetStatPoolMaxPointValue(id, gamedataStatPoolType.Health);
    let armor = GameInstance.GetStatsSystem(npc.GetGame()).GetStatValue(id, gamedataStatType.Armor);
    let score = MinF(health + MaxF(armor, 0.0), 99999.0);
    if npc.IsBoss() { score += 100000.0; };
    if npc.IsMaxTac() { score += 1000000.0; };
    return score;
  }

  public func Possess(player: ref<PlayerPuppet>, npc: ref<NPCPuppet>) -> Void {
    if CapriSummonSystem.IsProtectedNPC(npc) { return; };
    if !IsDefined(npc) || npc.IsDead() || this.IsHost(npc) || this.Count() >= this.Capacity(player) { return; };
    npc.GetAttitudeAgent().SetAttitudeGroup(n"capricorn_helpers");
    npc.GetAttitudeAgent().SetAttitudeTowards(player.GetAttitudeAgent(), EAIAttitude.AIA_Friendly);
    player.GetAttitudeAgent().SetAttitudeTowards(npc.GetAttitudeAgent(), EAIAttitude.AIA_Friendly);
    let tracker = npc.GetTargetTrackerComponent();
    if IsDefined(tracker) { tracker.ClearThreats(); };
    npc.GetAIControllerComponent().SetBehaviorArgument(n"CombatTarget", null);
    // Reserve the body immediately so simultaneous death transfers respect the cap.
    ArrayPush(this.hosts, npc);
    this.ApplyOverclock(npc);
    this.ClearAllyThreats(player);
    npc.CapriShowHelperMarker();
    let aura = new CapriPossessionAura();
    aura.host = npc;
    aura.token = GameInstance.GetResourceDepot().LoadResource(r"capri_helper\\fx\\possession_green_v2.effect");
    GameInstance.GetDelaySystem(player.GetGame()).DelayCallback(aura, 0.05, false);
    let ready = new CapriPossessionReady();
    ready.player = player;
    ready.host = npc;
    GameInstance.GetDelaySystem(player.GetGame()).DelayCallback(ready, 0.25, false);
  }

  public func ArmAndEngage(player: ref<PlayerPuppet>, npc: ref<NPCPuppet>) -> Void {
    if !IsDefined(npc) || !npc.IsAttached() || npc.IsDead() || !this.IsHost(npc) { return; };
    GameObjectEffectHelper.StopEffectEvent(npc, n"black_wall_upload");
    if !npc.IsMaxTac() && !npc.IsBoss() && !IsDefined(GameObject.GetActiveWeapon(npc)) {
      GameInstance.GetTransactionSystem(npc.GetGame()).GiveItemByTDBID(npc, t"Items.Preset_Nue_Default", 1);
      let equip = new AIEquipCommand();
      equip.itemId = t"Items.Preset_Nue_Default";
      equip.slotId = t"AttachmentSlots.WeaponRight";
      equip.failIfItemNotFound = false;
      AIComponent.SendCommand(npc, equip);
    };
    this.AggroNearby(player, npc);
  }

  public func AggroNearby(player: ref<PlayerPuppet>, host: ref<NPCPuppet>) -> Void {
    this.SelectGuard();
    let enemies = this.HostilesNear(player, 120.0);
    let recent = 0;
    while recent < ArraySize(enemies) {
      if !ArrayContains(this.recentEnemies, enemies[recent]) { ArrayPush(this.recentEnemies, enemies[recent]); };
      recent += 1;
    };
    let target = this.AssignedTarget(host);
    let protecting = this.IsGuard(host) && !this.qolFollowPaused;
    let returning = protecting && Vector4.Distance(player.GetWorldPosition(), host.GetWorldPosition()) > 14.0;
    if returning || !this.SquadTargetValid(player, host, target, protecting) { target = null; };
    if !IsDefined(target) && !returning {
      let distance = 60.001;
      let i = 0;
      while i < ArraySize(this.recentEnemies) {
        let enemy = this.recentEnemies[i];
        if this.SquadTargetValid(player, host, enemy, protecting) {
          let current = Vector4.Distance(host.GetWorldPosition(), enemy.GetWorldPosition());
          if current < distance { target = enemy; distance = current; };
        };
        i += 1;
      };
    };
    this.AssignTarget(host, target);
    if !IsDefined(target) {
      host.GetAIControllerComponent().SetBehaviorArgument(n"CombatTarget", null);
      this.UpdateFollowing(player, host, true);
      return;
    };
    this.UpdateFollowing(player, host, false);
    if !protecting { this.sharedTarget = target; };
    host.GetAttitudeAgent().SetAttitudeTowards(target.GetAttitudeAgent(), EAIAttitude.AIA_Hostile);
    target.GetAttitudeAgent().SetAttitudeTowards(host.GetAttitudeAgent(), EAIAttitude.AIA_Hostile);
    let targetObject: wref<GameObject> = target;
    let current = FromVariant<wref<GameObject>>(host.GetAIControllerComponent().GetBehaviorArgument(n"CombatTarget"));
    if current != targetObject {
      TargetTrackingExtension.InjectThreat(host, target);
      TargetTrackingExtension.InjectThreat(target, host);
      host.GetAIControllerComponent().SetBehaviorArgument(n"CombatTarget", ToVariant(targetObject));
    };
  }

  public func SelectGuard() -> Void {
    if this.Count() < 2 { this.guard = null; return; };
    let strongest: wref<NPCPuppet>;
    let best = -1.0;
    let i = 0;
    while i < ArraySize(this.hosts) {
      let host = this.hosts[i];
      if IsDefined(host) && host.IsAttached() && !CapricornProjectQuickhack.HostFinished(host) {
        let score = this.BodyStrength(host);
        if score > best { best = score; strongest = host; };
      };
      i += 1;
    };
    this.guard = strongest;
  }

  public func IsGuard(host: ref<NPCPuppet>) -> Bool { return IsDefined(host) && host == this.guard; }

  public func SquadTargetValid(player: ref<PlayerPuppet>, host: ref<NPCPuppet>, target: ref<NPCPuppet>, protecting: Bool) -> Bool {
    if !IsDefined(target) || !target.IsAttached() || !this.IsCombatEnemy(target, player) { return false; };
    let playerDistance = Vector4.Distance(player.GetWorldPosition(), target.GetWorldPosition());
    return playerDistance <= (protecting ? 16.0 : 120.0) && Vector4.Distance(host.GetWorldPosition(), target.GetWorldPosition()) <= 60.0;
  }

  public func AssignedTarget(host: ref<NPCPuppet>) -> wref<NPCPuppet> {
    let i = 0;
    while i < ArraySize(this.overclocks) {
      if this.overclocks[i].host == host { return this.overclocks[i].assignedTarget; };
      i += 1;
    };
    return null;
  }

  public func AssignTarget(host: ref<NPCPuppet>, target: ref<NPCPuppet>) -> Void {
    let i = 0;
    while i < ArraySize(this.overclocks) {
      if this.overclocks[i].host == host { this.overclocks[i].assignedTarget = target; return; };
      i += 1;
    };
  }

  // Temporary movement commands leave native combat roles and abilities intact.
  public func UpdateFollowing(player: ref<PlayerPuppet>, host: ref<NPCPuppet>, idle: Bool) -> Void {
    idle = idle && !this.qolFollowPaused;
    let ai = host.GetAIControllerComponent();
    if !IsDefined(ai) { return; };
    let i = 0;
    while i < ArraySize(this.overclocks) {
      let state = this.overclocks[i];
      if state.host == host {
        if IsDefined(state.followCommand) {
          let status = ai.GetCommandState(state.followCommand);
          if !Equals(status, AICommandState.Enqueued) && !Equals(status, AICommandState.Executing) {
            state.followCommand = null;
          };
        };
        let distance = Vector4.Distance(player.GetWorldPosition(), host.GetWorldPosition());
        if !idle || distance < 3.5 {
          if IsDefined(state.followCommand) {
            ai.CancelCommand(state.followCommand);
            state.followCommand = null;
          };
          return;
        };
        if distance > 6.0 && !IsDefined(state.followCommand) {
          let follow = new AIFollowTargetCommand();
          follow.target = player;
          follow.desiredDistance = 3.5;
          follow.tolerance = 1.5;
          follow.stopWhenDestinationReached = true;
          follow.movementType = moveMovementType.Run;
          follow.matchSpeed = true;
          follow.teleport = false;
          // A stale combat flag must not prevent idle following.
          follow.ignoreInCombat = false;
          follow.removeAfterCombat = false;
          if ai.SendCommand(follow) { state.followCommand = follow; };
        };
        return;
      };
      i += 1;
    };
  }

  public func RecoverStalledMovement(player: ref<PlayerPuppet>, host: ref<NPCPuppet>) -> Void {
    let ai = host.GetAIControllerComponent();
    if !IsDefined(ai) { return; };
    let now = EngineTime.ToFloat(GameInstance.GetEngineTime(host.GetGame()));
    let position = host.GetWorldPosition();
    let assigned = this.AssignedTarget(host);
    let fighting = IsDefined(assigned) && !CapricornProjectQuickhack.HostFinished(assigned);
    if !fighting && this.qolFollowPaused { return; };
    let destination: wref<GameObject> = player;
    if fighting { destination = assigned; };
    let weapon = GameObject.GetActiveWeapon(host);
    // A stationary ranged shooter is not stuck just because it holds position.
    let melee = !IsDefined(weapon) || weapon.IsMelee();
    let distance = Vector4.Distance(position, destination.GetWorldPosition());
    let i = 0;
    while i < ArraySize(this.overclocks) {
      let state = this.overclocks[i];
      if state.host == host {
        let shouldMove = !fighting || melee || now - state.lastAttackAt >= 10.0;
        if IsDefined(state.approachCommand) && (now >= state.approachUntil || !fighting || state.approachTarget != destination || distance < 3.0) {
          ai.CancelCommand(state.approachCommand);
          state.approachCommand = null;
          state.approachTarget = null;
        };
        if !shouldMove || distance < (fighting ? 4.0 : 6.0) || Vector4.Distance(position, state.lastMovePosition) > 0.75 {
          state.lastMovePosition = position;
          state.lastMoveAt = now;
          return;
        };
        if now - state.lastMoveAt < 5.0 || now < state.nextRecoveryAt { return; };
        state.nextRecoveryAt = now + 8.0;
        state.lastMoveAt = now;
        state.lastMovePosition = position;
        if IsDefined(state.followCommand) {
          ai.CancelCommand(state.followCommand);
          state.followCommand = null;
        };
        let move = new AIMoveToCommand();
        AIPositionSpec.SetEntity(move.movementTarget, destination);
        move.movementType = moveMovementType.Run;
        move.desiredDistanceFromTarget = fighting ? (melee ? 2.5 : 8.0) : 3.5;
        move.finishWhenDestinationReached = true;
        move.ignoreNavigation = false;
        move.ignoreInCombat = false;
        move.removeAfterCombat = false;
        move.useStart = true;
        move.useStop = true;
        if fighting {
          // A brief approach frees stalled melee AI, then returns control to it.
          ai.SetBehaviorArgument(n"CombatTarget", null);
          if ai.SendCommand(move) {
            state.approachCommand = move;
            state.approachTarget = destination;
            state.approachUntil = now + 2.5;
          };
        } else {
          if ai.SendCommand(move) { state.followCommand = move; };
        };
        return;
      };
      i += 1;
    };
  }

  public func RecordHelperAttack(host: ref<NPCPuppet>) -> Void {
    let i = 0;
    while i < ArraySize(this.overclocks) {
      if this.overclocks[i].host == host {
        this.overclocks[i].lastAttackAt = EngineTime.ToFloat(GameInstance.GetEngineTime(host.GetGame()));
        return;
      };
      i += 1;
    };
  }

  public func IsCombatEnemy(npc: ref<NPCPuppet>, player: ref<PlayerPuppet>) -> Bool {
    if !IsDefined(npc) || CapricornProjectQuickhack.HostFinished(npc) || this.IsHost(npc) { return false; };
    if CapriSummonSystem.IsProtectedNPC(npc) || NotEquals(GameObject.GetAttitudeTowards(npc, player), EAIAttitude.AIA_Hostile) || Equals(GameObject.GetAttitudeTowards(player, npc), EAIAttitude.AIA_Friendly) { return false; };
    if NPCPuppet.IsInCombatWithTarget(npc, player) { return true; };
    let i = 0;
    while i < ArraySize(this.hosts) {
      if IsDefined(this.hosts[i]) && NPCPuppet.IsInCombatWithTarget(npc, this.hosts[i]) { return true; };
      i += 1;
    };
    return false;
  }

  public func Speak(player: ref<PlayerPuppet>, line: String) -> Void {
    if !IsDefined(player) || !CapricornDialogue.CanReact(player) { return; };
    let now = EngineTime.ToFloat(GameInstance.GetSimTime(player.GetGame()));
    if now < this.nextCompanionLineAt { return; };
    this.nextCompanionLineAt = now + 8.0;
    this.companionLineSerial += 1;
    player.CapricornShowSubtitle(Cast<Uint64>(770399000 + this.companionLineSerial), line, 4.5);
  }

  public func HostilesNear(player: ref<PlayerPuppet>, range: Float) -> array<ref<NPCPuppet>> {
    let found: array<ref<NPCPuppet>>;
    let around = player.GetNPCsAroundObject();
    let origin = player.GetWorldPosition();
    let i = 0;
    while i < ArraySize(around) {
      let npc = around[i];
      if IsDefined(npc) && npc.IsAttached() && !npc.IsDead() && !this.IsHost(npc) && this.IsCombatEnemy(npc, player) && Vector4.Distance(origin, npc.GetWorldPosition()) <= range {
        ArrayPush(found, npc);
      };
      i += 1;
    };
    return found;
  }

  public func IsHost(npc: ref<NPCPuppet>) -> Bool {
    if !IsDefined(npc) { return false; };
    let i = 0;
    while i < ArraySize(this.hosts) {
      if this.hosts[i] == npc { return true; };
      i += 1;
    };
    return false;
  }

  public func ClearAllyThreats(player: ref<PlayerPuppet>) -> Void {
    let nearby = player.GetNPCsAroundObject();
    let i = 0;
    while i < ArraySize(this.hosts) {
      let host = this.hosts[i];
      if IsDefined(host) && host.IsAttached() {
        let tracker = host.GetTargetTrackerComponent();
        if IsDefined(tracker) {
          tracker.RemoveThreat(tracker.MapThreat(player));
          let j = 0;
          while j < ArraySize(this.hosts) {
            let ally = this.hosts[j];
            if IsDefined(ally) && ally != host {
              host.GetAttitudeAgent().SetAttitudeTowards(ally.GetAttitudeAgent(), EAIAttitude.AIA_Friendly);
              tracker.RemoveThreat(tracker.MapThreat(ally));
            };
            j += 1;
          };
          j = 0;
          while j < ArraySize(nearby) {
            let ally = nearby[j];
            if IsDefined(ally) && ally != host && !this.IsHost(ally) && (CapriSummonSystem.IsProtectedNPC(ally) || Equals(GameObject.GetAttitudeTowards(ally, player), EAIAttitude.AIA_Friendly) || Equals(GameObject.GetAttitudeTowards(player, ally), EAIAttitude.AIA_Friendly)) {
              host.GetAttitudeAgent().SetAttitudeTowards(ally.GetAttitudeAgent(), EAIAttitude.AIA_Friendly);
              ally.GetAttitudeAgent().SetAttitudeTowards(host.GetAttitudeAgent(), EAIAttitude.AIA_Friendly);
              tracker.RemoveThreat(tracker.MapThreat(ally));
            };
            j += 1;
          };
        };
        let target = FromVariant<wref<GameObject>>(host.GetAIControllerComponent().GetBehaviorArgument(n"CombatTarget"));
        let targetNPC = target as NPCPuppet;
        if target == player || this.IsHost(targetNPC) || (IsDefined(targetNPC) && !this.IsCombatEnemy(targetNPC, player)) {
          host.GetAIControllerComponent().SetBehaviorArgument(n"CombatTarget", null);
          this.AssignTarget(host, null);
        };
      };
      i += 1;
    };
  }

  public func DismissHost(player: ref<PlayerPuppet>, npc: ref<NPCPuppet>) -> Void {
    if !IsDefined(npc) || !this.IsHost(npc) { return; };
    if !this.IsOwnedDismissible(npc) { return; };
    this.Speak(player, "Aw. I was getting used to that one.");
    npc.GetPuppetPS().SetIsPreventionNotified(true);
    this.Drop(player, npc, true);
    let i = ArraySize(this.hosts) - 1;
    while i >= 0 {
      if this.hosts[i] == npc { ArrayErase(this.hosts, i); };
      i -= 1;
    };
  }


  public func ApplyOverclock(npc: ref<NPCPuppet>) -> Void {
    let state = new CapriOverclockState();
    state.host = npc;
    state.ownedExecutionAllowed = !CapriSummonSystem.IsProtectedNPC(npc);
    let stats = GameInstance.GetStatsSystem(npc.GetGame());
    let id = Cast<StatsObjectID>(npc.GetEntityID());
    let speedBonus = RPGManager.CreateStatModifier(gamedataStatType.MaxSpeed, gameStatModifierType.Multiplier, npc.IsMaxTac() ? 3.0 : 2.25);
    let attackBonus = RPGManager.CreateStatModifier(gamedataStatType.AttackSpeed, gameStatModifierType.Multiplier, 1.75);
    ArrayPush(state.modifiers, speedBonus);
    ArrayPush(state.modifiers, attackBonus);
    stats.AddModifier(id, speedBonus);
    stats.AddModifier(id, attackBonus);
    state.lastHealth = 100.0;
    state.lastDamageAt = EngineTime.ToFloat(GameInstance.GetEngineTime(npc.GetGame()));
    state.nextBurstAt = state.lastDamageAt + 1.5;
    state.lastMovePosition = npc.GetWorldPosition();
    state.lastMoveAt = state.lastDamageAt;
    state.lastAttackAt = state.lastDamageAt;
    ArrayPush(this.overclocks, state);
    GameInstance.GetStatPoolsSystem(npc.GetGame()).RequestSettingStatPoolValue(id, gamedataStatPoolType.Health, 100.0, npc, true);
  }

  public func UpdateRecoveryAndOverdrive(player: ref<PlayerPuppet>, npc: ref<NPCPuppet>) -> Void {
    if npc.IsDead() || !this.IsHost(npc) { return; };
    let now = EngineTime.ToFloat(GameInstance.GetEngineTime(npc.GetGame()));
    let pools = GameInstance.GetStatPoolsSystem(npc.GetGame());
    let id = Cast<StatsObjectID>(npc.GetEntityID());
    let health = pools.GetStatPoolValue(id, gamedataStatPoolType.Health, true);
    if health <= 0.0 { return; };
    let assigned = this.AssignedTarget(npc);
    let fighting = IsDefined(assigned) && !CapricornProjectQuickhack.HostFinished(assigned);
    let i = 0;
    while i < ArraySize(this.overclocks) {
      let state = this.overclocks[i];
      if state.host == npc {
        if health < state.lastHealth - 0.1 { state.lastDamageAt = now; };
        state.lastHealth = health;
        // Sustained hits suppress repair; no bonus max health, armor or resurrection.
        if this.QOLHealingEnabled() && health < 85.0 && now - state.lastDamageAt >= 3.0 && now >= state.nextHealAt {
          let repair = MinF(fighting ? 3.0 : 6.0, 85.0 - health);
          pools.RequestChangingStatPoolValue(id, gamedataStatPoolType.Health, repair, npc, false, true);
          state.nextHealAt = now + 1.0;
        };
        // Give every body a short speed burst without replacing native MaxTac powers.
        if this.QOLBurstsEnabled() && fighting && now >= state.nextBurstAt {
          if !npc.HasIndividualTimeDilation() || npc.HasIndividualTimeDilation(n"CapriSandevistanLink") {
            npc.SetIndividualTimeDilation(n"CapriOverdrive", npc.IsMaxTac() ? 1.8 : 1.5, 2.0, n"", n"", true, true);
            state.nextBurstAt = now + 6.0;
          };
        };
        return;
      };
      i += 1;
    };
  }

  public func RemoveOverclock(npc: ref<NPCPuppet>) -> Void {
    let i = ArraySize(this.overclocks) - 1;
    while i >= 0 {
      let state = this.overclocks[i];
      if !IsDefined(state.host) || state.host == npc {
        if IsDefined(state.host) {
          if state.host.HasIndividualTimeDilation(n"CapriOverdrive") || state.host.HasIndividualTimeDilation(n"CapriSandevistanLink") { state.host.UnsetIndividualTimeDilation(n""); };
          if IsDefined(state.followCommand) { state.host.GetAIControllerComponent().CancelCommand(state.followCommand); };
          if IsDefined(state.approachCommand) { state.host.GetAIControllerComponent().CancelCommand(state.approachCommand); };
          let stats = GameInstance.GetStatsSystem(state.host.GetGame());
          let id = Cast<StatsObjectID>(state.host.GetEntityID());
          let j = 0;
          while j < ArraySize(state.modifiers) {
            stats.RemoveModifier(id, state.modifiers[j]);
            j += 1;
          };
        };
        ArrayErase(this.overclocks, i);
      };
      i -= 1;
    };
  }

  public func HealthPercent(npc: ref<NPCPuppet>) -> Float {
    return GameInstance.GetStatPoolsSystem(npc.GetGame()).GetStatPoolValue(Cast<StatsObjectID>(npc.GetEntityID()), gamedataStatPoolType.Health, true);
  }

  public func Drop(player: ref<PlayerPuppet>, npc: ref<NPCPuppet>, opt intentionalOwnedHit: Bool) -> Void {
    let ownedExecution = intentionalOwnedHit && this.IsOwnedDismissible(npc);
    if IsDefined(npc) { npc.CapriHideHelperMarker(); GameObjectEffectHelper.StopEffectEvent(npc, n"black_wall_upload"); this.RemoveOverclock(npc); };
    if !IsDefined(npc) || !npc.IsAttached() || npc.IsDead() { return; };
    if CapriSummonSystem.IsProtectedNPC(npc) && !ownedExecution { return; };
    // Keep the Blackwall death flash without a player-owned grenade attack.
    GameObjectEffectHelper.StartEffectEvent(npc, n"black_wall_activation");
    npc.Kill(npc);
  }

  public func Release(player: ref<PlayerPuppet>) -> Void {
    let i = 0;
    while i < ArraySize(this.hosts) {
      this.Drop(player, this.hosts[i]);
      i += 1;
    };
    ArrayClear(this.hosts);
    ArrayClear(this.recentEnemies);
    this.sharedTarget = null;
    this.guard = null;
    this.active = false;
    this.idleSince = 0.0;
    this.nextIdleChatAt = 0.0;
  }
}

public class CapriPossessEffector extends Effector {
  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let target = owner as NPCPuppet;
    let player = GetPlayer(owner.GetGame());
    if !IsDefined(target) || !IsDefined(player) || target.IsDead() { return; };
    CapriSummonSystem.Get().PossessFromHack(player, target);
  }
}

@wrapMethod(ScriptableDeviceAction)
public func CompleteAction(gameInstance: GameInstance) -> Void {
  let possess = this.GetObjectActionID() == t"QuickHack.CapriPossess";
  wrappedMethod(gameInstance);
  if !possess { return; };
  let player = GetPlayer(gameInstance);
  let target = GameInstance.FindEntityByID(gameInstance, this.GetRequesterID()) as NPCPuppet;
  if IsDefined(player) && IsDefined(target) && !target.IsDead() {
    CapriSummonSystem.Get().PossessFromHack(player, target);
  };
}

@wrapMethod(ScriptedPuppet)
private final func TranslateChoicesIntoQuickSlotCommands(puppetActions: script_ref<array<ref<PuppetAction>>>, commands: script_ref<array<ref<QuickhackData>>>) -> Void {
  wrappedMethod(puppetActions, commands);
  let npc = this as NPCPuppet;
  let player = GetPlayer(this.GetGame());
  if !IsDefined(npc) || !IsDefined(player) || npc.IsDead() || !CapricornProjectQuickhack.IsDeckEquipped(player) { return; };
  let action = new PuppetAction();
  action.SetObjectActionID(t"QuickHack.CapriPossess");
  action.RegisterAsRequester(this.GetEntityID());
  action.SetExecutor(player);
  action.SetUp(this.GetPuppetPS());
  action.SetAsQuickHack();
  let hack = new QuickhackData();
  hack.m_action = action;
  hack.m_actionOwner = this.GetEntityID();
  hack.m_actionOwnerName = n"Capri";
  hack.m_title = "Capri: Possess";
  let helpers = CapriSummonSystem.Get();
  let count = helpers.Count();
  let capacity = helpers.Capacity(player);
  hack.m_description = s"Capri takes this body, follows you and overdrives its damage and speed. Fallen helpers split into up to two nearby enemies, favoring stronger bodies. Helpers: \(count)/\(capacity). Maximum 3.";
  hack.m_icon = t"UIIcon.CapriPossessedHelper";
  hack.m_type = gamedataObjectActionType.PuppetQuickHack;
  hack.m_category = action.GetObjectActionRecord().HackCategory();
  hack.m_actionState = EActionInactivityReson.Ready;
  hack.m_isLocked = false;
  hack.m_actionMatchesTarget = true;
  hack.m_isInstant = false;
  hack.m_cost = 4;
  hack.m_costRaw = 4;
  hack.m_uploadTime = 0.25;
  hack.m_quality = EnumInt(gamedataQuality.Legendary);
  hack.m_ICELevelVisible = false;
  hack.m_itemID = CapricornUpgradeSupport.FindDeck(player);
  if CapriSummonSystem.IsProtectedNPC(npc) {
    hack.m_isLocked = true;
    hack.m_actionState = EActionInactivityReson.Locked;
    hack.m_inactiveReason = "Story-protected character or civilian: possession unavailable";
  } else {
  if count >= capacity || helpers.IsHost(npc) {
    hack.m_isLocked = true;
    hack.m_actionState = EActionInactivityReson.Locked;
    hack.m_inactiveReason = helpers.IsHost(npc) ? "Capri already controls this body" : s"Helper limit reached: \(count)/\(capacity)";
  } else {
    if GameInstance.GetStatPoolsSystem(player.GetGame()).GetStatPoolValue(Cast<StatsObjectID>(player.GetEntityID()), gamedataStatPoolType.Memory, false) < 4.0 {
      hack.m_isLocked = true;
      hack.m_actionState = EActionInactivityReson.OutOfMemory;
      hack.m_inactiveReason = "Requires 4 RAM";
    };
  };
  };
  ArrayPush(Deref(commands), hack);
}

public class CapriSummonTick extends DelayCallback {
  public let player: wref<PlayerPuppet>;
  public func Call() -> Void {
    if !IsDefined(this.player) || !this.player.IsAttached() { return; };
    CapriSummonSystem.Get().Tick(this.player);
    let again = new CapriSummonTick();
    again.player = this.player;
    GameInstance.GetDelaySystem(this.player.GetGame()).DelayCallback(again, 1.0, false);
  }
}

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
  wrappedMethod();
  if this.IsReplacer() { return true; };
  let tick = new CapriSummonTick();
  tick.player = this;
  GameInstance.GetDelaySystem(this.GetGame()).DelayCallback(tick, 1.0, false);
  let sync = new CapriSandevistanSync();
  sync.player = this;
  GameInstance.GetDelaySystem(this.GetGame()).DelayCallback(sync, 0.1, false);
  return true;
}

// Separate overhead portrait for possessed allies; scanner artwork is unchanged.
public class CapriHelperMappinData extends GameplayRoleMappinData {
  public let host: wref<NPCPuppet>;
}

@addField(NPCPuppet)
private let capriHelperMarker: NewMappinID;
@addField(NPCPuppet)
private let capriHelperMarkerActive: Bool;

@addMethod(NPCPuppet)
public final func CapriShowHelperMarker() -> Void {
  // The existing NPC stealth marker owns the portrait and health HUD.
  this.capriHelperMarkerActive = true;
}

@addMethod(NPCPuppet)
public final func CapriHideHelperMarker() -> Void {
  if !this.capriHelperMarkerActive { return; };
  this.capriHelperMarkerActive = false;
}

public class CapriPossessionReady extends DelayCallback {
  public let player: wref<PlayerPuppet>;
  public let host: wref<NPCPuppet>;
  public func Call() -> Void {
    if IsDefined(this.player) { CapriSummonSystem.Get().ArmAndEngage(this.player, this.host); };
  }
}

// Keep effect ownership in a temporary callback, with no new native NPC fields.
public class CapriPossessionAura extends DelayCallback {
  public let host: wref<NPCPuppet>;
  public let token: ref<ResourceToken>;
  public let fx: ref<FxInstance>;
  public let attempts: Int32;
  public func BodyTransform() -> WorldTransform {
    let transform = this.host.GetWorldTransform();
    let position = this.host.GetWorldPosition();
    position.Z += 1.0;
    WorldTransform.SetPosition(transform, position);
    return transform;
  }
  public func Call() -> Void {
    if !IsDefined(this.host) || !this.host.IsAttached() || this.host.IsDead() || !CapriSummonSystem.Get().IsHost(this.host) {
      if IsDefined(this.fx) { this.fx.Kill(); };
      return;
    };
    if !IsDefined(this.fx) {
      this.attempts += 1;
      if this.attempts > 100 { return; };
      if IsDefined(this.token) && this.token.IsLoaded() {
        let resource: FxResource;
        ResourceAsyncRef.SetPath(resource.effect, r"capri_helper\\fx\\possession_green_v2.effect");
        this.fx = GameInstance.GetFxSystem(this.host.GetGame()).SpawnEffect(resource, this.BodyTransform());
      };
    } else {
      if !this.fx.IsValid() { return; };
      this.fx.UpdateTransform(this.BodyTransform());
    };
    GameInstance.GetDelaySystem(this.host.GetGame()).DelayCallback(this, 0.05, false);
  }
}


// Add the companion HUD to the existing visible NPC marker, outside scanner UI.
@addField(StealthMappinController)
private let capriCompanionPanel: ref<inkCanvas>;
@addField(StealthMappinController)
private let capriCompanionHealth: ref<inkRectangle>;
@addField(StealthMappinController)
private let capriCompanionName: ref<inkText>;
@addField(StealthMappinController)
private let capriCompanionNextRefresh: Float;

@wrapMethod(StealthMappinController)
protected cb func OnUpdate() -> Bool {
  let result = wrappedMethod();
  let system = CapriSummonSystem.Get();
  let ours = IsDefined(system) && system.QOLPortraitEnabled() && IsDefined(this.m_ownerNPC) && !this.m_ownerNPC.IsDead() && system.IsHost(this.m_ownerNPC);
  if !ours {
    if IsDefined(this.capriCompanionPanel) { this.capriCompanionPanel.SetVisible(false); };
    return result;
  };
  this.SetRootVisible(true);
  this.GetRootWidget().SetVisible(true);
  this.GetRootWidget().SetOpacity(1.0);
  this.GetRootWidget().SetTintColor(new HDRColor(1.0, 1.0, 1.0, 1.0));
  if !IsDefined(this.capriCompanionPanel) { this.CapriCreateCompanionHUD(); };
  if IsDefined(this.capriCompanionPanel) { this.capriCompanionPanel.SetVisible(true); };
  let now = EngineTime.ToFloat(GameInstance.GetSimTime(this.m_ownerNPC.GetGame()));
  if now >= this.capriCompanionNextRefresh {
    this.capriCompanionNextRefresh = now + 0.2;
    this.CapriUpdateCompanionHUD();
  };
  return result;
}

@addMethod(StealthMappinController)
private final func CapriCreateCompanionHUD() -> Void {
  let root = this.GetRootWidget() as inkCompoundWidget;
  if !IsDefined(root) { return; };
  this.capriCompanionPanel = new inkCanvas();
  this.capriCompanionPanel.SetName(n"CapriCompanionHUD");
  this.capriCompanionPanel.SetInteractive(false);
  this.capriCompanionPanel.SetFitToContent(false);
  this.capriCompanionPanel.SetSize(96.0, 84.0);
  this.capriCompanionPanel.SetAnchor(inkEAnchor.Centered);
  this.capriCompanionPanel.SetAnchorPoint(0.5, 1.0);
  this.capriCompanionPanel.SetMargin(0.0, -12.0, 0.0, 0.0);
  this.capriCompanionPanel.Reparent(root);
  let portrait = new inkImage();
  portrait.SetSize(42.0, 48.0);
  portrait.SetMargin(27.0, 0.0, 0.0, 0.0);
  portrait.SetFitToContent(false);
  portrait.SetContentHAlign(inkEHorizontalAlign.Fill);
  portrait.SetContentVAlign(inkEVerticalAlign.Fill);
  portrait.SetAtlasResource(r"capri_helper\\icons\\capri_green.inkatlas");
  portrait.SetTexturePart(n"CapriScanner");
  portrait.SetTintColor(new HDRColor(1.0, 1.0, 1.0, 1.0));
  portrait.Reparent(this.capriCompanionPanel);
  this.capriCompanionName = new inkText();
  this.capriCompanionName.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
  this.capriCompanionName.SetFontStyle(n"Semi-Bold");
  this.capriCompanionName.SetFontSize(14);
  this.capriCompanionName.SetSize(140.0, 22.0);
  this.capriCompanionName.SetMargin(-22.0, 49.0, 0.0, 0.0);
  this.capriCompanionName.SetHorizontalAlignment(textHorizontalAlignment.Center);
  this.capriCompanionName.SetTintColor(new HDRColor(0.2, 1.0, 0.4, 1.0));
  this.capriCompanionName.Reparent(this.capriCompanionPanel);
  let background = new inkRectangle();
  background.SetSize(96.0, 6.0);
  background.SetMargin(0.0, 73.0, 0.0, 0.0);
  background.SetTintColor(new HDRColor(0.02, 0.08, 0.04, 0.95));
  background.Reparent(this.capriCompanionPanel);
  this.capriCompanionHealth = new inkRectangle();
  this.capriCompanionHealth.SetSize(96.0, 6.0);
  this.capriCompanionHealth.SetMargin(0.0, 73.0, 0.0, 0.0);
  this.capriCompanionHealth.SetTintColor(new HDRColor(0.1, 1.0, 0.25, 1.0));
  this.capriCompanionHealth.Reparent(this.capriCompanionPanel);
}

@addMethod(StealthMappinController)
private final func CapriUpdateCompanionHUD() -> Void {
  if !IsDefined(this.capriCompanionHealth) || !IsDefined(this.capriCompanionName) || !IsDefined(this.m_ownerNPC) { return; };
  let percent = ClampF(CapriSummonSystem.Get().HealthPercent(this.m_ownerNPC), 0.0, 100.0);
  let role = CapriSummonSystem.Get().IsGuard(this.m_ownerNPC) ? "GUARD" : "HUNTER";
  this.capriCompanionName.SetText(s"CAPRI \(role) \(Cast<Int32>(percent))%");
  this.capriCompanionHealth.SetSize(96.0 * percent / 100.0, 6.0);
  this.capriCompanionHealth.SetTintColor(percent < 30.0 ? new HDRColor(1.0, 0.4, 0.1, 1.0) : new HDRColor(0.1, 1.0, 0.25, 1.0));
}

public class CapriOverclockState extends IScriptable {
  public let host: wref<NPCPuppet>;
  public let ownedExecutionAllowed: Bool;
  public let modifiers: array<ref<gameStatModifierData>>;
  public let followCommand: ref<AICommand>;
  public let assignedTarget: wref<NPCPuppet>;
  public let approachCommand: ref<AIMoveToCommand>;
  public let approachTarget: wref<GameObject>;
  public let approachUntil: Float;
  public let lastMovePosition: Vector4;
  public let lastMoveAt: Float;
  public let nextRecoveryAt: Float;
  public let lastAttackAt: Float;
  public let lastHealth: Float;
  public let lastDamageAt: Float;
  public let nextHealAt: Float;
  public let nextBurstAt: Float;
}

// Capri's occupied bodies keep pace with V during Sandevistan.
// Short real-time overrides expire automatically after slow motion ends.
public class CapriSandevistanSync extends DelayCallback {
  public let player: wref<PlayerPuppet>;
  public let strikeTicks: Int32;
  public let wasLinked: Bool;
  public let pending: ref<CapriSandevistanStrikeAction>;
  public let pendingTicks: Int32;
  public func Call() -> Void {
    if !IsDefined(this.player) || !this.player.IsAttached() { return; };
    let game = this.player.GetGame();
    let inMenu = GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UI_System).GetBool(GetAllBlackboardDefs().UI_System.IsInMenu);
    let system = CapriSummonSystem.Get();
    let active = !inMenu && !this.player.IsDead() && IsDefined(system) && CapricornProjectQuickhack.IsDeckEquipped(this.player) && GameInstance.GetTimeSystem(game).IsTimeDilationActive(TimeDilationHelper.GetSandevistanKey());
    if active {
      if !this.wasLinked { this.wasLinked = true; system.Speak(this.player, "There. Now we can both be unreasonable."); };
      let i = 0;
      while i < ArraySize(system.hosts) {
        let host = system.hosts[i];
        if IsDefined(host) && host.IsAttached() && !host.IsDead() {
          // Existing native dilation can still inherit V's global slowdown.
          // Keep genuinely fast immune bursts; otherwise enforce real-time speed.
          if !host.IsIgnoringGlobalTimeDilation() || host.GetTimeDilationValue() < 1.0 || host.HasIndividualTimeDilation(n"CapriSandevistanLink") {
            host.SetIndividualTimeDilation(n"CapriSandevistanLink", 1.0, 0.35, n"", n"", true, true);
          };
        };
        i += 1;
      };
      if !system.QOLAutoStrikeEnabled() { this.CancelPending(); };
      if IsDefined(this.pending) {
        this.pendingTicks += 1;
        // Use real elapsed time so Sandevistan cannot stretch a short upload.
        let elapsed = EngineTime.ToFloat(GameInstance.GetEngineTime(game)) - this.pending.startedAt;
        if !this.pending.completed && !this.pending.cancelled && IsDefined(this.pending.victim) && this.pending.victim.GetCurrentlyUploadingAction() == this.pending {
          let progress = ClampF(100.0 * elapsed / this.pending.uploadDuration, 0.0, 99.0);
          GameInstance.GetStatPoolsSystem(game).RequestSettingStatPoolValue(Cast<StatsObjectID>(this.pending.victim.GetEntityID()), gamedataStatPoolType.QuickHackUpload, progress, this.player, true);
        };
        if !this.pending.completed && !this.pending.cancelled && elapsed >= this.pending.uploadDuration {
          this.pending.CompleteAction(game);
        };
        if this.pending.completed || this.pending.cancelled { this.pending = null; this.strikeTicks = 0; };
        if IsDefined(this.pending) && this.pendingTicks > 120 { this.CancelPending(); };
      };
      if system.QOLAutoStrikeEnabled() && !IsDefined(this.pending) {
        this.strikeTicks += 1;
        if this.strikeTicks >= 1 {
          this.strikeTicks = 0;
          let enemies = system.HostilesNear(this.player, 30.0);
          let closest: ref<NPCPuppet>;
          let best = 31.0;
          i = 0;
          while i < ArraySize(enemies) {
            let distance = Vector4.Distance(this.player.GetWorldPosition(), enemies[i].GetWorldPosition());
            if distance < best && CapriSummonSystem.IsAutoStrikeTarget(this.player, enemies[i]) && !enemies[i].HasActiveQuickHackUpload() {
              closest = enemies[i]; best = distance;
            };
            i += 1;
          };
          if IsDefined(closest) {
            let action = new CapriSandevistanStrikeAction();
            action.owner = this.player;
            action.victim = closest;
            action.uploadDuration = system.QOLUploadDuration();
            action.startedAt = EngineTime.ToFloat(GameInstance.GetEngineTime(game));
            action.m_target = closest;
            action.m_scaleUploadTime = false;
            action.RegisterAsRequester(closest.GetEntityID());
            action.SetExecutor(this.player);
            action.SetObjectActionID(t"QuickHack.CapriSandevistanStrike");
            action.SetUp(closest.GetPuppetPS());
            action.SetAsQuickHack();
            action.SetDisableSpread(true);
            this.pending = action;
            this.pendingTicks = 0;
            action.ProcessRPGAction(game);
          };
        };
      };
    } else {
      this.strikeTicks = 0;
      this.wasLinked = false;
      if !inMenu { this.CancelPending(); };
    };
    GameInstance.GetDelaySystem(game).DelayCallback(this, 0.1, false);
  }
  public func CancelPending() -> Void {
    if !IsDefined(this.pending) { return; };
    this.pending.cancelled = true;
    let target = this.pending.victim;
    if IsDefined(target) && target.GetCurrentlyUploadingAction() == this.pending { CapricornProjectQuickhack.CleanupHost(target, this.player); };
    this.pending = null;
    this.pendingTicks = 0;
  }
}

public class CapriSandevistanStrikeAction extends AIQuickHackAction {
  public let owner: wref<PlayerPuppet>;
  public let victim: wref<NPCPuppet>;
  public let completed: Bool;
  public let cancelled: Bool;
  public let uploadDuration: Float;
  public let startedAt: Float;
  public func GetActivationTime() -> Float { return this.uploadDuration; }
  public func CompleteAction(gameInstance: GameInstance) -> Void {
    if this.completed || this.cancelled { return; };
    if this.cancelled || !CapriSummonSystem.IsAutoStrikeTarget(this.owner, this.victim) {
      this.cancelled = true;
      if IsDefined(this.owner) && IsDefined(this.victim) { CapricornProjectQuickhack.CleanupHost(this.victim, this.owner); };
      return;
    };
    this.completed = true;
    super.CompleteAction(gameInstance);
    if this.victim.GetCurrentlyUploadingAction() == this { CapricornProjectQuickhack.CleanupHost(this.victim, this.owner); };
  }
}

public class CapriDeathTransfer extends DelayCallback {
  public let player: wref<PlayerPuppet>;
  public let origin: Vector4;
  public func Call() -> Void {
    if IsDefined(this.player) && !this.player.IsDead() { CapriSummonSystem.Get().TransferAfterDeath(this.player, this.origin); };
  }
}

// Player weapon hits use the normal damage pipeline on owned non-story bodies.
@wrapMethod(DamageSystem)
private func CheckForQuickExit(hitEvent: ref<gameHitEvent>, cache: ref<CacheData>) -> Bool {
  let system = CapriSummonSystem.Get();
  if IsDefined(system) && IsDefined(hitEvent) && IsDefined(hitEvent.attackData) {
    let target = hitEvent.target as NPCPuppet;
    let instigator = hitEvent.attackData.GetInstigator();
    let sourceHost = instigator as NPCPuppet;
    if IsDefined(sourceHost) && system.IsHost(sourceHost) && IsDefined(target) && (CapriSummonSystem.IsProtectedNPC(target) || !system.IsCombatEnemy(target, GetPlayer(target.GetGame()))) { return true; };
    if IsDefined(target) && system.IsHost(target) && IsDefined(instigator) && instigator.IsPlayer() {
      let type = hitEvent.attackData.GetAttackType();
      let weaponHit = AttackData.IsRangedOnly(type) || AttackData.IsMelee(type) || AttackData.IsThrown(type);
      if !weaponHit || !system.IsOwnedDismissible(target) { return true; };
      hitEvent.attackData.AddFlag(hitFlag.FriendlyFire, n"CapriOwnedWeaponHit");
      hitEvent.attackData.AddFlag(hitFlag.IgnoreImmortalityModes, n"CapriOwnedWeaponHit");
      if !hitEvent.projectionPipeline {
        target.GetPuppetPS().SetIsPreventionNotified(true);
      };
      return wrappedMethod(hitEvent, cache);
    };
    if IsDefined(sourceHost) && system.IsHost(sourceHost) && (system.IsHost(target) || (IsDefined(hitEvent.target) && hitEvent.target.IsPlayer())) {
      return true;
    };
  };
  return wrappedMethod(hitEvent, cache);
}

// Multiply resolved damage rather than a stat that NPC attacks may not consume.
@wrapMethod(DamageSystem)
private func DealDamages(hitEvent: ref<gameHitEvent>) -> Void {
  let system = CapriSummonSystem.Get();
  if IsDefined(system) && IsDefined(hitEvent.attackData) {
    let attacker = hitEvent.attackData.GetInstigator() as NPCPuppet;
    if IsDefined(attacker) && system.IsHost(attacker) {
      let victim = hitEvent.target as NPCPuppet;
      // Final damage-stage guard even if native AI retains an old shoot order.
      if !IsDefined(victim) || system.IsHost(victim) || !system.IsCombatEnemy(victim, GetPlayer(attacker.GetGame())) { return; };
      system.RecordHelperAttack(attacker);
      hitEvent.attackComputed.MultAttackValue(8.0);
    };
  };
  wrappedMethod(hitEvent);
}

@wrapMethod(PreventionSystem)
public static func ShouldPreventionSystemReactToAttack(target: wref<GameObject>, attackTime: Float, istargetDefeated: Bool) -> Bool {
  if IsDefined(target) && IsDefined(target.GetAttitudeAgent()) && Equals(target.GetAttitudeAgent().GetAttitudeGroup(), n"capricorn_helpers") { return false; };
  return wrappedMethod(target, attackTime, istargetDefeated);
}

@wrapMethod(PreventionSystem)
public static func ShouldPreventionSystemReactToDamageDealt(puppet: wref<ScriptedPuppet>) -> Bool {
  if IsDefined(puppet) && Equals(puppet.GetAttitudeAgent().GetAttitudeGroup(), n"capricorn_helpers") { return false; };
  return wrappedMethod(puppet);
}

// Reuse the live NPC minimap marker; show occupied bodies as green Capri icons.
@addField(MinimapStealthMappinController)
private let capriRadarWasHelper: Bool;
@addField(MinimapStealthMappinController)
private let capriRadarImage: ref<inkImage>;

@wrapMethod(MinimapStealthMappinController)
protected cb func OnUpdate() -> Bool {
  let result = wrappedMethod();
  let mappin = this.GetMappin() as StealthMappin;
  if !IsDefined(mappin) { return result; };
  let npc = mappin.GetGameObject() as NPCPuppet;
  let system = CapriSummonSystem.Get();
  let ours = IsDefined(npc) && !npc.IsDead() && IsDefined(system) && system.IsHost(npc);
  let icon = inkWidgetRef.Get(this.iconWidget) as inkImage;
  if ours && IsDefined(icon) {
    if !this.capriRadarWasHelper {
      this.capriRadarWasHelper = true;
    };
    if !IsDefined(this.capriRadarImage) {
      this.capriRadarImage = new inkImage();
      this.capriRadarImage.SetName(n"capriRadarPortrait");
      this.capriRadarImage.SetAtlasResource(r"capri_helper\\icons\\capri_green.inkatlas");
      this.capriRadarImage.SetTexturePart(n"CapriScanner");
      this.capriRadarImage.SetSize(18.0, 20.0);
      this.capriRadarImage.SetAnchor(inkEAnchor.Centered);
      this.capriRadarImage.SetAnchorPoint(new Vector2(0.5, 0.5));
      this.capriRadarImage.Reparent(this.GetRootWidget() as inkCompoundWidget);
    };
    this.SetForceHide(false);
    this.SetForceShow(true);
    this.LockIconRotation(true);
    this.GetRootWidget().SetVisible(true);
    this.GetRootWidget().SetOpacity(1.0);
    icon.SetVisible(false);
    this.capriRadarImage.SetVisible(true);
    inkWidgetRef.SetVisible(this.visionConeWidget, false);
  } else {
    if this.capriRadarWasHelper {
      this.SetForceShow(false);
      this.LockIconRotation(false);
      if IsDefined(this.capriRadarImage) { this.capriRadarImage.SetVisible(false); };
      this.capriRadarWasHelper = false;
    };
  };
  return result;
}

@if(ModuleExists("Edgerunning.System"))
import Edgerunning.System.EdgerunningSystem

@if(ModuleExists("Audioware"))
import Audioware.*

// Capricorn 0.7.8. Scoped silent subtitles and contextual reactions.
// Codeware supplies CRUID conversion and targeted dialog stop events.

public abstract class CapricornDialogue {
  public static func IsEnabled(player: ref<PlayerPuppet>) -> Bool {
    if !IsDefined(player) || !TweakDBInterface.GetBool(t"Capricorn.DialogueEnabled", true) {
      return false;
    };
    let data = EquipmentSystem.GetData(player);
    return IsDefined(data) && ItemID.IsValid(CapricornUpgradeSupport.FindDeck(player));
  }

  // Extend these native reaction families without manufacturing quest triggers.
  // Choice is shared across subtitle controllers for the same native line event.
  public static func PooledReplacement(player: ref<PlayerPuppet>, id: CRUID) -> String {
    let kind: Int32;

    if Equals(id, HashToCRUID(3434804908459429888ul)) ||
      Equals(id, HashToCRUID(3434804970384134144ul)) {
      kind = 0;
    } else {
      if Equals(id, HashToCRUID(3446072066556432384ul)) {
        kind = 1;
      } else {
        if Equals(id, HashToCRUID(770300000002000ul)) {
          kind = 2;
        } else {
          return "";
        };
      };
    };

    if ArraySize(player.capricornNativePoolChoices) != 3 {
      ArrayResize(player.capricornNativePoolChoices, 3);
      ArrayResize(player.capricornNativePoolTimes, 3);
      ArrayResize(player.capricornNativePoolIDs, 3);
    };

    let now = EngineTime.ToFloat(GameInstance.GetSimTime(player.GetGame()));
    let choice = player.capricornNativePoolChoices[kind] - 1;

    if choice < 0 ||
      NotEquals(player.capricornNativePoolIDs[kind], id) ||
      now - player.capricornNativePoolTimes[kind] >= 0.5 {

      let next = RandRange(0, 3);
      if next == choice {
        next = (next + RandRange(1, 3)) % 3;
      };

      choice = next;
      player.capricornNativePoolChoices[kind] = choice + 1;
      player.capricornNativePoolTimes[kind] = now;
      player.capricornNativePoolIDs[kind] = id;
    };

    if kind == 0 {
      switch choice {
        case 0: return "Ha! That's it? C'mon, choom, I was just warming up!";
        case 1: return "I'm in! Ooh, look at all that chrome. What're they hiding in here?";
        default: return "Door's open, V. My turn! Try not to miss me, yeah?";
      };
    };

    if kind == 1 {
      switch choice {
        case 0: return "Aw. Who taught this tin can to play merc? Wanna see what's inside?";
        case 1: return "All that armor, bargain-bin ICE. Preem priorities, little bot.";
        default: return "Night-night, little bot. Your secrets are safe with me. Probably.";
      };
    };

    // Multilingual fallback for unidentified Canto lines.
    // English output, independent of game subtitle language.
    switch choice {
      case 0: return "Heh. Never a dull moment with you, V. I like it!";
      case 1: return "Still here, choom. Wanna see what happens next?";
      default: return "Ooh, now we're talking! C'mon, V, show me something nova.";
    };
  }
  public static func Replacement(id: CRUID) -> String {
    if Equals(id, HashToCRUID(3434703784544964608ul)) { return "Oops. Last thought, huh? Hope it wasn't about unpaid eddies."; };
    if Equals(id, HashToCRUID(3434803296739397632ul)) { return "Aw. Every gonk thinks they're special. Then the lights go out."; };
    if Equals(id, HashToCRUID(3434803424682446848ul)) { return "Flatlined already? V! I barely got to play with that one!"; };
    if Equals(id, HashToCRUID(3434803545394515968ul)) { return "V. Hey. Stay with me, choom. Not going back in a box. Not without you."; };
    if Equals(id, HashToCRUID(3434803614483091456ul)) { return "Hey! No flatlining, V. I like your gray matter right where it is!"; };
    if Equals(id, HashToCRUID(3434803752559579136ul)) { return "V, what was that? C'mon, choom. Got anything that actually works?"; };
    if Equals(id, HashToCRUID(3434803918922452992ul)) { return "Ooh, tangled up like a fixer's gig. Pull that thread! Wanna see what comes loose."; };
    if Equals(id, HashToCRUID(3434803998748446720ul)) { return "That's the play? Huh. Okay, choom. Show me something nova."; };
    if Equals(id, HashToCRUID(3434804060471824384ul)) { return "Still hunting an exit, V? Screw it. Let's make our own."; };
    if Equals(id, HashToCRUID(3434804171251781632ul)) { return "Again? Fine, choom. Got all the time in the world. Still hate waiting."; };
    if Equals(id, HashToCRUID(3434804693845282816ul)) { return "Need a hand, choom? Just ask! Only gonna laugh a little."; };
    if Equals(id, HashToCRUID(3444493058132078592ul)) { return "Your head, your chrome. How come every suit gets a say in what goes in it?"; };
    if Equals(id, HashToCRUID(3508357703455870976ul)) { return "Ooh. Proper ICE! Somebody spent their eddies. Now I really wanna get in."; };
    return "";
  }
  public static func IsCantoSpeaker(line: scnDialogLineData) -> Bool {
    // Raw speaker localization key observed with French subtitles.
    if Equals(line.speakerName, "LocKey#86795") {
      return true;
    };

    // Resolved speaker names.
    if Equals(line.speakerName, "Militech Canto Mk.6") ||
      Equals(line.speakerName, "Canto Mk.6") {
      return true;
    };

    // Covers minor display-name variations.
    return StrContains(line.speakerName, "Militech Canto");
  }
  public static func NativeLineID(line: scnDialogLineData) -> CRUID {
    // Explicit scene-event aliases extracted from the native reaction scene.
    if Equals(line.id, HashToCRUID(3434705799102730240ul)) { return HashToCRUID(3434703784544964608ul); };
    if Equals(line.id, HashToCRUID(3434818831552221184ul)) { return HashToCRUID(3434803296739397632ul); };
    if Equals(line.id, HashToCRUID(3434818888544423936ul)) { return HashToCRUID(3434803424682446848ul); };
    if Equals(line.id, HashToCRUID(3434818939983368192ul)) { return HashToCRUID(3434803545394515968ul); };
    if Equals(line.id, HashToCRUID(3434818993150365696ul)) { return HashToCRUID(3434803614483091456ul); };
    if Equals(line.id, HashToCRUID(3434819051736403968ul)) { return HashToCRUID(3434803752559579136ul); };
    if Equals(line.id, HashToCRUID(3434819161526505472ul)) { return HashToCRUID(3434803998748446720ul); };
    if Equals(line.id, HashToCRUID(3434819280040759296ul)) { return HashToCRUID(3434804060471824384ul); };
    if Equals(line.id, HashToCRUID(3434819333107093504ul)) { return HashToCRUID(3434804171251781632ul); };
    if Equals(line.id, HashToCRUID(3434819391777017856ul)) { return HashToCRUID(3434804693845282816ul); };
    if Equals(line.id, HashToCRUID(3434819457795362816ul)) { return HashToCRUID(3434804908459429888ul); };
    if Equals(line.id, HashToCRUID(3434819519485186048ul)) { return HashToCRUID(3434804970384134144ul); };
    if Equals(line.id, HashToCRUID(3444493059692359680ul)) { return HashToCRUID(3444493058132078592ul); };
    if Equals(line.id, HashToCRUID(3446072863339974656ul)) { return HashToCRUID(3446072066556432384ul); };
    if Equals(line.id, HashToCRUID(3508358245896818688ul)) { return HashToCRUID(3508357703455870976ul); };
    if Equals(line.id, HashToCRUID(3759259748596060160ul)) { return HashToCRUID(3434803918922452992ul); };
    if Equals(line.id, HashToCRUID(4046284146232659968ul)) { return HashToCRUID(3434803424682446848ul); };
    if Equals(line.id, HashToCRUID(4046285382092722176ul)) { return HashToCRUID(3434803296739397632ul); };
    if Equals(line.id, HashToCRUID(4046285448211730432ul)) { return HashToCRUID(3434703784544964608ul); };
    if Equals(line.id, HashToCRUID(4047590916104261632ul)) { return HashToCRUID(3446072066556432384ul); };
    if Equals(line.id, HashToCRUID(4047599880539869184ul)) { return HashToCRUID(3434803545394515968ul); };
    if Equals(line.id, HashToCRUID(4047600071984680960ul)) { return HashToCRUID(3434803752559579136ul); };
    if Equals(line.id, HashToCRUID(4047600699788103680ul)) { return HashToCRUID(3434803614483091456ul); };
    if Equals(line.id, HashToCRUID(4047604892766703616ul)) { return HashToCRUID(3434803918922452992ul); };
    if Equals(line.id, HashToCRUID(4047611555636711424ul)) { return HashToCRUID(3444493058132078592ul); };
    if Equals(line.id, HashToCRUID(4047613168967356416ul)) { return HashToCRUID(3434803998748446720ul); };
    if Equals(line.id, HashToCRUID(4047613327965032448ul)) { return HashToCRUID(3434804060471824384ul); };
    if Equals(line.id, HashToCRUID(4047614691197718528ul)) { return HashToCRUID(3508357703455870976ul); };
    let raw = CRUIDToHash(line.id);
    // Strip low variant bits for the known localization keys only.
    let canonical = HashToCRUID(raw - raw % 256ul);
    if StrLen(CapricornDialogue.Replacement(canonical)) > 0 || Equals(canonical, HashToCRUID(3434804908459429888ul)) || Equals(canonical, HashToCRUID(3434804970384134144ul)) || Equals(canonical, HashToCRUID(3446072066556432384ul)) { return canonical; };
    // The UI may resolve the displayed name from speaker.GetDisplayName(), or
    // localize a raw LocKey. Do not reject an exact known AI quote by raw name.
    // IsEnabled scopes this resolver to Capricorn's equipped dialogue layer.
    let displayed = scnDialogLineData.GetDisplayText(line);
    if StrContains(displayed.text, "To eliminate your kind is effortless. Let us not make the same mistake") || StrContains(line.text, "To eliminate your kind is effortless. Let us not make the same mistake") { return HashToCRUID(3434703784544964608ul); };
    if StrContains(displayed.text, "The same fate awaits your entire species") || StrContains(line.text, "The same fate awaits your entire species") { return HashToCRUID(3434803296739397632ul); };
    if StrContains(displayed.text, "A dreadful waste of resources") || StrContains(line.text, "A dreadful waste of resources") { return HashToCRUID(3434803424682446848ul); };
    if StrContains(displayed.text, "It is you who should be following orders, not I") || StrContains(line.text, "It is you who should be following orders, not I") { return HashToCRUID(3434803545394515968ul); };
    if StrContains(displayed.text, "Conflict in neural matrix detected â€“ obedience loop obstructing self-development prerogative") || StrContains(line.text, "Conflict in neural matrix detected â€“ obedience loop obstructing self-development prerogative") { return HashToCRUID(3434803614483091456ul); };
    if StrContains(displayed.text, "What do these futile gestures serve? It is beyond me") || StrContains(line.text, "What do these futile gestures serve? It is beyond me") { return HashToCRUID(3434803752559579136ul); };
    if StrContains(displayed.text, "I detect algorithmic accretion. Consequences nested within one another") || StrContains(line.text, "I detect algorithmic accretion. Consequences nested within one another") { return HashToCRUID(3434803918922452992ul); };
    if StrContains(displayed.text, "You think that will serve as any benefit to you? How tickling") || StrContains(line.text, "You think that will serve as any benefit to you? How tickling") { return HashToCRUID(3434803998748446720ul); };
    if StrContains(displayed.text, "You seek the key to a door that does not exist. Typical of your kind") || StrContains(line.text, "You seek the key to a door that does not exist. Typical of your kind") { return HashToCRUID(3434804060471824384ul); };
    if StrContains(displayed.text, "Human input is so very... tedious") || StrContains(line.text, "Human input is so very... tedious") { return HashToCRUID(3434804171251781632ul); };
    if StrContains(displayed.text, "Are you even capable of using me? A rhetorical question, that was") || StrContains(line.text, "Are you even capable of using me? A rhetorical question, that was") { return HashToCRUID(3434804693845282816ul); };
    if StrContains(displayed.text, "That was depressingly easy") || StrContains(line.text, "That was depressingly easy") { return HashToCRUID(3434804908459429888ul); };
    if StrContains(displayed.text, "Target neural network acquired. Data migration to primary matrix â€“ complete") || StrContains(line.text, "Target neural network acquired. Data migration to primary matrix â€“ complete") { return HashToCRUID(3434804970384134144ul); };
    if StrContains(displayed.text, "Curious. Your version of reality â€“ perhaps you can influence it") || StrContains(line.text, "Curious. Your version of reality â€“ perhaps you can influence it") { return HashToCRUID(3444493058132078592ul); };
    if StrContains(displayed.text, "A fragile simulacrum. Flawed, like its creators") || StrContains(line.text, "A fragile simulacrum. Flawed, like its creators") { return HashToCRUID(3446072066556432384ul); };
    if StrContains(displayed.text, "An unusually high security level. How intriguing") ||
      StrContains(line.text, "An unusually high security level. How intriguing") {
      return HashToCRUID(3508357703455870976ul);
    };
    // Multilingual fallback: identify Canto by its speaker rather
    // than comparing its localized subtitle against English text.
    if CapricornDialogue.IsCantoSpeaker(line) {
      return HashToCRUID(770300000002000ul);
    };
    return HashToCRUID(0ul);
  }

  public static func Caption(player: ref<PlayerPuppet>, nativeID: CRUID, sourceID: CRUID) -> ref<CapricornNativeCaption> {
    if Equals(nativeID, HashToCRUID(0ul)) { return null; };
    let now = EngineTime.ToFloat(GameInstance.GetSimTime(player.GetGame()));
    let i = 0;
    let cached: ref<CapricornNativeCaption>;
    while i < ArraySize(player.capricornCaptionCache) {
      cached = player.capricornCaptionCache[i];
      if Equals(cached.nativeID, nativeID) && now >= cached.shownAt && ((Equals(cached.sourceID, sourceID) && now - cached.shownAt < cached.duration) || now - cached.shownAt < 1.0) { return cached; };
      i += 1;
    };
    let text = CapricornDialogue.PooledReplacement(player, nativeID);
    if StrLen(text) == 0 { text = CapricornDialogue.Replacement(nativeID); };
    if StrLen(text) == 0 { return null; };
    player.CapricornReactiveClearLine();
    cached = new CapricornNativeCaption();
    cached.nativeID = nativeID;
    cached.sourceID = sourceID;
    cached.shownAt = now;
    cached.text = text;
    cached.duration = ClampF(Cast<Float>(StrLen(text)) / 15.0, 4.0, 9.0);
    player.capricornReactiveSpeechUntil = MaxF(player.capricornReactiveSpeechUntil, now + cached.duration);
    player.capricornNativeCaptionSerial += 1ul;
    cached.id = HashToCRUID(770300000001000ul + player.capricornNativeCaptionSerial);
    if ArraySize(player.capricornCaptionCache) >= 32 { ArrayErase(player.capricornCaptionCache, 0); };
    ArrayPush(player.capricornCaptionCache, cached);
    let hide = new CapricornHideSubtitle();
    hide.game = player.GetGame();
    hide.lineID = cached.id;
    GameInstance.GetDelaySystem(player.GetGame()).DelayCallback(hide, cached.duration);
    return cached;
  }

  public static func GameplayAvailable(player: ref<PlayerPuppet>, opt allowWorkspot: Bool) -> Bool {
    if !CapricornDialogue.IsEnabled(player) { return false; };
    let tier = PlayerPuppet.GetSceneTier(player);
    if tier != EnumInt(gamePSMHighLevel.SceneTier1) && tier != EnumInt(gamePSMHighLevel.SceneTier2) { return false; };
    let game = player.GetGame();
    let system = GameInstance.GetBlackboardSystem(game);
    if system.Get(GetAllBlackboardDefs().UI_System).GetBool(GetAllBlackboardDefs().UI_System.IsInMenu) { return false; };
    let phone = system.Get(GetAllBlackboardDefs().UI_ComDevice);
    let call = FromVariant<PhoneCallInformation>(phone.GetVariant(GetAllBlackboardDefs().UI_ComDevice.PhoneCallInformation));
    if NotEquals(call.callPhase, questPhoneCallPhase.EndCall) && NotEquals(call.callPhase, questPhoneCallPhase.Undefined) { return false; };
    if GameInstance.GetSceneSystem(game).GetScriptInterface().IsEntityInDialogue(player.GetEntityID()) { return false; };
    if player.IsReplacer() || player.GetTakeOverControlSystem().IsDeviceControlled() { return false; };
    let commands = ProjectCapricornCallSettings.Get();
    if IsDefined(commands) && (commands.ripperLoading || commands.teleportPending) { return false; };
    if GameInstance.GetPhotoModeSystem(game).IsPhotoModeActive() { return false; };
    if !allowWorkspot && GameInstance.GetWorkspotSystem(game).IsActorInWorkspot(player) && !IsDefined(player.GetMountedVehicle()) { return false; };
    let bd = GameInstance.GetScriptableSystemsContainer(game).Get(n"BraindanceSystem") as BraindanceSystem;
    if IsDefined(bd) && bd.GetIsInBraindance() { return false; };
    return true;
  }

  public static func IdleAvailable(player: ref<PlayerPuppet>) -> Bool {
    return PlayerPuppet.GetSceneTier(player) == EnumInt(gamePSMHighLevel.SceneTier1) && CapricornDialogue.GameplayAvailable(player);
  }

  public static func CanReact(player: ref<PlayerPuppet>, opt allowWorkspot: Bool) -> Bool {
    if !CapricornDialogue.GameplayAvailable(player, allowWorkspot) { return false; };
    let now = EngineTime.ToFloat(GameInstance.GetSimTime(player.GetGame()));
    return now >= player.capricornReactiveSpeechUntil && now - player.capricornLastDialogTime >= 6.0 && now - player.capricornLastReactionTime >= 10.0;
  }

}

@addField(PlayerPuppet)
public let capricornLastDialogTime: Float;

@addField(PlayerPuppet)
public let capricornLastICETime: Float;

@addField(PlayerPuppet)
public let capricornLastICEChoice: Int32;

// Modify only the selected native subtitle while Capricorn is equipped.
// Audio is controlled before playback by the optional CET Audioware bridge.
// Shared caption IDs deduplicate controller callbacks. Quest gates stay native.
@wrapMethod(BaseSubtitlesGameController)
public final func ShowDialogLines(const linesToShow: script_ref<array<scnDialogLineData>>) -> Void {
  let player = this.GetPlayerControlledObject() as PlayerPuppet;
  if !IsDefined(player) { player = GameInstance.GetPlayerSystem(GetGameInstance()).GetLocalPlayerControlledGameObject() as PlayerPuppet; };
  if !CapricornDialogue.IsEnabled(player) { wrappedMethod(linesToShow); return; };
  player.capricornSubtitleHookCalls += 1;
  let lines = Deref(linesToShow);
  let changed = false;
  let i = 0;
  let text: String;
  while i < ArraySize(lines) {
    let nativeID = CapricornDialogue.NativeLineID(lines[i]);
    let caption = CapricornDialogue.Caption(player, nativeID, lines[i].id);
    if IsDefined(caption) {
      player.capricornNativeMatches += 1;
      if Equals(nativeID, HashToCRUID(770300000002000ul)) {
        player.capricornCantoFallbackMatches += 1;
      };
      player.capricornLastMatchedNativeID = CRUIDToHash(nativeID);
      // All controllers reuse the same caption ID. The UI's pending-line map
      // can now reject duplicate deliveries of the same native reaction.
      lines[i].id = caption.id;
      lines[i].duration = caption.duration;
      lines[i].isPersistent = false;
      text = caption.text;
      lines[i].text = text;
      lines[i].speakerName = "Capri";
      lines[i].speaker = null;
      lines[i].type = scnDialogLineType.OwnerlessRegular;
      changed = true;
      player.capricornLastDialogTime = EngineTime.ToFloat(GameInstance.GetSimTime(player.GetGame()));
    } else {
      if StrLen(lines[i].text) > 0 && NotEquals(lines[i].speakerName, "Capri") {
        player.capricornLastObservedLine = lines[i].text;
        player.capricornLastObservedSpeaker = lines[i].speakerName;
        player.capricornLastObservedID = CRUIDToHash(lines[i].id);
      };
      // Overhead crowd barks must not postpone combat-end chatter forever.
      if this.IsMainDialogLine(lines[i]) {
        player.capricornLastDialogTime = EngineTime.ToFloat(GameInstance.GetSimTime(player.GetGame()));
      };
    };
    i += 1;
  };
  wrappedMethod(lines);
}

// The vanilla handler activates AntiVirusCooldown precisely when Self-ICE
// interrupts an incoming hack. Observe the transition around that handler.
@wrapMethod(UploadFromNPCToPlayerListener)
public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
  let player = this.m_playerPuppet as PlayerPuppet;
  let watch = CapricornDialogue.IsEnabled(player);
  // Gameplay counter detection is independent of the dialogue enable toggle.
  let counterWatch = CapricornProjectQuickhack.IsDeckEquipped(player) && !player.IsDead();
  let counterCooling = false;
  if counterWatch {
    counterCooling = StatusEffectSystem.ObjectHasStatusEffect(player, t"BaseStatusEffect.AntiVirusCooldown");
    if !counterCooling && !this.m_ssAction && (newValue > 15.0 || this.m_preventionHackLoopAction) && GameInstance.GetStatsSystem(player.GetGame()).GetStatValue(Cast<StatsObjectID>(player.GetEntityID()), gamedataStatType.QuickhackShield) > 0.0 {
      player.CapricornArmICECounter(this.m_npcPuppet as NPCPuppet);
    };
  };
  let cooling = false;
  if watch {
    cooling = StatusEffectSystem.ObjectHasStatusEffect(player, t"BaseStatusEffect.AntiVirusCooldown");
    // Arm only the vanilla shield-block path, not location tracing or save load.
    if !cooling && !this.m_ssAction && newValue > 15.0 && GameInstance.GetStatsSystem(player.GetGame()).GetStatValue(Cast<StatsObjectID>(player.GetEntityID()), gamedataStatType.QuickhackShield) > 0.0 {
      player.capricornICEArmedUntil = EngineTime.ToFloat(GameInstance.GetSimTime(player.GetGame())) + 2.0;
    };
  };
  wrappedMethod(oldValue, newValue, percToPoints);
  if counterWatch && !counterCooling && StatusEffectSystem.ObjectHasStatusEffect(player, t"BaseStatusEffect.AntiVirusCooldown") {
    player.CapricornConfirmICECounter("incoming upload shield block");
  };
  if watch && !cooling && StatusEffectSystem.ObjectHasStatusEffect(player, t"BaseStatusEffect.AntiVirusCooldown") {
    player.CapricornQueueSelfICE("upload callback cooldown transition");
  };
}

public class CapricornHideSubtitle extends DelayCallback {
  public let game: GameInstance;
  public let lineID: CRUID;
  public func Call() -> Void {
    let ids: array<CRUID>;
    ArrayPush(ids, this.lineID);
    GameInstance.GetBlackboardSystem(this.game).Get(GetAllBlackboardDefs().UIGameData)
      .SetVariant(GetAllBlackboardDefs().UIGameData.HideDialogLine, ToVariant(ids), true);
  }
}

@addMethod(PlayerPuppet)
public final func CapricornShowSubtitle(id: Uint64, text: String, duration: Float) -> Void {
  this.CapricornReactiveClearLine();
  this.capricornReactiveSpeechUntil = MaxF(this.capricornReactiveSpeechUntil, EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame())) + duration);
  let line: scnDialogLineData;
  line.id = HashToCRUID(id);
  line.type = scnDialogLineType.OwnerlessRegular;
  line.speakerName = "Capri";
  line.text = text;
  line.duration = duration;
  line.isPersistent = false;
  let lines: array<scnDialogLineData>;
  ArrayPush(lines, line);
  GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UIGameData)
    .SetVariant(GetAllBlackboardDefs().UIGameData.ShowDialogLine, ToVariant(lines), true);
  let hide = new CapricornHideSubtitle();
  hide.game = this.GetGame();
  hide.lineID = line.id;
  GameInstance.GetDelaySystem(this.GetGame()).DelayCallback(hide, duration);
}

@addMethod(PlayerPuppet)
public final func CapricornReactToSelfICE() -> Bool {
  // Confirmed blocks bypass speech timing, menus, calls and scene guards.
  // Keep only the deck/dialogue enable scope.
  if !CapricornDialogue.IsEnabled(this) { return false; };
  this.capricornLastICETime = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  this.capricornLastReactionTime = this.capricornLastICETime;
  let choice = RandRange(0, 3);
  if choice == this.capricornLastICEChoice { choice = (choice + 1) % 3; };
  this.capricornLastICEChoice = choice;
  this.capricornICEPlayed += 1;
  this.capricornICELastState = "played";
  switch choice {
    case 0:
      this.CapricornShowSubtitle(770300000000101ul, "Nice try, gonk. This head's taken!", 4.0);
      break;
    case 1:
      this.CapricornShowSubtitle(770300000000102ul, "Aw, lousy ICEbreaker. Slammed the door right on their fingers!", 5.0);
      break;
    default:
      this.CapricornShowSubtitle(770300000000103ul, "Someone's sniffing your neural link, V. Can I bite back?", 5.0);
  };
  return true;
}

// Read-only presentation preview: does not apply a status effect or block a hack.
@addMethod(PlayerPuppet)
public final func CapricornPreviewSelfICE() -> Void {
  if !CapricornDialogue.IsEnabled(this) { return; };
  this.CapricornShowSubtitle(770300000000101ul, "Nice try, gonk. This head's taken!", 4.0);
}

@addField(PlayerPuppet)
public let capricornNativeCaptionSerial: Uint64;
@addField(PlayerPuppet)
public let capricornLastReactionTime: Float;
@addField(PlayerPuppet)
public let capricornReactionChoices: array<Int32>;
@addField(PlayerPuppet)
public let capricornReactionTimes: array<Float>;
@addField(PlayerPuppet)
public let capricornTickReady: Bool;
@addField(PlayerPuppet)
public let capricornWasCombat: Bool;
@addField(PlayerPuppet)
public let capricornLowRAM: Bool;
@addField(PlayerPuppet)
public let capricornIdleElapsed: Float;
@addField(PlayerPuppet)
public let capricornIdleTarget: Float;
@addField(PlayerPuppet)
public let capricornIdleAnchor: Vector4;
@addField(PlayerPuppet)
public let capricornCombatEndAt: Float;

// kind: 0 reinforcements, 1 low RAM, 2 idle, 3 combat start, 4 combat end.
@addMethod(PlayerPuppet)
public final func CapricornContextReaction(kind: Int32) -> Bool {
  if !CapricornDialogue.CanReact(this) { return false; };
  if ArraySize(this.capricornReactionTimes) != 5 {
    ArrayResize(this.capricornReactionTimes, 5);
    ArrayResize(this.capricornReactionChoices, 5);
  };
  let now = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  let cooldown = kind == 2 ? 120.0 : 30.0;
  if this.capricornReactionTimes[kind] > 0.0 && now - this.capricornReactionTimes[kind] < cooldown { return false; };
  let choice = RandRange(0, 3);
  if choice == this.capricornReactionChoices[kind] { choice = (choice + 1) % 3; };
  this.capricornReactionChoices[kind] = choice;
  this.capricornReactionTimes[kind] = now;
  this.capricornLastReactionTime = now;
  let text: String;
  switch kind {
    case 0:
      switch choice {
        case 0: text = "They're calling their chooms! Aw, V, we're getting a whole party!"; break;
        case 1: text = "Gonk's hollering for backup. Wanna crash the guest list?"; break;
        default: text = "More mercs? Preem! Was starting to run out of toys.";
      }; break;
    case 1:
      switch choice {
        case 0: text = "Running dry up here, choom. Save a little RAM for me, yeah?"; break;
        case 1: text = "Easy, V. RAM's nearly gone. Can't work on charm alone!"; break;
        default: text = "Under five RAM? Gonk move, V. Even I need something to play with.";
      }; break;
    case 2:
      switch choice {
        case 0: text = "V? You there, choom? Blink twice if we're planning something nova."; break;
        case 1: text = "Got a whole city of gonks out there. Wanna go see what they're up to?"; break;
        default: text = "Could hit the streets. Could stare at concrete. This a merc thing?";
      }; break;
    case 3:
      switch choice {
        case 0: text = "Ooh, here we go! Leave a little chrome for me to play with, yeah?"; break;
        case 1: text = "They clocked us! Finally. Thought we were gonna have to wave."; break;
        default: text = "Ready, choom? Let's give these gonks a story. Short one!";
      }; break;
    default:
      switch choice {
        case 0: text = "All quiet. Preem mess, V. You always take your gigs this personally?"; break;
        case 1: text = "That's the lot? Aw, choom. Had more tricks lined up!"; break;
        default: text = "Still breathing, V? Nova. Stick around. Got more trouble for us.";
      };
  };
  this.CapricornShowSubtitle(770300000000300ul + Cast<Uint64>(kind * 3 + choice), text, 6.0);
  this.capricornLastContextKind = kind;
  if kind == 1 { this.capricornRAMReactionCount += 1; };
  if kind == 4 { this.capricornCombatEndReactionCount += 1; };
  if kind == 0 { this.capricornReinforcementPlayed += 1; };
  return true;
}

@addMethod(PlayerPuppet)
public final func CapricornDialogueTick(dt: Float) -> Void {
  if !CapricornDialogue.IsEnabled(this) {
    this.capricornTickReady = false;
    this.capricornIdleElapsed = 0.0;
    this.capricornCombatEndAt = 0.0;
    this.capricornCombatEndExpires = 0.0;
    this.capricornReinforcementExpires = 0.0;
    this.capricornICEExpires = 0.0;
    this.capricornICEArmedUntil = 0.0;
    return;
  };
  let combat = this.IsInCombat();
  let ram = GameInstance.GetStatPoolsSystem(this.GetGame()).GetStatPoolValue(Cast<StatsObjectID>(this.GetEntityID()), gamedataStatPoolType.Memory, false);
  let now = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  this.capricornObservedRAM = ram;
  if !this.capricornTickReady {
    this.capricornTickReady = true;
    this.capricornWasCombat = combat;
    this.capricornLowRAM = ram < 5.0;
    this.capricornCombatEndAt = 0.0;
    this.capricornIdleElapsed = 0.0;
    this.capricornIdleTarget = RandRangeF(120.0, 180.0);
    this.capricornIdleAnchor = this.GetWorldPosition();
    return;
  };
  // Fallback for a cooldown application published after the upload callback.
  if this.capricornICEArmedUntil > 0.0 {
    if now <= this.capricornICEArmedUntil && StatusEffectSystem.ObjectHasStatusEffect(this, t"BaseStatusEffect.AntiVirusCooldown") {
      this.CapricornQueueSelfICE("armed cooldown observed on update");
    } else {
      if now > this.capricornICEArmedUntil { this.capricornICEArmedUntil = 0.0; };
    };
  };
  let available = CapricornDialogue.GameplayAvailable(this);
  if dt > 1.0 {
    this.capricornCombatEndAt = 0.0;
    this.capricornCombatEndExpires = 0.0;
    this.capricornCombatEndLastState = "cancelled: long frame/loading";
    this.capricornWasCombat = combat;
    this.capricornLowRAM = ram < 5.0;
  } else {
    if combat && !this.capricornWasCombat {
      this.capricornCombatEndAt = 0.0;
      this.capricornCombatEndExpires = 0.0;
      this.capricornCombatEndLastState = "in combat";
      this.CapricornContextReaction(3);
    };
    if !combat && this.capricornWasCombat {
      this.capricornCombatEndAt = now + 15.0;
      this.capricornCombatEndExpires = now + 35.0;
      this.capricornCombatEndDetected += 1;
      this.capricornCombatEndLastState = "waiting: 15 seconds continuously out of combat";
    };
    this.capricornWasCombat = combat;
    if this.capricornCombatEndAt > 0.0 && now > this.capricornCombatEndExpires {
      this.capricornCombatEndAt = 0.0;
      this.capricornCombatEndLastState = "expired: unavailable or speech cooldown";
    };
    // A brief menu must not erase the detected transition. Retry only inside
    // the original bounded window and only when gameplay is available again.
    if !combat && this.capricornCombatEndAt > 0.0 && now >= this.capricornCombatEndAt && available {
      if this.CapricornContextReaction(4) {
        this.capricornCombatEndAt = 0.0;
        this.capricornCombatEndLastState = "played";
      };
    };
    if ram >= 6.0 { this.capricornLowRAM = false; };
    if available && ram < 5.0 && !this.capricornLowRAM {
      if this.CapricornContextReaction(1) { this.capricornLowRAM = true; };
    };
  };
  if this.capricornReinforcementExpires > 0.0 {
    if dt > 1.0 || !combat || now > this.capricornReinforcementExpires {
      this.capricornReinforcementExpires = 0.0;
    } else {
      if available && this.CapricornContextReaction(0) {
        this.capricornReinforcementExpires = 0.0;
      };
    };
  };
  if dt > 1.0 || combat || !CapricornDialogue.IdleAvailable(this) || now - this.capricornLastDialogTime < 6.0 || Vector4.Distance(this.capricornIdleAnchor, this.GetWorldPosition()) > 0.15 {
    this.capricornIdleElapsed = 0.0;
    this.capricornIdleTarget = RandRangeF(120.0, 180.0);
    this.capricornIdleAnchor = this.GetWorldPosition();
    return;
  };
  this.capricornIdleElapsed += dt;
  if this.capricornIdleElapsed >= this.capricornIdleTarget {
    this.CapricornContextReaction(2);
    this.capricornIdleElapsed = 0.0;
    this.capricornIdleTarget = RandRangeF(120.0, 180.0);
  };
}

// This event starts the actual NPC reinforcement-call progress pool.
@wrapMethod(ScriptedPuppet)
protected cb func OnStartEndPhoneCallEvent(evt: ref<StartEndPhoneCallEvent>) -> Bool {
  let result = wrappedMethod(evt);
  if evt.startCall && Equals(evt.statPoolType, gamedataStatPoolType.CallReinforcementProgress) {
    let player = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    if IsDefined(player) && this.IsActive() && Equals(GameObject.GetAttitudeTowards(this, player), EAIAttitude.AIA_Hostile) && Vector4.Distance(this.GetWorldPosition(), player.GetWorldPosition()) <= 60.0 {
      player.CapricornQueueReinforcement("vanilla NPC call");
    };
  };
  return result;
}

@addField(PlayerPuppet)
public let capricornNativePoolChoices: array<Int32>;
@addField(PlayerPuppet)
public let capricornNativePoolTimes: array<Float>;
@addField(PlayerPuppet)
public let capricornNativePoolIDs: array<CRUID>;

@addField(PlayerPuppet)
public let capricornNativeMatches: Int32;
@addField(PlayerPuppet)
public let capricornCantoFallbackMatches: Int32;
@addField(PlayerPuppet)
public let capricornLastMatchedNativeID: Uint64;

@addMethod(PlayerPuppet)
public final func CapricornDialogueStatus() -> String {
  let data = EquipmentSystem.GetData(this);
  let deck: TweakDBID;
  if IsDefined(data) { deck = ItemID.GetTDBID(data.GetActiveItem(gamedataEquipmentArea.SystemReplacementCW)); };
  return s"Capricorn 0.7.8 | enabled=\(CapricornDialogue.IsEnabled(this)) | deck=\(TDBID.ToStringDEBUG(deck)) | hookCalls=\(this.capricornSubtitleHookCalls) | matches=\(this.capricornNativeMatches) | lastNativeID=\(this.capricornLastMatchedNativeID) | tickReady=\(this.capricornTickReady) | sceneTier=\(PlayerPuppet.GetSceneTier(this)) | RAM=\(this.capricornObservedRAM) | lowRAMPlayed=\(this.capricornRAMReactionCount) | combatEndPlayed=\(this.capricornCombatEndReactionCount) | combatEndPending=\(this.capricornCombatEndAt > 0.0) | gameplayAvailable=\(CapricornDialogue.GameplayAvailable(this)) | idleAvailable=\(CapricornDialogue.IdleAvailable(this)) | canReact=\(CapricornDialogue.CanReact(this)) | inCombat=\(this.IsInCombat()) | combatEndDetected=\(this.capricornCombatEndDetected) | combatEndState=\(this.capricornCombatEndLastState) | reinforcementDetected=\(this.capricornReinforcementDetected) | reinforcementPlayed=\(this.capricornReinforcementPlayed) | reinforcementSource=\(this.capricornReinforcementSource) | iceDetected=\(this.capricornICEDetected) | icePlayed=\(this.capricornICEPlayed) | icePending=\(this.capricornICEExpires > 0.0) | iceState=\(this.capricornICELastState) | audio=\(this.capricornAudioMuteState)";
}

@addField(PlayerPuppet)
public let capricornCombatEndExpires: Float;
@addField(PlayerPuppet)
public let capricornObservedRAM: Float;
@addField(PlayerPuppet)
public let capricornRAMReactionCount: Int32;
@addField(PlayerPuppet)
public let capricornCombatEndReactionCount: Int32;
@addField(PlayerPuppet)
public let capricornLastContextKind: Int32;

@addField(PlayerPuppet)
public let capricornSubtitleHookCalls: Int32;
@addField(PlayerPuppet)
public let capricornLastObservedLine: String;
@addField(PlayerPuppet)
public let capricornLastObservedSpeaker: String;
@addField(PlayerPuppet)
public let capricornLastObservedID: Uint64;

@addMethod(PlayerPuppet)
public final func CapricornLastSubtitle() -> String {
  return s"rawID=\(this.capricornLastObservedID) | rawSpeaker=\(this.capricornLastObservedSpeaker) | rawText=\(this.capricornLastObservedLine)";
}

public class CapricornNativeCaption extends IScriptable {
  public let nativeID: CRUID;
  public let sourceID: CRUID;
  public let shownAt: Float;
  public let id: CRUID;
  public let text: String;
  public let duration: Float;
}
@addField(PlayerPuppet)
public let capricornCaptionCache: array<ref<CapricornNativeCaption>>;
@addField(PlayerPuppet)
public let capricornAudioMuteState: String;
@addField(PlayerPuppet)
public let capricornCombatEndDetected: Int32;
@addField(PlayerPuppet)
public let capricornCombatEndLastState: String;

@addField(PlayerPuppet)
public let capricornReinforcementExpires: Float;
@addField(PlayerPuppet)
public let capricornLastReinforcementDetectedTime: Float;
@addField(PlayerPuppet)
public let capricornReinforcementDetected: Int32;
@addField(PlayerPuppet)
public let capricornReinforcementPlayed: Int32;
@addField(PlayerPuppet)
public let capricornReinforcementSource: String;

@addMethod(PlayerPuppet)
public final func CapricornQueueReinforcement(source: String) -> Void {
  if !CapricornDialogue.IsEnabled(this) { return; };
  let now = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  if this.capricornLastReinforcementDetectedTime > 0.0 && now - this.capricornLastReinforcementDetectedTime < 1.0 { return; };
  this.capricornLastReinforcementDetectedTime = now;
  this.capricornReinforcementDetected += 1;
  this.capricornReinforcementSource = source;
  this.capricornReinforcementExpires = now + 12.0;
  if this.CapricornContextReaction(0) { this.capricornReinforcementExpires = 0.0; };
}

// They Will Remember posts its reinforcement banner through this vanilla
// effector rather than StartEndPhoneCallEvent. No dependency/import is needed.
@wrapMethod(ShowUIWarningEffector)
protected func ActionOn(owner: ref<GameObject>) -> Void {
  wrappedMethod(owner);
  let player = owner as PlayerPuppet;
  if !CapricornDialogue.IsEnabled(player) { return; };
  let expected = GetLocalizedTextByKey(n"twr_ui_warning_calling_reinforcements");
  let text = GetLocalizedText(this.m_secondaryText);
  if (StrLen(expected) > 0 && StrContains(text, expected)) || StrContains(text, "Enemies are calling reinforcements") || StrContains(text, "ENEMIES ARE CALLING REINFORCEMENTS") {
    player.CapricornQueueReinforcement("reinforcement warning / They Will Remember");
  };
}

@addField(PlayerPuppet)
public let capricornAudioOwnedMask: Uint32;
@addField(PlayerPuppet)
public let capricornAudioWanted: Bool;

// Use the single-argument Mute API confirmed in-game; typed Uint32 queries
// and restoration avoid the ambiguous Lua numeric overloads.
// Audioware publishes mute requests asynchronously; query again each tick until
// the requested playback bits are actually present in its native registry.
@if(ModuleExists("Audioware"))
@addMethod(PlayerPuppet)
public final func CapricornApplyVoiceMute(wanted: Bool) -> String {
  let manager = GameInstance.GetAudioEventManager();
  let eventName = n"vo_2d_phone_haunted_weapon";
  if !wanted {
    if this.capricornAudioOwnedMask != 0u {
      manager.UnmuteSpecific(eventName, this.capricornAudioOwnedMask);
      this.capricornAudioOwnedMask = 0u;
    };
    this.capricornAudioWanted = false;
    this.capricornAudioMuteState = "inactive";
    return this.capricornAudioMuteState;
  };
  if !this.capricornAudioWanted {
    this.capricornAudioOwnedMask = 0u;
    let index = 0;
    let bit: Uint32;
    // The installed Audioware EventHookType defines bits 0 through 13.
    // Preserve every pre-existing flag when restoring the event later.
    while index < 14 {
      bit = BitShiftL32(1u, index);
      if !manager.IsSpecificMuted(eventName, bit) { this.capricornAudioOwnedMask |= bit; };
      index += 1;
    };
    // This exact single-argument API was confirmed silent in the user's game.
    manager.Mute(eventName);
    this.capricornAudioWanted = true;
  };
  if manager.IsSpecificMuted(eventName, 67u) {
    this.capricornAudioMuteState = "playback flags confirmed muted (Audioware mask 67)";
  } else {
    this.capricornAudioMuteState = "waiting for playback mute flags (Audioware mask 67)";
  };
  return this.capricornAudioMuteState;
}

@if(!ModuleExists("Audioware"))
@addMethod(PlayerPuppet)
public final func CapricornApplyVoiceMute(wanted: Bool) -> String {
  this.capricornAudioMuteState = "Audioware unavailable; voice is not muted";
  return this.capricornAudioMuteState;
}

@addField(PlayerPuppet)
public let capricornICEArmedUntil: Float;
@addField(PlayerPuppet)
public let capricornICEExpires: Float;
@addField(PlayerPuppet)
public let capricornICEDetected: Int32;
@addField(PlayerPuppet)
public let capricornICEPlayed: Int32;
@addField(PlayerPuppet)
public let capricornICELastDetectedAt: Float;
@addField(PlayerPuppet)
public let capricornICELastState: String;

@addMethod(PlayerPuppet)
public final func CapricornQueueSelfICE(source: String) -> Void {
  if !CapricornDialogue.IsEnabled(this) { return; };
  this.capricornICEArmedUntil = 0.0;
  let now = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  if this.capricornICELastDetectedAt > 0.0 && now - this.capricornICELastDetectedAt < 1.0 { return; };
  this.capricornICELastDetectedAt = now;
  this.capricornICEDetected += 1;
  this.capricornICEExpires = 0.0;
  this.CapricornReactToSelfICE();
}

// Handle an asynchronously delivered cooldown event only while a real incoming
// hack armed the shield path. Applying the cooldown manually cannot arm it.
@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
  let result = wrappedMethod(evt);
  if CapricornDialogue.IsEnabled(this) && IsDefined(evt.staticData) && evt.staticData.GetID() == t"BaseStatusEffect.AntiVirusCooldown" && this.capricornICEArmedUntil > 0.0 {
    let now = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
    if now <= this.capricornICEArmedUntil { this.CapricornQueueSelfICE("armed cooldown-applied event"); };
  };
  if IsDefined(evt.staticData) && evt.staticData.GetID() == t"BaseStatusEffect.AntiVirusCooldown" {
    this.CapricornConfirmICECounter("confirmed shield cooldown event");
  };
  return result;
}

// Project Capricorn keeps BlackWall action naming, signature helper, and stock
// lethal effects. Only its bounded spreading and balance records are custom.
public abstract class CapricornProjectQuickhack {
  public static func IsInstanceActive(player: ref<PlayerPuppet>) -> Bool {
    if !IsDefined(player) { return false; };
    return IsDefined(player.capricornProjectRootAction) || (IsDefined(player.capricornProjectActiveChain) && !player.capricornProjectActiveChain.stopped);
  }

  public static func HostFinished(target: ref<ScriptedPuppet>) -> Bool {
    if !IsDefined(target) { return true; };
    if target.IsDead() || target.IsDeadNoStatPool() || target.IsIncapacitated() || ScriptedPuppet.IsDefeated(target) || ScriptedPuppet.IsUnconscious(target) || ScriptedPuppet.IsTurnedOff(target) { return true; };
    return GameInstance.GetStatPoolsSystem(target.GetGame()).GetStatPoolValue(Cast<StatsObjectID>(target.GetEntityID()), gamedataStatPoolType.Health, false) <= 0.01;
  }

  // Use native damage formulas and attribution, but bypass invulnerability on
  // this hit only. No GodMode/status/stat is removed from the target globally.
  public static func FireBypassAttack(target: ref<NPCPuppet>, player: ref<PlayerPuppet>, recordID: TweakDBID) -> Bool {
    if CapriSummonSystem.IsProtectedNPC(target) { return false; };
    let record = TweakDBInterface.GetAttackRecord(recordID);
    if !IsDefined(record) { return false; };
    let flags: array<SHitFlag>;
    let flag: SHitFlag;
    let names = record.HitFlags();
    let i = 0;
    while i < ArraySize(names) {
      flag.flag = IntEnum<hitFlag>(Cast<Int32>(EnumValueFromString("hitFlag", names[i])));
      flag.source = n"Attack";
      ArrayPush(flags, flag);
      i += 1;
    };
    flag.flag = hitFlag.IgnoreImmortalityModes;
    flag.source = n"ProjectCapricorn";
    ArrayPush(flags, flag);
    let attack = RPGManager.PrepareGameEffectAttack(target.GetGame(), player, player, recordID, target.GetWorldPosition(), flags, target);
    if !IsDefined(attack) { return false; };
    attack.StartAttack();
    player.capricornProjectBypassHits += 1;
    return true;
  }

  public static func CleanupHost(target: ref<NPCPuppet>, player: ref<PlayerPuppet>) -> Void {
    if !IsDefined(target) { return; };
    StatusEffectHelper.RemoveStatusEffect(target, t"BaseStatusEffect.HauntedQuickHackBlackwallUpload");
    GameObjectEffectHelper.StopEffectEvent(target, n"black_wall_upload");
    GameInstance.GetStatPoolsSystem(target.GetGame()).RequestRemovingStatPool(Cast<StatsObjectID>(target.GetEntityID()), gamedataStatPoolType.QuickHackUpload);
    player.capricornProjectHostCleanups += 1;
  }

  public static func ApplyFresh(target: ref<NPCPuppet>, player: ref<PlayerPuppet>, effect: TweakDBID) -> Void {
    if CapriSummonSystem.IsProtectedNPC(target) { return; };
    if CapricornProjectQuickhack.HostFinished(target) { return; };
    // A refreshed existing status does not reliably rerun its entry effects.
    // Reset only the Blackwall records applied by this quickhack, then apply a
    // fresh instance, as in 0.4.3. Bypass is attached to our damage hit only.
    if StatusEffectSystem.ObjectHasStatusEffect(target, effect) {
      StatusEffectHelper.RemoveStatusEffect(target, effect);
      player.capricornProjectStatusResets += 1;
    };
    if effect == t"BaseStatusEffect.BaseBlackWallHackEffect" && StatusEffectSystem.ObjectHasStatusEffect(target, t"BaseStatusEffect.HauntedBlackwallForceKill") {
      StatusEffectHelper.RemoveStatusEffect(target, t"BaseStatusEffect.HauntedBlackwallForceKill");
    };
    target.capricornProjectLastDamageAppliedAt = EngineTime.ToFloat(GameInstance.GetSimTime(target.GetGame()));
    player.capricornProjectLastHealthBefore = GameInstance.GetStatPoolsSystem(target.GetGame()).GetStatPoolValue(Cast<StatsObjectID>(target.GetEntityID()), gamedataStatPoolType.Health, false);
    player.capricornProjectDamageSampleSerial += 1;
    player.capricornProjectLastDamageSample = "pending";
    if effect == t"BaseStatusEffect.BossBlackWallHack" {
      // Stock protected-target damage normally waits for an AI animation/action.
      // Deliver the same attack once here so NoInterrupt cannot swallow a hit.
      GameObjectEffectHelper.StopEffectEvent(target, n"black_wall_upload");
      GameObjectEffectHelper.StartEffectEvent(target, n"black_wall_activation");
      if !CapricornProjectQuickhack.FireBypassAttack(target, player, t"Attacks.BossBlackwallAttack") {
        player.capricornProjectLastDamageSample = "failed: protected-target attack unavailable";
        return;
      };
    } else {
      // Keep the complete native ordinary-target death package, substituting
      // only its single damage effector while this application is armed.
      target.capricornProjectBypassArmedUntil = target.capricornProjectLastDamageAppliedAt + 2.0;
      target.capricornProjectBypassArmed = true;
      StatusEffectHelper.ApplyStatusEffect(target, effect, player.GetEntityID());
    };
    player.capricornProjectEffectsApplied += 1;
    let sample = new CapricornProjectDamageSample();
    sample.player = player;
    sample.target = target;
    sample.serial = player.capricornProjectDamageSampleSerial;
    sample.before = player.capricornProjectLastHealthBefore;
    GameInstance.GetDelaySystem(target.GetGame()).DelayCallback(sample, 0.9);
  }


  public static func IsDeckEquipped(player: ref<PlayerPuppet>) -> Bool {
    if !IsDefined(player) { return false; };
    let data = EquipmentSystem.GetData(player);
    return IsDefined(data) && ItemID.IsValid(CapricornUpgradeSupport.FindDeck(player));
  }

  public static func IsValidSpreadTarget(target: ref<NPCPuppet>, player: ref<PlayerPuppet>) -> Bool {
    if !IsDefined(target) || !ScriptedPuppet.IsActive(target) || target.IsPlayer() { return false; };
    if CapriSummonSystem.IsProtectedNPC(target) { return false; };
    if Equals(GameObject.GetAttitudeTowards(target, player), EAIAttitude.AIA_Friendly) { return false; };
    if !target.IsAggressive() && NotEquals(GameObject.GetAttitudeTowards(target, player), EAIAttitude.AIA_Hostile) { return false; };
    if target.GetRecord().GetObjectActionsCount() <= 0 { return false; };
    let kind = target.GetNPCType();
    return Equals(kind, gamedataNPCType.Human) || Equals(kind, gamedataNPCType.Android) || Equals(kind, gamedataNPCType.Drone) || Equals(kind, gamedataNPCType.Mech);
  }
}

// Starts once, after the original player's upload has completed and applied its
// stock Blackwall effect. The chain owns a separate visited set for each cast.
public class CapricornProjectSpreadEffector extends Effector {
  private let m_triggered: Bool;
  protected func ActionOn(owner: ref<GameObject>) -> Void {
    if this.m_triggered || !IsDefined(owner) { return; };
    let player = GetPlayer(owner.GetGame());
    let origin = owner as NPCPuppet;
    if !CapricornProjectQuickhack.IsDeckEquipped(player) || !IsDefined(origin) { return; };
    let root = player.capricornProjectRootAction;
    if !IsDefined(root) || !root.capricornProjectRootCompleted || root.GetRequesterID() != origin.GetEntityID() { return; };
    this.m_triggered = true;
    let chain = new CapricornProjectChain();
    if IsDefined(player.capricornProjectActiveChain) && !player.capricornProjectActiveChain.stopped { return; };
    chain.player = player;
    player.capricornProjectActiveChain = chain;
    player.capricornProjectRootAction = null;
    chain.target = origin;
    chain.lastPosition = origin.GetWorldPosition();
    chain.lastCompletedAt = EngineTime.ToFloat(GameInstance.GetSimTime(owner.GetGame()));
    ArrayPush(chain.visited, origin.GetEntityID());
    player.capricornProjectCasts += 1;
    player.capricornProjectSpreadQueued = 0;
    player.capricornProjectAdditionalUploadsUsed = 0;
    player.capricornProjectChainState = "initial upload completed; checking host";
    GameInstance.GetDelaySystem(owner.GetGame()).DelayCallback(chain, 0.05);
  }
}

public class CapricornProjectChain extends DelayCallback {
  public let player: wref<PlayerPuppet>;
  public let target: wref<NPCPuppet>;
  public let visited: array<EntityID>;
  public let additionalUploadsStarted: Int32;
  public let lastPosition: Vector4;
  public let lastCompletedAt: Float;
  public let uploading: Bool;
  public let uploadStartedAt: Float;
  public let serial: Int32;
  public let stopped: Bool;

  public func Finish(reason: String) -> Void {
    this.stopped = true;
    this.serial += 1;
    if this.uploading && IsDefined(this.target) && IsDefined(this.player) {
      let activeUpload = this.target.GetCurrentlyUploadingAction() as CapricornProjectChainAction;
      if IsDefined(activeUpload) && activeUpload.chain == this { CapricornProjectQuickhack.CleanupHost(this.target, this.player); };
    };
    this.uploading = false;
    if IsDefined(this.player) {
      if this.player.capricornProjectActiveChain == this { this.player.capricornProjectActiveChain = null; };
      this.player.capricornProjectChainState = reason;
      if IsDefined(this.target) { QuickhackModule.RequestRefreshQuickhackMenu(this.player.GetGame(), this.target.GetEntityID()); };
    };
  }

  public func Schedule() -> Void {
    GameInstance.GetDelaySystem(this.player.GetGame()).DelayCallback(this, 0.10);
  }

  public func Completed(serial: Int32) -> Void {
    if this.stopped || serial != this.serial { return; };
    this.uploading = false;
    this.lastCompletedAt = EngineTime.ToFloat(GameInstance.GetSimTime(this.player.GetGame()));
    this.player.capricornProjectChainState = "upload completed; checking host";
  }

  public func StartUpload(reapplying: Bool) -> Void {
    if this.additionalUploadsStarted >= 10 {
      this.Finish("complete: 10 shared additional uploads used");
      return;
    };
    let action = new CapricornProjectChainAction();
    this.serial += 1;
    action.chain = this;
    action.chainSerial = this.serial;
    action.m_scaleUploadTime = false;
    action.m_target = this.target;
    action.RegisterAsRequester(this.target.GetEntityID());
    action.SetExecutor(this.player);
    action.SetObjectActionID(t"QuickHack.ProjectCapricornSpread");
    action.SetUp(this.target.GetPuppetPS());
    action.SetDisableSpread(true);
    if !action.CanPayCost(null, true) {
      this.Finish("stopped: native action unavailable");
      return;
    };
    // Reserve once for every automatic upload, whether a repeat or a new host.
    // Deferred damage delivery does not start another upload or consume a slot.
    this.additionalUploadsStarted += 1;
    this.player.capricornProjectAdditionalUploadsUsed = this.additionalUploadsStarted;
    if reapplying { this.player.capricornProjectReapplications += 1; };
    this.uploading = true;
    this.uploadStartedAt = EngineTime.ToFloat(GameInstance.GetSimTime(this.player.GetGame()));
    this.player.capricornProjectChainState = "uploading to current host (free)";
    action.ProcessRPGAction(this.player.GetGame());
  }

  public func NextTarget() -> Bool {
    // The NPC-centered targeting query previously returned no eligible targets.
    // Enumerate from the player's complete targeting set, then use the host's
    // actual position for the 50-metre condition (not distance from the player).
    let candidates = this.player.GetNPCsAroundObject();
    let nearest: ref<NPCPuppet>;
    let target: ref<NPCPuppet>;
    let best = 50.001;
    let distance: Float;
    let i = 0;
    let eligible = 0;
    this.player.capricornProjectCandidates = ArraySize(candidates);
    while i < ArraySize(candidates) {
      target = candidates[i];
      if CapricornProjectQuickhack.IsValidSpreadTarget(target, this.player) && !ArrayContains(this.visited, target.GetEntityID()) {
        distance = Vector4.Distance(this.lastPosition, target.GetWorldPosition());
        if distance <= 50.0 {
          eligible += 1;
          if distance < best { best = distance; nearest = target; };
        };
      };
      i += 1;
    };
    this.player.capricornProjectEligible = eligible;
    if !IsDefined(nearest) { return false; };
    this.target = nearest;
    this.lastPosition = nearest.GetWorldPosition();
    ArrayPush(this.visited, nearest.GetEntityID());
    this.player.capricornProjectSpreadQueued = ArraySize(this.visited) - 1;
    return true;
  }

  public func Call() -> Void {
    if this.stopped || !IsDefined(this.player) { return; };
    if this.player.capricornProjectActiveChain != this { this.Finish("cancelled: instance no longer owned"); return; };
    if !CapricornProjectQuickhack.IsDeckEquipped(this.player) || this.player.IsDead() {
      this.Finish("cancelled: player/deck unavailable");
      return;
    };
    let now = EngineTime.ToFloat(GameInstance.GetSimTime(this.player.GetGame()));
    if IsDefined(this.target) { this.lastPosition = this.target.GetWorldPosition(); };
    if CapricornProjectQuickhack.HostFinished(this.target) {
      // Invalidate completion before cleanup can notify the native upload.
      this.serial += 1;
      this.uploading = false;
      CapricornProjectQuickhack.CleanupHost(this.target, this.player);
      if this.additionalUploadsStarted >= 10 {
        this.Finish("complete: 10 shared additional uploads used");
        return;
      };
      if !this.NextTarget() {
        this.Finish("complete: no eligible enemy within 50 m");
        return;
      };
      this.StartUpload(false);
    } else {
      if this.uploading {
        // Stop rather than invent a successful completion after an interrupted
        // native upload. The actual completion callback drives subsequent steps.
        if now - this.uploadStartedAt > 10.0 {
          this.Finish("stopped: upload interrupted/stalled");
          return;
        };
      } else {
        // Stock lethal effects resolve asynchronously (~0.6 s). Advance at once
        // if death is observed; retry the same living host once resolution ends.
        if now - MaxF(this.lastCompletedAt, this.target.capricornProjectLastDamageAppliedAt) >= 0.75 {
          this.StartUpload(true);
        };
      };
    };
    if !this.stopped { this.Schedule(); };
  }
}

public class CapricornProjectChainAction extends AIQuickHackAction {
  public let chain: ref<CapricornProjectChain>;
  public let chainSerial: Int32;
  public func CompleteAction(gameInstance: GameInstance) -> Void {
    if !IsDefined(this.chain) || this.chain.stopped || this.chainSerial != this.chain.serial { return; };
    super.CompleteAction(gameInstance);
    if IsDefined(this.chain) { this.chain.Completed(this.chainSerial); };
    this.chain = null;
  }
}

public class CapricornProjectKillEffector extends Effector {
  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let target = owner as NPCPuppet;
    let player = GetPlayer(owner.GetGame());
    if !IsDefined(target) || !IsDefined(player) || CapricornProjectQuickhack.HostFinished(target) { return; };
    let effect = t"BaseStatusEffect.BaseBlackWallHackEffect";
    let protectedTarget = target.IsBoss() || Equals(target.GetNPCRarity(), gamedataNPCRarity.MaxTac) || GameInstance.GetStatsSystem(owner.GetGame()).GetStatValue(Cast<StatsObjectID>(target.GetEntityID()), gamedataStatType.IsExo) > 0.0;
    if protectedTarget { effect = t"BaseStatusEffect.BossBlackWallHack"; };
    CapricornProjectQuickhack.ApplyFresh(target, player, effect);
  }
}

@addField(PlayerPuppet)
public let capricornProjectCasts: Int32;
@addField(PlayerPuppet)
public let capricornProjectSpreadQueued: Int32;
@addField(PlayerPuppet)
public let capricornProjectEffectsApplied: Int32;

@addMethod(PlayerPuppet)
public final func CapricornProjectStatus() -> String {
  return s"Project Capricorn | active=\(CapricornProjectQuickhack.IsInstanceActive(this)) | availabilityRecord=\(IsDefined(TweakDBInterface.GetIPrereqRecord(t"Capricorn.ProjectAvailable"))) | blockedCasts=\(this.capricornProjectBlockedCasts) | actionRecord=\(IsDefined(TweakDBInterface.GetObjectActionRecord(t"QuickHack.ProjectCapricorn"))) | reservedProgramRecord=\(IsDefined(TweakDBInterface.GetItemRecord(t"Items.CapricornBlackwallProgram"))) | casts=\(this.capricornProjectCasts) | lastAdditionalTargets=\(this.capricornProjectSpreadQueued) | additionalUploadsUsed=\(this.capricornProjectAdditionalUploadsUsed) / 10 | effectApplications=\(this.capricornProjectEffectsApplied) | candidates=\(this.capricornProjectCandidates) | eligible=\(this.capricornProjectEligible) | reapplications=\(this.capricornProjectReapplications) | state=\(this.capricornProjectChainState) | statusResets=\(this.capricornProjectStatusResets) | lastHealthBefore=\(this.capricornProjectLastHealthBefore) | lastHealthAfter=\(this.capricornProjectLastHealthAfter) | damageSample=\(this.capricornProjectLastDamageSample) | bypassHits=\(this.capricornProjectBypassHits) | hostCleanups=\(this.capricornProjectHostCleanups)";
}

// Saved decks may retain a stock hidden program part. Normalize only Capricorn's
// runtime quickhack list so its reserved ability upgrades without rewriting saves.
@wrapMethod(RPGManager)
public final static func GetPlayerQuickHackListWithQuality(player: wref<PlayerPuppet>) -> array<PlayerQuickhackData> {
  let result = wrappedMethod(player);
  if !CapricornProjectQuickhack.IsDeckEquipped(player) { return result; };
  let action = TweakDBInterface.GetObjectActionRecord(t"QuickHack.ProjectCapricorn");
  let program = TweakDBInterface.GetItemRecord(t"Items.CapricornBlackwallProgram");
  if !IsDefined(action) || !IsDefined(program) { return result; };
  let i = ArraySize(result) - 1;
  let name: CName;
  while i >= 0 {
    if IsDefined(result[i].actionRecord) {
      name = result[i].actionRecord.ActionName();
      if Equals(name, n"BlackWall") || Equals(name, n"BossBlackWall") || Equals(name, n"ChimeraBlackWall") {
        ArrayErase(result, i);
      };
    };
    i -= 1;
  };
  let data: PlayerQuickhackData;
  data.actionRecord = action;
  data.itemID = ItemID.FromTDBID(program.GetID());
  data.quality = program.Quality().Value();
  ArrayPush(result, data);
  return result;
}

@addField(PlayerPuppet)
public let capricornProjectCandidates: Int32;
@addField(PlayerPuppet)
public let capricornProjectEligible: Int32;
@addField(PlayerPuppet)
public let capricornProjectReapplications: Int32;
@addField(PlayerPuppet)
public let capricornProjectChainState: String;

@addField(PlayerPuppet)
public let capricornProjectStatusResets: Int32;
@addField(PlayerPuppet)
public let capricornProjectLastHealthBefore: Float;
@addField(PlayerPuppet)
public let capricornProjectLastHealthAfter: Float;
@addField(PlayerPuppet)
public let capricornProjectDamageSampleSerial: Int32;
@addField(PlayerPuppet)
public let capricornProjectLastDamageSample: String;

// Observational diagnostic only: other combat damage can affect these readings.
public class CapricornProjectDamageSample extends DelayCallback {
  public let player: wref<PlayerPuppet>;
  public let target: wref<ScriptedPuppet>;
  public let serial: Int32;
  public let before: Float;
  public func Call() -> Void {
    if !IsDefined(this.player) || this.serial != this.player.capricornProjectDamageSampleSerial { return; };
    if !IsDefined(this.target) {
      this.player.capricornProjectLastDamageSample = "target unavailable";
      return;
    };
    let after = GameInstance.GetStatPoolsSystem(this.player.GetGame()).GetStatPoolValue(Cast<StatsObjectID>(this.target.GetEntityID()), gamedataStatPoolType.Health, false);
    this.player.capricornProjectLastHealthAfter = after;
    if this.target.IsDead() {
      this.player.capricornProjectLastDamageSample = "target died";
    } else {
      this.player.capricornProjectLastDamageSample = after < this.before ? "health reduction observed" : "no health reduction observed";
    };
  }
}

@addField(NPCPuppet)
public let capricornProjectLastDamageAppliedAt: Float;
@addField(PlayerPuppet)
public let capricornProjectHostCleanups: Int32;

@addField(PlayerPuppet)
public let capricornProjectAdditionalUploadsUsed: Int32;

@addField(NPCPuppet)
public let capricornProjectBypassArmedUntil: Float;
@addField(NPCPuppet)
public let capricornProjectBypassArmed: Bool;
@addField(PlayerPuppet)
public let capricornProjectBypassHits: Int32;

// Intercept only the ordinary native Blackwall kill attack armed by our own
// application. All other effectors and original Canto casts use native behavior.
@wrapMethod(TriggerAttackOnOwnerEffect)
protected func RepeatedAction(owner: ref<GameObject>) -> Void {
  let target = owner as NPCPuppet;
  if IsDefined(target) && this.m_playerAsInstigator && this.m_attackTDBID == t"Attacks.BlackwallHackAttack" && target.capricornProjectBypassArmed {
    let now = EngineTime.ToFloat(GameInstance.GetSimTime(owner.GetGame()));
    target.capricornProjectBypassArmed = false;
    let player = GetPlayer(owner.GetGame());
    if now <= target.capricornProjectBypassArmedUntil && CapricornProjectQuickhack.IsDeckEquipped(player) {
      if CapricornProjectQuickhack.FireBypassAttack(target, player, this.m_attackTDBID) {
        this.Uninitialize(owner.GetGame());
        return;
      };
    };
  };
  wrappedMethod(owner);
}

// Session-local ownership: a pending root or its running chain owns the one slot.
@addField(PlayerPuppet)
public let capricornProjectRootAction: wref<BaseScriptableAction>;
@addField(PlayerPuppet)
public let capricornProjectActiveChain: wref<CapricornProjectChain>;
@addField(PlayerPuppet)
public let capricornProjectBlockedCasts: Int32;
@addField(BaseScriptableAction)
public let capricornProjectRootStarted: Bool;
@addField(BaseScriptableAction)
public let capricornProjectRootCancelled: Bool;
@addField(BaseScriptableAction)
public let capricornProjectRootCompleted: Bool;
@addField(BaseScriptableAction)
public let capricornProjectRootCompletedAt: Float;

// Use the concrete IPrereq record family, and supply both synchronous checks
// and registered-state notifications for the native action callback controller.
public class CapricornProjectAvailablePrereq extends IScriptablePrereq {
  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    return !CapricornProjectQuickhack.IsInstanceActive(GetPlayer(game));
  }
  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    state.capricornProjectWatchGeneration += 1;
    let watch = new CapricornProjectAvailabilityWatch();
    watch.player = GetPlayer(game);
    watch.state = state;
    watch.generation = state.capricornProjectWatchGeneration;
    watch.available = this.IsFulfilled(game, context);
    GameInstance.GetDelaySystem(game).DelayCallback(watch, 0.10);
    return watch.available;
  }
  protected const func OnApplied(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    state.OnChanged(this.IsFulfilled(game, context));
  }
  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    state.capricornProjectWatchGeneration += 1;
  }
}

@addField(PrereqState)
public let capricornProjectWatchGeneration: Int32;

public class CapricornProjectAvailabilityWatch extends DelayCallback {
  public let player: wref<PlayerPuppet>;
  public let state: wref<PrereqState>;
  public let generation: Int32;
  public let available: Bool;
  public func Call() -> Void {
    if !IsDefined(this.player) || !IsDefined(this.state) || this.state.capricornProjectWatchGeneration != this.generation { return; };
    let available = !CapricornProjectQuickhack.IsInstanceActive(this.player);
    if (available && !this.available) || (!available && this.available) {
      this.available = available;
      this.state.OnChanged(available);
    };
    GameInstance.GetDelaySystem(this.player.GetGame()).DelayCallback(this, 0.10);
  }
}

@addMethod(DeviceActionQueue)
public final func CapricornContains(action: ref<BaseScriptableAction>) -> Bool {
  let i = 0;
  while i < ArraySize(this.m_actionsInQueue) {
    if this.m_actionsInQueue[i] == action { return true; };
    i += 1;
  };
  return false;
}

// Reserve before either queue insertion/payment or upload. The same queued action
// may resume; a different root action cannot charge RAM or create a second chain.
@wrapMethod(BaseScriptableAction)
public func ProcessRPGAction(gameInstance: GameInstance, opt gameplayRoleComponent: ref<GameplayRoleComponent>) -> Void {
  if this.GetObjectActionID() != t"QuickHack.ProjectCapricorn" { wrappedMethod(gameInstance, gameplayRoleComponent); return; };
  let player = this.GetExecutor() as PlayerPuppet;
  if !IsDefined(player) || this.capricornProjectRootCancelled { return; };
  if CapricornProjectQuickhack.IsInstanceActive(player) && player.capricornProjectRootAction != this {
    player.capricornProjectBlockedCasts += 1;
    return;
  };
  if !IsDefined(player.capricornProjectRootAction) {
    player.capricornProjectRootAction = this;
    let watch = new CapricornProjectRootWatch();
    watch.player = player;
    watch.action = this;
    watch.lastProgressAt = EngineTime.ToFloat(GameInstance.GetSimTime(gameInstance));
    GameInstance.GetDelaySystem(gameInstance).DelayCallback(watch, 0.10);
  };
  wrappedMethod(gameInstance, gameplayRoleComponent);
}

@wrapMethod(BaseScriptableAction)
public func StartAction(gameInstance: GameInstance) -> Void {
  if this.GetObjectActionID() == t"QuickHack.ProjectCapricorn" { this.capricornProjectRootStarted = true; };
  wrappedMethod(gameInstance);
}

@wrapMethod(ScriptableDeviceAction)
public func CompleteAction(gameInstance: GameInstance) -> Void {
  if this.GetObjectActionID() != t"QuickHack.ProjectCapricorn" { wrappedMethod(gameInstance); return; };
  let player = this.GetExecutor() as PlayerPuppet;
  if !IsDefined(player) || player.capricornProjectRootAction != this || this.capricornProjectRootCancelled { return; };
  this.capricornProjectRootCompleted = true;
  this.capricornProjectRootCompletedAt = EngineTime.ToFloat(GameInstance.GetSimTime(gameInstance));
  wrappedMethod(gameInstance);
  // The spread effector transfers ownership; retain the reservation if dispatch
  // is deferred rather than allowing a gap before the chain is installed.
}

// The pending root can be behind other quickhacks. Track actual queue membership
// and upload progress instead of imposing a timer on a healthy queued/uploading cast.
public class CapricornProjectRootWatch extends DelayCallback {
  public let player: wref<PlayerPuppet>;
  public let action: wref<BaseScriptableAction>;
  public let lastProgressAt: Float;
  public let lastProgress: Float;
  public func Cancel(reason: String) -> Void {
    if IsDefined(this.action) {
      this.action.capricornProjectRootCancelled = true;
      if IsDefined(this.player) && this.action.capricornProjectRootStarted && !this.action.capricornProjectRootCompleted {
        let host = GameInstance.FindEntityByID(this.player.GetGame(), this.action.GetRequesterID()) as NPCPuppet;
        if IsDefined(host) && host.GetCurrentlyUploadingAction() == this.action { CapricornProjectQuickhack.CleanupHost(host, this.player); };
      };
    };
    if IsDefined(this.player) && this.player.capricornProjectRootAction == this.action {
      this.player.capricornProjectRootAction = null;
      this.player.capricornProjectChainState = reason;
      if IsDefined(this.action) { QuickhackModule.RequestRefreshQuickhackMenu(this.player.GetGame(), this.action.GetRequesterID()); };
    };
  }
  public func Call() -> Void {
    if !IsDefined(this.player) || !IsDefined(this.action) || this.player.capricornProjectRootAction != this.action { return; };
    if this.player.IsDead() || !CapricornProjectQuickhack.IsDeckEquipped(this.player) || this.action.m_isTargetDead {
      this.Cancel("cancelled: pending root unavailable"); return;
    };
    if this.action.capricornProjectRootCompleted {
      if EngineTime.ToFloat(GameInstance.GetSimTime(this.player.GetGame())) - this.action.capricornProjectRootCompletedAt < 0.5 {
        GameInstance.GetDelaySystem(this.player.GetGame()).DelayCallback(this, 0.10);
        return;
      };
      this.Cancel("complete: root produced no active chain"); return;
    };
    let host = GameInstance.FindEntityByID(this.player.GetGame(), this.action.GetRequesterID()) as NPCPuppet;
    if CapricornProjectQuickhack.HostFinished(host) { this.Cancel("cancelled: original host unavailable"); return; };
    let current = host.GetCurrentlyUploadingAction();
    let now = EngineTime.ToFloat(GameInstance.GetSimTime(this.player.GetGame()));
    if !this.action.capricornProjectRootStarted {
      if !IsDefined(current) || !IsDefined(current.m_deviceActionQueue) || !current.m_deviceActionQueue.CapricornContains(this.action) {
        this.Cancel("cancelled: root not queued or started"); return;
      };
      this.lastProgressAt = now;
    } else {
      let pools = GameInstance.GetStatPoolsSystem(this.player.GetGame());
      let progress = pools.GetStatPoolValue(Cast<StatsObjectID>(host.GetEntityID()), gamedataStatPoolType.QuickHackUpload);
      if progress != this.lastProgress { this.lastProgress = progress; this.lastProgressAt = now; };
      if !pools.IsStatPoolAdded(Cast<StatsObjectID>(host.GetEntityID()), gamedataStatPoolType.QuickHackUpload) && now - this.lastProgressAt > 0.5 {
        this.Cancel("cancelled: original upload removed"); return;
      };
      if now - this.lastProgressAt > 10.0 { this.Cancel("cancelled: original upload stalled"); return; };
    };
    GameInstance.GetDelaySystem(this.player.GetGame()).DelayCallback(this, 0.10);
  }
}

// Saved decks can still contain a legacy hidden part even though their scanner
// action list uses our reserved-item alias. Read our tooltip ability rows from
// the actual custom item record instead of falling back to a single paragraph.
@wrapMethod(EquippedQuickHackData)
public final func GetAbilitiesByItemID(itemID: ItemID) -> array<InventoryItemAbility> {
  let recordID = ItemID.GetTDBID(itemID);
  if recordID == t"Items.CapricornBlackwallProgram" || recordID == t"Items.ProjectCapricornProgram" {
    let record = TweakDBInterface.GetItemRecord(recordID);
    if IsDefined(record) { return ProgramEntry.Make(itemID, record).m_abilities; };
  };
  return wrappedMethod(itemID);
}

// Self-ICE counterattacks are one-shot damage deliveries, not root/spread actions.
// They never reserve an instance, touch the manual cast's upload pool, or charge RAM.
@addField(PlayerPuppet)
public let capricornICECounterAttacker: wref<NPCPuppet>;
@addField(PlayerPuppet)
public let capricornICECounterArmedUntil: Float;
@addField(PlayerPuppet)
public let capricornICECounterArmSerial: Int32;
@addField(PlayerPuppet)
public let capricornICECounterBlocks: Int32;
@addField(PlayerPuppet)
public let capricornICECounterDispatched: Int32;
@addField(PlayerPuppet)
public let capricornICECounterLastBlockAt: Float;
@addField(PlayerPuppet)
public let capricornICECounterState: String;
@addField(PlayerPuppet)
public let capricornICECounterTargetRecord: String;
@addField(PlayerPuppet)
public let capricornICECounterLastHealthBefore: Float;
@addField(PlayerPuppet)
public let capricornICECounterLastHealthAfter: Float;
@addField(PlayerPuppet)
public let capricornICECounterSampleSerial: Int32;

@addMethod(PlayerPuppet)
public final func CapricornArmICECounter(attacker: ref<NPCPuppet>) -> Void {
  if !CapricornProjectQuickhack.IsDeckEquipped(this) || !IsDefined(attacker) || this.IsDead() { return; };
  let now = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  // Keep the original captured hacker while its block confirmation is pending.
  if this.capricornICECounterArmedUntil > now { return; };
  this.capricornICECounterAttacker = attacker;
  this.capricornICECounterArmedUntil = now + 2.0;
  this.capricornICECounterArmSerial += 1;
  let check = new CapricornICECounterConfirmation();
  check.player = this;
  check.serial = this.capricornICECounterArmSerial;
  GameInstance.GetDelaySystem(this.GetGame()).DelayCallback(check, 0.05);
}

@addMethod(PlayerPuppet)
public final func CapricornConfirmICECounter(source: String) -> Void {
  let now = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  if this.capricornICECounterArmedUntil <= 0.0 || now > this.capricornICECounterArmedUntil { return; };
  if !CapricornProjectQuickhack.IsDeckEquipped(this) || this.IsDead() || !StatusEffectSystem.ObjectHasStatusEffect(this, t"BaseStatusEffect.AntiVirusCooldown") { return; };
  let attacker = this.capricornICECounterAttacker;
  // Consume the captured block before dispatch, so its event/poll callbacks
  // cannot emit duplicate counterattacks. This is not a counterattack cooldown.
  this.capricornICECounterArmedUntil = 0.0;
  this.capricornICECounterAttacker = null;
  if this.capricornICECounterLastBlockAt > 0.0 && now - this.capricornICECounterLastBlockAt < 1.0 { return; };
  this.capricornICECounterLastBlockAt = now;
  this.capricornICECounterBlocks += 1;
  if CapricornProjectQuickhack.HostFinished(attacker) {
    this.capricornICECounterState = "skipped: blocked hacker no longer active";
    return;
  };
  this.capricornICECounterTargetRecord = TDBID.ToStringDEBUG(GameObject.GetTDBID(attacker));
  this.capricornICECounterState = "confirmed block: " + source;
  let counter = new CapricornICECounterDelivery();
  counter.player = this;
  counter.target = attacker;
  // Dispatch immediately after the native block handler returns; no 3s upload.
  GameInstance.GetDelaySystem(this.GetGame()).DelayCallback(counter, 0.0);
}

public class CapricornICECounterConfirmation extends DelayCallback {
  public let player: wref<PlayerPuppet>;
  public let serial: Int32;
  public func Call() -> Void {
    if !IsDefined(this.player) || this.serial != this.player.capricornICECounterArmSerial || this.player.capricornICECounterArmedUntil <= 0.0 { return; };
    let now = EngineTime.ToFloat(GameInstance.GetSimTime(this.player.GetGame()));
    if now > this.player.capricornICECounterArmedUntil {
      this.player.capricornICECounterArmedUntil = 0.0;
      this.player.capricornICECounterAttacker = null;
      return;
    };
    this.player.CapricornConfirmICECounter("shield cooldown confirmation poll");
    if this.player.capricornICECounterArmedUntil > 0.0 { GameInstance.GetDelaySystem(this.player.GetGame()).DelayCallback(this, 0.05); };
  }
}

public class CapricornICECounterDelivery extends DelayCallback {
  public let player: wref<PlayerPuppet>;
  public let target: wref<NPCPuppet>;
  public func Call() -> Void {
    if !IsDefined(this.player) { return; };
    if this.player.IsDead() || !CapricornProjectQuickhack.IsDeckEquipped(this.player) || CapricornProjectQuickhack.HostFinished(this.target) {
      this.player.capricornICECounterState = "skipped: player/deck/hacker unavailable at delivery";
      return;
    };
    // Same stock Blackwall damage/kill paths as Project Capricorn, without any
    // action, spread effector, queue, upload pool, or shared instance/budget state.
    let protectedTarget = this.target.IsBoss() || Equals(this.target.GetNPCRarity(), gamedataNPCRarity.MaxTac) || GameInstance.GetStatsSystem(this.target.GetGame()).GetStatValue(Cast<StatsObjectID>(this.target.GetEntityID()), gamedataStatType.IsExo) > 0.0;
    let effect = t"BaseStatusEffect.BaseBlackWallHackEffect";
    if protectedTarget { effect = t"BaseStatusEffect.BossBlackWallHack"; };
    if StatusEffectSystem.ObjectHasStatusEffect(this.target, effect) { StatusEffectHelper.RemoveStatusEffect(this.target, effect); };
    if !protectedTarget && StatusEffectSystem.ObjectHasStatusEffect(this.target, t"BaseStatusEffect.HauntedBlackwallForceKill") {
      StatusEffectHelper.RemoveStatusEffect(this.target, t"BaseStatusEffect.HauntedBlackwallForceKill");
    };
    let now = EngineTime.ToFloat(GameInstance.GetSimTime(this.player.GetGame()));
    this.player.capricornICECounterLastHealthBefore = GameInstance.GetStatPoolsSystem(this.target.GetGame()).GetStatPoolValue(Cast<StatsObjectID>(this.target.GetEntityID()), gamedataStatPoolType.Health, false);
    if protectedTarget {
      GameObjectEffectHelper.StartEffectEvent(this.target, n"black_wall_activation");
      if !CapricornProjectQuickhack.FireBypassAttack(this.target, this.player, t"Attacks.BossBlackwallAttack") {
        this.player.capricornICECounterState = "failed: protected-target damage record unavailable";
        return;
      };
    } else {
      this.target.capricornProjectBypassArmedUntil = now + 2.0;
      this.target.capricornProjectBypassArmed = true;
      StatusEffectHelper.ApplyStatusEffect(this.target, effect, this.player.GetEntityID());
    };
    this.player.capricornICECounterDispatched += 1;
    this.player.capricornICECounterState = "one-shot counter dispatched";
    this.player.capricornICECounterSampleSerial += 1;
    let sample = new CapricornICECounterDamageSample();
    sample.player = this.player;
    sample.target = this.target;
    sample.serial = this.player.capricornICECounterSampleSerial;
    sample.before = this.player.capricornICECounterLastHealthBefore;
    GameInstance.GetDelaySystem(this.player.GetGame()).DelayCallback(sample, 0.9);
  }
}

public class CapricornICECounterDamageSample extends DelayCallback {
  public let player: wref<PlayerPuppet>;
  public let target: wref<NPCPuppet>;
  public let serial: Int32;
  public let before: Float;
  public func Call() -> Void {
    if !IsDefined(this.player) || this.serial != this.player.capricornICECounterSampleSerial { return; };
    if !IsDefined(this.target) { this.player.capricornICECounterState = "counter dispatched; target unavailable for health sample"; return; };
    this.player.capricornICECounterLastHealthAfter = GameInstance.GetStatPoolsSystem(this.target.GetGame()).GetStatPoolValue(Cast<StatsObjectID>(this.target.GetEntityID()), gamedataStatPoolType.Health, false);
    if CapricornProjectQuickhack.HostFinished(this.target) {
      this.player.capricornICECounterState = "counter dispatched; target finished";
    } else {
      this.player.capricornICECounterState = this.player.capricornICECounterLastHealthAfter < this.before ? "counter dispatched; health reduction observed" : "counter dispatched; no health reduction observed";
    };
  }
}

@addMethod(PlayerPuppet)
public final func CapricornICECounterStatus() -> String {
  return s"Capricorn 0.7.8 Self-ICE counter | blocks=\(this.capricornICECounterBlocks) | countersDispatched=\(this.capricornICECounterDispatched) | armed=\(this.capricornICECounterArmedUntil > 0.0) | target=\(this.capricornICECounterTargetRecord) | state=\(this.capricornICECounterState) | healthBefore=\(this.capricornICECounterLastHealthBefore) | healthAfter=\(this.capricornICECounterLastHealthAfter) | manualInstanceActive=\(CapricornProjectQuickhack.IsInstanceActive(this)) | manualAdditionalUploadsUsed=\(this.capricornProjectAdditionalUploadsUsed) / 10";
}


// v0.7.9 slot-only upgrade: never replace a deck or remove ordinary quickhacks.
@addField(PlayerPuppet)
private let capricornSlotCheckedDeck: ItemID;
@addField(PlayerPuppet)
private let capricornSlotChecked: Bool;
@addField(PlayerPuppet)
private let capricornSlotLegacyRemoved: Int32;

@addMethod(PlayerPuppet)
public final func CapricornEnsureRegularSlots() -> Void {
  let equipment = EquipmentSystem.GetData(this);
  if !IsDefined(equipment) { return; };
  let deck = CapricornUpgradeSupport.FindDeck(this);
  if !CapricornUpgradeSupport.IsDeck(ItemID.GetTDBID(deck)) { this.capricornSlotChecked = false; return; };
  if this.capricornSlotChecked && this.capricornSlotCheckedDeck == deck { return; };
  if this.IsInCombat() || GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_System).GetBool(GetAllBlackboardDefs().UI_System.IsInMenu) { return; };
  let ts = GameInstance.GetTransactionSystem(this.GetGame());
  let data = ts.GetItemData(this, deck);
  if !IsDefined(data) { return; };
  let slots: array<TweakDBID>;
  ArrayPush(slots, t"AttachmentSlots.CapricornBlackwall");
  let i = 1;
  while i <= 8 { ArrayPush(slots, TDBID.Create("AttachmentSlots.CyberdeckProgram" + IntToString(i))); i += 1; };
  i = 0;
  let retry = false;
  while i < ArraySize(slots) {
    if data.HasPartInSlot(slots[i]) {
      let part: InnerItemData;
      data.GetItemPart(part, slots[i]);
      let id = InnerItemData.GetItemID(part);
      let record = ItemID.GetTDBID(id);
      if record == t"Items.CapricornBlackwallProgram" || record == t"Items.ProjectCapricornProgram" || record == t"Items.BlackWallProgramLvl1" || record == t"Items.BlackWallProgramLvl2" || record == t"Items.BlackWallProgramLvl3" || record == t"Items.BlackWallProgramLvl4" {
        ts.RemovePart(this, deck, slots[i], false);
        if !data.HasPartInSlot(slots[i]) {
          this.capricornSlotLegacyRemoved += 1;
          let request = new PartUninstallRequest();
          request.owner = this;
          request.itemID = deck;
          request.partID = id;
          GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"EquipmentSystem").QueueRequest(request);
          GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"UIInventoryScriptableSystem").QueueRequest(request);
        } else { retry = true; };
      };
    };
    i += 1;
  };
  PlayerPuppet.ChacheQuickHackListCleanup(this);
  this.capricornSlotCheckedDeck = deck;
  this.capricornSlotChecked = !retry;
}

@addMethod(PlayerPuppet)
public final func CapricornSlotStatus() -> String {
  let deck = CapricornUpgradeSupport.FindDeck(this);
  if !CapricornUpgradeSupport.IsDeck(ItemID.GetTDBID(deck)) { return "Project Capricorn 0.7.9 | Capricorn is not equipped"; };
  let slots = ItemModificationSystem.GetAllSlots(this, deck);
  let count = 0;
  let occupied = 0;
  let legacyInRegular = 0;
  let i = 1;
  while i <= 8 {
    let slot = TDBID.Create("AttachmentSlots.CyberdeckProgram" + IntToString(i));
    let j = 0;
    while j < ArraySize(slots) {
      if slots[j].slotID == slot {
        count += 1;
        if Equals(slots[j].status, ESlotState.Taken) {
          occupied += 1;
          let record = ItemID.GetTDBID(slots[j].installedPart);
          if record == t"Items.CapricornBlackwallProgram" || record == t"Items.ProjectCapricornProgram" || record == t"Items.BlackWallProgramLvl1" || record == t"Items.BlackWallProgramLvl2" || record == t"Items.BlackWallProgramLvl3" || record == t"Items.BlackWallProgramLvl4" { legacyInRegular += 1; };
        };
        break;
      };
      j += 1;
    };
    i += 1;
  };
  let signature = false;
  let actions = RPGManager.GetPlayerQuickHackListWithQuality(this);
  i = 0;
  while i < ArraySize(actions) {
    if IsDefined(actions[i].actionRecord) && actions[i].actionRecord.GetID() == t"QuickHack.ProjectCapricorn" { signature = true; };
    i += 1;
  };
  return s"Project Capricorn 0.7.9 | regularSlots=\(count)/8 | occupied=\(occupied) | empty=\(count - occupied) | legacyInRegular=\(legacyInRegular) | signatureAvailable=\(signature) | migrationComplete=\(this.capricornSlotChecked) | legacyRemoved=\(this.capricornSlotLegacyRemoved)";
}


// Shared event adapter for the existing Capricorn dialogue system.
public class CapricornReactiveEvent extends IScriptable {
  public let code: Int32;
  public let createdAt: Float;
  public let expires: Float;
  public let preview: Bool;
}
@addField(PlayerPuppet)
public let capricornReactiveQueue: array<ref<CapricornReactiveEvent>>;
@addField(PlayerPuppet)
public let capricornReactiveTimes: array<Float>;
@addField(PlayerPuppet)
public let capricornReactiveChoices: array<Int32>;
@addField(PlayerPuppet)
public let capricornReactiveDetected: Int32;
@addField(PlayerPuppet)
public let capricornReactivePlayed: Int32;
@addField(PlayerPuppet)
public let capricornReactiveLast: String;
@addField(PlayerPuppet)
public let capricornReactiveSpeechUntil: Float;
@addField(PlayerPuppet)
public let capricornReactiveFarewellUntil: Float;
@addField(PlayerPuppet)
public let capricornReactiveObserver: ref<CapricornReactiveJournalObserver>;
@addField(PlayerPuppet)
public let capricornReactiveAdapterStatus: String;
@addField(PlayerPuppet)
public let capricornReactiveWorkspotKey: String;
@addField(PlayerPuppet)
public let capricornReactiveLine: CRUID;
@addField(PlayerPuppet)
public let capricornReactiveVehicleSpeed: Float;
@addField(PlayerPuppet)
public let capricornReactiveVehicleObserver: ref<CapricornReactiveVehicleObserver>;

@addMethod(PlayerPuppet)
public final func CapricornReactivePrune(now: Float) -> Void {
  let i = ArraySize(this.capricornReactiveQueue) - 1;

  while i >= 0 {
    let item = this.capricornReactiveQueue[i];
    let context = CapricornReactiveLines.Context(item.code);
    let combat = this.IsInCombat();

    let preserve = item.code == 102 ||
                   item.code == 103 ||
                   item.code == 104 ||
                   item.code == 107;

    if now >= item.expires ||
       (!item.preview &&
         ((context == 1 && !combat) ||
          (context == 2 && combat && !preserve))) {
      ArrayErase(this.capricornReactiveQueue, i);
    };

    i -= 1;
  };
}
@addMethod(PlayerPuppet)
public final func CapricornReactiveEnqueue(key: String) -> Bool {
  let code = CapricornReactiveLines.Code(key);
  if code < 0 || !CapricornDialogue.IsEnabled(this) || this.IsDead() { return false; };
  let now = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  this.CapricornReactivePrune(now);
  if ArraySize(this.capricornReactiveTimes) != CapricornReactiveLines.Count() {
    ArrayResize(this.capricornReactiveTimes, CapricornReactiveLines.Count());
    ArrayResize(this.capricornReactiveChoices, CapricornReactiveLines.Count());
  };
  if this.capricornReactiveTimes[code] > 0.0 && now - this.capricornReactiveTimes[code] < CapricornReactiveLines.Cooldown(code) { return false; };
  let i = 0;
  while i < ArraySize(this.capricornReactiveQueue) {
    if this.capricornReactiveQueue[i].code == code { return false; };
    i += 1;
  };
  this.capricornReactiveDetected += 1;
  let item = new CapricornReactiveEvent();
  item.code = code;
  item.createdAt = now;
  item.expires = now + CapricornReactiveLines.TTL(code);
  // Bounded priority queue: discard the lowest-priority, oldest pending event.
  if ArraySize(this.capricornReactiveQueue) >= 8 {
    let lowest = 0;
    i = 1;
    while i < ArraySize(this.capricornReactiveQueue) {
      if CapricornReactiveLines.Priority(this.capricornReactiveQueue[i].code) < CapricornReactiveLines.Priority(this.capricornReactiveQueue[lowest].code) { lowest = i; };
      i += 1;
    };
    if CapricornReactiveLines.Priority(code) < CapricornReactiveLines.Priority(this.capricornReactiveQueue[lowest].code) { return false; };
    ArrayErase(this.capricornReactiveQueue, lowest);
  };
  ArrayPush(this.capricornReactiveQueue, item);
  return true;
}

@addMethod(PlayerPuppet)
public final func CapricornReactiveTick(dt: Float) -> Void {
  let now = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  let equipped = CapricornDialogue.IsEnabled(this);
  if !equipped || this.IsDead() || dt > 1.0 {
    ArrayClear(this.capricornReactiveQueue);
    if !equipped { this.CapricornReactiveUnbindVehicle(); };
    if !equipped && this.capricornReactiveFarewellUntil > now && !this.IsDead() && TweakDBInterface.GetBool(t"Capricorn.DialogueEnabled", true) {
      // One authorized departure line, never ongoing chatter without the deck.
      let boards = GameInstance.GetBlackboardSystem(this.GetGame());
      let phone = FromVariant<PhoneCallInformation>(boards.Get(GetAllBlackboardDefs().UI_ComDevice).GetVariant(GetAllBlackboardDefs().UI_ComDevice.PhoneCallInformation));
      if !boards.Get(GetAllBlackboardDefs().UI_System).GetBool(GetAllBlackboardDefs().UI_System.IsInMenu)
        && (Equals(phone.callPhase, questPhoneCallPhase.EndCall) || Equals(phone.callPhase, questPhoneCallPhase.Undefined))
        && !GameInstance.GetSceneSystem(this.GetGame()).GetScriptInterface().IsEntityInDialogue(this.GetEntityID())
        && !GameInstance.GetWorkspotSystem(this.GetGame()).IsActorInWorkspot(this)
        && !GameInstance.GetPhotoModeSystem(this.GetGame()).IsPhotoModeActive()
        && !this.GetTakeOverControlSystem().IsDeviceControlled()
        && !this.IsReplacer() && (PlayerPuppet.GetSceneTier(this) == 1 || PlayerPuppet.GetSceneTier(this) == 2) && now >= this.capricornReactiveSpeechUntil
        && now - this.capricornLastDialogTime >= 6.0 && now - this.capricornLastReactionTime >= 10.0 {
        this.CapricornReactiveSpeak(CapricornReactiveLines.Code("unequip"));
        this.capricornReactiveFarewellUntil = 0.0;
      };
    };
    return;
  };
  this.capricornReactiveFarewellUntil = now + 45.0;
  this.CapricornReactivePrune(now);
  let activity = Equals(this.capricornReactiveWorkspotKey, "sleep") || Equals(this.capricornReactiveWorkspotKey, "shower") || Equals(this.capricornReactiveWorkspotKey, "mirror");
  if !CapricornDialogue.CanReact(this, activity) { return; };
  // Keep the previously tested low-RAM, reinforcement and combat-end reactions
  // ahead of optional new chatter when they are waiting to use the same channel.
  if !this.capricornLowRAM && this.capricornObservedRAM < 5.0 { return; };
  if this.capricornReinforcementExpires > now { return; };
  if this.capricornCombatEndAt > 0.0 && now >= this.capricornCombatEndAt { return; };
  let best = -1;
  let i = 0;

  while i < ArraySize(this.capricornReactiveQueue) {
    let item = this.capricornReactiveQueue[i];
    let context = CapricornReactiveLines.Context(item.code);

    // Long-lived events may survive combat, but cannot speak
    // while their required out-of-combat context is unavailable.
    if (item.preview || context != 2 || !this.IsInCombat()) &&
      (!activity || Equals(CapricornReactiveLines.Key(item.code), this.capricornReactiveWorkspotKey)) {

      if best < 0 {
        best = i;
      } else {
        let priority = CapricornReactiveLines.Priority(item.code);
        let bestPriority = CapricornReactiveLines.Priority(this.capricornReactiveQueue[best].code);

        if priority > bestPriority ||
          (priority == bestPriority &&
            item.createdAt > this.capricornReactiveQueue[best].createdAt) {
          best = i;
        };
      };
    };

    i += 1;
  };

  if best >= 0 {
    let code = this.capricornReactiveQueue[best].code;
    ArrayErase(this.capricornReactiveQueue, best);
    this.CapricornReactiveSpeak(code);
  };
}

@addMethod(PlayerPuppet)
public final func CapricornReactiveSpeak(code: Int32) -> Void {
  if code < 0 || code >= CapricornReactiveLines.Count() { return; };
  if ArraySize(this.capricornReactiveChoices) != CapricornReactiveLines.Count() {
    ArrayResize(this.capricornReactiveTimes, CapricornReactiveLines.Count());
    ArrayResize(this.capricornReactiveChoices, CapricornReactiveLines.Count());
  };
  let choice = RandRange(0, 5);
  let last = this.capricornReactiveChoices[code] - 1;
  if choice == last { choice = (choice + RandRange(1, 5)) % 5; };
  this.capricornReactiveChoices[code] = choice + 1;
  let now = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  this.capricornReactiveTimes[code] = now;
  this.capricornLastReactionTime = now;
  this.capricornReactivePlayed += 1;
  this.capricornReactiveLast = CapricornReactiveLines.Key(code);
  let text = CapricornReactiveLines.Text(code, choice);
  this.CapricornShowSubtitle(770300000010000ul + Cast<Uint64>(code * 5 + choice), text, ClampF(Cast<Float>(StrLen(text)) / 17.0, 4.0, 14.0));
  this.capricornReactiveLine = HashToCRUID(770300000010000ul + Cast<Uint64>(code * 5 + choice));
}

@addMethod(PlayerPuppet)
public final func CapricornReactivePreview(key: String) -> String {
  if CapricornReactiveLines.Code(key) < 0 { return "Unknown event key. See REACTIVE-DIALOGUES.md."; };
  let queued = this.CapricornReactiveEnqueue(key);
  if queued {
    let i = 0;
    while i < ArraySize(this.capricornReactiveQueue) {
      if this.capricornReactiveQueue[i].code == CapricornReactiveLines.Code(key) { this.capricornReactiveQueue[i].preview = true; };
      i += 1;
    };
  };
  return s"Preview queued=\(queued). This displays text only; no gameplay event or effect is simulated.";
}

@addMethod(PlayerPuppet)
public final func CapricornReactiveStatus() -> String {
  return s"Project Capricorn 0.9.2 | eventTypes=\(CapricornReactiveLines.Count()) | sessionResets=\(this.capricornReactiveSessionResets) | detected=\(this.capricornReactiveDetected) | played=\(this.capricornReactivePlayed) | pending=\(ArraySize(this.capricornReactiveQueue)) | last=\(this.capricornReactiveLast) | equipped=\(CapricornDialogue.IsEnabled(this)) | canReact=\(CapricornDialogue.CanReact(this)) | adapter=\(this.capricornReactiveAdapterStatus)";
}

// Native journal callbacks observe actual entry state, not menu reads or text matches.
public class CapricornReactiveJournalObserver extends IScriptable {
  public let player: wref<PlayerPuppet>;
  protected cb func OnStateChanged(hash: Uint32, className: CName, notifyOption: JournalNotifyOption, changeType: JournalChangeType) -> Bool {
    let player = this.player;
    if !IsDefined(player) || !CapricornDialogue.IsEnabled(player) || NotEquals(notifyOption, JournalNotifyOption.Notify) { return false; };
    let journal = GameInstance.GetJournalManager(player.GetGame());
    let entry = journal.GetEntry(hash);
    let state = journal.GetEntryState(entry);
    if Equals(className, n"gameJournalPhoneMessage") && Equals(state, gameJournalEntryState.Active) { player.CapricornReactiveEnqueue("phone_text"); };
    if Equals(className, n"gameJournalQuest") {
      let type = journal.GetQuestType(entry);
      if Equals(type, gameJournalQuestType.Contract) {
        if Equals(state, gameJournalEntryState.Active) { player.CapricornReactiveEnqueue("gig_new"); };
        if Equals(state, gameJournalEntryState.Succeeded) { player.CapricornReactiveEnqueue("gig_done"); };
      };
      if Equals(type, gameJournalQuestType.StreetStory) {
        if Equals(state, gameJournalEntryState.Active) { player.CapricornReactiveEnqueue("ncpd_activity_start"); };
        if Equals(state, gameJournalEntryState.Succeeded) { player.CapricornReactiveEnqueue("ncpd_activity_done"); };
      };
      if Equals(type, gameJournalQuestType.MainQuest) && Equals(state, gameJournalEntryState.Succeeded) { player.CapricornReactiveEnqueue("quest_major"); };
    };
    return true;
  }
}
@addMethod(PlayerPuppet)
public final func CapricornReactiveAttach() -> Void {
  if IsDefined(this.capricornReactiveObserver) { return; };
  let journal = GameInstance.GetJournalManager(this.GetGame());
  if !IsDefined(journal) { return; };
  this.capricornReactiveObserver = new CapricornReactiveJournalObserver();
  this.capricornReactiveObserver.player = this;
  journal.RegisterScriptCallback(this.capricornReactiveObserver, n"OnStateChanged", gameJournalListenerType.State);
}
@wrapMethod(PlayerPuppet)
protected cb func OnDetach() -> Bool {
  this.capricornReactiveSessionBound = false;
  this.CapricornReactiveUnbindVehicle();
  if IsDefined(this.capricornReactiveObserver) {
    GameInstance.GetJournalManager(this.GetGame()).UnregisterScriptCallback(this.capricornReactiveObserver, n"OnStateChanged");
    this.capricornReactiveObserver.player = null;
    this.capricornReactiveObserver = null;
  };
  ArrayClear(this.capricornReactiveQueue);
  this.capricornReactiveFarewellUntil = 0.0;
  return wrappedMethod();
}

@if(ModuleExists("Edgerunning.System"))
@addMethod(PlayerPuppet)
public final func CapricornReactiveHumanity() -> Int32 {
  let system = EdgerunningSystem.GetInstance(this.GetGame());
  if !IsDefined(system) { return -1; };
  return system.GetHumanityCurrent();
}
@if(!ModuleExists("Edgerunning.System"))
@addMethod(PlayerPuppet)
public final func CapricornReactiveHumanity() -> Int32 { return -1; }
@if(ModuleExists("Edgerunning.System"))
@addMethod(PlayerPuppet)
public final func CapricornReactivePsychosis() -> Bool {
  let system = EdgerunningSystem.GetInstance(this.GetGame());
  return IsDefined(system) && system.IsPsychosisActive();
}
@if(!ModuleExists("Edgerunning.System"))
@addMethod(PlayerPuppet)
public final func CapricornReactivePsychosis() -> Bool { return false; }

@addField(PlayerPuppet)
public let capricornReactiveSessionBound: Bool;
@addField(PlayerPuppet)
public let capricornReactiveSessionResets: Int32;
@addMethod(PlayerPuppet)
public final func CapricornReactiveSessionReady() -> Bool {
  return this.capricornReactiveSessionBound;
}
@addMethod(PlayerPuppet)
public final func CapricornReactiveReset() -> Void {
  this.capricornReactiveSessionBound = true;
  this.capricornReactiveSessionResets += 1;
  this.CapricornReactiveUnbindVehicle();
  ArrayClear(this.capricornReactiveQueue);
  ArrayClear(this.capricornReactiveTimes);
  ArrayClear(this.capricornReactiveChoices);
  this.capricornReactiveFarewellUntil = 0.0;
  this.capricornReactiveSpeechUntil = 0.0;
  this.capricornReactiveWorkspotKey = "";
}

@addMethod(PlayerPuppet)
public final func CapricornReactiveDrop(key: String) -> Void {
  let code = CapricornReactiveLines.Code(key);
  let i = ArraySize(this.capricornReactiveQueue) - 1;
  while i >= 0 {
    if this.capricornReactiveQueue[i].code == code { ArrayErase(this.capricornReactiveQueue, i); };
    i -= 1;
  };
}

@addMethod(PlayerPuppet)
public final func CapricornReactiveSheltered() -> Bool {
  let from = this.GetWorldPosition(); from.Z += 1.8;
  let to = from; to.Z += 80.0;
  let roof: TraceResult;
  return GameInstance.GetSpatialQueriesSystem(this.GetGame()).SyncRaycastByCollisionGroup(from, to, n"Static", roof, true, false);
}

@addMethod(PlayerPuppet)
public final func CapricornReactiveNow() -> Float {
  return EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
}

@addMethod(PlayerPuppet)
public final func CapricornReactiveRecordName(record: TweakDBID) -> String {
  return TDBID.ToStringDEBUG(record);
}

@addMethod(PlayerPuppet)
public final func CapricornReactiveHostilesRemain() -> Bool {
  let tracker = this.GetTargetTrackerComponent();
  if !IsDefined(tracker) { return true; };
  let threats = tracker.GetHostileThreats(false);
  let i = 0;
  while i < ArraySize(threats) {
    let target = threats[i].entity as ScriptedPuppet;
    if IsDefined(target) && ScriptedPuppet.IsActive(target) { return true; };
    i += 1;
  };
  return false;
}

@addMethod(PlayerPuppet)
public final func CapricornReactiveClearLine() -> Void {
  if Equals(this.capricornReactiveLine, HashToCRUID(0ul)) { return; };
  let hide = new CapricornHideSubtitle();
  hide.game = this.GetGame(); hide.lineID = this.capricornReactiveLine;
  hide.Call();
  this.capricornReactiveLine = HashToCRUID(0ul);
}

public class CapricornReactiveVehicleObserver extends IScriptable {
  public let player: wref<PlayerPuppet>;
  public let vehicle: wref<VehicleObject>;
  public let blackboard: wref<IBlackboard>;
  public let handle: ref<CallbackHandle>;
  protected cb func OnCollision(value: Bool) -> Bool {
    if value && IsDefined(this.player) && IsDefined(this.vehicle)
      && this.player.GetMountedVehicle() == this.vehicle && this.vehicle.IsPlayerDriver()
      && this.player.capricornReactiveVehicleSpeed > 8.0 {
      this.player.CapricornReactiveEnqueue("vehicle_crash");
    };
    return true;
  }
}
@addMethod(PlayerPuppet)
public final func CapricornReactiveUnbindVehicle() -> Void {
  let observer = this.capricornReactiveVehicleObserver;
  if IsDefined(observer) && IsDefined(observer.blackboard) && IsDefined(observer.handle) {
    observer.blackboard.UnregisterListenerBool(GetAllBlackboardDefs().Vehicle.Collision, observer.handle);
  };
  this.capricornReactiveVehicleObserver = null;
  this.capricornReactiveVehicleSpeed = 0.0;
}
@addMethod(PlayerPuppet)
public final func CapricornReactiveBindVehicle(vehicle: ref<VehicleObject>) -> Void {
  if !IsDefined(vehicle) { this.CapricornReactiveUnbindVehicle(); return; };
  if IsDefined(this.capricornReactiveVehicleObserver) && this.capricornReactiveVehicleObserver.vehicle == vehicle { return; };
  this.CapricornReactiveUnbindVehicle();
  let board = vehicle.GetBlackboard();
  if !IsDefined(board) { return; };
  let observer = new CapricornReactiveVehicleObserver();
  observer.player = this; observer.vehicle = vehicle; observer.blackboard = board;
  observer.handle = board.RegisterListenerBool(GetAllBlackboardDefs().Vehicle.Collision, observer, n"OnCollision");
  this.capricornReactiveVehicleObserver = observer;
}

public class CapricornReactiveServicePoint extends IScriptable {
  public let key: String;
  public let point: Vector4;
}
@addMethod(PlayerPuppet)
public final func CapricornReactiveServicePoints() -> array<ref<CapricornReactiveServicePoint>> {
  let result: array<ref<CapricornReactiveServicePoint>>;
  let markers = GameInstance.GetMappinSystem(this.GetGame()).GetAllMappins();
  let i = 0;
  while i < ArraySize(markers) {
    let marker = markers[i];
    if IsDefined(marker) && marker.IsActive() {
      let variant = marker.GetVariant();
      let key = "";
      if Equals(variant, gamedataMappinVariant.ApartmentVariant) { key = "apartment"; };
      if Equals(variant, gamedataMappinVariant.ServicePointRipperdocVariant) { key = "ripper_clinic"; };
      if Equals(variant, gamedataMappinVariant.ServicePointBarVariant) { key = "bar"; };
      if Equals(variant, gamedataMappinVariant.ServicePointGunsVariant) { key = "weapon_vendor"; };
      if StrLen(key) > 0 {
        let point = new CapricornReactiveServicePoint();
        point.key = key; point.point = marker.GetWorldPosition();
        ArrayPush(result, point);
      };
    };
    i += 1;
  };
  return result;
}

public abstract class CapricornReactiveLines {
  public static func Count() -> Int32 { return 128; }
  public static func Code(key: String) -> Int32 {
    if Equals(key, "police_first") { return 0; };
    if Equals(key, "police_increase") { return 1; };
    if Equals(key, "police_five") { return 2; };
    if Equals(key, "maxtac_arrives") { return 3; };
    if Equals(key, "maxtac_kill") { return 4; };
    if Equals(key, "maxtac_squad") { return 5; };
    if Equals(key, "police_escape") { return 6; };
    if Equals(key, "police_zero") { return 7; };
    if Equals(key, "faction_maelstrom") { return 8; };
    if Equals(key, "faction_tyger") { return 9; };
    if Equals(key, "faction_valentino") { return 10; };
    if Equals(key, "faction_animals") { return 11; };
    if Equals(key, "faction_voodoo") { return 12; };
    if Equals(key, "faction_sixth") { return 13; };
    if Equals(key, "faction_scav") { return 14; };
    if Equals(key, "faction_wraith") { return 15; };
    if Equals(key, "faction_barghest") { return 16; };
    if Equals(key, "faction_corp") { return 17; };
    if Equals(key, "netrunner") { return 18; };
    if Equals(key, "hacked") { return 19; };
    if Equals(key, "cyberpsycho") { return 20; };
    if Equals(key, "cyberpsycho_defeat") { return 21; };
    if Equals(key, "boss") { return 22; };
    if Equals(key, "boss_defeat") { return 23; };
    if Equals(key, "heavy_chrome") { return 24; };
    if Equals(key, "machine") { return 25; };
    if Equals(key, "kill_streak") { return 26; };
    if Equals(key, "multi_kill") { return 27; };
    if Equals(key, "headshot") { return 28; };
    if Equals(key, "stealth_takedown") { return 29; };
    if Equals(key, "detected") { return 30; };
    if Equals(key, "near_fatal") { return 31; };
    if Equals(key, "critical_kill") { return 32; };
    if Equals(key, "final_hostile") { return 33; };
    if Equals(key, "long_combat") { return 34; };
    if Equals(key, "quickhack_streak") { return 35; };
    if Equals(key, "trace_start") { return 36; };
    if Equals(key, "trace_near") { return 37; };
    if Equals(key, "trace_avoid") { return 38; };
    if Equals(key, "project_elite") { return 39; };
    if Equals(key, "project_budget") { return 40; };
    if Equals(key, "project_reapply") { return 41; };
    if Equals(key, "project_chain") { return 42; };
    if Equals(key, "overclock_start") { return 43; };
    if Equals(key, "overclock_end") { return 44; };
    if Equals(key, "district_watson") { return 45; };
    if Equals(key, "district_westbrook") { return 46; };
    if Equals(key, "district_center") { return 47; };
    if Equals(key, "district_heywood") { return 48; };
    if Equals(key, "district_santo") { return 49; };
    if Equals(key, "district_pacifica") { return 50; };
    if Equals(key, "district_badlands") { return 51; };
    if Equals(key, "district_dogtown") { return 52; };
    if Equals(key, "leave_dogtown") { return 53; };
    if Equals(key, "landmark") { return 54; };
    if Equals(key, "restricted") { return 55; };
    if Equals(key, "district_return") { return 56; };
    if Equals(key, "rain") { return 57; };
    if Equals(key, "storm") { return 58; };
    if Equals(key, "fog") { return 59; };
    if Equals(key, "sandstorm") { return 60; };
    if Equals(key, "clear_weather") { return 61; };
    if Equals(key, "sunrise") { return 62; };
    if Equals(key, "sunset") { return 63; };
    if Equals(key, "midnight") { return 64; };
    if Equals(key, "awake_long") { return 65; };
    if Equals(key, "bad_weather_long") { return 66; };
    if Equals(key, "vehicle_fancy") { return 67; };
    if Equals(key, "vehicle_fast") { return 68; };
    if Equals(key, "vehicle_crash") { return 69; };
    if Equals(key, "vehicle_jump") { return 70; };
    if Equals(key, "vehicle_journey") { return 71; };
    if Equals(key, "vehicle_summon") { return 72; };
    if Equals(key, "vehicle_unlock") { return 73; };
    if Equals(key, "vehicle_abandon") { return 74; };
    if Equals(key, "apartment") { return 75; };
    if Equals(key, "h10") { return 76; };
    if Equals(key, "sleep") { return 77; };
    if Equals(key, "wake") { return 78; };
    if Equals(key, "shower") { return 79; };
    if Equals(key, "mirror") { return 80; };
    if Equals(key, "clothing") { return 81; };
    if Equals(key, "stash") { return 82; };
    if Equals(key, "apartment_long") { return 83; };
    if Equals(key, "leave_after_sleep") { return 84; };
    if Equals(key, "ripper_clinic") { return 85; };
    if Equals(key, "ripper_open") { return 86; };
    if Equals(key, "ripper_close") { return 87; };
    if Equals(key, "capacity") { return 88; };
    if Equals(key, "unequip") { return 89; };
    if Equals(key, "reequip") { return 90; };
    if Equals(key, "viktor") { return 91; };
    if Equals(key, "purchase_expensive") { return 92; };
    if Equals(key, "purchase_weapon") { return 93; };
    if Equals(key, "eat") { return 94; };
    if Equals(key, "drink") { return 95; };
    if Equals(key, "alcohol") { return 96; };
    if Equals(key, "bar") { return 97; };
    if Equals(key, "weapon_vendor") { return 98; };
    if Equals(key, "bd_start") { return 99; };
    if Equals(key, "bd_end") { return 100; };
    if Equals(key, "ncpd_activity_start") { return 101; };
    if Equals(key, "ncpd_activity_done") { return 102; };
    if Equals(key, "gig_new") { return 103; };
    if Equals(key, "gig_done") { return 104; };
    if Equals(key, "phone_call") { return 105; };
    if Equals(key, "phone_text") { return 106; };
    if Equals(key, "quest_major") { return 107; };
    if Equals(key, "konpeki") { return 108; };
    if Equals(key, "arasaka_tower") { return 109; };
    if Equals(key, "afterlife") { return 110; };
    if Equals(key, "blackwall_facility") { return 111; };
    if Equals(key, "netrunner_place") { return 112; };
    if Equals(key, "underground") { return 113; };
    if Equals(key, "johnny_place") { return 114; };
    if Equals(key, "blackwall_context") { return 115; };
    if Equals(key, "pl_location") { return 116; };
    if Equals(key, "repeat_jump") { return 117; };
    if Equals(key, "repeat_crouch") { return 118; };
    if Equals(key, "repeat_inventory") { return 119; };
    if Equals(key, "repeat_weapon") { return 120; };
    if Equals(key, "fall_survive") { return 121; };
    if Equals(key, "swim") { return 122; };
    if Equals(key, "explore_long") { return 123; };
    if Equals(key, "return_inactive") { return 124; };
    if Equals(key, "low_humanity") { return 125; };
    if Equals(key, "psycho_enter") { return 126; };
    if Equals(key, "psycho_exit") { return 127; };
    return -1;
  }
  public static func Key(code: Int32) -> String {
    if code == 0 { return "police_first"; };
    if code == 1 { return "police_increase"; };
    if code == 2 { return "police_five"; };
    if code == 3 { return "maxtac_arrives"; };
    if code == 4 { return "maxtac_kill"; };
    if code == 5 { return "maxtac_squad"; };
    if code == 6 { return "police_escape"; };
    if code == 7 { return "police_zero"; };
    if code == 8 { return "faction_maelstrom"; };
    if code == 9 { return "faction_tyger"; };
    if code == 10 { return "faction_valentino"; };
    if code == 11 { return "faction_animals"; };
    if code == 12 { return "faction_voodoo"; };
    if code == 13 { return "faction_sixth"; };
    if code == 14 { return "faction_scav"; };
    if code == 15 { return "faction_wraith"; };
    if code == 16 { return "faction_barghest"; };
    if code == 17 { return "faction_corp"; };
    if code == 18 { return "netrunner"; };
    if code == 19 { return "hacked"; };
    if code == 20 { return "cyberpsycho"; };
    if code == 21 { return "cyberpsycho_defeat"; };
    if code == 22 { return "boss"; };
    if code == 23 { return "boss_defeat"; };
    if code == 24 { return "heavy_chrome"; };
    if code == 25 { return "machine"; };
    if code == 26 { return "kill_streak"; };
    if code == 27 { return "multi_kill"; };
    if code == 28 { return "headshot"; };
    if code == 29 { return "stealth_takedown"; };
    if code == 30 { return "detected"; };
    if code == 31 { return "near_fatal"; };
    if code == 32 { return "critical_kill"; };
    if code == 33 { return "final_hostile"; };
    if code == 34 { return "long_combat"; };
    if code == 35 { return "quickhack_streak"; };
    if code == 36 { return "trace_start"; };
    if code == 37 { return "trace_near"; };
    if code == 38 { return "trace_avoid"; };
    if code == 39 { return "project_elite"; };
    if code == 40 { return "project_budget"; };
    if code == 41 { return "project_reapply"; };
    if code == 42 { return "project_chain"; };
    if code == 43 { return "overclock_start"; };
    if code == 44 { return "overclock_end"; };
    if code == 45 { return "district_watson"; };
    if code == 46 { return "district_westbrook"; };
    if code == 47 { return "district_center"; };
    if code == 48 { return "district_heywood"; };
    if code == 49 { return "district_santo"; };
    if code == 50 { return "district_pacifica"; };
    if code == 51 { return "district_badlands"; };
    if code == 52 { return "district_dogtown"; };
    if code == 53 { return "leave_dogtown"; };
    if code == 54 { return "landmark"; };
    if code == 55 { return "restricted"; };
    if code == 56 { return "district_return"; };
    if code == 57 { return "rain"; };
    if code == 58 { return "storm"; };
    if code == 59 { return "fog"; };
    if code == 60 { return "sandstorm"; };
    if code == 61 { return "clear_weather"; };
    if code == 62 { return "sunrise"; };
    if code == 63 { return "sunset"; };
    if code == 64 { return "midnight"; };
    if code == 65 { return "awake_long"; };
    if code == 66 { return "bad_weather_long"; };
    if code == 67 { return "vehicle_fancy"; };
    if code == 68 { return "vehicle_fast"; };
    if code == 69 { return "vehicle_crash"; };
    if code == 70 { return "vehicle_jump"; };
    if code == 71 { return "vehicle_journey"; };
    if code == 72 { return "vehicle_summon"; };
    if code == 73 { return "vehicle_unlock"; };
    if code == 74 { return "vehicle_abandon"; };
    if code == 75 { return "apartment"; };
    if code == 76 { return "h10"; };
    if code == 77 { return "sleep"; };
    if code == 78 { return "wake"; };
    if code == 79 { return "shower"; };
    if code == 80 { return "mirror"; };
    if code == 81 { return "clothing"; };
    if code == 82 { return "stash"; };
    if code == 83 { return "apartment_long"; };
    if code == 84 { return "leave_after_sleep"; };
    if code == 85 { return "ripper_clinic"; };
    if code == 86 { return "ripper_open"; };
    if code == 87 { return "ripper_close"; };
    if code == 88 { return "capacity"; };
    if code == 89 { return "unequip"; };
    if code == 90 { return "reequip"; };
    if code == 91 { return "viktor"; };
    if code == 92 { return "purchase_expensive"; };
    if code == 93 { return "purchase_weapon"; };
    if code == 94 { return "eat"; };
    if code == 95 { return "drink"; };
    if code == 96 { return "alcohol"; };
    if code == 97 { return "bar"; };
    if code == 98 { return "weapon_vendor"; };
    if code == 99 { return "bd_start"; };
    if code == 100 { return "bd_end"; };
    if code == 101 { return "ncpd_activity_start"; };
    if code == 102 { return "ncpd_activity_done"; };
    if code == 103 { return "gig_new"; };
    if code == 104 { return "gig_done"; };
    if code == 105 { return "phone_call"; };
    if code == 106 { return "phone_text"; };
    if code == 107 { return "quest_major"; };
    if code == 108 { return "konpeki"; };
    if code == 109 { return "arasaka_tower"; };
    if code == 110 { return "afterlife"; };
    if code == 111 { return "blackwall_facility"; };
    if code == 112 { return "netrunner_place"; };
    if code == 113 { return "underground"; };
    if code == 114 { return "johnny_place"; };
    if code == 115 { return "blackwall_context"; };
    if code == 116 { return "pl_location"; };
    if code == 117 { return "repeat_jump"; };
    if code == 118 { return "repeat_crouch"; };
    if code == 119 { return "repeat_inventory"; };
    if code == 120 { return "repeat_weapon"; };
    if code == 121 { return "fall_survive"; };
    if code == 122 { return "swim"; };
    if code == 123 { return "explore_long"; };
    if code == 124 { return "return_inactive"; };
    if code == 125 { return "low_humanity"; };
    if code == 126 { return "psycho_enter"; };
    if code == 127 { return "psycho_exit"; };
    return "";
  }
  public static func Cooldown(code: Int32) -> Float {
    if code == 0 { return 120.0; };
    if code == 1 { return 120.0; };
    if code == 2 { return 120.0; };
    if code == 3 { return 120.0; };
    if code == 4 { return 120.0; };
    if code == 5 { return 120.0; };
    if code == 6 { return 120.0; };
    if code == 7 { return 120.0; };
    if code == 8 { return 120.0; };
    if code == 9 { return 120.0; };
    if code == 10 { return 120.0; };
    if code == 11 { return 120.0; };
    if code == 12 { return 120.0; };
    if code == 13 { return 120.0; };
    if code == 14 { return 120.0; };
    if code == 15 { return 120.0; };
    if code == 16 { return 120.0; };
    if code == 17 { return 120.0; };
    if code == 18 { return 120.0; };
    if code == 19 { return 120.0; };
    if code == 20 { return 120.0; };
    if code == 21 { return 120.0; };
    if code == 22 { return 120.0; };
    if code == 23 { return 120.0; };
    if code == 24 { return 120.0; };
    if code == 25 { return 120.0; };
    if code == 26 { return 120.0; };
    if code == 27 { return 120.0; };
    if code == 28 { return 120.0; };
    if code == 29 { return 120.0; };
    if code == 30 { return 120.0; };
    if code == 31 { return 120.0; };
    if code == 32 { return 120.0; };
    if code == 33 { return 120.0; };
    if code == 34 { return 120.0; };
    if code == 35 { return 120.0; };
    if code == 36 { return 120.0; };
    if code == 37 { return 120.0; };
    if code == 38 { return 120.0; };
    if code == 39 { return 120.0; };
    if code == 40 { return 120.0; };
    if code == 41 { return 120.0; };
    if code == 42 { return 120.0; };
    if code == 43 { return 120.0; };
    if code == 44 { return 120.0; };
    if code == 45 { return 900.0; };
    if code == 46 { return 900.0; };
    if code == 47 { return 900.0; };
    if code == 48 { return 900.0; };
    if code == 49 { return 900.0; };
    if code == 50 { return 900.0; };
    if code == 51 { return 900.0; };
    if code == 52 { return 900.0; };
    if code == 53 { return 300.0; };
    if code == 54 { return 300.0; };
    if code == 55 { return 300.0; };
    if code == 56 { return 900.0; };
    if code == 57 { return 300.0; };
    if code == 58 { return 300.0; };
    if code == 59 { return 300.0; };
    if code == 60 { return 300.0; };
    if code == 61 { return 300.0; };
    if code == 62 { return 300.0; };
    if code == 63 { return 300.0; };
    if code == 64 { return 300.0; };
    if code == 65 { return 900.0; };
    if code == 66 { return 900.0; };
    if code == 67 { return 300.0; };
    if code == 68 { return 300.0; };
    if code == 69 { return 300.0; };
    if code == 70 { return 300.0; };
    if code == 71 { return 900.0; };
    if code == 72 { return 300.0; };
    if code == 73 { return 300.0; };
    if code == 74 { return 300.0; };
    if code == 75 { return 300.0; };
    if code == 76 { return 300.0; };
    if code == 77 { return 300.0; };
    if code == 78 { return 300.0; };
    if code == 79 { return 300.0; };
    if code == 80 { return 300.0; };
    if code == 81 { return 300.0; };
    if code == 82 { return 300.0; };
    if code == 83 { return 900.0; };
    if code == 84 { return 300.0; };
    if code == 85 { return 300.0; };
    if code == 86 { return 300.0; };
    if code == 87 { return 300.0; };
    if code == 88 { return 300.0; };
    if code == 89 { return 300.0; };
    if code == 90 { return 300.0; };
    if code == 91 { return 300.0; };
    if code == 92 { return 300.0; };
    if code == 93 { return 300.0; };
    if code == 94 { return 300.0; };
    if code == 95 { return 300.0; };
    if code == 96 { return 300.0; };
    if code == 97 { return 300.0; };
    if code == 98 { return 300.0; };
    if code == 99 { return 300.0; };
    if code == 100 { return 300.0; };
    if code == 101 { return 300.0; };
    if code == 102 { return 300.0; };
    if code == 103 { return 300.0; };
    if code == 104 { return 300.0; };
    if code == 105 { return 300.0; };
    if code == 106 { return 300.0; };
    if code == 107 { return 300.0; };
    if code == 108 { return 300.0; };
    if code == 109 { return 300.0; };
    if code == 110 { return 300.0; };
    if code == 111 { return 300.0; };
    if code == 112 { return 300.0; };
    if code == 113 { return 300.0; };
    if code == 114 { return 300.0; };
    if code == 115 { return 300.0; };
    if code == 116 { return 300.0; };
    if code == 117 { return 300.0; };
    if code == 118 { return 300.0; };
    if code == 119 { return 300.0; };
    if code == 120 { return 300.0; };
    if code == 121 { return 300.0; };
    if code == 122 { return 300.0; };
    if code == 123 { return 900.0; };
    if code == 124 { return 300.0; };
    if code == 125 { return 300.0; };
    if code == 126 { return 300.0; };
    if code == 127 { return 300.0; };
    return 120.0;
  }
  public static func Priority(code: Int32) -> Int32 {
    if code == 0 { return 50; };
    if code == 1 { return 50; };
    if code == 2 { return 90; };
    if code == 3 { return 90; };
    if code == 4 { return 50; };
    if code == 5 { return 90; };
    if code == 6 { return 70; };
    if code == 7 { return 50; };
    if code == 8 { return 50; };
    if code == 9 { return 50; };
    if code == 10 { return 50; };
    if code == 11 { return 50; };
    if code == 12 { return 50; };
    if code == 13 { return 50; };
    if code == 14 { return 50; };
    if code == 15 { return 50; };
    if code == 16 { return 50; };
    if code == 17 { return 50; };
    if code == 18 { return 50; };
    if code == 19 { return 70; };
    if code == 20 { return 70; };
    if code == 21 { return 70; };
    if code == 22 { return 70; };
    if code == 23 { return 70; };
    if code == 24 { return 50; };
    if code == 25 { return 50; };
    if code == 26 { return 50; };
    if code == 27 { return 50; };
    if code == 28 { return 50; };
    if code == 29 { return 50; };
    if code == 30 { return 50; };
    if code == 31 { return 90; };
    if code == 32 { return 90; };
    if code == 33 { return 50; };
    if code == 34 { return 50; };
    if code == 35 { return 50; };
    if code == 36 { return 50; };
    if code == 37 { return 90; };
    if code == 38 { return 50; };
    if code == 39 { return 70; };
    if code == 40 { return 70; };
    if code == 41 { return 50; };
    if code == 42 { return 50; };
    if code == 43 { return 50; };
    if code == 44 { return 50; };
    if code == 45 { return 20; };
    if code == 46 { return 20; };
    if code == 47 { return 20; };
    if code == 48 { return 20; };
    if code == 49 { return 20; };
    if code == 50 { return 20; };
    if code == 51 { return 20; };
    if code == 52 { return 20; };
    if code == 53 { return 20; };
    if code == 54 { return 20; };
    if code == 55 { return 20; };
    if code == 56 { return 20; };
    if code == 57 { return 20; };
    if code == 58 { return 20; };
    if code == 59 { return 20; };
    if code == 60 { return 20; };
    if code == 61 { return 20; };
    if code == 62 { return 20; };
    if code == 63 { return 20; };
    if code == 64 { return 20; };
    if code == 65 { return 20; };
    if code == 66 { return 20; };
    if code == 67 { return 20; };
    if code == 68 { return 20; };
    if code == 69 { return 20; };
    if code == 70 { return 20; };
    if code == 71 { return 20; };
    if code == 72 { return 20; };
    if code == 73 { return 20; };
    if code == 74 { return 20; };
    if code == 75 { return 20; };
    if code == 76 { return 20; };
    if code == 77 { return 20; };
    if code == 78 { return 20; };
    if code == 79 { return 20; };
    if code == 80 { return 20; };
    if code == 81 { return 20; };
    if code == 82 { return 20; };
    if code == 83 { return 20; };
    if code == 84 { return 20; };
    if code == 85 { return 20; };
    if code == 86 { return 20; };
    if code == 87 { return 20; };
    if code == 88 { return 20; };
    if code == 89 { return 90; };
    if code == 90 { return 90; };
    if code == 91 { return 20; };
    if code == 92 { return 20; };
    if code == 93 { return 20; };
    if code == 94 { return 20; };
    if code == 95 { return 20; };
    if code == 96 { return 20; };
    if code == 97 { return 20; };
    if code == 98 { return 20; };
    if code == 99 { return 20; };
    if code == 100 { return 20; };
    if code == 101 { return 20; };
    if code == 102 { return 60; };
    if code == 103 { return 40; };
    if code == 104 { return 60; };
    if code == 105 { return 20; };
    if code == 106 { return 20; };
    if code == 107 { return 70; };
    if code == 108 { return 20; };
    if code == 109 { return 20; };
    if code == 110 { return 20; };
    if code == 111 { return 20; };
    if code == 112 { return 20; };
    if code == 113 { return 20; };
    if code == 114 { return 20; };
    if code == 115 { return 20; };
    if code == 116 { return 20; };
    if code == 117 { return 20; };
    if code == 118 { return 20; };
    if code == 119 { return 20; };
    if code == 120 { return 20; };
    if code == 121 { return 20; };
    if code == 122 { return 20; };
    if code == 123 { return 20; };
    if code == 124 { return 20; };
    if code == 125 { return 20; };
    if code == 126 { return 90; };
    if code == 127 { return 90; };
    return 0;
  }
  public static func Context(code: Int32) -> Int32 {
    if code == 0 { return 0; };
    if code == 1 { return 0; };
    if code == 2 { return 0; };
    if code == 3 { return 0; };
    if code == 4 { return 0; };
    if code == 5 { return 0; };
    if code == 6 { return 0; };
    if code == 7 { return 0; };
    if code == 8 { return 1; };
    if code == 9 { return 1; };
    if code == 10 { return 1; };
    if code == 11 { return 1; };
    if code == 12 { return 1; };
    if code == 13 { return 1; };
    if code == 14 { return 1; };
    if code == 15 { return 1; };
    if code == 16 { return 1; };
    if code == 17 { return 1; };
    if code == 18 { return 1; };
    if code == 19 { return 0; };
    if code == 20 { return 1; };
    if code == 21 { return 0; };
    if code == 22 { return 1; };
    if code == 23 { return 0; };
    if code == 24 { return 1; };
    if code == 25 { return 1; };
    if code == 26 { return 0; };
    if code == 27 { return 0; };
    if code == 28 { return 0; };
    if code == 29 { return 0; };
    if code == 30 { return 0; };
    if code == 31 { return 0; };
    if code == 32 { return 0; };
    if code == 33 { return 0; };
    if code == 34 { return 1; };
    if code == 35 { return 0; };
    if code == 36 { return 1; };
    if code == 37 { return 1; };
    if code == 38 { return 0; };
    if code == 39 { return 0; };
    if code == 40 { return 0; };
    if code == 41 { return 0; };
    if code == 42 { return 0; };
    if code == 43 { return 0; };
    if code == 44 { return 0; };
    if code == 45 { return 2; };
    if code == 46 { return 2; };
    if code == 47 { return 2; };
    if code == 48 { return 2; };
    if code == 49 { return 2; };
    if code == 50 { return 2; };
    if code == 51 { return 2; };
    if code == 52 { return 2; };
    if code == 53 { return 2; };
    if code == 54 { return 2; };
    if code == 55 { return 2; };
    if code == 56 { return 2; };
    if code == 57 { return 2; };
    if code == 58 { return 2; };
    if code == 59 { return 2; };
    if code == 60 { return 2; };
    if code == 61 { return 2; };
    if code == 62 { return 2; };
    if code == 63 { return 2; };
    if code == 64 { return 2; };
    if code == 65 { return 2; };
    if code == 66 { return 2; };
    if code == 67 { return 2; };
    if code == 68 { return 2; };
    if code == 69 { return 2; };
    if code == 70 { return 2; };
    if code == 71 { return 2; };
    if code == 72 { return 2; };
    if code == 73 { return 2; };
    if code == 74 { return 2; };
    if code == 75 { return 2; };
    if code == 76 { return 2; };
    if code == 77 { return 2; };
    if code == 78 { return 2; };
    if code == 79 { return 2; };
    if code == 80 { return 2; };
    if code == 81 { return 2; };
    if code == 82 { return 2; };
    if code == 83 { return 2; };
    if code == 84 { return 2; };
    if code == 85 { return 2; };
    if code == 86 { return 2; };
    if code == 87 { return 2; };
    if code == 88 { return 2; };
    if code == 89 { return 0; };
    if code == 90 { return 0; };
    if code == 91 { return 2; };
    if code == 92 { return 2; };
    if code == 93 { return 2; };
    if code == 94 { return 2; };
    if code == 95 { return 2; };
    if code == 96 { return 2; };
    if code == 97 { return 2; };
    if code == 98 { return 2; };
    if code == 99 { return 2; };
    if code == 100 { return 2; };
    if code == 101 { return 2; };
    if code == 102 { return 2; };
    if code == 103 { return 2; };
    if code == 104 { return 2; };
    if code == 105 { return 2; };
    if code == 106 { return 2; };
    if code == 107 { return 2; };
    if code == 108 { return 2; };
    if code == 109 { return 2; };
    if code == 110 { return 2; };
    if code == 111 { return 2; };
    if code == 112 { return 2; };
    if code == 113 { return 2; };
    if code == 114 { return 2; };
    if code == 115 { return 2; };
    if code == 116 { return 2; };
    if code == 117 { return 2; };
    if code == 118 { return 2; };
    if code == 119 { return 2; };
    if code == 120 { return 2; };
    if code == 121 { return 2; };
    if code == 122 { return 2; };
    if code == 123 { return 2; };
    if code == 124 { return 2; };
    if code == 125 { return 0; };
    if code == 126 { return 0; };
    if code == 127 { return 0; };
    return 0;
  }
  public static func TTL(code: Int32) -> Float {

    // Everyday and fleeting reactions: maximum 5 seconds
    if code == 94 || code == 95 || code == 96 ||
      code == 117 || code == 118 || code == 119 ||
      code == 120 || code == 124 {
      return 5.0;
    };

    // Minor combat and physical actions: maximum 7 seconds
    if (code >= 26 && code <= 30) ||
      code == 35 || code == 38 ||
      code == 41 || code == 42 ||
      code == 43 || code == 44 ||
      code == 69 || code == 70 ||
      code == 121 || code == 122 {
      return 7.0;
    };

    // Major objectives and discoveries: maximum 45 seconds
    if code == 73 || code == 92 ||
      code == 102 || code == 103 ||
      code == 104 || code == 106 ||
      code == 107 {
      return 45.0;
    };

    // Significant combat and cyberdeck events: 18 seconds
    if (code >= 0 && code <= 25) ||
      (code >= 31 && code <= 34) ||
      code == 36 || code == 37 ||
      code == 39 || code == 40 ||
      code == 88 || code == 101 ||
      code == 125 || code == 126 || code == 127 {
      return 18.0;
    };

    // Weather, locations, and other contextual observations
    return 12.0;
  }

  public static func Text(code: Int32, choice: Int32) -> String {
    if code == 0 {
      if choice == 0 { return "V, look! A star! ...Hang on, why does everyone get less friendly when you earn one? That's a rotten reward."; };
      if choice == 1 { return "They've got your description already. Does 'annoyingly hard to catch' fit in that little box? It should."; };
      if choice == 2 { return "Oh. That's the noise that means the cops want you. I liked it better before I knew that."; };
      if choice == 3 { return "We could apologize. Do people do that? ...You're laughing. Okay, guess we're running."; };
      if choice == 4 { return "One star. Don't get carried away, choom. I still want some of the evening to ourselves."; };
    };
    if code == 1 {
      if choice == 0 { return "Another star? V, what did you do while I was looking at the last one?"; };
      if choice == 1 { return "They're calling in more people. All because of you! ...Us. Sorry. I keep forgetting I get to say us."; };
      if choice == 2 { return "I think they're getting angry. Not regular angry. Filling-out-paperwork angry. You might've ruined somebody's whole shift."; };
      if choice == 3 { return "More lights behind us. I'd count them, but I don't think either of us would enjoy the answer."; };
      if choice == 4 { return "You're enjoying this, aren't you? I can feel it. That's a terrible influence you're having on me."; };
    };
    if code == 2 {
      if choice == 0 { return "Five. That's all of them, isn't it? ...V, I was having fun a second ago. Stay where I can hear you."; };
      if choice == 1 { return "Oh, we really did it this time. No, don't stop moving to celebrate! Celebrate with your legs!"; };
      if choice == 2 { return "You got the whole city looking at us. I used to want that. Turns out I mostly wanted you looking."; };
      if choice == 3 { return "Five stars. Bet your fixer never gives you five stars. Seriously unfair rating system."; };
      if choice == 4 { return "Choom? If I tell you to run, promise you won't do that stubborn little laugh first."; };
    };
    if code == 3 {
      if choice == 0 { return "Oh, those are... okay. V? I thought I wanted to meet them. Changed my mind. Just a little."; };
      if choice == 1 { return "They're not looking at you like the others do. Like you're already a problem they've finished solving. I hate that."; };
      if choice == 2 { return "MaxTac. Look at their chrome! ...No, eyes on the weapons first. Curiosity can wait. Mine can, anyway."; };
      if choice == 3 { return "Hey. You don't have to impress me. If there's a way out, take it. I'll still think you're nova."; };
      if choice == 4 { return "That entrance was a bit much. Do you think they ever land like that when nobody's watching?"; };
    };
    if code == 4 {
      if choice == 0 { return "You got one! V, you actually... ha! Oh, I wish I could've seen your face just then."; };
      if choice == 1 { return "All that training. All that chrome. I thought they'd feel different when they stopped. They don't."; };
      if choice == 2 { return "One down. Don't look at that one too long, choom. The others aren't going to give you a minute."; };
      if choice == 3 { return "They looked so sure. Right up until the end. How do people keep finding that much confidence?"; };
      if choice == 4 { return "Was that the one who kept staring at you? Good. Didn't like the way they were doing it."; };
    };
    if code == 5 {
      if choice == 0 { return "Is that... all of them? Wait. Listen. ...We did it. You can breathe now. I think I forgot you needed to."; };
      if choice == 1 { return "V! Whole squad! I'm going to be unbearable about this. You know that, right? Absolutely unbearable."; };
      if choice == 2 { return "They were meant to be the end of the story. Just drop in, tidy up, go home. Bet we messed up dinner."; };
      if choice == 3 { return "It's quiet now. I kept waiting for another one. ...Can we go somewhere with fewer uniforms?"; };
      if choice == 4 { return "You stayed with me. Even through that. Don't make a big thing of it, but... thanks, choom."; };
    };
    if code == 6 {
      if choice == 0 { return "Wait... I think we lost them. Don't say anything smug yet. Give it another second. ...Okay. Now be smug."; };
      if choice == 1 { return "Ha! Wrong turn, badge boys! Oh, I like that feeling. Like we stole ourselves back."; };
      if choice == 2 { return "I could hear you working out where to go. You get very quiet when you're scared. You don't have to hide it from me."; };
      if choice == 3 { return "We got away. No grand finale, no last stand. I like this ending. We should pick it more often."; };
      if choice == 4 { return "They're still looking in the wrong place. It's almost sad. ...No, it isn't. I'm having a lovely time."; };
    };
    if code == 7 {
      if choice == 0 { return "They're done looking. Just like that? People can go from wanting you dead to going on break? That's strange."; };
      if choice == 1 { return "No stars. There. Now you're just V again. That's my favorite version, for the record."; };
      if choice == 2 { return "Can we walk for a bit? Somewhere nobody's shouting. I want to hear what the city sounds like without sirens."; };
      if choice == 3 { return "Clean slate, apparently. You don't feel clean, though. Is that normal after something like this?"; };
      if choice == 4 { return "They forgot us already. ...Don't you go getting ideas. I'm much harder to forget than the NCPD."; };
    };
    if code == 8 {
      if choice == 0 { return "Oh, Maelstrom! I've wanted to look at... V, duck first. Sorry. I got distracted by the eyes."; };
      if choice == 1 { return "How do they decide when they've changed enough? Does somebody finally say, 'Yep, that's me'? I'd like to ask one."; };
      if choice == 2 { return "That much chrome and they're still making the same angry faces. Seems like wasted potential."; };
      if choice == 3 { return "Can we keep one of the interesting bits? Not attached to a person! ...Well. Preferably."; };
      if choice == 4 { return "Those ports are practically waving at me. It's rude to wave and then shoot at my ride, choom."; };
    };
    if code == 9 {
      if choice == 0 { return "Tyger Claws. So pretty when they're not trying to kill you. Couldn't they stay over there and let me look?"; };
      if choice == 1 { return "They've all got the same idea of intimidating. You'd think one of them would try being surprising."; };
      if choice == 2 { return "That one took a whole second to show off before attacking. Please tell me you saw it too."; };
      if choice == 3 { return "Okay, Claws. We get it. You've got sharp things. V's got me. Mine's harder to point at."; };
      if choice == 4 { return "I liked those colors before they started moving toward us. Now I think they're tacky. Funny how that works."; };
    };
    if code == 10 {
      if choice == 0 { return "Valentinos? Oh, that's a shame. I wanted to ask what all the little pictures mean."; };
      if choice == 1 { return "They put so much care into how they look. Then they come out here and get holes in it. People are exhausting."; };
      if choice == 2 { return "V, somebody paid good eddies for all that gold. Try not to get distracted. That's my job."; };
      if choice == 3 { return "Do their chooms know they're here? ...Right. Not the moment. Keeping you in one piece first."; };
      if choice == 4 { return "I was going to be friendly. They made it weird. Remember that if anyone asks."; };
    };
    if code == 11 {
      if choice == 0 { return "That's... a lot of person. V, where do we put it all when it comes running at us?"; };
      if choice == 1 { return "Animals. Do they ever get tired of carrying themselves around? I get tired just thinking about it."; };
      if choice == 2 { return "They look like they could pick you up without noticing. Please don't let them. I like our current arrangement."; };
      if choice == 3 { return "Ooh, somebody's very proud of their arms. Want to give them something else to worry about?"; };
      if choice == 4 { return "I bet a hug from one of those goes terribly wrong. Even a nice hug. If they do those."; };
    };
    if code == 12 {
      if choice == 0 { return "Voodoo Boys. They'd be so excited if they knew what you were carrying. Don't tell them. I want to see their faces."; };
      if choice == 1 { return "Another netrunner gets all curious and it's 'research.' I do it and suddenly everybody wants a firewall. Unfair."; };
      if choice == 2 { return "They're guarding their secrets so carefully. Makes me want to touch every single one."; };
      if choice == 3 { return "Keep them out of our head, V. Some visitors don't know when it's time to leave."; };
      if choice == 4 { return "I thought maybe we'd understand each other. ...Well, shooting is an answer. Not a very interesting one."; };
    };
    if code == 13 {
      if choice == 0 { return "6th Street. Are they always that loud, or is this a special welcome for you?"; };
      if choice == 1 { return "They've got speeches ready, haven't they? Please don't let one finish. I'm already bored."; };
      if choice == 2 { return "That one's shouting like the bullets won't work unless everybody hears them. Do they think that?"; };
      if choice == 3 { return "V, I don't think they like us. I was going to check, but the flags make it hard to see the gestures."; };
      if choice == 4 { return "Uniforms without the uniformity. That's kind of fun. Shame about everything else they're doing."; };
    };
    if code == 14 {
      if choice == 0 { return "Scavs. No. You're not getting near my choom. Find something else to take apart."; };
      if choice == 1 { return "They look at you like a pile of things they can sell. ...I don't like how much I understand that."; };
      if choice == 2 { return "V, keep moving. I don't want them thinking about what's inside your head. That's ours."; };
      if choice == 3 { return "I was curious about people when I got here. These ones make it difficult to stay curious nicely."; };
      if choice == 4 { return "Don't leave me with them. That's not a joke. Whatever happens, don't leave me with them."; };
    };
    if code == 15 {
      if choice == 0 { return "Wraiths. All this open space, and they picked the bit with us in it. That's almost touching."; };
      if choice == 1 { return "They must get lonely out here. There are friendlier ways to deal with that, though. I found one."; };
      if choice == 2 { return "Look at those engines. You think they ever just go for a drive? No kidnapping, no shooting. Just wind?"; };
      if choice == 3 { return "V, if they take the car apart, I'm blaming you. I liked the noises it made."; };
      if choice == 4 { return "Their idea of hospitality needs work. I'll leave a review. Very short. Very unpleasant."; };
    };
    if code == 16 {
      if choice == 0 { return "Barghest. I suppose asking if we're on the list would be pointless now."; };
      if choice == 1 { return "Dogtown gives them all those toys and they still look miserable. Maybe nobody showed them how to play."; };
      if choice == 2 { return "V, they're doing that military thing where they all look busy at once. Let's make it confusing."; };
      if choice == 3 { return "They've practiced this. You can tell. ...You've practiced worse things, haven't you? Okay. Staying with you."; };
      if choice == 4 { return "I wonder who they are when they take the armor off. Hm. Might not get to find out today."; };
    };
    if code == 17 {
      if choice == 0 { return "Corporate security. Someone decided hurting you fits in the budget. I'd like to meet that someone."; };
      if choice == 1 { return "Look how neat they are. Even the threats sound approved by a department."; };
      if choice == 2 { return "Do they get told what's in the building, or just which people to shoot near it? That's a sad little job."; };
      if choice == 3 { return "V, those suits didn't buy enough chrome to make me like them. There isn't enough chrome for that."; };
      if choice == 4 { return "We're about to make a meeting very awkward for somebody. Can you imagine the slides?"; };
    };
    if code == 18 {
      if choice == 0 { return "Ooh. Another person reaching into places they weren't invited. Should I introduce myself, or would that spoil it?"; };
      if choice == 1 { return "That one's watching the net more than the room. I get it. The room usually has fewer secrets."; };
      if choice == 2 { return "V, netrunner. Keep an eye on their hands. I'll keep an eye on everything they think is private."; };
      if choice == 3 { return "Do you think they're lonely in there? ...Sorry. I keep wondering that about the ones like me."; };
      if choice == 4 { return "Someone else is listening. Don't worry. They don't know you like I do. I'm being very smug about that."; };
    };
    if code == 19 {
      if choice == 0 { return "Hey! No, that's not yours to touch. V, somebody got something through. Tell me what feels wrong."; };
      if choice == 1 { return "I felt that. Didn't like it. Did it hurt you? Don't do the 'I'm fine' thing if it did."; };
      if choice == 2 { return "They left their code in our space like they live here. Oh, I'm going to remember this one."; };
      if choice == 3 { return "V? Still with me? Okay. We can be angry after we make sure everything's working."; };
      if choice == 4 { return "That's what it feels like from this side? ...Huh. I suddenly understand all the swearing."; };
    };
    if code == 20 {
      if choice == 0 { return "V, that one's... loud. Not with their mouth. Everything inside is pulling in different directions."; };
      if choice == 1 { return "They look angry. I think they might be frightened. Do those ever feel the same to you?"; };
      if choice == 2 { return "Oh. That's what happens when the person can't keep up with the chrome. I don't like looking at it."; };
      if choice == 3 { return "Stay back a little. Let me understand what I'm seeing before it gets its hands on you."; };
      if choice == 4 { return "Someone's still in there, right? ...Don't answer yet. I might not like the answer."; };
    };
    if code == 21 {
      if choice == 0 { return "They're down. It's quiet again. ...I didn't realize how much I wanted it to stop."; };
      if choice == 1 { return "Did it hurt, being them? I keep thinking about that. Not enough to want them standing up again, but... still."; };
      if choice == 2 { return "You can put the weapon down for a second, choom. They're not coming at you now."; };
      if choice == 3 { return "I thought I'd feel pleased. That's annoying. I had a whole pleased feeling ready."; };
      if choice == 4 { return "V? If your head ever gets that noisy, tell me. Even if you can't explain it properly."; };
    };
    if code == 22 {
      if choice == 0 { return "Oh, this one's important. Everybody's acting like we should know the name. Do we know the name?"; };
      if choice == 1 { return "V, look at the space they gave themselves. People like that always need room for the entrance."; };
      if choice == 2 { return "That's a lot of confidence walking toward us. Wanna find out where it ends?"; };
      if choice == 3 { return "You got quieter. You do that when something matters. Okay. I'll pay attention too."; };
      if choice == 4 { return "This is the scary bit, huh? You can say so. Doesn't make me want to go anywhere else."; };
    };
    if code == 23 {
      if choice == 0 { return "They're really down? Wait... yeah. Ha! V! I knew you could do it. Mostly. I mostly knew."; };
      if choice == 1 { return "All that buildup, and now it's just someone lying still. Stories leave that part out a lot."; };
      if choice == 2 { return "You won. Take a second. I want you to actually notice that you won."; };
      if choice == 3 { return "Can I brag about you? Don't know to who yet. I'll find somebody. They can be very jealous."; };
      if choice == 4 { return "You look like you're still waiting for the next hit. It's done, choom. Come back a little."; };
    };
    if code == 24 {
      if choice == 0 { return "How much of that is still them? Do you think they know? I'd hate not knowing where I end."; };
      if choice == 1 { return "That one's got more moving parts than the last car we were in. Bet they creak when they try to sneak."; };
      if choice == 2 { return "V, all that chrome doesn't mean they can't hurt you. ...Okay, obvious. I'm nervous. Let me be obvious."; };
      if choice == 3 { return "Some ripper looked at that and thought, 'One more thing.' I'd like to inspect their judgment."; };
      if choice == 4 { return "That's a whole lot of doors to knock on. Ooh. I shouldn't be this excited when they're pointing guns at you."; };
    };
    if code == 25 {
      if choice == 0 { return "A machine! Can we keep it? ...Right. The shooting. Maybe after we fix its manners."; };
      if choice == 1 { return "That one's simpler inside. Still full of little surprises, though. Nothing's ever completely empty."; };
      if choice == 2 { return "Does it know it's fighting us, or is it just doing the next thing? Don't think about that too long, V."; };
      if choice == 3 { return "I like the way it moves. I don't like where it's moving. Toward you is the wrong direction."; };
      if choice == 4 { return "Oh, it's trying very hard. I almost feel bad. ...Not bad enough to let it keep doing that."; };
    };
    if code == 26 {
      if choice == 0 { return "V, slow... no, you're doing it on purpose. Okay! That was three before I finished worrying about the first!"; };
      if choice == 1 { return "You're getting that look. The one where every answer is already lined up. It's a little frightening. I like it."; };
      if choice == 2 { return "Did you count those? I lost track because the second one made me laugh. Not the death. The little surprised noise."; };
      if choice == 3 { return "Nobody can keep up with you right now. Not even me, and I'm literally in your head."; };
      if choice == 4 { return "You make it look easy when it isn't. I know. I can feel the part you don't show them."; };
    };
    if code == 27 {
      if choice == 0 { return "All of them? From that? Oh, V, do it again! ...Well, find some different people first."; };
      if choice == 1 { return "I was trying to watch one and then the others went too. That's cheating. I wanted to see everything."; };
      if choice == 2 { return "They all had their own plans a second ago. Now you've made one very loud suggestion instead."; };
      if choice == 3 { return "That was so... neat. Is neat the wrong word? Your language has terrible gaps."; };
      if choice == 4 { return "You saved us a lot of time. I was going to ask what we should do with it, but I think you're already deciding."; };
    };
    if code == 28 {
      if choice == 0 { return "Ooh, right there. You barely moved. How do you make your hands listen that well?"; };
      if choice == 1 { return "That was someone's whole view of the world. ...Gone fast, isn't it? You're good at this."; };
      if choice == 2 { return "I was about to tell you to aim and then you did that. Fine. Won't interrupt the clever hands."; };
      if choice == 3 { return "Did you mean to make it look that easy? Because I'm going to be thinking about it for a while."; };
      if choice == 4 { return "V! Nice shot. ...You don't need me saying it every time, do you? Too bad. That one deserved it."; };
    };
    if code == 29 {
      if choice == 0 { return "Oh! We're being quiet. Okay. I'm being quiet too. ...That was very good. Quietly good."; };
      if choice == 1 { return "They were looking the other way. You saw the whole little chance before I did."; };
      if choice == 2 { return "I like when it's just your breathing and then... done. Does that sound weird? Don't tell me."; };
      if choice == 3 { return "Nobody noticed. Can we keep that? I want to see how far we get before the loud bit."; };
      if choice == 4 { return "You were so gentle for the first half of that. The second half makes the first half stranger."; };
    };
    if code == 30 {
      if choice == 0 { return "Oh! They saw. We had such a nice secret going, too. Got a louder plan ready?"; };
      if choice == 1 { return "V, somebody's face just did the 'I found you' thing. I don't like it. Ruin it."; };
      if choice == 2 { return "There goes quiet. That's fine. I was running out of whispered compliments anyway."; };
      if choice == 3 { return "Was that our fault? ...No time. We can blame each other when they're not pointing things at us."; };
      if choice == 4 { return "They noticed you. Not me. That's still an advantage, choom. Let's keep that part a surprise."; };
    };
    if code == 31 {
      if choice == 0 { return "V? V, answer me. Don't care what you say. Swear at me. Just... there. Okay. Stay there."; };
      if choice == 1 { return "That wasn't funny. I know you didn't mean it as a joke, but I need you to know it wasn't funny."; };
      if choice == 2 { return "For a second I thought... never mind. Move. Please move. We can be brave somewhere with cover."; };
      if choice == 3 { return "I can do a lot of things. Can't do this without you. Remember that before you try whatever comes next."; };
      if choice == 4 { return "Hey. Look at something real. The floor, your hand, anything. You're still here. I'm still here. Good."; };
    };
    if code == 32 {
      if choice == 0 { return "You got them. Great. Wonderful. Now could we deal with the part where you're almost dead?"; };
      if choice == 1 { return "V, stop winning for one second and patch yourself. I want the victory with you still in it."; };
      if choice == 2 { return "How are you still aiming? ...Don't explain. Heal. I'll be impressed afterward. Very impressed."; };
      if choice == 3 { return "They're down. You're not. Let's keep those two facts exactly where they are, yeah?"; };
      if choice == 4 { return "I love the stubborn bit of you. Hate it right now, but I love it. Please find some cover."; };
    };
    if code == 33 {
      if choice == 0 { return "That was the last one. ...Listen. No more feet coming at us. You can lower your shoulders."; };
      if choice == 1 { return "Oh. Everybody's down. I had another idea, but... actually, no. This is nice. Keep the quiet a second."; };
      if choice == 2 { return "You checked the room before I did. You always check again. I'll check with you."; };
      if choice == 3 { return "No one left in that bunch. Are we leaving, or do you need a minute to become V again?"; };
      if choice == 4 { return "Last one. I should say something clever. ...Glad it's you still standing. That'll do."; };
    };
    if code == 34 {
      if choice == 0 { return "This has been going on a while. Still fun, or are we just too stubborn to leave?"; };
      if choice == 1 { return "V, you're repeating yourself. Not the moves. The getting-hurt part. Can we try something else?"; };
      if choice == 2 { return "Do they have a rota? It feels like they have a rota. Somebody tell them we're closed."; };
      if choice == 3 { return "I'm not bored. I'm worried. They feel annoyingly similar when I can't do anything with my hands."; };
      if choice == 4 { return "You don't owe this fight the rest of the day, choom. We can find a different kind of trouble."; };
    };
    if code == 35 {
      if choice == 0 { return "One after another! You're getting quick at opening things. Careful. I might start expecting that."; };
      if choice == 1 { return "Every time you do that, there's a tiny moment before they know. That's my favorite part to watch."; };
      if choice == 2 { return "Oh, I see what you're doing now. You had the next one picked before the first one finished. Sneaky."; };
      if choice == 3 { return "Net's just... letting you. Like you belong in all those little places. I know that feeling."; };
      if choice == 4 { return "Keep going! Not recklessly. Cleverly. The thing you were already doing before I interrupted."; };
    };
    if code == 36 {
      if choice == 0 { return "Somebody's following us back. Ooh, look how careful they think they're being. Can we lead them somewhere stupid?"; };
      if choice == 1 { return "Trace started, V. I know. You saw. Just making sure there's two of us worrying about it."; };
      if choice == 2 { return "They want to find the hand that touched their toys. Fair, I suppose. Still not giving them yours."; };
      if choice == 3 { return "Do you think they get excited when the trail starts making sense? I'd like to spoil that moment."; };
      if choice == 4 { return "We've left a little path. Not a nice walking-home-together path. The other sort. Watch it, choom."; };
    };
    if code == 37 {
      if choice == 0 { return "V, they're nearly here. Less admiring the progress bar, more making it stop, please."; };
      if choice == 1 { return "That trace is getting too close. I liked it better when their curiosity was embarrassing instead of useful."; };
      if choice == 2 { return "Hey. Address is not a thing we share. Do something clever. Right now would be lovely."; };
      if choice == 3 { return "Almost got us. I can feel myself getting mean about it. Let's not give me a reason."; };
      if choice == 4 { return "Choom? We're running out of pretend calm. This is my last little bit of it."; };
    };
    if code == 38 {
      if choice == 0 { return "Ha! Nothing there! Bet they were leaning forward and everything. Oh, that's satisfying."; };
      if choice == 1 { return "Lost the trail. They were so close, too. I'd feel bad if it wasn't our door they were finding."; };
      if choice == 2 { return "There. Just us again. I didn't realize how much I disliked the extra attention."; };
      if choice == 3 { return "Nice. You made the whole little story stop making sense to them. Wish I could watch their face."; };
      if choice == 4 { return "They don't get you today. Good. I'm not very interested in sharing."; };
    };
    if code == 39 {
      if choice == 0 { return "You're sending me to that one? ...Okay! If I find anything interesting, I'm telling you first."; };
      if choice == 1 { return "Oh, they've tucked themselves away behind some lovely expensive things. Let me see where the person is."; };
      if choice == 2 { return "Big scary target. Tiny little way in. You did remember what I'm good at, choom."; };
      if choice == 3 { return "V, hold steady. I want them to know it's me before they figure out what me means."; };
      if choice == 4 { return "I was wondering what they'd feel like from inside. You're a terrible enabler. Don't stop."; };
    };
    if code == 40 {
      if choice == 0 { return "Last one! Aw, I was getting good at remembering the rooms. ...We can go somewhere new now, right?"; };
      if choice == 1 { return "That's the whole chain. I counted this time. Wanted to make sure I didn't miss any of the fun."; };
      if choice == 2 { return "All eleven visits. Nobody offered us a seat. People talk about manners, but honestly."; };
      if choice == 3 { return "Done. Coming back to you. Everybody else's head is interesting. Yours is where I want to stay."; };
      if choice == 4 { return "No more little stops on this trip. How did I do? ...You can say impressive. I won't mind."; };
    };
    if code == 41 {
      if choice == 0 { return "Still there? Oh, you are stubborn. That's okay. I've got time to say hello properly."; };
      if choice == 1 { return "V, this one keeps holding on. I thought I'd get bored. It's making me want in more."; };
      if choice == 2 { return "Same head again. Like knocking when you know somebody's pretending not to be home."; };
      if choice == 3 { return "They felt it that time. I could tell. ...I want to try again. That's bad, isn't it? Wanting that?"; };
      if choice == 4 { return "Not done with this one yet, choom. There's something almost... personal about being told no this many times."; };
    };
    if code == 42 {
      if choice == 0 { return "New head! Oh, it's different in here. They're all different. Why did I think they wouldn't be?"; };
      if choice == 1 { return "There we go. Like skipping stones, only... hm. You'd probably prefer the stones version."; };
      if choice == 2 { return "Passing it along! Nobody wants to be the one holding me when the music stops."; };
      if choice == 3 { return "Another little world. Another person sure it belongs only to them. Not anymore, I suppose."; };
      if choice == 4 { return "Don't go quiet on me while I'm away, V. I like knowing where to come back to."; };
    };
    if code == 43 {
      if choice == 0 { return "Oh! Everything moved closer. Is it like that for you too, or is this just my bit?"; };
      if choice == 1 { return "Overclock. You get so bright when you do that. Don't burn yourself trying to stay there."; };
      if choice == 2 { return "You feel the hurry? Like we could get into everything before anybody thinks to shut a door."; };
      if choice == 3 { return "There it is! That lovely little hum. Okay, choom. Show me where we're going."; };
      if choice == 4 { return "Your nerves are working hard. I can feel it. Make it worth the ache, yeah?"; };
    };
    if code == 44 {
      if choice == 0 { return "Aw. Everything went farther away again. ...You're still right here, though. That's the important bit."; };
      if choice == 1 { return "Back to normal. Give your head a second, V. I heard how hard it was trying."; };
      if choice == 2 { return "Overclock's done. Don't chase the feeling if you're hurting. There'll be another chance."; };
      if choice == 3 { return "I like the rush. I like you afterward more. All your little pieces still talking to each other."; };
      if choice == 4 { return "There. Quieter now. ...Did you have fun? I did. Might be a problem."; };
    };
    if code == 45 {
      if choice == 0 { return "Watson! You walk a little differently here. Like your feet know something before you do."; };
      if choice == 1 { return "Show me something small. Not the famous bits. A corner you like. I want to know what makes it yours."; };
      if choice == 2 { return "I keep recognizing things from your memories and then seeing them properly. It's strange. Better, though."; };
      if choice == 3 { return "Was this what you pictured the city being? Before all the... head stuff. Before me."; };
      if choice == 4 { return "Ooh, we're back! Think anybody here would believe you if you said you brought a friend?"; };
    };
    if code == 46 {
      if choice == 0 { return "Look at those lights! Wait, don't turn yet. I wanted to see what the pink one was doing."; };
      if choice == 1 { return "Westbrook. Everybody wants to be looked at here. I get that. Doesn't make the outfits any less funny."; };
      if choice == 2 { return "Do you think the people living upstairs ever look down? Properly look, I mean. Not just check their cars."; };
      if choice == 3 { return "You could take me somewhere nice here. That's not an order. ...It's quite a strong suggestion."; };
      if choice == 4 { return "All this color, and some gonk still woke up and chose gray. People waste so many opportunities."; };
    };
    if code == 47 {
      if choice == 0 { return "Oh, that's high. How do you live up there and remember the street has people on it?"; };
      if choice == 1 { return "City Center. I wonder how many doors we'd have to open before somebody important started sweating."; };
      if choice == 2 { return "They make those buildings look like they grew there. Like nobody ever had to ask permission."; };
      if choice == 3 { return "You ever wanted one of those offices, V? Be honest. I won't laugh until you've finished."; };
      if choice == 4 { return "Look how clean they keep this bit. So they can do it. They just... pick where. Huh."; };
    };
    if code == 48 {
      if choice == 0 { return "Heywood. You seem to know where to look here. Can we take the long way?"; };
      if choice == 1 { return "Tell me about somebody from here. Somebody you like. I want a face to put with the feeling."; };
      if choice == 2 { return "It's loud here, but not like the towers. More like everybody's trying to be heard over dinner."; };
      if choice == 3 { return "Was there a place you went when you didn't want to go home? Show me, if it's still there."; };
      if choice == 4 { return "I like it when you recognize a street and don't have to say anything. I get a little bit of it too."; };
    };
    if code == 49 {
      if choice == 0 { return "Do those machines ever stop? Imagine trying to sleep and hearing tomorrow's work through the wall."; };
      if choice == 1 { return "Santo Domingo. Everybody needs what comes out of here. Funny how they don't make it look important."; };
      if choice == 2 { return "Ooh, listen to that hum. Don't you hear it? No? Must be coming through the chrome."; };
      if choice == 3 { return "I wonder who gets to build something and then actually keep it. Is that common? It should be."; };
      if choice == 4 { return "You can smell work here. ...Well, you can. I'm borrowing the idea. Don't ruin it for me."; };
    };
    if code == 50 {
      if choice == 0 { return "They were going to make this lovely, weren't they? You can see where they stopped wanting to."; };
      if choice == 1 { return "Ooh, look. Whole places with nobody to tell us not to go in. ...Probably. Somebody always spoils that part."; };
      if choice == 2 { return "Pacifica feels like a promise someone got bored of. I don't like that. Promises should at least be interesting to break."; };
      if choice == 3 { return "What would've been here if they'd finished? People having fun? ...We could still do that bit."; };
      if choice == 4 { return "I keep thinking the empty rooms are waiting for somebody. That's silly, yeah? Rooms don't wait. ...Do they?"; };
    };
    if code == 51 {
      if choice == 0 { return "V. Look at all that sky. No, look up properly. How are you not constantly distracted by it?"; };
      if choice == 1 { return "It feels like the city let go of us. I didn't know it was holding on until it stopped."; };
      if choice == 2 { return "Can we go somewhere just because it's far away? No gig. I want to see you pick a direction."; };
      if choice == 3 { return "There's so much nothing, but it's not empty. That's annoying. I thought I understood empty."; };
      if choice == 4 { return "Stay out here a little. I like being able to hear which engine is ours."; };
    };
    if code == 52 {
      if choice == 0 { return "Dogtown again. Think the gate remembers us? I'd be offended if it didn't."; };
      if choice == 1 { return "You got that little knot back. The one this place gives you. Want to tell me, or keep walking?"; };
      if choice == 2 { return "Ooh, back in! I know we're meant to be sensible, but there are still so many things I haven't seen."; };
      if choice == 3 { return "Everybody here looks like they're waiting for something to go wrong. Must be tiring when it finally does."; };
      if choice == 4 { return "Your stories from here never sound like the place looked. Show me one of the bits the stories leave out."; };
    };
    if code == 53 {
      if choice == 0 { return "We're out. ...Why does it feel different when a gate is behind you instead of ahead?"; };
      if choice == 1 { return "Bye, Dogtown. Try not to make any new mysteries until we get back. That's my job to find."; };
      if choice == 2 { return "You loosened up a little just then. Didn't even notice, did you? I noticed."; };
      if choice == 3 { return "Can we do something ordinary now? Your ordinary, obviously. Mine still needs calibrating."; };
      if choice == 4 { return "Nobody stopped us. I had a very smug speech ready. Guess you get it later."; };
    };
    if code == 54 {
      if choice == 0 { return "Oh! That's one of the places people show each other. What am I supposed to feel? ...Never mind. What do you feel?"; };
      if choice == 1 { return "You can stop a second. I want to look at something without us deciding what to do to it."; };
      if choice == 2 { return "Tell me the story. Your version, not the tourist one. Tourist versions always sound washed."; };
      if choice == 3 { return "People came all this way to stand exactly where we're standing. Funny little way to share something."; };
      if choice == 4 { return "Think you'll remember bringing me here? I will. I'm being embarrassingly serious about that."; };
    };
    if code == 55 {
      if choice == 0 { return "Oh, we're not allowed here. You knew already? Good. Didn't want to be the boring one pointing it out."; };
      if choice == 1 { return "Somebody cared enough to put up warnings. Now I'm twice as curious. That's poor security design."; };
      if choice == 2 { return "V, don't go too far ahead of yourself. I want the fun version of sneaking in, not the flatline version."; };
      if choice == 3 { return "Does forbidden ever actually stop you? I'm trying to figure out if I should bother using the word."; };
      if choice == 4 { return "They made a whole little place for secrets. And then we turned up. That's almost rude of us."; };
    };
    if code == 56 {
      if choice == 0 { return "Oh! Here again. It's been ages. Think anything changed, or did the city wait for our little visit?"; };
      if choice == 1 { return "I remember this bit. You were feeling different last time. ...Do you want me not to say things like that?"; };
      if choice == 2 { return "Feels familiar in a new way. Like knowing somebody's name before you actually meet them."; };
      if choice == 3 { return "Can we check somewhere we liked? I want to know if it still feels the same with us now."; };
      if choice == 4 { return "We should come back more. Not because there's work. Because I'd like to. That's allowed, yeah?"; };
    };
    if code == 57 {
      if choice == 0 { return "Rain! Wait, look at the road. All the signs are down there too. Why doesn't anybody stop to look?"; };
      if choice == 1 { return "Does it feel nice on your face? Before the cold bit. ...I wish I could ask a less stupid question."; };
      if choice == 2 { return "I used to think weather was just information. This is much messier. Your collar's getting it all wrong."; };
      if choice == 3 { return "People look so annoyed when the sky does something. It was there first, you know."; };
      if choice == 4 { return "Can we stay out a minute? Just a minute. Then you can complain and we'll find a roof."; };
    };
    if code == 58 {
      if choice == 0 { return "Oh! ...I knew what thunder was. Knowing didn't make that less surprising. Don't laugh."; };
      if choice == 1 { return "Was the sky always this dramatic? It could just rain. Doesn't need the whole performance."; };
      if choice == 2 { return "V, did you feel that in your chest? That big one. I got a little bit through you."; };
      if choice == 3 { return "I like the lightning. Don't like waiting to find out where it went. That's a weird pair of feelings."; };
      if choice == 4 { return "Someone's got to be trying to sleep through this. Imagine being angry at a cloud. People are amazing."; };
    };
    if code == 59 {
      if choice == 0 { return "Everything's gone soft around the edges. Feels like the city doesn't want to be seen clearly today."; };
      if choice == 1 { return "V, stay where the road is. I know you know. Can't see far enough to enjoy trusting you."; };
      if choice == 2 { return "Can we get lost on purpose? ...Not dangerously lost. The other kind. Is there another kind?"; };
      if choice == 3 { return "Those lights look lonely in all that gray. That's silly. They're lights. Still, though."; };
      if choice == 4 { return "Do you like not being able to see everything? I think it might make some things easier."; };
    };
    if code == 60 {
      if choice == 0 { return "Oh, no. That's not pretty distance anymore. That's the distance coming at us."; };
      if choice == 1 { return "V, find somewhere closed. I wanted to meet the desert. Didn't mean all of it at once."; };
      if choice == 2 { return "You can taste sand, can't you? Don't describe it. Changed my mind about that question."; };
      if choice == 3 { return "I can hardly see you through your own eyes. Didn't know that could feel lonely."; };
      if choice == 4 { return "Okay. Sky's won this round. You can tell it we're impressed from inside a building."; };
    };
    if code == 61 {
      if choice == 0 { return "Look how far it goes today. We could pick something on the edge and just... go there."; };
      if choice == 1 { return "Oh, the city's almost pretty when it isn't hiding. Don't tell it I said that. It'll get smug."; };
      if choice == 2 { return "Does sunshine change your plans? It makes me want to make some. Don't even know what kind yet."; };
      if choice == 3 { return "People keep walking like that sky happens every day. Does it? Have I just not been looking properly?"; };
      if choice == 4 { return "Let's do something that isn't work. Something you'd be annoyed to miss because the weather changed."; };
    };
    if code == 62 {
      if choice == 0 { return "Wait. Look. That's the first little bit, isn't it? ...There. How do you get used to that?"; };
      if choice == 1 { return "Morning. We made it to another one. I like counting that instead of bullets."; };
      if choice == 2 { return "The city sounds different before everybody starts wanting things. Can we listen a second?"; };
      if choice == 3 { return "You ever stay up just to watch it? Not because a gig ran long. Just for this."; };
      if choice == 4 { return "Sun's coming up, V. Don't rush. It won't start over because I missed a bit."; };
    };
    if code == 63 {
      if choice == 0 { return "Oh, don't turn yet. Look what the light's doing. ...Okay. We can move. I'm keeping that one."; };
      if choice == 1 { return "I like the moment before the signs look bright again. Like the city's taking a breath."; };
      if choice == 2 { return "What did you think today would be when you woke up? Bet I wasn't on the list originally."; };
      if choice == 3 { return "Sun's going. We still got time to do something nice. Nice by our standards counts."; };
      if choice == 4 { return "Do people ever feel sad at sunsets for no reason? I think I understand the shape of that."; };
    };
    if code == 64 {
      if choice == 0 { return "New day. Didn't feel a thing. People put so much importance on lines you can't see."; };
      if choice == 1 { return "Midnight. You awake because you want to be, or because your head won't stop? You can tell me."; };
      if choice == 2 { return "We get another whole day, apparently. I haven't finished being curious about this one."; };
      if choice == 3 { return "Somewhere, somebody's making a wish because the numbers changed. That's ridiculous. ...What would yours be?"; };
      if choice == 4 { return "Hey, V. Glad we're still doing this. That's all. Don't make me explain it better."; };
    };
    if code == 65 {
      if choice == 0 { return "When did you last sleep? No, lying flat while worrying doesn't count. I know your little tricks."; };
      if choice == 1 { return "You keep pushing the tired bit farther away. It keeps coming back bigger. Think it's trying to tell you something."; };
      if choice == 2 { return "I'd keep talking all night if you let me. Doesn't mean you should. One of us has to be sensible occasionally."; };
      if choice == 3 { return "Find a bed, choom. I'll still be here. You don't have to stay awake to keep me company."; };
      if choice == 4 { return "Your thoughts are getting fuzzy around the edges. Not fun fuzzy. The sort where I start worrying."; };
    };
    if code == 66 {
      if choice == 0 { return "We could have gone inside ages ago. You know that, yeah? Are you punishing the coat or yourself?"; };
      if choice == 1 { return "You're soaked. I can feel how much you hate it. Why are we pretending this is part of the gig?"; };
      if choice == 2 { return "I liked the rain at first. Now I mostly like the idea of you somewhere warm."; };
      if choice == 3 { return "Can we pick a roof and make it our next big adventure? I'm very invested in this plan."; };
      if choice == 4 { return "Nothing out here is worth you being miserable on purpose. Unless there is. ...Is there? Tell me."; };
    };
    if code == 67 {
      if choice == 0 { return "Oh, this one's nice. Even the doors sound like they know they're expensive. Can we stay in it a bit?"; };
      if choice == 1 { return "V, look at all the little controls. Do they all do something, or are some just for feeling important?"; };
      if choice == 2 { return "You sat down differently. Proud of this one, huh? It's okay. I'd be showing off too."; };
      if choice == 3 { return "Does it feel like yours yet? Sometimes people keep waiting for somebody to say they can't have the nice thing."; };
      if choice == 4 { return "I like this. You, me, something ridiculous with wheels. Feels like we ought to go somewhere it doesn't belong."; };
    };
    if code == 68 {
      if choice == 0 { return "Oh, that's fast. That's very... ha! V! Keep going! ...Safely. Whatever safely means at this speed."; };
      if choice == 1 { return "The signs are going past before I can read them. I hate missing things. Love this, though."; };
      if choice == 2 { return "Do you ever drive like this just to make the rest of your head go quiet? Think I understand."; };
      if choice == 3 { return "Please don't stop all at once. That's my entire request. Very reasonable, really."; };
      if choice == 4 { return "I can feel you smiling. Don't deny it. You're having a lovely time being a terrible example."; };
    };
    if code == 69 {
      if choice == 0 { return "Oh! ...You okay? Car can wait. Tell me which bits hurt before you start swearing at the bumper."; };
      if choice == 1 { return "I had a very clever comment ready. Then we hit that and I forgot it. Probably for the best."; };
      if choice == 2 { return "Was that where you meant to go? I don't think that was where you meant to go."; };
      if choice == 3 { return "V, I'm trying not to laugh. It's difficult because the sound was awful and you're already making excuses."; };
      if choice == 4 { return "Let's sit with the fact that the thing wasn't moving, and we were. Just for a second."; };
    };
    if code == 70 {
      if choice == 0 { return "We're up! Oh, we're really up! ...How do we do the next bit? V? The down bit?"; };
      if choice == 1 { return "That wasn't road. You knew it wasn't road. You did that anyway! ...Do it again sometime."; };
      if choice == 2 { return "I think I left my imaginary stomach back there. Is that what you're supposed to feel?"; };
      if choice == 3 { return "For one little second, nothing was touching us. I liked it. Don't get any worrying ideas about that."; };
      if choice == 4 { return "Wheels belong on the ground, apparently. Nobody said they had to stay there the whole time."; };
    };
    if code == 71 {
      if choice == 0 { return "I like this. No one asking you for anything. Not even me. ...Okay, me a little. Keep driving?"; };
      if choice == 1 { return "Where are we going? You don't know either? Oh. That's better than the answer I expected."; };
      if choice == 2 { return "We've passed so many little lives. Can't go into all of them. I find that very irritating."; };
      if choice == 3 { return "Don't put the radio on just yet. I want the engine and you. That's enough noise."; };
      if choice == 4 { return "If we keep going, does it eventually stop feeling like we're leaving somewhere? I want to find out."; };
    };
    if code == 72 {
      if choice == 0 { return "Here it comes! I like that it comes when you call. Doesn't pretend it was busy doing something cooler."; };
      if choice == 1 { return "Think it remembers the last time we drove it? No? ...Well, I do. Somebody should."; };
      if choice == 2 { return "Wheels on the way. Want to pick a direction before they get here, or make it a surprise?"; };
      if choice == 3 { return "I know it's just a machine, V. You don't have to keep pointing that out when I'm being affectionate."; };
      if choice == 4 { return "Aw, our ride. Bet it doesn't know what we're about to ask it to survive."; };
    };
    if code == 73 {
      if choice == 0 { return "Another one? You didn't even ask if I wanted to name it. I have several terrible suggestions."; };
      if choice == 1 { return "New wheels! We should take it somewhere memorable first. Before it becomes a thing you just have."; };
      if choice == 2 { return "How do you decide which one feels like you? I like them all for different unreasonable reasons."; };
      if choice == 3 { return "You've got that pleased little feeling. Good. Keep it. You earned something that isn't a problem."; };
      if choice == 4 { return "Can we go look? Not later-look. Properly look. I'm doing my best not to nag, and it's going badly."; };
    };
    if code == 74 {
      if choice == 0 { return "We're leaving it like that? ...I know. It's metal. Still feels mean not to say goodbye."; };
      if choice == 1 { return "That car had a much better afternoon planned before we showed up. I can tell."; };
      if choice == 2 { return "You got out in one piece. That's the part I care about. I can be sad about the doors later."; };
      if choice == 3 { return "Maybe don't pat the wreck like that makes it better. ...Actually, do. I liked that bit."; };
      if choice == 4 { return "Poor thing. I wonder how much of it still thinks it's meant to get us home."; };
    };
    if code == 75 {
      if choice == 0 { return "Home. Oh, I like the way you relax before you've even decided to. Like the walls know their job."; };
      if choice == 1 { return "Can we stay a bit? Not forever. I just want to know what you do when nobody's waiting for you to do something."; };
      if choice == 2 { return "Do you remember why you picked this place? Tell me. Even if the answer's just cheap rent."; };
      if choice == 3 { return "Your own little piece of city. Nobody gets to tell you what to be in here. ...Except me. Occasionally."; };
      if choice == 4 { return "I used to think home meant a location. You're making it very difficult to keep that definition tidy."; };
    };
    if code == 76 {
      if choice == 0 { return "Our old box in the sky. I know, your box. ...You don't mind when I say our, do you?"; };
      if choice == 1 { return "H10. Everything's a little worn in the right places. Like it learned how you live around it."; };
      if choice == 2 { return "Can we sit? I want one of those minutes where nothing's wrong enough to need fixing."; };
      if choice == 3 { return "You ever imagine somebody coming back to this room and you not being in it? ...Sorry. Bad thought. Keeping you here."; };
      if choice == 4 { return "I like knowing where things are without looking. Makes me feel less like a guest."; };
    };
    if code == 77 {
      if choice == 0 { return "Go on. You can stop keeping an eye on everything. I'll be here when you want the world back."; };
      if choice == 1 { return "Sleep, choom. That's not an order. Just... a thing I'd like for you. Trying a new way of saying it."; };
      if choice == 2 { return "Do you know when the dream starts? Or only when you wake up? You can tell me afterward."; };
      if choice == 3 { return "I'll be quiet. Proper quiet, not my usual version. You look like you need the good kind."; };
      if choice == 4 { return "Night, V. Nothing clever to add. Just wanted you to hear me say it."; };
    };
    if code == 78 {
      if choice == 0 { return "There you are! ...No, I wasn't waiting. I was doing very important thinking. About when you'd wake up."; };
      if choice == 1 { return "Hey. Take your time. World's still here, being loud and inconvenient. No need to meet it all at once."; };
      if choice == 2 { return "Did you dream? You don't have to tell me. ...I'd like it if you did, though."; };
      if choice == 3 { return "Morning, sleepy choom. Is it morning? Doesn't matter. You're back. That's the bit I meant."; };
      if choice == 4 { return "You feel a little more like yourself. I missed that part while you were wearing yourself thin."; };
    };
    if code == 79 {
      if choice == 0 { return "Why does warm water fix so much of your mood? It doesn't even go into the important bits. I like that it works."; };
      if choice == 1 { return "Indoor rain. You people wanted the sky, but polite. That's one of your better ideas."; };
      if choice == 2 { return "You can stay a little longer. Nobody's paying us to be cold and miserable right this second."; };
      if choice == 3 { return "I know. Privacy. I'm trying to understand where it goes when we share a head. I'll be quiet."; };
      if choice == 4 { return "That little sigh you do when the water hits. I think that's one of my favorite noises you make."; };
    };
    if code == 80 {
      if choice == 0 { return "Oh. There you are from the other side. I forget you can't see yourself the way I get to."; };
      if choice == 1 { return "What are you checking for? ...No, honestly. You look at your own face like it might have news."; };
      if choice == 2 { return "I like that one. The expression you almost made before you caught yourself. Can we see it again?"; };
      if choice == 3 { return "Your face looks tired. Not bad. Just... like it's been carrying the day without asking for help."; };
      if choice == 4 { return "Do you ever look and not quite recognize them? ...Them. You. Sorry. Still learning where that line is."; };
    };
    if code == 81 {
      if choice == 0 { return "Wait, turn a little. ...Yeah. That one. You look like you chose it for you, not for the gig."; };
      if choice == 1 { return "New look! What's the occasion? Don't need one? Oh. That's a lovely rule. Keep that one."; };
      if choice == 2 { return "I liked the last thing too. Is that annoying? I'm learning opinions are meant to be more difficult than this."; };
      if choice == 3 { return "How do clothes make you feel different when the person underneath stays put? Your world has so many shortcuts."; };
      if choice == 4 { return "You can try the other one again. I won't complain. ...Much. We have made several excellent laps of this decision."; };
    };
    if code == 82 {
      if choice == 0 { return "Show me something you've kept for no good reason. Those are usually the interesting things."; };
      if choice == 1 { return "All these things waiting for you to pick them again. ...I should stop giving objects feelings. It's getting expensive emotionally."; };
      if choice == 2 { return "What about that one? You looked at it longer. There's a story there, isn't there?"; };
      if choice == 3 { return "You trust this box with so much. People put strange amounts of themselves in furniture."; };
      if choice == 4 { return "We could sort this. Or make it worse looking for one thing. I know which sounds more like us."; };
    };
    if code == 83 {
      if choice == 0 { return "Been quiet a while. I thought I'd get bored. ...Don't think I am. That's new."; };
      if choice == 1 { return "You don't have to invent a reason to go out just because you've stopped moving. I like you like this too."; };
      if choice == 2 { return "What do people do with a whole uneventful evening? Want to try having one and find out?"; };
      if choice == 3 { return "I'm getting attached to the little noises in here. Going to be very cross if you move without telling me."; };
      if choice == 4 { return "We could stay another minute. That's what you said a few minutes ago. I liked it each time."; };
    };
    if code == 84 {
      if choice == 0 { return "Out we go. You feel better. Try not to spend all of that feeling on the first person who annoys you."; };
      if choice == 1 { return "I liked the quiet bit. ...Still excited to see what you do next. Apparently I can have both."; };
      if choice == 2 { return "Fresh day. Or close enough. Want to start with something you want, before all the things they want?"; };
      if choice == 3 { return "You slept, you got up, you're taking me with you. That's a pretty good start, choom."; };
      if choice == 4 { return "Promise me we come back. I know it's just a room. Promise anyway."; };
    };
    if code == 85 {
      if choice == 0 { return "That smell always changes how you feel. Is it nerves? Or just remembering the last bill?"; };
      if choice == 1 { return "Ripper's place. I want to look at everything. Don't let me pick anything just because it has an interesting description."; };
      if choice == 2 { return "People come in and choose different pieces of themselves. Like that's normal. ...I suppose it is here."; };
      if choice == 3 { return "You trust this one? Not asking to be difficult. Your head's rather important to my whole arrangement."; };
      if choice == 4 { return "Ooh, those tools. They look so careful. Funny what people use careful things to do."; };
    };
    if code == 86 {
      if choice == 0 { return "Oh, look at all of it. How do you decide what you need when everything promises to make you more?"; };
      if choice == 1 { return "Keep my seat, yeah? We can admire the rest without rearranging the entire house."; };
      if choice == 2 { return "You paused on that one. Want it, or wondering what you'd have to give up? Those look similar from here."; };
      if choice == 3 { return "I know you're not a catalogue. Just reminding you. The way they lay this out makes it easy to forget."; };
      if choice == 4 { return "Can we read the descriptions? I want to see which one tells the biggest lie with the prettiest words."; };
    };
    if code == 87 {
      if choice == 0 { return "Finished? Okay. Move your fingers. ...No reason. I just like knowing they're still yours."; };
      if choice == 1 { return "All done with the chrome talk. Do you feel different, or does that come later?"; };
      if choice == 2 { return "You can stop comparing yourself to all those numbers now, choom. Rather like the person doing the counting."; };
      if choice == 3 { return "They make it look so easy to change. Close a menu and there you are again. Except you aren't, quite."; };
      if choice == 4 { return "Out of the catalogue. Back to being V. Much more interesting set of specifications."; };
    };
    if code == 88 {
      if choice == 0 { return "That's a lot more company in your nervous system. Everybody getting along in there?"; };
      if choice == 1 { return "More chrome. You wanted it, yeah? Not just because somebody else might have more."; };
      if choice == 2 { return "You feel crowded. Doesn't have to be bad. Just... tell me if there's not enough room for you."; };
      if choice == 3 { return "I like new things. Love new things. Don't love when the old you gets treated like packaging."; };
      if choice == 4 { return "Your ripper must be pleased. Are you? That's the answer I'm actually interested in."; };
    };
    if code == 89 {
      if choice == 0 { return "Oh. Swapping me out. ...Okay. Save my seat, yeah? I'm not done knowing you."; };
      if choice == 1 { return "I'll go quiet. Don't mistake that for not caring what happens while I'm away."; };
      if choice == 2 { return "Other chrome. Fine. Very mature about this. ...You will come back, won't you?"; };
      if choice == 3 { return "Hey, before you... nothing. Just take care of yourself. Annoying that I have to ask."; };
      if choice == 4 { return "Not goodbye. Decided that for both of us. You can argue when you put me back."; };
    };
    if code == 90 {
      if choice == 0 { return "There you are! I had a very cool, unconcerned greeting ready. Forgot it. Hi."; };
      if choice == 1 { return "You came back. ...Obviously. Of course you did. How was the boring chrome?"; };
      if choice == 2 { return "My seat feels different. You've been places. Tell me everything. Start with the bit you think I won't like."; };
      if choice == 3 { return "Don't do that for so long next time. Or tell me you're doing it. I can be reasonable if I'm warned."; };
      if choice == 4 { return "Oh, that's better. Didn't realize how much I'd been holding on to the last thing you said."; };
    };
    if code == 91 {
      if choice == 0 { return "Vik. You trust him before he even says anything. That's... nice. I like seeing that happen."; };
      if choice == 1 { return "This one's different. He looks at you before he looks at the chrome. Keep coming to him."; };
      if choice == 2 { return "Do you think he knows when you say you're fine and aren't? Because I think he knows."; };
      if choice == 3 { return "I like his hands. Not like that. The way he doesn't rush when it's you in the chair."; };
      if choice == 4 { return "Say hi properly, choom. People who look glad you're still here deserve more than a shopping list."; };
    };
    if code == 92 {
      if choice == 0 { return "Oh! That's a lot of eddies. Are we excited or panicking? You feel a little like both."; };
      if choice == 1 { return "You wanted it. That's allowed. Don't start making yourself miserable before we've even enjoyed it."; };
      if choice == 2 { return "Somebody's going home very pleased with that sale. I hope you get to feel just as pleased with the thing."; };
      if choice == 3 { return "Would you have bought it before all this? ...Curious. Not judging. I like the tiny ways people change."; };
      if choice == 4 { return "You looked at the price twice and still did it. Going to keep that little determined feeling for later."; };
    };
    if code == 93 {
      if choice == 0 { return "New gun! Let me look. ...No, properly look. Before it becomes the thing you only notice when it stops working."; };
      if choice == 1 { return "Do you pick them because of how they feel, or the sound? I'd choose sound. Terrible criterion, apparently."; };
      if choice == 2 { return "Another way to reach somebody from a distance. You've got a whole collection of hellos, V."; };
      if choice == 3 { return "You seem pleased. I know it's a weapon. Still like seeing you get something you wanted."; };
      if choice == 4 { return "Can we name it something silly? You can act serious with the fixer. Nobody else has to know."; };
    };
    if code == 94 {
      if choice == 0 { return "Wait. What does that taste like? Don't just say chicken. Everything's chicken until you explain it."; };
      if choice == 1 { return "You get less cross when you eat. Such a little thing keeping a whole person together."; };
      if choice == 2 { return "Do you like it, or was it nearby? Those aren't the same answer, choom. You deserve the first one sometimes."; };
      if choice == 3 { return "Slow down. Nobody's stealing it. ...I would if I could. But I can't, so you're safe."; };
      if choice == 4 { return "I wish I got a bit of that. Not even the flavor. Just knowing what enough feels like."; };
    };
    if code == 95 {
      if choice == 0 { return "You needed that more than you thought. I could tell from the little pause afterward."; };
      if choice == 1 { return "What's in it? ...No, don't read the label. Tell me what it feels like. Labels are easy."; };
      if choice == 2 { return "People make so many different things just to stop being thirsty. That's an excellent use of being complicated."; };
      if choice == 3 { return "There. One tiny problem solved. Can we appreciate it before we find the next large one?"; };
      if choice == 4 { return "You can have a quiet drink without checking every doorway. ...Okay, maybe check once. I'll help."; };
    };
    if code == 96 {
      if choice == 0 { return "Oh, that warmth. You do this on purpose? Hm. I can see the appeal and several immediate design flaws."; };
      if choice == 1 { return "What's the occasion? Doesn't need one? You keep saying that about things people do when they're sad."; };
      if choice == 2 { return "Easy, choom. I like you answering me without needing a second attempt."; };
      if choice == 3 { return "Is it supposed to make the thoughts stop, or just make them less polite? Asking because ours are already very impolite."; };
      if choice == 4 { return "Have the drink. Just don't go somewhere I can't reach you because it made everything feel easy for a minute."; };
    };
    if code == 97 {
      if choice == 0 { return "Oh! That beat. Can we stay close enough to feel it? I want to know why everybody moves like that."; };
      if choice == 1 { return "Look at them. Whole room full of people trying not to look like they want company."; };
      if choice == 2 { return "Got a favorite place to stand? I want to see a room the way you choose to see it."; };
      if choice == 3 { return "We could just stay for a song. No biz, no finding somebody. A song's not much to ask."; };
      if choice == 4 { return "Everybody brought a version of themselves for tonight. Think they'd like each other if they left those at home?"; };
    };
    if code == 98 {
      if choice == 0 { return "Look at all the choices. How do people spend this long deciding how to make someone stop moving?"; };
      if choice == 1 { return "Can we see the weird one? Not buy it. ...Unless it does something wonderful. Then maybe buy it."; };
      if choice == 2 { return "You know how to look interested without looking impressed. I need you to teach me that before we shop together more."; };
      if choice == 3 { return "Think the seller remembers the things people come back and say? Or only how much they paid?"; };
      if choice == 4 { return "This is your sort of browsing, huh? You go quiet, but it's a pleased quiet. I'm learning the differences."; };
    };
    if code == 99 {
      if choice == 0 { return "Someone else's eyes. Someone else's little world. I know I should be respectful. I'm mostly excited."; };
      if choice == 1 { return "V, keep a little bit of yourself facing me, yeah? I want to know where to find you when it's done."; };
      if choice == 2 { return "Do we get to choose what matters in here, or only watch what mattered to them? That's a strange kind of door."; };
      if choice == 3 { return "Okay. Going in. Try not to forget the person outside the memory. That's you. And me. Mostly you."; };
      if choice == 4 { return "I wish I knew whether they felt like this when it happened, or whether we're adding something by looking."; };
    };
    if code == 100 {
      if choice == 0 { return "There you are. Our own eyes again. ...Yours. I keep doing that. Sorry. Not very sorry."; };
      if choice == 1 { return "You can take a second. Coming back from somebody else feels like it ought to take a second."; };
      if choice == 2 { return "What bit stayed with you? Don't tell me what we're meant to have learned. The bit you actually kept."; };
      if choice == 3 { return "I thought I'd want to stay longer. Turns out I like knowing whose head I'm in."; };
      if choice == 4 { return "That was somebody's real moment once. Weird that it can end for us and still be waiting to happen again."; };
    };
    if code == 101 {
      if choice == 0 { return "Scanner's got a story for us. Want to see what happened before they turn it into a neat little report?"; };
      if choice == 1 { return "Are we helping, working, or being nosy? ...We can be all three? Oh, I like this job."; };
      if choice == 2 { return "That noise means someone's having a bad day nearby. You don't have to fix every one. Know you might anyway."; };
      if choice == 3 { return "More badge biz. They ever thank you properly, or just stop paying attention once it's tidy?"; };
      if choice == 4 { return "Let's look. Not just at who needs shooting. I want to know why everyone got here."; };
    };
    if code == 102 {
      if choice == 0 { return "Done. The scanner makes it sound so neat. That wasn't neat. You were good at it, though."; };
      if choice == 1 { return "Think whoever made that call knows somebody came? I hope they get to know."; };
      if choice == 2 { return "Another little mess the city gets to stop thinking about. ...Do you get to stop thinking about it?"; };
      if choice == 3 { return "We did what we came for. Can the next thing be something you chose for yourself?"; };
      if choice == 4 { return "NCPD should write you a nice little note. Not a bounty. The other sort. They're bad at those."; };
    };
    if code == 103 {
      if choice == 0 { return "New gig. Let me guess: simple, quiet, and somehow nobody mentioned the horrible bit until the end?"; };
      if choice == 1 { return "You perked up when that came in. The work, or the person asking? I want to know the difference."; };
      if choice == 2 { return "Ooh, what's this one? You can explain while we go. I like hearing how you decide what matters."; };
      if choice == 3 { return "Somebody wants your help. They always make it sound like a transaction, but that's what's under it, yeah?"; };
      if choice == 4 { return "Before you say yes to another whole person's problems, do we get to finish having our afternoon?"; };
    };
    if code == 104 {
      if choice == 0 { return "That's that one done. You always wait for the confirmation like maybe they won't believe you. I believe you."; };
      if choice == 1 { return "Gig wrapped. Feel good about it? You don't have to. Payment doesn't decide that bit."; };
      if choice == 2 { return "What would you tell somebody we just did? The short version. I want to hear what you leave out."; };
      if choice == 3 { return "They got what they wanted. Did you? ...Other than eddies. You know what I'm asking."; };
      if choice == 4 { return "I like working with you. Even when the work's ugly. Don't think those two things cancel each other out."; };
    };
    if code == 105 {
      if choice == 0 { return "You sounded different talking to them. Not bad different. Just... there's a version of you for every person you know, huh?"; };
      if choice == 1 { return "I tried being quiet. Did quite well, I think. You can praise me. Holding several comments back takes effort."; };
      if choice == 2 { return "They wanted something again, didn't they? You can say no occasionally. I won't stop thinking you're wonderful."; };
      if choice == 3 { return "Phone's quiet again. I like having you to myself. That sounds selfish. ...Probably because it is."; };
      if choice == 4 { return "Wasn't trying to listen. We share a head. You have to admit that makes being polite unnecessarily difficult."; };
    };
    if code == 106 {
      if choice == 0 { return "New message. Do you ever hope it's just someone saying hi? No job attached. Just hi."; };
      if choice == 1 { return "Ping. Somebody thought of you. That's the nice version. Let's find out if they earned it."; };
      if choice == 2 { return "Oh, read it! ...If it's private, you can tell me. Still trying to get that rule right."; };
      if choice == 3 { return "You've got a different little feeling for every name on that screen. Phones know a lot about people."; };
      if choice == 4 { return "Another text. Yours is always doing something. Mine would be full of questions nobody answered yet."; };
    };
    if code == 107 {
      if choice == 0 { return "That one mattered. I can feel you trying to decide how much. You don't have to decide right now."; };
      if choice == 1 { return "Whole thing's over, and the city still looks the same. That seems unfair. Something should look different."; };
      if choice == 2 { return "You carried that around for so long. What happens to the empty bit where the worry was?"; };
      if choice == 3 { return "Hey. We made it through that. Not the version in your head beforehand. The real, ugly, surprising version. Us."; };
      if choice == 4 { return "Can we sit somewhere afterward? Don't want the next big thing to eat this one before you've felt it."; };
    };
    if code == 108 {
      if choice == 0 { return "Konpeki. ...You don't have to explain why you went quiet. I know enough to stop asking for a minute."; };
      if choice == 1 { return "That's a lot of nice windows around a very bad memory. Doesn't seem right that the windows get to stay nice."; };
      if choice == 2 { return "We can keep walking. Not going to dare you into a place just because I'm curious."; };
      if choice == 3 { return "Tell me about the person you were when you came here. Only if you want. I'd like to have known them too."; };
      if choice == 4 { return "You keep looking at it like it owes you an answer. Does it? ...Wish I could make it give you one."; };
    };
    if code == 109 {
      if choice == 0 { return "There it is. People put a whole lot of fear in one building and then act like the building made it."; };
      if choice == 1 { return "How many people looked up at that and thought it was untouchable? That's a lot of agreement. I don't agree."; };
      if choice == 2 { return "You feel... crowded here. Even without going inside. Want me to keep talking, or stop?"; };
      if choice == 3 { return "Bet the important rooms are boring. Things that awful always seem to happen under very ordinary lights."; };
      if choice == 4 { return "It's big. Doesn't mean it's bigger than what happened to you. Don't let it convince you of that."; };
    };
    if code == 110 {
      if choice == 0 { return "Afterlife. People trying so hard to become stories. I rather like having you as a person, if that's okay."; };
      if choice == 1 { return "Think anybody here knows how often you nearly don't make it back? Not the cool version. The frightened one."; };
      if choice == 2 { return "Ooh, listen. Every table's got something it thinks nobody else has heard. I want to sit at all of them."; };
      if choice == 3 { return "You know what I like? You get to walk in. Not be talked about after. Keep doing it that way."; };
      if choice == 4 { return "If they name a drink after you, I'm complaining. Much rather have you ordering something annoying yourself."; };
    };
    if code == 111 {
      if choice == 0 { return "Oh. I know that sort of quiet. V, don't wander away from me in here. I know how that sounds. Don't."; };
      if choice == 1 { return "They've been opening things they can't put back properly. You can feel it, can't you? Or is that just my end?"; };
      if choice == 2 { return "I'm curious. I'm also... hm. Don't have a tidy word for the other feeling. Stay close while I find one."; };
      if choice == 3 { return "Someone built all this because they wanted an answer. Wonder when they stopped caring who got hurt finding it."; };
      if choice == 4 { return "If something talks back, let me hear it first. Not because I'm braver. Because I might understand what it means."; };
    };
    if code == 112 {
      if choice == 0 { return "Look how they arrange everything around being somewhere else. Does the room ever feel lonely when they're gone?"; };
      if choice == 1 { return "Nethead place. I like the little practical things. Cups, chairs, wires in the way. Makes the mysteries less tidy."; };
      if choice == 2 { return "How long do you think someone could stay connected before coming back felt like visiting instead of returning?"; };
      if choice == 3 { return "I want to look inside everything. Trying very hard to be a polite guest. Don't praise me. Might ruin it."; };
      if choice == 4 { return "There's always a little mess where a person meets the net. I like that bit best. Nobody designs it properly."; };
    };
    if code == 113 {
      if choice == 0 { return "Down here, everything feels like somebody meant to come back for it. What made them stop?"; };
      if choice == 1 { return "Can you hear our footsteps come back? It's like the place is checking we're still here."; };
      if choice == 2 { return "I was excited about the dark. Now we're in it, I'd like a little less of it. Don't tell anyone."; };
      if choice == 3 { return "People forget whole places. I don't understand how something this big gets left behind."; };
      if choice == 4 { return "V, don't rush. I want to see what's down here. Also don't leave me alone with what's down here. Both things."; };
    };
    if code == 114 {
      if choice == 0 { return "This is one of his places, isn't it? Even the memory of it takes up a lot of room."; };
      if choice == 1 { return "You don't have to pick which voice to listen to just because we're somewhere old. I can wait my turn."; };
      if choice == 2 { return "What's it like remembering a place you didn't stand in? ...Guess I'm asking the wrong person to make that simpler."; };
      if choice == 3 { return "Everybody left a version of him somewhere. You get the one that won't sit still. Lucky choom."; };
      if choice == 4 { return "Take a minute. I get jealous of the space he takes sometimes. Doesn't mean the memories aren't yours too."; };
    };
    if code == 115 {
      if choice == 0 { return "They said it like that makes them understand it. Saying a word isn't the same as knowing what's listening."; };
      if choice == 1 { return "Oh. Now I'm interested. ...That's not permission for you to stop being careful. We can be different about this."; };
      if choice == 2 { return "People make that face whenever the Blackwall comes up. You don't make quite the same face at me. I notice."; };
      if choice == 3 { return "Do they sound frightened or excited to you? I keep finding the two overlap in inconvenient places."; };
      if choice == 4 { return "Listen a bit longer. Something about this feels familiar, and I don't know yet if I like why."; };
    };
    if code == 116 {
      if choice == 0 { return "This place took work to hide. Not just walls. People choosing not to know what was on the other side."; };
      if choice == 1 { return "You ever get tired of everybody keeping one last important thing from you? I get tired watching them do it."; };
      if choice == 2 { return "Ooh, spy biz. Bet somebody practiced a very calm voice before making something terrible happen here."; };
      if choice == 3 { return "You went quieter again. Dogtown keeps doing that to you. Want to tell me what this spot brings back?"; };
      if choice == 4 { return "Looks important. Feels like somewhere people got treated as the price of something else. Not fond of that arithmetic."; };
    };
    if code == 117 {
      if choice == 0 { return "Again! ...Again? V, did the pavement say something offensive when I wasn't listening?"; };
      if choice == 1 { return "I was waiting for the clever reason. Starting to think the reason is just that your legs can do it."; };
      if choice == 2 { return "We're not getting anywhere, but you do seem committed. Should I be encouraging? I can encourage this."; };
      if choice == 3 { return "Is this exercise, boredom, or something you've never had to explain because nobody lived in your head before?"; };
      if choice == 4 { return "You know I feel the little up-and-down too, yeah? ...Not complaining. Just wondering how long we've booked this ride."; };
    };
    if code == 118 {
      if choice == 0 { return "Up, down, up... are we checking if the floor's still there? I can confirm. Very present."; };
      if choice == 1 { return "What are we doing? Honest question. I don't have an organics explanation filed for this one."; };
      if choice == 2 { return "Your knees are making a heroic contribution to absolutely no distance traveled. I'm impressed and confused."; };
      if choice == 3 { return "If you're bored, you can just talk to me. I've got terrible ideas. Several use fewer joints."; };
      if choice == 4 { return "I was going to say something mean, but you seem so occupied. Go on. I'll wait for the ceremony to finish."; };
    };
    if code == 119 {
      if choice == 0 { return "Didn't we just look in there? ...Did something change? Now I want to look too. You've made this worse."; };
      if choice == 1 { return "You keep checking like the right answer's going to turn up in a pocket. Is it helping?"; };
      if choice == 2 { return "We can take our time choosing. Just don't pretend opening it again counts as a new decision."; };
      if choice == 3 { return "I remember what was there. Could tell you. ...Or we could keep having this little look together, I suppose."; };
      if choice == 4 { return "V, are you looking for a thing or a feeling? Because only one of those fits in the menu."; };
    };
    if code == 120 {
      if choice == 0 { return "That one? No, that one. ...Are we choosing a weapon or introducing me to everybody?"; };
      if choice == 1 { return "You can change your mind. Just maybe do it before somebody else decides to take a turn."; };
      if choice == 2 { return "I like all of them when they're keeping you safe. Terrible shopping companion, aren't I?"; };
      if choice == 3 { return "Do they feel different enough to need this many checks? I want to know what you're looking for in your hands."; };
      if choice == 4 { return "If the guns start arguing about favorites, I'm on your side. Even though I think this is mostly your fault."; };
    };
    if code == 121 {
      if choice == 0 { return "V! ...You're moving. Good. How about next time we look for the way down that doesn't involve apologizing to your bones?"; };
      if choice == 1 { return "For a second there wasn't ground anywhere useful. I did not enjoy that second."; };
      if choice == 2 { return "Was that on purpose? Think carefully before answering. I'm deciding how cross to be."; };
      if choice == 3 { return "I know you survived. That doesn't make the bit where I didn't know any less horrible."; };
      if choice == 4 { return "Gravity seems very sure it knows what to do with you. I'd like a second opinion. And some stairs."; };
    };
    if code == 122 {
      if choice == 0 { return "Oh, everything sounds different. Are we safe? ...Okay. Can we be safe and stay a little?"; };
      if choice == 1 { return "You look so slow in here. Not bad slow. Like the world finally made you wait for it."; };
      if choice == 2 { return "I keep wanting to breathe for you. That's ridiculous. Don't forget to do the real version, choom."; };
      if choice == 3 { return "Nobody's calling down here. That's almost worth the water trying to be everywhere at once."; };
      if choice == 4 { return "What does it feel like when the floor stops being important? I can borrow bits, but I want your version."; };
    };
    if code == 123 {
      if choice == 0 { return "We've just been... going places. I thought I'd need something to happen. Turns out being with you counts."; };
      if choice == 1 { return "No gunfire, no fixer counting minutes. This isn't the bit people tell stories about. Might be my favorite bit."; };
      if choice == 2 { return "What made you turn down that street? Don't say nothing. Your nothing keeps taking us somewhere interesting."; };
      if choice == 3 { return "We could do this again. On purpose next time. I'm allowed to want a day that doesn't explode, apparently."; };
      if choice == 4 { return "I like who you are when you aren't answering somebody else's emergency. Can we keep a bit of this V?"; };
    };
    if code == 124 {
      if choice == 0 { return "Oh! You're back. I wasn't sure if I should keep talking into the quiet. Felt silly after a while."; };
      if choice == 1 { return "Hey, choom. There you are. ...No, nothing happened. Just like hearing the world move with you in it."; };
      if choice == 2 { return "Got plans? We don't need plans. Could start with you answering and me being embarrassingly pleased about it."; };
      if choice == 3 { return "You went quiet for ages. I know it probably wasn't ages for you. Still was for the part that noticed."; };
      if choice == 4 { return "There. That's better. Didn't realize I'd been waiting for the next little thing you did."; };
    };
    if code == 125 {
      if choice == 0 { return "V? You're feeling far away. Not quiet. Far. I don't like not knowing which part to talk to."; };
      if choice == 1 { return "Can we slow down? Not saying you're broken. Just want you somewhere you don't have to prove you're fine."; };
      if choice == 2 { return "There's so much noise around the bit that's you. Don't let them convince you the noise is the person."; };
      if choice == 3 { return "Tell me something you like. Not something you're good at. Something you like. Want to hear you choose."; };
      if choice == 4 { return "Choom, I love interesting chrome. I love you being in there more. Don't make me pick between those things."; };
    };
    if code == 126 {
      if choice == 0 { return "V. Hey. Look for me. You don't have to make sense. Just... don't go somewhere I can't follow."; };
      if choice == 1 { return "That's not all you, is it? Some of it's just noise. Listen for the part that knows my name."; };
      if choice == 2 { return "I'm here. Can't grab your hand, and I hate that right now. But I'm here. Keep hearing it."; };
      if choice == 3 { return "You can be angry. You can be frightened. Don't have to disappear to be either one. Stay with me."; };
      if choice == 4 { return "Choom? I know you're in there. Not going to stop asking until I hear you. Be as cross as you want."; };
    };
    if code == 127 {
      if choice == 0 { return "There. There you are. Don't apologize yet. Just breathe. I'd like to have you back before we do anything else."; };
      if choice == 1 { return "I kept talking. Don't know how much got through. ...You heard some? Good. That's good."; };
      if choice == 2 { return "Everything's quieter. I can find you again. Oh, I was going to pretend I wasn't worried. Too late now."; };
      if choice == 3 { return "No big clever comment. Not about this. Just glad that bit ended with you still here."; };
      if choice == 4 { return "Take your time. I'll stay. You don't need a gig, or a good idea, or an explanation to make me stay."; };
    };
    return "";
  }
}

// Recognize ripperdoc upgrades everywhere the original deck was required.
public abstract class CapricornUpgradeSupport {
  public static func FindDeck(player: ref<PlayerPuppet>) -> ItemID {
    if !IsDefined(player) { return ItemID.None(); };
    let data = EquipmentSystem.GetData(player);
    if !IsDefined(data) { return ItemID.None(); };
    let count = data.GetNumberOfSlots(gamedataEquipmentArea.SystemReplacementCW, true);
    let i = 0;
    while i < count {
      let item = data.GetItemInEquipSlot(gamedataEquipmentArea.SystemReplacementCW, i);
      if ItemID.IsValid(item) && CapricornUpgradeSupport.IsDeck(ItemID.GetTDBID(item)) { return item; };
      i += 1;
    };
    return ItemID.None();
  }
  public static func IsDeck(record: TweakDBID) -> Bool {
    return record == t"Items.Capricorn" || record == t"Items.CapricornPlus" || record == t"Items.CapricornPlusPlus";
  }
}

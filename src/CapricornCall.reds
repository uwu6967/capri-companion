@if(ModuleExists("Edgerunning.System"))
import Edgerunning.System.EdgerunningSystem

// Project Capricorn 0.9.1 — Call Capri. Settings/input/menu are independent of
// the standard quickhack instance and of the confirmed Self-ICE counter path.
public class ProjectCapricornCallSettings extends ScriptableSystem {
  @runtimeProperty("ModSettings.mod", "ProjectCapricorn-ModName")
  @runtimeProperty("ModSettings.category", "ProjectCapricorn-CallCategory")
  @runtimeProperty("ModSettings.displayName", "ProjectCapricorn-CallEnabled")
  public let callEnabled: Bool = true;

  @runtimeProperty("ModSettings.mod", "ProjectCapricorn-ModName")
  @runtimeProperty("ModSettings.category", "ProjectCapricorn-CallCategory")
  @runtimeProperty("ModSettings.displayName", "ProjectCapricorn-CallKey")
  @runtimeProperty("ModSettings.description", "ProjectCapricorn-CallKeyDesc")
  public let ProjectCapricornCallKey: EInputKey = EInputKey.IK_F10;

  @runtimeProperty("ModSettings.mod", "ProjectCapricorn-ModName")
  @runtimeProperty("ModSettings.category", "ProjectCapricorn-CallCategory")
  @runtimeProperty("ModSettings.displayName", "ProjectCapricorn-CallHint")
  public let showHint: Bool = true;

  public persistent let eliminateCooldown: Float = 0.0;
  public persistent let healCooldown: Float = 0.0;
  public let player: wref<PlayerPuppet>;
  public let listener: ref<ProjectCapricornCallInput>;
  public let hud: wref<dialogWidgetGameController>;
  public let menuOpen: Bool;
  public let selected: Int32;
  public let hintShown: Bool;
  public let teleportPending: Bool;
  public let teleportDeadline: Float;
  public let ripperLoading: Bool;
  public let ripperPhaseEpoch: Int32;
  public let ripperPollScheduled: Bool;
  public let ripperCoverSerial: Int32;
  public let ripperCompletedSerial: Int32;
  public let ripperCleanupCount: Int32;
  public let ripperStaleCallbacks: Int32;
  public let ripperStandingSamples: Int32;
  public let ripperLastDistance: Float;
  public let ripperLastRoute: String;
  public let ripperLastResult: String;
  public let ripperLastFinishedPhase: Int32;
  public let ripperLastVisualCheck: String;
  public let ripperFrozen: Bool;
  public let ripperLoadPhase: Int32;
  public let ripperLoadPolls: Int32;
  public let ripperLoadAnchor: Vector4;
  public let ripperLoadOrigin: Vector4;
  public let ripperLoadLanding: Vector4;
  public let ripperLoadYaw: Float;
  public let ripperLoadNPCID: EntityID;
  public let ripperLoadingCanvas: ref<inkCanvas>;
  public let ripperLoadingText: ref<inkText>;
  public let lastRipperAttemptAt: Float;
  public let nearestRipper: wref<ScriptedPuppet>;
  public let liveRipperCount: Int32;
  public let teleportSerial: Int32;
  public let teleportFX: ref<FxInstance>;
  public let lastState: String;
  public let lastAreaTargetCount: Int32;
  public let lastVehicleTargets: Int32;
  public let lastVehicleDispatched: Int32;
  public let lastVehicleSkipped: Int32;
  public let lastVehicleProtected: Int32;
  public let lastCleanseRequests: Int32;
  public let lastHumanityRestored: Int32;
  public let lastHumanityState: String;
  public let areaBatchSerial: Int32;
  public let areaBatchActive: Bool;
  public let areaBatchPending: Int32;
  public let areaBatchDispatched: Int32;
  public let areaBatchSkipped: Int32;
  public let areaBatchState: String;
  public let lastReplyID: Uint64;
  public let lastChoices: array<Int32>;
  public let lastRenderSecond: Int32;
  public let lastRenderedSelection: Int32;
  public persistent let ripperArrivals: array<ProjectCapricornRipperArrival>;
  public let ripperDestinationName: String;
  public let ripperDestinationSource: String;
  public let lastMoveAt: Float;
  public let capricornScannerPrimer: ref<inkImage>;
  public let capricornUploadPrimer: ref<inkImage>;
  public let capricornFillPrimer: ref<inkImage>;
  public let capricornScannerAtlasToken: ref<ResourceToken>;

  public func PrimeIconImages() -> Void {
    if IsDefined(this.capricornScannerPrimer) { return; };
    let layer = GameInstance.GetInkSystem().GetLayer(n"inkHUDLayer");
    if !IsDefined(layer) || !IsDefined(layer.GetVirtualWindow()) { return; };
    this.capricornScannerPrimer = this.CreateIconPrimer(layer.GetVirtualWindow(), r"capricorn\\icons\\capri.inkatlas", n"CapriScanner");
    this.capricornUploadPrimer = this.CreateIconPrimer(layer.GetVirtualWindow(), r"capricorn\\icons\\capri_upload.inkatlas", n"CapriUpload");
    this.capricornFillPrimer = this.CreateIconPrimer(layer.GetVirtualWindow(), r"capricorn\\icons\\capri_upload.inkatlas", n"CapriUploadFill");
  }
  private func CreateIconPrimer(parent: ref<inkCompoundWidget>, atlas: ResRef, part: CName) -> ref<inkImage> {
    let image = new inkImage();
    image.SetName(n"ProjectCapricornIconPrimer");
    image.SetSize(1.0, 1.0);
    image.SetFitToContent(false);
    image.SetInteractive(false);
    image.SetAnchor(inkEAnchor.BottomRight);
    image.SetAnchorPoint(1.0, 1.0);
    image.SetMargin(0.0, 0.0, 2.0, 2.0);
    image.SetOpacity(0.01);
    image.SetAtlasResource(atlas);
    image.SetTexturePart(part);
    image.Reparent(parent);
    return image;
  }
  private func RemoveIconPrimer(image: ref<inkImage>) -> Void {
    if !IsDefined(image) { return; };
    let parent = image.GetParentWidget() as inkCompoundWidget;
    if IsDefined(parent) { parent.RemoveChild(image); };
  }

  public let capricornScannerTextureToken: ref<ResourceToken>;
  public let capricornUploadAtlasToken: ref<ResourceToken>;
  public let capricornUploadTextureToken: ref<ResourceToken>;

  public func WarmIconResources() -> Void {
    let depot = GameInstance.GetResourceDepot();
    if !IsDefined(depot) { return; };
    if !IsDefined(this.capricornScannerAtlasToken) { this.capricornScannerAtlasToken = depot.LoadResource(r"capricorn\\icons\\capri.inkatlas"); };
    if !IsDefined(this.capricornScannerTextureToken) { this.capricornScannerTextureToken = depot.LoadResource(r"capricorn\\icons\\capri.xbm"); };
    if !IsDefined(this.capricornUploadAtlasToken) { this.capricornUploadAtlasToken = depot.LoadResource(r"capricorn\\icons\\capri_upload.inkatlas"); };
    if !IsDefined(this.capricornUploadTextureToken) { this.capricornUploadTextureToken = depot.LoadResource(r"capricorn\\icons\\capri_upload.xbm"); };
  }


  public static func Get() -> ref<ProjectCapricornCallSettings> {
    return GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"ProjectCapricornCallSettings") as ProjectCapricornCallSettings;
  }
  private func OnAttach() -> Void { ModSettings.RegisterListenerToClass(this); this.WarmIconResources(); }
  private func OnDetach() -> Void {
    this.DetachPlayer();
    ModSettings.UnregisterListenerToClass(this);
  }
  public func DetachPlayer() -> Void {
    this.RemoveIconPrimer(this.capricornScannerPrimer);
    this.RemoveIconPrimer(this.capricornUploadPrimer);
    this.RemoveIconPrimer(this.capricornFillPrimer);
    this.capricornScannerPrimer = null;
    this.capricornUploadPrimer = null;
    this.capricornFillPrimer = null;
    this.areaBatchSerial += 1;
    this.areaBatchActive = false;
    this.areaBatchPending = 0;
    this.Close();
    this.SetHint(false);
    if IsDefined(this.player) && IsDefined(this.listener) { this.player.UnregisterInputListener(this.listener); };
    this.ResetTeleport();
    this.listener = null;
    this.player = null;
  }
  public func EnsurePlayer(player: ref<PlayerPuppet>) -> Void {
    this.WarmIconResources();
    if IsDefined(player.capricornCallHUD) { this.hud = player.capricornCallHUD; };
    if this.player == player && IsDefined(this.listener) { this.PrimeIconImages(); return; };
    this.DetachPlayer();
    this.player = player;
    this.PrimeIconImages();
    this.listener = new ProjectCapricornCallInput();
    this.listener.settings = this;
    player.RegisterInputListener(this.listener, n"ProjectCapricornCall");
    player.RegisterInputListener(this.listener, n"ProjectCapricornMenuUp");
    player.RegisterInputListener(this.listener, n"ProjectCapricornMenuDown");
    player.RegisterInputListener(this.listener, n"ProjectCapricornMenuConfirm");
    player.RegisterInputListener(this.listener, n"ProjectCapricornMenuCancel");
    player.RegisterInputListener(this.listener, n"ChoiceApply");
    player.RegisterInputListener(this.listener, n"Choice1");
    player.RegisterInputListener(this.listener, n"ChoiceScrollUp");
    player.RegisterInputListener(this.listener, n"ChoiceScrollDown");
    player.RegisterInputListener(this.listener, n"NextWeapon");
    player.RegisterInputListener(this.listener, n"PreviousWeapon");
  }
  public func CanUse() -> Bool {
    if !IsDefined(this.player) || !this.callEnabled || this.player.IsDead() || !CapricornProjectQuickhack.IsDeckEquipped(this.player) { return false; };
    let tier = PlayerPuppet.GetSceneTier(this.player);
    if tier != 1 && tier != 2 { return false; };
    let game = this.player.GetGame();
    let bbs = GameInstance.GetBlackboardSystem(game);
    if bbs.Get(GetAllBlackboardDefs().UI_System).GetBool(GetAllBlackboardDefs().UI_System.IsInMenu) { return false; };
    let phone = bbs.Get(GetAllBlackboardDefs().UI_ComDevice);
    let call = FromVariant<PhoneCallInformation>(phone.GetVariant(GetAllBlackboardDefs().UI_ComDevice.PhoneCallInformation));
    if NotEquals(call.callPhase, questPhoneCallPhase.EndCall) && NotEquals(call.callPhase, questPhoneCallPhase.Undefined) { return false; };
    if GameInstance.GetSceneSystem(game).GetScriptInterface().IsEntityInDialogue(this.player.GetEntityID()) { return false; };
    if GameInstance.GetPhotoModeSystem(game).IsPhotoModeActive() || GameInstance.GetWorkspotSystem(game).IsActorInWorkspot(this.player) { return false; };
    if this.player.IsReplacer() || this.player.GetTakeOverControlSystem().IsDeviceControlled() { return false; };
    if VehicleComponent.IsMountedToVehicle(game, this.player.GetEntityID()) { return false; };
    let bd = GameInstance.GetScriptableSystemsContainer(game).Get(n"BraindanceSystem") as BraindanceSystem;
    if IsDefined(bd) && bd.GetIsInBraindance() { return false; };
    let interactions = bbs.Get(GetAllBlackboardDefs().UIInteractions);
    let realDialogs = FromVariant<DialogChoiceHubs>(interactions.GetVariant(GetAllBlackboardDefs().UIInteractions.DialogChoiceHubs));
    if ArraySize(realDialogs.choiceHubs) > 0 { return false; };
    let choices = FromVariant<InteractionChoiceHubData>(interactions.GetVariant(GetAllBlackboardDefs().UIInteractions.InteractionChoiceHub));
    return !choices.active;
  }
  public func Tick(player: ref<PlayerPuppet>, delta: Float) -> Void {
    this.EnsurePlayer(player);
    let game = player.GetGame();
    let now = EngineTime.ToFloat(GameInstance.GetSimTime(game));
    if !this.ripperLoading && this.teleportPending && (this.teleportDeadline <= 0.0 || now > this.teleportDeadline) {
      this.ResetTeleport(); this.lastState = "Teleport state released after timeout";
    };
    let paused = GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UI_System).GetBool(GetAllBlackboardDefs().UI_System.IsInMenu);
    if !paused {
      this.eliminateCooldown = MaxF(0.0, this.eliminateCooldown - MaxF(0.0, MinF(delta, 1.0)));
      this.healCooldown = MaxF(0.0, this.healCooldown - MaxF(0.0, MinF(delta, 1.0)));
    };
    if IsDefined(this.teleportFX) { this.teleportFX.UpdateTransform(player.GetWorldTransform()); };
    let available = this.CanUse() && !this.teleportPending;
    this.SetHint(available && this.showHint && !this.menuOpen && NotEquals(this.ProjectCapricornCallKey, EInputKey.IK_None));
    if this.menuOpen {
      if !available { this.Close(); return; };
      let second = CeilF(MaxF(this.eliminateCooldown, this.healCooldown));
      if second != this.lastRenderSecond { this.Render(); };
    };
  }
  public func SetHint(show: Bool) -> Void {
    if !IsDefined(this.player) { this.hintShown = false; return; };
    if (show && this.hintShown) || (!show && !this.hintShown) { return; };
    this.hintShown = show;
    let data: InputHintData;
    data.action = n"ProjectCapricornCall";
    data.source = n"ProjectCapricorn";
    data.localizedLabel = "Call Capri";
    data.holdIndicationType = inkInputHintHoldIndicationType.Hold;
    data.enableHoldAnimation = true;
    data.sortingPriority = 128;
    let evt = new UpdateInputHintEvent();
    evt.data = data;
    evt.show = show;
    evt.targetHintContainer = n"GameplayInputHelper";
    GameInstance.GetUISystem(this.player.GetGame()).QueueEvent(evt);
  }
  public func Open() -> Void {
    if this.menuOpen { this.Close(); return; };
    if !this.CanUse() || this.teleportPending { this.lastState = "Call unavailable in current activity"; return; };
    if !IsDefined(this.hud) { this.lastState = "Dialogue HUD controller unavailable"; return; };
    this.menuOpen = true;
    this.lastRenderedSelection = -1;
    this.selected = 0;
    this.SetHint(false);
    this.SayGroup(0);
    this.Render();
    this.lastState = "Call Capri menu open";
  }
  public func Close() -> Void {
    if !this.menuOpen { return; };
    this.menuOpen = false;
    if IsDefined(this.hud) { this.hud.ProjectCapricornRestoreHUD(); };
  }
  public func Move(offset: Int32) -> Void {
    if !this.menuOpen { return; };
    let now = EngineTime.ToFloat(GameInstance.GetSimTime(this.player.GetGame()));
    if now - this.lastMoveAt < 0.08 { return; };
    this.lastMoveAt = now;
    this.selected = (this.selected + offset + 5) % 5;
    this.Render();
  }
  public func Data() -> DialogChoiceHubs {
    let result: DialogChoiceHubs;
    let hub: ListChoiceHubData;
    hub.id = 770306;
    hub.activityState = EVisualizerActivityState.Active;
    hub.title = "Capri";
    let i = 0;
    while i < 5 {
      let choice: ListChoiceData;
      choice = this.Choice(i);
      ArrayPush(hub.choices, choice);
      i += 1;
    };
    ArrayPush(result.choiceHubs, hub);
    return result;
  }
  public func Choice(index: Int32) -> ListChoiceData {
    let choice: ListChoiceData;
      switch index {
        case 0: choice.localizedName = "Eliminate everything around me."; break;
        case 1: choice.localizedName = "Let's go home."; break;
        case 2: choice.localizedName = "Bring me to the nearest Ripperdoc."; break;
        case 3: choice.localizedName = "Fix me up."; break;
        default: choice.localizedName = "Nevermind.";
      };
      ChoiceTypeWrapper.ClearType(choice.type, gameinteractionsChoiceType.Inactive);
      ChoiceTypeWrapper.ClearType(choice.type, gameinteractionsChoiceType.Blueline);
      let remaining = index == 0 ? this.eliminateCooldown : (index == 3 ? this.healCooldown : 0.0);
      if remaining > 0.0 {
        choice.localizedName += s" (ready in \(CeilF(remaining)) sec.)";
        ChoiceTypeWrapper.SetType(choice.type, gameinteractionsChoiceType.Inactive);
      } else {
        ChoiceTypeWrapper.SetType(choice.type, gameinteractionsChoiceType.Blueline);
      };
      // Native "None" means one contextual F prompt on the selected row.
      choice.inputActionName = n"None";
    return choice;
  }
  public func Render() -> Void {
    if !this.menuOpen || !IsDefined(this.hud) { return; };
    this.lastRenderSecond = CeilF(MaxF(this.eliminateCooldown, this.healCooldown));
    if this.lastRenderedSelection != this.selected {
      this.hud.ProjectCapricornShowHUD(this.Data(), this.selected);
      this.lastRenderedSelection = this.selected;
    } else { this.hud.ProjectCapricornRefreshLabels(this.Data()); };
  }
  public func SayText(text: String, id: Uint64) -> Void {
    if !IsDefined(this.player) || !CapricornDialogue.IsEnabled(this.player) { return; };
    if this.lastReplyID > 0ul {
      let hide = new CapricornHideSubtitle();
      hide.game = this.player.GetGame();
      hide.lineID = HashToCRUID(this.lastReplyID);
      hide.Call();
    };
    this.lastReplyID = id;
    this.player.capricornLastReactionTime = EngineTime.ToFloat(GameInstance.GetSimTime(this.player.GetGame()));
    this.player.CapricornShowSubtitle(id, text, 5.0);
  }
  public func SayGroup(group: Int32) -> Void {
    while ArraySize(this.lastChoices) < 6 { ArrayPush(this.lastChoices, -1); };
    let count = group == 0 ? 5 : 4;
    let choice = RandRange(0, count);
    if choice == this.lastChoices[group] { choice = (choice + 1) % count; };
    this.lastChoices[group] = choice;
    this.SayText(ProjectCapricornCallLines.Text(group, choice), 770300000000500ul + Cast<Uint64>(group * 10 + choice));
  }
  public func Select() -> Void {
    if !this.menuOpen || !this.CanUse() { this.Close(); return; };
    if this.teleportPending { return; };
    let choice = this.selected;
    if (choice == 0 && this.eliminateCooldown > 0.0) || (choice == 3 && this.healCooldown > 0.0) { return; };
    switch choice {
      case 0:
        if this.Eliminate() { this.SayGroup(1); this.Close(); };
        break;
      case 1:
        let home = new Vector4(-1391.8707, 1271.6887, 123.0824, 1.0);
        if this.StartTeleport(home, -99.2506) { this.SayGroup(2); this.Close(); };
        break;
      case 2:
        let attemptAt = EngineTime.ToFloat(GameInstance.GetSimTime(this.player.GetGame()));
        if attemptAt - this.lastRipperAttemptAt < 0.30 { return; };
        this.lastRipperAttemptAt = attemptAt;
        if this.RequestRipperTravel() { this.SayGroup(3); this.Close(); }
        else { this.SayText("No available ripperdoc clinic found, V. Try again in a moment.", 770300000000590ul); };
        break;
      case 3:
        this.lastCleanseRequests = ProjectCapricornRecovery.Cleanse(this.player);
        this.RestoreWannabeHumanity();
        GameInstance.GetStatPoolsSystem(this.player.GetGame()).RequestSettingStatPoolValue(Cast<StatsObjectID>(this.player.GetEntityID()), gamedataStatPoolType.Health, 100.0, this.player, true);
        this.healCooldown = 180.0;
        this.SayGroup(4);
        this.lastState = s"Healed to maximum health; cleanse requests=\(this.lastCleanseRequests); Humanity restored=\(this.lastHumanityRestored) (\(this.lastHumanityState)); 180-second heal cooldown";
        this.Close();
        break;
      default:
        this.SayGroup(5);
        this.Close();
        this.lastState = "Call ended";
    };
  }
  public func Eliminate() -> Bool {
    if this.areaBatchActive { this.lastState = "Area strike already running"; return false; };
    let candidates = this.player.GetNPCsAroundObject();
    let batch = new ProjectCapricornAreaBatch();
    batch.player = this.player;
    batch.settings = this;
    batch.center = this.player.GetWorldPosition();
    let i = 0;
    while i < ArraySize(candidates) {
      let target = candidates[i];
      if IsDefined(target) && target.IsAttached() && CapricornProjectQuickhack.IsValidSpreadTarget(target, this.player) && !CapricornProjectQuickhack.HostFinished(target) && Vector4.Distance(batch.center, target.GetWorldPosition()) <= 50.0 && !ArrayContains(batch.targets, target) {
        ArrayPush(batch.targets, target);
      };
      i += 1;
    };
    this.lastVehicleProtected = 0;
    let entities = this.player.GetEntitiesAroundObject(50.0);
    i = 0;
    while i < ArraySize(entities) {
      let vehicle = entities[i] as VehicleObject;
      if IsDefined(vehicle) && vehicle.IsAttached() && Vector4.Distance(batch.center, vehicle.GetWorldPosition()) <= 50.0 {
        if ProjectCapricornAreaBatch.ProtectedVehicle(vehicle) {
          this.lastVehicleProtected += 1;
        } else {
          if ProjectCapricornAreaBatch.ValidVehicle(vehicle, batch.center) && !ArrayContains(batch.vehicles, vehicle) { ArrayPush(batch.vehicles, vehicle); };
        };
      };
      i += 1;
    };
    let count = ArraySize(batch.targets);
    this.lastAreaTargetCount = count;
    this.lastVehicleTargets = ArraySize(batch.vehicles);
    this.lastVehicleDispatched = 0;
    this.lastVehicleSkipped = 0;
    if count + this.lastVehicleTargets == 0 { this.lastState = "No valid hostile targets or vehicles within 50 m"; this.SayText("Nobody to fry and no rides to wreck within fifty meters, V.", 770300000000591ul); return false; };
    this.areaBatchSerial += 1;
    batch.serial = this.areaBatchSerial;
    this.areaBatchActive = true;
    this.areaBatchPending = count + this.lastVehicleTargets;
    this.areaBatchDispatched = 0;
    this.areaBatchSkipped = 0;
    this.areaBatchState = "running: simultaneous area strike";
    this.eliminateCooldown = 180.0;
    this.lastState = s"Area strike queued for \(count) hostile targets and \(this.lastVehicleTargets) vehicles; 180-second cooldown";
    GameInstance.GetDelaySystem(this.player.GetGame()).DelayCallback(batch, 0.01);
    return true;
  }
  public func RequestRipperTravel() -> Bool {
    if this.teleportPending || !this.CanUse() { return false; };
    let game = this.player.GetGame();
    let markers: array<ref<IMappin>>;
    let world: array<ref<IMappin>>;
    GameInstance.GetMappinSystem(game).GetMappins(gamemappinsMappinTargetType.Map, markers);
    GameInstance.GetMappinSystem(game).GetMappins(gamemappinsMappinTargetType.World, world);
    let i = 0;
    while i < ArraySize(world) { ArrayPush(markers, world[i]); i += 1; };
    let best = 9999999.0;
    let found = false;
    let anchor: Vector4;
    let npcID: EntityID;
    i = 0;
    while i < ArraySize(markers) {
      let marker = markers[i];
      if IsDefined(marker) && marker.IsActive() && Equals(marker.GetVariant(), gamedataMappinVariant.ServicePointRipperdocVariant) {
        let candidate = marker.GetWorldPosition();
        let distance = ProjectCapricornRipperSafety.HorizontalDistance(this.player.GetWorldPosition(), candidate);
        if distance < best {
          best = distance; anchor = candidate; found = true;
          npcID = marker.GetEntityID(); this.ripperDestinationName = marker.GetDisplayName();
        };
      };
      i += 1;
    };
    if !found {
      let local: Vector4;
      if this.NearestRipperdoc(local) && IsDefined(this.nearestRipper) {
        anchor = this.nearestRipper.GetWorldPosition(); npcID = this.nearestRipper.GetEntityID(); found = true;
      };
    };
    if !found { this.lastState = "No available ripperdoc clinic marker or NPC"; return false; };
    // Loaded and partially/unloaded clinics now share this single transaction.
    this.ripperLoadOrigin = this.player.GetWorldPosition();
    this.ripperLoadYaw = this.player.GetWorldYaw();
    this.ripperLoadAnchor = anchor; this.ripperLoadNPCID = npcID;
    this.ripperLastDistance = ProjectCapricornRipperSafety.HorizontalDistance(this.ripperLoadOrigin, anchor);
    this.teleportSerial += 1;
    this.ripperPhaseEpoch += 1;
    this.ripperLoadPolls = 0; this.ripperLoadPhase = 0;
    this.ripperFrozen = false; this.ripperPollScheduled = false; this.ripperStandingSamples = 0;
    this.ripperLoading = true; this.teleportPending = true;
    this.teleportDeadline = EngineTime.ToFloat(GameInstance.GetSimTime(game)) + 45.0;
    this.ripperLastResult = "in progress";
    this.ripperLastRoute = "waiting for freeze/readiness";
    if !this.ShowRipperLoading() { this.FinishRipperTravel(this.teleportSerial, false, "Loading cover unavailable; stayed at origin"); return false; };
    this.lastState = "Clinic travel: waiting for movement freeze";
    this.QueueRipperLoadPoll();
    let watchdog = new ProjectCapricornRipperLoadTimeout();
    watchdog.settings = this; watchdog.serial = this.teleportSerial;
    GameInstance.GetDelaySystem(game).DelayCallback(watchdog, 45.0);
    return true;
  }

  public func RipperAtDestination() -> ref<ScriptedPuppet> {
    let game = this.player.GetGame();
    let exact = GameInstance.FindEntityByID(game, this.ripperLoadNPCID) as ScriptedPuppet;
    if IsDefined(exact) && !exact.IsDead() && Equals(exact.GetVendorType(), gamedataVendorType.RipperDoc) { return exact; };
    let market = GameInstance.GetScriptableSystemsContainer(game).Get(n"MarketSystem") as MarketSystem;
    let docs: array<ref<ScriptedPuppet>>;
    if IsDefined(market) { docs = market.ProjectCapricornAttachedRipperdocs(); };
    let near = this.player.GetNPCsAroundObject();
    let i = 0;
    while i < ArraySize(near) {
      if IsDefined(near[i]) && Equals(near[i].GetVendorType(), gamedataVendorType.RipperDoc) && !ArrayContains(docs, near[i]) { ArrayPush(docs, near[i]); };
      i += 1;
    };
    this.liveRipperCount = ArraySize(docs);
    let nearest: ref<ScriptedPuppet>;
    let best = 45.0;
    i = 0;
    while i < ArraySize(docs) {
      let doc = docs[i];
      if IsDefined(doc) && !doc.IsDead() && ScriptedPuppet.IsActive(doc) {
        let docPosition = doc.GetWorldPosition();
        let distance = ProjectCapricornRipperSafety.HorizontalDistance(docPosition, this.ripperLoadAnchor);
        if distance < best && AbsF(docPosition.Z - this.ripperLoadAnchor.Z) < 20.0 { best = distance; nearest = doc; };
      };
      i += 1;
    };
    return nearest;
  }
  public func ShowRipperLoading() -> Bool {
    if !this.ripperLoading || !this.teleportPending { return false; };
    if IsDefined(this.ripperLoadingCanvas) && this.ripperCoverSerial == this.teleportSerial { return true; };
    this.ClearRipperCover();
    let layer = GameInstance.GetInkSystem().GetLayer(n"inkGameNotificationsLayer");
    if !IsDefined(layer) || !IsDefined(layer.GetVirtualWindow()) { return false; };
    let canvas = new inkCanvas();
    canvas.SetName(n"ProjectCapricornClinicLoading");
    canvas.SetAnchor(inkEAnchor.Fill);
    canvas.SetSize(0.0, 0.0);
    canvas.SetFitToContent(false);
    canvas.SetInteractive(true);
    canvas.Reparent(layer.GetVirtualWindow());
    let background = new inkRectangle();
    background.SetAnchor(inkEAnchor.Fill);
    background.SetSize(0.0, 0.0);
    background.SetTintColor(new HDRColor(0.0, 0.0, 0.0, 1.0));
    background.Reparent(canvas);
    let text = new inkText();
    text.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    text.SetFontStyle(n"Semi-Bold");
    text.SetFontSize(42);
    text.SetTintColor(new HDRColor(0.25, 0.9, 1.0, 1.0));
    text.SetAnchor(inkEAnchor.Centered);
    text.SetAnchorPoint(new Vector2(0.5, 0.5));
    text.SetSize(1200.0, 160.0);
    text.SetHorizontalAlignment(textHorizontalAlignment.Center);
    text.SetVerticalAlignment(textVerticalAlignment.Center);
    text.SetText("PROJECT CAPRICORN\nLoading ripperdoc clinic...");
    text.Reparent(canvas);
    this.ripperCoverSerial = this.teleportSerial;
    this.ripperLoadingCanvas = canvas;
    this.ripperLoadingText = text;
    return true;
  }
  public func EndRipperLoading() -> Void {
    this.ripperLoading = false; this.ripperFrozen = false;
    this.ClearRipperCover();
  }
  public func ClearRipperCover() -> Void {
    if IsDefined(this.ripperLoadingCanvas) {
      this.ripperLoadingCanvas.SetVisible(false);
      this.ripperLoadingCanvas.SetOpacity(0.0);
      this.ripperLoadingCanvas.SetInteractive(false);
      let parent = this.ripperLoadingCanvas.GetParentWidget() as inkCompoundWidget;
      if IsDefined(parent) { parent.RemoveChild(this.ripperLoadingCanvas); };
    };
    this.ripperLoadingCanvas = null; this.ripperLoadingText = null; this.ripperCoverSerial = 0;
  }

  public func QueueRipperLoadPoll() -> Void {
    if !this.ripperLoading || !this.teleportPending || this.ripperPollScheduled || this.ripperLoadPhase == 4 { return; };
    this.ripperPollScheduled = true;
    let poll = new ProjectCapricornRipperLoadPoll();
    poll.settings = this; poll.player = this.player;
    poll.serial = this.teleportSerial; poll.epoch = this.ripperPhaseEpoch;
    GameInstance.GetDelaySystem(this.player.GetGame()).DelayCallback(poll, 0.10);
  }
  public func SetRipperPhase(phase: Int32) -> Void {
    this.ripperLoadPhase = phase; this.ripperLoadPolls = 0;
    this.ripperStandingSamples = 0;
    this.ripperPhaseEpoch += 1; this.ripperPollScheduled = false;
  }

  public func PlayRipperArrivalFX() -> Void {
    if !this.ripperLoading || !this.teleportPending { return; };
    // The floor is verified BEFORE reveal. Only the existing art duration remains.
    this.SetRipperPhase(4);
    this.ClearRipperCover();
    if IsDefined(this.teleportFX) { this.teleportFX.Kill(); this.teleportFX = null; };
    let resource: FxResource;
    ResourceAsyncRef.SetPath(resource.effect, r"ep1\\fx\\player\\blackwall\\blackwall_onscreen_high.effect");
    this.teleportFX = GameInstance.GetFxSystem(this.player.GetGame()).SpawnEffect(resource, this.player.GetWorldTransform(), true);
    if !IsDefined(this.teleportFX) { this.FinishRipperTravel(this.teleportSerial, true, "Clinic arrival complete; transition resource unavailable"); return; };
    let end = new ProjectCapricornRipperRevealEnd();
    end.settings = this; end.serial = this.teleportSerial; end.epoch = this.ripperPhaseEpoch;
    GameInstance.GetDelaySystem(this.player.GetGame()).DelayCallback(end, 0.65);
  }

  public func NativeLoadingTravel(point: Vector4) -> Void {
    if !this.ripperLoading || !this.teleportPending || !IsDefined(this.player) { return; };
    // Do not start a native fast-travel presentation without its engine lifecycle.
    // Teleportation requests destination streaming; our owned cover stays until
    // the actual NPC, collision and standing point have been verified.
    GameInstance.GetTeleportationFacility(this.player.GetGame()).Teleport(this.player, point, this.player.GetWorldOrientation().ToEulerAngles());
  }

  public func PollRipperLoading() -> Void {
    if !this.ripperLoading || !this.teleportPending || !IsDefined(this.player) { return; };
    this.ripperLoadPolls += 1;
    if this.ripperLoadPhase == 0 {
      if !this.ripperFrozen {
        if this.ripperLoadPolls >= 30 { this.FinishRipperTravel(this.teleportSerial, false, "Movement freeze unavailable; stayed at origin"); return; };
      } else {
        let doc = this.RipperAtDestination();
        let landing: Vector4;
        if IsDefined(doc) && ProjectCapricornRipperSafety.ArrivalBeside(doc, landing) {
          this.nearestRipper = doc; this.ripperLoadLanding = landing;
          this.ripperLastRoute = "clinic already ready; common completion";
          this.NativeLoadingTravel(landing); this.SetRipperPhase(2);
        } else {
          let anchor = this.ripperLoadAnchor; anchor.Z += 2.0;
          this.ripperLastRoute = "clinic requires streaming; owned cover only";
          this.NativeLoadingTravel(anchor); this.SetRipperPhase(1);
        };
      };
    } else {
      if this.ripperLoadPhase == 1 {
        let doc = this.RipperAtDestination();
        let landing: Vector4;
        if IsDefined(doc) && ProjectCapricornRipperSafety.ArrivalBeside(doc, landing) {
          this.nearestRipper = doc; this.ripperLoadLanding = landing;
          this.NativeLoadingTravel(landing); this.SetRipperPhase(2);
          this.lastState = "Clinic NPC and floor ready; verifying actual arrival";
        } else {
          if this.ripperLoadPolls >= 300 { this.ReturnFromRipperLoad("Clinic NPC/floor did not become ready"); return; };
        };
      } else {
        if this.ripperLoadPhase == 2 {
          let floor: Vector4;
          let doc = this.nearestRipper;
          let actual = this.player.GetWorldPosition();
          if IsDefined(doc) && !doc.IsDead() && Vector4.Distance(actual, doc.GetWorldPosition()) <= 2.0
            && ProjectCapricornRipperSafety.PhysicalStandingPoint(this.player.GetGame(), actual, floor) {
            this.ripperStandingSamples += 1;
            if this.ripperStandingSamples >= 2 {
              this.ripperDestinationSource = "nearest clinic; actual NPC and standing floor verified within 2 m";
              this.PlayRipperArrivalFX(); return;
            };
          } else { this.ripperStandingSamples = 0; };
          if this.ripperLoadPolls >= 50 { this.ReturnFromRipperLoad("Actual arrival failed floor/NPC verification"); return; };
        } else {
          if this.ripperLoadPhase == 3 {
            let floor: Vector4;
            let actual = this.player.GetWorldPosition();
            if ProjectCapricornRipperSafety.HorizontalDistance(actual, this.ripperLoadOrigin) < 2.0
              && ProjectCapricornRipperSafety.PhysicalStandingPoint(this.player.GetGame(), actual, floor) {
              this.ripperStandingSamples += 1;
              if this.ripperStandingSamples >= 2 { this.FinishRipperTravel(this.teleportSerial, false, "Travel cancelled; original location and floor restored"); return; };
            } else { this.ripperStandingSamples = 0; };
          };
        };
      };
    };
    if IsDefined(this.ripperLoadingText) {
      this.ripperLoadingText.SetText(this.ripperLoadPhase == 3 ? "PROJECT CAPRICORN\nReturning to starting location..." : "PROJECT CAPRICORN\nLoading ripperdoc clinic...");
    };
    this.QueueRipperLoadPoll();
  }

  public func ReturnFromRipperLoad(reason: String) -> Void {
    if !this.ripperLoading || !this.teleportPending || this.ripperLoadPhase == 3 { return; };
    if this.ripperLoadPhase == 4 { this.FinishRipperTravel(this.teleportSerial, true, "Arrival verified; reveal cleanup completed by watchdog"); return; };
    this.SetRipperPhase(3);
    this.lastState = reason + "; returning to original position";
    this.ShowRipperLoading();
    let rotation: EulerAngles; rotation.Yaw = this.ripperLoadYaw;
    GameInstance.GetTeleportationFacility(this.player.GetGame()).Teleport(this.player, this.ripperLoadOrigin, rotation);
    this.teleportDeadline = EngineTime.ToFloat(GameInstance.GetSimTime(this.player.GetGame())) + 12.0;
    this.QueueRipperLoadPoll();
    let watchdog = new ProjectCapricornRipperLoadTimeout();
    watchdog.settings = this; watchdog.serial = this.teleportSerial; watchdog.returning = true;
    GameInstance.GetDelaySystem(this.player.GetGame()).DelayCallback(watchdog, 12.0);
  }
  public func FinishRipperTravel(serial: Int32, success: Bool, reason: String) -> Void {
    if serial != this.teleportSerial || !this.teleportPending || !this.ripperLoading { this.ripperStaleCallbacks += 1; return; };
    this.ripperLastFinishedPhase = this.ripperLoadPhase;
    this.ripperLastResult = reason;
    this.ResetTeleport();
    this.lastState = reason;
  }

  public func NearestRipperdoc(out position: Vector4) -> Bool {
    this.nearestRipper = null;
    this.liveRipperCount = 0;
    let game = this.player.GetGame();
    let docs: array<ref<ScriptedPuppet>>;
    let market = GameInstance.GetScriptableSystemsContainer(game).Get(n"MarketSystem") as MarketSystem;
    if IsDefined(market) { docs = market.ProjectCapricornAttachedRipperdocs(); };
    let nearby = this.player.GetNPCsAroundObject();
    let i = 0;
    while i < ArraySize(nearby) {
      let doc = nearby[i];
      if IsDefined(doc) && Equals(doc.GetVendorType(), gamedataVendorType.RipperDoc) && !ArrayContains(docs, doc) { ArrayPush(docs, doc); };
      i += 1;
    };
    let best = 9999999.0;
    i = 0;
    while i < ArraySize(docs) {
      let doc = docs[i];
      if IsDefined(doc) && !doc.IsDead() && ScriptedPuppet.IsActive(doc) && Equals(doc.GetVendorType(), gamedataVendorType.RipperDoc) {
        this.liveRipperCount += 1;
        let distance = Vector4.Distance(this.player.GetWorldPosition(), doc.GetWorldPosition());
        if distance < best { best = distance; this.nearestRipper = doc; };
      };
      i += 1;
    };
    if !IsDefined(this.nearestRipper) {
      this.ripperDestinationSource = "no live ripperdoc NPC loaded";
      this.lastState = "No live ripperdoc NPC is available; retry closer to a clinic";
      return false;
    };
    this.ripperDestinationName = TDBID.ToStringDEBUG(this.nearestRipper.GetRecordID());
    if !ProjectCapricornRipperSafety.ArrivalBeside(this.nearestRipper, position) {
      this.ripperDestinationSource = "closest NPC has no clear 2 m standing point";
      this.lastState = "No clear floor within 2 m of closest ripperdoc; option remains available to retry";
      return false;
    };
    this.ripperDestinationSource = "closest live NPC; direct teleport within 2 m";
    this.lastState = "Resolved direct arrival within 2 m of closest ripperdoc NPC";
    return true;
  }
  public func ResetTeleport() -> Void {
    // Invalidate every movement/reveal/poll callback BEFORE releasing visuals.
    let active = this.teleportPending || this.ripperLoading;
    this.ripperCompletedSerial = this.teleportSerial;
    this.teleportSerial += 1; this.ripperPhaseEpoch += 1;
    this.teleportPending = false; this.teleportDeadline = 0.0;
    this.ripperPollScheduled = false;
    this.EndRipperLoading();
    if IsDefined(this.teleportFX) { this.teleportFX.Kill(); this.teleportFX = null; };
    if active { this.ripperCleanupCount += 1; };
    this.ripperLastVisualCheck = "owned cover removed; owned FX killed; freeze released; native fast-travel never requested; pixel rendering still requires visual verification";
  }

  public func StartTeleport(position: Vector4, yaw: Float, opt clinic: Bool, opt doc: ref<ScriptedPuppet>) -> Bool {
    if this.teleportPending || !this.CanUse() { return false; };
    this.teleportPending = true;
    this.teleportSerial += 1;
    this.teleportDeadline = EngineTime.ToFloat(GameInstance.GetSimTime(this.player.GetGame())) + 3.0;
    let resource: FxResource;
    ResourceAsyncRef.SetPath(resource.effect, r"ep1\\fx\\player\\blackwall\\blackwall_onscreen_high.effect");
    this.teleportFX = GameInstance.GetFxSystem(this.player.GetGame()).SpawnEffect(resource, this.player.GetWorldTransform(), true);
    if !IsDefined(this.teleportFX) { this.ResetTeleport(); this.lastState = "Blackwall transition effect unavailable"; return false; };
    let move = new ProjectCapricornTeleport();
    move.settings = this;
    move.player = this.player;
    move.serial = this.teleportSerial;
    move.destination = position;
    move.clinic = clinic;
    move.doc = doc;
    move.returnPoint = new Vector4(-1391.8707, 1271.6887, 123.0824, 1.0);
    let safeOrigin: Vector4;
    if ProjectCapricornRipperSafety.StandingPoint(this.player.GetGame(), this.player.GetWorldPosition(), safeOrigin) { move.returnPoint = safeOrigin; };
    move.yaw = yaw;
    GameInstance.GetDelaySystem(this.player.GetGame()).DelayCallback(move, 0.65);
    let timeout = new ProjectCapricornTeleportTimeout();
    timeout.settings = this;
    timeout.serial = this.teleportSerial;
    GameInstance.GetDelaySystem(this.player.GetGame()).DelayCallback(timeout, 3.0);
    this.lastState = "Blackwall teleport transition started";
    return true;
  }
// Optional typed integration: installing/removing Wannabe Edgerunner never
// becomes a hard dependency of Project Capricorn.
@if(ModuleExists("Edgerunning.System"))
private final func RestoreWannabeHumanity() -> Void {
  this.lastHumanityRestored = 0;
  let system = EdgerunningSystem.GetInstance(this.player.GetGame());
  if !IsDefined(system) { this.lastHumanityState = "Wannabe Edgerunner system unavailable"; return; };
  let board = this.player.GetPlayerStateMachineBlackboard();
  let before = board.GetInt(GetAllBlackboardDefs().PlayerStateMachine.HumanityDamage);
  system.RemoveHumanityDamage(30);
  let after = board.GetInt(GetAllBlackboardDefs().PlayerStateMachine.HumanityDamage);
  this.lastHumanityRestored = Max(0, before - after);
  this.lastHumanityState = "Wannabe Edgerunner detected; native 30-point recovery";
}

@if(!ModuleExists("Edgerunning.System"))
private final func RestoreWannabeHumanity() -> Void {
  this.lastHumanityRestored = 0;
  this.lastHumanityState = "Wannabe Edgerunner not installed";
}


}


public class ProjectCapricornCallInput extends IScriptable {
  public let settings: wref<ProjectCapricornCallSettings>;
  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    if !IsDefined(this.settings) { return false; };
    let name = ListenerAction.GetName(action);
    let kind = ListenerAction.GetType(action);
    if Equals(name, n"ProjectCapricornCall") && Equals(kind, gameinputActionType.BUTTON_HOLD_COMPLETE) {
      if Equals(this.settings.ProjectCapricornCallKey, EInputKey.IK_None) { return false; };
      this.settings.Open();
      ListenerActionConsumer.ConsumeSingleAction(consumer);
      return true;
    };
    if !this.settings.menuOpen || NotEquals(kind, gameinputActionType.BUTTON_PRESSED) { return false; };
    if Equals(name, n"ProjectCapricornMenuUp") || Equals(name, n"ChoiceScrollUp") || Equals(name, n"NextWeapon") {
      this.settings.Move(-1);
    } else {
      if Equals(name, n"ProjectCapricornMenuDown") || Equals(name, n"ChoiceScrollDown") || Equals(name, n"PreviousWeapon") {
        this.settings.Move(1);
      } else {
        if Equals(name, n"ProjectCapricornMenuConfirm") || Equals(name, n"ChoiceApply") || Equals(name, n"Choice1") {
          this.settings.Select();
        } else {
          if Equals(name, n"ProjectCapricornMenuCancel") { this.settings.Close(); } else { return false; };
        };
      };
    };
    ListenerActionConsumer.ConsumeSingleAction(consumer);
    return true;
  }
}

// Render in the game's own dialogue interaction hub, without injecting synthetic
// choices into quest/interaction blackboards or issuing nonexistent scene choices.
@wrapMethod(dialogWidgetGameController)
protected cb func OnInitialize() -> Bool {
  let result = wrappedMethod();
  let player = this.GetPlayerControlledObject() as PlayerPuppet;
  if IsDefined(player) { player.capricornCallHUD = this; };
  let settings = ProjectCapricornCallSettings.Get();
  if IsDefined(settings) { settings.hud = this; };
  return result;
}
@wrapMethod(dialogWidgetGameController)
protected cb func OnUninitialize() -> Bool {
  let player = this.GetPlayerControlledObject() as PlayerPuppet;
  if IsDefined(player) && player.capricornCallHUD == this { player.capricornCallHUD = null; };
  let settings = ProjectCapricornCallSettings.Get();
  if IsDefined(settings) && settings.hud == this { settings.menuOpen = false; settings.hud = null; };
  return wrappedMethod();
}
@addMethod(dialogWidgetGameController)
public final func ProjectCapricornShowHUD(data: DialogChoiceHubs, selected: Int32) -> Void {
  this.m_data = data;
  this.m_activeHubID = 770306;
  this.m_selectedIndex = selected;
  this.m_AreDialogsOpen = true;
  this.OnInteractionsChanged();
}
@addMethod(dialogWidgetGameController)
public final func ProjectCapricornRestoreHUD() -> Void {
  let bb = GameInstance.GetBlackboardSystem(GetGameInstance()).Get(GetAllBlackboardDefs().UIInteractions);
  let data = FromVariant<DialogChoiceHubs>(bb.GetVariant(GetAllBlackboardDefs().UIInteractions.DialogChoiceHubs));
  this.m_data = data;
  this.m_activeHubID = bb.GetInt(GetAllBlackboardDefs().UIInteractions.ActiveChoiceHubID);
  this.m_selectedIndex = bb.GetInt(GetAllBlackboardDefs().UIInteractions.SelectedIndex);
  this.m_AreDialogsOpen = ArraySize(data.choiceHubs) > 0;
  this.OnInteractionsChanged();
}
@wrapMethod(dialogWidgetGameController)
protected func UpdateDialogsData(const data: script_ref<DialogChoiceHubs>) -> Void {
  let settings = ProjectCapricornCallSettings.Get();
  if IsDefined(settings) && settings.menuOpen {
    if ArraySize(Deref(data).choiceHubs) > 0 {
      // A real conversation always takes priority over our optional menu.
      settings.menuOpen = false;
      settings.lastState = "Call menu closed for native dialogue";
    } else {
      this.m_AreDialogsOpen = true;
      this.m_activeHubID = 770306;
      this.m_selectedIndex = settings.selected;
      let custom = settings.Data();
      wrappedMethod(custom);
      return;
    };
  };
  wrappedMethod(data);
}
@wrapMethod(dialogWidgetGameController)
protected cb func OnDialogsSelectIndex(index: Int32) -> Bool {
  let settings = ProjectCapricornCallSettings.Get();
  if IsDefined(settings) && settings.menuOpen {
    this.m_selectedIndex = settings.selected;
    this.OnInteractionsChanged();
    return true;
  };
  return wrappedMethod(index);
}
@wrapMethod(dialogWidgetGameController)
protected cb func OnDialogsActivateHub(activeHubId: Int32) -> Bool {
  let settings = ProjectCapricornCallSettings.Get();
  if IsDefined(settings) && settings.menuOpen {
    this.m_activeHubID = 770306;
    this.OnInteractionsChanged();
    return true;
  };
  return wrappedMethod(activeHubId);
}

public class ProjectCapricornAreaStrike extends DelayCallback {
  public let player: wref<PlayerPuppet>;
  public let target: wref<NPCPuppet>;
  public func Call() -> Void {
    if !IsDefined(this.player) || !this.player.IsAttached() || this.player.IsDead() || !CapricornProjectQuickhack.IsDeckEquipped(this.player) || !IsDefined(this.target) || !this.target.IsAttached() || !CapricornProjectQuickhack.IsValidSpreadTarget(this.target, this.player) || CapricornProjectQuickhack.HostFinished(this.target) { return; };
    let effect = t"BaseStatusEffect.BaseBlackWallHackEffect";
    if this.target.IsBoss() || Equals(this.target.GetNPCRarity(), gamedataNPCRarity.MaxTac) || GameInstance.GetStatsSystem(this.target.GetGame()).GetStatValue(Cast<StatsObjectID>(this.target.GetEntityID()), gamedataStatType.IsExo) > 0.0 {
      effect = t"BaseStatusEffect.BossBlackWallHack";
    };
    // One free application per selected hostile. No recursive chain or instance.
    CapricornProjectQuickhack.ApplyFresh(this.target, this.player, effect);
  }
}
public class ProjectCapricornTeleport extends DelayCallback {
  public let settings: wref<ProjectCapricornCallSettings>;
  public let player: wref<PlayerPuppet>;
  public let serial: Int32;
  public let destination: Vector4;
  public let doc: wref<ScriptedPuppet>;
  public let yaw: Float;
  public let clinic: Bool;
  public let returnPoint: Vector4;
  public func Call() -> Void {
    if !IsDefined(this.settings) || this.settings.teleportSerial != this.serial { return; };
    if !IsDefined(this.player) { this.settings.ResetTeleport(); return; };
    let dispatched = false;
    let point = this.destination;
    if this.settings.player == this.player && this.settings.CanUse() {
      let rotation: EulerAngles;
      rotation.Yaw = this.yaw;
      let validated: Vector4;
      if !this.clinic || (IsDefined(this.doc) && !this.doc.IsDead() && ProjectCapricornRipperSafety.ArrivalBeside(this.doc, validated)) {
        if this.clinic { point = validated; };
        GameInstance.GetTeleportationFacility(this.player.GetGame()).Teleport(this.player, point, rotation);
        dispatched = true;
        this.settings.lastState = "Blackwall teleport dispatched";
      } else { this.settings.lastState = "Ripperdoc teleport cancelled: arrival lost floor validation"; };
    } else { this.settings.lastState = "Teleport cancelled: player activity changed"; };
    let cleanup = new ProjectCapricornTeleportEnd();
    cleanup.settings = this.settings;
    cleanup.serial = this.serial;
    cleanup.clinic = this.clinic && dispatched;
    cleanup.destination = dispatched ? point : this.destination;
    cleanup.returnPoint = this.returnPoint;
    GameInstance.GetDelaySystem(this.player.GetGame()).DelayCallback(cleanup, 1.0);
  }
}
public class ProjectCapricornTeleportEnd extends DelayCallback {
  public let settings: wref<ProjectCapricornCallSettings>;
  public let serial: Int32;
  public let clinic: Bool;
  public let destination: Vector4;
  public let returnPoint: Vector4;
  public func Call() -> Void {
    if !IsDefined(this.settings) || this.settings.teleportSerial != this.serial { return; };
    let player = this.settings.player;
    if this.clinic && IsDefined(player) && !player.IsDead() {
      let actual = player.GetWorldPosition();
      if actual.Z < this.destination.Z - 1.2 && ProjectCapricornRipperSafety.HorizontalDistance(actual, this.destination) < 3.0 {
        GameInstance.GetTeleportationFacility(player.GetGame()).Teleport(player, this.returnPoint, player.GetWorldOrientation().ToEulerAngles());
        this.settings.lastState = "Ripperdoc landing failed: returned to safe origin";
      };
    };
    this.settings.ResetTeleport();
  }
}

@addMethod(PlayerPuppet)
public final func CapricornCallTick(delta: Float) -> Void {
  let settings = ProjectCapricornCallSettings.Get();
  if IsDefined(settings) { settings.Tick(this, delta); };
}
@addMethod(PlayerPuppet)
public final func CapricornCallStatus() -> String {
  let settings = ProjectCapricornCallSettings.Get();
  if !IsDefined(settings) { return "Project Capricorn | Call Capri settings system unavailable"; };
  return s"Project Capricorn | callEnabled=\(settings.callEnabled) | key=\(EnumInt(settings.ProjectCapricornCallKey)) | inputReady=\(IsDefined(settings.listener)) | hudReady=\(IsDefined(settings.hud)) | canUse=\(settings.CanUse()) | menuOpen=\(settings.menuOpen) | selection=\(settings.selected) | eliminateCooldown=\(settings.eliminateCooldown) | healCooldown=\(settings.healCooldown) | areaTargets=\(settings.lastAreaTargetCount) | areaActive=\(settings.areaBatchActive) | areaPending=\(settings.areaBatchPending) | areaSent=\(settings.areaBatchDispatched) | areaSkipped=\(settings.areaBatchSkipped) | areaState=\(settings.areaBatchState) | teleportPending=\(settings.teleportPending) | ripperSource=\(settings.ripperDestinationSource) | ripperName=\(settings.ripperDestinationName) | liveRippers=\(settings.liveRipperCount) | loading=\(settings.ripperLoading) | loadPhase=\(settings.ripperLoadPhase) | freezeReady=\(settings.ripperFrozen) | loadPolls=\(settings.ripperLoadPolls) | teleportDeadline=\(settings.teleportDeadline) | state=\(settings.lastState)";
}
@addMethod(PlayerPuppet)
public final func CapricornTeleportVisualStatus() -> String {
  let s = ProjectCapricornCallSettings.Get();
  if !IsDefined(s) { return "Project Capricorn | settings unavailable"; };
  let coverVisible = false;
  let coverOpacity = 0.0;
  if IsDefined(s.ripperLoadingCanvas) {
    coverVisible = s.ripperLoadingCanvas.IsVisible();
    coverOpacity = s.ripperLoadingCanvas.GetOpacity();
  };
  return s"Project Capricorn | pending=\(s.teleportPending) | loading=\(s.ripperLoading) | frozen=\(s.ripperFrozen) | phase=\(s.ripperLoadPhase) | serial=\(s.teleportSerial) | epoch=\(s.ripperPhaseEpoch) | pollQueued=\(s.ripperPollScheduled) | coverExists=\(IsDefined(s.ripperLoadingCanvas)) | coverVisible=\(coverVisible) | coverOpacity=\(coverOpacity) | FXexists=\(IsDefined(s.teleportFX)) | completedSerial=\(s.ripperCompletedSerial) | cleanupCount=\(s.ripperCleanupCount) | staleCallbacks=\(s.ripperStaleCallbacks) | distance=\(s.ripperLastDistance) | route=\(s.ripperLastRoute) | result=\(s.ripperLastResult) | visuals=\(s.ripperLastVisualCheck)";
}
@wrapMethod(PlayerPuppet)
protected cb func OnDetach() -> Bool {
  let settings = ProjectCapricornCallSettings.Get();
  if IsDefined(settings) && settings.player == this { settings.DetachPlayer(); };
  return wrappedMethod();
}

public abstract class ProjectCapricornCallLines {
  public static func Text(group: Int32, choice: Int32) -> String {
    if group == 0 && choice == 0 { return "Hey, choom! Miss me, or we breaking something?"; };
    if group == 0 && choice == 1 { return "Yeah, V? Got a gig for me? Better be a fun one!"; };
    if group == 0 && choice == 2 { return "You rang! Tell me we're about to do something nova."; };
    if group == 0 && choice == 3 { return "Right here, choom. Aw, you sound happy to hear me!"; };
    if group == 0 && choice == 4 { return "Finally! Thought you'd ghosted the girl living in your head. Rude!"; };
    if group == 1 && choice == 0 { return "All these gonks? Aw, V. You spoil me!"; };
    if group == 1 && choice == 1 { return "Fifty meters of bad biz. My turn to clean up!"; };
    if group == 1 && choice == 2 { return "Stick close, choom. Gonna get loud!"; };
    if group == 1 && choice == 3 { return "Consider it handled, V. Not charging eddies. Choom discount!"; };
    if group == 2 && choice == 0 { return "Back to your digs! Try not to trip over reality, yeah?"; };
    if group == 2 && choice == 1 { return "Your box in the sky? Preem. Calling dibs on the comfy spot!"; };
    if group == 2 && choice == 2 { return "Home it is, choom. No traffic, no fares. You're welcome!"; };
    if group == 2 && choice == 3 { return "One shortcut, zero eddies. Mind your head, V!"; };
    if group == 3 && choice == 0 { return "Let's find a ripper. Yours always charge this much to poke at people?"; };
    if group == 3 && choice == 1 { return "Nearest ripper, coming up! No poking around my corner of your chrome, though."; };
    if group == 3 && choice == 2 { return "Off to the ripper! Keep the fun bits, yeah? I'm using those."; };
    if group == 3 && choice == 3 { return "Found a ripper, choom. Think they do a two-for-one? Kidding! Mostly."; };
    if group == 4 && choice == 0 { return "Hold still, choom. You're leaking! Kinda need you in one piece."; };
    if group == 4 && choice == 1 { return "There! Keep your blood inside this time, yeah? Preem little trick."; };
    if group == 4 && choice == 2 { return "Patching you up, V. No flatlining on my watch!"; };
    if group == 4 && choice == 3 { return "Oh, choom. What'd you do without me? Bleed on your nice chrome?"; };
    if group == 5 && choice == 0 { return "Changed your mind? Fine, choom. Still calling dibs on the next gig!"; };
    if group == 5 && choice == 1 { return "Yeah, yeah. Ping me when you've got something nova."; };
    if group == 5 && choice == 2 { return "That's it? Gonk tease. Was getting all excited!"; };
    if group == 5 && choice == 3 { return "Still here, V. Can't ghost me. We share gray matter!"; };
    return "Right here, choom. What's the play?";
  }
}

@addMethod(PlayerPuppet)
public final func CapricornCallOpen() -> Void {
  let settings = ProjectCapricornCallSettings.Get();
  if IsDefined(settings) { settings.EnsurePlayer(this); settings.Open(); };
}

@addField(PlayerPuppet)
public let capricornCallHUD: wref<dialogWidgetGameController>;

// Generic safety resolver used for every ripperdoc vendor, including DLC vendors.
public struct ProjectCapricornRipperArrival {
  public persistent let record: TweakDBID;
  public persistent let position: Vector4;
}
public abstract class ProjectCapricornRipperSafety {
  public static func HorizontalDistance(a: Vector4, b: Vector4) -> Float {
    let dx = a.X - b.X;
    let dy = a.Y - b.Y;
    return SqrtF(dx * dx + dy * dy);
  }
  public static func StandingPoint(game: GameInstance, seed: Vector4, out point: Vector4) -> Bool {
    let nav = GameInstance.GetNavigationSystem(game);
    if !nav.IsNavmeshStreamedInLocation(seed, 0.8) { return false; };
    let result = nav.FindPointInSphereOnlyHumanNavmesh(seed, 0.65, NavGenAgentSize.Human, true);
    if NotEquals(result.status, worldNavigationRequestStatus.OK) || AbsF(result.point.Z - seed.Z) > 0.45 { return false; };
    let start = result.point;
    let finish = result.point;
    start.Z += 0.25;
    finish.Z -= 0.45;
    let floor: TraceResult;
    let queries = GameInstance.GetSpatialQueriesSystem(game);
    if !queries.SyncRaycastByCollisionGroup(start, finish, n"Static", floor, true, false) { return false; };
    if floor.normal.Z < 0.70 || AbsF(floor.position.Z - result.point.Z) > 0.30 { return false; };
    point = result.point;
    point.Z = floor.position.Z + 0.10;
    point.W = 1.0;
    start = point; start.Z += 0.15;
    finish = point; finish.Z += 1.90;
    let ceiling: TraceResult;
    if queries.SyncRaycastByCollisionGroup(start, finish, n"Static", ceiling, true, false) { return false; };
    return true;
  }
  public static func ArrivalBeside(doc: ref<ScriptedPuppet>, out point: Vector4) -> Bool {
    if !IsDefined(doc) || doc.IsDead() { return false; };
    let feet = doc.GetWorldPosition();
    let game = doc.GetGame();
    let queries = GameInstance.GetSpatialQueriesSystem(game);
    let candidates: array<Vector4>;
    let lowest = feet.Z + 0.35;
    let i = 0;
    // Direct teleport: no pathfinding/navmesh requirement. Sample three rings
    // inside 2 m of the actual NPC, with physical landing checks only.
    while i < 48 {
      let angle = Cast<Float>(i % 16) * 0.3926990817;
      let radius = i < 16 ? 1.75 : (i < 32 ? 1.25 : 0.80);
      let seed = feet;
      seed.X += CosF(angle) * radius;
      seed.Y += SinF(angle) * radius;
      let standing: Vector4;
      if ProjectCapricornRipperSafety.PhysicalStandingPoint(game, seed, standing) && Vector4.Distance(feet, standing) <= 2.0 {
        // A wall between the NPC and arrival means it is another room or void.
        let from = feet; from.Z += 1.0;
        let to = standing; to.Z += 1.0;
        let wall: TraceResult;
        if !queries.SyncRaycastByCollisionGroup(from, to, n"Static", wall, true, false) {
          ArrayPush(candidates, standing);
          lowest = MinF(lowest, standing.Z);
        };
      };
      i += 1;
    };
    i = 0;
    while i < ArraySize(candidates) {
      if candidates[i].Z <= lowest + 0.20 { point = candidates[i]; return true; };
      i += 1;
    };
    return false;
  }
  public static func PhysicalStandingPoint(game: GameInstance, seed: Vector4, out point: Vector4) -> Bool {
    let start = seed; start.Z += 0.25;
    let finish = seed; finish.Z -= 1.20;
    let queries = GameInstance.GetSpatialQueriesSystem(game);
    let floor: TraceResult;
    if !queries.SyncRaycastByCollisionGroup(start, finish, n"Static", floor, true, false) || floor.normal.Z < 0.75 { return false; };
    if floor.position.Z > seed.Z + 0.15 || floor.position.Z < seed.Z - 1.0 { return false; };
    point = seed;
    point.Z = floor.position.Z + 0.10;
    point.W = 1.0;
    let i = 0;
    // Validate a standing footprint and body clearance, not a single ray/ledge.
    while i < 5 {
      let center = point;
      switch i {
        case 1: center.X += 0.30; break;
        case 2: center.X -= 0.30; break;
        case 3: center.Y += 0.30; break;
        case 4: center.Y -= 0.30; break;
      };
      start = center; start.Z += 0.15;
      finish = center; finish.Z -= 0.25;
      let support: TraceResult;
      if !queries.SyncRaycastByCollisionGroup(start, finish, n"Static", support, true, false) || support.normal.Z < 0.75 || AbsF(support.position.Z - floor.position.Z) > 0.15 { return false; };
      start = center; start.Z += 0.15;
      finish = center; finish.Z += 1.90;
      let obstacle: TraceResult;
      if queries.SyncRaycastByCollisionGroup(start, finish, n"Static", obstacle, true, false) { return false; };
      let level = 0;
      while level < 3 {
        start = point; start.Z += 0.35 + Cast<Float>(level) * 0.65;
        finish = center; finish.Z = start.Z;
        if i > 0 && queries.SyncRaycastByCollisionGroup(start, finish, n"Static", obstacle, true, false) { return false; };
        level += 1;
      };
      i += 1;
    };
    return true;
  }

}
@addMethod(MarketSystem)
public final func ProjectCapricornAttachedRipperdocs() -> array<ref<ScriptedPuppet>> {
  let result: array<ref<ScriptedPuppet>>;
  let i = 0;
  while i < ArraySize(this.m_vendors) {
    let vendor = this.m_vendors[i];
    if IsDefined(vendor) && vendor.IsAttached() && Equals(vendor.GetVendorType(), gamedataVendorType.RipperDoc) {
      let doc = vendor.GetVendorObject() as ScriptedPuppet;
      if IsDefined(doc) { ArrayPush(result, doc); };
    };
    i += 1;
  };
  return result;
}
// Update countdown labels without replaying selection/wipe animations every second.
@addMethod(dialogWidgetGameController)
public final func ProjectCapricornRefreshLabels(data: DialogChoiceHubs) -> Void {
  this.m_data = data;
  let i = 0;
  while i < ArraySize(this.m_hubControllers) && i < ArraySize(data.choiceHubs) {
    this.m_hubControllers[i].ProjectCapricornRefreshLabels(data.choiceHubs[i]);
    i += 1;
  };
}
@addMethod(DialogHubLogicController)
public final func ProjectCapricornRefreshLabels(data: ListChoiceHubData) -> Void {
  this.m_data = data;
  let i = 0;
  while i < ArraySize(this.m_itemControllers) && i < ArraySize(data.choices) {
    let item = this.m_itemControllers[i];
    let choice = data.choices[i];
    item.SetChoiceText(choice.localizedName, "");
    item.SetType(choice.type);
    item.SetDimmed(ChoiceTypeWrapper.IsType(choice.type, gameinteractionsChoiceType.Inactive));
    item.UpdateView();
    i += 1;
  };
}

// Independent cleanup still runs if the CET polling job or another callback stops.
public class ProjectCapricornTeleportTimeout extends DelayCallback {
  public let settings: wref<ProjectCapricornCallSettings>;
  public let serial: Int32;
  public func Call() -> Void {
    if IsDefined(this.settings) && this.settings.teleportSerial == this.serial && this.settings.teleportPending && !this.settings.ripperLoading {
      this.settings.ResetTeleport();
      this.settings.lastState = "Teleport timed out; option released for retry";
    };
  }
}

// Scope gravity-free stock locomotion to this transaction, without overwriting
// quest-owned permanent ForceFreeze parameters. All other freezes keep working.
@wrapMethod(LocomotionTransition)
protected final const func IsFreezeForced(const stateContext: ref<StateContext>) -> Bool {
  let settings = ProjectCapricornCallSettings.Get();
  return wrappedMethod(stateContext) || (IsDefined(settings) && settings.ripperLoading);
}
@wrapMethod(ForceFreezeEvents)
public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  wrappedMethod(stateContext, scriptInterface);
  let settings = ProjectCapricornCallSettings.Get();
  if IsDefined(settings) && settings.ripperLoading && settings.player == scriptInterface.owner { settings.ripperFrozen = true; };
}
public class ProjectCapricornRipperLoadPoll extends DelayCallback {
  public let settings: wref<ProjectCapricornCallSettings>;
  public let player: wref<PlayerPuppet>;
  public let serial: Int32;
  public let epoch: Int32;
  public func Call() -> Void {
    if !IsDefined(this.settings) { return; };
    if this.settings.teleportSerial != this.serial || this.settings.ripperPhaseEpoch != this.epoch || !this.settings.ripperLoading {
      this.settings.ripperStaleCallbacks += 1; return;
    };
    this.settings.ripperPollScheduled = false;
    if !IsDefined(this.player) || this.settings.player != this.player || this.player.IsDead() { this.settings.ResetTeleport(); return; };
    this.settings.PollRipperLoading();
  }
}
public class ProjectCapricornRipperLoadTimeout extends DelayCallback {
  public let settings: wref<ProjectCapricornCallSettings>;
  public let serial: Int32;
  public let returning: Bool;
  public func Call() -> Void {
    if !IsDefined(this.settings) || this.settings.teleportSerial != this.serial || !this.settings.ripperLoading { return; };
    if !IsDefined(this.settings.player) { this.settings.ResetTeleport(); return; };
    if this.settings.ripperLoadPhase == 4 {
      this.settings.FinishRipperTravel(this.serial, true, "Arrival verified; reveal cleanup completed by watchdog");
    } else {
      if this.returning {
        let rotation: EulerAngles; rotation.Yaw = this.settings.ripperLoadYaw;
        GameInstance.GetTeleportationFacility(this.settings.player.GetGame()).Teleport(this.settings.player, this.settings.ripperLoadOrigin, rotation);
        this.settings.FinishRipperTravel(this.serial, false, "Returned to original coordinates; floor verification timed out; visuals released for recovery");
      } else { this.settings.ReturnFromRipperLoad("Clinic readiness deadline exceeded"); };
    };
  }
}
public class ProjectCapricornRipperRevealEnd extends DelayCallback {
  public let settings: wref<ProjectCapricornCallSettings>;
  public let serial: Int32;
  public let epoch: Int32;
  public func Call() -> Void {
    if !IsDefined(this.settings) || this.settings.teleportSerial != this.serial || this.settings.ripperPhaseEpoch != this.epoch || this.settings.ripperLoadPhase != 4 { return; };
    this.settings.FinishRipperTravel(this.serial, true, "Ripperdoc arrival verified; transition and loading visuals restored");
  }
}



// v0.8.3 acquisition is independent of Call Capri being enabled/equipped.
public abstract class ProjectCapricornAcquisition {
  public static func ProgressReady(player: ref<PlayerPuppet>) -> Bool {
    if !IsDefined(player) { return false; };
    let game = player.GetGame();
    let stats = GameInstance.GetStatsSystem(game);
    let id = Cast<StatsObjectID>(player.GetEntityID());
    return ProjectCapricornInvitation.SomewhatDamagedComplete(player)
      && stats.GetStatValue(id, gamedataStatType.Level) >= 60.0
      && stats.GetStatValue(id, gamedataStatType.StreetCred) >= 50.0;
  }
  public static func Notify(player: ref<PlayerPuppet>, text: String) -> Void {
    let message: SimpleScreenMessage;
    message.isShown = true;
    message.duration = 10.0;
    message.message = text;
    GameInstance.GetBlackboardSystem(player.GetGame()).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(message), true);
  }
  public static func Book(player: ref<PlayerPuppet>) -> ref<CraftBook> {
    let crafting = GameInstance.GetScriptableSystemsContainer(player.GetGame()).Get(n"CraftingSystem") as CraftingSystem;
    if IsDefined(crafting) { return crafting.GetPlayerCraftBook(); };
    return null;
  }
  public static func IsConversion(record: TweakDBID) -> Bool {
    return record == t"Items.Capricorn" || record == t"Items.Capricorn_CantoConversion" || record == t"Items.Capricorn_ErebusConversion";
  }
  public static func RecipeTarget(erebus: Bool) -> TweakDBID {
    return erebus ? t"Items.Capricorn_ErebusConversion" : t"Items.Capricorn_CantoConversion";
  }
  public static func FindCore(player: ref<PlayerPuppet>, opt erebus: Bool) -> ref<gameItemData> {
    if !IsDefined(player) { return null; };
    let ts = GameInstance.GetTransactionSystem(player.GetGame());
    let items: array<wref<gameItemData>>;
    ts.GetItemList(player, items);
    let i = 0;
    while i < ArraySize(items) {
      let core = items[i];
      if IsDefined(core) && !core.HasTag(n"Quest") && !RPGManager.IsItemEquipped(player, core.GetID()) {
        let record = ItemID.GetTDBID(core.GetID());
        if erebus {
          if (record == t"Items.Legendary_Borg4a_HauntedGun" || record == t"Items.Preset_Borg4a_HauntedGun") && Equals(RPGManager.GetItemTierForUpgrades(core), gamedataQuality.LegendaryPlusPlus) { return core; };
        } else {
          if record == t"Items.HauntedCyberdeck_LegendaryPlusPlus" && ProjectCapricornAcquisition.ProgramsRemoved(player, core) { return core; };
        };
      };
      i += 1;
    };
    return null;
  }
  public static func ProgramsRemoved(player: ref<PlayerPuppet>, core: ref<gameItemData>) -> Bool {
    let slots: array<TweakDBID>;
    GameInstance.GetTransactionSystem(player.GetGame()).GetUsedSlotsOnItem(player, core.GetID(), slots);
    let i = 0;
    while i < ArraySize(slots) {
      let part: InnerItemData;
      core.GetItemPart(part, slots[i]);
      let record = InnerItemData.GetStaticData(part);
      if IsDefined(record) && Equals(record.ItemType().Type(), gamedataItemType.Prt_Program)
        && record.GetID() != t"Items.BlackWallProgramLvl4" && !record.TagsContains(n"DummyPart") { return false; };
      i += 1;
    };
    return true;
  }
  public static func BlockReason(player: ref<PlayerPuppet>, opt selectedRecipe: TweakDBID) -> String {
    let erebus = selectedRecipe == t"Items.Capricorn_ErebusConversion";
    if !ProjectCapricornAcquisition.ProgressReady(player) { return "Requires Level 60, Street Cred 50, and completion of Somewhat Damaged."; };
    if !ProjectCapricornInvitation.HasReplied(player) { return "Reply to the Unknown sender in your phone to receive the conversion schematics."; };
    let book = ProjectCapricornAcquisition.Book(player);
    if !IsDefined(book) { return "Crafting book is unavailable."; };
    let learned = book.GetRecipeIndex(ProjectCapricornAcquisition.RecipeTarget(erebus)) >= 0;
    if selectedRecipe == t"Items.Capricorn" && book.GetRecipeIndex(t"Items.Capricorn") >= 0 { learned = true; };
    if !learned { return "The selected Capricorn conversion schematic has not been learned yet."; };
    if !IsDefined(ProjectCapricornAcquisition.FindCore(player, erebus)) {
      if erebus { return "Requires an unequipped, non-quest Tier 5++ Erebus. The selected weapon and any remaining attachments will be consumed."; };
      return "Requires an unequipped Tier 5++ Canto Mk.6 with all removable quickhacks removed.";
    };
    let ts = GameInstance.GetTransactionSystem(player.GetGame());
    if ts.GetItemQuantity(player, ItemID.CreateQuery(t"Items.LegendaryMaterial1")) < 1000 { return "Requires 1,000 Tier 5 item components."; };
    if ts.GetItemQuantity(player, ItemID.CreateQuery(t"Items.QuickHackLegendaryMaterial1")) < 500 { return "Requires 500 Tier 5 quickhack components."; };
    return "";
  }
}
@addMethod(PlayerPuppet)
public final func CapricornAcquisitionTick() -> Void {
  if this.IsDead() { return; };
  let book = ProjectCapricornAcquisition.Book(this);
  if !IsDefined(book) || !IsDefined(book.GetOwner()) { return; };
  // Poll reply state even while the phone is open. Never grant on a read receipt.
  if !ProjectCapricornInvitation.Tick(this) {
    ProjectCapricornInvitation.SetRecipesHidden(book, true);
    return;
  };
  if !ProjectCapricornAcquisition.ProgressReady(this) { return; };
  let ts = GameInstance.GetTransactionSystem(this.GetGame());
  let learned = false;
  if book.GetRecipeIndex(t"Items.Capricorn_CantoConversion") < 0 && ts.GetItemQuantity(this, ItemID.CreateQuery(t"Items.Recipe_Capricorn")) == 0 {
    if ts.GiveItemByTDBID(this, t"Items.Recipe_Capricorn", 1) { learned = true; };
  };
  if book.GetRecipeIndex(t"Items.Capricorn_ErebusConversion") < 0 && ts.GetItemQuantity(this, ItemID.CreateQuery(t"Items.Recipe_Capricorn_Erebus")) == 0 {
    if ts.GiveItemByTDBID(this, t"Items.Recipe_Capricorn_Erebus", 1) { learned = true; };
  };
  ProjectCapricornInvitation.SetRecipesHidden(book, false);
  // CraftBook deduplicates by output record. These two preview records remain
  // independent; both handlers explicitly produce the real Items.Capricorn.
  if book.GetRecipeIndex(t"Items.Capricorn_CantoConversion") >= 0 && book.GetRecipeIndex(t"Items.Capricorn_ErebusConversion") >= 0 && book.GetRecipeIndex(t"Items.Capricorn") >= 0 {
    let legacy = book.GetRecipeData(t"Items.Capricorn");
    if !legacy.isHidden { book.HideRecipe(t"Items.Capricorn", true); };
  };
  if learned { ProjectCapricornAcquisition.Notify(this, "Received two Capricorn conversion schematics: Canto Mk.6 and Erebus."); };
}
@addMethod(PlayerPuppet)
public final func CapricornAcquisitionStatus() -> String {
  let book = ProjectCapricornAcquisition.Book(this);
  let canto = IsDefined(book) && book.GetRecipeIndex(t"Items.Capricorn_CantoConversion") >= 0;
  let erebus = IsDefined(book) && book.GetRecipeIndex(t"Items.Capricorn_ErebusConversion") >= 0;
  let cantoReason = ProjectCapricornAcquisition.BlockReason(this, t"Items.Capricorn_CantoConversion");
  let erebusReason = ProjectCapricornAcquisition.BlockReason(this, t"Items.Capricorn_ErebusConversion");
  return s"Project Capricorn | invitationReplied=\(ProjectCapricornInvitation.HasReplied(this)) | progressReady=\(ProjectCapricornAcquisition.ProgressReady(this)) | cantoRecipe=\(canto) | erebusRecipe=\(erebus) | cantoReady=\(Equals(cantoReason, "")) | erebusReady=\(Equals(erebusReason, "")) | cantoRequirement=\(cantoReason) | erebusRequirement=\(erebusReason)";
}

@wrapMethod(CraftingSystem)
public final const func GetItemCraftingCost(itemRecord: wref<Item_Record>) -> array<IngredientData> {
  if IsDefined(itemRecord) && ProjectCapricornAcquisition.IsConversion(itemRecord.GetID()) {
    let cost: array<IngredientData>;
    let erebus = itemRecord.GetID() == t"Items.Capricorn_ErebusConversion";
    let coreRecord = erebus ? t"Items.Legendary_Borg4a_HauntedGun" : t"Items.HauntedCyberdeck_LegendaryPlusPlus";
    let book = this.GetPlayerCraftBook();
    if IsDefined(book) {
      let core = ProjectCapricornAcquisition.FindCore(book.GetOwner() as PlayerPuppet, erebus);
      if IsDefined(core) { coreRecord = ItemID.GetTDBID(core.GetID()); };
    };
    ArrayPush(cost, this.CreateIngredientData(TweakDBInterface.GetItemRecord(coreRecord), 1));
    ArrayPush(cost, this.CreateIngredientData(TweakDBInterface.GetItemRecord(t"Items.LegendaryMaterial1"), 1000));
    ArrayPush(cost, this.CreateIngredientData(TweakDBInterface.GetItemRecord(t"Items.QuickHackLegendaryMaterial1"), 500));
    return cost;
  };
  return wrappedMethod(itemRecord);
}
@wrapMethod(CraftingSystem)
public final const func CanItemBeCrafted(itemRecord: wref<Item_Record>) -> Bool {
  if IsDefined(itemRecord) && ProjectCapricornAcquisition.IsConversion(itemRecord.GetID()) { return Equals(ProjectCapricornAcquisition.BlockReason(this.GetPlayerCraftBook().GetOwner() as PlayerPuppet, itemRecord.GetID()), ""); };
  return wrappedMethod(itemRecord);
}
@wrapMethod(CraftingSystem)
public final const func CanItemBeCrafted(itemData: wref<gameItemData>) -> Bool {
  if IsDefined(itemData) && ProjectCapricornAcquisition.IsConversion(ItemID.GetTDBID(itemData.GetID())) { return Equals(ProjectCapricornAcquisition.BlockReason(this.GetPlayerCraftBook().GetOwner() as PlayerPuppet, ItemID.GetTDBID(itemData.GetID())), ""); };
  return wrappedMethod(itemData);
}
@wrapMethod(CraftingSystem)
private final func OnCraftItemRequest(request: ref<CraftItemRequest>) -> Void {
  if !IsDefined(request.itemRecord) || !ProjectCapricornAcquisition.IsConversion(request.itemRecord.GetID()) { wrappedMethod(request); return; };
  let player = request.target as PlayerPuppet;
  if !IsDefined(player) { return; };
  let reason = ProjectCapricornAcquisition.BlockReason(player, request.itemRecord.GetID());
  if !Equals(reason, "") { this.m_lastActionStatus = false; ProjectCapricornAcquisition.Notify(player, reason); return; };
  let core: ref<gameItemData> = ProjectCapricornAcquisition.FindCore(player, request.itemRecord.GetID() == t"Items.Capricorn_ErebusConversion");
  if !IsDefined(core) { this.m_lastActionStatus = false; ProjectCapricornAcquisition.Notify(player, "The selected core is no longer available. Nothing was consumed."); return; };
  let ts = GameInstance.GetTransactionSystem(player.GetGame());
  // Exact costs and one conversion per request. Other recipes keep vanilla perks.
  if !ts.RemoveItemByTDBID(player, t"Items.LegendaryMaterial1", 1000, true) { this.m_lastActionStatus = false; return; };
  if !ts.RemoveItemByTDBID(player, t"Items.QuickHackLegendaryMaterial1", 500, true) {
    ts.GiveItemByTDBID(player, t"Items.LegendaryMaterial1", 1000);
    this.m_lastActionStatus = false; return;
  };
  if !ts.RemoveItem(player, core.GetID(), 1) {
    ts.GiveItemByTDBID(player, t"Items.LegendaryMaterial1", 1000);
    ts.GiveItemByTDBID(player, t"Items.QuickHackLegendaryMaterial1", 500);
    this.m_lastActionStatus = false;
    ProjectCapricornAcquisition.Notify(player, "The selected core could not be consumed. Components refunded."); return;
  };
  let result = ItemID.FromTDBID(t"Items.Capricorn");
  if !ts.GiveItem(player, result, 1) {
    ts.GiveItemByItemData(player, core);
    ts.GiveItemByTDBID(player, t"Items.LegendaryMaterial1", 1000);
    ts.GiveItemByTDBID(player, t"Items.QuickHackLegendaryMaterial1", 500);
    this.m_lastActionStatus = false;
    ProjectCapricornAcquisition.Notify(player, "Capricorn could not be created. Original core and components returned."); return;
  };
  let output = ts.GetItemData(player, result);
  this.SetItemLevel(output);
  this.MarkItemAsCrafted(output);
  this.SendItemCraftedDataTrackingRequest(result, 1);
  this.m_lastActionStatus = true;
  this.UpdateBlackboard(CraftingCommands.CraftingFinished, result);
}

// Scanner portraits have their own widget: a late vehicle-icon image request
// can only modify the hidden stock image, never Capri's independent portrait.
@wrapMethod(InkImageUtils)
public final static func RequestSetImage(controller: ref<inkLogicController>, target: inkImageRef, iconID: TweakDBID, opt callbackFunction: CName) -> Void {
  let scanner = controller as QuickhacksListItemController;
  if IsDefined(scanner) && iconID == t"UIIcon.ProjectCapricornScanner" {
    scanner.CapricornUseFramedIcon();
    return;
  };
  wrappedMethod(controller, target, iconID, callbackFunction);
}

@addField(QuickhacksListItemController)
private let capricornPortrait: ref<inkImage>;
@addField(QuickhacksListItemController)
private let capricornOriginalIconVisible: Bool;
@addField(QuickhacksListItemController)
private let capricornOriginalIconOpacity: Float;
@addField(QuickhacksListItemController)
private let capricornFramedIconActive: Bool;
@addField(QuickhacksListItemController)
private let capricornOriginalIconTint: HDRColor;
@addField(QuickhacksListItemController)
private let capricornNativeFrames: array<wref<inkWidget>>;
@addField(QuickhacksListItemController)
private let capricornNativeFrameVisibility: array<Bool>;

@addMethod(QuickhacksListItemController)
public final func CapricornUseFramedIcon() -> Void {
  if !this.capricornFramedIconActive {
    let icon = inkWidgetRef.Get(this.m_icon);
    if IsDefined(icon) { this.capricornOriginalIconTint = icon.GetTintColor(); this.capricornOriginalIconVisible = icon.IsVisible(); this.capricornOriginalIconOpacity = icon.GetOpacity(); };
    ArrayClear(this.capricornNativeFrames);
    ArrayClear(this.capricornNativeFrameVisibility);
    this.CapricornCollectNativeFrames(this.GetRootWidget());
    this.capricornFramedIconActive = true;
  };
  let nativeIcon = inkWidgetRef.Get(this.m_icon) as inkImage;
  if IsDefined(nativeIcon) {
    let parent = nativeIcon.GetParentWidget() as inkCompoundWidget;
    if IsDefined(parent) {
      if !IsDefined(this.capricornPortrait) {
        this.capricornPortrait = new inkImage();
        this.capricornPortrait.SetName(n"ProjectCapricornScannerPortrait");
        this.capricornPortrait.SetInteractive(false);
        this.capricornPortrait.SetFitToContent(false);
        this.capricornPortrait.SetHAlign(inkEHorizontalAlign.Fill);
        this.capricornPortrait.SetVAlign(inkEVerticalAlign.Fill);
        this.capricornPortrait.SetContentHAlign(inkEHorizontalAlign.Fill);
        this.capricornPortrait.SetContentVAlign(inkEVerticalAlign.Fill);
        this.capricornPortrait.SetAtlasResource(r"capricorn\\icons\\capri.inkatlas");
        this.capricornPortrait.SetTexturePart(n"CapriScanner");
        this.capricornPortrait.SetTintColor(new HDRColor(1.0, 1.0, 1.0, 1.0));
        this.capricornPortrait.Reparent(parent);
      };
      let size = parent.GetSize();
      if size.X <= 0.0 || size.Y <= 0.0 { size = new Vector2(100.0, 100.0); };
      this.capricornPortrait.SetSize(size);
      this.capricornPortrait.SetVisible(true);
      nativeIcon.SetVisible(false); nativeIcon.SetOpacity(0.0);
    };
  };
  let i = 0;
  while i < ArraySize(this.capricornNativeFrames) {
    if IsDefined(this.capricornNativeFrames[i]) { this.capricornNativeFrames[i].SetVisible(false); };
    i += 1;
  };
}
@addMethod(QuickhacksListItemController)
private final func CapricornCollectNativeFrames(node: ref<inkWidget>) -> Void {
  if !IsDefined(node) { return; };
  let image = node as inkImage;
  if IsDefined(image) {
    let part = image.GetTexturePart();
    if Equals(part, n"frame_qh_bg") || Equals(part, n"frame_qh_fg") {
      ArrayPush(this.capricornNativeFrames, node);
      ArrayPush(this.capricornNativeFrameVisibility, node.IsVisible());
    };
  };
  let compound = node as inkCompoundWidget;
  if IsDefined(compound) {
    let i = 0;
    while i < compound.GetNumChildren() {
      this.CapricornCollectNativeFrames(compound.GetWidgetByIndex(i));
      i += 1;
    };
  };
}
@addMethod(QuickhacksListItemController)
public final func CapricornRestoreNativeFrame() -> Void {
  if IsDefined(this.capricornPortrait) { this.capricornPortrait.SetVisible(false); };
  let icon = inkWidgetRef.Get(this.m_icon);
  if IsDefined(icon) && this.capricornFramedIconActive {
    icon.UnbindProperty(n"tintColor");
    icon.SetTintColor(this.capricornOriginalIconTint);
    icon.SetVisible(this.capricornOriginalIconVisible); icon.SetOpacity(this.capricornOriginalIconOpacity);
  };
  let i = 0;
  while i < ArraySize(this.capricornNativeFrames) && i < ArraySize(this.capricornNativeFrameVisibility) {
    if IsDefined(this.capricornNativeFrames[i]) { this.capricornNativeFrames[i].SetVisible(this.capricornNativeFrameVisibility[i]); };
    i += 1;
  };
  ArrayClear(this.capricornNativeFrames);
  ArrayClear(this.capricornNativeFrameVisibility);
  this.capricornFramedIconActive = false;
}

// Apply after the stock handler so optional category tinting cannot override
// the user's full-color artwork. Other rows retain their native tint behavior.
@wrapMethod(QuickhacksListItemController)
protected cb func OnDataChanged(value: ref<IScriptable>) -> Bool {
  let data = value as QuickhackData;
  let ours = false;
  let helper = false;
  if IsDefined(data) {
    if IsDefined(data.m_action) {
      helper = data.m_action.GetObjectActionID() == t"QuickHack.CapriPossess";
      ours = helper || data.m_action.GetObjectActionID() == t"QuickHack.ProjectCapricorn";
    } else {
      helper = data.m_icon == t"UIIcon.CapriPossessedHelper";
      ours = helper || data.m_icon == t"UIIcon.ProjectCapricornScanner";
    };
    if ours { data.m_icon = helper ? t"UIIcon.CapriPossessedHelper" : t"UIIcon.ProjectCapricornScanner"; };
  };
  if this.capricornFramedIconActive && !ours {
    this.CapricornRestoreNativeFrame();
    let previous = inkWidgetRef.Get(this.m_icon);
    if IsDefined(previous) {
      previous.SetFitToContent(true);
      previous.SetHAlign(inkEHorizontalAlign.Center);
      previous.SetVAlign(inkEVerticalAlign.Center);
    };
  };
  let result = wrappedMethod(value);
  if ours {
    this.CapricornUseFramedIcon();
    if IsDefined(this.capricornPortrait) {
      if helper { this.capricornPortrait.SetAtlasResource(r"capri_helper\\icons\\capri_green.inkatlas"); }
      else { this.capricornPortrait.SetAtlasResource(r"capricorn\\icons\\capri.inkatlas"); };
      this.capricornPortrait.SetTexturePart(n"CapriScanner");
      this.capricornPortrait.SetTintColor(new HDRColor(1.0, 1.0, 1.0, 1.0));
    };
  };
  return result;
}


// Upload/duration/queue use unframed artwork clipped to the stock frame silhouette.
// Match the native frame footprint and its margin on both normal and fill layers.
// Preserve the native masks, border, tint states, progress and animations.
@wrapMethod(InkImageUtils)
public final static func RequestSetImage(controller: ref<inkLogicController>, target: wref<inkImage>, iconID: TweakDBID, opt callbackFunction: CName) -> Void {
  let marker = IsDefined(controller as QuickHackMappinController) || IsDefined(controller as QuickHackQueueItem);
  if marker && IsDefined(target) {
    if iconID == t"UIIcon.CapriPossessedHelper" {
      target.SetFitToContent(false);
      target.SetSize(80.0, 88.0);
      target.SetMargin(0.0, 0.0, 0.0, 0.0);
      target.SetContentHAlign(inkEHorizontalAlign.Fill);
      target.SetContentVAlign(inkEVerticalAlign.Fill);
      target.SetAtlasResource(r"capri_helper\\icons\\capri_green.inkatlas");
      target.SetTexturePart(n"CapriScanner");
      target.UnbindProperty(n"tintColor");
      target.SetTintColor(new HDRColor(1.0, 1.0, 1.0, 1.0));
      return;
    };
    if iconID == t"UIIcon.ProjectCapricornScanner" {
      target.SetFitToContent(false);
      target.SetSize(80.0, 88.0);
      target.SetMargin(0.0, 0.0, 0.0, 0.0);
      target.SetContentHAlign(inkEHorizontalAlign.Fill);
      target.SetContentVAlign(inkEVerticalAlign.Fill);
      target.SetAtlasResource(r"capricorn\\icons\\capri_upload.inkatlas");
      if Equals(target.GetName(), n"icon_fill") {
        target.SetTexturePart(n"CapriUploadFill");
      } else {
        target.SetTexturePart(n"CapriUpload");
      };
      return;
    };
    if Equals(target.GetTexturePart(), n"CapriUpload") || Equals(target.GetTexturePart(), n"CapriUploadFill") || Equals(target.GetTexturePart(), n"CapriScanner") {
      target.SetFitToContent(true);
      target.SetSize(64.0, 64.0);
      target.SetMargin(0.0, 0.0, 0.0, 7.0);
    };
  };
  wrappedMethod(controller, target, iconID, callbackFunction);
}

@addMethod(PlayerPuppet)
public func CapricornIconStatus() -> String {
  let settings = ProjectCapricornCallSettings.Get();
  if !IsDefined(settings) { return "Project Capricorn | icon resources unavailable"; };
  return s"Project Capricorn| hudPrimer=\(IsDefined(settings.capricornScannerPrimer)) | scannerAtlas=\(IsDefined(settings.capricornScannerAtlasToken) && settings.capricornScannerAtlasToken.IsLoaded()) | scannerTexture=\(IsDefined(settings.capricornScannerTextureToken) && settings.capricornScannerTextureToken.IsLoaded()) | uploadAtlas=\(IsDefined(settings.capricornUploadAtlasToken) && settings.capricornUploadAtlasToken.IsLoaded()) | uploadTexture=\(IsDefined(settings.capricornUploadTextureToken) && settings.capricornUploadTextureToken.IsLoaded())";
}

// Dispatch all valid snapshot targets in one callback, without per-target delays.
public class ProjectCapricornAreaBatch extends DelayCallback {
  public let player: wref<PlayerPuppet>;
  public let settings: wref<ProjectCapricornCallSettings>;
  public let targets: array<wref<NPCPuppet>>;
  public let vehicles: array<wref<VehicleObject>>;
  public let center: Vector4;
  public let serial: Int32;
  public let index: Int32;
  public static func ProtectedVehicle(vehicle: ref<VehicleObject>) -> Bool {
    if !IsDefined(vehicle) { return true; };
    return vehicle.capricornSelfDestructProtected || vehicle.IsPlayerVehicle() || vehicle.IsPlayerActiveVehicle() || GameInstance.GetVehicleSystem(vehicle.GetGame()).IsVehiclePlayerUnlocked(vehicle.GetRecordID());
  }
  public static func ValidVehicle(vehicle: ref<VehicleObject>, center: Vector4) -> Bool {
    if !IsDefined(vehicle) || !vehicle.IsAttached() || Vector4.Distance(center, vehicle.GetWorldPosition()) > 50.0 { return false; };
    if ProjectCapricornAreaBatch.ProtectedVehicle(vehicle) { return false; };
    let ps = vehicle.GetVehiclePS();
    return IsDefined(ps) && !ps.GetHasExploded() && !ps.GetIsDestroyed();
  }
  public func Call() -> Void {
    if !IsDefined(this.settings) || this.settings.areaBatchSerial != this.serial { return; };
    if !IsDefined(this.player) || !this.player.IsAttached() || this.player.IsDead() || this.settings.player != this.player || !CapricornProjectQuickhack.IsDeckEquipped(this.player) || Vector4.Distance(this.center, this.player.GetWorldPosition()) > 75.0 {
      this.settings.areaBatchSkipped += ArraySize(this.targets) - this.index;
      this.settings.lastVehicleSkipped += ArraySize(this.vehicles);
      this.settings.areaBatchPending = 0;
      this.settings.areaBatchActive = false;
      this.settings.areaBatchState = "cancelled: player, deck, session or location changed";
      return;
    };
    while this.index < ArraySize(this.targets) {
      let target: ref<NPCPuppet> = this.targets[this.index];
      this.index += 1;
      this.settings.areaBatchPending = ArraySize(this.targets) - this.index + ArraySize(this.vehicles);
      if IsDefined(target) && target.IsAttached() && CapricornProjectQuickhack.IsValidSpreadTarget(target, this.player) && !CapricornProjectQuickhack.HostFinished(target) {
        let strike = new ProjectCapricornAreaStrike();
        strike.player = this.player;
        strike.target = target;
        strike.Call();
        this.settings.areaBatchDispatched += 1;
      } else { this.settings.areaBatchSkipped += 1; };
    };
    let vehicleIndex = 0;
    while vehicleIndex < ArraySize(this.vehicles) {
      let vehicle: ref<VehicleObject> = this.vehicles[vehicleIndex];
      if ProjectCapricornAreaBatch.ValidVehicle(vehicle, this.center) {
        // Exact native effect used by VehicleComponentPS.OnVehicleOverrideExplode.
        // No manual Project Capricorn instance, spread, RAM cost or per-car delay.
        vehicle.ActivateNetrunnerQuickhack(VehicleNetrunnerQuickhackType.Explode);
        this.settings.lastVehicleDispatched += 1;
      } else { this.settings.lastVehicleSkipped += 1; };
      vehicleIndex += 1;
      this.settings.areaBatchPending = ArraySize(this.vehicles) - vehicleIndex;
    };
    this.settings.areaBatchPending = 0;
    this.settings.areaBatchActive = false;
    this.settings.areaBatchState = "completed: simultaneous area strike";
  }
}


public abstract class ProjectCapricornRecovery {
  public static func Cleanse(player: ref<PlayerPuppet>) -> Int32 {
    let system = GameInstance.GetStatusEffectSystem(player.GetGame());
    let effects: array<ref<StatusEffect>>;
    system.GetAppliedEffects(player.GetEntityID(), effects);
    let board = GameInstance.GetBlackboardSystem(player.GetGame()).Get(GetAllBlackboardDefs().UI_PlayerBioMonitor);
    let debuffs = FromVariant<array<BuffInfo>>(board.GetVariant(GetAllBlackboardDefs().UI_PlayerBioMonitor.DebuffsList));
    let requests = 0;
    let i = 0;
    while i < ArraySize(effects) {
      if IsDefined(effects[i]) {
        let record = effects[i].GetRecord();
        if IsDefined(record) && ProjectCapricornRecovery.IsHarmful(record, debuffs) {
          system.RemoveStatusEffect(player.GetEntityID(), record.GetID());
          requests += 1;
        };
      };
      i += 1;
    };
    return requests;
  }
  public static func IsHarmful(record: ref<StatusEffect_Record>, debuffs: array<BuffInfo>) -> Bool {
    let kind = record.StatusEffectType();
    if !IsDefined(kind) { return false; };
    let type = kind.Type();
    // Cooldowns and quest-control effects are not removable medical debuffs.
    if Equals(type, gamedataStatusEffectType.PlayerCooldown) || record.GameplayTagsContains(n"Quest") || record.GameplayTagsContains(n"QuestRestriction") { return false; };
    if record.GameplayTagsContains(n"Debuff") || record.GameplayTagsContains(n"NegativeEffect") || record.GameplayTagsContains(n"NegativeStatusEffect") { return true; };
    if record.GameplayTagsContains(n"Buff") { return false; };
    let i = 0;
    while i < ArraySize(debuffs) {
      if debuffs[i].buffID == record.GetID() { return true; };
      i += 1;
    };
    switch type {
      case gamedataStatusEffectType.BlackwallHack:
      case gamedataStatusEffectType.Bleeding:
      case gamedataStatusEffectType.Blind:
      case gamedataStatusEffectType.BrainMelt:
      case gamedataStatusEffectType.Burning:
      case gamedataStatusEffectType.Crippled:
      case gamedataStatusEffectType.Deafened:
      case gamedataStatusEffectType.EMP:
      case gamedataStatusEffectType.Electrocuted:
      case gamedataStatusEffectType.Exhausted:
      case gamedataStatusEffectType.Jam:
      case gamedataStatusEffectType.Knockdown:
      case gamedataStatusEffectType.Overheat:
      case gamedataStatusEffectType.Overload:
      case gamedataStatusEffectType.Pain:
      case gamedataStatusEffectType.PassiveDebuff:
      case gamedataStatusEffectType.Poisoned:
      case gamedataStatusEffectType.QuickHackFreezeLocomotion:
      case gamedataStatusEffectType.QuickHackStaggerCyberware:
      case gamedataStatusEffectType.QuickHackStaggerLocomotion:
      case gamedataStatusEffectType.QuickHackStaggerWeapon:
      case gamedataStatusEffectType.Stagger:
      case gamedataStatusEffectType.Stunned:
      case gamedataStatusEffectType.SuicideHack:
      case gamedataStatusEffectType.SystemCollapse:
      case gamedataStatusEffectType.UncontrolledMovement:
      case gamedataStatusEffectType.Wounded:
      case gamedataStatusEffectType.CPOShocked:
        return true;
    };
    return false;
  }
}

@addMethod(PlayerPuppet)
public final func CapricornCommandStatus() -> String {
  let settings = ProjectCapricornCallSettings.Get();
  if !IsDefined(settings) { return "Project Capricorn | Call Capri system unavailable"; };
  return s"Project Capricorn | NPCs=\(settings.lastAreaTargetCount) | vehicles=\(settings.lastVehicleTargets) | playerVehiclesProtected=\(settings.lastVehicleProtected) | vehicleEffectsSent=\(settings.lastVehicleDispatched) | vehiclesSkipped=\(settings.lastVehicleSkipped) | cleanseRequests=\(settings.lastCleanseRequests) | humanityRestored=\(settings.lastHumanityRestored) | humanity=\(settings.lastHumanityState)";
}


// Optional opt-out for external vehicle spawners. No global spawn hooks needed.
@addField(VehicleObject)
public let capricornSelfDestructProtected: Bool;


// The phone thread is a native, save-persistent journal contribution. Polling
// only observes the two native reply states; it never simulates V replying.
public abstract class ProjectCapricornInvitation {
  public static func SomewhatDamagedComplete(player: ref<PlayerPuppet>) -> Bool {
    if !IsDefined(player) { return false; };

    let journal = GameInstance.GetJournalManager(player.GetGame());
    if !IsDefined(journal) { return false; };

    let quest = journal.GetEntryByString(
      "ep1/quests/main_quest/q305_bunker",
      "gameJournalQuest"
    );

    if !IsDefined(quest) { return false; };

    return Equals(
      journal.GetEntryState(quest),
      gameJournalEntryState.Succeeded
    );
  }
  public static func HasReplied(player: ref<PlayerPuppet>) -> Bool {
    let facts = GameInstance.GetQuestsSystem(player.GetGame());
    if facts.GetFact(n"capricorn_invitation_replied") > 0 { return true; };
    let journal = GameInstance.GetJournalManager(player.GetGame());
    if !IsDefined(journal) { return false; };
    let first = journal.GetEntryByString("contacts/capricorn_unknown/schematics/replies/reply_1", "gameJournalPhoneChoiceEntry");
    let second = journal.GetEntryByString("contacts/capricorn_unknown/schematics/replies/reply_2", "gameJournalPhoneChoiceEntry");
    return (IsDefined(first) && Equals(journal.GetEntryState(first), gameJournalEntryState.Succeeded)) || (IsDefined(second) && Equals(journal.GetEntryState(second), gameJournalEntryState.Succeeded));
  }
  public static func SetRecipesHidden(book: ref<CraftBook>, hidden: Bool) -> Void {
    let ids: array<TweakDBID>;
    ArrayPush(ids, t"Items.Capricorn_CantoConversion");
    ArrayPush(ids, t"Items.Capricorn_ErebusConversion");
    if hidden { ArrayPush(ids, t"Items.Capricorn"); };
    let i = 0;
    while i < ArraySize(ids) {
      if book.GetRecipeIndex(ids[i]) >= 0 {
        let data = book.GetRecipeData(ids[i]);
        if (data.isHidden && !hidden) || (!data.isHidden && hidden) { book.HideRecipe(ids[i], hidden); };
      };
      i += 1;
    };
  }
  public static func CanDeliver(player: ref<PlayerPuppet>) -> Bool {
    if player.IsDead() || player.IsInCombat() || player.IsReplacer() { return false; };
    let tier = PlayerPuppet.GetSceneTier(player);
    if tier != 1 && tier != 2 { return false; };
    let game = player.GetGame();
    let boards = GameInstance.GetBlackboardSystem(game);
    if boards.Get(GetAllBlackboardDefs().UI_System).GetBool(GetAllBlackboardDefs().UI_System.IsInMenu) { return false; };
    if GameInstance.GetSceneSystem(game).GetScriptInterface().IsEntityInDialogue(player.GetEntityID()) || GameInstance.GetWorkspotSystem(game).IsActorInWorkspot(player) || GameInstance.GetPhotoModeSystem(game).IsPhotoModeActive() { return false; };
    let call = FromVariant<PhoneCallInformation>(boards.Get(GetAllBlackboardDefs().UI_ComDevice).GetVariant(GetAllBlackboardDefs().UI_ComDevice.PhoneCallInformation));
    return Equals(call.callPhase, questPhoneCallPhase.EndCall) || Equals(call.callPhase, questPhoneCallPhase.Undefined);
  }
  private static func Activate(journal: ref<JournalManager>, path: String, type: String, notify: JournalNotifyOption) -> Bool {
    let entry = journal.GetEntryByString(path, type);
    if !IsDefined(entry) { return false; };
    if Equals(journal.GetEntryState(entry), gameJournalEntryState.Inactive) {
      return journal.ChangeEntryState(path, type, gameJournalEntryState.Active, notify);
    };
    return true;
  }
  public static func Deliver(player: ref<PlayerPuppet>, path: String) -> Bool {
    let journal = GameInstance.GetJournalManager(player.GetGame());
    if !IsDefined(journal) { return false; };
    // Verify the full resource is registered before exposing a partial thread.
    let last = journal.GetEntryByString(path + "/schematics/replies/reply_2", "gameJournalPhoneChoiceEntry");
    if !IsDefined(last) { return false; };
    if !ProjectCapricornInvitation.Activate(journal, path, "gameJournalContact", JournalNotifyOption.DoNotNotify) { return false; };
    if !ProjectCapricornInvitation.Activate(journal, path + "/schematics", "gameJournalPhoneConversation", JournalNotifyOption.DoNotNotify) { return false; };
    if !ProjectCapricornInvitation.Activate(journal, path + "/schematics/message_1", "gameJournalPhoneMessage", JournalNotifyOption.DoNotNotify) { return false; };
    if !ProjectCapricornInvitation.Activate(journal, path + "/schematics/message_2", "gameJournalPhoneMessage", JournalNotifyOption.DoNotNotify) { return false; };
    if !ProjectCapricornInvitation.Activate(journal, path + "/schematics/message_3", "gameJournalPhoneMessage", JournalNotifyOption.Notify) { return false; };
    if !ProjectCapricornInvitation.Activate(journal, path + "/schematics/replies", "gameJournalPhoneChoiceGroup", JournalNotifyOption.DoNotNotify) { return false; };
    return true;
  }
  public static func ResetTest(player: ref<PlayerPuppet>) -> Void {
    let journal = GameInstance.GetJournalManager(player.GetGame());
    if !IsDefined(journal) { return; };
    let paths: array<String>;
    let types: array<String>;
    ArrayPush(paths, "/schematics/replies/reply_1"); ArrayPush(types, "gameJournalPhoneChoiceEntry");
    ArrayPush(paths, "/schematics/replies/reply_2"); ArrayPush(types, "gameJournalPhoneChoiceEntry");
    ArrayPush(paths, "/schematics/replies"); ArrayPush(types, "gameJournalPhoneChoiceGroup");
    ArrayPush(paths, "/schematics/message_3"); ArrayPush(types, "gameJournalPhoneMessage");
    ArrayPush(paths, "/schematics/message_2"); ArrayPush(types, "gameJournalPhoneMessage");
    ArrayPush(paths, "/schematics/message_1"); ArrayPush(types, "gameJournalPhoneMessage");
    ArrayPush(paths, "/schematics"); ArrayPush(types, "gameJournalPhoneConversation");
    ArrayPush(paths, ""); ArrayPush(types, "gameJournalContact");
    let i = 0;
    while i < ArraySize(paths) {
      let path = "contacts/capricorn_unknown_test" + paths[i];
      let entry = journal.GetEntryByString(path, types[i]);
      if IsDefined(entry) {
        journal.ChangeEntryState(path, types[i], gameJournalEntryState.Inactive, JournalNotifyOption.DoNotNotify);
        journal.SetEntryVisited(entry, false);
      };
      i += 1;
    };
  }
  public static func Tick(player: ref<PlayerPuppet>) -> Bool {
    let facts = GameInstance.GetQuestsSystem(player.GetGame());
    if ProjectCapricornInvitation.HasReplied(player) {
      if facts.GetFact(n"capricorn_invitation_replied") == 0 { facts.SetFact(n"capricorn_invitation_replied", 1); };
      return true;
    };
    if facts.GetFact(n"capricorn_invitation_started") > 0 || !ProjectCapricornAcquisition.ProgressReady(player) || !ProjectCapricornInvitation.CanDeliver(player) { return false; };
    if !ProjectCapricornInvitation.Deliver(player, "contacts/capricorn_unknown") { return false; };
    facts.SetFact(n"capricorn_invitation_started", 1);
    return false;
  }
}

@addMethod(PlayerPuppet)
public final func CapricornInvitationStatus() -> String {
  let journal = GameInstance.GetJournalManager(this.GetGame());
  let contact = journal.GetEntryByString("contacts/capricorn_unknown", "gameJournalContact");
  let reply = journal.GetEntryByString("contacts/capricorn_unknown/schematics/replies/reply_2", "gameJournalPhoneChoiceEntry");
  let facts = GameInstance.GetQuestsSystem(this.GetGame());
  let sent = facts.GetFact(n"capricorn_invitation_started");
  let q305 = facts.GetFact(n"q305_finished");
  let q306 = facts.GetFact(n"q306_finished");
  let stats = GameInstance.GetStatsSystem(this.GetGame());
  let id = Cast<StatsObjectID>(this.GetEntityID());
  let level = stats.GetStatValue(id, gamedataStatType.Level);
  let cred = stats.GetStatValue(id, gamedataStatType.StreetCred);
  return s"Project Capricorn | contactRegistered=\(IsDefined(contact)) | repliesRegistered=\(IsDefined(reply)) | level=\(level)/60 | streetCred=\(cred)/50 | q305_finished=\(q305) | q306_finished=\(q306) | PLComplete=\(ProjectCapricornInvitation.SomewhatDamagedComplete(this)) | requirementsReady=\(ProjectCapricornAcquisition.ProgressReady(this)) | canDeliverNow=\(ProjectCapricornInvitation.CanDeliver(this)) | invitationSent=\(sent) | replied=\(ProjectCapricornInvitation.HasReplied(this))";
}

@addMethod(PlayerPuppet)
public final func CapricornTestConversation() -> String {
  if !ProjectCapricornInvitation.CanDeliver(this) { return "Use this in free gameplay outside combat, menus, dialogue and phone calls, then try again."; };
  let journal = GameInstance.GetJournalManager(this.GetGame());
  let entry = journal.GetEntryByString("contacts/capricorn_unknown_test/schematics/replies/reply_2", "gameJournalPhoneChoiceEntry");
  if !IsDefined(entry) { return "Test journal is not registered. Restart the game with v0.8.3 and check ArchiveXL loading."; };
  ProjectCapricornInvitation.ResetTest(this);
  if !ProjectCapricornInvitation.Deliver(this, "contacts/capricorn_unknown_test") { return "Test delivery failed; no normal unlock or story facts were changed."; };
  return "Conversation sent to Unknown (Test). Read and choose either reply. This test does not unlock recipes or change real story flags. Run CapricornEndConversationTest() to remove the test thread.";
}

@addMethod(PlayerPuppet)
public final func CapricornEndConversationTest() -> String {
  ProjectCapricornInvitation.ResetTest(this);
  return "Test thread deactivated. The real conversation, unlock progress and story facts are unchanged.";
}

@addMethod(PlayerPuppet)
public final func CapricornConversationTestStatus() -> String {
  let journal = GameInstance.GetJournalManager(this.GetGame());
  let one = journal.GetEntryByString("contacts/capricorn_unknown_test/schematics/replies/reply_1", "gameJournalPhoneChoiceEntry");
  let two = journal.GetEntryByString("contacts/capricorn_unknown_test/schematics/replies/reply_2", "gameJournalPhoneChoiceEntry");
  let first = IsDefined(one) && Equals(journal.GetEntryState(one), gameJournalEntryState.Succeeded);
  let second = IsDefined(two) && Equals(journal.GetEntryState(two), gameJournalEntryState.Succeeded);
  return s"Project Capricorn test | registered=\(IsDefined(one) && IsDefined(two)) | reply1Sent=\(first) | reply2Sent=\(second) | realUnlockReplied=\(ProjectCapricornInvitation.HasReplied(this))";
}

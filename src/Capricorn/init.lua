-- Shared identity check for the original deck and both ripperdoc upgrades.
local function isCapricornDeck(item)
  local id = ItemID.GetTDBID(item)
  return id == TweakDBID.new("Items.Capricorn") or id == TweakDBID.new("Items.CapricornPlus") or id == TweakDBID.new("Items.CapricornPlusPlus")
end

-- CET stores one callback per event per mod. Fan out locally; register once.
local capricornNativeRegister = registerForEvent
local capricornEventHandlers = {}
local capricornEventErrors = {}
local function registerForEvent(event, callback)
  if not capricornEventHandlers[event] then
    capricornEventHandlers[event] = {}
    capricornNativeRegister(event, function(...)
      for index, handler in ipairs(capricornEventHandlers[event]) do
        local ok, err = pcall(handler, ...)
        local key = event .. ":" .. index
        if not ok then
          if capricornEventErrors[key] ~= tostring(err) then print("[Project Capricorn] " .. key .. ": " .. tostring(err)) end
          capricornEventErrors[key] = tostring(err)
        else capricornEventErrors[key] = nil end
      end
    end)
  end
  table.insert(capricornEventHandlers[event], callback)
end

-- Capricorn 0.7.8. Transient queue correction; never changes saved perks.
local state = { elapsed = 0, owner = nil, modifier = nil, amount = 0, failed = false }

local function clear()
  if state.owner and state.modifier then
    Game.GetStatsSystem():RemoveModifier(state.owner:GetEntityID(), state.modifier)
  end
  state.owner, state.modifier, state.amount = nil, nil, 0
end

local function updateQueue()
  local player = Game.GetPlayer()
  if not player then clear(); return end
  if state.owner and state.owner ~= player then clear() end
  local data = EquipmentSystem.GetData(player)
  if not data then clear(); return end
  local item = CapricornUpgradeSupport.FindDeck(player)
  if not isCapricornDeck(item) then
    clear()
    return
  end
  local stats = Game.GetStatsSystem()
  local id = player:GetEntityID()
  -- Subtract only our own contribution. Preserve and respond to perk changes.
  local current = stats:GetStatValue(id, gamedataStatType.QuickHackQueueSize)
  local desired = 5 - (current - state.amount)
  if state.owner == player and math.abs(desired - state.amount) < 0.01 then return end
  clear()
  if math.abs(desired) > 0.01 then
    local modifier = RPGManager.CreateStatModifier(gamedataStatType.QuickHackQueueSize, gameStatModifierType.Additive, desired)
    stats:AddModifier(id, modifier)
    state.owner, state.modifier, state.amount = player, modifier, desired
  end
end

registerForEvent("onInit", function()
  print("[Capricorn] Queue helper loaded; target queue size: 5.")
end)

local function tickQueue(dt)
  if state.failed then return end
  state.elapsed = state.elapsed + dt
  if state.elapsed < 0.25 then return end
  state.elapsed = 0
  local ok, err = pcall(updateQueue)
  if not ok then
    pcall(clear)
    state.failed = true
    print("[Capricorn] Queue helper stopped: " .. tostring(err))
  end
end



-- Audio overloads and CName construction are handled in typed redscript.
-- This optional job remains isolated from queue correction and dialogue polling.
local audio = { owner = nil, failed = false, status = "initializing" }
local function releaseAudio()
  if audio.owner then audio.owner:CapricornApplyVoiceMute(false) end
  audio.owner = nil
end
local function updateAudio(player)
  if audio.owner and audio.owner ~= player then releaseAudio() end
  if not player then audio.status = "inactive"; return end
  audio.owner = player
  local wanted = false
  if TweakDB:GetFlat("Capricorn.DialogueEnabled") ~= false then
    local data = EquipmentSystem.GetData(player)
    wanted = data and isCapricornDeck(CapricornUpgradeSupport.FindDeck(player)) or false
  end
  audio.status = player:CapricornApplyVoiceMute(wanted)
end

-- Dialogue, voice mute, Call Capri and acquisition use independent error handling.
local dialogue = { elapsed = 0, failed = false }
local callCapri = { failed = false }
local acquisition = { elapsed = 0, failed = false }
local slots = { elapsed = 0, failed = false }
registerForEvent("onUpdate", function(dt)
  tickQueue(dt)
  dialogue.elapsed = dialogue.elapsed + dt
  if dialogue.elapsed < 0.25 then return end
  local elapsed = dialogue.elapsed
  dialogue.elapsed = 0
  local player = Game.GetPlayer()
  if not audio.failed then
    local ok, err = pcall(updateAudio, player)
    if not ok then
      pcall(releaseAudio)
      audio.failed = true
      audio.status = "Audioware mute unavailable: " .. tostring(err)
      print("[Capricorn] " .. audio.status)
    end
  end
  if player then pcall(function() player.capricornAudioMuteState = audio.status end) end
  if player and not callCapri.failed then
    local ok, err = pcall(function() player:CapricornCallTick(elapsed) end)
    if not ok then
      callCapri.failed = true
      print("[Project Capricorn] Call Capri update stopped: " .. tostring(err))
    end
  end
  -- Slot migration is isolated from all working gameplay jobs. It checks each
  -- equipped deck once; only legacy signature attachments may be removed.
  if player and not slots.failed then
    slots.elapsed = slots.elapsed + elapsed
    if slots.elapsed >= 2 then
      slots.elapsed = 0
      local ok, err = pcall(function() player:CapricornEnsureRegularSlots() end)
      if not ok then
        slots.failed = true
        print("[Project Capricorn] Slot migration stopped: " .. tostring(err))
      end
    end
  end
  if player and not acquisition.failed then
    acquisition.elapsed = acquisition.elapsed + elapsed
    if acquisition.elapsed >= 2 then
      acquisition.elapsed = 0
      local ok, err = pcall(function() player:CapricornAcquisitionTick() end)
      if not ok then
        acquisition.failed = true
        print("[Project Capricorn] Recipe unlock polling stopped: " .. tostring(err))
      end
    end
  end
  if not player or dialogue.failed then return end
  local ok, err = pcall(function() player:CapricornDialogueTick(elapsed) end)
  if not ok then
    dialogue.failed = true
    print("[Capricorn] Dialogue polling stopped: " .. tostring(err))
  end
end)
registerForEvent("onShutdown", function()
  pcall(clear)
  pcall(releaseAudio)
end)


-- 0.9.0: read-only event detection; all speech uses Capricorn's typed dispatcher.
-- No attack, quest, equipment, weather or vehicle gameplay is changed here.
local capriReactive = (function()
  local R = { elapsed = 0, clock = 0, errors = {}, hookCount = 0, poll = {} }
  local function name(value)
    if value == nil then return "" end
    if type(value) == "string" then return value end
    local ok, text = pcall(NameToString, value)
    if ok and text and text ~= "" then return text end
    return tostring(value)
  end
  local function lower(value) return string.lower(name(value)) end
  local function recordText(value) return R.owner:CapricornReactiveRecordName(value) end
  local function id(object) return object and tostring(object:GetEntityID().hash) or "" end
  local function pos(object)
    local v = object:GetWorldPosition()
    return {x=v.x or v.X,y=v.y or v.Y,z=v.z or v.Z}
  end
  local function distance(a,b)
    if not a or not b then return math.huge end
    return math.sqrt((a.x-b.x)^2+(a.y-b.y)^2+(a.z-b.z)^2)
  end
  local function enabled()
    local p=R.activePlayer
    return p and not p:IsDead() and p or nil
  end
  local function fail(channel, err)
    local prior=R.errors[channel]
    R.errors[channel]=tostring(err)
    if not prior then print("[Project Capricorn reactions] "..channel..": "..tostring(err)) end
  end
  local function guard(channel,fn,...)
    local ok,result=pcall(fn,...)
    if not ok then fail(channel,result); return nil end
    R.errors[channel]=nil
    return result
  end
  local function emit(key)
    local p=enabled()
    if not p then return false end
    return p:CapricornReactiveEnqueue(key)
  end
  local function drop(key)
    local p=Game.GetPlayer()
    if p then p:CapricornReactiveDrop(key) end
  end
  local function edge(key,value,trigger)
    local old=R[key];R[key]=value
    if old~=nil and old~=value and value and trigger then emit(trigger) end
    return old
  end
  local function burst(key,window,threshold,trigger)
    local a=R[key] or {};R[key]=a
    while #a>0 and R.clock-a[1]>window do table.remove(a,1) end
    a[#a+1]=R.clock
    if #a>=threshold then emit(trigger);R[key]={} end
  end
  
-- Debug-only synthetic gameplay detection.
-- Does not alter actual player, world, or quest state.

function R.injectSyntheticDetection(key)
  if type(key) ~= "string" or key == "" then
    return "Invalid trigger key"
  end

  local p = Game.GetPlayer()
  if not p or not CapricornDialogue.IsEnabled(p) then
    return "Capricorn must be equipped and enabled"
  end

  R.syntheticSignals = R.syntheticSignals or {}

  if #R.syntheticSignals >= 8 then
    return "Synthetic signal buffer full"
  end

  table.insert(R.syntheticSignals, key)
  return "Synthetic detector signal scheduled: " .. key
end

local function runSyntheticDetection(p, key)
  local before = p.capricornReactiveDetected or 0

  -- Simulate actual repetition detector inputs.
  local repetitions = {
    repeat_jump      = {"jumpTimes", 12, 6},
    repeat_crouch    = {"crouchTimes", 10, 8},
    repeat_inventory = {"inventoryTimes", 40, 4},
    repeat_weapon    = {"weaponTimes", 12, 6},
    kill_streak      = {"killTimes", 8, 3},
    quickhack_streak = {"uploadTimes", 12, 3}
  }

  local test = repetitions[key]

  if test then
    -- Preserve the real detector's partial counter.
    local previous = R[test[1]]
    R[test[1]] = {}

    for i = 1, test[3] do
      burst(test[1], test[2], test[3], key)
    end

    R[test[1]] = previous
  else
    -- Simulate the other detectors reporting an event.
    emit(key)
  end

  local accepted = (p.capricornReactiveDetected or 0) > before

  print(
    "[Capricorn synthetic detection] " ..
    key .. " | accepted=" .. tostring(accepted)
  )
end
  local function observe(class,method,fn,before)
    local ok,err=pcall(function()
      local bind=before and ObserveBefore or ObserveAfter
      bind(class,method,function(...)
        if not R.owner or not enabled() then return end
        guard(class.."."..method,fn,...)
      end)
    end)
    if not ok then fail("hook:"..class.."."..method,err) else R.hookCount=R.hookCount+1 end
  end
  local function stat(p,kind) return Game.GetStatsSystem():GetStatValue(p:GetEntityID(),kind) end
  local function health(p) return Game.GetStatPoolsSystem():GetStatPoolValue(p:GetEntityID(),gamedataStatPoolType.Health,true) end
  local function psm(p)
    return Game.GetBlackboardSystem():GetLocalInstanced(p:GetEntityID(),GetAllBlackboardDefs().PlayerStateMachine)
  end
  local function activeGameplay(p) return CapricornDialogue.GameplayAvailable(p,false) end
  local function reset(p)
    local errors,hooks=R.errors,R.hookCount
    for k,v in pairs(R) do if type(v)~="function" then R[k]=nil end end
    R.errors,R.hookCount,R.elapsed,R.clock,R.poll=errors,hooks,0,0,{}
    R.owner=p;R.ownerID=id(p);R.lastPosition=pos(p);R.exploreStart=pos(p);R.lastInput=0;R.peace=0
    R.killed,R.defeated,R.lastHits,R.pendingKills,R.squad,R.seen={}, {}, {}, {}, {}, {}
    p:CapricornReactiveReset();p:CapricornReactiveAttach()
  end
  local function encounter(npc)
    if npc:IsCharacterCyberpsycho() then return "cyberpsycho" end
    if npc:IsBoss() then return "boss" end
    if npc:IsNetrunnerPuppet() then return "netrunner" end
    local typ=lower(npc:GetNPCType())
    if not string.find(typ,"human",1,true) then return "machine" end
    if npc:IsMassive() or StatusEffectSystem.ObjectHasStatusEffectOfType(npc,gamedataStatusEffectType.Sandevistan) or StatusEffectSystem.ObjectHasStatusEffectOfType(npc,gamedataStatusEffectType.Berserk) then return "heavy_chrome" end
  end
  local factions={maelstrom="faction_maelstrom",tygerclaws="faction_tyger",valentinos="faction_valentino",animals="faction_animals",voodooboys="faction_voodoo",sixthstreet="faction_sixth",scavengers="faction_scav",wraiths="faction_wraith",barghest="faction_barghest",arasaka="faction_corp",militech="faction_corp"}
  function R.combat(p,dt)
    local combat=p:IsInCombat()
    if combat and not R.wasCombat then R.encounter={};R.combatAt=R.clock;R.longPlayed=false end
    if not combat then R.peace=(R.peace or 0)+dt else R.peace=0 end
    if combat and R.clock-(R.combatAt or R.clock)>=180 and not R.longPlayed then emit("long_combat");R.longPlayed=true end
    if not combat and R.peace>=900 and not R.peacePlayed and distance(R.exploreStart,R.lastPosition)>300 then emit("explore_long");R.peacePlayed=true end
    if combat then R.exploreStart=pos(p);R.peacePlayed=false end
    R.wasCombat=combat
    local prevention=Game.GetScriptableSystemsContainer():Get("PreventionSystem")
    if prevention then
      local stars=tonumber(prevention:GetHeatStageAsInt())
      if R.stars~=nil and stars>R.stars then
        if stars==5 then emit("police_five") elseif R.stars==0 then emit("police_first") else emit("police_increase") end
      end
      -- Escape is loss of exact location during a live pursuit; clearing is a
      -- separate 0-star transition. Do not emit both for a forced quest reset.
      local searching=stars>0 and prevention:IsPoliceUnawareOfThePlayerExactLocation()
      if R.searching==false and searching and R.stars and R.stars>0 then emit("police_escape") end
      if R.stars and R.stars>0 and stars==0 then emit("police_zero");R.squad={};R.squadAnnounced=false;R.maxtacPresent=false end
      R.stars,R.searching=stars,searching
    end
    if not combat or R.clock-(R.npcPoll or -10)<1.5 then return end
    R.npcPoll=R.clock
    local npcs=p:GetNPCsAroundObject()
    local scanned=0
    for _,npc in ipairs(npcs) do
      if npc and npc:IsAttached() and not npc:IsDead() and distance(pos(p),pos(npc))<=60 and GameObject.GetAttitudeTowards(npc,p)==EAIAttitude.AIA_Hostile then
        scanned=scanned+1
        if npc:IsMaxTac() then
          local nid=id(npc)
          if R.squadAnnounced and R.squad[nid]==nil then R.squad={};R.squadAnnounced=false;R.maxtacPresent=false end
          if not R.squad[nid] then
            R.squad[nid]=false
            if not R.maxtacPresent then emit("maxtac_arrives");R.maxtacPresent=true end
          end
        end
        local key=encounter(npc)
        R.encounter=R.encounter or {}
        if key and not R.encounter[key] then R.encounter[key]=true;emit(key) end
        local aff=lower(npc:GetRecord():Affiliation():Type()):gsub("[^a-z]","")
        for token,event in pairs(factions) do
          if aff:find(token,1,true) and not R.encounter[event] then R.encounter[event]=true;emit(event) end
        end
      end
      if scanned>=64 then break end
    end
  end
  function R.project(p)
    local casts=p.capricornProjectCasts
    local used=p.capricornProjectAdditionalUploadsUsed
    local repeats=p.capricornProjectReapplications
    local hops=p.capricornProjectSpreadQueued
    if casts~=R.projectCasts then R.repeatBase=repeats;R.hopBase=hops;R.budgetPlayed=false;R.repeatPlayed=false;R.hopPlayed=false end
    if R.projectCasts~=nil then
      if used>=10 and not R.budgetPlayed then
        -- Budget line describes completed uploads, not the last upload starting.
        local chain=p.capricornProjectActiveChain
        local completed=not chain and tostring(p.capricornProjectChainState or ""):find("complete: 10",1,true)==1
        if (chain and not chain.uploading) or completed then emit("project_budget");R.budgetPlayed=true end
      end
      if repeats-(R.repeatBase or repeats)>=2 and not R.repeatPlayed then emit("project_reapply");R.repeatPlayed=true end
      if hops>=2 and not R.hopPlayed then emit("project_chain");R.hopPlayed=true end
    end
    R.projectCasts,R.projectUsed=casts,used
    local over=StatusEffectSystem.ObjectHasStatusEffect(p,TweakDBID.new("BaseStatusEffect.Intelligence_Central_Milestone_3_Overclock_Buff"))
    if R.over~=nil and over~=R.over then emit(over and "overclock_start" or "overclock_end") end
    R.over=over
  end
  local districtNames={watson="district_watson",westbrook="district_westbrook",citycenter="district_center",heywood="district_heywood",santodomingo="district_santo",pacifica="district_pacifica",badlands="district_badlands",dogtown="district_dogtown"}
  function R.district(p)
    local sys=Game.GetScriptableSystemsContainer():Get("PreventionSystem")
    if not sys then return end
    local d=sys:GetCurrentDistrict()
    if not d then return end
    local rec=d:GetDistrictRecord();local key
    for _=1,4 do
      if not rec then break end
      local text=lower(rec:Type()):gsub("[^a-z]","")
      for token,event in pairs(districtNames) do if text:find(token,1,true) then key=event;break end end
      if key then break end
      rec=rec:ParentDistrict()
    end
    if d:IsDogTown() then key="district_dogtown" elseif d:IsBadlands() then key="district_badlands" end
    if key and key~=R.districtKey then
      R.districtSeen=R.districtSeen or {}
      if R.districtKey then
        if R.districtKey=="district_dogtown" then emit("leave_dogtown") end
        if R.districtSeen[key] and R.clock-R.districtSeen[key]>=1800 then emit("district_return") else emit(key) end
        R.districtSeen[R.districtKey]=R.clock
      end
      R.districtKey=key
    end
  end
  function R.environment(p,dt)
    local t=Game.GetTimeSystem():GetGameTime()
    local minutes=GameTime.Days(t)*1440+GameTime.Hours(t)*60+GameTime.Minutes(t)
    if R.gameMinutes and minutes>=R.gameMinutes and minutes-R.gameMinutes<10 then
      for hour,event in pairs({[6]="sunrise",[18]="sunset",[0]="midnight"}) do
        if math.floor((minutes-hour*60)/1440)>math.floor((R.gameMinutes-hour*60)/1440) then emit(event) end
      end
    end
    R.gameMinutes=minutes;R.awakeSince=R.awakeSince or minutes
    if minutes-R.awakeSince>=1440 and not R.awakePlayed then emit("awake_long");R.awakePlayed=true end
    local weather=Game.GetWeatherSystem():GetWeatherState()
    local wn=weather and lower(weather.name) or ""
    local rain=Game.GetWeatherSystem():GetRainIntensityType()~=worldRainIntensity.NoRain
    local key
    if wn:find("sand",1,true) then key="sandstorm"
    elseif wn:find("storm",1,true) or wn:find("thunder",1,true) then key="storm"
    elseif wn:find("fog",1,true) or wn:find("smog",1,true) then key="fog"
    elseif rain then key="rain"
    elseif wn:find("sunny",1,true) or wn:find("clear",1,true) then key="clear_weather" end
    if R.weatherSeeded and key and key~=R.weatherKey then
      R.weatherSince=R.clock;R.weatherAnnounced=false
    end
    if R.weatherSeeded and key and not R.weatherAnnounced and R.clock-(R.weatherSince or R.clock)>=10 then emit(key);R.weatherAnnounced=true end
    if not R.weatherSeeded then R.weatherSince=R.clock;R.weatherAnnounced=true end
    R.weatherSeeded=true;R.weatherKey=key
    if key and key~="clear_weather" and not p:CapricornReactiveSheltered() then R.badWeather=(R.badWeather or 0)+dt else R.badWeather=0;R.badPlayed=false end
    if R.badWeather>=300 and not R.badPlayed then emit("bad_weather_long");R.badPlayed=true end
  end
  function R.vehicle(p,dt)
    local vehicle=p:GetMountedVehicle()
    if vehicle then
      local vid=id(vehicle);local position=pos(vehicle)
      if R.vehicleID~=vid then
        p:CapricornReactiveBindVehicle(vehicle)
        R.vehicleID=vid;R.vehiclePosition=position;R.vehicleDistance=0;R.vehicleStop=0;R.vehicleFast=0;R.vehicleAir=nil
        local record=vehicle:GetRecord();local label=lower(recordText(record:GetID()))
        if label:find("rayfield",1,true) or label:find("porsche",1,true) or label:find("caliburn",1,true) or label:find("aerondight",1,true) or label:find("arch_nazar",1,true) or label:find("quadra_turbo",1,true) then emit("vehicle_fancy") end
      end
      local step=distance(position,R.vehiclePosition);local speed=step/dt
      if step>100 then R.vehicleDistance=0;speed=0 end
      local bb=vehicle:GetBlackboard();local collision=bb:GetBool(GetAllBlackboardDefs().Vehicle.Collision)
      if collision and not R.vehicleCollision and (R.vehicleSpeed or 0)>8 then emit("vehicle_crash") end
      R.vehicleCollision=collision
      if speed>45 and vehicle:IsPlayerDriver() then R.vehicleFast=R.vehicleFast+dt else R.vehicleFast=0;R.fastPlayed=false end
      if R.vehicleFast>=3 and not R.fastPlayed then emit("vehicle_fast");R.fastPlayed=true end
      if speed>2 then R.vehicleDistance=R.vehicleDistance+step;R.vehicleStop=0 else R.vehicleStop=R.vehicleStop+dt end
      if R.vehicleStop>10 then R.vehicleDistance=0;R.journeyPlayed=false end
      if R.vehicleDistance>=5000 and not R.journeyPlayed then emit("vehicle_journey");R.journeyPlayed=true end
      if not vehicle.isOnGround then
        if not R.vehicleAir then R.vehicleAir={time=R.clock,z=position.z,peak=position.z,speed=speed} end
        R.vehicleAir.peak=math.max(R.vehicleAir.peak,position.z)
      elseif R.vehicleAir then
        if R.clock-R.vehicleAir.time>=0.7 and R.vehicleAir.peak-R.vehicleAir.z>=1.5 and R.vehicleAir.speed>10 and vehicle:IsPlayerDriver() then emit("vehicle_jump") end
        R.vehicleAir=nil
      end
      R.vehicleDamaged=health(vehicle)<25
      R.vehiclePosition,R.vehicleSpeed=position,speed
      p.capricornReactiveVehicleSpeed=speed
    elseif R.vehicleID then
      p:CapricornReactiveUnbindVehicle()
      if R.vehicleDamaged then emit("vehicle_abandon") end
      R.vehicleID=nil;R.vehicleCollision=false
    end
  end
  function R.behavior(p,dt)
    local bb=psm(p);local defs=GetAllBlackboardDefs().PlayerStateMachine
    local onGround=bb:GetBool(defs.IsOnGround);local position=pos(p)
    local movement=distance(position,R.lastPosition)
    if movement<100 then
      if not p:GetMountedVehicle() and not onGround then R.fallPeak=math.max(R.fallPeak or position.z,position.z)
      elseif onGround and R.fallPeak then
        if R.fallPeak-position.z>=8 and not p:IsDead() then emit("fall_survive") end
        R.fallPeak=nil
      end
    else R.fallPeak=nil end
    local swim=bb:GetInt(defs.Swimming)
    edge("swimming",swim==1 or swim==2,"swim")
    local loc=bb:GetInt(defs.Locomotion)
    if loc~=R.locomotion then
      if loc==5 then
        if not R.jumpAnchor or distance(position,R.jumpAnchor)>8 then R.jumpAnchor=position;R.jumpTimes={} end
        burst("jumpTimes",12,6,"repeat_jump")
      end
      if loc==1 or R.locomotion==1 then burst("crouchTimes",10,8,"repeat_crouch") end
    end
    R.locomotion=loc
    local zone=bb:GetInt(defs.Zones)
    if R.zone and zone>=3 and R.zone<3 then emit("restricted") end
    R.zone=zone
    local cap=stat(p,gamedataStatType.HumanityAllocated)
    if R.capacity and cap-R.capacity>=15 then emit("capacity") end
    R.capacity=cap
    local h=p:CapricornReactiveHumanity()
    if h>=35 then R.humanityWarned=false end
    if h>=0 and h<30 and not R.humanityWarned then emit("low_humanity");R.humanityWarned=true end
    R.humanity=h
    local psycho=p:CapricornReactivePsychosis()
    if (R.psycho~=nil and psycho~=R.psycho) or (R.psycho==nil and psycho) then emit(psycho and "psycho_enter" or "psycho_exit") end
    R.psycho=psycho
    local hp=health(p)
    if p:IsInCombat() and R.hp and R.hp>hp and R.hp-hp>=35 and hp>0 and hp<=10 then emit("near_fatal") end
    R.hp=hp
    R.lastPosition=position
  end
  local anchors={{["name"]="Konpeki Tower",["x"]=-2229.413818359375,["y"]=1769.44970703125,["z"]=21.0,["radius"]=150,["height"]=200,["events"]={"konpeki","landmark"}},{["name"]="Arasaka Tower - Counter-Intel",["x"]=-1442.981689453125,["y"]=139.8174591064453,["z"]=141.9965057373047,["radius"]=130,["height"]=600,["events"]={"arasaka_tower","landmark"}},{["name"]="The Afterlife",["x"]=-1453.0498046875,["y"]=1016.658935546875,["z"]=16.49999237060547,["radius"]=27,["height"]=8,["events"]={"afterlife","bar"}},{["name"]="Lizzie's Bar",["x"]=-1188.916259765625,["y"]=1566.1929931640625,["z"]=22.915115356445312,["radius"]=30,["height"]=9,["events"]={"bar","netrunner_place"}},{["name"]="Totentanz Club - Dancefloor",["x"]=-1720.9764404296875,["y"]=2199.1025390625,["z"]=86.21162414550781,["radius"]=30,["height"]=8,["events"]={"bar"}},{["name"]="Voodoo Boys Subway",["x"]=-1662.758544921875,["y"]=-1867.0025634765625,["z"]=54.98204040527344,["radius"]=65,["height"]=12,["events"]={"netrunner_place","underground"}},{["name"]="Arasaka Tower - Underground",["x"]=-1376.1915283203125,["y"]=143.7060089111328,["z"]=-26.64801025390625,["radius"]=80,["height"]=12,["events"]={"underground"}},{["name"]="Cynosure Core",["x"]=-2072.9167480469,["y"]=-2205.7290039063,["z"]=-194.77502441406,["radius"]=140,["height"]=35,["events"]={"blackwall_facility","underground","pl_location"}},{["name"]="Black Sapphire Stage",["x"]=-1872.1772460938,["y"]=-2258.8901367188,["z"]=439.77749633789,["radius"]=70,["height"]=45,["events"]={"pl_location","landmark"}},{["name"]="The Atlantis Club",["x"]=-761.29455566406,["y"]=1085.0062255859,["z"]=60.989921569824,["radius"]=35,["height"]=12,["events"]={"johnny_place","bar"}},{["name"]="Johnny Interrogation Room",["x"]=-1389.446533203125,["y"]=141.2665557861328,["z"]=-139.361572265625,["radius"]=35,["height"]=12,["events"]={"johnny_place"}},{["name"]="The Oil Fields",["x"]=-1818.8236083984375,["y"]=3858.029541015625,["z"]=7.161346435546875,["radius"]=150,["height"]=18,["events"]={"johnny_place"}},{["name"]="Time Machine Guitar Room",["x"]=-1843.6763916015625,["y"]=-575.3362426757812,["z"]=7.754035949707031,["radius"]=18,["height"]=6,["events"]={"johnny_place","landmark"}},{["name"]="Kerry Villa",["x"]=213.94752502441,["y"]=1073.0196533203,["z"]=200.38607788086,["radius"]=45,["height"]=15,["events"]={"johnny_place"}},{["name"]="V's Apartment",["x"]=-1391.8707275391,["y"]=1271.6887207031,["z"]=123.08239746094,["radius"]=11,["height"]=4,["events"]={"h10"}},{["name"]="Ripperdoc - Viktor",["x"]=-1547.95849609375,["y"]=1230.00830078125,["z"]=11.520233154296875,["radius"]=12,["height"]=4,["events"]={"viktor","ripper_clinic"}}}
  function R.locations(p)
    local position=pos(p);local present={};local apartment=false
    for _,anchor in ipairs(anchors) do
      local dx,dy,dz=position.x-anchor.x,position.y-anchor.y,position.z-anchor.z
      if dx*dx+dy*dy<=anchor.radius^2 and math.abs(dz)<=anchor.height then
        for _,key in ipairs(anchor.events) do present[key]=true end
      end
    end
    -- Service and owned-apartment markers, cached instead of enumerated per frame.
    if R.clock-(R.markerAt or -20)>=10 then
      R.markerAt=R.clock;R.markers={}
      for _,m in ipairs(p:CapricornReactiveServicePoints()) do
        local v=m.point
        R.markers[#R.markers+1]={key=m.key,point={x=v.x or v.X,y=v.y or v.Y,z=v.z or v.Z}}
      end
    end
    for _,m in ipairs(R.markers or {}) do
      local dx,dy=position.x-m.point.x,position.y-m.point.y
      if dx*dx+dy*dy<=225 and math.abs(position.z-m.point.z)<=5 then present[m.key]=true end
    end
    local market=Game.GetScriptableSystemsContainer():Get("MarketSystem")
    if market then
      for _,doc in ipairs(market:ProjectCapricornAttachedRipperdocs()) do
        local at=pos(doc)
        if distance(position,at)<=12 and math.abs(position.z-at.z)<=3 then present.ripper_clinic=true end
      end
    end
    apartment=present.apartment or present.h10 or false
    if R.present then
      for key in pairs(present) do if not R.present[key] then emit(key) end end
      if apartment and not R.inApartment then R.apartmentAt=R.clock end
      if not apartment and R.inApartment then
        if R.sleptAtHome then emit("leave_after_sleep");R.sleptAtHome=false end
        R.homeLongPlayed=false
      end
    end
    if apartment and R.clock-(R.apartmentAt or R.clock)>=300 and not R.homeLongPlayed then emit("apartment_long");R.homeLongPlayed=true end
    R.inApartment=apartment;R.present=present
  end
  local function activityName(p,evt)
    local pieces={}
    if evt and evt.tags then for _,tag in ipairs(evt.tags) do pieces[#pieces+1]=lower(tag) end end
    local instance=Game.GetWorkspotSystem():GetWorkspotInstance(p:GetEntityID())
    if instance then pieces[#pieces+1]=lower(instance.animName);pieces[#pieces+1]=lower(instance.idleAnim) end
    local text=table.concat(pieces," ")
    if text:find("sleep",1,true) or text:find("bed_lie",1,true) then return "sleep" end
    if text:find("shower",1,true) then return "shower" end
    if text:find("mirror",1,true) then return "mirror" end
  end
  local function startActivity(p,kind)
    if not kind or R.activity==kind then return end
    R.activity=kind;p.capricornReactiveWorkspotKey=kind;emit(kind)
    if kind=="sleep" then
      if not R.inApartment then R.locations(p) end
      R.sleptAtHome=R.inApartment or false
      -- A safe pre-workspot window may show the goodnight line immediately.
      p:CapricornReactiveTick(0)
    end
  end
  local function endActivity(p)
    if R.activity=="sleep" then
      drop("sleep");emit("wake")
      local now=Game.GetTimeSystem():GetGameTime()
      R.awakeSince=GameTime.Days(now)*1440+GameTime.Hours(now)*60+GameTime.Minutes(now)
      R.gameMinutes=R.awakeSince;R.awakePlayed=false
    end
    R.activity=nil;p.capricornReactiveWorkspotKey=""
  end
  function R.activities(p)
    local workspot=Game.GetWorkspotSystem():IsActorInWorkspot(p)
    if workspot then startActivity(p,activityName(p)) elseif R.activity then endActivity(p) end
    local bd=Game.GetScriptableSystemsContainer():Get("BraindanceSystem")
    local active=bd and bd:GetIsInBraindance() or false
    if R.bd~=nil and active~=R.bd then
      if active then emit("bd_start") else drop("bd_start");emit("bd_end") end
    end
    R.bd=active
    local phone=Game.GetBlackboardSystem():Get(GetAllBlackboardDefs().UI_ComDevice)
    local info=FromVariant(phone:GetVariant(GetAllBlackboardDefs().UI_ComDevice.PhoneCallInformation))
    local calling=info and info.callPhase~=questPhoneCallPhase.EndCall and info.callPhase~=questPhoneCallPhase.Undefined
    if R.calling==false and calling then emit("phone_call") end
    R.calling=calling or false
  end
  local function processKill(p,npc,killType)
    local nid=id(npc)
    local defeated=lower(killType):find("defeat",1,true)~=nil
    if R.killed[nid] or (defeated and R.defeated[nid]) then return end
    local hit=R.lastHits[nid]
    if GameObject.GetAttitudeTowards(npc,p)~=EAIAttitude.AIA_Hostile and not (hit and hit.hostile) and R.squad[nid]==nil and not npc:IsBoss() and not npc:IsCharacterCyberpsycho() then return end
    if not defeated then R.killed[nid]=R.clock end
    if not R.defeated[nid] then
      if npc:IsCharacterCyberpsycho() then emit("cyberpsycho_defeat") elseif npc:IsBoss() then emit("boss_defeat") end
    end
    R.defeated[nid]=R.clock
    if R.takedownTarget==nid and R.takedownStealth and R.clock-(R.takedownAt or -100)<=12 then emit("stealth_takedown");R.takedownTarget=nil end
    if defeated then return end
    if npc:IsMaxTac() then
      emit("maxtac_kill");R.squad[nid]=true
      local total,dead=0,0
      for _,killed in pairs(R.squad) do total=total+1;if killed then dead=dead+1 end end
      if total>=4 and dead==total and not R.squadAnnounced then R.squadClearPending=true end
    end
    if hit and R.clock-hit.time<=3 then
      if hit.headshot then emit("headshot") end
      if hit.definition then
        R.attackKills=R.attackKills or {}
        local entry
        for _,group in ipairs(R.attackKills) do if group.definition==hit.definition and group.attackTime==hit.attackTime and group.source==hit.source then entry=group;break end end
        if not entry then
          entry={n=0,time=R.clock,definition=hit.definition,attackTime=hit.attackTime,source=hit.source}
          if #R.attackKills>=64 then table.remove(R.attackKills,1) end
          R.attackKills[#R.attackKills+1]=entry
        end
        entry.n=entry.n+1
        if entry.n==2 then emit("multi_kill") end
      end
    end
    if health(p)<=20 then emit("critical_kill") end
    burst("killTimes",8,3,"kill_streak")
    R.checkFinal=R.clock+0.5
  end
  function R.kills(p)
    for i=#R.pendingKills,1,-1 do
      local k=R.pendingKills[i]
      if R.clock>=k.time then
        local npc=Game.FindEntityByID(k.entityID)
        if npc then processKill(p,npc,k.kind) end
        table.remove(R.pendingKills,i)
      end
    end
    if R.squadClearPending then
      local prevention=Game.GetScriptableSystemsContainer():Get("PreventionSystem")
      if prevention and prevention:IsMaxTacDefeated() then emit("maxtac_squad");R.squadAnnounced=true;R.squadClearPending=false end
    end
    if R.checkFinal and R.clock>=R.checkFinal then
      R.checkFinal=nil;local any=p:CapricornReactiveHostilesRemain()
      for _,npc in ipairs(p:GetNPCsAroundObject()) do
        if npc and npc:IsAttached() and ScriptedPuppet.IsActive(npc) and distance(pos(p),pos(npc))<=60 and GameObject.GetAttitudeTowards(npc,p)==EAIAttitude.AIA_Hostile then any=true;break end
      end
      if not any then emit("final_hostile") end
    end
    -- Bound all transient attribution maps; despawning is never counted as a kill.
    for k,v in pairs(R.killed) do if R.clock-v>300 then R.killed[k]=nil end end
    for k,v in pairs(R.defeated) do if R.clock-v>300 then R.defeated[k]=nil end end
    for k,v in pairs(R.lastHits) do if R.clock-v.time>5 then R.lastHits[k]=nil end end
    for i=#(R.attackKills or {}),1,-1 do if R.clock-R.attackKills[i].time>5 then table.remove(R.attackKills,i) end end
  end
  function R.trace(p)
    if R.clock<(R.nativeTraceUntil or 0) then return end
    local bb=Game.GetBlackboardSystem():Get(GetAllBlackboardDefs().UI_HUDProgressBar)
    local kind=FromVariant(bb:GetVariant(GetAllBlackboardDefs().UI_HUDProgressBar.MessageType))
    local active=bb:GetBool(GetAllBlackboardDefs().UI_HUDProgressBar.Active) and kind==SimpleMessageType.Reveal
    local progress=bb:GetFloat(GetAllBlackboardDefs().UI_HUDProgressBar.Progress)
    if R.traceActive==false and active then emit("trace_start");R.tracePeak=0;R.traceWarned=false end
    if active then
      R.tracePeak=math.max(R.tracePeak or 0,progress)
      if progress>=0.8 and not R.traceWarned then emit("trace_near");R.traceWarned=true end
    elseif R.traceActive then
      -- Require an interrupted progress bar, not a completed trace or menu hide.
      local failed=bb:GetString(GetAllBlackboardDefs().UI_HUDProgressBar.FailedText)
      if (R.tracePeak or 1)<0.96 and failed~="" and activeGameplay(p) then emit("trace_avoid") end
    end
    R.traceActive=active
  end
  function R.install()
    observe("ScriptedPuppet","RewardKiller",function(npc,killer,kind)
      local p=Game.GetPlayer()
      if id(killer)==id(p) and #R.pendingKills<64 then R.pendingKills[#R.pendingKills+1]={entityID=npc:GetEntityID(),kind=kind,time=R.clock+0.1} end
    end)
    observe("DamageSystem","PostProcess",function(_,evt)
      local p=Game.GetPlayer();local data=evt and evt.attackData
      if not data then return end
      if id(data:GetInstigator())==id(p) and evt.target and id(evt.target)~=id(p) then
        local definition=data:GetAttackDefinition()
        R.lastHits[id(evt.target)]={time=R.clock,headshot=data:HasFlag(hitFlag.Headshot),definition=definition,attackTime=data:GetAttackTime(),source=id(data:GetSource()),hostile=GameObject.GetAttitudeTowards(evt.target,p)==EAIAttitude.AIA_Hostile}
      end
    end)
    observe("PlayerPuppet","OnStatusEffectApplied",function(p,evt)
      if id(p)~=id(Game.GetPlayer()) or not evt.staticData then return end
      local record=lower(recordText(evt.staticData:GetID()))
      if record:find("overclock",1,true) then return end -- Polled as one transition, never double-dispatched.
      local instigator=evt.instigatorEntityID
      if R.incomingHacker and instigator and tostring(instigator.hash)==R.incomingHacker and R.clock<=(R.incomingHackUntil or 0)
        and R.incomingEffects and R.incomingEffects[record] then emit("hacked") end
      local tags=evt.staticData:GameplayTags();local text=record
      for _,tag in ipairs(tags) do text=text.." "..lower(tag) end
      if text:find("alcohol",1,true) or text:find("drunk",1,true) then emit("alcohol")
      elseif text:find("wellfed",1,true) or text:find("nourishment",1,true) then emit("eat")
      elseif text:find("hydration",1,true) or text:find("hydrated",1,true) then emit("drink") end
    end)
    observe("UploadFromNPCToPlayerListener","OnStatPoolAdded",function(listener)
      -- Some native callbacks have no action attached yet.
      local action = listener and listener.m_action
      if not action then return end

      if listener.m_npcPuppet then
        R.incomingHacker=id(listener.m_npcPuppet)
        R.incomingHackUntil=R.clock+30
        R.incomingEffects={}

        local record=action:GetObjectActionRecord()
        if record then
          for i=0,math.min(record:GetCompletionEffectsCount(),16)-1 do
            local entry=record:GetCompletionEffectsItem(i)
            local effect=entry and entry:StatusEffect()
            if effect then
              R.incomingEffects[lower(recordText(effect:GetID()))]=true
            end
          end
        end
      end

      local actionID=action:GetObjectActionID()
      if actionID==TweakDBID.new("AIQuickHack.HackRevealPosition")
        or actionID==TweakDBID.new("AIQuickHack.PreventionHackRevealPosition")
        or actionID==TweakDBID.new("AIQuickHack.HackReveal") then
        R.traceListener=listener
        R.nativeTraceUntil=R.clock+2
        R.traceWarned=false
        R.traceActive=true
        emit("trace_start")
      end
    end)
    observe("UploadFromNPCToPlayerListener","OnStatPoolValueChanged",function(listener,oldValue,newValue)
      if R.traceListener~=listener then return end
      R.nativeTraceUntil=R.clock+3
      if listener.m_HUDData.active then
        if newValue>=80 and not R.traceWarned then emit("trace_near");R.traceWarned=true end
      elseif newValue<96 then
        if listener.m_HUDData.failedText=="LocKey#15353" and not Game.GetPlayer():IsInCombat() then emit("trace_avoid") end
        R.traceListener=nil;R.traceActive=false
      end
    end)
    observe("UploadFromNPCToPlayerListener","OnStatPoolMaxValueReached",function(listener)
      if R.traceListener==listener then R.traceListener=nil;R.traceActive=false;R.nativeTraceUntil=R.clock+3 end
    end)
    observe("QuickHackUploadListener","SendUploadFinishedEvent",function(listener)
      local action=listener.m_action
      if action and id(action:GetExecutor())==id(Game.GetPlayer()) and action:IsQuickHack() and action:GetObjectActionID()~=TweakDBID.new("QuickHack.ProjectCapricornSpread") then burst("uploadTimes",12,3,"quickhack_streak") end
    end)
    observe("BaseScriptableAction","StartAction",function(action)
      if action:GetObjectActionID()~=TweakDBID.new("QuickHack.ProjectCapricorn") then return end
      local npc=Game.FindEntityByID(action:GetRequesterID())
      if npc and (npc:IsBoss() or npc:IsMaxTac()) then emit("project_elite") end
    end)
    observe("PlayerPuppet","OnWorkspotStartedEvent",function(p,evt) startActivity(p,activityName(p,evt)) end,true)
    observe("PlayerPuppet","OnWorkspotFinishedEvent",function(p) endActivity(p) end)
    observe("PlayerPuppet","OnPlayerTakedownStateChange",function(p,state)
      if state==1 then
        R.takedownTarget=tostring(psm(p):GetEntityID(GetAllBlackboardDefs().PlayerStateMachine.TakedownTargetID).hash)
        R.takedownAt=R.clock;R.takedownStealth=not p:IsInCombat()
      end
    end)
    observe("StealthIndicatorPartLogicController","OnUpdateDetection",function(_,params)
      if params.detectionProgress>=100 and not R.detected then
        if R.clock-(R.undetectedAt or R.clock)>=10 then emit("detected") end
        R.detected=true
      elseif params.detectionProgress==0 then
        if R.detected or not R.undetectedAt then R.undetectedAt=R.clock end
        R.detected=false
      end
    end)
    observe("gameuiInventoryGameController","OnInitialize",function() burst("inventoryTimes",40,4,"repeat_inventory") end)
    observe("ItemActionsHelper","EatItem;GameObjectItemIDBool",function(executor) if id(executor)==id(Game.GetPlayer()) then emit("eat") end end)
    observe("ItemActionsHelper","DrinkItem;GameObjectItemIDBool",function(executor,item)
      if id(executor)~=id(Game.GetPlayer()) then return end
      local record=TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item));local text=record and lower(recordText(record:GetID())) or ""
      if record then for _,tag in ipairs(record:Tags()) do text=text.." "..lower(tag) end end
      if text:find("alcohol",1,true) or text:find("liquor",1,true) or text:find("beer",1,true) then emit("alcohol") else emit("drink") end
    end)
    observe("Stash","OnOpenStash",function() emit("stash") end)
    observe("RipperDocGameController","OnInitialize",function() emit("ripper_open") end)
    observe("RipperDocGameController","OnUninitialize",function() drop("ripper_open");emit("ripper_close") end)
    observe("VehicleSummonWidgetGameController","OnVehicleSummonStateChanged",function(_,state) if state==1 then emit("vehicle_summon") end end)
    observe("VehicleSummonWidgetGameController","OnVehiclePurchased",function() emit("vehicle_unlock") end)
    observe("VehicleSystem","EnablePlayerVehicle",function(system,vehicle,enable)
      if enable then
        R.unlockBefore=R.unlockBefore or {};R.unlockBefore[vehicle]=system:IsVehiclePlayerUnlocked(TweakDBID.new(vehicle))
      end
    end,true)
    observe("VehicleSystem","EnablePlayerVehicle",function(system,vehicle,enable)
      if enable and R.unlockBefore and R.unlockBefore[vehicle]==false and system:IsVehiclePlayerUnlocked(TweakDBID.new(vehicle)) then emit("vehicle_unlock") end
      if R.unlockBefore then R.unlockBefore[vehicle]=nil end
    end)
    observe("FullscreenVendorGameController","OnUIVendorItemBoughtEvent",function(controller,evt)
      local p=Game.GetPlayer();local price=0
      for i,item in ipairs(evt.itemsID) do
        local record=TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item))
        if record and record:ItemCategory():Type()==gamedataItemCategory.Weapon then emit("purchase_weapon") end
        price=price+controller.m_VendorDataManager:GetBuyingPrice(item)*(tonumber(evt.quantity[i]) or 1)
      end
      if price>=50000 then emit("purchase_expensive") end
    end)
    observe("BaseSubtitlesGameController","ShowDialogLines",function(_,lines)
      for _,line in ipairs(lines) do
        if line.speakerName~="Capri" and line.speakerName~="Militech Canto Mk.6" then
          local displayed=scnDialogLineData.GetDisplayText(line)
          local text=lower(displayed.text)
          if text:find("blackwall",1,true) then emit("blackwall_context");break end
        end
      end
    end)
    observe("PlayerPuppet","OnAction",function(_,action)
      local now=os.time()
      if R.lastRealInput and now-R.lastRealInput>=180 then emit("return_inactive") end
      R.lastRealInput=now
    end)
    observe("BraindanceSystem","OnSetIsInBraindance",function(_,request)
      if request.newState then emit("bd_start");R.bd=true;Game.GetPlayer():CapricornReactiveTick(0) end
    end,true)
    observe("BraindanceSystem","OnSetIsInBraindance",function(_,request)
      if not request.newState then drop("bd_start");emit("bd_end");R.bd=false end
    end)
    observe("EquipmentSystemPlayerData","EquipItem;ItemIDBoolBool",function(data,item)
      local player = Game.GetPlayer()
      if not data or not player or not item then return end

      local owner = data:GetOwner()
      if not owner or id(owner) ~= id(player) then return end

      local record = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item))
      if not record then return end

      local category = record:ItemCategory()
      if not category then return end

      if category:Type() == gamedataItemCategory.Clothing then
        emit("clothing")
      end
    end)
  end
  function R.tick(dt)
    R.elapsed=(R.elapsed or 0)+dt
    if R.elapsed<0.25 then return end
    dt=R.elapsed;R.elapsed=0
    local p=Game.GetPlayer()
    if not p then R.owner=nil;R.ownerID=nil;return end
    local sim=p:CapricornReactiveNow()
    -- CET may return a fresh Lua wrapper for the SAME native player on every call.
    -- EntityID plus a native per-player flag identifies the actual session.
    if R.ownerID~=id(p) or not p:CapricornReactiveSessionReady() or (R.lastSim and sim<R.lastSim) then reset(p) end
    R.owner=p
    R.lastSim=sim
    if dt>1 then
      R.lastPosition=pos(p);R.fallPeak=nil;R.vehicleID=nil
      p:CapricornReactiveTick(dt);return
    end
    R.clock=sim
    local deck=CapricornDialogue.IsEnabled(p)
    R.activePlayer=deck and p or nil
    -- Process synthetic signals through the detector's update loop.
    if deck and R.syntheticSignals and #R.syntheticSignals > 0 then
      local signal = table.remove(R.syntheticSignals, 1)

      guard("synthetic detector", function()
        runSyntheticDetection(p, signal)
      end)
    end
    if not deck and R.hadDeck then
      local os=EquipmentSystem.GetData(p):GetActiveItem(gamedataEquipmentArea.SystemReplacementCW)
      if ItemID.IsValid(os) and not isCapricornDeck(os) then R.usedOtherOS=true end
    end
    if R.deck==false and deck and R.usedOtherOS then emit("reequip");R.usedOtherOS=false end
    if deck then R.hadDeck=true end
    R.deck=deck
    guard("speech queue",function() p:CapricornReactiveTick(dt) end)
    if not deck then R.vehicleID=nil;return end
    guard("activities",R.activities,p)
    local ui=Game.GetBlackboardSystem():Get(GetAllBlackboardDefs().UI_System):GetBool(GetAllBlackboardDefs().UI_System.IsInMenu)
    local weapon=EquipmentSystem.GetData(p):GetActiveItem(gamedataEquipmentArea.Weapon)
    local wid=recordText(ItemID.GetTDBID(weapon))..":"..tostring(weapon.rngSeed)..":"..tostring(weapon.uniqueCounter)
    if R.weapon and wid~=R.weapon then burst("weaponTimes",12,6,"repeat_weapon") end
    R.weapon=wid
    if activeGameplay(p) then
      for channel,period in pairs({combat=0.5,project=0.25,district=2,environment=5,vehicle=0.25,behavior=0.25,locations=2,kills=0.25,trace=0.25}) do
        R.poll[channel]=(R.poll[channel] or 0)+dt
        if R.poll[channel]>=period then local delta=R.poll[channel];R.poll[channel]=0;guard(channel,R[channel],p,delta) end
      end
    else
      R.lastPosition=pos(p);R.fallPeak=nil
      R.pendingKills={};R.lastHits={};R.attackKills={};R.checkFinal=nil
    end
    if R.clock-(R.statusAt or -5)>=5 then
      R.statusAt=R.clock;local errors={}
      p:CapricornReactiveAttach()
      for channel,message in pairs(R.errors) do errors[#errors+1]=channel.."="..tostring(message):sub(1,220) end
      p.capricornReactiveAdapterStatus="hooks="..R.hookCount.." | detectorErrors="..table.concat(errors,",").." | weather="..tostring(R.weatherKey or "unknown").." | district="..tostring(R.districtKey or "unknown")
    end
  end
  return R
end)()

function CapriSimulateDetection(key)
  return capriReactive.injectSyntheticDetection(key)
end

registerForEvent("onInit",function() capriReactive.install() end)
local capriReactiveLastError
registerForEvent("onUpdate",function(dt)
  local ok,err=pcall(capriReactive.tick,dt)
  if not ok then
    if capriReactiveLastError~=tostring(err) then print("[Project Capricorn reactions] update: "..tostring(err)) end
    capriReactiveLastError=tostring(err)
  else capriReactiveLastError=nil end
end)
return {
  SimulateDetection = CapriSimulateDetection
}
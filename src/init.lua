-- Capri Companion QoL: independent CET panel for the installed possession mod.
local defaults = {
  chatter = true, autoStrike = false, healing = true, bursts = true,
  portrait = true, uploadMin = 1.0, uploadMax = 3.0, safetyVersion = 2
}
local settings, overlayOpen, elapsed = {}, false, 0
local appliedSystem, dirty = nil, true
local status = "Load your save to see Capri's helpers."
local message = "Changes save automatically."
local lastError = nil

local function sanitize(raw)
  local result = {}
  raw = type(raw) == "table" and raw or {}
  for key, value in pairs(defaults) do
    if type(raw[key]) == type(value) then result[key] = raw[key]
    else result[key] = value end
  end
  for _, key in ipairs({"uploadMin", "uploadMax"}) do
    local value = result[key]
    if value ~= value or value == math.huge or value == -math.huge then value = defaults[key] end
    result[key] = math.max(0.5, math.min(5.0, value))
  end
  result.uploadMax = math.max(result.uploadMin, result.uploadMax)
  -- The old automatic force-kill version could harm mission characters.
  -- Migrate older preferences to OFF even if they previously enabled it.
  if raw.safetyVersion ~= 2 then result.autoStrike = false end
  result.safetyVersion = 2
  return result
end

local function loadSettings()
  local file = io.open("settings.json", "r")
  if not file then settings = sanitize(nil); return end
  local content = file:read("*a")
  file:close()
  local ok, raw = pcall(json.decode, content)
  settings = sanitize(ok and raw or nil)
  if not ok then message = "Settings could not be read; safe defaults are active." end
end

local function saveSettings()
  local file, err = io.open("settings.json", "w")
  if not file then error("Cannot save settings: " .. tostring(err)) end
  local ok, writeError = file:write(json.encode(settings))
  file:close()
  if not ok then error("Cannot save settings: " .. tostring(writeError)) end
end

local function context()
  local player = Game.GetPlayer()
  if not player then return nil, nil end
  local system = CapriSummonSystem.Get()
  if not system then return nil, nil end
  return player, system
end

local function apply(system)
  system:ConfigureQOL(settings.chatter, settings.autoStrike, settings.healing,
    settings.bursts, settings.portrait, settings.uploadMin, settings.uploadMax)
  dirty, appliedSystem = false, system
end

local function guarded(job)
  local ok, err = pcall(job)
  if not ok then
    message = "Capri controls are unavailable. Restart the game after installing the update."
    if lastError ~= tostring(err) then print("[Capri Companion QoL] " .. tostring(err)) end
    lastError = tostring(err)
  else lastError = nil end
end

local function changed()
  settings = sanitize(settings)
  dirty = true
  saveSettings()
  local _, system = context()
  if system then apply(system) end
  message = "Settings saved."
end

local function command(name)
  guarded(function()
    local player, system = context()
    if not player then message = "Load your save first."; return end
    if name == "regroup" then message = system:QOLRegroup(player)
    elseif name == "follow" then message = system:QOLToggleFollowing(player)
    elseif name == "talk" then message = system:QOLTalk(player) end
    status = system:QOLStatus(player)
    print("[Capri Companion] " .. tostring(message))
  end)
end

-- Inputs also work while the player is holding movement keys; no keys are stolen.
registerInput("capri_regroup", "Capri: Regroup / unstick helpers", function(pressed)
  if pressed and not overlayOpen then command("regroup") end
end)
registerInput("capri_follow", "Capri: Pause / resume following", function(pressed)
  if pressed and not overlayOpen then command("follow") end
end)
registerInput("capri_talk", "Capri: Talk to me", function(pressed)
  if pressed and not overlayOpen then command("talk") end
end)
registerInput("capri_auto_strike", "Capri: Toggle Sandevistan automatic kills", function(pressed)
  if not pressed or overlayOpen then return end
  guarded(function()
    if not Game.GetPlayer() then return end
    settings.autoStrike = not settings.autoStrike
    changed()
    message = settings.autoStrike and "Sandevistan automatic kills enabled." or "Sandevistan automatic kills disabled. Helpers still keep pace with you."
    print("[Capri Companion] " .. message)
  end)
end)

registerForEvent("onInit", function()
  guarded(loadSettings)
  if next(settings) == nil then settings = sanitize(nil) end
  print("[Capri Companion QoL] Open the CET overlay for companion controls.")
end)
registerForEvent("onOverlayOpen", function() overlayOpen = true end)
registerForEvent("onOverlayClose", function() overlayOpen = false end)
registerForEvent("onUpdate", function(dt)
  elapsed = elapsed + dt
  if elapsed < 0.5 then return end
  elapsed = 0
  guarded(function()
    local player, system = context()
    if not player then
      appliedSystem, dirty = nil, true
      status = "Load your save to see Capri's helpers."
      return
    end
    if dirty or appliedSystem ~= system or not system.qolConfigured then apply(system) end
    if overlayOpen then status = system:QOLStatus(player) end
  end)
end)

local function checkbox(label, key)
  local value, edited = ImGui.Checkbox(label, settings[key])
  if edited then settings[key] = value; changed() end
end

registerForEvent("onDraw", function()
  if not overlayOpen then return end
  local visible = ImGui.Begin("Capri Companion", ImGuiWindowFlags.AlwaysAutoResize)
  if visible then
    guarded(function()
      ImGui.Text("CAPRI // COMPANION LINK")
      ImGui.Separator()
      ImGui.TextWrapped(status)
      ImGui.Separator()
      if ImGui.Button("Regroup / unstick") then command("regroup") end
      ImGui.SameLine()
      if ImGui.Button("Pause / resume following") then command("follow") end
      if ImGui.Button("Talk to Capri") then command("talk") end
      ImGui.TextWrapped("Regroup refreshes orders on foot. Helpers finish nearby combat first.")
      ImGui.Separator()
      checkbox("Random Capri chatter (subtitles)", "chatter")
      checkbox("Overhead portraits and health bars", "portrait")
      checkbox("Helper healing (capped at 85%)", "healing")
      checkbox("Helper combat speed bursts", "bursts")
      ImGui.Separator()
      checkbox("Automatic attacks on ordinary combat enemies (OFF by default)", "autoStrike")
      ImGui.TextWrapped("Story-protected characters, allies, civilians and bosses are excluded. Force-kill fallback removed.")
      ImGui.TextWrapped("Turning automatic kills off keeps helper slow-motion immunity enabled.")
      local value, edited = ImGui.SliderFloat("Shortest upload (seconds)", settings.uploadMin, 0.5, 5.0, "%.1f")
      if edited then settings.uploadMin = value; changed() end
      value, edited = ImGui.SliderFloat("Longest upload (seconds)", settings.uploadMax, 0.5, 5.0, "%.1f")
      if edited then settings.uploadMax = value; changed() end
      ImGui.TextWrapped("Upload timing is randomized within this range, using real seconds.")
      if ImGui.Button("Restore QoL defaults") then settings = sanitize(nil); changed() end
      ImGui.Separator()
      ImGui.TextWrapped(message)
      ImGui.TextWrapped("Optional controls are listed under CET > Bindings > CapriCompanionQoL.")
    end)
  end
  ImGui.End()
end)

return { sanitize = sanitize }

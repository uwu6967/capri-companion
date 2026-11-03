param([string]$GameRoot = 'E:\SteamLibrary\steamapps\common\Cyberpunk 2077')
$ErrorActionPreference = 'Stop'
$taskRoot = (Resolve-Path -LiteralPath $GameRoot).Path
if (!(Test-Path -LiteralPath (Join-Path $taskRoot 'bin\x64\Cyberpunk2077.exe'))) {
  throw 'The selected folder is not a Cyberpunk 2077 installation.'
}
if (Get-Process -Name Cyberpunk2077 -ErrorAction SilentlyContinue) {
  throw 'Please fully quit Cyberpunk before installing this snapshot.'
}
$taskBackup = Join-Path $taskRoot ('_redscript_update\capri-qol-install-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
$taskFiles = @{
  'init.lua' = 'bin\x64\plugins\cyber_engine_tweaks\mods\CapriCompanionQoL\init.lua'
  'capri_summon.reds' = 'r6\scripts\capri_summon\capri_summon.reds'
  'CapricornDialogue.reds' = 'r6\scripts\Capricorn\CapricornDialogue.reds'
  'CapricornCall.reds' = 'r6\scripts\Capricorn\CapricornCall.reds'
  'Capricorn.yaml' = 'r6\tweaks\Capricorn.yaml'
  'Capricorn\init.lua' = 'bin\x64\plugins\cyber_engine_tweaks\mods\Capricorn\init.lua'
  'capri_possess.yaml' = 'r6\tweaks\unlimited_cyberware\capri_possess.yaml'
  'apogee_capri.yaml' = 'r6\tweaks\unlimited_cyberware\apogee_capri.yaml'
}
$taskAssets = @{
  'capri_helper_green.archive' = 'archive\pc\mod\capri_helper_green.archive'
  'capri_possession_visuals.archive' = 'archive\pc\mod\capri_possession_visuals.archive'
}
foreach ($taskName in $taskFiles.Keys) {
  $taskSource = Join-Path $PSScriptRoot ('src\' + $taskName)
  if (!(Test-Path -LiteralPath $taskSource)) { throw "Missing source file: $taskName" }
}
foreach ($taskName in $taskAssets.Keys) {
  if (!(Test-Path -LiteralPath (Join-Path $PSScriptRoot ('assets\' + $taskName)))) { throw "Missing asset: $taskName" }
}
foreach ($taskName in $taskFiles.Keys) {
  $taskRelative = $taskFiles[$taskName]
  $taskTarget = Join-Path $taskRoot $taskRelative
  if (Test-Path -LiteralPath $taskTarget) {
    $taskBackupFile = Join-Path $taskBackup $taskRelative
    New-Item -ItemType Directory -Path (Split-Path $taskBackupFile -Parent) -Force | Out-Null
    Copy-Item -LiteralPath $taskTarget -Destination $taskBackupFile
  }
  New-Item -ItemType Directory -Path (Split-Path $taskTarget -Parent) -Force | Out-Null
  Copy-Item -LiteralPath (Join-Path $PSScriptRoot ('src\' + $taskName)) -Destination $taskTarget -Force
}
foreach ($taskName in $taskAssets.Keys) {
  $taskTarget = Join-Path $taskRoot $taskAssets[$taskName]
  if (Test-Path -LiteralPath $taskTarget) {
    $taskBackupFile = Join-Path $taskBackup $taskAssets[$taskName]
    New-Item -ItemType Directory -Path (Split-Path $taskBackupFile -Parent) -Force | Out-Null
    Copy-Item -LiteralPath $taskTarget -Destination $taskBackupFile
  }
  New-Item -ItemType Directory -Path (Split-Path $taskTarget -Parent) -Force | Out-Null
  Copy-Item -LiteralPath (Join-Path $PSScriptRoot ('assets\' + $taskName)) -Destination $taskTarget -Force
}
Write-Output "Installed Capri Companion QoL. Backup: $taskBackup"
Write-Output 'Restart Cyberpunk and open the CET overlay to find Capri Companion.'

$ErrorActionPreference = 'Stop'
$taskProject = Split-Path $PSScriptRoot -Parent
$taskRoot = Join-Path ([IO.Path]::GetTempPath()) ('capri-installer-test-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $taskRoot -Force | Out-Null
# Fake prerequisites: this test never starts a game or compiler executable.
foreach ($taskFile in @('bin\x64\Cyberpunk2077.exe', 'archive\pc\mod\capricorn.archive', 'engine\tools\scc.exe', 'red4ext\plugins\Codeware\Codeware.dll', 'red4ext\plugins\TweakXL\TweakXL.dll', 'bin\x64\plugins\cyber_engine_tweaks.asi')) {
  $taskPath = Join-Path $taskRoot $taskFile
  New-Item -ItemType Directory -Path (Split-Path $taskPath -Parent) -Force | Out-Null
  [IO.File]::WriteAllText($taskPath, 'fake prerequisite')
}
$taskOldFile = Join-Path $taskRoot 'r6\scripts\capri_summon\capri_summon.reds'
New-Item -ItemType Directory -Path (Split-Path $taskOldFile -Parent) -Force | Out-Null
[IO.File]::WriteAllText($taskOldFile, 'original backup fixture')
$taskSettings = Join-Path $taskRoot 'bin\x64\plugins\cyber_engine_tweaks\mods\CapriCompanionQoL\settings.json'
New-Item -ItemType Directory -Path (Split-Path $taskSettings -Parent) -Force | Out-Null
[IO.File]::WriteAllText($taskSettings, '{"chatter":false}')
& (Join-Path $taskProject 'Install.ps1') -GameRoot $taskRoot -WhatIf
if ((Get-Content -LiteralPath $taskOldFile -Raw) -ne 'original backup fixture') { throw 'WhatIf changed a file' }
if (Test-Path -LiteralPath (Join-Path $taskRoot '_redscript_update')) { throw 'WhatIf created a backup' }
& (Join-Path $taskProject 'Install.ps1') -GameRoot $taskRoot -Confirm:$false
$taskMap = Get-Content -LiteralPath (Join-Path $taskProject 'package-map.json') -Raw | ConvertFrom-Json
foreach ($taskEntry in $taskMap.PSObject.Properties) {
  if ((Get-FileHash -LiteralPath (Join-Path $taskProject $taskEntry.Name)).Hash -ne (Get-FileHash -LiteralPath (Join-Path $taskRoot $taskEntry.Value)).Hash) { throw "Hash mismatch: $($taskEntry.Name)" }
}
if ((Get-Content -LiteralPath $taskSettings -Raw) -ne '{"chatter":false}') { throw 'Installer changed preferences' }
$taskBackups = @(Get-ChildItem -LiteralPath (Join-Path $taskRoot '_redscript_update') -Directory)
if ($taskBackups.Count -ne 1) { throw 'Expected exactly one backup' }
if ((Get-Content -LiteralPath (Join-Path $taskBackups[0].FullName 'r6\scripts\capri_summon\capri_summon.reds') -Raw) -ne 'original backup fixture') { throw 'Original file was not backed up' }
# Inject a single mid-install failure, then verify earlier overwrites roll back.
[IO.File]::WriteAllText($taskOldFile, 'rollback fixture')
$taskNewFile = Join-Path $taskRoot 'bin\x64\plugins\cyber_engine_tweaks\mods\CapriCompanionQoL\init.lua'
if (!$taskNewFile.StartsWith([IO.Path]::GetFullPath($taskRoot), [StringComparison]::OrdinalIgnoreCase)) { throw 'Invalid fixture path' }
Remove-Item -LiteralPath $taskNewFile -Force
$global:capriInstallerTestInject = $true
function Copy-Item {
  [CmdletBinding()]
  param([string]$LiteralPath, [string]$Destination, [switch]$Force)
  if ($global:capriInstallerTestInject -and $LiteralPath -eq (Join-Path $taskProject 'src\CapricornCall.reds')) {
    $global:capriInstallerTestInject = $false
    throw 'Injected installer failure'
  }
  Microsoft.PowerShell.Management\Copy-Item @PSBoundParameters
}
$taskFailureObserved = $false
try {
  & (Join-Path $taskProject 'Install.ps1') -GameRoot $taskRoot -Confirm:$false
} catch {
  if ($_.Exception.Message -notlike '*Injected installer failure*') { throw }
  $taskFailureObserved = $true
} finally {
  Remove-Item Function:\Copy-Item
  Remove-Variable -Name capriInstallerTestInject -Scope Global
}
if (!$taskFailureObserved) { throw 'Failure injection did not run' }
if ((Get-Content -LiteralPath $taskOldFile -Raw) -ne 'rollback fixture') { throw 'Rollback did not restore the old file' }
if (Test-Path -LiteralPath $taskNewFile) { throw 'Rollback did not remove a newly installed file' }
if ((Get-Content -LiteralPath $taskSettings -Raw) -ne '{"chatter":false}') { throw 'Rollback changed preferences' }
Write-Output "PASS: WhatIf, backup, installed hashes, preferences, injected-failure rollback. Fixture: $taskRoot"

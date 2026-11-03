[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
param([string]$GameRoot = 'E:\SteamLibrary\steamapps\common\Cyberpunk 2077')
$ErrorActionPreference = 'Stop'
$taskRoot = (Resolve-Path -LiteralPath $GameRoot).Path
if (!(Test-Path -LiteralPath (Join-Path $taskRoot 'bin\x64\Cyberpunk2077.exe'))) {
  throw 'The selected folder is not a Cyberpunk 2077 installation.'
}
if (Get-Process -Name Cyberpunk2077 -ErrorAction SilentlyContinue) {
  throw 'Please fully quit Cyberpunk before installing this snapshot.'
}
$taskMap = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'package-map.json') -Raw | ConvertFrom-Json
$taskPrefix = $taskRoot.TrimEnd([char[]]'\/') + [IO.Path]::DirectorySeparatorChar
$taskProjectPrefix = $PSScriptRoot.TrimEnd([char[]]'\/') + [IO.Path]::DirectorySeparatorChar
$taskPlan = @()
foreach ($taskEntry in $taskMap.PSObject.Properties) {
  $taskSource = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot $taskEntry.Name))
  $taskTarget = [IO.Path]::GetFullPath((Join-Path $taskRoot $taskEntry.Value))
  if (!$taskSource.StartsWith($taskProjectPrefix, [StringComparison]::OrdinalIgnoreCase) -or !$taskTarget.StartsWith($taskPrefix, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Package map contains a path outside the project or game root.'
  }
  if (!(Test-Path -LiteralPath $taskSource -PathType Leaf)) { throw "Missing package source: $($taskEntry.Name)" }
  $taskPlan += [pscustomobject]@{ Source = $taskSource; Target = $taskTarget; Relative = $taskEntry.Value; Existed = (Test-Path -LiteralPath $taskTarget -PathType Leaf) }
}
foreach ($taskDependency in @('archive\pc\mod\capricorn.archive', 'engine\tools\scc.exe', 'red4ext\plugins\Codeware\Codeware.dll', 'red4ext\plugins\TweakXL\TweakXL.dll', 'bin\x64\plugins\cyber_engine_tweaks.asi')) {
  if (!(Test-Path -LiteralPath (Join-Path $taskRoot $taskDependency) -PathType Leaf)) { throw "Install the original mod/framework first: $taskDependency" }
}
if (!$PSCmdlet.ShouldProcess($taskRoot, "Back up and install $($taskPlan.Count) Capri Companion files")) { return }
$taskBackup = Join-Path $taskRoot ('_redscript_update\capri-qol-install-' + (Get-Date -Format 'yyyyMMdd-HHmmss-fff'))
# Finish all backups before the first overwrite.
foreach ($taskItem in $taskPlan) {
  if ($taskItem.Existed) {
    $taskBackupFile = Join-Path $taskBackup $taskItem.Relative
    New-Item -ItemType Directory -Path (Split-Path $taskBackupFile -Parent) -Force | Out-Null
    Copy-Item -LiteralPath $taskItem.Target -Destination $taskBackupFile -Force
  }
}
$taskWritten = [Collections.Generic.List[object]]::new()
try {
  foreach ($taskItem in $taskPlan) {
    New-Item -ItemType Directory -Path (Split-Path $taskItem.Target -Parent) -Force | Out-Null
    $taskWritten.Add($taskItem)
    Copy-Item -LiteralPath $taskItem.Source -Destination $taskItem.Target -Force
    if ((Get-FileHash -LiteralPath $taskItem.Source).Hash -ne (Get-FileHash -LiteralPath $taskItem.Target).Hash) { throw "Installed file did not verify: $($taskItem.Relative)" }
  }
} catch {
  $taskInstallError = $_
  foreach ($taskItem in $taskWritten) {
    if ($taskItem.Existed) {
      Copy-Item -LiteralPath (Join-Path $taskBackup $taskItem.Relative) -Destination $taskItem.Target -Force
    } elseif (Test-Path -LiteralPath $taskItem.Target -PathType Leaf) {
      # Targets were individually validated inside the named game directory.
      Remove-Item -LiteralPath $taskItem.Target -Force
    }
  }
  throw $taskInstallError
}
Write-Output "Installed and verified $($taskPlan.Count) Capri Companion files. Backup: $taskBackup"
Write-Output 'Private test candidate. Restart Cyberpunk and test fresh possessions. Do not publish.'

param([ValidateSet('apply','restore','status')][string]$Action='status')
$ErrorActionPreference='Stop'
$adb=Join-Path $PSScriptRoot 'adb.exe'
if (!(Test-Path $adb)) { $adb='adb.exe' }
function A { $r=& $adb @args; if ($LASTEXITCODE -ne 0) { throw "ADB failed: $args" }; return ($r -join "`n").Trim() }
if ((A shell getprop ro.product.device) -ne 'gtowifi' -or (A shell getprop ro.build.version.sdk) -ne '35') { throw 'Expected gtowifi Android 15' }
$backup=Join-Path $PSScriptRoot 'wozos-ui-backup.json'
$settings=@(
@{ns='secure';key='ui_night_mode';value='2'},
@{ns='global';key='window_animation_scale';value='0.5'},
@{ns='global';key='transition_animation_scale';value='0.5'},
@{ns='global';key='animator_duration_scale';value='0.5'}
)
if ($Action -eq 'status') { A shell cmd overlay list --user 0; A shell cmd uimode night; foreach($s in $settings){ "$($s.key): $(A shell settings get $s.ns $s.key)" }; exit }
if ($Action -eq 'apply') {
if (Test-Path $backup) { throw 'Backup already exists; restore first' }
$old=@(foreach($s in $settings){ @{ns=$s.ns;key=$s.key;value=(A shell settings get $s.ns $s.key)} })
$old | ConvertTo-Json | Set-Content -Encoding UTF8 $backup
A shell cmd uimode night yes
foreach($s in $settings | Where-Object {$_.key -ne 'ui_night_mode'}) { A shell settings put $s.ns $s.key $s.value }
A shell am start -a android.intent.action.MAIN -c android.intent.category.HOME
} else {
if (!(Test-Path $backup)) { throw 'No backup found' }
foreach($s in (Get-Content -Raw $backup | ConvertFrom-Json)){
if ($s.key -eq 'ui_night_mode') {
switch ($s.value) { '0' { A shell cmd uimode night auto }; '1' { A shell cmd uimode night no }; '2' { A shell cmd uimode night yes }; default { Write-Warning 'Restore original custom night schedule manually in Settings' } }
} elseif ($s.ns -eq 'global' -and $s.key -in @('window_animation_scale','transition_animation_scale','animator_duration_scale')) {
if ($s.value -eq 'null') { A shell settings delete $s.ns $s.key } else { A shell settings put $s.ns $s.key $s.value }
}
}
}

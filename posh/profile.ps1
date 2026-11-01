$CurrentDir = $PSScriptRoot

# Set to $false to hide the git segment in the oh-my-posh prompt
$EnableGitStatus = $true

if (Get-Command starship -ErrorAction SilentlyContinue) {
  Invoke-Expression (&starship init powershell)
}

$ompConfig = "$CurrentDir\myposhconfig.json"
if (-not $EnableGitStatus) {
  # Strip the git segment from a temporary copy of the config
  $config = Get-Content $ompConfig -Raw | ConvertFrom-Json
  $config.blocks[0].segments = @($config.blocks[0].segments | Where-Object { $_.type -ne 'git' })
  $ompConfig = Join-Path $env:TEMP 'myposhconfig.nogit.json'
  $config | ConvertTo-Json -Depth 20 | Set-Content $ompConfig -Encoding utf8
}
oh-my-posh init pwsh --config $ompConfig | Invoke-Expression

Import-Module PSReadLine # Better history & completion
Set-PSReadLineOption -PredictionSource History

# Source other settings
Get-ChildItem "$CurrentDir\lib\*.ps1" | ForEach-Object { . $_.FullName }

# Source local settings
$localProfile = "$HOME\local.ps1"
if (Test-Path $localProfile) {
    . $localProfile
}

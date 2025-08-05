# Personal PowerShell profile that should be the same across all my machines
$thirdPartyModules = "PSReadLine","Microsoft.PowerShell.ConsoleGuiTools","PSFzf"

# fzf.exe is needed for PSFzf
if (!(Get-Command fzf)) {
  throw "Install fzf: choco install fzf"
}

foreach($mod in $thirdPartyModules) {
  try {
    Import-Module $mod
  } catch {
    Write-Host "Installing module: $mod"
    Install-Module $mod -ErrorAction Stop
    Import-Module $mod
  }
}

if ($host.Name -eq 'ConsoleHost')
{
    # Binding for moving through history by prefix
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

# Override PSReadLine's history search
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' `
                -PSReadlineChordReverseHistory 'Ctrl+r'

# Override default tab completion
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }

# Ensure common directories exist
foreach($dir in "$Env:UserProfile/temp","$Env:UserProfile/git") {
  New-Item -type Directory $Env:UserProfile\temp -ErrorAction Ignore | Out-Null
}
#
# My Aliases
#
Set-Alias -Force -Name l -Value Get-ChildItem

#
# Custom Functions
#

function Split-Note {
  $note = Get-ChildItem -Recurse -File -Filter '*.md' $Env:UserProfile\git\notes | Invoke-Fzf | Get-Item
  $newDir = Join-Path $note.DirectoryName $note.BaseName
  if (!(Test-Path $newDir)) {
    Write-Host "Creating $newDir"
    New-Item -Type Directory $newDir -ErrorAction Stop | Out-Null
  }
  Write-Host "Moving $($note.Name) to $newDir"
  $note | Move-Item -Destination $newDir | Out-Null
}

# Go to a directory, creating it if it does not exist
function MkCd {
  param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$path
  )
  $newDir = New-Item -Type Directory -Path $path -ErrorAction SilentlyContinue
  Set-Location $newDir
}

enum CommonDir {
  Books
  Git
  Home
  Notes
  Sidelines
  Temp
}

function G {
  param (
    [Parameter(Mandatory)]
    [CommonDir]$Dir
  )
  $dirMapping = @{
    [CommonDir]::Books = "$Env:UserProfile/books"
    [CommonDir]::Git = "$Env:UserProfile/git"
    [CommonDir]::Home = "~"
    [CommonDir]::Notes = "$Env:UserProfile/git/notes"
    [CommonDir]::Sidelines = "$Env:UserProfile/git/sidelines"
    [CommonDir]::Temp = "$Env:UserProfile/temp"
  }
  if (!$dirMapping.ContainsKey($Dir)) {
      throw "No directory configured for provided value"
  }
  Set-Location -Path $dirMapping[$Dir]
}

# Create a new GUID and put it on the clipboard
function Copy-Guid { [guid]::NewGuid() | Set-Clipboard }

# Throw if the current session isn't an admin session
function Ensure-Admin { 
  $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
  if(!($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) { throw "Run in admin shell" } 
}

enum PersonalConfig {
  GitAliases
  GitConfig
  HelixConfig
  InitLua
  Powershell
  WindowsTerminal
  Duplicati
  Win11Setup
}

function Update-Config {
  param (
    [Parameter(Mandatory)]
    [PersonalConfig[]]$Configs
  )
  $configFiles = @{
    [PersonalConfig]::Powershell = @("BaseProfile.ps1", $PROFILE.AllUsersAllHosts)
    [PersonalConfig]::Win11Setup = @("Win11Setup.ps1", "~/setup.ps1")
    [PersonalConfig]::HelixConfig = @("helix-config.toml", "$env:APPDATA/helix/config.toml")
    [PersonalConfig]::Duplicati = @("duplicati.json", "~/duplicati.json")
    [PersonalConfig]::GitAliases = @("git-aliases.ps1", "~/git-aliases.ps1")
    [PersonalConfig]::InitLua = @("init.lua", "~/AppData/Local/nvim/init.lua")
    [PersonalConfig]::GitConfig = @(".gitconfig", "~/.gitconfig")
    [PersonalConfig]::WindowsTerminal = @("terminal-settings.json", "~\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json")
  }
  Ensure-Admin
  $Configs | % {
    $config = $_
    if (!$configFiles.ContainsKey($config)) { throw "No config file configured for provided value" }
    $fileName, $outFile = $configFiles[$config]
    Write-Host "Config https://raw.githubusercontent.com/o9-9/configs/main/$fileName -> $outFile"
    New-Item -Type File -ErrorAction Ignore $outFile
    Get-Item $outFile | Copy-Item -Destination "$outFile.bak"
    Invoke-WebRequest "https://https://raw.githubusercontent.com/o9-9/configs/main/$fileName" -OutFile $outFile -Headers @{"Cache-Control" = "no-cache"}
  }
}

function Edit-Configs {
  Start-Process "https://gist.github.com/o9-9/7e7008bf4d01c315033f854e1388a27b/edit"
}

if (Test-Path ~/git-aliases.ps1) {
  . ~/git-aliases.ps1
}

# Remove Most Aliases

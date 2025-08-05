# Intended to be downloaded on a fresh Win 11 Dev VM and get it completely setup
# Set Execution Policy needs to be done before running:
# Set-ExecutionPolicy Unrestricted
param (
    [Parameter(Mandatory)]
    [string]$Username,
    [bool]$IncludeNonEssentialSoftware = $false
)

# On error we will make a case by case choice
$ErrorActionPreference = Inquire

Set-Location "C:\Users\$Username"

# Set Time Zone
Set-TimeZone -Id "Eastern Standard Time"

# VcRedist
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://vcredist.com/install.ps1'))

# Install Chocolatey
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
choco feature enable -n allowGlobalConfirmation

# Install initial choco packages
choco install -y 7zip 
choco install -y Cygwin
choco install -y Everything 
choco install -y GoogleChrome 
choco install -y KB2919355 
choco install -y KB2919442 
choco install -y KB2999226 
choco install -y KB3033929 
choco install -y KB3035131 
choco install -y SQLite 
choco install -y Wget 
choco install -y ack 
choco install -y ag 
choco install -y bat
choco install -y busybox 
choco install -y chocolatey-compatibility.extension 
choco install -y chocolatey-core.extension 
choco install -y chocolatey-windowsupdate.extension 
choco install -y cmake 
choco install -y codecov 
choco install -y cyg-get
choco install -y delta
choco install -y diffutils
choco install -y docker-desktop
choco install -y dotnet
choco install -y dotnet-script
choco install -y dotnet4.7.2
choco install -y es
choco install -y everythingtoolbar
choco install -y fd 
choco install -y fzf
choco install -y gawk
choco install -y gh
choco install -y git 
choco install -y git-lfs 
choco install -y gitextensions 
choco install -y github-desktop
choco install -y github-hovercard-chrome
choco install -y gnuwin32-coreutils.install
choco install -y graphviz 
choco install -y grep
choco install -y helix
choco install -y hxd 
choco install -y jetbrainstoolbox 
choco install -y jq 
choco install -y neovim 
choco install -y ninja 
choco install -y notepadplusplus 
choco install -y nvm
choco install -y okular
choco install -y openssh 
choco install -y osquery 
choco install -y pandoc 
choco install -y python311 
choco install -y ripgrep 
choco install -y rustup.install 
choco install -y sed
choco install -y seq
choco install -y strawberryperl 
choco install -y sysinternals 
choco install -y temurin
choco install -y vcredist140 
choco install -y vcredist2015 
choco install -y vscode 
choco install -y windirstat 
choco install -y winmerge

if ($IncludeNonEssentialSoftware) {
    Write-Information "Installing non essential software"
    choco install -y calibre
    choco install -y ffmpeg
    choco install -y gimp
    choco install -y gimp-data-extras
    choco install -y googledrive
    choco install -y imagemagick 
    choco install -y imagemagick.app 
    choco install -y irfanview
    choco install -y licecap
    choco install -y milton
    choco install -y paint.net
    choco install -y photogimp
    choco install -y qbittorrent
    choco install -y siteshoter
    choco install -y steam
    choco install -y tor-browser
    choco install -y vlc
    choco install -y zoom
}

winget install --id Microsoft.Powershell --source winget

Invoke-WebRequest https://bootstrap.pypa.io/get-pip.py -OutFile get-pip.py
python ./get-pip.py
Remove-Item -ErrorAction Ignore ./get-pip.py
Set-Alias -Name python -Value python3.11.exe
python -m pip install addict
python -m pip install aiohttp
python -m pip install arrow
python -m pip install asyncio
python -m pip install async-timeout
python -m pip install attrs
python -m pip install bashplotlib
python -m pip install backoff
python -m pip install black
python -m pip install cachetools
python -m pip install chess
python -m pip install click
python -m pip install colorama
python -m pip install coverage
python -m pip install decorator
python -m pip install deepdiff
python -m pip install docutils
python -m pip instlal dulwich
python -m pip install Faker
python -m pip install GitPython
python -m pip install graphviz
python -m pip install humanize
python -m pip install humanfriendly
python -m pip install importlib-metadata
python -m pip install ipython
python -m pip install isort
python -m pip install jedi
python -m pip install jinja2
python -m pip install mako
python -m pip install more-itertools
python -m pip install mypy
python -m pip install notebook
python -m pip install orjson
python -m pip install parsedatetime
python -m pip install pendulum
python -m pip install pillow
python -m pip install platformdirs
python -m pip install plotly
python -m pip install prettytable
python -m pip install psutil
python -m pip install pygit2
python -m pip install pytest
python -m pip install pytest-cov
python -m pip install python-dateutil
python -m pip install "python-lsp-server[all]"
python -m pip install requests
python -m pip install responses
python -m pip install scapy
python -m pip install seaborn
python -m pip install setuptools
python -m pip install semver
python -m pip install stringcase
python -m pip install structlog
python -m pip install tabulate
python -m pip install tomli
python -m pip install urllib3
python -m pip install yarl

# Set Explorer Options
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' Hidden 1
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' HideFileExt 0
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' ShowSuperHidden 1

# Setup neovim
$nvimConfDir = "C:/Users/$Username/AppData/Local/nvim"
New-Item -Type Directory -Path $nvimConfDir -ErrorAction Ignore
Invoke-WebRequest https://https://raw.githubusercontent.com/o9-9/configs/main/init.lua -OutFile "$nvimConfDir/init.lua"

# Install personal profile
New-Item -Type Directory -Path "C:\Windows\System32\WindowsPowerShell\v1.0" -ErrorAction Ignore
Invoke-WebRequest "https://https://raw.githubusercontent.com/o9-9/configs/main/BaseProfile.ps1" -OutFile $profile.AllUsersAllHosts

# Defender Exclusion
Set-MpPreference -ExclusionPath "$env:USERPROFILE/git", "$env:USERPROFILE/src"

# Add posh-git
Install-Module -Scope AllUsers posh-git
Add-PoshGitToProfile -AllHosts

# Download Jetbrains Mono
$fontArchive = "jetbrainsmono.zip"
Invoke-WebRequest "https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip" -OutFile $fontArchive
Expand-Archive $fontArchive -Destination JetBrainsMonoFont

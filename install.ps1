<#
.SYNOPSIS
  sturq's Windows tiling-desktop installer.

.DESCRIPTION
  Sets up the GlazeWM + Zebar stack to visually mirror the Sway + Waybar +
  Stylix (Catppuccin Mocha) NixOS config. Always pulls the latest published
  version of each tool via winget; symlinks configs from this repo.

  Run from an *elevated* PowerShell:

      iwr -useb https://raw.githubusercontent.com/sturq/win-glazewm/main/install.ps1 | iex

  Or clone the repo first and run locally:

      .\install.ps1
#>

[CmdletBinding()]
param(
    [string]$RepoUrl  = 'https://github.com/sturq/win-glazewm',
    [string]$RepoPath = "$env:USERPROFILE\.config\win-glazewm",
    [switch]$NoFonts,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# ─── helpers ───────────────────────────────────────────────────────────────
function Write-Step($msg)    { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)      { Write-Host "    $msg" -ForegroundColor Green }
function Write-Warn2($msg)   { Write-Host "    $msg" -ForegroundColor Yellow }
function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
function Has-Cmd($name) { [bool](Get-Command $name -ErrorAction SilentlyContinue) }

if (-not (Test-Admin) -and -not $Force) {
    throw 'Run this script from an elevated PowerShell (Run as Administrator).'
}

# ─── 1. winget bootstrap ───────────────────────────────────────────────────
Write-Step 'Checking winget'
if (-not (Has-Cmd 'winget')) {
    throw 'winget is not installed. On Windows 10+/11 install "App Installer" from the Microsoft Store.'
}
Write-Ok ('winget ' + (winget --version))

# ─── 2. Install GlazeWM + Zebar (always latest) ────────────────────────────
$pkgs = @(
    @{ id = 'glzr-io.glazewm'; name = 'GlazeWM' }
    @{ id = 'glzr-io.zebar';   name = 'Zebar'   }
)

foreach ($p in $pkgs) {
    Write-Step "Installing/upgrading $($p.name) ($($p.id))"
    winget install --id $p.id --exact --silent --accept-source-agreements --accept-package-agreements --disable-interactivity 2>&1 | Out-Null
    winget upgrade --id $p.id --exact --silent --accept-source-agreements --accept-package-agreements --disable-interactivity 2>&1 | Out-Null
    Write-Ok "$($p.name) is at the latest published version."
}

# ─── 3. Fonts: Roboto + RobotoMono Nerd (match NixOS Stylix side) ─────────
if (-not $NoFonts) {
    Write-Step 'Installing Roboto + RobotoMono Nerd Font'
    winget install --id 'Google.Roboto'             --exact --silent --accept-source-agreements --accept-package-agreements --disable-interactivity 2>&1 | Out-Null
    winget install --id 'NerdFonts.RobotoMono'      --exact --silent --accept-source-agreements --accept-package-agreements --disable-interactivity 2>&1 | Out-Null
    Write-Ok 'Roboto + RobotoMono Nerd Font ready.'
}

# ─── 4. Clone / update repo with configs ───────────────────────────────────
Write-Step "Syncing config repo → $RepoPath"
if (Test-Path $RepoPath) {
    git -C $RepoPath fetch origin --quiet
    git -C $RepoPath reset --hard origin/main --quiet
} else {
    if (-not (Has-Cmd 'git')) {
        Write-Step 'Installing git'
        winget install --id 'Git.Git' --exact --silent --accept-source-agreements --accept-package-agreements --disable-interactivity 2>&1 | Out-Null
    }
    git clone $RepoUrl $RepoPath --quiet
}
Write-Ok 'Repo synced.'

# ─── 5. Symlink configs into the expected GlazeWM / Zebar locations ────────
$links = @(
    @{ src = "$RepoPath\glazewm"; dst = "$env:USERPROFILE\.glzr\glazewm" }
    @{ src = "$RepoPath\zebar";   dst = "$env:USERPROFILE\.glzr\zebar"   }
)

foreach ($l in $links) {
    Write-Step "Linking $($l.dst) → $($l.src)"
    if (Test-Path $l.dst) {
        # Back up an existing real config once.
        $backup = "$($l.dst).pre-sturq-$(Get-Date -Format yyyyMMddHHmmss)"
        Move-Item -Force $l.dst $backup
        Write-Warn2 "Existing config backed up to $backup"
    }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $l.dst) | Out-Null
    New-Item -ItemType SymbolicLink -Path $l.dst -Target $l.src | Out-Null
    Write-Ok 'Symlink created.'
}

# ─── 6. Wallpaper = sturq base (#2A3042), accent = primary (#B9C5EE) ──────
Write-Step 'Setting wallpaper to sturq-palette primary (#B9C5EE, solid)'
Add-Type -AssemblyName System.Drawing | Out-Null
$wallpaperPath = "$env:USERPROFILE\.glzr\wallpaper.png"
$bmp = New-Object System.Drawing.Bitmap 1920, 1080
$g   = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::FromArgb(0xB9, 0xC5, 0xEE))
$bmp.Save($wallpaperPath, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class _Wp {
  [DllImport("user32.dll", CharSet=CharSet.Auto)]
  public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@ -ErrorAction SilentlyContinue
[void][_Wp]::SystemParametersInfo(20, 0, $wallpaperPath, 3)
Write-Ok "Wallpaper set: $wallpaperPath"

Write-Step 'Setting Windows accent color to sturq-palette primary (#B9C5EE)'
# Windows stores colors as 0xAABBGGRR — sturq lavender BGR = 0xEEC5B9
$dwm = 'HKCU:\Software\Microsoft\Windows\DWM'
Set-ItemProperty $dwm 'AccentColor'         -Value 0xFFEEC5B9 -Type DWord
Set-ItemProperty $dwm 'ColorizationColor'   -Value 0xFFEEC5B9 -Type DWord
Set-ItemProperty $dwm 'ColorizationAfterglow' -Value 0xFFEEC5B9 -Type DWord
Set-ItemProperty $dwm 'ColorPrevalence'     -Value 1 -Type DWord
Write-Ok 'Accent color set.'

Write-Step 'Setting lockscreen background to pure black'
$lockPath = "$env:USERPROFILE\.glzr\lockscreen.png"
$bmpL = New-Object System.Drawing.Bitmap 1920, 1080
$gL   = [System.Drawing.Graphics]::FromImage($bmpL)
$gL.Clear([System.Drawing.Color]::Black)
$bmpL.Save($lockPath, [System.Drawing.Imaging.ImageFormat]::Png)
$gL.Dispose(); $bmpL.Dispose()

$csp = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\PersonalizationCSP'
if (-not (Test-Path $csp)) { New-Item -Path $csp -Force | Out-Null }
Set-ItemProperty $csp 'LockScreenImageUrl'    -Value $lockPath
Set-ItemProperty $csp 'LockScreenImagePath'   -Value $lockPath
Set-ItemProperty $csp 'LockScreenImageStatus' -Value 1 -Type DWord
Write-Ok 'Lockscreen set to pure black.'

Write-Step 'Forcing dark theme (apps + system)'
$themes = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
Set-ItemProperty $themes 'AppsUseLightTheme'   -Value 0 -Type DWord
Set-ItemProperty $themes 'SystemUsesLightTheme' -Value 0 -Type DWord
Write-Ok 'Dark mode enforced.'

Write-Step 'Hiding all desktop icons'
$adv = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Set-ItemProperty $adv 'HideIcons' -Value 1 -Type DWord
Write-Ok 'Desktop icons hidden.'

Write-Step 'Configuring Windows Terminal — OLED-black bg + Termux/Tango colors + Roboto Mono'
$wtSettings = Get-ChildItem "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_*\LocalState\settings.json" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($wtSettings) {
    $json = Get-Content $wtSettings.FullName -Raw | ConvertFrom-Json
    $tango = @{
        name       = 'Termux-OLED'
        background = '#000000'
        foreground = '#FFFFFF'
        cursorColor= '#FFFFFF'
        selectionBackground = '#46506E'
        black   = '#000000'; red     = '#CC0000'; green = '#4E9A06'; yellow  = '#C4A000'
        blue    = '#3465A4'; purple  = '#75507B'; cyan  = '#06989A'; white   = '#D3D7CF'
        brightBlack  = '#555753'; brightRed    = '#EF2929'; brightGreen = '#8AE234'; brightYellow = '#FCE94F'
        brightBlue   = '#729FCF'; brightPurple = '#AD7FA8'; brightCyan  = '#34E2E2'; brightWhite  = '#EEEEEC'
    }
    if (-not $json.schemes) { $json | Add-Member -NotePropertyName schemes -NotePropertyValue @() -Force }
    $json.schemes = @($json.schemes | Where-Object { $_.name -ne 'Termux-OLED' }) + $tango
    if (-not $json.profiles.defaults) { $json.profiles | Add-Member -NotePropertyName defaults -NotePropertyValue @{} -Force }
    $json.profiles.defaults | Add-Member -NotePropertyName colorScheme -NotePropertyValue 'Termux-OLED' -Force
    $json.profiles.defaults | Add-Member -NotePropertyName font -NotePropertyValue @{ face = 'RobotoMono Nerd Font Mono'; size = 12 } -Force
    $json.profiles.defaults | Add-Member -NotePropertyName opacity -NotePropertyValue 100 -Force
    $json | ConvertTo-Json -Depth 32 | Set-Content $wtSettings.FullName
    Write-Ok 'Windows Terminal themed (Termux-OLED + Roboto Mono).'
} else {
    Write-Warn2 'Windows Terminal settings.json not found; open it once then re-run the installer.'
}

Write-Step 'Auto-hide taskbar'
$stuckPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'
if (Test-Path $stuckPath) {
    $stuck = (Get-ItemProperty $stuckPath).Settings
    $stuck[8] = 3   # bit flag: 3 = auto-hide enabled
    Set-ItemProperty $stuckPath 'Settings' $stuck
}
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Write-Ok 'Taskbar will auto-hide (explorer restarted).'

# ─── 7. Autostart at login ─────────────────────────────────────────────────
Write-Step 'Registering GlazeWM autostart (HKCU Run key)'
$runKey  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
$glzExe  = (Get-Command 'glazewm' -ErrorAction SilentlyContinue)?.Source
if (-not $glzExe) {
    $glzExe = Join-Path $env:LOCALAPPDATA 'Programs\GlazeWM\glazewm.exe'
}
Set-ItemProperty -Path $runKey -Name 'GlazeWM' -Value "`"$glzExe`""
Write-Ok 'GlazeWM will start on login.'

Write-Host ''
Write-Host '✓ Install complete.' -ForegroundColor Green
Write-Host '  Start now:  glazewm   (Zebar autostarts via GlazeWM startup_commands)'
Write-Host '  Re-run this script any time to pull updates.'

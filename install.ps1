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

# ─── 3. JetBrains Mono Nerd Font (matches the NixOS side via Stylix) ───────
if (-not $NoFonts) {
    Write-Step 'Installing JetBrains Mono Nerd Font'
    winget install --id 'NerdFonts.JetBrainsMono' --exact --silent --accept-source-agreements --accept-package-agreements --disable-interactivity 2>&1 | Out-Null
    Write-Ok 'JetBrains Mono Nerd Font ready.'
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

# ─── 6. Autostart at login ─────────────────────────────────────────────────
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

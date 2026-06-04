# win-glazewm

sturq's Windows tiling-desktop — same look + keybinds as the NixOS Sway+Waybar
+ Stylix (Catppuccin Mocha) setup at [sturq/nix-config](https://github.com/sturq/nix-config).

| Tool | Latest release |
|---|---|
| GlazeWM | <https://github.com/glzr-io/glazewm/releases/latest> |
| Zebar | <https://github.com/glzr-io/zebar/releases/latest> |

The installer always pulls the latest published version via winget.

---

## Install

From an **elevated PowerShell**:

```powershell
iwr -useb https://raw.githubusercontent.com/sturq/win-glazewm/main/install.ps1 | iex
```

What the script does:

1. Checks for winget (Windows 10+/11 ships it via App Installer)
2. Installs / upgrades **GlazeWM** (`glzr-io.glazewm`) to latest
3. Installs / upgrades **Zebar** (`glzr-io.zebar`) to latest
4. Installs **JetBrains Mono Nerd Font** (`NerdFonts.JetBrainsMono`)
5. Clones this repo to `%USERPROFILE%\.config\win-glazewm`
6. Symlinks `glazewm/` and `zebar/` into `%USERPROFILE%\.glzr\`
7. Adds GlazeWM to autostart (HKCU Run key)

Re-running pulls latest GlazeWM + Zebar versions and updates the repo.

---

## Hotkeys (1:1 with the NixOS Sway config)

| Hotkey | Action |
|---|---|
| **Win + Enter** | Windows Terminal |
| **Win + R** | Run / launcher |
| **Win + E** | Explorer |
| **Win + L** | Lock screen |
| **Win + Q** / **Alt + F4** | Close window |
| **Win + Tab** / **Alt + Tab** | Focus next window |
| **Win + Shift + Tab** | Focus previous window |
| **Win + 1..9** | Switch to workspace |
| **Win + Shift + 1..9** | Move window to workspace |
| **Win + ← / →** | Resize master split |
| **Win + ↑** | Toggle fullscreen |
| **Win + Space** / **Win + F** | Toggle floating |
| **Win + D** / **Win + T** | Toggle tiling direction |
| **Win + M** | Tabbed layout |
| **Win + H/J/K** | Focus left/down/up (vi-style) |
| **Win + Shift + Q** | Exit GlazeWM |

---

## Layout

```
win-glazewm/
├── install.ps1          PowerShell installer (idempotent, always-latest)
├── glazewm/
│   └── config.yaml      Keybinds + gaps + colors + workspaces
└── zebar/
    └── config.yaml      Top bar (HTML/CSS, Catppuccin Mocha, JetBrains Mono)
```

`glazewm/` symlinked to `%USERPROFILE%\.glzr\glazewm`
`zebar/` symlinked to `%USERPROFILE%\.glzr\zebar`

---

## Theme

Catppuccin Mocha — mirrors the Stylix scheme on the NixOS side so both
machines feel identical when you alt-tab between them on a KVM or RDP.

| Role | Hex | Catppuccin name |
|---|---|---|
| Background | `#1e1e2e` | base |
| Surface | `#313244` | surface0 |
| Border (focus) | `#cba6f7` | mauve |
| Border (other) | `#45475a` | surface1 |
| Text | `#cdd6f4` | text |
| Muted | `#6c7086` | overlay0 |

---

## When the NixOS Sway side changes

If keybinds, colors, workspace count, or any visible behaviour change in
[`sturq/nix-config`](https://github.com/sturq/nix-config) (`home/features/desktop/sway.nix`
or `modules/stylix.nix`), this repo gets mirrored in the same commit
window. Both sides are intentionally kept in sync.

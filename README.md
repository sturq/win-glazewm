# win-glazewm

sturq's Windows tiling-desktop — the GlazeWM + Zebar mirror of the NixOS
Sway + Waybar + Stylix setup at [`sturq/nix-config`](https://github.com/sturq/nix-config).
Same keybinds, same colors, same workflow.

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

1. Verifies winget is present (Windows 10+/11 has it via App Installer)
2. Installs / upgrades **GlazeWM** (`glzr-io.glazewm`) to latest
3. Installs / upgrades **Zebar** (`glzr-io.zebar`) to latest
4. Installs **JetBrains Mono Nerd Font** (`NerdFonts.JetBrainsMono`)
5. Clones this repo to `%USERPROFILE%\.config\win-glazewm`
   (or `git pull --hard` if it's already there)
6. Symlinks `glazewm/` and `zebar/` into `%USERPROFILE%\.glzr\`
7. **Sets the desktop wallpaper** to sturq-palette `primary` (`#B9C5EE`, solid)
8. **Sets the Windows accent color** to sturq-palette `primary` (`#B9C5EE`)
9. **Sets the lockscreen background** to pure black (`#000000`)
10. **Forces dark theme** (system + apps)
11. **Hides all desktop icons**
12. **Themes Windows Terminal** — OLED-black bg + Tango ANSI + Roboto Mono Nerd Font
13. **Enables auto-hide on the taskbar** and restarts explorer
14. Adds GlazeWM to autostart (HKCU Run key)

Re-running the script picks up the latest GlazeWM + Zebar versions and
re-syncs the repo. Safe to run any number of times.

---

## Hotkeys (1:1 with the NixOS Sway config)

| Hotkey | Action |
|---|---|
| **Win + Enter** | Windows Terminal |
| **Win + R** | Run / launcher |
| **Win + E** | Explorer |
| **Win + L** | Lock (handled natively by Windows — no GlazeWM binding needed) |
| **Win + Q** · **Alt + F4** | Close window |
| **Win + Shift + Q** | Exit GlazeWM |
| **Win + Tab** · **Alt + Tab** | Focus next window |
| **Win + Shift + Tab** | Focus previous window |
| **Win + 1..9** | Switch to workspace |
| **Win + Shift + 1..9** | Move window to workspace |
| **Win + ← / →** | Resize master split (width) |
| **Win + ↓** | Resize height |
| **Win + ↑** | Toggle fullscreen |
| **Win + Space** · **Win + F** | Toggle floating |
| **Win + D** · **Win + T** | Toggle tiling direction |
| **Win + M** | Tabbed layout |
| **Win + H/J/K** | Focus left/down/up (vi-style) |

---

## Layout

```
win-glazewm/
├── install.ps1          PowerShell installer (idempotent, always-latest,
│                        wallpaper + accent + lockscreen + autohide).
├── glazewm/
│   └── config.yaml      Keybinds + gaps + colors + workspaces.
└── zebar/
    └── config.yaml      Top bar (HTML/CSS, sturq-palette OLED, JetBrains Mono).
```

`glazewm/` is symlinked to `%USERPROFILE%\.glzr\glazewm`
`zebar/` is symlinked to `%USERPROFILE%\.glzr\zebar`

---

## Theme

[**sturq-palette OLED**](https://github.com/sturq/sturq-palette) — the same
palette is loaded into Stylix on the NixOS side, so both machines feel
identical when alt-tabbing between them on a KVM or RDP session.

| Role | Hex | sturq-palette name |
|---|---|---|
| Background | `#2A3042` | base |
| Surface | `#384058` | surface0 |
| Border (focus) | `#B9C5EE` | lavender / primary |
| Border (other) | `#46506E` | surface1 |
| Text | `#FFFFFF` | text |
| Muted | `#67739D` | overlay0 |

---

## When the NixOS Sway side changes

If keybinds, colors, workspace count, or any visible behaviour change in
[`sturq/nix-config`](https://github.com/sturq/nix-config) (`home/features/desktop/sway.nix`
or `modules/stylix.nix`), this repo gets mirrored in the same commit window.
Both sides are intentionally kept in sync.

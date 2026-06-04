# win-glazewm

sturq's Windows tiling-desktop — GlazeWM + Zebar with bindings that mirror
the Plasma + KWin side at [`sturq/nix-config`](https://github.com/sturq/nix-config).

The installer touches **nothing else on Windows** — no wallpaper, no accent
colour, no dark-mode toggle, no taskbar tweak, no Windows Terminal theming.
Pure tiler + topbar + bindings.

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
4. Installs **RobotoMono Nerd Font** (for the Zebar topbar — Nerd Font icons)
5. Clones this repo to `%USERPROFILE%\.config\win-glazewm`
   (or `git fetch + reset --hard` if it's already there)
6. Symlinks `glazewm/` and `zebar/` into `%USERPROFILE%\.glzr\`
7. Adds GlazeWM to autostart (HKCU Run key)

Re-running picks up the latest GlazeWM + Zebar versions and re-syncs the repo.

---

## Hotkeys

| Hotkey | Action |
|---|---|
| **Win + Enter** | Windows Terminal |
| **Win + R** | Run / launcher |
| **Win + E** | Explorer |
| **Win + L** | Lock (handled natively by Windows) |
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

The Plasma/KWin side at `sturq/nix-config` is configured 1:1 so muscle memory
carries between Linux and Windows.

---

## Layout

```
win-glazewm/
├── install.ps1          PowerShell installer (idempotent, always-latest).
├── glazewm/
│   └── config.yaml      Keybinds + gaps + workspaces.
└── zebar/
    └── config.yaml      Top bar (HTML/CSS).
```

`glazewm/` is symlinked to `%USERPROFILE%\.glzr\glazewm`
`zebar/` is symlinked to `%USERPROFILE%\.glzr\zebar`

---

## When the Plasma side changes

If keybinds or workspace behaviour change in [`sturq/nix-config`](https://github.com/sturq/nix-config)
(KWin shortcuts inside the Plasma config), this repo gets mirrored in the same
commit window. Both sides are intentionally kept in sync.

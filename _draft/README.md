# Draft: Dendritic Restructure

This folder contains a draft migration of the config to the dendritic pattern
using flake-parts and import-tree. Nothing here is active — it is a reference
for a potential restructure.

Read `COMPARISON.md` first for a full breakdown of the three approaches.

## File map: current → draft

```
CURRENT                               DRAFT
──────────────────────────────────────────────────────────────────────────
flake.nix (58 lines, manual)      →   flake.nix (42 lines, zero maintenance)
modules/common.nix (201 lines)    →   modules/system/core.nix
                                      modules/system/boot.nix
                                      modules/system/networking.nix
                                      modules/system/users.nix
                                      modules/system/virtualization.nix
                                      modules/desktop/hyprland.nix  (NixOS half)
                                      modules/desktop/stylix.nix    (NixOS half)
                                      modules/desktop/kanata.nix    (NixOS half)
modules/gaming.nix (72 lines)     →   modules/gaming.nix            (unchanged logic)
home.nix (625 lines)              →   modules/apps/terminal.nix
                                      modules/apps/development.nix
                                      modules/apps/media.nix
                                      modules/apps/tools.nix
                                      modules/desktop/hyprland.nix  (HM half, same file!)
                                      modules/desktop/stylix.nix    (HM half, same file!)
                                      modules/desktop/kanata.nix    (HM half, same file!)
                                      modules/desktop/waybar.nix    (not drafted, same idea)
                                      modules/desktop/rofi.nix      (not drafted)
hosts/desktop/configuration.nix  →   modules/hosts/desktop/default.nix
hosts/laptop/configuration.nix   →   modules/hosts/laptop/default.nix
```

## Key structural differences

### 1. flake.nix never changes again
Adding a new feature = add a file. `import-tree` finds it automatically.
The current `flake.nix` must be edited every time the module list changes.

### 2. Feature co-location (the main benefit)
`modules/desktop/hyprland.nix` contains:
  - `flake.modules.nixos.hyprland`  → NixOS: enable compositor, XDG portal
  - `flake.modules.homeManager.hyprland` → HM: link config files, install tools

In the current setup these are in two separate files with no obvious connection.

### 3. No extraSpecialArgs
`hostName` was passed through `extraSpecialArgs` so `home.nix` could pick
the right `monitors-<hostName>.conf`. In the draft, each host module sets
the monitor symlink directly — no magic string threading.

### 4. Host modules are first-class
Each host registers itself into `flake.nixosConfigurations` and explicitly
states what is different about it (GPU drivers, SSH keys, gaming on/off).
Everything shared is pulled in automatically via `builtins.attrValues`.

## What is not drafted

- `modules/desktop/waybar.nix` — same pattern as `hyprland.nix`, large but mechanical
- `modules/desktop/rofi.nix` — same pattern
- `modules/desktop/gtk.nix` — trivial, same pattern
- `modules/system/bluetooth.nix` — trivial
- Hardware configs — copied unchanged from `hosts/*/hardware-configuration.nix`
- `scripts.nix` — can become `modules/_lib/scripts.nix` (underscore = not imported
  by import-tree; imported explicitly from terminal.nix or tools.nix)

## New inputs needed in flake.nix

```nix
flake-parts = {
  url = "github:hercules-ci/flake-parts";
  inputs.nixpkgs-lib.follows = "nixpkgs";
};
import-tree.url = "github:vic/import-tree";
```

## Known gotchas

### gaming.nix options inside deferredModule
The `options.custom.gaming` declaration is inside `flake.modules.nixos.gaming`
(a deferredModule). This works because options and config are evaluated together
when `nixosSystem` processes the module. If you see "option not found" errors,
check that the gaming module is in `builtins.attrValues config.flake.modules.nixos`
before the host-specific config that sets `custom.gaming.enable`.

### flake.modules requires explicit import
The `flake.modules` option set (staging area) is not enabled by default in
flake-parts. You must add to flake.nix:
```nix
imports = [ inputs.flake-parts.flakeModules.modules ... ];
```
The draft flake.nix already includes this.

### home-manager wiring in host modules
`home-manager.users.elias.imports` must be set in the host module to
`builtins.attrValues config.flake.modules.homeManager`. This is the only
manual wiring step remaining. It cannot be automated without a custom
flake-parts option because home-manager needs to know the username.

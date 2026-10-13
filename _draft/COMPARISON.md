# NixOS Configuration Architecture Comparison

## Overview

Three distinct approaches to structuring a NixOS flake, from simplest to most principled.

---

## Approach 1 — Traditional (your current setup)

```
flake.nix            # All orchestration lives here
home.nix             # All home-manager config in one file (~625 lines)
modules/
  common.nix         # All shared NixOS config in one file (~200 lines)
  gaming.nix         # One well-extracted feature module
hosts/
  desktop/configuration.nix
  laptop/configuration.nix
```

### How it works

`flake.nix` manually assembles a list of modules for each host.
The `hostName` string is injected into home-manager via `extraSpecialArgs`
so that `home.nix` can pick the right monitor config.

```
flake.nix
 └─ commonModules "nixos-desktop"
     ├─ modules/common.nix          (NixOS: networking, boot, DE, packages)
     ├─ modules/gaming.nix          (NixOS: steam, gamescope, controllers)
     ├─ home-manager module
     │   └─ home.nix                (HM: shell, DE, apps, dev tools)
     └─ stylix module
```

### Advantages
- Zero extra dependencies — just nixpkgs + home-manager
- Massive community resources, examples everywhere
- Dead simple to understand end-to-end
- Clear, explicit import list in flake.nix
- Gaming module already shows the right instinct: extract a feature with options

### Disadvantages
- **Split concern problem**: Hyprland NixOS config (`programs.hyprland.enable`) is in
  `common.nix`, while Hyprland home-manager config is in `home.nix`. To understand
  "how is Hyprland set up?", you read two unrelated files.
- **`extraSpecialArgs` is an escape hatch**, not a proper interface. Values passed this
  way are not type-checked and do not participate in option merging.
- **Manual imports**: adding a new module requires editing `flake.nix` by hand. Easy
  to forget.
- **Monolithic files grow unbounded**: `common.nix` and `home.nix` will keep getting
  longer as you add features. There is no forcing function to split them.
- **All hosts share every module**: even if a module is irrelevant to a host, it is
  still evaluated (controlled only by enable options).

---

## Approach 2 — flake-parts (structured, without full dendritic)

```
flake.nix                     # ~15 lines: inputs + mkFlake + import-tree
modules/
  _imports.nix                # Registers flake-parts extras (modules class)
  hosts/
    desktop.nix               # flake-parts module: registers nixosConfigurations.nixos-desktop
    laptop.nix                # flake-parts module: registers nixosConfigurations.nixos-virgin
  system/
    boot.nix                  # NixOS module (plain)
    networking.nix            # NixOS module (plain)
    users.nix                 # NixOS module (plain)
    bluetooth.nix             # NixOS module (plain)
    virtualization.nix        # NixOS module (plain)
  desktop/
    hyprland.nix              # NixOS module (plain) — still separate from HM config
    stylix.nix                # NixOS module (plain)
  home/
    shell.nix                 # HM module (plain)
    desktop.nix               # HM module (plain)
    development.nix           # HM module (plain)
  gaming.nix                  # NixOS module with options (existing, unchanged)
```

### How it works

`flake-parts` applies the NixOS module system to the flake itself.
Each file under `modules/` is a flake-parts module. Feature modules are still
split into NixOS and home-manager halves, but at least they are small focused files.
Host modules are proper flake-parts modules that register `nixosConfigurations` entries.

```
flake.nix → mkFlake → import-tree ./modules
                          ├─ modules/system/*.nix      (NixOS modules, collected)
                          ├─ modules/desktop/*.nix     (NixOS modules, collected)
                          ├─ modules/gaming.nix        (NixOS module with options)
                          ├─ modules/home/*.nix        (HM modules, collected)
                          └─ modules/hosts/desktop.nix (registers nixosConfiguration,
                                                        imports all of the above)
```

`withSystem` in the host module provides properly scoped `pkgs` without needing
`nixpkgs.legacyPackages.${system}` hacks.

### Advantages
- `flake.nix` is minimal and never needs to change when adding features
- `import-tree` discovers files automatically — add a file, it is imported
- `withSystem` gives clean access to per-system packages
- Familiar NixOS module patterns for feature files (no new concepts needed)
- Better structure than monolithic: features are small focused files
- Host configs are first-class flake objects
- No `extraSpecialArgs` for system-level data — hosts wire things explicitly

### Disadvantages
- Still splits NixOS and home-manager config for the same feature across directories
- Requires flake-parts and import-tree as additional inputs
- flake-parts module system is a new concept to learn (though shallow)
- Home-manager integration still requires manual wiring in host modules
- Moderate learning curve compared to traditional

---

## Approach 3 — Dendritic (flake-parts + full co-location)

```
flake.nix                     # ~10 lines: inputs + mkFlake + import-tree
modules/
  _lib/
    utils.nix                 # Shared helpers (excluded from import-tree)
  hosts/
    desktop/
      default.nix             # flake-parts module: registers nixos-desktop
      hardware-configuration.nix
    laptop/
      default.nix             # flake-parts module: registers nixos-virgin
      hardware-configuration.nix
  system/
    boot.nix                  # flake-parts module → flake.modules.nixos.boot
    networking.nix            # flake-parts module → flake.modules.nixos.networking
    users.nix                 # flake-parts module → flake.modules.nixos.users
    bluetooth.nix             # flake-parts module → flake.modules.nixos.bluetooth
    virtualization.nix        # flake-parts module → flake.modules.nixos.virtualization
  desktop/
    hyprland.nix              # flake-parts module → nixos.hyprland + homeManager.hyprland
    waybar.nix                # flake-parts module → homeManager.waybar
    rofi.nix                  # flake-parts module → homeManager.rofi
    kanata.nix                # flake-parts module → nixos.kanata + homeManager.kanata
    stylix.nix                # flake-parts module → nixos.stylix + homeManager.stylix
    gtk.nix                   # flake-parts module → homeManager.gtk
  apps/
    terminal.nix              # flake-parts module → nixos.terminal + homeManager.terminal
    development.nix           # flake-parts module → homeManager.development
    media.nix                 # flake-parts module → homeManager.media
    tools.nix                 # flake-parts module → homeManager.tools
  gaming.nix                  # flake-parts module → nixos.gaming (with options)
```

### How it works

Every `.nix` file (except `flake.nix`) is a flake-parts module. Each module
contributes config to a staging area (`flake.modules.nixos.*` and
`flake.modules.homeManager.*`) using the `deferredModule` type — module definitions
stored as data, not evaluated yet. Host modules then collect all staged modules and
pass them to `nixpkgs.lib.nixosSystem`.

```
All feature files → flake.modules.nixos.X
                 → flake.modules.homeManager.X

Host file reads:
  flake.nixosConfigurations.nixos-desktop = withSystem "x86_64-linux" ({ pkgs }:
    nixpkgs.lib.nixosSystem {
      modules = [ hardware.nix ]
             ++ attrValues config.flake.modules.nixos;
      # home-manager gets: attrValues config.flake.modules.homeManager
    }
  );
```

### Advantages
- **Complete co-location**: all config for Hyprland (NixOS + home-manager) lives in
  `modules/desktop/hyprland.nix`. One file = one feature.
- **Zero manual imports**: add a file anywhere under `modules/`, it is automatically
  discovered and used. `flake.nix` never changes.
- **No `extraSpecialArgs`**: host-specific values are set directly in the host module,
  where they belong, using proper option assignments.
- **Scales perfectly**: 2 hosts → 20 hosts, 10 features → 100 features — the pattern
  does not change.
- **Uniform file shape**: every non-host file looks the same. You always know where
  to look and what structure to expect.

### Disadvantages
- **Highest learning curve**: requires understanding flake-parts modules, `deferredModule`
  type, `withSystem`, and the `flake.modules` staging convention.
- **`deferredModule` debugging is hard**: errors in deferred modules surface at evaluation
  time with less context about which file caused them.
- **Home-manager module class is not built-in**: flake-parts defines `nixos` as a
  built-in class but `homeManager` requires manual setup via `extras/modules.nix`.
- **Smaller community**: fewer examples, less Stack Overflow, more reading source code.
- **Over-engineered for small configs**: for 2 hosts and ~10 features the added
  infrastructure costs more than it saves.
- **`builtins.attrValues` ordering**: when collecting all staged modules, evaluation
  order depends on attribute name sorting — usually fine, but can surprise.

---

## Side-by-side Summary

| | Traditional | flake-parts | Dendritic |
|---|---|---|---|
| `flake.nix` size | ~60 lines, grows | ~15 lines, stable | ~10 lines, never changes |
| Adding a feature | Edit `common.nix` + `home.nix` + `flake.nix` | Add one file, possibly two | Add one file |
| NixOS + HM co-location | No — two files | No — two files | Yes — one file |
| `extraSpecialArgs` needed | Yes (hostName) | No | No |
| Learning curve | Low | Medium | High |
| Extra dependencies | None | flake-parts, import-tree | flake-parts, import-tree |
| Debugging experience | Best | Good | Harder |
| Community/examples | Huge | Medium | Small |
| Scales to many hosts | Poorly | Well | Perfectly |
| Gaming module pattern | Works | Works | Works (adapted) |

---

## Recommendation for this config

**Start with Approach 2 (flake-parts, structured).** It gives you:
- Auto-discovery (no manual import lists)
- Proper host modules
- Split `common.nix` into focused per-feature files
- No `extraSpecialArgs` hack for hostName

You can migrate to full dendritic incrementally: the two approaches are compatible,
and you can start co-locating NixOS+HM config in individual files as you feel
comfortable with `deferredModule`.

The draft files in this `_draft/` folder show the **dendritic approach** since that is
the most instructive target. Use them as a reference even if you implement Approach 2.

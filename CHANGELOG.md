# Changelog

## 2026-09-28

### Changed

- Home Manager packages on the NixOS host now come from the `nixpkgs-latest`
  application channel via `_module.args.pkgsPath`. Home Manager always reused
  the system channel before, which made `home-manager.follows` and
  `useGlobalPkgs` no-ops. Result: libation 13.5.0 → 14.2.2, calibre 9.14.0,
  firefox 156.0.1, nodejs 24.20.0, starship 1.26.0.
- `nixpkgs` 2026-07-23 → 2026-09-28 and `sops-nix` 2026-03-30 → 2026-09-27.
  Both channels have to stay on the same nixpkgs generation (Home Manager mixes
  its `lib` with `${pkgs.path}/lib`), so update them in one command:
  `nix flake update nixpkgs nixpkgs-latest`.
- `pkgsSystem` now means "the channel the system was built from" and is used
  for Plasma-dependent packages: Konsole, Yakuake and `discover`.
- Kernel 7.1 → 7.2 on the NixOS host; 7.1 reached end-of-life and was removed
  from nixpkgs.
- The deck and both macOS hosts now receive `pkgsLatest`, `pkgsSystem` and
  `sopsAgeKeyFile` as Home Manager extra args. The deck configuration could not
  be evaluated at all before.

### Fixed

- Deprecated `stdenv.isDarwin` usage in `modules/home/zsh/zsh.nix`.
- Dangling `pkgs` references in `modules/home/base.nix` left over from the
  switch to `pkgsLatest`.

### Known issues

- `nix flake check` fails on `modules/shells/iterm-automation.nix` (iTerm2 is
  aarch64-darwin only, but devShells are generated for every system).
  Pre-existing and unrelated to the above.

{ nixpkgs, system }:
nixpkgs.legacyPackages.${system}.mkShell {
  buildInputs = with nixpkgs.legacyPackages.${system}; [
    python3
    python3.pkgs.iterm2
  ];
}

{ nixpkgs, system }:
nixpkgs.legacyPackages.${system}.mkShell {
  buildInputs = with nixpkgs.legacyPackages.${system}; [
    mysql80
    postgresql
  ];
}

{ nixpkgs, system }:
nixpkgs.legacyPackages.${system}.mkShell {
  buildInputs = with nixpkgs.legacyPackages.${system}; [
    mysql84
    postgresql
  ];
}

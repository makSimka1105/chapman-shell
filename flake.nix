{
  description = "chapman-shell: Quickshell desktop shell for niri";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forSystems (pkgs: {
        default = pkgs.callPackage ./nix/package.nix { };
      });

      homeManagerModules.default = import ./nix/module.nix self;
    };
}

{
  outputs = {
    self,
    nixpkgs,
    nvfetcher,
    ...
  }: let
    forEachSystem = nixpkgs.lib.genAttrs ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
  in {
    devShells = forEachSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = pkgs.mkShell {
        buildInputs = [
          nvfetcher.packages.${system}.default
          pkgs.alejandra
          pkgs.statix
          pkgs.deadnix
        ];
      };
    });

    packages = forEachSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [self.overlays.default];
      };
    in rec {
      inherit (pkgs) mcrouter folly fizz wangle mvfst fbthrift;
      default = mcrouter;
    });

    dockerImages = let
      forEachLinuxSystem = nixpkgs.lib.genAttrs ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    in
      forEachLinuxSystem (system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [self.overlays.default];
        };
      in
        import ./images.nix {
          inherit self system pkgs;
        });

    overlays.default = import ./overlay.nix;

    formatter = forEachSystem (system: nixpkgs.legacyPackages.${system}.alejandra);
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nvfetcher = {
      url = "github:berberman/nvfetcher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}

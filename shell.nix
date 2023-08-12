{
  packages ? pkgs: [
    pkgs.alejandra
    pkgs.statix
    pkgs.deadnix
  ],
}: let
  flake = builtins.getFlake "${toString ./.}";

  pkgs = import flake.inputs.nixpkgs {};
in
  pkgs.mkShell {
    NIX_PATH = "nixpkgs=${flake.inputs.nixpkgs}";
    packages = packages pkgs;
  }

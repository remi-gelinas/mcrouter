{
  self,
  system,
  pkgs,
}: let
  mkImageFrom = let
    inherit (pkgs) mcrouter;
    bareTag = "${mcrouter.version}_${self.rev or "dirty"}";
  in
    {
      baseImage ? null,
      mkTag ? _: bareTag,
    }:
      pkgs.dockerTools.buildLayeredImage {
        fromImage = baseImage;

        name = "mcrouter";
        tag = mkTag bareTag;
        created = "now";
        contents = [mcrouter];
      };
in {
  mcrouter = {
    bare = mkImageFrom {};
    alpine = let
      source = pkgs.sources."alpine-${system}";
    in
      mkImageFrom {
        baseImage = source.src;
        mkTag = tag: "${tag}_alpine-${source.version}";
      };
  };
}

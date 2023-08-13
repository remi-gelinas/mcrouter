{
  self,
  system,
  pkgs,
}: {
  alpine = pkgs.dockerTools.streamLayeredImage {
    name = "mcrouter";
    tag = "${pkgs.mcrouter.version}-${self.rev}-alpine";
    created = "now";
    contents = [pkgs.mcrouter];
  };
}

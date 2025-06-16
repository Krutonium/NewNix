{ pkgs, ... }:
{
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/github-dark.yaml";
    targets = {
      gtk.flatpakSupport.enable = false;
    };
    opacity = {
      applications = 1.0;
      desktop = 0.7;
      popups = 0.5;
      terminal = 1.0;
    };
  };
}

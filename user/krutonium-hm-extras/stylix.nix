{ pkgs, ... }:
{
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    targets = {
      gtk.flatpakSupport.enable = false;
    };
  };
}
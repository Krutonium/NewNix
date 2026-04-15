{ pkgs, osConfig, ... }:
{
  stylix = {
    enable = true;
    base16Scheme = osConfig.stylix.base16Scheme;
    polarity = osConfig.stylix.polarity;
    targets = {
      gtk.flatpakSupport.enable = false;
    };
    opacity = {
      applications = 1.0;
      desktop = 0.7;
      popups = 0.5;
      terminal = 1.0;
    };
    iconTheme = {
      enable = true;
      package = pkgs.numix-icon-theme-circle;
      light = "Numix-Circle-Light";
      dark = "Numix-Circle-Light";
    };
    image = osConfig.stylix.image;
    targets.firefox.profileNames = [ "krutonium" ];
  };
}

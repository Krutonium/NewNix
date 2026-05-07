{ self, ... }:
{
  flake.nixosModules.stylix =
    {
      pkgs,
      config,
      ...
    }:
    {
      imports = [
        self.nixosModules.assets
      ];
      home-manager.users.krutonium.imports = [ self.homeModules.stylix ];
      stylix = {
        enable = true;
        autoEnable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/ia-dark.yaml";
        image = "${config.assets.wallpaper}";
        targets = {
          grub.enable = false;
          gnome.enable = true;
        };
        cursor = {
          name = "oreo_spark_purple_bordered_cursors";
          package = pkgs.oreo-cursors-plus;
          size = 24;
        };
        fonts = {
          monospace = {
            name = "Ubuntu Mono Regular";
            package = pkgs.ubuntu-classic;
          };
          sansSerif = {
            name = "Ubuntu";
            package = pkgs.ubuntu-classic;
          };
          serif = {
            name = "Ubuntu";
            package = pkgs.ubuntu-classic;
          };
          sizes = {
            applications = 12;
            terminal = 13;
            desktop = 10;
            popups = 10;
          };
        };
        opacity = {
          applications = 1.0;
          desktop = 0.7;
          popups = 0.5;
          terminal = 1.0;
        };
        polarity = "dark";
      };
    };
}

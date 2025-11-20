{
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.sys.desktop;
in
{
  config = mkIf (cfg.displayManager == "sddm") {
    services = {
      xserver.enable = true;
      displayManager = {
        sddm = {
          enable = true;
          wayland.enable = true;
        };
      };
    };
    systemd.tmpfiles.rules =
      let
        username = "krutonium";
      in
      [
        # Ensure SDDM .config directory exists
        "d /var/lib/sddm/.config 0755 sddm sddm -"

        # Copy KWin output config into SDDM user’s config
        # C = copy only if missing (use C! if you want forced overwrite)
        "C! /var/lib/sddm/.config/kwinoutputconfig.json 0600 sddm sddm - /home/${username}/.config/kwinoutputconfig.json"
      ];
  };
}

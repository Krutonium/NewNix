{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.sys.steam;
in
{
  config = mkIf (cfg.steam == true) {
    environment.systemPackages = with pkgs; [
      steam-run
      (steam.override {
        extraPkgs =
          pkgs:
          [
            glxinfo
            jre8
            monado
          ]
          ++ config.fonts.packages;
        extraEnv = {
          __NV_PRIME_RENDER_OFFLOAD = 1;
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
          __VK_LAYER_NV_optimus = "NVIDIA_only";
        };

      }).run
      protonup-qt
      proton-caller
      #protontricks
    ];
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      remotePlay.openFirewall = true;
      #protontricks.enable = true;
    };

    services.wivrn = {
      enable = true;
      openFirewall = true;

      # Write information to /etc/xdg/openxr/1/active_runtime.json, VR applications
      # will automatically read this and work with WiVRn (Note: This does not currently
      # apply for games run in Valve's Proton)
      defaultRuntime = true;

      # Run WiVRn as a systemd service on startup
      autoStart = true;

      # Config for WiVRn (https://github.com/WiVRn/WiVRn/blob/master/docs/configuration.md)
      config = {
        enable = true;
        json = {
          # 1.0x foveation scaling
          scale = 1.0;
          # 100 Mb/s
          bitrate = 100000000;
          encoders = [
            {
              encoder = "vaapi";
              codec = "h265";
              # 1.0 x 1.0 scaling
              width = 1.0;
              height = 1.0;
              offset_x = 0.0;
              offset_y = 0.0;
            }
          ];
        };
      };
    };
  };
}

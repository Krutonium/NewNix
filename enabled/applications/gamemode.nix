{ ... }:
{
  flake.nixosModules.gamemode =
    { lib, pkgs, ... }:
    let
      notify = lib.getExe' pkgs.libnotify "notify-send";
      dconf = lib.getExe pkgs.dconf;
      key = "/org/gnome/desktop/peripherals/touchpad/disable-while-typing";

      startScript = pkgs.writeShellScript "gamemode-start" ''
        ${dconf} write ${key} false
        ${notify} "Gamemode Started"
      '';

      endScript = pkgs.writeShellScript "gamemode-end" ''
        ${dconf} write ${key} true
        ${notify} "Gamemode Ended"
      '';
    in
    {
      programs.gamemode = {
        enable = true;
        enableRenice = true;
        settings = {
          gpu = {
            apply_gpu_optimisations = "accept-responsibility";
            gpu_device = 0;
            nv_powermizer_mode = 1;
            nv_core_clock_mhz_offset = 100;
            nv_mem_clock_mhz_offset = 100;
          };
          cpu.pin_cores = "yes";
          general = {
            desiredgov = "performance";
            igpu_desiredgov = "powersave";
            softrealtime = "on";
          };
          custom = {
            start = "${startScript}";
            end = "${endScript}";
          };
        };
      };
    };
}

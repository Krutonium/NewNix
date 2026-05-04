{ ... }:
{
  flake.nixosModules.gamemode =
    { lib, pkgs, ... }:
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
            start = "${lib.getExe' pkgs.libnotify "notify-send"} \"Gamemode Started\"";
            end = "${lib.getExe' pkgs.libnotify "notify-send"} \"Gamemode Ended\"";
          };
        };
      };
    };
}
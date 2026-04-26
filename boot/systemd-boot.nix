with lib;
with builtins;
let
  cfg = config.sys.boot;
  #mountPoint = "/boot";
  devices = "nodev";
  default = "saved";
in
{
  config = mkIf (cfg.bootloader == "systemd") {
    boot.loader = {
      efi = {
        efiSysMountPoint = cfg.uefiPath;
        canTouchEfiVariables = false; # Let it use the default paths for compat
      };
      systemd-boot = {
        enable = true;
        memtest86.enable = true;
        netbootxyz.enable = true;
      };
    };
  };
}

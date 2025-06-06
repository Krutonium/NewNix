{
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.sys.custom;
in
{
  config = mkIf (cfg.ddcutil_nvidiaFix) {
    services.xserver.config = ''
      Section "Device"
         Driver "nvidia"
         Identifier "Dev0"
         Option     "RegistryDwords"  "RMUseSwI2c=0x01; RMI2cSpeed=100"
         # solves problem of i2c errors with nvidia driver
         # per https://devtalk.nvidia.com/default/topic/572292/-solved-does-gddccontrol-work-for-anyone-here-nvidia-i2c-monitor-display-ddc/#4309293
      EndSection
    '';
  };
}

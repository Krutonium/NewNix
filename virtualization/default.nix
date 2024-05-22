{ pkgs, config, lib, ... }:
with lib;
with builtins;
{
  options.sys.virtualization = {
    server = mkOption {
      type = types.enum [ "virtd" "vbox" "vmware" "none" ];
      default = "none";
      description = ''
        VM support
      '';
    };
    windows = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Windows VM w/ GPU
      '';
    };
  };
  imports = [ ./virtd.nix ./vbox.nix ./none.nix ./WindowsVMWithGPU.nix ./vmware.nix ];
}

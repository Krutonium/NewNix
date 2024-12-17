{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.virtualization;
  # I'm going to put all the configurables in here
  # This is the device ID's of my GTX 750 Ti with it's audio device as well.
  toPassToVM_kernelcmd = "vfio-pci.ids=1002:731f,1002:ab38";
in
{
  config = mkIf (cfg.server == "windows") {
    #Disable the nouveau driver if the card is nVidia. Not sure how to handle it if there is more than one card, or one is AMD.
    boot.blacklistedKernelModules = [ "amdgpu" ];
    # If you're on Intel, you need
    # boot.kernelParams = ["intel_iommu=on"];
    # If you're on AMD, you don't need anything, it will just work.
    boot.kernelModules = [ "vfio-pci" ];
    # Add our nVidia GPU to passthrough
    boot.kernelParams = [ toPassToVM_kernelcmd ];
    environment.systemPackages = [
      #pkgs.looking-glass-client
    ];

    #systemd.services.windows = {
    #  description = "Windows Virtual Machine";
    #  serviceConfig = {
    #    Type = "simple";
    #    User = "root";
    #    Restart = "on-failure";
    #    KillSignal = "SIGINT";
    #  };
    #  wantedBy = [ "multi-user.target" ];
    #  after = [ "networking.target" ];
    #  path = [ pkgs.libvirt ];
    #  script = ''
    #    virsh start win10
    #  '';
    #  enable = false;
    #};
  };
}

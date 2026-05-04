{ inputs, self, ... }:
{
  flake.nixosConfigurations.uGamingPC = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      avahi
      boot
      common
      nvidia
      gnome
      uGamingPCModule
      stylix
      krutonium
      steam
      sops
      pipewire
      ssh
      nix-serve
      v4l2loopback
      gamemode
    ];
  };

  flake.nixosModules.uGamingPCModule =
    { pkgs, config, ... }:
    let
      initrdAvailable = [
        "xhci_pci"
        "ahci"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
      initrdRequired = [
        "nvidia"
        "nvidia_modeset"
        "nvidia_drm"
        "nvidia_uvm"
      ];
      kernelModules = [
        "kvm-amd"
        "nvidia"
        "nvidia_modeset"
        "nvidia_drm"
        "nvidia_uvm"
        "i2c-dev" # RGB
        "i2c-piix4"
      ];
      kernelModulePackages = with config.boot.kernelPackages; [
        zenpower.out
      ];
      kernelModulesBlacklist = [ ];
      kernelParams = [
        "nvidia.NVreg_EnableResizableBar=1"
        "mitigations=off"
        "acpi_enforce_resources=lax"
        "quiet"
        "splash"
      ];
      udevPackages = [
        pkgs.qmk-udev-rules
        pkgs.logitech-udev-rules
        pkgs.via
      ];
      kernel = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;

    in
    {
      # Hardware
      boot = {
        tmp.useTmpfs = false;
        initrd.availableKernelModules = initrdAvailable;
        kernelModules = kernelModules;
        kernelParams = kernelParams;
        extraModulePackages = kernelModulePackages;
        kernelPackages = kernel;
      };

      networking.hostId = "ad53f8bc";
      fileSystems = {
        "/" = {
          device = "/dev/disk/by-uuid/9ade4de4-cf0f-4852-8855-827d6034aa3a";
          fsType = "ext4";
        };
        "/boot" = {
          device = "UUID=67C9-9661";
          fsType = "vfat";
        };
        "/drives/128GSSD" = {
          device = "/dev/disk/by-uuid/97ba97b1-f9c5-4ec2-8b2f-8eaaf8c20329";
          fsType = "ext4";
        };
        "/drives/500GHDD" = {
          device = "/dev/disk/by-uuid/3e2b804b-8521-4433-97aa-5d70560802a0";
          fsType = "ext4";
        };
        "/drives/500GSSD" = {
          device = "/dev/disk/by-uuid/ebe6c0b5-2383-4c07-bc9d-184e8e669754";
          fsType = "ext4";
        };
        "/drives/2TBHDD" = {
          device = "/dev/disk/by-uuid/cd25a73a-5694-4895-af7d-f7bf2facc081";
          fsType = "ext4";
        };
        "/uWebServer" = {
          device = "krutonium@krutonium.ca:/";
          fsType = "sshfs";
          options = [
            "allow_other" # for non-root access
            "default_permissions"
            "idmap=user"
            "_netdev" # requires network to mount
            "x-systemd.automount" # mount on demand
            "uid=1002" # id -a
            "gid=100"
            "max_conns=20" # MOAR THREADS (when needed)
            "IdentityFile=/home/krutonium/.ssh/id_ed25519"
            # Handle connection drops better
            "ServerAliveInterval=2"
            "ServerAliveCountMax=2"
            "reconnect"
            "x-gvfs-show"
            "x-gvfs-name=uWebServer"
          ];
        };
        "/uServerHost" = {
          device = "root@10.3:/";
          fsType = "sshfs";
          options = [
            "allow_other" # for non-root access
            "default_permissions"
            "idmap=user"
            "_netdev" # requires network to mount
            "x-systemd.automount" # mount on demand
            "uid=1002" # id -a
            "gid=100"
            "max_conns=20" # MOAR THREADS (when needed)
            "IdentityFile=/home/krutonium/.ssh/id_ed25519"
            # Handle connection drops better
            "ServerAliveInterval=2"
            "ServerAliveCountMax=2"
            "reconnect"
            "x-gvfs-show"
            "x-gvfs-name=uServerHost"
          ];
        };
      };

      hardware.cpu.amd.updateMicrocode = true;
      programs = {
        gamemode.enable = true;
      };
      services = {
        udev.packages = udevPackages;
        hardware.openrgb = {
          enable = true;
          motherboard = "amd";
          package = pkgs.openrgb-with-all-plugins;
        };
      };
      networking = {
        hostName = "uGamingPC";
      };
      zramSwap = {
        enable = true;
        priority = 1;
      };

    };
}

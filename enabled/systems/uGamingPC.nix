{
  inputs,
  self,
  mv,
  ...
}:
{
  flake.nixosConfigurations.uGamingPC = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit mv; };
    modules = with self.nixosModules; [
      avahi
      boot
      common
      #clamav
      gnome
      #labwc
      uGamingPCModule
      stylix
      krutonium
      steam
      sops
      pipewire
      ssh
      #pinpam
      #v4l2loopback
      gamemode
      root
      #vr
      zswap
      #moonshine
      lact
      g600
      ada305
      gpu-unlock
      v4l2loopback
      wol-target
    ];
  };

  flake.nixosModules.uGamingPCModule =
    {
      pkgs,
      config,
      mv,
      ...
    }:
    let
      modProbeConfig = ''
        # IT8686E fan controller has no upstream driver; expose it as the
        # register-compatible IT8689E, and leave the IT8792E (0x4e) untouched.
        options it87 force_id=0x8689,0
      '';
      initrdAvailable = [
        "xhci_pci"
        "ahci"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
      initrdRequired = [

      ];
      kernelModules = [
        "kvm-amd"
        "i2c-dev" # RGB
        "i2c-piix4"
        "it87" # IT8686E/IT8792E fan + temperature monitoring
      ];
      kernelModulePackages = with config.boot.kernelPackages; [
        zenpower.out
      ];
      #kernelModulesBlacklist = [ ];
      kernelParams = [
        "nvidia.NVreg_EnableResizableBar=1"
        "nvidia-drm.modeset=1"
        "nvidia-drm.fbdev=1"
        "mitigations=off"
        "acpi_enforce_resources=lax"
        "drm_kms_helper.poll=0" # Fix Monitors Turning themselves back on constantly
        "udev.event-timeout=5"
        "quiet"
        "splash"
      ];
      udevPackages = [
        pkgs.qmk-udev-rules
        #pkgs.logitech-udev-rules
        pkgs.via
      ];
      kernel = mv.tip.linuxPackages_latest;
    in
    {
      sys.pinpam.backend = "device"; # hardware fTPM

      # Hardware
      boot = {
        tmp.useTmpfs = false;
        extraModprobeConfig = modProbeConfig;
        initrd.availableKernelModules = initrdAvailable;
        initrd.kernelModules = initrdRequired;
        kernelModules = kernelModules;
        kernelParams = kernelParams;
        extraModulePackages = kernelModulePackages;
        kernelPackages = kernel;
        supportedFilesystems = [ "bcachefs" ];
      };
      virtualisation.libvirtd.enable = true;
      swapDevices = [
        {
          device = "/swap";
          priority = 1;
          size = 32768;
        }
      ];
      fileSystems = {
        "/" = {
          device = "/dev/disk/by-uuid/9ade4de4-cf0f-4852-8855-827d6034aa3a";
          fsType = "ext4";
        };
        "/boot" = {
          device = "UUID=67C9-9661";
          fsType = "vfat";
        };
        "/games" = {
          device = "UUID=2f94b423-9ca0-4ad4-a351-38e4efc4e02a";
          fsType = "bcachefs";
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
      programs = {
        virt-manager.enable = true;
        gamemode.enable = true;
      };
      services = {
        xserver.videoDrivers = [ "nvidia" ];
        g600-key-remap.enable = true;
        wolTarget = {
          enable = true;
          interface = "eno1";
        };
        udev.packages = udevPackages;
        hardware.openrgb = {
          enable = true;
          motherboard = "amd";
          package = pkgs.openrgb-with-all-plugins;
          startupProfile = "Default";
        };
      };
      hardware = {
        gpuUnlock = {
          enable = true;
        };
        graphics.enable = true;
        cpu.amd.updateMicrocode = true;
        nvidia = {
          package = pkgs.nvidia-patch.auto-patch (config.boot.kernelPackages.nvidiaPackages.latest);
          open = true;
          modesetting.enable = true;
        };
      };
      nix = {
        distributedBuilds = false;
      };
      nixpkgs.config.cudaSupport = true;
      systemd.tmpfiles.rules = [
        "d /var/lib/OpenRGB 0755 root root -"
        "C+ /var/lib/OpenRGB/Default.orp 0644 root root - ${self}/enabled/assets/Default.orp"
      ];
      networking = {
        hostName = "uGamingPC";
        hostId = "2f68fbd7";
      };
    };
}

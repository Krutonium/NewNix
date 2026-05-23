{ inputs, self, ... }:
{
  flake.nixosConfigurations.uMsiLaptop = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      avahi
      boot
      common
      gnome
      uMsiLaptopModule
      stylix
      krutonium
      steam
      sops
      pipewire
      ssh
      gamemode
      root
      zswap
      simpleCpuGovernor
    ];
  };
  flake.nixosModules.uMsiLaptopModule =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      modProbeConfig = "options iwlwifi bt_corex_active=0";
      kernelModulesInitrd = [
        "i915"
        "kvm-intel"
      ];
      kernelModules = [
        "ec_sys"
        "xhci_pci"
        "ehci_pci"
        "ahci"
        "sd_mod"
        "sr_mod"
        "rtsx_pci_sdmmc"
      ];
      #kernel = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;
      kernel = pkgs.linuxPackages_zen;
      kernelParams = [
        "nouveau.config=NvClkMode=15" # Not using Nouveau ATM. Maybe someday?
        "mitigations=off"
        "loglevel=3" # Only KERN_ERR and above
        "rd.systemd.show_status=false"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
        "vt.global_cursor_default=0"
        "i915.enable_psr=0"
        "i915.enable_rc6=0"
        "quiet"
        "splash"
      ];
      btrfsDisk = "/dev/disk/by-uuid/941617ae-329b-477d-9760-09268d5cfeef";
    in
    {
      boot = {
        extraModprobeConfig = modProbeConfig;
        initrd.kernelModules = kernelModulesInitrd;
        kernelModules = kernelModules;
        kernelPackages = kernel;
        kernelParams = kernelParams;
      };
      networking = {
        hostName = "uMsiLaptop";
        hostId = "185e48db";
      };
      # Don't bother with the partial Vulkan Support on the iGPU
      environment.variables.VK_LOADER_DRIVERS_SELECT = "nvidia_*";
      systemd = {
        services = {
          "getty@tty1".enable = lib.mkDefault false;
          "autovt@tty1".enable = lib.mkDefault false;
          #"NetworkManager-wait-online".wantedBy = lib.mkForce []; # No longer blocks boot
          "NetworkManager-wait-online".enable = lib.mkForce false;
          "systemd-networkd-wait-online".enable = lib.mkForce false;
        };
        network.enable = true;
      };
      nix = {
        distributedBuilds = true;
        settings = {
          max-jobs = 0;
          builders-use-substitutes = true;
        };
        buildMachines = [
          {
            hostName = "uWebServer";
            system = "x86_64-linux";
            protocol = "ssh";
            sshUser = "krutonium"; # optional if same username
            maxJobs = 8;
            speedFactor = 5;
            supportedFeatures = [
              "nixos-test"
              "benchmark"
              "big-parallel"
              "kvm"
            ];
            systems = [
              "x86_64-linux"
              "i686-linux"
            ];
          }
          {
            hostName = "uServerHost";
            system = "x86_64-linux";
            protocol = "ssh";
            sshUser = "krutonium"; # optional if same username
            maxJobs = 16;
            speedFactor = 10;
            supportedFeatures = [
              "nixos-test"
              "benchmark"
              "big-parallel"
              "kvm"
            ];
            systems = [
              "x86_64-linux"
              "i686-linux"
            ];
          }
        ];
      };
      swapDevices = [
        {
          device = "/home/swap";
          priority = 1;
          discardPolicy = "both";
        }
      ];
      hardware.graphics.enable = true;

      # NVIDIA driver configuration
      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true; # Runtime power management (suspend/resume)
        powerManagement.finegrained = true; # Turn GPU off when not in use (requires modesetting)
        open = false; # 950M requires proprietary driver
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
        prime = {
          offload = {
            enable = true;
            enableOffloadCmd = true; # Provides `nvidia-offload` helper command
          };
          intelBusId = "PCI:0:2:0"; # Adjust to match your hardware
          nvidiaBusId = "PCI:1:0:0"; # Adjust to match your hardware
        };
      };
      nixpkgs.config.cudaSupport = false;
      services.simpleCpuGovernor = {
        target = lib.mkForce 40;
      };

      # Load nvidia driver for Xorg and Wayland
      services.xserver.videoDrivers = [
        "modesetting"
        "nvidia"
      ];

      fileSystems = {
        "/" = {
          device = "/dev/disk/by-label/root";
          fsType = "ext4";
        };
        "/boot" = {
          device = "/dev/disk/by-label/BOOT";
          fsType = "vfat";
          options = [
            "fmask=0022"
            "dmask=0022"
          ];
        };
        "/storage" = {
          device = "/dev/disk/by-uuid/3333f503-a70b-40b9-8037-8c226456bff4";
          fsType = "ext4";
          options = [
            "defaults"
            "nofail"
            "x-gvfs-show"
            "x-gvfs-name=Storage"
          ];
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
    };
}

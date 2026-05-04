{ inputs, self, ... }:
{
  flake.nixosConfigurations.uMsiLaptop = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      avahi
      boot
      common
      #nvidia-legacy
      gnome
      uMsiLaptopModule
      stylix
      krutonium
      steam
      sops
      pipewire
      ssh
      nix-serve
      gamemode
      root
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
      kernel = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;
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
        settings = {
          max-jobs = 4;
        };
      };
      zramSwap = {
        enable = true;
        priority = 1;
        writebackDevice = "/dev/disk/by-uuid/34d142d4-9274-4901-a938-2f8bcc8c8ed6";
        memoryPercent = 50;
      };
      services = {
        xserver.videoDrivers = [
          "modesetting"
          "nvidia"
        ];
      };

      hardware = {
        cpu.intel.updateMicrocode = true;
        graphics.enable = true;
        nvidia = {
          open = false; # NV110 - Not Open Supported
          package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
          prime = {
            offload = {
              enable = true;
              enableOffloadCmd = true;
            };
            nvidiaBusId = "PCI:1:0:0";
            intelBusId = "PCI:0:2:0";
          };
        };
      };

      fileSystems = {
        "/" = {
          # tmpfs root
          device = "root";
          fsType = "tmpfs";
          options = [
            "defaults"
            "mode=755"
          ];
        };
        "/tmp" = {
          device = btrfsDisk;
          fsType = "btrfs";
          options = [
            "compress=zstd:15"
            "subvol=tmp"
          ];
        };
        "/boot" = {
          device = "/dev/disk/by-uuid/1B37-4FC4";
          fsType = "vfat";
          options = [
            "fmask=0022"
            "dmask=0022"
          ];
        };
        "/nix" = {
          device = btrfsDisk;
          fsType = "btrfs";
          options = [
            "compress=zstd:15"
            "subvol=nix"
          ];
        };
        "/home" = {
          device = btrfsDisk;
          fsType = "btrfs";
          options = [
            "compress=zstd:15"
            "subvol=home"
          ];
        };
        "/etc/NetworkManager" = {
          device = btrfsDisk;
          fsType = "btrfs";
          options = [
            "compress=zstd:15"
            "subvol=networkmanager"
          ];
        };
        "/etc/ssh" = {
          device = btrfsDisk;
          fsType = "btrfs";
          options = [
            "compress=zstd:15"
            "subvol=ssh"
          ];
          neededForBoot = true;
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

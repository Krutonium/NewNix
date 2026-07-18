{ inputs, self, lib, ... }:
{
  flake.nixosConfigurations.SteamDeck = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      common
      SteamDeckModule
      boot
      inputs.jovian-nixos.nixosModules.default
      krutonium
      ssh
      gnome
      sops
    ];
  };
  flake.nixosModules.SteamDeckModule =
    { lib, ... }:
    let
      mountOptions = [
        "compress=zstd:5"
        "noatime"
        "discard=async"
      ];
    in
    {
      nixpkgs.overlays = [ inputs.self.overlays.jovian-unstable-bits ];
      boot = {
        tmp.useTmpfs = false;
      };
      services.displayManager.gdm.enable = lib.mkForce false;
      nixpkgs = {
        config = {
          allowUnfree = true;
          nvidia.acceptLicense = true;
          allowUnfreePredicate = _pkg: true;
          allowBroken = true;
          allowBrokenPredicate = _pkg: true;
          allowInsecure = true;
          allowInsecurePredicate = _pkg: true;
          permittedInsecurePackages = [
          ];
        };
      };
      disko.devices.disk = {
        root = {
          device = "/dev/disk/by-id/nvme-Phison_ESMP512GMB47C3-E13TS_22272M51234990";
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                type = "EF00";
                size = "500M";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" ];
                };
              };
              swap = {
                size = "16G";
                content = {
                  type = "swap";
                  discardPolicy = "both";
                  resumeDevice = true;
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "@" = {
                      mountpoint = "/";
                      mountOptions = mountOptions;
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = mountOptions;
                    };
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = mountOptions;
                    };
                  };
                };
              };
            };
          };
        };
      };
      jovian = {
        steam = {
          enable = true;
          autoStart = true;
          user = "krutonium";
          desktopSession = "gnome";
          updater.splash = "bgrt";
        };
        decky-loader.enable = true;
        devices.steamdeck = {
          autoUpdate = true;
          enable = true;
          enableGyroDsuService = true;
          enableVendorDrivers = true;
        };
      };
      networking.networkmanager.enable = true;
      nixpkgs.hostPlatform = {
        system = "x86_64-linux";
      };
      nix = {
        settings = {
          substituters = [
            "https://cache.krutonium.ca/KruCache"
            "https://jovian-nixos.cachix.org"
          ];
          trusted-public-keys = [
            "KruCache:iDgMvjBS9EN4/Zy3jYLFkER3UpmBw2FnYm0q9f23csw="
            "jovian-nixos.cachix.org-1:mAWLjAxLNlfxAnozUjOqGj4AxQwCl7MXwOfu7msVlAo="
          ];
        };
      };
      system.stateVersion = "26.05";
    };

}

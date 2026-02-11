{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.sys.boot;
  #mountPoint = "/boot";
  devices = "nodev";
  default = "saved";
in
{
  config = mkIf (cfg.bootloader == "uefi") {
    boot = {
      loader = {
        timeout = 1;
        efi = {
          efiSysMountPoint = cfg.uefiPath;
          canTouchEfiVariables = false; # Let it use the default paths for compat
        };
        grub = {
          timeoutStyle = "hidden";
          devices = [ devices ];
          efiSupport = true;
          efiInstallAsRemovable = true;
          configurationLimit = 5;
          useOSProber = true;
          default = default;
          enable = true;
          memtest86.enable = true;
          extraFiles = {
            "netbootxyz.efi" = "${pkgs.netbootxyz-efi}";
          };
          minegrub-world-sel = {
            enable = true;
            customIcons = [
              {
                name = "nixos";
                lineTop = "NixOS";
                lineBottom = "Survival Mode, No Cheats, Version: 25.05";
                # Icon: you can use an icon from the remote repo, or load from a local file
                imgName = "nixos";
                # customImg = builtins.path {
                #   path = ./nixos-logo.png;
                #   name = "nixos-img";
                # };
              }
              {
                name = "iPXE";
                lineTop = "NetBoot";
                lineBottom = "Permadeath, No Cheats, Version: 1.21.1";
                imgName = "uefi";
              }
              {
                name = "Memtest86+";
                lineTop = "Memory Testing";
                lineBottom = "Creative Mode, No Cheats, Version: 7.20";
              }
              {
                name = "NixOS - All Configurations";
                lineTop = "Older Generations";
                lineBottom = "Creative Mode, Cheats, Various Versions";
              }
            ];
          };
          #          theme = pkgs.fetchFromGitHub {
          #            owner = "shvchk";
          #            repo = "fallout-grub-theme";
          #            rev = "80734103d0b48d724f0928e8082b6755bd3b2078";
          #            sha256 = "sha256-7kvLfD6Nz4cEMrmCA9yq4enyqVyqiTkVZV5y4RyUatU=";
          #          };
          extraEntries = ''
            menuentry "iPXE" {
              chainloader /netbootxyz.efi
            }
          '';
        };
      };
    };
  };
}

{ config, pkgs, ... }:
{
  imports = [
    ./defaultPackages.nix
    ./boot
    ./audio
    ./desktop
    ./user
    ./services
    ./minecraft
    ./steam
    ./virtualization
    ./custom-packages
    ./scripts.nix
  ];
  boot = {
    cleanTmpDir = true;
    kernel = {
      sysctl = {
        "vm.max_map_count" = 1000000;
      };
    };
    supportedFilesystems = [ "ntfs" ]; #Add explicit NTFS support
  };
  documentation.enable = true;
  qt5.style = "adwaita-dark";
  hardware.enableAllFirmware = true;
  boot.binfmt = {
    emulatedSystems = [ "aarch64-linux" "riscv64-linux" "x86_64-windows" ];
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "@wheel" ];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
      extra-platforms = x86_64-linux i686-linux aarch64-linux riscv64-linux
    '';
    settings = {
      system-features = [ "i686-linux" "x86_64-linux" "big-parallel" ];
    };
  };
  time = {
    hardwareClockInLocalTime = true;
    timeZone = "America/Toronto";
  };
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (pkg: true);
    };
  };
  networking = {
    networkmanager = {
      enable = true;
    };
    firewall = {
      enable = true;
    };
    dhcpcd.wait = "background";
    dhcpcd.extraConfig = "noarp";
    nameservers = [
      "8.8.8.8"
      "1.1.1.1"
      "2001:4860:4860::8888"
      "2606:4700:4700::1111"
    ];
  };

  i18n = {
    defaultLocale = "en_CA.UTF-8";
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  systemd = {
    enableEmergencyMode = false;
    network = {
      wait-online = {
        anyInterface = true;
      };
    };
    services = {
      systemd-udev-settle.enable = false;
    };
  };

  services = {
    fwupd.enable = true;
  };
  programs.noisetorch.enable = true;
  systemd.extraConfig = ''
    DefaultLimitNOFILE=1048576
    DefaultTimeoutStopSec=10s
  '';
  boot.kernelParams = [ "mitigations=off" ];

  # DO NOT CHANGE THIS
  system.stateVersion = "22.05";

}

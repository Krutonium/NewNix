{
  config,
  pkgs,
  outputs,
  inputs,
  ...
}:
let
 # TODO: Figure out how the fuck sops works
in
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
    inputs.sops-nix.nixosModules.sops
    #./builders
  ];
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/krutonium/.config/sops/keys.txt";
  };

  # PAM configuration for GNOME keyring auto-unlock
  security.pam.services = {
    gdm-autologin-keyring.text = ''
      auth      optional      ${pkgs.gdm}/lib/security/pam_gdm.so
      auth      optional      ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so
    '';
  };
  # System services configuration
  services = {
    atd.enable = true;
    # CPU interrupt balancing
    irqbalance.enable = true;
    # Process scheduler for better performance
    system76-scheduler = {
      enable = true;
      settings.processScheduler = {
        pipewireBoost.enable = true;
        enable = true;
      };
      package = pkgs.system76-scheduler;
    };

    # Printer support
    printing = {
      enable = true;
      drivers = with pkgs; [ brlaser ];
    };

    # Monitor control support
    ddccontrol.enable = true;

    # Firmware update daemon
    fwupd.enable = true;

    # udev rules for disk I/O ratios
    udev.extraRules = ''
      ACTION=="add|change", SUBSYSTEM=="bdi", ATTR{min_ratio}="2", ATTR{max_ratio}="50"
    '';
  };

  # Shell configuration
  environment = {
    shellAliases = {
      ls = "${pkgs.eza}/bin/eza --icons --git";
    };
    variables = {
      NIXPKGS_ALLOW_UNFREE = "1";
      MANGOHUD = "1";
      QT_QPA_PLATFORMTHEME = "gnome";
    };
  };

  # Boot configuration
  boot = {
    # Virtual webcam support
    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];
    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    '';

    # System maintenance and kernel parameters
    tmp.cleanOnBoot = true;
    kernel.sysctl = {
      "vm.max_map_count" = 1000000;
      "vm.dirty_ratio" = "25"; # 25% of all memory optionally as write cache
      "kernel.panic" = "60";
      "kernel.perf_event_paranoid" = "1";
      "kernel.kptr_restrict" = "0";
    };
    supportedFilesystems = [ "ntfs" ]; # Add explicit NTFS support
  };

  # Security settings
  security = {
    polkit.enable = true;
    sudo.wheelNeedsPassword = false;
  };

  # Hardware configuration
  hardware = {
    enableAllFirmware = true;
    enableAllHardware = true;
    bluetooth.enable = true;
    usb-modeswitch.enable = true;
    steam-hardware.enable = true;
  };
  # Documentation
  documentation.enable = false;

  # Nix package manager configuration

  nix = {
    # access-tokens = githubKey;
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "@wheel" ];
      min-free = 50 * 1000 * 1000 * 1000; # 50GB
      system-features = [
        "i686-linux"
        "x86_64-linux"
        "big-parallel"
        "kvm"
      ];

    };
    gc = {
      automatic = true;
      options = "--delete-older-than 3d";
      dates = "weekly";
    };
    extraOptions = ''
      experimental-features = nix-command flakes
      extra-platforms = x86_64-linux i686-linux
    '';
  };

  # System time configuration
  time = {
    hardwareClockInLocalTime = true;
    timeZone = "America/Toronto";
  };

  # Package management configuration
  nixpkgs = {
    config = {
      allowUnfree = true;
      nvidia.acceptLicense = true;
      allowUnfreePredicate = pkg: true;
      allowBroken = true;
      allowBrokenPredicate = pkg: true;
      allowInsecure = true;
      allowInsecurePredicate = pkg: true;
      permittedInsecurePackages = [
        "dotnet-sdk_6" # Needed for godot4_mono
      ];
    };
  };

  # Network configuration
  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
    dhcpcd = {
      wait = "background";
      extraConfig = "noarp";
    };
    nameservers = [
      "10.0.0.1"
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  # Locale settings
  i18n.defaultLocale = "en_CA.UTF-8";

  # Systemd configuration
  systemd = {
    enableEmergencyMode = false;
    network.wait-online.anyInterface = true;
    services.systemd-udev-settle.enable = true;
    extraConfig = ''
      DefaultLimitNOFILE=1048576
      DefaultTimeoutStopSec=10s
    '';
    services.irqbalance.serviceConfig.ProtectKernelTunables = "no"; #Fix for #371415
  };

  # Program configurations
  programs = {
    noisetorch.enable = true;
    gamemode = {
      enable = true;
      enableRenice = true;
    };
    command-not-found.enable = false;
  };
  environment.gnome.excludePackages = [
    pkgs.gnome-software
    pkgs.gnome-contacts
  ];
  # System state version (DO NOT CHANGE)
  system.stateVersion = "23.11";

}

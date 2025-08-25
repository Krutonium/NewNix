{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  copy = pkgs.writeShellScriptBin "copy" ''
    mkdir -p /root/.ssh/
    cp -rav /home/krutonium/.ssh/* /root/.ssh/
    chmod 700 /root/.ssh
    chmod 600 /root/.ssh/*
    chown root /root/.ssh/ -R
  '';
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
    ./virtualization
    ./custom-packages
    ./scripts.nix
    inputs.sops-nix.nixosModules.sops
    #./builders
  ];
  systemd.services.copySshKeysForRoot = {
    description = "Copies Krutonium's SSH keys for root";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${copy}/bin/copy";
    };
    enable = true;
  };
  programs.gnupg.agent = {
    enable = true;
  };
  # https://tinted-theming.github.io/tinted-gallery/
  stylix = {
    enable = true;
    autoEnable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/ia-dark.yaml";
    targets = {
      grub.enable = false;
    };
    cursor = {
      name = "oreo_spark_purple_bordered_cursors";
      package = pkgs.oreo-cursors-plus;
      size = 10;
    };
    fonts = {
      monospace = {
        name = "Ubuntu Mono Regular";
        package = pkgs.ubuntu_font_family;
      };
      sansSerif = {
        name = "Ubuntu";
        package = pkgs.ubuntu_font_family;
      };
      serif = {
        name = "Ubuntu";
        package = pkgs.ubuntu_font_family;
      };
      sizes = {
        applications = 12;
        terminal = 13;
        desktop = 10;
        popups = 10;
      };
    };
    opacity = {
      applications = 1.0;
      desktop = 0.7;
      popups = 0.5;
      terminal = 1.0;
    };
    polarity = "dark";
  };
  programs.appimage = {
    enable = true;
    binfmt = true;
  };
  programs.direnv.enable = true;
  systemd.tmpfiles.rules =
    let
      username = "krutonium";
    in
    [
      "f+ /var/lib/AccountsService/users/${username}  0600 root root - [User]\\nIcon=/var/lib/AccountsService/icons/${username}\\n"
      "L+ /var/lib/AccountsService/icons/${username}  - - - - ${./user/${username}-hm-extras/assets/profile.png}"
    ];
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/home/krutonium/.ssh/id_ed25519" ];
    #age.keyFile = "/home/krutonium/.ssh/";
    secrets = {
      searx_secret = {
        path = "/etc/secrets/searx_secret";
      };
    };
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
      ls = "${lib.getExe pkgs.eza} --icons --git";
      cat = "${lib.getExe pkgs.bat}";
      top = "${lib.getExe pkgs.btop}";
    };
    variables = {
      NIXPKGS_ALLOW_UNFREE = "1";
      MANGOHUD = "1";
      GSK_RENDERER = "ngl";
    };
  };

  services.lvm.enable = true;
  # Boot configuration
  boot = {
    initrd.services.lvm.enable = true;
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
      # Fixes some games (Hogwarts Legacy) that just spam memory allocations.
      "vm.max_map_count" = 1000000;
      # 25% of memory can be write cache
      "vm.dirty_ratio" = 25;
      # Reboot 60 seconds after a kernel panic
      "kernel.panic" = 60;
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
    enableAllFirmware = false;
    enableAllHardware = false;
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
      require-sigs = false;
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
    registry.unstable.to = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-unstable";
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
      allowUnfreePredicate = _pkg: true;
      allowBroken = true;
      allowBrokenPredicate = _pkg: true;
      allowInsecure = true;
      allowInsecurePredicate = _pkg: true;
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
    services.irqbalance.serviceConfig.ProtectKernelTunables = "no"; # Fix for #371415
  };

  # Program configurations
  programs = {
    noisetorch.enable = true;
    gamemode = {
      enable = true;
      enableRenice = true;
      settings = {
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
          nv_powermizer_mode = 1;
          nv_core_clock_mhz_offset = 100;
          nv_mem_clock_mhz_offset = 100;
        };
        cpu = {
          pin_cores = "yes";
        };
        general = {
          desiredgov = "performance";
          igpu_desiredgov = "powersave";
          softrealtime = "on";
        };
        custom = {
          start = "${lib.getExe' pkgs.notify "notify-send"} \"Gamemode Started\"";
          end = "${lib.getExe' pkgs.notify "notify-send"} \"Gamemode Ended\"";
        };
      };
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

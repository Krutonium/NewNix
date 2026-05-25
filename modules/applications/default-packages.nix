{ ... }:
{
  flake.nixosModules.default-packages =
    { pkgs, ... }:
    {
      i18n.inputMethod.ibus.engines = with pkgs.ibus-engines; [ uniemoji ];
      environment.systemPackages = with pkgs; [
        rPackages.fontawesome
        nano
        git
        tldr
        screen
        tmux
        file
        wget
        sshfs
        usbutils
        ripgrep
        btop
        killall
        nix-index
        appimage-run
        unison
        p7zip
        pciutils
        android-tools
        nixfmt
        btrfs-progs
        cifs-utils
        nixpkgs-review
        unrar
        ncurses
        lm_sensors
        wl-clipboard
        sops
        cachix
        nh
      ];
    };
}
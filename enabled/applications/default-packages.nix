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
        appimage-run
        unison
        p7zip
        pciutils
        android-tools
        btrfs-progs
        cifs-utils
        unrar
        ncurses
        lm_sensors
        sops
        cachix
        nh
      ];
    };
}

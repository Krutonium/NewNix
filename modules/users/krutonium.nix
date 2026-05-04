{ self, ... }:
{
  flake.nixosModules.krutonium =
    { pkgs, ... }:
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
      programs.fish = {
        enable = true;
        useBabelfish = true;
      };
      users.groups.krutonium = { };
      users.users.krutonium = {
        uid = 1002;
        home = "/home/krutonium";
        isNormalUser = true;
        description = "Krutonium";
        shell = pkgs.fish;
        extraGroups = [
          "wheel"
          "networkmanager"
          "libvirtd"
          "docker"
          "deluge"
          "adbusers"
          "i2c-dev"
          "gamemode"
          "gameserver"
          "minecraft"
          "krutonium"
        ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBGydZMghVpYF+glHje55hN0/00i9nOEA+OP4A/eneXp"
        ];
        hashedPassword = "$6$l5HeZlsZILfJPHoJ$bE95YsS6Xu1kTj9RgPKpd4JblUsoA35UmCrqFdr5N71HNa3T3SA3Nw.RxT4ifqF239DzYECcyZQZQGLCtFb8W/";
      };
      home-manager.users.krutonium = {
        home = {
          stateVersion = "25.11";
          username = "krutonium";
          homeDirectory = "/home/krutonium";
          sessionVariables = {
            EDITOR = "nano";
            VISUAL = "nano";
          };
        };
        programs.home-manager.enable = true;
        imports = with self.homeModules; [
          firefox
          gnome-dconf
          git
          ssh
          terminal
          krutonium-config
          packages-desktop
          packages-server
          xdg
        ];
      };
      systemd.services.copySshKeysForRoot = {
        description = "Copies Krutonium's SSH keys for root";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${copy}/bin/copy";
        };
        enable = true;
      };
    };

}

{ self, ... }:
{
  flake.nixosModules.krutonium =
    { config, pkgs, ... }:
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
      sops.secrets.krutonium_password_hash = {
        neededForUsers = true;
      };
      users.groups.krutonium = { gid = 992; };
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
          "media"
        ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBGydZMghVpYF+glHje55hN0/00i9nOEA+OP4A/eneXp"
        ];
        hashedPasswordFile = config.sops.secrets.krutonium_password_hash.path;
      };
      home-manager.users.krutonium = {
        home = {
          enableNixpkgsReleaseCheck = false;
          stateVersion = "26.05";
          username = "krutonium";
          homeDirectory = "/home/krutonium";
          sessionVariables = {
            EDITOR = "nano";
            VISUAL = "nano";
          };
        };
        programs.home-manager.enable = true;
        targets.genericLinux.enable = true;
        imports = with self.homeModules; [
          firefox
          dynamic-apps
          gnome-dconf
          opencode
          git
          ssh
          terminal
          krutonium-config
          packages-desktop
          packages-server
          xdg
          editors
          labwc
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

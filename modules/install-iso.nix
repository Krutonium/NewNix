{ self, inputs, ... }:
{
  flake.nixosModules.minimalInstallerIso = { config, lib, pkgs, modulesPath, ... }: {
    imports = [
      (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ];

    isoImage.squashfsCompression = "zstd -Xcompression-level 6";

    networking.hostName = "krutonium-installer";
    networking.networkmanager.enable = true;

    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
      };
    };

    users.users.root.openssh.authorizedKeys.keys = [
      # Replace with your actual public key(s)
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBGydZMghVpYF+glHje55hN0/00i9nOEA+OP4A/eneXp"
    ];
    users.users.root = {
      password = "root";
      initialHashedPassword = lib.mkForce null;
    };

    # Pull from KruCache on the live ISO — publicly readable, no token needed
    nix = {
      settings = {
        substituters = [ "https://cache.krutonium.ca/KruCache" ];
        trusted-public-keys = [
          "KruCache:iDgMvjBS9EN4/Zy3jYLFkER3UpmBw2FnYm0q9f23csw="
        ];
      };
      extraOptions = ''
        experimental-features = nix-command flakes
        extra-platforms = x86_64-linux i686-linux
      '';
    };
    systemd.services.show-ip-in-issue = {
      description = "Write current IPv4 address(es) into /etc/issue";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" "network-online.target" ];
      partOf = [ "network-online.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        {
          echo "\S{PRETTY_NAME} \n \l"
          echo ""
          for ip in $(${pkgs.iproute2}/bin/ip -4 -o addr show scope global | ${pkgs.gawk}/bin/awk '{print $4}'); do
            echo "IPv4 address: $ip"
          done
          echo ""
        } > /etc/issue
      '';
    };
    systemd.network.networks."99-show-ip" = lib.mkIf config.networking.useNetworkd {
      matchConfig.Name = "*";
      linkConfig.RequiredForOnline = false;
    };
    systemd.services."show-ip-on-dhcp" = {
      description = "Refresh /etc/issue when NetworkManager reports connectivity changes";
      after = [ "NetworkManager.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.networkmanager}/bin/nmcli monitor";
        ExecStartPost = "${pkgs.systemd}/bin/systemctl start show-ip-in-issue.service";
        Restart = "always";
      };
    };

    environment.systemPackages = with pkgs; [
      git
      disko
    ];
    system.stateVersion = "26.05";
  };

  flake.nixosConfigurations.minimalInstallerIso = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [ self.nixosModules.minimalInstallerIso ];
  };
}

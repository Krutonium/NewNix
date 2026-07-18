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
    boot.zfs.forceImportRoot = true;

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

{ ... }:
{
  flake.nixosModules.nix-settings =
    { config, ... }:
    {
      nix = {
        settings = {
          require-sigs = false;
          auto-optimise-store = true;
          trusted-users = [ "@wheel" ];
          min-free = 50 * 1000 * 1000 * 1000;
          download-buffer-size = 524288000;
          connect-timeout = 1;
          download-attempts = 1;
          system-features = [
            "i686-linux"
            "x86_64-linux"
            "big-parallel"
            "kvm"
          ];
          substituters = [
            "https://cache.nixos-cuda.org"
            "https://attic.xuyh0120.win/lantian"
            "http://10.1:5000"
            "http://10.2:5000"
            "http://10.3:5000"
            "http://10.5:5000"
          ];
          trusted-public-keys = [
            "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
            "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
            "cache.krutonium.ca:bOYu3ZAbNGhhbbgFYLVy4HLApS9bVVzH2rMoGK3jl4Q="
          ];
          fallback = true;
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
          !include ${config.sops.templates."nix-access-tokens.conf".path}
        '';
      };
    };
}
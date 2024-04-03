{ config, pkgs, ... }:
{
  nix.buildMachines = [{
    hostName = "10.1";
    systems = [
      "x86_64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-linux"
      "riscv64-linux"
    ];
    protocol = "ssh-ng";
    sshUser = "krutonium";
    sshKey = "/home/krutonium/.ssh/id_ed25519";
    # if the builder supports building for multiple architectures,
    # replace the previous line by, e.g.
    # systems = ["x86_64-linux" "aarch64-linux"];
    maxJobs = 4;
    speedFactor = 2;
    supportedFeatures = [
      "nixos-test"
      "benchmark"
      "big-parallel"
      "kvm"
    ];
    mandatoryFeatures = [ ];
  }];
  nix.distributedBuilds = true;
  # optional, useful when the builder has a faster internet connection than yours
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
}

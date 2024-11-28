{ config, pkgs, ... }:
let
  sshr = pkgs.writeShellScriptBin "sshr" ''
    ssh $@
    until !!; do sleep 5 ; done
  '';
  updateindex = pkgs.writeShellScriptBin "updateindex" ''
    mkdir -p ~/.cache/nix-index && cd ~/.cache/nix-index
    wget -N https://github.com/Mic92/nix-index-database/releases/latest/download/index-x86_64-linux -O files
    echo Update Complete.
  '';
  why-installed = pkgs.writeShellScriptBin "why-installed" ''
    nix-store --query --referrers $(nix-instantiate '<nixpkgs>' -A $1)
  '';
  where-installed = pkgs.writeShellScriptBin "where-installed" ''
    nix eval --json "/home/krutonium/NixOS/.#nixosConfigurations.$(hostname).options.environment.systemPackages.files" | jq -r ".[]" | xargs rg $1
  '';
  zink = pkgs.writeShellScriptBin "zink" ''
    MESA_LOADER_DRIVER_OVERRIDE=zink $@
  '';
  
  # Define reusable scripts for common operations.
  # Define common_git script
  common_git = pkgs.writeShellScriptBin "common_git" ''
    set -e
    cd ~/NixOS

    # Stash changes if necessary
    git diff --quiet || git stash save "Pre Pull" --include-untracked

    # Check if there are uncommitted changes to commit and push
    if ! git diff --cached --quiet || ! git diff --quiet; then
      git add .
      git commit -m "Auto-commit before pull" || true
      git push || true
    fi

    # Check for new changes to pull
    if git fetch && ! git diff --quiet HEAD..origin/$(git rev-parse --abbrev-ref HEAD); then
      git pull --rebase || true
    fi

    # Attempt to reapply stashed changes if there were any
    git stash list | grep -q "Pre Pull" && git stash pop || true
  '';

  # Define garbage_collect script
  garbage_collect = pkgs.writeShellScriptBin "garbage_collect" ''
    sudo nix-collect-garbage --delete-older-than 7d --log-format bar-with-logs
    nix-collect-garbage --delete-older-than 7d --log-format bar-with-logs
  '';

  # Define nupdate script
  update = pkgs.writeShellScriptBin "nupdate" ''
    set -e
    ${common_git}
    # Update the flake and push changes
    nix flake update --commit-lock-file || true
    git push || true
  '';

  # Define nswitch script
  switch = pkgs.writeShellScriptBin "nswitch" ''
    set -e
    ${common_git}
    # Rebuild and switch configuration
    sudo nixos-rebuild --flake .#$(uname -n) switch
    ${garbage_collect}
  '';

  # Define nboot script
  boot = pkgs.writeShellScriptBin "nboot" ''
    set -e
    ${common_git}
    # Rebuild and apply boot configuration
    sudo nixos-rebuild --flake .#$(uname -n) boot
    ${garbage_collect}
  '';

  # Define ncommit script
  commit = pkgs.writeShellScriptBin "ncommit" ''
    set -e
    cd ~/NixOS

    # Commit and push changes
    git add .
    git commit || true
    git push || true
  '';

  relinkrepo = pkgs.writeShellScriptBin "relinkrepo" ''
    cd ~/NixOS
    git remote set-url origin forgejo@gitea.krutonium.ca:Krutonium/NixOS.git
  '';
  explain = pkgs.writeShellScriptBin "explain" ''
    ${pkgs.unstable.gh}/bin/gh explain "$@"
  '';
  help = pkgs.writeShellScriptBin "help" ''
    ${pkgs.unstable.gh}/bin/gh suggest "$@"
  '';

in
{
  environment.systemPackages = [
    sshr
    updateindex
    why-installed
    where-installed
    pkgs.jq
    pkgs.git
    zink
    update
    switch
    boot
    commit
    relinkrepo
    explain
    help
  ];
}

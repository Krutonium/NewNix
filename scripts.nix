{ config, pkgs, ... }:
let
  # Helper script to retry SSH connections
  sshr = pkgs.writeShellScriptBin "sshr" ''
    ssh $@
    until !!; do sleep 5 ; done
  '';

  # Update nix-index database from GitHub
  updateindex = pkgs.writeShellScriptBin "updateindex" ''
    mkdir -p ~/.cache/nix-index && cd ~/.cache/nix-index
    wget -N https://github.com/Mic92/nix-index-database/releases/latest/download/index-x86_64-linux -O files
    echo Update Complete.
  '';

  # Show what packages depend on a given package
  why-installed = pkgs.writeShellScriptBin "why-installed" ''
    nix-store --query --referrers $(nix-instantiate '<nixpkgs>' -A $1)
  '';

  # Search for where a package is referenced in the config
  where-installed = pkgs.writeShellScriptBin "where-installed" ''
    nix eval --json "/home/krutonium/NixOS/.#nixosConfigurations.$(hostname).options.environment.systemPackages.files" | jq -r ".[]" | xargs rg $1
  '';

  # Run a program using Zink OpenGL driver
  zink = pkgs.writeShellScriptBin "zink" ''
    MESA_LOADER_DRIVER_OVERRIDE=zink $@
  '';

  # Helper script for common git operations
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

  # Clean up old nix generations
  garbage_collect = pkgs.writeShellScriptBin "garbage_collect" ''
    sudo nix-collect-garbage --delete-older-than 7d --log-format bar-with-logs
    nix-collect-garbage --delete-older-than 7d --log-format bar-with-logs
  '';

  # Update flake inputs
  update = pkgs.writeShellScriptBin "nupdate" ''
    set -e
    ${common_git}/bin/common_git
    cd ~/NixOS
    nix flake update --commit-lock-file || true
    git push || true
  '';

  # Rebuild and switch to new configuration
  switch = pkgs.writeShellScriptBin "nswitch" ''
    set -e
    ${common_git}/bin/common_git
    cd ~/NixOS
    sudo nixos-rebuild --flake .#$(uname -n) switch
    ${garbage_collect}/bin/garbage_collect
  '';

  # Rebuild configuration for next boot
  boot = pkgs.writeShellScriptBin "nboot" ''
    set -e
    ${common_git}/bin/common_git
    cd ~/NixOS
    sudo nixos-rebuild --flake .#$(uname -n) boot
    ${garbage_collect}/bin/garbage_collect
  '';

  # Commit and push changes to git
  commit = pkgs.writeShellScriptBin "ncommit" ''
    set -e
    cd ~/NixOS
    git add .
    git commit || true
    git pull || true
    git push || true
    git pull || true
    git push || true
  '';

  # Update git remote URL
  relinkrepo = pkgs.writeShellScriptBin "relinkrepo" ''
    cd ~/NixOS
    git remote set-url origin forgejo@gitea.krutonium.ca:Krutonium/NixOS.git
  '';

  # GitHub CLI explain command wrapper
  explain = pkgs.writeShellScriptBin "explain" ''
    ${pkgs.unstable.gh}/bin/gh explain "$@"
  '';

  # GitHub CLI suggest command wrapper  
  help = pkgs.writeShellScriptBin "help" ''
    ${pkgs.unstable.gh}/bin/gh suggest "$@"
  '';
  zink-run = pkgs.writeShellScriptBin "zink-run" ''
    env __GLX_VENDOR_LIBRARY_NAME=mesa __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json MESA_LOADER_DRIVER_OVERRIDE=zink GALLIUM_DRIVER=zink
  '';

in
{
  environment.systemPackages = [
    zink-run
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

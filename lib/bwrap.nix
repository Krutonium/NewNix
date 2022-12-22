{ lib, pkgs, ... }:

with builtins;
with lib;

# NOTE:
# A fake dbus like this Will hide tray and fix some issues,
# but some apps will keep running in backgroud
#
# fake_dbus =
#   if fake_dbus then "export $(dbus-launch)" else "";

{
  bwrapIt = (
    { name
    , package
    , args ? ''"$@"''
    , exec ? "bin/${name}"
    , binds ? [ ] # [string] | [{from: string; to: string;}]
    , ro_binds ? [ ] # [string] | [{from: string; to: string;}]
    , unshare ? "--unshare-all"
    , dri ? false # video acceleration
    , dev ? false # Vulkan support / devices usage
    , xdg ? false
    , net ? false
    , tmp ? false # some tray icons needs it
    , custom_config ? [ ]
      # Fixes "cannot set terminal process group (-1)" but is
      # not recommended because of a security issue with TIOCSTI [1]
      # [1] - https://wiki.archlinux.org/title/Bubblewrap#New_session
    , keep_session ? false
    }:
    let
      # Normalizes to [{from: string; to: string;}]
      _normalize_binds = map
        (x:
          if x ? to && x ? from
          then x
          else { to = x; from = x; });

      # Bwrap can't bind symlinks correctly, it needs canonicalized paths [1]
      # `readlink -m` solves this issue
      # [1] - https://github.com/containers/bubblewrap/issues/195
      _rw_binds = pipe binds [
        _normalize_binds
        (map (x: ''--bind-try $(readlink -mn ${x.from}) ${x.to}''))
        (concatStringsSep " \\\n")
      ];

      _default_ro_binds = [
        "~/.config/dconf"
        "~/.config/gtk-3.0/settings.ini"
        "~/.config/gtk-4.0/settings.ini"
        "~/.gtkrc-2.0"
      ];

      _ro_binds = pipe (ro_binds ++ _default_ro_binds) [
        _normalize_binds
        (map (x: ''--ro-bind-try $(readlink -mn ${x.from}) ${x.to}''))
        (concatStringsSep " \\\n")
      ];

      # mkdir -p (only if bwrap is on the name)
      _mkdir = pipe binds [
        _normalize_binds
        (map (x: if isList (match ".*(bwrap).*" x.from) then "mkdir -p ${x.from}" else ""))
        (concatStringsSep "\n")
      ];

      _dev_or_dri =
        if dri || dev then
          (if dev then
            "--dev-bind /dev /dev"
          else
            "--dev /dev --dev-bind /dev/dri /dev/dri")
        else "--dev /dev";

      _xdg = if xdg then "--bind $XDG_RUNTIME_DIR $XDG_RUNTIME_DIR" else "";
      _net = if net then "--share-net" else "";
      _tmp = if tmp then "--bind /tmp /tmp" else "--tmpfs /tmp";
      _new_session = if keep_session then "" else "--new-session";
      _custom_config = concatStringsSep " " custom_config;
    in
    #
      # bind /bin for using xdg-open (eg: telegram) and
      # to fix sh and bash for some scripts
      #
      # NOTE: Remember to follow the binding order from ~/
      # eg: ~/ ~/.config ~/.config/*
      #
    pkgs.writeScriptBin name ''
      #! ${pkgs.stdenv.shell} -e
      ${_mkdir}
      exec -a "$0" ${lib.getBin pkgs.bubblewrap}/bin/bwrap \
        --ro-bind /run /run \
        --ro-bind /bin/sh /bin/sh \
        --ro-bind /bin/sh /bin/bash \
        --ro-bind /etc /etc \
        --ro-bind /nix /nix \
        --ro-bind /sys /sys \
        --ro-bind /var /var \
        --ro-bind /usr /usr \
        --proc /proc \
        --tmpfs /home \
        --die-with-parent \
        ${_new_session} \
        ${unshare} \
        ${_dev_or_dri} \
        ${_xdg} \
        ${_net} \
        ${_tmp} \
        ${_rw_binds} \
        ${_ro_binds} \
        ${_custom_config} \
        ${lib.getBin package}/${exec} ${args}
    ''
  );

  #fhsIt = (
  #  { name
  #  , runScript ? "bash"
  #  , targetPkgs ? (pkgs: [ ])
  #  }:
  #  (bwrapIt {
  #    name = name;
  #    package =
  #      (pkgs.buildFHSUserEnvBubblewrap {
  #        name = name;
  #        runScript = runScript;
  #        targetPkgs = targetPkgs;
  #        extraBwrapArgs = [
  #          "--tmpfs /home"
  #          "--bind-try ~/bwrap/android ~/"
  #          "--new-session"
  #        ];
  #      });
  #  })
  #);
}

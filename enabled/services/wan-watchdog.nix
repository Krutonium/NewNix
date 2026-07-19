{ ... }: {
  flake.nixosModules.wan-watchdog = { config, pkgs, lib, ... }: {
    options.services.wan-watchdog.interface = lib.mkOption {
      type = lib.types.str;
      description = "WAN interface name to check for existence.";
    };

    config = {
      systemd.services.wan-watchdog = {
        description = "Reboot if WAN interface is not present after boot";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = false;
          ExecStartPre = "${pkgs.coreutils}/bin/sleep 120";
          ExecStart = pkgs.writeShellScript "wan-watchdog" ''
            IFACE="${config.services.wan-watchdog.interface}"
            if ${pkgs.iproute2}/bin/ip link show "$IFACE" > /dev/null 2>&1; then
              echo "WAN interface $IFACE is present, all good."
            else
              echo "WAN interface $IFACE not found 2 minutes after boot — rebooting."
              ${pkgs.systemd}/bin/systemctl reboot
            fi
          '';
        };
      };
    };
  };
}
{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.sys.custom;
in
{
  config = mkIf (cfg.ddcutil == true) {
    environment.systemPackages = [ pkgs.ddcutil ];
    hardware.i2c.enable = true;
    services.udev.extraRules = ''
      # Assigns the i2c devices to group i2c, and gives that group RW access:
      # KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
      # Gives everyone RW access to the /dev/i2c devices:
      KERNEL=="i2c-[0-9]*",  MODE="0666"

      # ==== #

      # Rules for USB attached monitors, which are categorized as User Interface Devices.

      # The following example rules assign USB connected monitors to group video, and give RW permission
      # to users in that group.  Alternatively, you can give everyone RW permission for monitor devices by
      # changing 'MODE="0660", GROUP="video"' to 'MODE="0666"'.

      # Use ddcutil to check if a USB Human Interface Device appears to be a monitor.
      # Note this rule will have to be adjusted to reflect the actual path where ddcutil is installed.
      # The -v option produces informational messages.  These are lost when the rule is normally executed
      # udev, but can be helpful when rules are tested using the "udevadm test" command.
      SUBSYSTEM=="usbmisc",  KERNEL=="hiddev*", PROGRAM="${pkgs.ddcutil}/usr/bin/ddcutil chkusbmon $env{DEVNAME} -v", MODE="0660", GROUP="video"

      # Identifies a particular monitor device by its vid/pid.
      # The values in this example are for an Apple Cinema Display, model A1082.
      # SUBSYSTEM=="usbmisc", ATTRS{idVendor}=="05ac", ATTRS{idProduct}=="9223",  MODE="0666"
    '';
  };
}

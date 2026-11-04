{ inputs, ... }:
{
  flake.nixosModules.ada305 =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        inputs.ada305.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
      services.udev.extraRules = ''
        # Altec Lansing ADA305 speakers (ada305 CLI)
        SUBSYSTEM=="usb", ATTR{idVendor}=="04d2", ATTR{idProduct}=="0305", MODE="0660", TAG+="uaccess"
      '';
    };
}

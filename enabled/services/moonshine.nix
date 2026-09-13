{ inputs, ... }:
{
  flake.nixosModules.moonshine =
    { lib, ... }:
    let
    in
    {
      imports = [ inputs.moonshine.nixosModules.default ];
      virtualisation.vmVariant = {
        services.moonshine.enable = lib.mkForce false;
      };
      services.moonshine = {
        enable = true;
        user = "krutonium";
        openFirewall = true;
        settings = {
          application = [
            {
              title = "Steam";
              command = [
                "/run/current-system/sw/bin/steam"
                "steam://open/bigpicture"
              ];
            }
          ];
        };
      };
    };
}

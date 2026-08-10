{ inputs, ... }:
{
  flake.nixosModules.moonshine =
    { ... }:
    let
    in
    {
      imports = [ inputs.moonshine.nixosModules.default ];
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

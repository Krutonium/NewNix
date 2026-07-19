{ ... }:
{
  flake.nixosModules.ssh =
    { ... }:
    {
      services.openssh = {
        enable = true;
        openFirewall = true;
        ports = [ 22 ];
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
          X11Forwarding = true;
        };
        extraConfig = ''
          Match Address  10.0.0.*
              PermitRootLogin yes
        '';
      };

      services.sshguard = {
        enable = true;
        whitelist = [ "10.0.0.0/16" ];
      };

      programs.mosh.enable = true;
      programs.mosh.openFirewall = true;
    };
}
{ ... }:
{
  flake.nixosModules.nginxAuth =
    { config, lib, ... }:
    let
      cfg = config.sys.nginxAuth;

      sites = lib.filterAttrs (_: users: users != [ ]) cfg.sites;

      # Sites with the same set of users share one rendered htpasswd file.
      templateName = users:
        "htpasswd-${lib.concatStringsSep "+" (lib.sort builtins.lessThan (lib.unique users))}";

      userSets = lib.unique (lib.attrValues sites);
      templates = lib.listToAttrs
        (map (users: lib.nameValuePair (templateName users) users) userSets);

      allUsers = lib.unique (lib.concatLists (lib.attrValues sites));
    in
    {
      options.sys.nginxAuth.sites = lib.mkOption {
        type = lib.types.attrsOf (lib.types.listOf lib.types.str);
        default = { };
        example = {
          "gryphon.krutonium.ca" = [ "krutonium" "gryphon" ];
          "nevvy.krutonium.ca" = [ "nevvy" ];
        };
        description = ''
          nginx virtual hosts protected by HTTP basic auth, mapped to the
          htpasswd users allowed in. Each user's crypt(3) password hash lives
          at the sops key `htpasswd/<user>`.
        '';
      };

      config = lib.mkIf (sites != { }) {
        # Individual hashes stay root-only; only the rendered files are
        # readable by nginx.
        sops.secrets = lib.genAttrs (map (user: "htpasswd/${user}") allUsers) (_: { });

        sops.templates = lib.mapAttrs (_: users: {
          owner = "nginx";
          group = "nginx";
          mode = "0440";
          content = lib.concatMapStringsSep "\n"
            (user: "${user}:${config.sops.placeholder."htpasswd/${user}"}")
            (lib.unique users);
        }) templates;

        services.nginx.virtualHosts = lib.mapAttrs
          (vhost: users: {
            basicAuthFile = config.sops.templates.${templateName users}.path;
          })
          sites;
      };
    };
}

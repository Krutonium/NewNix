# TPM-backed PIN for interactive logins only: console (login) and GNOME
# (gdm-password includes `auth substack login`). No sudo/polkit/screen unlock.
{ inputs, ... }:
{
  flake.nixosModules.pinpam =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.sys.pinpam;
    in
    {
      imports = [ inputs.pinpam.nixosModules.default ];

      options.sys.pinpam.backend = lib.mkOption {
        type = lib.types.enum [
          "device"
          "swtpm"
        ];
        default = "device";
        description = ''
          TPM backend for pinpam. `device` uses the machine's hardware TPM.
          `swtpm` runs a software TPM exposed through the kernel vTPM proxy,
          so pinpam still uses /dev/tpmrm0 and normal udev permissions.
        '';
      };

      config = lib.mkMerge [
        {
          security.pinpam = {
            enable = true;
            pinPolicy  = {
              minLength = 4;
              maxLength = 6;
              maxAttempts = 5;
            };
            auth = {
              enable = true;
              services = [
                "sudo"
                "login"
              ];
            };
            masterKey = {
              enable = true;
              services.login = {
                enable = true;
                # Auth methods whose success should route into the master-key stage.
                # Each is copied into the decision substack as `sufficient` and disabled
                # in the parent stack. List exactly the methods you use; add network /
                # identity methods (e.g. "systemd_home", "ldap", "sss") here too.
                successRules = [
                  "pinpam"
                  "unix"
                ];
                # Keyring rules moved to run after master-key so they capture the
                # stamped token. Defaults to the common keyring/secret modules.
                postAuthRules = [
                  "kwallet"
                  "gnome_keyring"
                  "gnupg"
                ];
              };
            };
          };
        }

        (lib.mkIf (cfg.backend == "swtpm") {
          # The vTPM proxy needs this module to create /dev/tpmrm0.
          boot.kernelModules = [ "tpm_vtpm_proxy" ];

          systemd.services.swtpm = {
            description = "Software TPM 2.0 (vTPM proxy) for pinpam";
            wantedBy = [ "multi-user.target" ];
            before = [
              "display-manager.service"
              "getty@tty1.service"
            ];
            serviceConfig = {
              Type = "simple";
              ExecStart = lib.mkForce (
                "${pkgs.swtpm}/bin/swtpm chardev --vtpm-proxy --tpm2"
                + " --tpmstate dir=/var/lib/swtpm"
                + " --flags not-need-init,startup-clear"
                + " --ctrl type=unixio,path=/run/swtpm/ctrl,mode=0600,uid=0,gid=0"
              );
              StateDirectory = "swtpm";
              RuntimeDirectory = "swtpm";
              RuntimeDirectoryMode = "0700";
              Restart = "on-failure";
            };
          };
        })
      ];
    };
}

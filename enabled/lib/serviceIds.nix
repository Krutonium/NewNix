# Pinned IDs for service accounts that own persistent data (subvolumes under
# /var/lib, /media2, /persist). Values match the live uWebServer allocation so
# that pinning them changes nothing today; it just stops future config changes
# or a fresh /var/lib/nixos from reallocating IDs out from under existing files.
#
# Accounts already pinned elsewhere:
#   krutonium 1002 / 992   (enabled/users/krutonium.nix)
#   kea       1001         (enabled/users/kea.nix)
#   gryphon   1000         (enabled/users/gryphon.nix)
#   nevvy     1003         (enabled/users/nevvy.nix)
#   media     989          (enabled/common.nix)
#   plex      193 / 193    (enabled/services/plex.nix)
#   rtorrent  990 / 990    (enabled/services/rtorrent.nix)
# nginx (60), postgres (71) and matrix-synapse (224) come from nixpkgs' ids.nix.
{ ... }:
{
  flake.nixosModules.userIds =
    { ... }:
    {
      users.users = {
        acme.uid = 999;
        forgejo.uid = 995;
        jellyfin.uid = 993;
        nextcloud.uid = 991;
      };
      users.groups = {
        acme.gid = 999;
        forgejo.gid = 994;
        nextcloud.gid = 988;
      };
    };
}

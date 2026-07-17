# Guide

What is found where?

 ### /applications
 This contains lists of applications and configuration for them, things that aren't services, and should be shared between hosts.
 ### /assets
 This contains all the assets, things like fonts, wallpapers, etc.
 ### /audio
 This contains the configuration for Audio - At the time of writing, it's just pipewire with some overrides to fix some issues, and add noice cancelling.
 ### /desktop
 This contains the configuration for the desktop environment - At this time, Gnome. It only contains the base configuration though, as actual customization is handled by the user via home manager.
 ### /overlays
 This contains overlays for nixpkgs; things like importing the nixos-unstable channel as `pkgs.unstable.` and adding extra packages to `pkgs` - Like the Hytale Launcher.
 ### /secrets
 This contains a SOPS file for storing secrets. Used whenever I need to store sensitive information.
 ### /services
 This contains the configuration for services, MOSTLY used on uWebServer, but not always. I'm defining services here as software with an expected long life time, and not as software that is only used once or occasionally.
 ### /systems
 This contains the configuration for the systems themselves. At the time of writing, there is four systems defined. They each have a `nixosSystem` function that defines the system, which is just a series of modules, including a module that's also defined in that same file, which defined the hardware and any single use configuration.
 ### /users
 This contains the configuration for users. Inside it, where applicable, there is also a `username-hm` folder, which contains that users home manager configuration.
 ### ./boot.nix
 This is, quite simply, the universal bootloader configuration.
 ### ./common.nix
 This is the common configuration for all systems. Things that are truly universal for all systems. It also imports imports that need to exist for all as well, and makes sure that overlays are applied.
 
Build install ISO with `nix build .#nixosConfigurations.minimalInstallerIso.config.system.build.isoImage`
# Guide

What is found where?

### /core
Universal/foundational system configuration shared by all hosts (`boot.nix`, `common.nix`, `nix-settings.nix`).

### /applications
This contains lists of applications and configuration for them, things that aren't services, and should be shared between hosts.

### /assets
This contains all the assets, things like fonts, wallpapers, etc.

### /audio
This contains the configuration for Audio - At the time of writing, it's just pipewire with some overrides to fix some issues, and add noice cancelling.

### /desktop
This contains the configuration for the desktop environment - At this time, Gnome. It only contains the base configuration though, as actual customization is handled by the user via home manager.

### /hardware
Hardware enablement and hardware-related daemons/integrations (GPU unlock, LACT, input devices, VR).

### /lib
Shared libraries/data/helpers used across the configuration.

### /modules
Custom Nix modules/extensions (not just nixpkgs overlays).

### /networking
Networking-focused services and configuration (mDNS/Avahi, DDNS, routing).

### /overlays
This contains overlays for nixpkgs. Could be anything.

### /secrets
This contains a SOPS file for storing secrets. Used whenever I need to store sensitive information.

### /security
Security-related configuration (host keys).

### /services
This contains the configuration for services, MOSTLY used on uWebServer, but not always. I'm defining services here as software with an expected long life time, and not as software that is only used once or occasionally.

### /systems
This contains the configuration for the systems themselves. At the time of writing, there is four systems defined. They each have a `nixosSystem` function that defines the system, which is just a series of modules, including a module that's also defined in that same file, which defined the hardware and any single use configuration.

### /users
This contains the configuration for users. Inside it, where applicable, there is also a `username-hm` folder, which contains that users home manager configuration.

Build install ISO with `nix build .#nixosConfigurations.minimalInstallerIso.config.system.build.isoImage` (moved to `enabled/systems/`).

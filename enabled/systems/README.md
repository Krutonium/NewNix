# Systems

NixOS system configurations for each host. Each host defines a `nixosSystem` assembled from shared modules plus its own hardware/single-use configuration module in the same file.

## Files

- `uGamingPC.nix` - Gaming desktop (AMD/NVIDIA, VR, gaming stack)
- `uMsiLaptop.nix` - MSI laptop configuration
- `uServerHost.nix` - Server host configuration
- `uWebServer.nix` - Web server configuration

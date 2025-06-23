# My NixOS Config

## A Note for GitHub: 

If you're viewing this on GitHub, this is a mirror from my personal Forgejo/Gitea instance. It should be up to date to within 6 hours of my latest changes.
# What is this?

An evolution of my previous config, this repo represents my current NixOS configuration across my machines. It is a work in progress, and I am still learning NixOS, so there are likely to be some mistakes.

Realistically though, it should be easy enough for anyone to learn from and use as reference.


Each directory, where appropriate, should contain a README.md file with more information about the contents of that directory.

## How does it all work?

First, we start in the flake. This is the entry point for NixOS. It contains the following:

 - A general definition that fits all devices
 - A definition for each device that imports and customizes that general definition

From there, each device calls it's own `devices/<device>.nix` file, which contains the following:

 - Device Specific Configuration such as 
   - Kernel, 
   - Bootloader, 
   - Services, 
   - Hostname,
   - Hardware Quirks.
 - Imports the Users
    - And specifies if they should have Home Manager enabled.

Finally, once that's all done, You've basically already traversed most of the config! Feel free to explore and ask questions!

## How do the modules work?

Basically, inside of `common.nix`, I import each directory where I've put a module. Each module contains a `default.nix` file, which then defines properties and so on for what I want available. For example in `desktop` you can pick between Gnome, KDE and Budgie, as well as decide if you want Wayland (if it's supported).
This allows for a lot of flexability and a huge amount of code-reuse. I encourage others to copy this design and use it for their own configs.


## Extra Note:
Cachix for this is available at:
`https://myflake.cachix.org`
with key
`myflake.cachix.org-1:KlIcGPe6D7DUHGBw+2nycRaSlJXilMBQpbIeiL7w5eQ=`
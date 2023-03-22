# My New NixOS Config

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
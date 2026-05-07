# Welcome to Version 3 of my NixOS configuration!

In this iteration, I've re-written my NixOS configuration in a more modular way.
This time, I am using flake-parts, instead of my previous approach of using honestly quite brittle `options` - which required a LOT of boilerplate.

In my flake, I am making use of 2 different modules to make everything smooth, one already mentioned:
 - [Flake Parts](https://flake.parts/), which allows me to easily define my config as a collection of modules that can be assembled like lego blocks.
 - [Import Tree](https://github.com/denful/import-tree), which in essence makes sure all .nix files within /modules are in scope, without needing to explicitly import them.

With that combination, whenever I want to add a new module, be it a service, a desktop environment, or a system configuration, I can just add a new module to /modules and it will automatically be picked up by flake-parts.
This is a huge time saver, and I can not understate how much easier it is to maintain than my previous approach.

It also means that if you see a module that you'd like in your configuration, you should, with minimum difficulty, be able to copy and paste it into your own configuration, barring hardcoded or otherwise incorrect values for your exact system.

If you're viewing this on GitHub, please be aware that this is a MIRROR from my personal git repository, located [here](https://git.krutonium.ca/Krutonium/NixOS).

My previous configuration can be found [here](https://git.krutonium.ca/Krutonium/NixOS/src/branch/legacy).

A guide to exploring my configuration can be found [here](./modules/guide.md).

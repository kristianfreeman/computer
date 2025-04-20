# Gamedev machine role configuration
{ config, pkgs, ... }:

{
  homebrew.casks = [
    "blender"
    "unity-hub"
  ];

  homebrew.masApps = {};
  environment.systemPackages = [];
}

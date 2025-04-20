# Gamedev machine role configuration
{ config, pkgs, ... }:

{
  homebrew.brews = [
    "git-lfs"
  ];

  homebrew.casks = [
    "blender"
    "unity-hub"
  ];

  homebrew.masApps = {};
  environment.systemPackages = [];
}

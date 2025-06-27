# Gamedev machine role configuration
{ config, pkgs, ... }:

{
  homebrew.brews = [
  ];

  homebrew.casks = [
    "steam"
  ];

  environment.systemPackages = [];
}

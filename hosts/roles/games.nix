# Gamedev machine role configuration
{ config, pkgs, ... }:

{
  homebrew.brews = [
  ];

  homebrew.casks = [
    "steam"
    "steam-link"
  ];

  environment.systemPackages = [];
}

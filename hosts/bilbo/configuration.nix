{ config, pkgs, ... }:

let 
in
{
  imports = [
    ../darwin-common.nix
    ../darwin-homebrew.nix
    ../roles/development.nix
    ../roles/games.nix
    ../roles/media.nix
  ];

  homebrew.brews = [
    "handbrake"
  ];

  homebrew.casks = [
    "anki"
    "bambu-studio"
    "capcut"
    "ledger-live"
    "steam"
    "unity-hub"
  ];

  environment.systemPackages = [
    pkgs.consul
  ];
}

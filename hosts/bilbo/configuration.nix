{ config, pkgs, ... }:

let 
in
{
  # Import common macOS configuration
  imports = [
    ../darwin-common.nix
    ../darwin-homebrew.nix
    ../roles/development.nix
    ../roles/gamedev.nix
    ../roles/media.nix
  ];

  # Host-specific overrides and additions
  
  # Host-specific additional Nix packages
  environment.systemPackages = [
    pkgs.consul
  ];

  # Host-specific additional Homebrew casks
  homebrew.casks = [
    "bambu-studio"
    "capcut"
    "ledger-live"
    "steam"
  ];
}

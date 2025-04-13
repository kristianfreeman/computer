{ config, pkgs, ... }:

let 
in
{
  # Import common macOS configuration
  imports = [
    ../darwin-common.nix
    ../darwin-homebrew.nix
    ../roles/development.nix
  ];

  # Host-specific overrides and additions
  
  # Host-specific Homebrew casks
  homebrew.casks = [
    "boltai"
    "flux"
    "kitty"
    "macwhisper"
    "mochi"
    "plexamp"
    "screen-studio"
  ];
}
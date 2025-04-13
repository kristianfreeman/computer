{ config, pkgs, ... }:

let 
in
{
  # Import common macOS configuration
  imports = [
    ../darwin-common.nix
    ../darwin-homebrew.nix
    ../roles/music.nix
  ];

  # Host-specific overrides and additions
  
  # Host-specific Homebrew casks
  homebrew.casks = [
    "karabiner-elements"
    "kitty"
  ];
}
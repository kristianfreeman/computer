{ config, pkgs, ... }:

let 
in
{
  # Import common macOS configuration
  imports = [
    ../darwin-common.nix
    ../darwin-homebrew.nix
    ../roles/development.nix
    ../roles/games.nix
    ../roles/media.nix
    ../roles/music.nix
  ];

  # Host-specific overrides and additions
  
  # Host-specific Homebrew brews
  homebrew.brews = [
    "handbrake"
    "libpq"
    "libusb"
  ];

  # Host-specific Homebrew casks
  homebrew.casks = [
    "battle-net"
    "ledger-live"
    "musicbrainz-picard"
    "parsec"
  ];

  # Host-specific Nix packages
  environment.systemPackages = [
    pkgs.goku
    pkgs.imagemagick
    pkgs.ruby_3_3
  ];
}

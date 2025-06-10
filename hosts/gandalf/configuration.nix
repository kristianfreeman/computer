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
    ../roles/music.nix
  ];

  # Host-specific overrides and additions
  
  # Host-specific Homebrew brews
  homebrew.brews = [
    "libpq"
    "libusb"
  ];

  # Host-specific Homebrew casks
  homebrew.casks = [
    "battle-net"
    "ledger-live"
    "musicbrainz-picard"
    "parsec"
    "plex-media-server"
  ];

  # Host-specific Mac App Store apps
  homebrew.masApps = {
    FinalCutPro = 424389933;
    MacFamilyTree = 1567970985;
    Parcel = 639968404;
  };
  
  # Host-specific Nix packages
  environment.systemPackages = [
    pkgs.goku
    pkgs.imagemagick
    pkgs.ruby_3_3
  ];
}

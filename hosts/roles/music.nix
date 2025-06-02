# Music production role configuration
{ config, pkgs, ... }:

{
  # Music production tools via Homebrew
  homebrew.casks = [
    "ableton-live-suite"
    "native-access"
    "rekordbox"
    "splice"
  ];
  
  # Music production tools via Nix
  environment.systemPackages = [
    pkgs.id3v2
    pkgs.juce
  ];
}

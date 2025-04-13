# Media machine role configuration
{ config, pkgs, ... }:

{
  # Media tools via Homebrew
  homebrew.casks = [
    "audacity"
    "calibre"
    "macwhisper"
    "plexamp"
    "sonos"
    "splice"
    "spotify"
    "transmission"
    "ultimate-vocal-remover"
    "vlc"
  ];
  
  # Media-focused Mac App Store apps
  homebrew.masApps = {
    PixelmatorPro = 1289583905;
  };
  
  # Media tools via Nix
  environment.systemPackages = [
    pkgs.ffmpeg
    pkgs.imagemagick
  ];
}

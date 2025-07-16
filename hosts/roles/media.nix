# Media machine role configuration
{ config, pkgs, ... }:

{
  # Media tools via Homebrew
  homebrew.casks = [
    "audacity"
    "calibre"
    "feishin"
    "macwhisper"
    "plexamp"
    "sonos"
    "splice"
    "spotify"
    "transmission"
    "ultimate-vocal-remover"
    "vlc"
  ];

  # Media tools via Nix
  environment.systemPackages = [
    pkgs.ffmpeg
    pkgs.imagemagick
    pkgs.stig
  ];
}

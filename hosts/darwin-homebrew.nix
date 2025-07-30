# Common Homebrew configuration for macOS systems
{ config, pkgs, ... }@args:

{
  # Install homebrew if not yet installed
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "kristian";
  };

  # Common Homebrew configuration
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";

    # Common brews across all macs (can be overridden in host-specific configs)
    brews = [
      "mas"
    ];

    # Common casks across all macs
    casks = [ 
      "1password" 
      "caffeine"
      "flux"
      "font-atkinson-hyperlegible"
      "font-jetbrains-mono-nerd-font"
      "jordanbaird-ice"
      "loom"
      "macwhisper"
      "mochi"
      "ollama"
      "raycast"
      "recut"
      "the-unarchiver"
    ];
  };

  # Common Nix packages for all macOS hosts
  environment.systemPackages = [
    pkgs._1password-cli
    pkgs.yt-dlp
  ];
}

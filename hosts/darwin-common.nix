# Common configuration for all Darwin (macOS) systems
{ config, pkgs, ... }:

{
  # Default settings from nix-darwin
  services.nix-daemon.enable = true;
  nix.settings.experimental-features = "nix-command flakes";
  nix.extraOptions = ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';
  system.stateVersion = 5;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.kristian = {
    name = "kristian";
    home = "/Users/kristian";
  };

  # Enable Touch ID support
  security.pam.enableSudoTouchIdAuth = true;

  # System settings
  system.defaults = {
    loginwindow.LoginwindowText = "REWARD IF LOST: kristian@kristianfreeman.com";
    screencapture.location = "~/Pictures/Screenshots";
    screensaver.askForPasswordDelay = 10;

    # Dock
    dock = {
      autohide = true;
      autohide-time-modifier = 0.1;
      expose-group-by-app = true;
      mru-spaces = false;
      show-recents = false;
      static-only = true;
    };

    finder = {
      AppleShowAllExtensions = true;
      FXPreferredViewStyle = "clmv";
    };

    NSGlobalDomain = { 
      # Fix trackpad scroll direction
      "com.apple.swipescrolldirection" = false;
      ApplePressAndHoldEnabled = false;

      InitialKeyRepeat = 10;
      KeyRepeat = 1;
    };

    spaces.spans-displays = true;
  };

  # Common homebrew shell initialization
  home-manager.users.kristian.programs.zsh = {
    initExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
  };
}
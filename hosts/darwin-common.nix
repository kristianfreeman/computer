# Common configuration for all Darwin (macOS) systems
{ config, pkgs, ... }:

{
  nix.enable = false;
  nix.settings.experimental-features = "nix-command flakes";
  nix.extraOptions = ''
    experimental-features = flakes nix-command
    extra-platforms = x86_64-darwin aarch64-darwin
  '';
  system.stateVersion = 5;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = "kristian";

  users.users.kristian = {
    name = "kristian";
    home = "/Users/kristian";
  };

  # System settings
  system.defaults = {
    loginwindow.LoginwindowText = "REWARD IF LOST: kristian@kristianfreeman.com";
    screencapture.location = "~/Pictures/Screenshots";
    screensaver.askForPasswordDelay = 10;

    # Dock
    dock = {
      autohide = true;
      autohide-time-modifier = 0.1;
      expose-group-apps = true;
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

    # Turn on stage manager
    WindowManager.GloballyEnabled = true;
  };

  # Common homebrew shell initialization
  home-manager.users.kristian.programs.zsh = {
    initExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
  };
}

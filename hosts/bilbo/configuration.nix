{ config, pkgs, homebrew-core, homebrew-cask, ... }:

let 
in
{
  # Default settings from nix-darwin.
  ###################################
  services.nix-daemon.enable = true;
  nix.settings.experimental-features = "nix-command flakes";
  nix.extraOptions = ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';
  # TODO: fix this
  # system.configurationRevision = config.configurationRevision or null;
  system.stateVersion = 5;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.kristian = {
    name = "kristian";
    home = "/Users/kristian";
  };

  # Install homebrew if not yet installed
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "kristian";

    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
    };
  };

  # Nix packages
  ##############
  environment.systemPackages = [
    pkgs._1password-cli
    pkgs.aerospace
    pkgs.caddy
    pkgs.ffmpeg
    pkgs.goku
    pkgs.heroku
    pkgs.mas 
    pkgs.neofetch 
    pkgs.solana-cli 
    pkgs.yt-dlp
  ];

  # Homebrew, managed by Nix
  ##########################
  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";
    taps = [
      "homebrew/homebrew-core"
      "homebrew/homebrew-cask"
    ];
    brews = [];
    casks = [ 
      "1password" 
      "balenaetcher"
      "boltai"
      "caffeine"
      "discord"
      "flux"
      "font-atkinson-hyperlegible"
      "font-jetbrains-mono-nerd-font"
      "google-chrome"
      "jordanbaird-ice"
      "karabiner-elements"
      "kitty" 
      "macwhisper"
      "mochi"
      "notion"
      "obsidian"
      "plexamp" 
      "raycast"
      "screen-studio"
      "signal"
      "slack"
      "telegram"
      "visual-studio-code"
    ];
    masApps = {
      Noir = 1592917505;
      OnePasswordExtension = 1569813296;
    };
  };

  # System settings
  #################

  # Enable Touch ID support
  security.pam.enableSudoTouchIdAuth = true;

  # system.keyboard.enableKeyMapping = true;
  # system.keyboard.userKeyMapping = [
  #   {
  #     # From: CapsLock (0x700000039)
  #     HIDKeyboardModifierMappingSrc = 30064771129;
  #     # To: F18 (0x70000006D)
  #     HIDKeyboardModifierMappingDst = 30064771181;
  #   }
  # ];

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
}

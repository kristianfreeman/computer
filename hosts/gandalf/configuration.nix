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

  # Homebrew, managed by Nix
  ##########################
  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";
    taps = [
      "homebrew/homebrew-core"
      "homebrew/homebrew-cask"
    ];
    brews = [
      "libpq"
      "libyaml"
      "postgresql@14"
    ];
    casks = [ 
      "1password" 
      "ableton-live-suite"
      "balenaetcher"
      "boltai"
      "caffeine"
      "calibre"
      "claude"
      "discord"
      "flux"
      "font-atkinson-hyperlegible"
      "font-jetbrains-mono-nerd-font"
      "google-chrome"
      "jordanbaird-ice"
      "karabiner-elements"
      "macwhisper"
      "mochi"
      "notion"
      "obsidian"
      "plex-media-server"
      "plexamp" 
      "raycast"
      "recut"
      "screen-studio"
      "signal"
      "slack"
      "splice"
      "steam"
      "telegram"
      "transmission"
      "visual-studio-code"
    ];
    # nix shell nixpkgs#mas
    # mas search <app name>
    masApps = {
      Adblock = 1402042596;
      Copilot = 1447330651;
      MacFamilyTree = 1567970985;
      Noir = 1592917505;
      PixelmatorPro = 1289583905;
      OnePasswordExtension = 1569813296;
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
    pkgs.id3v2
    pkgs.heroku
    pkgs.mas 
    pkgs.neofetch 
    pkgs.ruby_3_3
    pkgs.solana-cli 
    pkgs.yt-dlp
  ];

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

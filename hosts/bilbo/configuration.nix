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
    pkgs.fzf
    pkgs.gh
    pkgs.jq
    pkgs.mas 
    pkgs.neofetch 
    pkgs.neovim 
    pkgs.nodejs_22
    pkgs.ripgrep
    pkgs.solana-cli 
    pkgs.zellij
    pkgs.zoxide
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
      "jordanbaird-ice"
      "karabiner-elements"
      "kitty" 
      "mochi"
      "notion"
      "obsidian"
      "plexamp" 
      "raycast"
      "signal"
      "slack"
      "telegram"
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

  # System settings
  system.defaults = {
    loginwindow.LoginwindowText = "REWARD IF LOST: kristian@kristianfreeman.com";
    screencapture.location = "~/Pictures/Screenshots";
    screensaver.askForPasswordDelay = 10;

    # Dock
    dock = {
      autohide = true;
      autohide-time-modifier = 0.1;
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
  };
}

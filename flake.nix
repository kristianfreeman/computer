# Nix config
# Kristian Freeman / kristianfreeman.com
# Created 2024-11-08

# Tested with https://determinate.systems installer

# Sources that helped me set this up:
#  - https://davi.sh/blog/2024/01/nix-darwin/
#  - https://nixcademy.com/posts/nix-on-macos/
#  - https://github.com/mirkolenz/nixos/blob/main/system/darwin/settings.nix

# Things I would like to set in here:
# 1. git config
# 2. home manager
# 3. fix trackpad direction

{
  description = "Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nix-darwin, nixpkgs, nix-homebrew, homebrew-core, homebrew-cask, home-manager }:

  let
    configuration = { pkgs, ... }: {
      # Default settings from nix-darwin.
      ###################################
      services.nix-daemon.enable = true;
      nix.settings.experimental-features = "nix-command flakes";
      nix.extraOptions = ''
        extra-platforms = x86_64-darwin aarch64-darwin
      '';
      system.configurationRevision = self.rev or self.dirtyRev or null;
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
        pkgs.neofetch 
        pkgs.neovim 
        pkgs.nodejs_22
        pkgs.zellij
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
        brews = [
          "jq"
          "mas"
          "ripgrep"
          "solana"
          "zoxide"
        ];
        casks = [ 
          "1password" 
          "boltai"
          "flux"
          "font-atkinson-hyperlegible"
          "font-jetbrains-mono-nerd-font"
          "jordanbaird-ice"
          "karabiner-elements"
          "kitty" 
          "obsidian"
          "plexamp" 
          "raycast"
          "slack"
        ];
        masApps = {
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
    };

    # Home Manager
    ##############
    homeconfig = { pkgs, ... }: {
      home.stateVersion = "23.05";
      programs.home-manager.enable = true;

      home.packages = with pkgs; [];

      home.sessionVariables = {
        EDITOR = "vim";
      };

      programs.git = {
        enable = true;
        userName = "Kristian Freeman";
        userEmail = "kristian@kristianfreeman.com";
        ignores = [ ".DS_Store" ];
        extraConfig = {
          init.defaultBranch = "main";
          push.autoSetupRemote = true;
        };
      };

      programs.zsh = {
        enable = true;
        shellAliases = {
          switch = "darwin-rebuild switch --flake ~/.config/nix";
        };
      };
    };
  
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#bilbo
    darwinConfigurations.bilbo = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
	  home-manager.verbose = true;
          home-manager.users.kristian = homeconfig;
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations.bilbo.pkgs;
  };
}

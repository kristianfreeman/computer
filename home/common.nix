{ config, pkgs, lib, ... }:

let
in
{
  # State version used in configurations
  home.stateVersion = "23.05";
  
  # Enable Home Manager
  programs.home-manager.enable = true;

  home.shellAliases = {
    ao = "exec $SHELL -l";
    cat = "bat --theme catppuccin-mocha";
    ls = "eza --group-directories-first";
    tree = "eza --group-directories-first --tree";
    switch = if pkgs.stdenv.isDarwin then "sudo darwin-rebuild switch --flake ~/.config/nix" else "sudo nixos-rebuild switch --flake /etc/nixos";
    vim = "hx";
    vi = "hx";
  };

  # Shared home packages
  home.packages = with pkgs; [
    ansible
    cargo
    devbox
    gh
    gifsicle
    neovim
    nmap
    nodejs
    openssl
    ripgrep
    ruby_3_3
    rustc
    sd
    slides
    starship
    stockfish
    wget
    xh
  ];

  # Environment variables common to all machines
  home.sessionVariables = {
    EDITOR = "nvim";
    TERM = "xterm";
  };

  # Sync config folders across systems
  home.file.".config/bat" = {
    source = ./bat;
    recursive = true;
  };

  home.file.".config/ghostty" = {
    source = ./ghostty;
    recursive = true;
  };

  home.file.".config/helix/config.toml" = {
    source = ./helix/config.toml;
    recursive = true;
  };

  home.file.".config/nvim" = {
    source = ./nvim;
    recursive = true;
  };

  home.file.".editorconfig" = {
    source = ./editorconfig;
    recursive = true;
  };

  home.file.".config/kitty" = {
    source = ./kitty;
    recursive = true;
  };

  home.file.".config/btop" = {
    source = ./btop;
    recursive = true;
  };

  home.file.".config/stig/rc" = {
    source = ./stig/rc;
    recursive = true;
  };

  home.file.".npmrc" = {
    source = ./npmrc;
    recursive = true;
  };

  # Programs with no config
  programs.bat.enable = true;
  programs.btop.enable = true;
  programs.direnv.enable = true;
  programs.fzf.enable = true;
  programs.jq.enable = true;
  programs.zoxide.enable = true;

  programs.firefox = {
    enable = true;
    profiles = {
      default = {
        id = 0;
        name = "default";
        isDefault = true;
        search = {
          engines = {
            "ddg" = {
              urls = [{
                template = "https://duckduckgo.com/?q={searchTerms}";
              }];
              definedAliases = [ "@ddg" ];
            };
          };
          default = "ddg";
        };
        settings = {
          # Enable vertical tabs
          "sidebar.verticalTabs" = true;
          "sidebar.revamp" = true;
          
          # Optional: Hide horizontal tabs
          "browser.tabs.tabmanager.enabled" = false;
          
          # Dark theme
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
          "browser.theme.content-theme" = 0;
          "browser.theme.toolbar-theme" = 0;
          
          # Auto-enable extensions
          "extensions.autoDisableScopes" = 0;
          "extensions.enabledScopes" = 15;
          
          # Allow unsigned extensions (for Nix-installed addons)
          "xpinstall.signatures.required" = false;
        };
        extensions = {
          packages = with pkgs.nur.repos.rycee.firefox-addons; [
            darkreader
            tridactyl
            ublock-origin
            onepassword-password-manager
            sponsorblock
            enhancer-for-youtube
          ];
        };
      };
    };
  };

  programs.eza = {
    enable = true;
    icons = "auto";

    extraOptions = [
      "--group-directories-first"
      "--no-quotes"
      "--git-ignore"
    ];
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

  programs.yazi = {
    enable = true;
    settings = {
      theme = "catppuccin-mocha";
    };
  };

  programs.zellij = {
    enable = true;
    settings = {
      theme = "catppuccin-mocha";
    };
  };

  programs.zsh = {
    enable = true;
    initExtra = "source ${./zsh/includes.zsh}";  # Assumes zsh config stored outside this file.
    shellAliases = {
    };
    oh-my-zsh = {
      enable = true;
      theme = "sunaku";
      plugins = [
        "fzf"
        "starship"
        "zoxide"
      ];
    };
  };
}


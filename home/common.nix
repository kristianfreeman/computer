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
    vi = "nvim";
    vim = "nvim";
    y = "yazi";
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
    initContent = "source ${./zsh/includes.zsh}";  # Assumes zsh config stored outside this file.
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


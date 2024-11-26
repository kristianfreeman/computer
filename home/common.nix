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
  };

  # Shared home packages
  home.packages = with pkgs; [
    gh
    id3v3
    neovim
    nmap
    nodejs
    openssl
    ripgrep
    starship
    stockfish
    wget
    zellij
    xh
  ];

  # Environment variables common to all machines
  home.sessionVariables = {
    EDITOR = "nvim";
    TERM = "xterm";
  };

  # Sync config folders across systems
  home.file.".config/nvim" = {
    source = ./nvim;
    recursive = true;
  };

  home.file.".aerospace.toml" = {
    source = ./aerospace.toml;
  };

  home.file.".config/karabiner.edn" = {
    source = ./karabiner.edn;
  };

  home.file.".editorconfig" = {
    source = ./editorconfig;
    recursive = true;
  };

  home.file.".config/zellij" = {
    source = ./zellij;
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

  # Git configuration
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

  programs.bat.enable = true;
  programs.btop.enable = true;
  programs.eza = {
    enable = true;
    icons = "auto";

    extraOptions = [
      "--group-directories-first"
      "--no-quotes"
      "--git-ignore"
    ];

  };
  programs.fzf.enable = true;
  programs.jq.enable = true;
  programs.zoxide.enable = true;

  # ZSH and oh-my-zsh configurations
  programs.zsh = {
    enable = true;
    initExtra = "source ${./zsh/includes.zsh}";  # Assumes zsh config stored outside this file.
    shellAliases = {
      vi = "nvim";
      vim = "nvim";
      switch = if pkgs.stdenv.isDarwin then "darwin-rebuild switch --flake ~/.config/nix" else "sudo nixos-rebuild switch --flake /etc/nixos";
    };
    oh-my-zsh = {
      enable = true;
      theme = "sunaku";
      plugins = [
        "chruby"
        "fzf"
        "starship"
        "zoxide"
      ];
    };
  };

  home.activation.syncGoku = lib.mkIf pkgs.stdenv.isDarwin ''
    ${pkgs.goku}/bin/goku
  '';
}


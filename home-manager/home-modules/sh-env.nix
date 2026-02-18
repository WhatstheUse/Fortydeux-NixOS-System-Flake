{ config, pkgs, inputs,... }:

{
  # Bash Shell
  programs.bash = {
    enable = true;
    enableCompletion = true;
  };
  # Zsh shell
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    initExtra = ''
      # fastfetch|lolc
      eval "$(zoxide init zsh)"
      eval "$(starship init zsh)"
      # eval "$(gh copilot alias -- zsh)"
    '';
  };
  # Fish Shell
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting

      # Source API keys if secrets file exists
      if test -f ~/.env.secrets
        source ~/.env.secrets
      end
    '';
  };
  # Atuin shell history - using flake input for latest version
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    # package = inputs.atuin.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
  # Session variables and shell aliases
  home = {
    sessionPath = [
      "${config.home.homeDirectory}/.cargo/bin"
    ];
    sessionVariables = {
      # EDITOR = "emacs";
      # VISUAL = "hx";
      # EDITOR = "hx";
      BROWSER = "firefox";
      DEFAULT_BROWSER = "firefox";
    };
    shellAliases = {
      ls = "lsd -lh --group-directories-first --color always --icon always";
      rrr = "ranger";
      yyy = "yazi";
      fast = "fastfetch";
      fetch = "fastfetch";
      ff = "cd ~/fortyflake";
      ffy = "cd ~/fortyflake && yazi";
      org = "cd ~/Documents/Org-Mode";
      orgy = "cd ~/Documents/Org-Mode && yazi";
      stat = "git status";
      st = "git status -s";
      kncaudio = "cd ~/pCloudDrive/KNC-Audio";
      teach = "cd ~/pCloudDrive/Shared-TobAnni/T-KNCS-Teaching";
      teachy = "cd ~/pCloudDrive/Shared-TobAnni/T-KNCS-Teaching && yazi";
      zzz = "zellij";
      reset-audio = "systemctl --user restart pipewire wireplumber && sleep 2";
    };
  };
  # Nix-direnv
  programs.direnv = {
      enable = true;
      # enableBashIntegration = true;
      # enableFishIntegration = true;
      # enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  #Shell-related packages
  home.packages = (with pkgs; [
    devenv #Fast, Declarative, Reproducible, and Composable Developer Environments
    starship
    lsd
    eza
    bat
    fd
    gnused
    gnugrep
    ripgrep
    zoxide
    # LSPs
    nixd #Feature-rich Nix language server interoperating with C++ nix
    # Formatters
    # alejandra #Uncompromising Nix Code Formatter
    nixfmt #Official formatter for Nix code
  ]);
}

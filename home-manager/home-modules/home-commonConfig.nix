{ config, pkgs, ... }:

{
  imports = [
    ./wm-homeConfig.nix
    ./mime-config.nix
    ./whisper-faster.nix
    ./whisper-cpp.nix
    ./whisper-plasma.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "fortydeux";
  home.homeDirectory = "/home/fortydeux";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  nixpkgs.config.allowUnfree = true;

  home.packages = (with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # hello
    # anytype #P2P note-taking tool
    appflowy #An open-source alternative to Notion
    barrier #Open-source KVM software
    cachix #Command-line client for Nix binary cache hosting https://cachix.org
    code-cursor #AI-powered code editor built on vscode    
    # cheese # Cheesy camera app
    # decent-sampler #An audio sample player
    # discord #Discord social client
    ext4magic #Recover / undelete files from ext3 or ext4 partitions
    extundelete #Utility that can recover deleted files from an ext3 or ext4 partition
    fish #Fish terminal
    # freetube #An Open Source YouTube app for privacy
    # fuzzel # Wayland launcher
    gh #Github CLI tool 
    ghostty #Fast, native, feature-rich terminal emulator pushing modern features
    # helix #Post modern modal text editor
    impala #TUI for managing Wifi
    jellyfin-tui #TUI for Jellyfin music
    joplin-desktop #An open source note taking and to-do application with synchronisation capabilities
    joshuto #Ranger-like TUI file manager written in Rust
    # (kdePackages.kdenlive.overrideAttrs (prevAttrs: {
    #   nativeBuildInputs = (prevAttrs.nativeBuildInputs or [ ]) ++ [ makeBinaryWrapper ];
    #   postInstall = (prevAttrs.postInstall or "") + ''
    #     wrapProgram $out/bin/kdenlive --prefix LADSPA_PATH : ${rnnoise-plugin}/lib/ladspa
    #   '';
    # }))
    # kdePackages.kdenlive # Open source video editor based on MLT and KDE frameworks
 #   logseq #Logseq electron desktop client
    # libinput # Handles input devices in Wayland compositors
    lan-mouse #Wayland software KVM switch
    # media-downloader #Media-downloader desktop client
    # mediawriter #USB imaage writer
    # moc # Terminal music player
    # musescore #Music notation and composition software
    nix-melt # A ranger-like flake.lock viewer
    nix-search-cli # CLI for searching packages on search.nixos.org
    nix-search-tv # Fuzzy search for Nix packages
    # obs-studio #Screen recorder       
    patchance # JACK Patchbay GUI
    pdfgrep # Commandline utility to search text in PDF files
    poppler_utils #Poppler is a PDF rendering library based on the xpdf-3.0 code base. In addition it provides a number of tools that can be installed separately.    
    reaper #Reaper DAW
    rustscan #Nmap scanner written in Rust
    # shotcut #Open-source cross-platform video editor
    signal-desktop-bin #Signal electron desktop client
    # simplex-chat-desktop #SimpleX Chat Desktop Client
    # spotify #Spotify music client - Requires non-free packages enabled
    super-productivity # To Do List / Time Tracker with Jira Integration
 #   teams #Microsoft Teams application - not yet available for Linux
    # telegram-desktop #Telegram desktop client
    tenere #Rust-based TUI for interacting with LLMs
    testdisk #Data recovery utilities
    ticktick #A powerful to-do & task management app with seamless cloud synchronization across all your devices
    tldr # Simplified and community-driven man pages
    tmux #Terminal multiplexer
    trayer # Lightweight GTK2-based system tray for unix desktp
    vault-tasks #TUI Markdown Task manager
    vscode #Open source source code editor developed by Microsoft for Windows, Linux and macOS    
    # kdePackages.yakuake #Drop-down terminal emulator based on Konsole technologies
    warp-terminal # Modern rust-based terminal       
    waveterm # Paneled Terminal, File-Manager w/ Preview, AI chat, and Webviewer
    # waynergy #A synergy client for Wayland compositors
    wiki-tui #Wikipedia TUI interface
    windsurf # Agentic IDE powered by AI Flow paradigm
    yt-dlp #Command-line tool to download videos from YouTube.com and other sites (youtube-dl fork)
    zed-editor #Modern text editor with AI built in - still in development for Linux
    # zoom-us #zoom.us video conferencing application
    
    # Alternative audio control applications that work properly
    pwvucontrol  # Modern PipeWire volume control (should have working icons)
    pavucontrol  # Keep original as fallback
    
   ]);
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
     
  programs = {
    fzf.enable = true;
    fuzzel = {
      enable = true;
    };
    ghostty = {
      enable = true;
      settings = {
        theme = "stylix";
      };
    };
    helix = {
      enable = true;
      defaultEditor = true;
      settings = {
        # theme = "tokyonight";
        editor = {
          line-number = "relative";
          mouse = true;
        };      
        editor.lsp = {
          display-messages = true;
        };        
        editor.cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };        
        editor.soft-wrap = {
          enable = true;
        };
      };
      languages = {
        language-server = {
          nixd = {
            command = "nixd";
          };
          nil = {
            command = "nil";
          };
        };
        language = [{
          name = "nix";
          language-servers = [ "nixd" "nil" ];
          formatter = {
            command = "nixfmt";
            args = [ "-" ];
          };
          auto-format = false;
        }];       
      };
    };
    nnn = {
      enable = true;
      package = pkgs.nnn.override ({ withNerdIcons = true; });
      extraPackages = with pkgs; [
        mediainfo
        ffmpegthumbnailer
        sxiv
        nsxiv
        file
        zathura
        tree
        # Essential dependencies for preview-tui plugin
        bat
        ueberzug
        chafa
        viu
        catimg
        timg
        glow
        lowdown
        w3m
        lynx
        elinks
        pistol
      ];
      plugins = {
        mappings = {
          #f = "finder";
          #o = "fzopen";
          n = "nuke";
          p = "preview-tui";
          #s = "-!printf $PWD/$nnn|wl-copy*";
          #d = "";
        };
        src = ./plugins/nnn;
        #src = (pkgs.fetchFromGitHub {
        #  owner = "jarun";
        #  repo = "nnn";
        #  rev = "v4.0";
        #  sha256 = "sha256-Hpc8YaJeAzJoEi7aJ6DntH2VLkoR6ToP6tPYn3llR7k=";
        #}) + "/plugins";
      };
    };
    yazi = {
      enable = true;
      settings = {
        opener = {
          # Text files
          edit = [
            { run = "$EDITOR \"$@\""; block = true; for = "unix"; }
            { run = "code \"$@\""; desc = "VS Code"; }
            { run = "cursor \"$@\""; desc = "Cursor"; }
          ];
          
          # Images
          image = [
            { run = "gwenview \"$@\""; desc = "Gwenview"; }
            { run = "firefox \"$@\""; desc = "Firefox"; }
          ];
          
          # Videos
          video = [
            { run = "mpv \"$@\""; desc = "MPV"; }
            { run = "vlc \"$@\""; desc = "VLC"; }
          ];
          
          # Audio
          audio = [
            { run = "mpv \"$@\""; desc = "MPV"; }
            { run = "vlc \"$@\""; desc = "VLC"; }
          ];
          
          # PDFs
          pdf = [
            { run = "okular \"$@\""; desc = "Okular"; }
            { run = "firefox \"$@\""; desc = "Firefox"; }
          ];
          
          # Documents
          document = [
            { run = "onlyoffice-desktopeditors \"$@\""; desc = "OnlyOffice"; }
            { run = "libreoffice \"$@\""; desc = "LibreOffice"; }
          ];
          
          # Archives
          archive = [
            { run = "ark \"$@\""; desc = "Ark"; }
          ];
          
          # Web links
          web = [
            { run = "firefox \"$@\""; desc = "Firefox"; }
          ];
        };
        
        open = {
          rules = [
            { name = "*/"; use = [ "edit" "reveal" ]; }
            { mime = "text/*"; use = [ "edit" "reveal" ]; }
            { mime = "image/*"; use = [ "image" "reveal" ]; }
            { mime = "video/*"; use = [ "video" "reveal" ]; }
            { mime = "audio/*"; use = [ "audio" "reveal" ]; }
            { mime = "application/pdf"; use = [ "pdf" "reveal" ]; }
            { mime = "application/zip"; use = [ "archive" "reveal" ]; }
            { mime = "application/x-tar"; use = [ "archive" "reveal" ]; }
            { mime = "application/x-7z-compressed"; use = [ "archive" "reveal" ]; }
            { mime = "application/x-rar-compressed"; use = [ "archive" "reveal" ]; }
            { name = "*.nix"; use = [ "edit" "reveal" ]; }
            { name = "*.py"; use = [ "edit" "reveal" ]; }
            { name = "*.rs"; use = [ "edit" "reveal" ]; }
            { name = "*.js"; use = [ "edit" "reveal" ]; }
            { name = "*.ts"; use = [ "edit" "reveal" ]; }
            { name = "*.md"; use = [ "edit" "reveal" ]; }
            { name = "*.json"; use = [ "edit" "reveal" ]; }
            { name = "*.yaml"; use = [ "edit" "reveal" ]; }
            { name = "*.yml"; use = [ "edit" "reveal" ]; }
            { name = "*.toml"; use = [ "edit" "reveal" ]; }
            { name = "*.docx"; use = [ "document" "reveal" ]; }
            { name = "*.doc"; use = [ "document" "reveal" ]; }
            { name = "*.xlsx"; use = [ "document" "reveal" ]; }
            { name = "*.xls"; use = [ "document" "reveal" ]; }
            { name = "*.pptx"; use = [ "document" "reveal" ]; }
            { name = "*.ppt"; use = [ "document" "reveal" ]; }
            { name = "*.odt"; use = [ "document" "reveal" ]; }
            { name = "*.ods"; use = [ "document" "reveal" ]; }
            { name = "*.odp"; use = [ "document" "reveal" ]; }
            { name = "*.rtf"; use = [ "document" "reveal" ]; }
          ];
        };
      };
    };
    zellij = {
      enable = true;
      settings = {
        # theme = "dracula";
      };
    };
  };

  services = {
    walker = {
      enable = true;
      settings =  {
          app_launch_prefix = "";
          as_window = false;
          close_when_open = false;
          disable_click_to_close = false;
          force_keyboard_focus = false;
          hotreload_theme = false;
          locale = "";
          monitor = "";
          terminal_title_flag = "";
          theme = "default";
          timeout = 0;
        };
    };
    dictation-faster = {
        enable = true;
        model = "tiny";       # Toggle model here
        language = "en";
        device = "cpu";       # set "cuda" if you have NVIDIA + CUDA set up
    };

    dictation-whispercpp = {
        enable = true;
        model = "small";      # Toggle model here
        language = "en";
    };

    dictation-plasma = {
      enable = true;
      enableFasterWhisper = true;
      enableWhisperCpp = true; 
    };
  };
  
  home.sessionVariables = {
    # NNN_OPENER = "/home/fortydeux/scripts/file-ops/linkhandler.sh";
    # NNN_FCOLORS = "$BLK$CHR$DIR$EXE$REG$HARDLINK$SYMLINK$MISSING$ORPHAN$FIFO$SOCK$OTHER";
    NNN_TRASH = 1;
    NNN_FIFO = "/tmp/nnn.fifo";
  };
  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/fortydeux/etc/profile.d/hm-session-vars.sh
  #
  
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

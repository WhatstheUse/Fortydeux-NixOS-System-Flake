{ config, pkgs, username, inputs, ... }:

{
  imports = [
    ./mime-config.nix
    ./screenshot-tools.nix
    ./ai-tools.nix
    inputs.nixvim.homeModules.nixvim
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = "/home/${username}";

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
  
  # Override packages to fix CMake compatibility issues
  # nixpkgs.overlays = [
  #   (final: prev: {
  #     ctranslate2 = prev.ctranslate2.overrideAttrs (oldAttrs: {
  #       nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ final.cmake ];
  #       cmakeFlags = (oldAttrs.cmakeFlags or []) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
  #     });
  #   })    
  # ];

  home.packages = (with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # hello
    # apostrophe # Distraction-free Markdown editor for GNU/Linux
    # anytype #P2P note-taking tool
    cachix #Command-line client for Nix binary cache hosting https://cachix.org
    # cheese # Cheesy camera app
    ctune # Ncurses internet radio TUI
    # decent-sampler #An audio sample player
    # discord #Discord social client
    ext4magic #Recover / undelete files from ext3 or ext4 partitions
    extundelete #Utility that can recover deleted files from an ext3 or ext4 partition
    fish #Fish terminal
    # freetube #An Open Source YouTube app for privacy
    # fuzzel # Wayland launcher
    gh #Github CLI tool 
    ghostty #Fast, native, feature-rich terminal emulator pushing modern features
    kdePackages.ghostwriter # Text editor for Markdown
    # helix #Post modern modal text editor
    imagemagick # Software suite to convert, edit, merge, create bitmap images
    # img2pdf # Convert images to PDFs via direct JPEG inclusion
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
    nvchecker # New version checker for software
    # obs-studio #Screen recorder       
    patchance # JACK Patchbay GUI
    pdfgrep # Commandline utility to search text in PDF files
    poppler_utils #Poppler is a PDF rendering library based on the xpdf-3.0 code base. In addition it provides a number of tools that can be installed separately.    
    python3 # Python 3
    pyradio #Curses based internet radio
    radio-cli #Simple radio CLI written in rust
    reaper #Reaper DAW
    retext # Editor for Markdown and reStructuredText
    rustscan #Nmap scanner written in Rust
    satty #Modern Screenshot Annotation tool
    # shotcut #Open-source cross-platform video editor
    signal-desktop-bin #Signal electron desktop client
    # simplex-chat-desktop #SimpleX Chat Desktop Client
    spotify-player #Spotify music client
    ncspot #Spotify music client
    # spotify #Spotify music client - Requires non-free packages enabled
    super-productivity # To Do List / Time Tracker with Jira Integration
 #   teams #Microsoft Teams application - not yet available for Linux
    # telegram-desktop #Telegram desktop client
    testdisk #Data recovery utilities
    ticktick #A powerful to-do & task management app with seamless cloud synchronization across all your devices
    tldr # Simplified and community-driven man pages
    tmux #Terminal multiplexer
    trayer # Lightweight GTK2-based system tray for unix desktp
    vault-tasks #TUI Markdown Task manager
    vscode #Open source source code editor developed by Microsoft for Windows, Linux and macOS    
    # kdePackages.yakuake #Drop-down terminal emulator based on Konsole technologies
    # waynergy #A synergy client for Wayland compositors
    wiki-tui #Wikipedia TUI interface
    yt-dlp #Command-line tool to download videos from YouTube.com and other sites (youtube-dl fork)
    # zoom-us #zoom.us video conferencing application
    
    # Alternative audio control applications that work properly
    pwvucontrol  # Modern PipeWire volume control (should have working icons)
    pavucontrol  # Keep original as fallback
    
    # File utilities
    file  # File type detection utility
    
    # PDF tools
    xournalpp  # Handwriting note-taking application
    evince  # Document viewer for PDF files
    
    # C compiler for treesitter and other tools
    gcc  # GNU Compiler Collection
    
    # Secrets management
    sops  # Secrets OPerationS - encrypted secrets management
    
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
    emacs = {
      enable = true;
    };
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
    nixvim = {
      enable = true;
      # enableMan = false;
      # defaultEditor = true;
      waylandSupport = true;
      opts = {
        # Tab and indentation settings
        tabstop = 2;
        shiftwidth = 2;
        expandtab = true;
        smartindent = true;
        autoindent = true;
        # Line numbers
        number = true;
        relativenumber = true;
        # Other useful settings
        wrap = false;
        cursorline = true;
      };
      plugins = {
        avante = {
          enable = true;
        };
        codecompanion = {
          enable = true;
        };
        orgmode.enable = true;
        which-key.enable = true;
        telescope.enable = true;
        treesitter = {
          enable = true;
          settings = { 
            indent.enable = true;
            ensure_installed = [ "lua" "nix" "python" "json" "yaml" "markdown" "bash" "javascript" "html" "css" ];
          };
        };
        treesitter-textobjects.enable = true;
        lsp = {
          enable = true;
          servers = {
            lua_ls.enable = true;
            pyright.enable = true;
            jsonls.enable = true;
            nil_ls.enable = true;
            bashls.enable = true;
            ts_ls.enable = true;
          };
        };
        luasnip.enable = true;
        comment.enable = true;
        nvim-autopairs.enable = true;
        nvim-surround.enable = true;
        # indent-blankline.enable = true;
        gitsigns.enable = true;
        diffview.enable = true;
        lualine.enable = true;
        bufferline.enable = true;
        dressing.enable = true;
        oil.enable = true;
        flash.enable = true;
        multicursors.enable = true;
        web-devicons.enable = true;
        yanky.enable = true;
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
        # catimg  # Disabled due to CMake compatibility issues
        (catimg.overrideAttrs (oldAttrs: {
          nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ cmake ];
          cmakeFlags = (oldAttrs.cmakeFlags or []) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
        }))
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
    radio-active = {
      enable = true;
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
            { run = "zeditor \"$@\""; desc = "Zed Editor"; }
            { run = "kate \"$@\""; desc = "Kate"; }
            { run = "lapce \"$@\""; desc = "Lapce"; }
            { run = "ghostwriter \"$@\""; desc = "Ghostwriter"; }
            { run = "kitty -e hx \"$@\""; desc = "Helix"; }
            { run = "kitty -e nvim \"$@\""; desc = "Neovim"; }
            { run = "emacs \"$@\""; desc = "Emacs"; }
            { run = "retext \"$@\""; desc = "ReText"; }
            { run = "okular \"$@\""; desc = "Okular"; }
            { run = "apostrophe \"$@\""; desc = "Apostrophe"; }
            { run = "onlyoffice-desktopeditors \"$@\""; desc = "OnlyOffice"; }
            { run = "${config.home.homeDirectory}/.config/scripts/app-picker.sh \"$@\""; desc = "Application Picker"; }
          ];
          
          # Images
          image = [
            { run = "gwenview \"$@\""; desc = "Gwenview"; }
            { run = "firefox \"$@\""; desc = "Firefox"; }
            { run = "${config.home.homeDirectory}/.config/scripts/app-picker.sh \"$@\""; desc = "Application Picker"; }
          ];
          
          # Videos
          video = [
            { run = "mpv \"$@\""; desc = "MPV"; }
            { run = "vlc \"$@\""; desc = "VLC"; }
            { run = "${config.home.homeDirectory}/.config/scripts/app-picker.sh \"$@\""; desc = "Application Picker"; }
          ];
          
          # Audio
          audio = [
            { run = "mpv \"$@\""; desc = "MPV"; }
            { run = "vlc \"$@\""; desc = "VLC"; }
            { run = "${config.home.homeDirectory}/.config/scripts/app-picker.sh \"$@\""; desc = "Application Picker"; }
            ];
          
          # PDFs
          pdf = [
            { run = "okular \"$@\""; desc = "Okular"; }
            { run = "evince \"$@\""; desc = "Evince"; }
            { run = "xournalpp \"$@\""; desc = "Xournal++"; }
            { run = "org.libreoffice.LibreOffice --draw \"$@\""; desc = "LibreOffice Draw (flatpak)"; }
            { run = "libreoffice --draw \"$@\""; desc = "LibreOffice Draw (nixpkgs)"; }
            { run = "onlyoffice-desktopeditors \"$@\""; desc = "OnlyOffice"; }
            { run = "firefox \"$@\""; desc = "Firefox"; }
            { run = "${config.home.homeDirectory}/.config/scripts/app-picker.sh \"$@\""; desc = "Application Picker"; }
          ];
          
          # Documents
          document = [
            { run = "org.libreoffice.LibreOffice \"$@\""; desc = "LibreOffice flatpak"; }
            { run = "libreoffice \"$@\""; desc = "LibreOffice nixpkgs"; }
            { run = "onlyoffice-desktopeditors \"$@\""; desc = "OnlyOffice"; }
            { run = "${config.home.homeDirectory}/.config/scripts/app-picker.sh \"$@\""; desc = "Application Picker"; }
          ];
          
          # Archives
          archive = [
            { run = "ark \"$@\""; desc = "Ark"; }
            { run = "${config.home.homeDirectory}/.config/scripts/app-picker.sh \"$@\""; desc = "Application Picker"; }
          ];
          
          # Web links
          web = [
            { run = "firefox \"$@\""; desc = "Firefox"; }
            { run = "${config.home.homeDirectory}/.config/scripts/app-picker.sh \"$@\""; desc = "Application Picker"; }
          ];
          
          # Reveal in file manager
          reveal = [
            { run = "nautilus \"$@\""; desc = "Nautilus"; }
            { run = "dolphin \"$@\""; desc = "Dolphin"; }
            { run = "thunar \"$@\""; desc = "Thunar"; }
            { run = "pcmanfm \"$@\""; desc = "PCManFM"; }
            { run = "${config.home.homeDirectory}/.config/scripts/app-picker.sh \"$@\""; desc = "Application Picker"; }
          ];
        };
        
        open = {
          rules = [
            { name = "*/"; use = [ "edit" "reveal" ]; }
            { mime = "text/*"; use = [ "edit" "reveal" ]; }
            # MIME type rules
            { mime = "image/*"; use = [ "image" "reveal" ]; }
            { mime = "video/*"; use = [ "video" "reveal" ]; }
            { mime = "audio/*"; use = [ "audio" "reveal" ]; }
            { mime = "application/pdf"; use = [ "pdf" "reveal" ]; }
            { mime = "application/zip"; use = [ "archive" "reveal" ]; }
            { mime = "application/x-tar"; use = [ "archive" "reveal" ]; }
            { mime = "application/x-7z-compressed"; use = [ "archive" "reveal" ]; }
            { mime = "application/x-rar-compressed"; use = [ "archive" "reveal" ]; }
            { mime = "application/x-bzip2"; use = [ "archive" "reveal" ]; }
            { mime = "application/x-xz"; use = [ "archive" "reveal" ]; }
            { mime = "application/x-lzma"; use = [ "archive" "reveal" ]; }
            { mime = "font/ttf"; use = [ "reveal" ]; }
            { mime = "font/otf"; use = [ "reveal" ]; }
            { mime = "font/woff"; use = [ "reveal" ]; }
            { mime = "font/woff2"; use = [ "reveal" ]; }
            { mime = "model/vnd.collada+xml"; use = [ "reveal" ]; }
            { mime = "application/sla"; use = [ "reveal" ]; }
            # Code and markup files
            { name = "*.nix"; use = [ "edit" "reveal" ]; }
            { name = "*.py"; use = [ "edit" "reveal" ]; }
            { name = "*.rs"; use = [ "edit" "reveal" ]; }
            { name = "*.js"; use = [ "edit" "reveal" ]; }
            { name = "*.ts"; use = [ "edit" "reveal" ]; }
            { name = "*.json"; use = [ "edit" "reveal" ]; }
            { name = "*.yaml"; use = [ "edit" "reveal" ]; }
            { name = "*.yml"; use = [ "edit" "reveal" ]; }
            { name = "*.toml"; use = [ "edit" "reveal" ]; }
            { name = "*.xml"; use = [ "edit" "reveal" ]; }
            { name = "*.html"; use = [ "edit" "reveal" ]; }
            { name = "*.htm"; use = [ "edit" "reveal" ]; }
            { name = "*.css"; use = [ "edit" "reveal" ]; }
            { name = "*.sql"; use = [ "edit" "reveal" ]; }
            { name = "*.sh"; use = [ "edit" "reveal" ]; }
            { name = "*.bash"; use = [ "edit" "reveal" ]; }
            { name = "*.zsh"; use = [ "edit" "reveal" ]; }
            { name = "*.fish"; use = [ "edit" "reveal" ]; }
            { name = "*.c"; use = [ "edit" "reveal" ]; }
            { name = "*.cpp"; use = [ "edit" "reveal" ]; }
            { name = "*.cc"; use = [ "edit" "reveal" ]; }
            { name = "*.h"; use = [ "edit" "reveal" ]; }
            { name = "*.hpp"; use = [ "edit" "reveal" ]; }
            
            # Image files
            { name = "*.jpg"; use = [ "image" "reveal" ]; }
            { name = "*.jpeg"; use = [ "image" "reveal" ]; }
            { name = "*.png"; use = [ "image" "reveal" ]; }
            { name = "*.gif"; use = [ "image" "reveal" ]; }
            { name = "*.bmp"; use = [ "image" "reveal" ]; }
            { name = "*.svg"; use = [ "image" "reveal" ]; }
            { name = "*.webp"; use = [ "image" "reveal" ]; }
            { name = "*.tiff"; use = [ "image" "reveal" ]; }
            { name = "*.tif"; use = [ "image" "reveal" ]; }
            { name = "*.ico"; use = [ "image" "reveal" ]; }
            { name = "*.xcf"; use = [ "image" "reveal" ]; }
            
            # Video files
            { name = "*.mp4"; use = [ "video" "reveal" ]; }
            { name = "*.avi"; use = [ "video" "reveal" ]; }
            { name = "*.mkv"; use = [ "video" "reveal" ]; }
            { name = "*.mov"; use = [ "video" "reveal" ]; }
            { name = "*.wmv"; use = [ "video" "reveal" ]; }
            { name = "*.flv"; use = [ "video" "reveal" ]; }
            { name = "*.webm"; use = [ "video" "reveal" ]; }
            { name = "*.m4v"; use = [ "video" "reveal" ]; }
            { name = "*.mpg"; use = [ "video" "reveal" ]; }
            { name = "*.mpeg"; use = [ "video" "reveal" ]; }
            { name = "*.ogv"; use = [ "video" "reveal" ]; }
            
            # Audio files
            { name = "*.mp3"; use = [ "audio" "reveal" ]; }
            { name = "*.wav"; use = [ "audio" "reveal" ]; }
            { name = "*.flac"; use = [ "audio" "reveal" ]; }
            { name = "*.ogg"; use = [ "audio" "reveal" ]; }
            { name = "*.m4a"; use = [ "audio" "reveal" ]; }
            { name = "*.aac"; use = [ "audio" "reveal" ]; }
            { name = "*.wma"; use = [ "audio" "reveal" ]; }
            
            # Archive files
            { name = "*.zip"; use = [ "archive" "reveal" ]; }
            { name = "*.tar"; use = [ "archive" "reveal" ]; }
            { name = "*.gz"; use = [ "archive" "reveal" ]; }
            { name = "*.bz2"; use = [ "archive" "reveal" ]; }
            { name = "*.7z"; use = [ "archive" "reveal" ]; }
            { name = "*.rar"; use = [ "archive" "reveal" ]; }
            { name = "*.xz"; use = [ "archive" "reveal" ]; }
            { name = "*.lzma"; use = [ "archive" "reveal" ]; }
            
            # Font files
            { name = "*.ttf"; use = [ "reveal" ]; }
            { name = "*.otf"; use = [ "reveal" ]; }
            { name = "*.woff"; use = [ "reveal" ]; }
            { name = "*.woff2"; use = [ "reveal" ]; }
            
            # 3D/CAD files
            { name = "*.stl"; use = [ "reveal" ]; }
            { name = "*.obj"; use = [ "edit" "reveal" ]; }
            { name = "*.fbx"; use = [ "reveal" ]; }
            { name = "*.dae"; use = [ "reveal" ]; }
            
            # Microsoft Office formats
            { name = "*.docx"; use = [ "document" "reveal" ]; }
            { name = "*.doc"; use = [ "document" "reveal" ]; }
            { name = "*.xlsx"; use = [ "document" "reveal" ]; }
            { name = "*.xls"; use = [ "document" "reveal" ]; }
            { name = "*.pptx"; use = [ "document" "reveal" ]; }
            { name = "*.ppt"; use = [ "document" "reveal" ]; }
            
            # OpenDocument formats
            { name = "*.odt"; use = [ "document" "reveal" ]; }
            { name = "*.ods"; use = [ "document" "reveal" ]; }
            { name = "*.odp"; use = [ "document" "reveal" ]; }
            { name = "*.odg"; use = [ "document" "reveal" ]; }
            { name = "*.odc"; use = [ "document" "reveal" ]; }
            { name = "*.odf"; use = [ "document" "reveal" ]; }
            { name = "*.odi"; use = [ "document" "reveal" ]; }
            { name = "*.odm"; use = [ "document" "reveal" ]; }
            
            # Other document formats
            { name = "*.rtf"; use = [ "document" "reveal" ]; }
            { name = "*.csv"; use = [ "document" "reveal" ]; }
            { name = "*.txt"; use = [ "edit" "reveal" ]; }
            { name = "*.md"; use = [ "edit" "reveal" ]; }
            { name = "*.markdown"; use = [ "edit" "reveal" ]; }
            { name = "*.mdown"; use = [ "edit" "reveal" ]; }
            { name = "*.mkd"; use = [ "edit" "reveal" ]; }
            { name = "*.mkdn"; use = [ "edit" "reveal" ]; }
            { name = "*.mdwn"; use = [ "edit" "reveal" ]; }
            { name = "*.mdtxt"; use = [ "edit" "reveal" ]; }
            { name = "*.mdtext"; use = [ "edit" "reveal" ]; }
            { name = "*.rst"; use = [ "edit" "reveal" ]; }
            { name = "*.log"; use = [ "edit" "reveal" ]; }
            
            # Database files
            { name = "*.db"; use = [ "reveal" ]; }
            { name = "*.sqlite"; use = [ "reveal" ]; }
            { name = "*.sqlite3"; use = [ "reveal" ]; }
            
            # Web and configuration files
            { name = "*.conf"; use = [ "edit" "reveal" ]; }
            { name = "*.config"; use = [ "edit" "reveal" ]; }
            { name = "*.ini"; use = [ "edit" "reveal" ]; }
            { name = "*.cfg"; use = [ "edit" "reveal" ]; }
            { name = "*.env"; use = [ "edit" "reveal" ]; }
            { name = "*.lock"; use = [ "edit" "reveal" ]; }
            
            # Catch-all rule for any remaining files
            { name = "*"; use = [ "edit" "reveal" ]; }
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
    satty = {
      enable = true;
      settings = {
        general = {
          fullscreen = true;
          corner-roundness = 12;
          initial-tool = "brush";
          actions-on-enter = [ "save-to-file" "exit" ];
          output-filename = "/home/${username}/Pictures/satty-%Y-%m-%d_%H-%M-%S.png";
        };
        color-palette = {
          palette = [
            "#ff6b6b"  # Red
            "#4ecdc4"  # Teal
            "#45b7d1"  # Blue
            "#96ceb4"  # Green
            "#feca57"  # Yellow
            "#ff9ff3"  # Pink
            "#54a0ff"  # Light Blue
            "#5f27cd"  # Purple
            "#00d2d3"  # Cyan
            "#ff9f43"  # Orange
          ];
        };
      };
    };
  };

  services = {
    caffeine.enable = true;
    
  #   walker = {
  #     enable = true;
  #     settings =  {
  #         app_launch_prefix = "";
  #         as_window = false;
  #         close_when_open = false;
  #         disable_click_to_close = false;
  #         force_keyboard_focus = false;
  #         hotreload_theme = false;
  #         locale = "";
  #         monitor = "";
  #         terminal_title_flag = "";
  #         theme = "default";
  #         timeout = 0;
  #       };
  #   };
  };
  
  home.sessionVariables = {
    # NNN_OPENER = "/home/${user}/scripts/file-ops/linkhandler.sh";
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
  #  /etc/profiles/per-user/${user}/etc/profile.d/hm-session-vars.sh
  #
  
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

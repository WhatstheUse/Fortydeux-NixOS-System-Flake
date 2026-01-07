{ config, pkgs, username, inputs, lib, ... }:

{
  imports = [
    ./mime-config.nix
    ./screenshot-tools.nix
    ./ai-tools.nix
    inputs.nixvim.homeModules.nixvim
    # inputs.sops-nix.homeManagerModules.sops
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

  home.packages =
    let
      signalDesktopWithKwallet =
        pkgs.symlinkJoin {
          name = "signal-desktop-bin";
          paths = [ pkgs.signal-desktop-bin ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/signal-desktop \
              --add-flags "--password-store=kwallet6"
          '';
        };
    in (with pkgs; [
    # XDG Desktop Portal backends - Required for file choosers and other portal features
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
    gnome-keyring

    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # hello
    # apostrophe # Distraction-free Markdown editor for GNU/Linux
    # anytype #P2P note-taking tool
    cachix #Command-line client for Nix binary cache hosting https://cachix.org
    castero # TUI Podcast client for the terminal
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
    ghostscript #PDF Tools
    ghostty #Fast, native, feature-rich terminal emulator pushing modern features
    kdePackages.ghostwriter # Text editor for Markdown
    # helix #Post modern modal text editor
    img2pdf #Image JPEG to PDF converter with stitching capability
    imagemagick # Software suite to convert, edit, merge, create bitmap images
    # img2pdf # Convert images to PDFs via direct JPEG inclusion
    impala #TUI for managing Wifi
    jellyfin-tui #TUI for Jellyfin music
    # joplin-desktop #An open source note taking and to-do application with synchronisation capabilities - TEMPORARILY DISABLED: uses EOL electron-36.9.5
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
    # lan-mouse #Wayland software KVM switch
    # media-downloader #Media-downloader desktop client
    # mediawriter #USB imaage writer
    # moc # Terminal music player
    # musescore #Music notation and composition software
    nix-melt # A ranger-like flake.lock viewer
    nix-search-cli # CLI for searching packages on search.nixos.org
    nix-search-tv # Fuzzy search for Nix packages
    nvchecker # New version checker for software
    # obs-studio #Screen recorder       
    pandoc # Conversion between document formats
    patchance # JACK Patchbay GUI
    pdfarranger # GTK4 GUI for arranging, merging, and working with PDF documents
    pdfgrep # Commandline utility to search text in PDF files
    pdfchain # GUI for using pdftk - requires pdftk
    pdftk # Command line tool for working with PDFs
    poppler-utils # Poppler is a PDF rendering library based on the xpdf-3.0 code base. In addition it provides a number of tools that can be installed separately.    
    python3 # Python 3
    pyradio # Curses based internet radio
    radio-cli # Simple radio CLI written in rust
    reaper # Reaper DAW
    retext # Editor for Markdown and reStructuredText
    satty # Modern Screenshot Annotation tool
    # shotcut #Open-source cross-platform video editor
    # signal-desktop-bin # original package replaced by wrapped version below
    # simplex-chat-desktop # SimpleX Chat Desktop Client
    spotify-player # Spotify music client
    ncspot # Spotify music client
    # spotify # Spotify music client - Requires non-free packages enabled
    # super-productivity # To Do List / Time Tracker with Jira Integration
 #   teams #Microsoft Teams application - not yet available for Linux
    # telegram-desktop #Telegram desktop client
    testdisk # Data recovery utilities
    ticktick # A powerful to-do & task management app with seamless cloud synchronization across all your devices
    tldr # Simplified and community-driven man pages
    tmux # Terminal multiplexer
    topgrade # Upgrade all the things
    trayer # Lightweight GTK2-based system tray for unix desktp
    vault-tasks # TUI Markdown Task manager
    vlc # Cross-platform media player
    vscode # Open source source code editor developed by Microsoft for Windows, Linux and macOS    
    # kdePackages.yakuake #Drop-down terminal emulator based on Konsole technologies
    # waynergy #A synergy client for Wayland compositors
    wiki-tui # Wikipedia TUI interface
    yt-dlp # Command-line tool to download videos from YouTube.com and other sites (youtube-dl fork)
    # zoom-us # zoom.us video conferencing application
    
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
    # sops  # Secrets OPerationS - encrypted secrets management

    # Network Tools
    rustscan #Nmap scanner written in Rust
    speedtest-rs # Network speedtest tool written in Rust
    zenmap # Official NMAP security scanner GUI
    
    
  ]) ++ [ signalDesktopWithKwallet ];
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
      extraPackages = epkgs: with epkgs; [
        # Org-mode and visual enhancements
        org
        org-bullets
        org-modern
        org-appear

        # Productivity and time management
        org-pomodoro
        org-download

        # UI and usability
        which-key
        evil  # Vim keybindings (optional, can remove if not needed)
        evil-org

        # Syntax highlighting and completion
        company

        # Theme (optional)
        doom-themes
      ];

      extraConfig = ''
        ;;; Emacs Org-mode Configuration (Moderate Setup)

        ;; Basic Emacs settings
        (setq inhibit-startup-message t)
        (tool-bar-mode -1)
        (menu-bar-mode -1)
        (scroll-bar-mode -1)
        (global-display-line-numbers-mode 1)
        (setq display-line-numbers-type 'relative)

        ;; Font size
        (set-face-attribute 'default nil :height 120)

        ;; Theme
        (load-theme 'doom-one t)

        ;; Which-key for keybinding discovery
        (require 'which-key)
        (which-key-mode 1)
        (setq which-key-idle-delay 0.5)

        ;; Company mode for completion
        (require 'company)
        (add-hook 'after-init-hook 'global-company-mode)

        ;; Evil mode (Vim keybindings) - comment out if you prefer Emacs bindings
        (require 'evil)
        (evil-mode 1)
        (require 'evil-org)
        (add-hook 'org-mode-hook 'evil-org-mode)
        (evil-org-set-key-theme '(navigation insert textobjects additional calendar))

        ;;; Org-mode Configuration
        (require 'org)

        ;; Org directory structure
        (setq org-directory "~/Documents/Org-Mode/")
        (setq org-default-notes-file (concat org-directory "inbox.org"))

        ;; Org agenda files
        (setq org-agenda-files
              (list (concat org-directory "todo.org")
                    (concat org-directory "notes.org")
                    (concat org-directory "class-notes.org")))

        ;; Visual improvements
        (require 'org-bullets)
        (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

        (require 'org-modern)
        (add-hook 'org-mode-hook 'org-modern-mode)
        (add-hook 'org-agenda-finalize-hook 'org-modern-agenda)

        (require 'org-appear)
        (add-hook 'org-mode-hook 'org-appear-mode)
        (setq org-appear-autolinks t)
        (setq org-appear-autosubmarkers t)
        (setq org-appear-autoentities t)

        ;; Better org-mode display
        (setq org-hide-emphasis-markers t)
        (setq org-pretty-entities t)
        (setq org-startup-indented t)
        (setq org-ellipsis " ▾")

        ;; Org TODO keywords
        (setq org-todo-keywords
              '((sequence "TODO(t)" "IN-PROGRESS(i)" "WAITING(w)" "|" "DONE(d)" "CANCELLED(c)")))

        ;; Org TODO keyword faces
        (setq org-todo-keyword-faces
              '(("TODO" . org-warning)
                ("IN-PROGRESS" . "yellow")
                ("WAITING" . "orange")
                ("DONE" . org-done)
                ("CANCELLED" . "grey")))

        ;; Org capture templates
        (setq org-capture-templates
              '(("t" "Task" entry (file+headline org-default-notes-file "Tasks")
                 "* TODO %?\n  %i\n  %a\n  %T")
                ("n" "Note" entry (file+headline org-default-notes-file "Notes")
                 "* %?\n  %i\n  %a\n  %T")
                ("j" "Journal" entry (file+datetree (concat org-directory "journal.org"))
                 "* %?\nEntered on %U\n  %i")
                ("m" "Meeting" entry (file+headline org-default-notes-file "Meetings")
                 "* MEETING %? :meeting:\n  %T\n  %i")))

        ;; Org refile targets
        (setq org-refile-targets
              '((org-agenda-files :maxlevel . 3)))
        (setq org-refile-use-outline-path 'file)
        (setq org-outline-path-complete-in-steps nil)

        ;; Org babel - code execution support
        (org-babel-do-load-languages
         'org-babel-load-languages
         '((emacs-lisp . t)
           (shell . t)
           (python . t)
           (js . t)))
        (setq org-confirm-babel-evaluate nil)  ; Don't prompt for confirmation
        (setq org-src-fontify-natively t)      ; Syntax highlighting in source blocks
        (setq org-src-tab-acts-natively t)     ; Tab acts as in native mode

        ;; Org-download for images
        (require 'org-download)
        (add-hook 'dired-mode-hook 'org-download-enable)
        (setq-default org-download-image-dir (concat org-directory "images/"))

        ;; Org-pomodoro
        (require 'org-pomodoro)
        (setq org-pomodoro-length 25)
        (setq org-pomodoro-short-break-length 5)
        (setq org-pomodoro-long-break-length 15)

        ;; Key bindings
        (global-set-key (kbd "C-c l") 'org-store-link)
        (global-set-key (kbd "C-c a") 'org-agenda)
        (global-set-key (kbd "C-c c") 'org-capture)
        (global-set-key (kbd "C-c b") 'org-switchb)

        ;; Additional org-mode hooks
        (add-hook 'org-mode-hook 'visual-line-mode)
        (add-hook 'org-mode-hook 'org-indent-mode)

        ;;; End of Org-mode Configuration
      '';
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
      # Tree-sitter dependencies for :TSInstallFromGrammar
      extraPackages = with pkgs; [
        tree-sitter  # Tree-sitter parser generator
        nodejs      # Node.js for tree-sitter grammar compilation
      ];
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
        wrap = true;
        cursorline = true;
        # Allow cursor to wrap to next/previous line with arrow keys
        whichwrap = "b,s,<,>,[,]";
        # Enable system clipboard integration
        clipboard = "unnamedplus";
        # Timeout settings for better plugin compatibility
        timeoutlen = 1000;
        updatetime = 300;
      };
      plugins = {
        avante = {
          enable = true;
          settings = {
            provider = "openrouter";
            auto_suggestions_provider = "openrouter";
            providers = {
              copilot = {
                __raw = ''
                  {
                    parse_curl_args = function() return {} end,
                    parse_response_data = function() return "" end,
                    list_models = function() return {} end,
                  }
                '';
              };
              openrouter = {
                __inherited_from = "openai";
                api_key_name = "OPENROUTER_API_KEY";
                endpoint = "https://openrouter.ai/api/v1";
                model = "anthropic/claude-sonnet-4.5";
                timeout = 30000;
                model_names = [
                  # Anthropic Claude 
                  "anthropic/claude-sonnet-4.5"    
                  "anthropic/claude-haiku-4.5"     
                  "anthropic/claude-opus-4.1"      

                  # OpenAI
                  "openai/gpt-4.1"                 
                  "openai/gpt-4o"                  
                  "openai/gpt-4o-mini"             

                  # Google Gemini
                  "google/gemini-2.5-pro"          
                  "google/gemini-2.5-flash"        
                  "google/gemini-2.5-pro-exp-03-25:free" 

                  # DeepSeek 
                  "deepseek/deepseek-r1"           
                  "deepseek/deepseek-r1:free"      

                  # Meta Llama 
                  "meta-llama/llama-4-maverick:free"      
                  "meta-llama/llama-3.3-70b-instruct:free"
                ];
                extra_request_body = {
                  temperature = 0;
                  max_tokens = 4096;
                };
              };
            };
          };
        };
        codecompanion = {
          enable = true;
          settings = {
            # Configure adapters using the new http structure
            adapters = {
              http = {
                anthropic = {
                  __raw = ''
                    function()
                      return require("codecompanion.adapters").extend("anthropic", {
                        env = {
                          api_key = "ANTHROPIC_API_KEY",
                        },
                      })
                    end
                  '';
                };
                openai = {
                  __raw = ''
                    function()
                      return require("codecompanion.adapters").extend("openai", {
                        env = {
                          api_key = "OPENAI_API_KEY",
                        },
                      })
                    end
                  '';
                };
                openrouter = {
                  __raw = ''
                    function()
                      return require("codecompanion.adapters").extend("openai", {
                        env = {
                          api_key = "OPENROUTER_API_KEY",
                        },
                        url = "https://openrouter.ai/api/v1/chat/completions",
                        schema = {
                          model = {
                            default = "anthropic/claude-4.5-sonnet",
                          },
                        },
                      })
                    end
                  '';
                };
              };
            };
            # Set strategies to use specific adapters
            strategies = {
              chat = {
                adapter = "anthropic";
              };
              inline = {
                adapter = "anthropic";
              };
            };
            # Enable debug logging and other options
            opts = {
              log_level = "DEBUG";
              send_code = true;
              use_default_actions = true;
              use_default_prompts = true;
            };
            # Configure display settings for better autocomplete
            display = {
              action_palette = {
                provider = "default";
                opts = {
                  show_default_prompt_library = true;
                };
              };
              chat = {
                window = {
                  layout = "vertical";
                  opts = {
                    breakindent = true;
                  };
                };
              };
            };
          };
        };
        orgmode = {
          enable = true;
          settings = {
            org_agenda_files = [ "~/Documents/Org-Mode/*.org" ];
            org_default_notes_file = "~/Documents/Org-Mode/notes.org";
            org_todo_keywords = [ "TODO" "NEXT" "DOING" "|" "DONE" ];
          };
        };
        which-key.enable = true;
        telescope.enable = true;
        treesitter = {
          enable = true;
          grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
            lua
            nix
            python
            json
            yaml
            markdown
            markdown_inline
            bash
            javascript
            html
            css
          ];
          settings = {
            indent.enable = true;
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
        # Enable nvim-cmp for CodeCompanion autocomplete
        cmp = {
          enable = true;
          settings = {
            completion = {
              completeopt = "menu,menuone,noinsert";
            };
            preselect = "None";
            sources = [
              { name = "nvim_lsp"; }
              { name = "luasnip"; }
              { name = "buffer"; }
              { name = "path"; }
            ];
            mapping = {
              __raw = ''
                {
                  ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                  ['<C-f>'] = cmp.mapping.scroll_docs(4),
                  ['<C-Space>'] = cmp.mapping.complete(),
                  ['<C-e>'] = cmp.mapping.abort(),
                  ['<CR>'] = cmp.mapping.confirm({ select = true }),
                  ['<Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                      cmp.select_next_item()
                    elseif luasnip and luasnip.expand_or_jumpable() then
                      luasnip.expand_or_jump()
                    else
                      fallback()
                    end
                  end, { 'i', 's' }),
                  ['<S-Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                      cmp.select_prev_item()
                    elseif luasnip and luasnip.jumpable(-1) then
                      luasnip.jump(-1)
                    else
                      fallback()
                    end
                  end, { 'i', 's' }),
                  ['<Down>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                      cmp.select_next_item()
                    else
                      fallback()
                    end
                  end, { 'i', 's', 'c' }),
                  ['<Up>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                      cmp.select_prev_item()
                    else
                      fallback()
                    end
                  end, { 'i', 's', 'c' }),
                }
              '';
            };
          };
        };
        luasnip.enable = true;
        comment.enable = true;
        nvim-autopairs.enable = true;
        nvim-surround.enable = true;
        # indent-blankline.enable = true;
        gitsigns.enable = true;
        diffview = {
          enable = true;
          settings = {
            # Remove hg_cmd since it's not available and not needed
            # hg_cmd = "hg";  # Commented out to avoid warning
          };
        };
        lualine.enable = true;
        bufferline.enable = true;
        colorizer.enable = true;
        dressing.enable = true;
        oil.enable = true;
        flash.enable = true;
        visual-multi.enable = true;
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
          # Org files - Neovim as default, but other editors available
          org-edit = [
            { run = "nvim \"$@\""; block = true; orphan = true; desc = "Neovim"; }
            { run = "kitty -e nvim \"$@\""; desc = "Nvim"; }
            { run = "emacs \"$@\""; desc = "Emacs"; }
            { run = "kitty -e hx \"$@\""; desc = "Helix"; }
            { run = "retext \"$@\""; desc = "ReText"; }
            { run = "okular \"$@\""; desc = "Okular"; }
            { run = "onlyoffice-desktopeditors \"$@\""; desc = "OnlyOffice"; }
            { run = "zeditor \"$@\""; desc = "Zed Editor"; }
            { run = "code \"$@\""; desc = "VS Code"; }
            { run = "cursor \"$@\""; desc = "Cursor"; }
            { run = "kate \"$@\""; desc = "Kate"; }
            { run = "lapce \"$@\""; desc = "Lapce"; }
            { run = "ghostwriter \"$@\""; desc = "Ghostwriter"; }
            { run = "apostrophe \"$@\""; desc = "Apostrophe"; }
            { run = "${config.home.homeDirectory}/.config/scripts/app-picker.sh \"$@\""; desc = "Application Picker"; }
          ];

          # Text files
          edit = [
            { run = "$EDITOR \"$@\""; block = true; for = "unix"; }
            { run = "kitty -e nvim \"$@\""; desc = "Neovim"; }
            { run = "kitty -e hx \"$@\""; desc = "Helix"; }
            { run = "retext \"$@\""; desc = "ReText"; }
            { run = "okular \"$@\""; desc = "Okular"; }
            { run = "onlyoffice-desktopeditors \"$@\""; desc = "OnlyOffice"; }
            { run = "zeditor \"$@\""; desc = "Zed Editor"; }
            { run = "emacs \"$@\""; desc = "Emacs"; }
            { run = "code \"$@\""; desc = "VS Code"; }
            { run = "cursor \"$@\""; desc = "Cursor"; }
            { run = "kate \"$@\""; desc = "Kate"; }
            { run = "lapce \"$@\""; desc = "Lapce"; }
            { run = "ghostwriter \"$@\""; desc = "Ghostwriter"; }
            { run = "apostrophe \"$@\""; desc = "Apostrophe"; }
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
            # Org-mode files - always use Neovim
            { name = "*.org"; use = [ "org-edit" "reveal" ]; }

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
    caffeine.enable = lib.mkForce false;

    tomat.enable = true;
    
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

  # systemd.user.services."caffeine-ng" =
  #   let
  #     caffeineLauncher = pkgs.writeShellScript "launch-caffeine-ng" ''
  #       if [[ ${"$"}{XDG_CURRENT_DESKTOP:-} == *KDE* ]]; then
  #         exec ${pkgs.caffeine-ng}/bin/caffeine
  #       else
  #         exit 0
  #       fi
  #     '';
  #   in {
  #   Unit = {
  #     Description = "Caffeine-ng (conditional launch)";
  #     PartOf = [ "graphical-session.target" ];
  #     After = [ "graphical-session.target" ];
  #   };
  #   Service = {
  #     ExecStart = caffeineLauncher;
  #     Restart = "on-failure";
  #   };
  #   Install = {
  #     WantedBy = [ "graphical-session.target" ];
  #   };
  # };

  systemd.user.services."import-wayland-environment" =
    let
      importScript = pkgs.writeShellScript "import-wayland-environment" ''#!/usr/bin/env bash
        set -eu

        find_wayland_display() {
          if [ -n "''${WAYLAND_DISPLAY:-}" ]; then
            return 0
          fi
          if [ -n "''${XDG_RUNTIME_DIR:-}" ]; then
            guess=$(ls "''${XDG_RUNTIME_DIR}"/wayland-* 2>/dev/null | head -n1 || true)
            if [ -n "$guess" ]; then
              export WAYLAND_DISPLAY="$(basename "$guess")"
              return 0
            fi
          fi
          return 1
        }

        for _ in $(seq 1 20); do
          if find_wayland_display; then
            break
          fi
          sleep 0.25
        done

        if [ -z "''${DISPLAY:-}" ] && [ -n "''${WAYLAND_DISPLAY:-}" ]; then
          export DISPLAY=":0"
        fi

        if [ -z "''${XDG_CURRENT_DESKTOP:-}" ]; then
          if [ -n "''${DESKTOP_SESSION:-}" ]; then
            export XDG_CURRENT_DESKTOP="''${DESKTOP_SESSION}"
          else
            export XDG_CURRENT_DESKTOP="WaylandSession"
          fi
        fi

        systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP || true
        dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP || true

        # Restart portal backends to ensure they see the updated environment
        systemctl --user start --no-block xdg-desktop-portal-kde.service || true
        systemctl --user restart --no-block xdg-desktop-portal.service || true
      '';
    in {
      Unit = {
        Description = "Import Wayland environment for portals";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = importScript;
        RemainAfterExit = false;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  
  home.sessionVariables = {
    # NNN_OPENER = "/home/${user}/scripts/file-ops/linkhandler.sh";
    # NNN_FCOLORS = "$BLK$CHR$DIR$EXE$REG$HARDLINK$SYMLINK$MISSING$ORPHAN$FIFO$SOCK$OTHER";
    NNN_TRASH = 1;
    NNN_FIFO = "/tmp/nnn.fifo";
    
    # API Keys for Neovim plugins (overridden by ~/.env.secrets if it exists)
    AVANTE_ANTHROPIC_API_KEY = "";
    AVANTE_OPENAI_API_KEY = "";
    AVANTE_OPENROUTER_API_KEY = "";
    ANTHROPIC_API_KEY = "";
    OPENAI_API_KEY = "";
    OPENROUTER_API_KEY = "";
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

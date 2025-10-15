# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, lib, pkgs, inputs, username, ... }:

{ # Common-config.nix

  # Allow unfree/insecure packages
  nixpkgs.config.allowUnfree = true;
               
  imports = [
    ./networking.nix
    ./security.nix
    # ./determinate.nix
    ./system-theme.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  ### Shell
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  ### System settings
  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Experimental Features
  nix.settings = {
    accept-flake-config = true;
    experimental-features = [ "nix-command" "flakes" ];
  };
  # Set $NIX_PATH to Flake input - suggested for nixd LSP to ensure <nixpkgs> reference works as expected
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
 
   # Housekeeping
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 20d";
  };
  # system.autoUpgrade.enable = false; 

  # Increase inotify watch limit:
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 1048576;

  ### Users
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    shell = pkgs.fish;
    isNormalUser = true;
    description = "${builtins.substring 0 1 (lib.toUpper username)}${builtins.substring 1 (builtins.stringLength username) username}";
    extraGroups =
      [ "networkmanager" "wheel" "video" "audio" "jackaudio" "lp" "surface-control" "uinput" ];
    packages = [
        # User packages may also go into Home.nix if using home-manager
      ];
  };

  ### Packages
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [

    ## A few of my favorite things that I want on every new install
    alacritty # A cross-platform, GPU-accelerated terminal emulator
    axel # Console downloading program with some features for parallel connections for faster downloading
    btop # User-friendly TUI resource monitor
    browsh # Modern TUI browser
    duf # Disk Usage/Free Utility
    fd # a simple, fast and user-friendly alternative to find
    fh # Official FlakeHub CLI
    fzf # Command-line fuzzy finder written in go
    firefox # Firefox browser
    git # Git CLI utility
    gparted # Disk/Partition manager
    htop # Human readable CLI top utility
    kitty # A modern, hackable, featureful, OpenGL based terminal emulator - Default Terminal for Hyprland
    mc # File Manager and User Shell for the GNU Project, known as Midnight Commander
    micro # Modern and intuitive terminal-based text editor
    neovim # Vim text editor fork focused on extensibility and agility
    nnn # Small ncurses-based file browser forked from noice
    pcloud # Synced cloud file storage service - similar to Dropbox
    kdePackages.qtwayland # Qt6 Wayland support
    ranger # File manager with minimalistic curses interface
    ripgrep # Utility that combines the usability of The Silver Searcher with the raw speed of grep
    wget # Tool for retrieving files using HTTP, HTTPS, and FTP

  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  ### Utilities
  programs.nix-ld.enable = true; # Nix-ld ALlows for more normal running of linux binaries on Nix without repackaging or patching with autoPatchelfHook

  ### Services
  # List services that you want to enable:

  #Services - locate:
  services.locate.enable = true;
  services.locate.package = pkgs.plocate;

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # OOM
  systemd.oomd.enable = true;

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    cups-pdf.enable = true;
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable Hardware. Components
  hardware = {
    bluetooth.enable = true;
    graphics.enable = true;
    uinput.enable = true; # Needed for ydotool
  };

  services = { 
    blueman.enable = true;
    pulseaudio.enable = false;
  };
  
  # Enable sound with pipewire.
  security.rtkit.enable = true;
  
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true; 
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;
    
    # Enable screen capture support for OBS/portal integration
    extraConfig.pipewire."10-screen-capture" = {
      "context.modules" = [
        {
          name = "libpipewire-module-portal";
          args = { };
        }
      ];
    };
  };
   
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;


  ### System state version - No touchy!
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}

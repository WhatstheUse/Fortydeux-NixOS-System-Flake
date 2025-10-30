{
config,
pkgs,
...
}:

{
  # Enable Flatpaks
  services.flatpak.enable = true;

  environment.systemPackages = with pkgs; [

    ## CLI Tools
    appimage-run # Utility for running AppImage format
    feh # Very handy CLI photo/slideshow tool
    ffmpeg # FFmpeg is the leading multimedia framework, able to decode, encode, transcode, mux, demux, stream, filter and play pretty much anything that humans and machines have created. It supports the most obscure ancient formats up to the cutting edge. No matter if they were designed by some standards committee, the community or a corporation.
    jq # A lightweight and flexible command-line JSON processor
    mpv # General-purpose media player, fork of MPlayer and mplayer2
    nix-prefetch-github # Prefetch sources from github
    nmap # Network mapping utility
    pavucontrol # PulseAudio Volume Control
    tlp # Advanced Power Management for Linux
    vim # The most popular clone of the VI editor
    wcalc # A command line calculator

    wireplumber

    ## GUI Applications
    baobab # Disk Usage Analyzer
    #   blender #3D Creation/Animation/Publishing System
    brave # Brave Browser
    # betterbird # Betterbird is a fine-tuned version of Mozilla Thunderbird, Thunderbird on steroids, if you will - leaving TBird installed bc BT uses same profile, but runs better on Wayland with HIDPI scaling
    chromium # Chromium browser
    kdePackages.discover # KDE and Plasma resources management GUI
    foot # A fast, lightweight and minimalistic Wayland terminal emulator
    fish # Smart and user-friendly command line shell
    # gnome-calculator # Gnome GUI calculator
    kdePackages.kcalc # KDE Calculator
    qalculate-qt # QT-based Desktop Calculator
    gnome-calendar # Gnome GUI calendar
    kdePackages.partitionmanager # Manage the disk devices, partitions and file systems on your computer
    kitty-themes # Themes for the kitty terminal emulator
    krita # A free and open source painting application
    lapce # Lightning-fast and Powerful Code Editor written in Rust
    # librewolf # A fork of Firefox, focused on privacy, security and freedom
    kdePackages.kate # Plasma text editor
    # monitor # ElementayOS/Pantheon package for managing processes and monitoring system resources
    # pcloud #Previously using nix-env -f channel:nixos-22.11 -iA pcloud instead (seemed to be broken package issue with patchelf https://github.com/NixOS/nixpkgs/issues/226339)
    nautilus # Gnome File Manager
    tor-browser # Tor Browser Bundle built by torproject.org
    vscodium # Open source source code editor developed by Microsoft for Windows, Linux and macOS (VS Code without MS branding/telemetry/licensing)
    wezterm # GPU-accelerated cross-platform terminal emulator and multiplexer written by wez and implemented in Rust

    ## Wine
    samba

    ## Caffeine
    caffeine-ng

    ## Utilities
    foo2zjs    

    ## Theming
    # themechanger #Theme changing utility for Linux
  ];

  ## More Wine
  programs.xwayland = {
    enable = true;
  };
}

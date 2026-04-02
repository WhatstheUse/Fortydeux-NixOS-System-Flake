{ config, pkgs, ... }: 

{ # Fun-and-games.nix
	
  # Enable Steam - Steam games distribution
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # 32-bit graphics support - required for SteamVR and many Steam games
  hardware.graphics.enable32Bit = true;

  # SteamVR udev rules - NixOS fix for "requires superuser privileges" error.
  # SteamVR's setup script tries to write udev rules to /etc/udev/rules.d/,
  # which is read-only on NixOS. This declares them properly instead.
  hardware.steam-hardware.enable = true;

  # Extra packages for Intel QuickSync
  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver
    intel-vaapi-driver
  ];

  # Enable sunshine for streaming to Moonlight client
  services.sunshine = {
    enable = true;

    openFirewall = true;

    capSysAdmin = true; # required for input control
  };
  
  # Open firewall for iVRy (iPhone as SteamVR headset over WiFi)
  # iVRy uses UDP 5555 for video streaming and TCP 5556 for control
  networking.firewall.allowedUDPPorts = [ 5555 ];
  networking.firewall.allowedTCPPorts = [ 5556 ];

  environment.systemPackages = with pkgs; [
    ## Games support
    lutris #Open Source gaming platform for GNU/Linux
 
    ## Candy - not necessary
    cava #Console-based Audio Visualizer for Alsa
    cbonsai #Grow bonsai trees in your terminal
    cmatrix #Simulates the falling characters theme from The Matrix movie
    cool-retro-term #erminal emulator which mimics the old cathode display
    distrobox
    hollywood #Fill your console with Hollywood melodrama technobabble
    lolcat # A rainbow for your text output
    nms #A command line tool that recreates the famous data decryption effect seen in the 1992 movie Sneakers.
    pipes #Animated pipes terminal screensaver
    tty-clock #Digital clock in ncurses
    vitetris #Terminal-based Tetris clone by Victor Nilsson
  ];

}

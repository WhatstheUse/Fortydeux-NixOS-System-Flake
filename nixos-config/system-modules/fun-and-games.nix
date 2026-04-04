{ config, pkgs, ... }: 

{ # Fun-and-games.nix
	
  # Enable Steam - Steam games distribution
  # programs.steam = {
  #   enable = true;
  #   remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  #   dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  # };

  # 32-bit graphics support - required for SteamVR and many Steam games
  hardware.graphics.enable32Bit = true;

  # SteamVR udev rules - NixOS fix for "requires superuser privileges" error.
  # SteamVR's setup script tries to write udev rules to /etc/udev/rules.d/,
  # which is read-only on NixOS. This declares them properly instead.
  hardware.steam-hardware.enable = true;

  # Extra packages for AMD Radeon 680M (RDNA2) - required for ALVR/SteamVR
  # RADV (Vulkan) is included in mesa by default; rocm provides OpenCL compute
  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr   # ROCm OpenCL runtime for compute
    mesa               # Includes radeonsi VAAPI driver for hardware video encode/decode
  ];

  # Enable ALVR
  programs.alvr = {
    enable = true;
    openFirewall = true;
  };

  # VAAPI environment for ALVR/SteamVR hardware video encoding on AMD
  # NixOS puts VAAPI drivers in /run/opengl-driver/lib/dri rather than /usr/lib/dri
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "radeonsi";
    LIBVA_DRIVERS_PATH = "/run/opengl-driver/lib/dri";
  };
  
  
  # Enable sunshine for streaming to Moonlight client
  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true; # required for input control
  };

  services.monado = {
    enable = true;
    highPriority = true;
  };

  # Explicitly set XR_RUNTIME_JSON in /etc/environment so Wayland compositors
  # like Niri (which don't source shell profiles) can find Monado
  environment.variables.XR_RUNTIME_JSON = "${pkgs.monado}/share/openxr/1/openxr_monado.json";
  
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
    wayvr  # VR on Linux
    wl-mirror # Mirror Wayland outputs into WayVR for desktop-in-VR
  ];

}

{ config, pkgs, inputs, ... }: 

{ # Fun-and-games.nix

  # Modules
  # imports = [
  #   inputs.nixpkgs-xr.nixosModules.nixpkgs-xr
  # ]; 


	
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

  programs.immersed = {
    enable = true;
  };

  # Enable ALVR - wireless PC VR streaming via SteamVR
  programs.alvr = {
    enable = true;
    openFirewall = true;
  };

  programs.envision = {
    enable = true;
    openFirewall = true; # This is set true by default
  };

  # Enable sunshine for streaming to Moonlight client
  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true; # required for input control
  };

  # Enable WiVRN - wireless PC VR streaming (native OpenXR, wraps Monado internally)
  # Both ALVR and WiVRN can coexist; switch active runtime via XR_RUNTIME_JSON
  services.wivrn = {
    enable = true;
    openFirewall = true;  # opens TCP/UDP 9757
    highPriority = true;  # CAP_SYS_NICE for async reprojection
    steam.enable = true;  # integrate with Steam OpenXR discovery
  };

  # Monado - standalone OpenXR runtime (for directly-connected headsets, no streaming)
  # Re-enable if you want Monado instead of / alongside WiVRN.
  # Note: disable services.wivrn above first, or they will conflict on the OpenXR runtime.
  # services.monado = {
  #   enable = true;
  #   highPriority = true;
  # };

  # Explicitly set XR_RUNTIME_JSON in /etc/environment so Wayland compositors
  # like Niri (which don't source shell profiles) can find the active OpenXR runtime.
  # WiVRN:  "${pkgs.wivrn}/share/openxr/1/openxr_wivrn.json"
  # Monado: "${pkgs.monado}/share/openxr/1/openxr_monado.json"
  # ALVR uses the SteamVR OpenXR layer rather than XR_RUNTIME_JSON
  # environment.variables.XR_RUNTIME_JSON = "${pkgs.wivrn}/share/openxr/1/openxr_wivrn.json";
  
  # Open firewall for iVRy (iPhone as SteamVR headset over WiFi)
  # iVRy uses UDP 5555 for video streaming and TCP 5556 for control
  networking.firewall.allowedUDPPorts = [ 5555 ];
  networking.firewall.allowedTCPPorts = [ 5556 ];

  environment.systemPackages = with pkgs; [
    ## Games support
    lutris #Open Source gaming platform for GNU/Linux
 
    ## Candy - not necessary
    cava # Console-based Audio Visualizer for Alsa
    cbonsai # Grow bonsai trees in your terminal
    cmatrix # Simulates the falling characters theme from The Matrix movie
    cool-retro-term # Terminal emulator which mimics the old cathode display
    distrobox
    hollywood # Fill your console with Hollywood melodrama technobabble
    lolcat # A rainbow for your text output
    nms #A command line tool that recreates the famous data decryption effect seen in the 1992 movie Sneakers.
    pipes # Animated pipes terminal screensaver
    tty-clock # Digital clock in ncurses
    vitetris # Terminal-based Tetris clone by Victor Nilsson
    android-tools # Android SDK platform tools
    opencomposite # Reimplementation of OpenVR, translating calls to OpenXR Open app store and side-loading tool for Android-based VR devices
    sidequest # 
    wayvr  # VR on Linux
    wl-mirror # Mirror Wayland outputs into WayVR for desktop-in-VR
  ];

}

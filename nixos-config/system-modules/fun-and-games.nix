{ config, pkgs, inputs, ... }: 

{ # Fun-and-games.nix

  # Graphics Card Control
  services.lact = {
    enable = true;
  };

	
  # Enable Steam - Steam games distribution
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server

    # Desktop streaming (e.g. to the Steam Frame) needs PipeWire screen capture
    # on Wayland - Steam's X11 capture path does not work there. Without this
    # flag Steam logs "Desktop capture unavailable, try running Steam with
    # -pipewire" and the Desktop entry never appears on the headset.
    # extraArgs feeds the wrapper (exec steam $extraArgs "$@"), so it applies to
    # every launch path: app launcher, terminal, and steam:// URL handler.
    package = pkgs.steam.override { extraArgs = "-pipewire"; };
  };

  # 32-bit graphics support - required for SteamVR and many Steam games
  hardware.graphics.enable32Bit = true;

  # SteamVR udev rules - NixOS fix for "requires superuser privileges" error.
  # SteamVR's setup script tries to write udev rules to /etc/udev/rules.d/,
  # which is read-only on NixOS. This declares them properly instead.
  hardware.steam-hardware.enable = true;

  # Wi-Fi regulatory domain - required for the Steam Frame wireless dongle
  # (Valve 28de:2432, driven by rtw89_8852cu on kernel >= 7.2).
  # The dongle links to the headset on 6 GHz only. Under the default world
  # domain ("00") the kernel marks all 50 of its 6 GHz channels as disabled,
  # so the dongle enumerates and loads firmware but never sees the headset.
  # Set the domain that actually matches our location (America/New_York -> US).
  # Note: only set a domain you are actually located in.
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="US"
  '';

   # Set by networkmanager - should not be necessary
   # hardware.wirelessRegulatoryDatabase = true;

  programs.immersed = {
    enable = true;
  };

  # Enable ALVR - wireless PC VR streaming via SteamVR
  programs.alvr = {
    enable = true;
    openFirewall = true;
  };

  # programs.envision = {
  #   enable = true;
  #   openFirewall = true; # This is set true by default
  # };

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
    # lutris #Open Source gaming platform for GNU/Linux
 
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
    # sidequest # Now marked as "insecure" - 10/9/26 
    wayvr  # VR on Linux
    wl-mirror # Mirror Wayland outputs into WayVR for desktop-in-VR
  ];

}

# audio-prod.nix - Professional Audio Configuration with PipeWire + JACK compatibility
{ lib, pkgs, inputs, username, ... }:

{
  imports = [
    inputs.musnix.nixosModules.musnix
  ];

  # Real-time audio optimizations via musnix
  musnix = {
    enable = true;
    rtcqs.enable = true;
    ffado.enable = true;
    rtirq = {
      resetAll = 1;
      prioLow = 0;
      enable = true;
      nameList = "rtc0 snd";
    };
  };

  # FireWire DMA timeout prevention
  boot.kernelParams = [
    "firewire_ohci.quirks=0x2"    # Enable compatibility quirks
    "firewire_ohci.debug=0"       # Reduce debug overhead
  ];

  # For PipeWire, we may need ALSA FireWire drivers
  # Temporarily disable blacklisting to test PipeWire integration
  # boot.blacklistedKernelModules = [
  #   "snd_dice"
  #   "snd_firewire_lib"
  #   "snd_firewire_digi00x"
  #   "snd_firewire_tascam"
  #   "snd_firewire_motu"
  #   "snd_bebob"
  #   "snd_oxfw"
  # ];

  # Prevent power management interference with FireWire audio
  services.udev.extraRules = ''
    # Keep FireWire controller active
    SUBSYSTEM=="pci", ATTR{vendor}=="0x1106", ATTR{device}=="0x3044", ATTR{power/control}="on"
    SUBSYSTEM=="firewire", ACTION=="add", ATTR{power/control}="on"
    # Keep FireWire audio interfaces active
    SUBSYSTEM=="firewire", ATTR{vendor}=="0x00130e", ATTR{power/control}="on"
  '';

  # Disable conflicting audio systems
  services.pulseaudio.enable = lib.mkForce false;
  hardware.bluetooth.enable = true;
  hardware.graphics.enable = true;
  
  # Enable RTKit for real-time scheduling
  security.rtkit.enable = true;

  # PipeWire with professional audio configuration
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    
    # Enable JACK compatibility
    jack.enable = true;

    # Low-latency configuration for professional audio
    extraConfig.pipewire."99-professional-audio" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.allowed-rates" = [ 44100 48000 88200 96000 ];
        "default.clock.quantum" = 256;
        "default.clock.min-quantum" = 256;
        "default.clock.max-quantum" = 256;
        "default.clock.force-quantum" = 256;
        "core.daemon" = true;
        "core.name" = "pipewire-0";
      };
      "context.modules" = [
        {
          name = "libpipewire-module-rt";
          args = {
            "nice.level" = -11;
            "rt.prio" = 88;
            "rt.time.soft" = 200000;
            "rt.time.hard" = 200000;
          };
        }
      ];
    };
    
    # WirePlumber configuration for FireWire devices
    wireplumber.extraConfig = {
      "50-ffado-firewire" = {
        "monitor.ffado" = {
          "enabled" = true;
        };
      };
      "51-firewire-pro-audio" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              { "device.bus" = "firewire"; }
              { "alsa.card_name" = "~.*Pro40.*"; }
            ];
            actions = {
              "update-props" = {
                "api.alsa.period-size" = 256;
                "api.alsa.headroom" = 0;
                "session.suspend-timeout-seconds" = 0;
                "api.alsa.disable-mmap" = false;
                "api.alsa.disable-batch" = false;
                "audio.format" = "S32LE";
                "audio.channels" = 16;  # Saffire Pro 40 has 16 channels
              };
            };
          }
        ];
      };
      "52-daw-applications" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              { "application.name" = "~.*(Bitwig|Studio|JACK).*"; }
            ];
            actions = {
              "update-props" = {
                "api.alsa.period-size" = 256;
                "api.alsa.headroom" = 0;
                "session.suspend-timeout-seconds" = 0;
              };
            };
          }
        ];
      };
    };
  };

  # Professional audio packages
  environment.systemPackages = with pkgs; [
    # Core audio tools
    qjackctl           # JACK control GUI
    helvum             # PipeWire patchbay
    pavucontrol        # PulseAudio/PipeWire volume control
    
    # JACK ecosystem
    jack2              # JACK audio connection kit
    jack-example-tools # JACK utilities (jack_lsp, etc.)
    libjack2           # JACK library
    
    # FireWire audio support
    ffado              # FireWire audio drivers (kernel modules only)
    # Note: ffado-mixer requires ffado-dbus-server which is not packaged in NixOS
    # Use helvum/pavucontrol instead for device control

    # Audio bridges and plugins
    alsa-plugins       # ALSA plugins for compatibility

    # Professional audio applications (commented out due to build issues)
    # yabridge           # Windows VST bridge - Wine 32-bit linking failure in nixpkgs
    # yabridgectl        # yabridge control utility

    # Development tools (commented out due to build issues)
    # zrythm           # DAW - currently has build issues due to Cython/Python3.13 incompatibility
    # carla            # Plugin host - currently has build issues due to Python3.13 incompatibility
  ];

  # Environment variables for audio applications
  environment.variables = {
    # JACK compatibility
    PIPEWIRE_LATENCY = "256/48000";
    
    # Ensure audio applications can find PipeWire's JACK interface
    JACK_DEFAULT_SERVER = "pipewire";
  };

  # Audio group membership and limits
  users.users.${username}.extraGroups = [ "audio" "jackaudio" ];
  
  security.pam.loginLimits = [
    { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
    { domain = "@audio"; item = "rtprio"; type = "-"; value = "99"; }
    { domain = "@audio"; item = "nofile"; type = "soft"; value = "99999"; }
    { domain = "@audio"; item = "nofile"; type = "hard"; value = "99999"; }
  ];
}

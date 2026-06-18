{ config, pkgs, lib, inputs, ... }:

let
  # Kirigami QML path for Noctalia (workaround for libplasma override issue)
  # This is needed because libplasma's partial kirigami overrides the full kirigami package
  kirigamiQmlPath = "${lib.getLib pkgs.kdePackages.kirigami}/lib/qt-6/qml";

  # Bridge Stylix base16 colors into Noctalia v5's custom-palette format.
  # Upstream Stylix's noctalia target still guards on the old `programs.noctalia-shell`
  # option and writes a `colors` attr that no longer exists in the v5 module, so it
  # silently applies nothing. We map base16 -> Material tokens ourselves (same mapping
  # Stylix used) and feed it via programs.noctalia.customPalettes.
  c = config.lib.stylix.colors.withHashtag;
  stylixPalette = {
    mPrimary = c.base0D;
    mOnPrimary = c.base00;
    mSecondary = c.base0E;
    mOnSecondary = c.base00;
    mTertiary = c.base0C;
    mOnTertiary = c.base00;
    mError = c.base08;
    mOnError = c.base00;
    mSurface = c.base00;
    mOnSurface = c.base05;
    mSurfaceVariant = c.base01;
    mOnSurfaceVariant = c.base04;
    mOutline = c.base03;
    mShadow = c.base00;
    mHover = c.base0C;
    mOnHover = c.base00;
  };
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  # Noctalia desktop shell - shared across compositors
  programs.noctalia = {
    enable = true;
    # systemd.enable = true;

    # Custom palette derived from Stylix; written to ~/.config/noctalia/palettes/stylix.json
    customPalettes.stylix = {
      dark = stylixPalette;
      light = stylixPalette;
    };

    settings = {
      # Activate the Stylix-derived palette (source = custom + custom_palette name).
      theme = {
        mode = "dark";
        source = "custom";
        custom_palette = "stylix";
      };

      # v5 dropped general.radiusRatio/iRadiusRatio in favor of a single corner_radius_scale
      # (0 = square, 1 = default, 2 = extra rounded). 0.6 approximates the old reduced
      # rounding (radiusRatio 0.4); the reference points differ, so tune to taste in Settings.
      shell = {
        corner_radius_scale = 0.6;
      };

      # v5 dropped location.name; use address (geocoded) or explicit coordinates. Add a
      # state/country (e.g. "Allentown, PA") if the bare name geocodes ambiguously.
      location = {
        auto_locate = false;
        address = "Allentown";
      };

      # v5 moved the temperature unit out of location.useFahrenheit into [weather].
      # NOTE: the weather service only checks `unit == "imperial"` for Fahrenheit — the
      # example.toml "celsius | fahrenheit" comment is wrong, and any other value (including
      # the struct default "metric") renders Celsius. Enabled so the unit has an effect; set
      # enabled = false to turn weather off entirely.
      weather = {
        enabled = true;
        unit = "imperial";
      };

      # v5 replaced the flat lockScreen* keys with [lockscreen]; intensities are now 0.0-1.0
      # (old lockScreenBlur 30 -> 0.3). These only apply to Noctalia's own lock screen, which
      # you bypass via swayidle + swaylock. lockOnSuspend has no v5 equivalent (your swayidle
      # setup handles lock-on-suspend).
      lockscreen = {
        blur_intensity = 0.3;
        tint_intensity = 0.4;
      };

      # v5 replaced the flat idle.* timeouts with named [idle.behavior.*] blocks (seconds).
      # Disabled because idle/lock is managed by swayidle + swaylock; timeouts preserved
      # (converted from minutes) for reference if you re-enable Noctalia's idle handling.
      # The old suspendTimeout (70 min) has no built-in equivalent — define a custom
      # [idle.behavior.<name>] with a command if you want Noctalia to suspend.
      idle.behavior = {
        lock = {
          enabled = false;
          timeout = 1200;   # was 20 min
        };
        "screen-off" = {
          enabled = false;
          timeout = 3000;   # was 50 min
        };
      };

      # v5 bar model: flat arrays of widget-id strings under [bar.main] (was
      # bar.widgets.left/center/right with {id=...} objects). IDs are now lowercase/underscored
      # (SystemMonitor -> sysmon, ActiveWindow -> active_window, MediaMini -> media,
      # NotificationHistory -> notifications, ControlCenter -> control-center).
      bar.main = {
        start  = [ "launcher" "wallpaper" "clock" "sysmon" "active_window" ];
        center = [ "workspaces" ];
        end    = [ "media" "tray" "notifications" "clipboard" "network" "bluetooth" "volume" "brightness" "battery" "control-center" "session" ];
        capsule = true;
      };
      dock = {
        enabled = true;
        auto_hide = true;
        reserve_space = false;
      };
      # Per-widget settings moved to [widget.<name>] (was inline displayMode). The old
      # "icon-always"/"alwaysShow" both map to v5's default of always showing the label, so
      # these are explicit-but-default. (v5 battery.display_mode only accepts glyph|graphic,
      # so the literal "icon-always" value is intentionally not carried over.)
      widget = {
        battery = {
          show_label = true;
          hide_when_plugged = false;
          hide_when_full = false;
        };
        volume = {
          show_label = true;
        };
      };
    };
  };
}

{config, lib, pkgs, inputs, ...}:

{
  imports = [
    inputs.stylix.homeModules.stylix
  ];

  stylix = {
    enable = true;
    autoEnable = true;
    image = ../dotfiles/wallpapers/a_silhouette_of_trees_on_a_hill.jpg; 
    # image = pkgs.fetchurl {
    #   url = "https://www.pixelstalk.net/wp-content/uploads/2016/05/Epic-Anime-Awesome-Wallpapers.jpg";
    #   sha256 = "enQo3wqhgf0FEPHj2coOCvo7DuZv+x5rL/WIo4qPI50=";
    # };
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/valua.yaml";
    # https://tinted-theming.github.io/tinted-gallery/
    # # 3024, ayu-mirage, brewer, bright, chalk, circus, classic-dark, colors, da-one-black, default-dark, 
    # embers, equilibrium-dark, equilibrium-gray-dark, evenok-dark, framer, gigavolt, google-dark, gruber,
    # gruvbox-dark-hard, gruvbox-material-dark-hard, hardcore, harmonic16-dark, helios, horizon-dark,
    # horizon-terminal-dark, humanoid-dark, ia-dark, ir-black, isotope, macintosh, material-darker,
    # measured-dark,monokai, mountain, onedark-dark, outrun-dark, oxocarbon-dark, pandora,
    # papercolor-dark, phd, pico, pop, precious-dark-eleven, primer-dark, purpledream, qualia,
    # rose-pine, selenized-black, seti, snazzy, solarflare, solarized-dark, spacemacs, standardized-dark,
    # summercamp, summerfruit-dark, synth-midnight-dark, tarot, tokyo-city-dark, tokyo-city-terminal-dark,
    # tokyo-night-dark, tokyo-night-terminal-dark, tokyodark, tomorrow-night, tube, twilight, uwunicorn,
    # vulcan, windows-10, windows-95, windows-highcontrast, windows-nt, woodland, zenbones
    cursor = {
      package = pkgs.phinger-cursors;
      name = "phinger-cursors-light";
      size = 32;
    };
    targets = {
      fuzzel.enable = true;
    };
  };

  # GTK theming settings
  gtk = {
    enable = true;
    
    # Icon Theme - Critical for missing icons pavucontrol
    # iconTheme = {
    #   package = pkgs.kdePackages.breeze-icons;
    #   name = "breeze-dark";
    # };
   iconTheme = {
     package = pkgs.papirus-icon-theme;
     name = "Papirus-Dark";
   };
  };

  # Qt theming
  qt = {
      enable = true;
      # platformTheme.package = with pkgs.kdePackages; [
       #     plasma-integration
       #     # I don't remember why I put this is here, maybe it fixes the theme of the system setttings
       #     systemsettings
       # ];
       style = {
           package = pkgs.kdePackages.breeze;
           # name = "Breeze";
       };
   };
   # systemd.user.sessionVariables = lib.mkForce { QT_QPA_PLATFORMTHEME = "kde"; };
}

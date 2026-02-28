{
  description = "Fortydeux NixOS System and Home-manager Flake";

# Flake.nix

  inputs = {  
    # Determinate, Nix, and HM
    # determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/0.1";
    # nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2505"; # 25.05 from Flakehub - more stable Rust/kernel combo
    # nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.0"; # Unstable from Flakehub
	  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # Unstable from NixOS
    # Stable nixpkgs for Rust compatibility with MS Surface kernel
    # stable-nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2505"; # 25.05 from Flakehub
    # home-manager.url = "https://flakehub.com/f/nix-community/home-manager/0.1";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # nixos-hardware.url = "github:NixOS/nixos-hardware/a65b650d6981e23edd1afa1f01eb942f19cdcbb7";
  	home-manager = {
      url = "github:nix-community/home-manager";
      # url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Other Projects
    # NUR - Nix User Repository
    # nur = {
    #   url = "github:nix-community/NUR";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # Stylix theming
    # stylix.url = "https://flakehub.com/f/danth/stylix/0.1";
    stylix.url = "github:nix-community/stylix";
    # Niri compositor
    niri.url = "github:YaLTeR/niri";
    # Noctalia desktop shell for Wayland
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Wooz screen magnifier for Wayland
    wooz.url = "github:negrel/wooz";
    # Hyprland compositor + Plugins
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    hyprscroller = {
      url = "github:cpiber/hyprscroller";
      inputs.hyprland.follows = "hyprland";
    };
    hyprgrass = {
       url = "github:horriblename/hyprgrass";
       inputs.hyprland.follows = "hyprland"; # IMPORTANT
    };  
    hyprshell = {
      url = "github:H3rmt/hyprshell?ref=hyprshell-release";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    anyrun.url = "github:anyrun-org/anyrun";
    # Atuin shell history
    atuin = {
      url = "github:ellie/atuin/ea218c546f325ea408e4e10cefee5f5ac97b35b8";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Yazi file manager - using git version for latest fixes
    yazi = {
      url = "github:sxyazi/yazi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Scroll compositor (Sway fork with scrolling layout)
    scroll-flake = {
      url = "github:AsahiRocks/scroll-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #MusNix
    musnix.url = "github:musnix/musnix";
    # SOPS secrets management
    # sops-nix = {
    #   url = "github:Mic92/sops-nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };
  
  outputs = { self, nixpkgs, home-manager, atuin, ... }@inputs:
    let
      username = "fortydeux";  # Change this to your username

      # Theme configuration - three modes:
      # 1. Named theme (string): "gruvbox-material-dark-soft.yaml" - fetched from base16-schemes
      # 2. Custom theme (path): ./themes/my-custom-theme.yaml - local file in repo
      # 3. Wallpaper-derived (null): null - requires useWallpaper = true in home-theme.nix
      #
      # Base16 Tinted theming gallery: https://tinted-theming.github.io/tinted-gallery/
      # Recommended dark: valua, darkmoss, atlas, atelier-cave, atelier-savanna, darktooth,
      #   digital-rain, eris, espresso, gigavolt, gruvbox-dark-hard, gruvbox-material-dark-hard,
      #   measured-dark, mocha, moonlight, paraiso, phd, precious-dark-eleven, kanagawa,
      #   kanagawa-dragon, everforest-dark-hard, silk-dark, vice
      # Recommended light: da-one-paper, gruvbox-light/-soft/-material-light-soft, precious-light-warm
      base16Theme = "darkmoss.yaml";  # Named theme
      # base16Theme = ./themes/custom-gruvyrails.yaml;  # Custom theme file
      # base16Theme = null;  # Wallpaper-derived colors

      polarity = "dark";  # Theme polarity: "dark" or "light"
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {    
      nixosConfigurations = {
        #--Archerfish host--#
      	archerfish-nixos = lib.nixosSystem {
    	  	modules = [
    	  	  ./nixos-config/hosts/archerfish/configuration.nix
          ];
          specialArgs = { inherit inputs username base16Theme polarity; };
      	};
        #--Killifish host--#
      	killifish-nixos = lib.nixosSystem {
    	  	modules = [
    	  	  ./nixos-config/hosts/killifish/configuration.nix
          ];
          specialArgs = { inherit inputs username base16Theme polarity; };
      	};
        #--Pufferfish host--#
      	pufferfish-nixos = lib.nixosSystem {
    	  	modules = [
    	  	  ./nixos-config/hosts/pufferfish/configuration.nix
          ];
          specialArgs = { inherit inputs username base16Theme polarity; };
      	};
        #--Blackfin host--#
      	blackfin-nixos = lib.nixosSystem {
    	  	modules = [
    	  	  ./nixos-config/hosts/blackfin/configuration.nix
            ];
          specialArgs = { inherit inputs username base16Theme polarity; };
      	};
        #--Blacktetra host--#
        blacktetra-nixos = lib.nixosSystem {
          modules = [
            ./nixos-config/hosts/blacktetra/configuration.nix
          ];
          specialArgs = { inherit inputs username base16Theme polarity; };
        }; 

      };

      ##--Home-Manager Configuration--##     
      homeConfigurations = {
        #--Archerfish host--#
        "${username}@archerfish-nixos" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs username base16Theme polarity; };
    	    modules = [
            ./home-manager/hosts/archerfish-home.nix
          ];
        }; 
         #--Killifish host--#
        "${username}@killifish-nixos" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs username base16Theme polarity; };
    	    modules = [
            ./home-manager/hosts/killifish-home.nix
          ];
        }; 
         #--Pufferfish host--#
        "${username}@pufferfish-nixos" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs username base16Theme polarity; };
    	    modules = [
            ./home-manager/hosts/pufferfish-home.nix
          ];
        }; 
         #--Blackfin host--#
        "${username}@blackfin-nixos" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs username base16Theme polarity; };
    	    modules = [
            ./home-manager/hosts/blackfin-home.nix
          ];
        };
         #--Blacktetra host--#
        "${username}@blacktetra-nixos" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs username base16Theme polarity; };
          modules = [
            ./home-manager/hosts/blacktetra-home.nix
          ];
        }; 
      }; 
   }; 
} 

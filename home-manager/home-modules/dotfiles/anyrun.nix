{ config, lib, pkgs, inputs, ... }:

{
  programs.anyrun = {
    enable = true;
    # package = inputs.anyrun.packages.${pkgs.system}.anyrun;
    config = {
      x = { fraction = 0.5; };
      y = { fraction = 0.3; };
      width = { fraction = 0.3; };
      hideIcons = false;
      ignoreExclusiveZones = false;
      layer = "overlay";
      hidePluginInfo = false;
      closeOnClick = false;
      showResultsImmediately = false;
      maxEntries = null;
      plugins = [
        "${pkgs.anyrun}/lib/libapplications.so"
        "${pkgs.anyrun}/lib/libsymbols.so"
        "${pkgs.anyrun}/lib/libdictionary.so"
        "${pkgs.anyrun}/lib/libkidex.so"
        "${pkgs.anyrun}/lib/librandr.so"
        "${pkgs.anyrun}/lib/librink.so"
        "${pkgs.anyrun}/lib/libshell.so"
        "${pkgs.anyrun}/lib/libstdin.so"
        "${pkgs.anyrun}/lib/libtranslate.so"
        "${pkgs.anyrun}/lib/libwebsearch.so"
      ];
    };
    extraConfigFiles = {
      "websearch.ron".text = ''
        Config(          
          prefix: "?",
          // Options: Google, Ecosia, Bing, DuckDuckGo, Custom
          //
          // Custom engines can be defined as such:
          // Custom(
          //   name: "Searx",
          //   url: "searx.be/?q={}",
          // )
          //
          // NOTE: `{}` is replaced by the search query and `https://` is automatically added in front.
          engines: [DuckDuckGo]         )
      '';
    };
    extraCss = ''
      window {
        background: transparent;
      }

      box.main {
        padding: 5px;
        margin: 10px;
        border-radius: 10px;
        border: 1px solid @theme_selected_bg_color;
        background-color: @theme_bg_color;
        # box-shadow: 0 0 5px black;
      }

      text {
        min-height: 30px;
        padding: 5px;
        border-radius: 5px;
      }

      .matches {
        background-color: rgba(0, 0, 0, 0);
        border-radius: 10px;
      }

      box.plugin:first-child {
        margin-top: 5px;
      }

      box.plugin.info {
        min-width: 200px;
      }

      list.plugin {
        background-color: rgba(0, 0, 0, 0);
      }

      label.match.description {
        font-size: 10px;
      }

      label.plugin.info {
        font-size: 14px;
      }

      .match {
        background: transparent;
      }

      .match:selected {
        border-left: 4px solid @theme_selected_bg_color;
        background: transparent;
        animation: fade 0.1s linear;
      }

      @keyframes fade {
        0% {
          opacity: 0;
        }

        100% {
          opacity: 1;
        }
      }     
    '';
  };
}

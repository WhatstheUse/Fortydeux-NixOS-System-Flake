{
config,
pkgs,
...
}:

{
  environment.systemPackages = with pkgs; [
    ## Build tools
    cargo # Downloads your Rust project's dependencies and builds your project
    clang # C language frontend
    rustc # Rust language wrapper
    # (python311.withPackages
    #   (ps: with ps; [ pycairo pygobject3 ])) # Python3.11 with packages

    ## Office Packages
    libreoffice-qt6-fresh # Comprehensive, professional-quality productivity suite, a variant of openoffice.org
    onlyoffice-desktopeditors # Office suite that combines text, spreadsheet and presentation editors allowing to create, view and edit local documents

    ## Wine
    winetricks
    wineWow64Packages.stable
    
  ];

}

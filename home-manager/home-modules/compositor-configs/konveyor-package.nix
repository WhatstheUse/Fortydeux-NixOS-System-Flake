{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "konveyor";
  version = "0.1.0-unstable-2026-11-17";

  src = pkgs.fetchFromGitHub {
    owner = "DevL0rd";
    repo = "Konveyor";
    rev = "178b9f2291401a1bdf644ca1019d0940ae777231";
    hash = "sha256-pmtElHAur3/FESpevtlJ/zutRjrA1AZik8hb2PnAiEY=";
  };

  nativeBuildInputs = with pkgs; [
    cmake
    ninja
    pkg-config
    kdePackages.extra-cmake-modules
    qt6.wrapQtAppsHook
  ];

  buildInputs =
    with pkgs;
    [
      libxcb
      libxkbcommon
      pipewire
      xcbutilwm
      qt6.qtbase
      qt6.qtdeclarative
      qt6.qtshadertools
    ]
    ++ (with kdePackages; [
      kcmutils
      kcolorscheme
      kconfig
      kconfigwidgets
      kcoreaddons
      kdecoration
      kglobalaccel
      ki18n
      knotifications
      kservice
      kwindowsystem
      kwin
      libplasma
    ]);

  cmakeFlags = [
    "-DKDE_INSTALL_USE_QT_SYS_PATHS=ON"
    "-DKONVEYOR_BUILD_TESTS=OFF"
  ];

  meta = {
    description = "Scrolling column tiling effect for KDE Plasma KWin";
    homepage = "https://github.com/DevL0rd/Konveyor";
    license = pkgs.lib.licenses.gpl3Plus;
    platforms = pkgs.lib.platforms.linux;
  };
}

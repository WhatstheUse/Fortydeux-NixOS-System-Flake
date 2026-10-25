{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "konveyor";
  version = "0.1.0-unstable-2026-10-25";

  src = pkgs.fetchFromGitHub {
    owner = "DevL0rd";
    repo = "Konveyor";
    rev = "33b3fe1edf7099ab4fb965631ce7873a80b963c2";
    hash = "sha256-MD8aOsMkFnoKMNZPU+Oz8ZFoLipEvZAOfskbxVCM4jM=";
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
      xcbutilwm
      qt6.qtbase
      qt6.qtdeclarative
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

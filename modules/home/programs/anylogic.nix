{pkgs, ...}: {
  home.packages = [pkgs.anylogic];

  xdg.dataFile."applications/anylogic.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=AnyLogic PLE
    GenericName=Simulation Modeling
    Comment=Simulation modeling environment
    Exec=anylogic %f
    Icon=${pkgs.anylogic-unwrapped}/opt/anylogic/icon.xpm
    Categories=Development;Science;
    StartupWMClass=AnyLogic 8 Personal Learning Edition
    Terminal=false
  '';
}

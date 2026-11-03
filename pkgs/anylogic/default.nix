{
  lib,
  pkgs,
  buildFHSEnv,
  writeShellScript,
  anylogic-unwrapped,
}: let
  app = "${anylogic-unwrapped}/opt/anylogic";

  launcher = writeShellScript "anylogic-launcher" ''
    set -eu

    mkdir -p "$HOME/.AnyLogicPLE/Config8.8" "$HOME/.AnyLogicPLE/Workspace8.8"
    if [ ! -f "$HOME/.AnyLogicPLE/Config8.8/config.ini" ]; then
      echo "osgi.nl=en" > "$HOME/.AnyLogicPLE/Config8.8/config.ini"
    fi

    cd "${app}"

    export SWT_GTK3=0
    export UBUNTU_MENUPROXY=
    export GDK_BACKEND=x11
    export LD_LIBRARY_PATH="/usr/lib64:/usr/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    export GDK_PIXBUF_MODULE_FILE=/usr/lib64/gdk-pixbuf-2.0/2.10.0/loaders.cache
    export GDK_PIXBUF_MODULEDIR=/usr/lib64/gdk-pixbuf-2.0/2.10.0/loaders
    export _JAVA_AWT_WM_NONREPARENTING=1
    export WEBKIT_DISABLE_COMPOSITING_MODE=1

    exec ./anylogic "$@"
  '';
in
  buildFHSEnv {
    pname = "anylogic";
    version = "8.9.10";
    executableName = "anylogic";

    targetPkgs = pkgs:
      with pkgs; [
        adwaita-icon-theme
        alsa-lib
        atk
        cairo
        cups
        dbus
        expat
        fontconfig
        freetype
        gdk-pixbuf
        glib
        gsettings-desktop-schemas
        gtk2
        gtk3
        harfbuzz
        libGL
        libGLU
        libX11
        libXScrnSaver
        libXcomposite
        libXcursor
        libXdamage
        libXext
        libXfixes
        libXi
        libXrandr
        libXrender
        libXtst
        libXxf86vm
        libdrm
        libxcb
        libgbm
        libpulseaudio
        librsvg
        libsecret
        libxkbcommon
        libxshmfence
        mesa
        nspr
        nss
        pango
        shared-mime-info
        udev
        util-linux
        webkitgtk_4_1
        xdg-utils
        xz
        zlib
      ];

    runScript = launcher;

    extraBuildCommands = ''
      chmod -R u+w $out/usr/lib64/gdk-pixbuf-2.0/2.10.0
      rm -f $out/usr/lib64/gdk-pixbuf-2.0/2.10.0/loaders.cache
      ${pkgs.gdk-pixbuf.dev}/bin/gdk-pixbuf-query-loaders \
        ${pkgs.gdk-pixbuf}/lib/gdk-pixbuf-2.0/2.10.0/loaders/*.so \
        ${pkgs.librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders/*.so \
        > $out/usr/lib64/gdk-pixbuf-2.0/2.10.0/loaders.cache
    '';

    meta = {
      description = "AnyLogic PLE simulation modeling environment (FHS wrapper)";
      homepage = "https://www.anylogic.com/";
      license = lib.licenses.unfree;
      platforms = ["x86_64-linux"];
      mainProgram = "anylogic";
    };
  }

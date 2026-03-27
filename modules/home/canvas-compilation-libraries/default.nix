{
  pkgs,
  lib,
  ...
}:

{
  home.packages = with pkgs; [
    cairo.dev
    giflib
    glib.dev
    libjpeg.dev
    libpng.dev
    librsvg.dev
    harfbuzz.dev
    freetype.dev
    pango.dev
    pixman
    pkg-config
  ];

  home.sessionVariables = {
    PKG_CONFIG_PATH = lib.makeSearchPath "lib/pkgconfig" (
      with pkgs;
      [
        cairo.dev
        giflib
        glib.dev
        libjpeg.dev
        libpng.dev
        librsvg.dev
        harfbuzz.dev
        freetype.dev
        pango.dev
        pixman
      ]
    );
  };
}

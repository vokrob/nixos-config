{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "anylogic";
  version = "8.9.10";

  src = fetchurl {
    url = "https://files.anylogic.com/anylogic-ple-${finalAttrs.version}.linux.x86_64.tgz.bin";
    hash = "sha256-v1sGbD63jY64882UPwLPOJQ7OK2kGNr64SAHNhftvJQ=";
  };

  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;
  dontPatchELF = true;
  dontStrip = true;

  unpackPhase = ''
    runHook preUnpack
    tail -n +546 "$src" | tar xzf -
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/opt"
    cp -a anylogic "$out/opt/anylogic"
    chmod +x "$out/opt/anylogic/anylogic" "$out/opt/anylogic/start-anylogic.sh"
    runHook postInstall
  '';

  meta = {
    description = "AnyLogic PLE simulation modeling environment";
    homepage = "https://www.anylogic.com/";
    license = lib.licenses.unfree;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    platforms = ["x86_64-linux"];
    mainProgram = "anylogic";
  };
})

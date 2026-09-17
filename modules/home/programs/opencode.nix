{pkgs, ...}: {
  programs.opencode = {
    enable = true;

    # wakatime-cli must be on PATH so opencode-wakatime uses the nix package
    # instead of downloading its own binary into ~/.wakatime/
    extraPackages = [pkgs.wakatime-cli];

    settings = {
      plugin = ["opencode-wakatime"];
      small_model = "google/gemini-3.5-flash-lite";
    };
  };
}

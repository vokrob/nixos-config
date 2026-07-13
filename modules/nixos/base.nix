{ pkgs, nix-openclaw, ... }: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.initrd.systemd.enable = true;

  boot.kernelParams = ["nowatchdog"];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "schedutil";
  };

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  fonts.packages = with pkgs; [nerd-fonts.jetbrains-mono];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.android_sdk.accept_license = true;

  nixpkgs.overlays = [
    nix-openclaw.overlays.default
    (import ../../overlays)
  ];

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    max-jobs = "auto";
    build-cores = 0;
    trusted-users = ["vokrob"];
    warn-dirty = false;
    extra-substituters = ["https://cache.garnix.io"];
    extra-trusted-public-keys = ["cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="];
    accept-flake-config = true;
  };

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

  nix.optimise = {
    automatic = true;
    dates = ["weekly"];
  };
}

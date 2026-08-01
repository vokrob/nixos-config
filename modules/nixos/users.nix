{pkgs, ...}: {
  users.users."vokrob" = {
    isNormalUser = true;
    description = "Danil";
    extraGroups = ["networkmanager" "wheel" "kvm"];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  age.secrets = {
    "codestats-api-key" = {
      file = ../../secrets/codestats-api-key.age;
      owner = "vokrob";
      group = "users";
      mode = "0400";
    };
    "wakatime-api-key" = {
      file = ../../secrets/wakatime-api-key.age;
      owner = "vokrob";
      group = "users";
      mode = "0400";
    };
    "openclaw-telegram-token" = {
      file = ../../secrets/openclaw-telegram-token.age;
      owner = "vokrob";
      group = "users";
      mode = "0400";
    };
    "openclaw-zhipu-key" = {
      file = ../../secrets/openclaw-zhipu-key.age;
      owner = "vokrob";
      group = "users";
      mode = "0400";
    };
    "openclaw-gateway-token" = {
      file = ../../secrets/openclaw-gateway-token.age;
      owner = "vokrob";
      group = "users";
      mode = "0400";
    };
  };

  age.identityPaths = ["/home/vokrob/.config/agenix/age-key.txt"];
}

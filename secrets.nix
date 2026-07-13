let
  system = "age13u3d9hplysfuffw6j89s6e5qjmq29llvy84q64c5ug58zcmelvwsrqyv32";
in {
  "secrets/codestats-api-key.age".publicKeys = [ system ];
  "secrets/amneziawg-awg0.age".publicKeys = [ system ];
  "secrets/wakatime-api-key.age".publicKeys = [ system ];
  "secrets/openclaw-telegram-token.age".publicKeys = [ system ];
  "secrets/openclaw-zhipu-key.age".publicKeys = [ system ];
  "secrets/openclaw-gateway-token.age".publicKeys = [ system ];
}

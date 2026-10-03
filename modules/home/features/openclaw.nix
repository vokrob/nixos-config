{openclaw-workspace, ...}: {
  programs.openclaw = {
    enable = true;
    workspace.bootstrapFiles = {
      agents = "${openclaw-workspace}/AGENTS.md";
      soul = "${openclaw-workspace}/SOUL.md";
      tools = "${openclaw-workspace}/TOOLS.md";
      identity = "${openclaw-workspace}/IDENTITY.md";
      user = "${openclaw-workspace}/USER.md";
    };

    environment = {
      GEMINI_API_KEY = "/run/agenix/gemini-api-key";
      OPENCLAW_GATEWAY_TOKEN = "/run/agenix/openclaw-gateway-token";
    };

    config = {
      gateway = {
        mode = "local";
      };
      tools = {
        elevated = {
          enabled = true;
          allowFrom = {
            telegram = [5748618304];
          };
        };
      };
      channels.telegram = {
        tokenFile = "/run/agenix/openclaw-telegram-token";
        allowFrom = [5748618304];
      };
      models.providers.google = {
        apiKey = {
          source = "env";
          provider = "default";
          id = "GEMINI_API_KEY";
        };
        models = [
          {
            name = "Gemini Flash Lite Latest";
            id = "gemini-flash-lite-latest";
            api = "google-generative-ai";
            contextWindow = 1048576;
          }
        ];
      };
      memory.backend = "qmd";

      agents.defaults = {
        model.primary = "google/gemini-flash-lite-latest";
        thinkingDefault = "low";
        compaction.reserveTokensFloor = 20000;
      };
    };

    reloadScript.enable = true;

    bundledPlugins = {
      summarize.enable = true;
    };
  };

  systemd.user.services.openclaw-gateway.Install.WantedBy = ["default.target"];
}

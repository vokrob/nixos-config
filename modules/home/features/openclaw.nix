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
      BAI_API_KEY = "/run/agenix/openclaw-bai-key";
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
      models.providers.bai = {
        baseUrl = "https://api.b.ai/v1";
        apiKey = {
          source = "env";
          provider = "default";
          id = "BAI_API_KEY";
        };
        models = [
          {
            name = "Qwen3.8-Flash";
            id = "qwen3.8-flash";
            api = "openai-completions";
            contextWindow = 1048576;
          }
        ];
      };
      memory.backend = "qmd";

      agents.defaults = {
        model.primary = "bai/qwen3.8-flash";
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

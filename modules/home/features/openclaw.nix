{ openclaw-workspace, ... }: {
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
      ZHIPU_API_KEY = "/run/agenix/openclaw-zhipu-key";
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
      models.providers.openai = {
        baseUrl = "https://open.bigmodel.cn/api/paas/v4";
        apiKey = {
          source = "env";
          provider = "default";
          id = "ZHIPU_API_KEY";
        };
        models = [{
          name = "glm-4.7-flash";
          id = "glm-4.7-flash";
          api = "openai-completions";
          contextWindow = 200000;
        }];
      };
      memory.backend = "qmd";

      agents.defaults = {
        model.primary = "openai/glm-4.7-flash";
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

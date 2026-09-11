{...}: {
  programs.opencode = {
    enable = true;

    settings = {
      # no top-level "model": startup uses the last used model
      # (persisted in ~/.local/state/opencode/model.json)
      # background tasks don't need heavy reasoning: run them on the "low" variant
      agent = {
        title = {
          model = "bai/GLM-5.3-Flash";
          variant = "low";
        };
        summary = {
          model = "bai/GLM-5.3-Flash";
          variant = "low";
        };
        compaction = {
          model = "bai/GLM-5.3-Flash";
          variant = "low";
        };
      };

      provider.bai = {
        npm = "@ai-sdk/openai-compatible";
        name = "B.AI";
        options = {
          baseURL = "https://api.b.ai/v1";
          # API key is read from the BAI_API_KEY environment variable
          apiKey = "{env:BAI_API_KEY}";
        };
        models."GLM-5.3-Flash" = {
          name = "GLM-5.3-Flash";
          id = "glm-5.3-flash";
          attachment = true; # verified: API accepts images
          reasoning = true; # verified: reasoning_content confirmed
          tool_call = true;
          limit = {
            context = 1000000;
            output = 131072;
          };
          modalities = {
            input = ["text" "image"];
            output = ["text"];
          };
          variants = {
            low = {reasoningEffort = "low";};
            high = {reasoningEffort = "high";};
            max = {reasoningEffort = "max";};
          };
        };
      };
    };
  };

  # concurrency limiter + retry for the B.AI provider
  xdg.configFile."opencode/plugin/rate-limit.ts".source =
    ../../../dotfiles/opencode/rate-limit.ts;
}

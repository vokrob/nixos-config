{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      nvim-treesitter
      nvim-lspconfig
      catppuccin-nvim
      lualine-nvim
      which-key-nvim
      telescope-nvim
      plenary-nvim
      neo-tree-nvim
      nvim-web-devicons
      trouble-nvim
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      luasnip
      cmp_luasnip
      friendly-snippets
      conform-nvim
      gitsigns-nvim
      comment-nvim
      todo-comments-nvim
      mini-nvim
      undotree
      harpoon
      toggleterm-nvim
    ];

    initLua = ''
      vim.opt.number = true
      vim.opt.relativenumber = false
      vim.opt.mouse = "a"
      vim.opt.showmode = false
      vim.opt.clipboard = "unnamedplus"
      vim.opt.breakindent = true
      vim.opt.undofile = true
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
      vim.opt.signcolumn = "yes"
      vim.opt.updatetime = 250
      vim.opt.timeoutlen = 300
      vim.opt.splitright = true
      vim.opt.splitbelow = true
      vim.opt.tabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.expandtab = true
      vim.opt.termguicolors = true

      vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
      vim.keymap.set("n", "<leader>w", "<cmd>write<CR>")

      require("catppuccin").setup({ flavour = "mocha", transparent_background = false, term_colors = true })
      vim.cmd.colorscheme("catppuccin")

      require("nvim-treesitter").setup({
        ensure_installed = { "lua", "nix", "python", "rust", "typescript", "javascript", "go", "yaml", "json", "html", "css", "markdown", "bash" },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })

      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr, remap = false }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
      end
      local servers = { "lua_ls", "nil_ls", "pyright", "rust_analyzer", "ts_ls", "gopls", "yamlls", "bashls" }
      for _, server in ipairs(servers) do
        vim.lsp.config[server] = { on_attach = on_attach }
      end
      vim.lsp.enable(servers)

      local cmp = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, { name = "luasnip" },
        }, {
          { name = "buffer" }, { name = "path" },
        }),
      })

      require("telescope").setup({
        defaults = {
          mappings = { i = { ["<C-j>"] = "move_selection_next", ["<C-k>"] = "move_selection_previous" } },
        },
      })
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
      vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})

      require("lualine").setup({ options = { theme = "auto" } })
      require("which-key").setup({})
      require("neo-tree").setup({
        close_if_last_window = true,
        window = { position = "left", width = 30 },
      })
      vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>")
      require("gitsigns").setup({})
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          nix = { "alejandra" },
          python = { "isort", "black" },
          javascript = { "prettierd" },
          typescript = { "prettierd" },
          json = { "prettierd" },
          yaml = { "prettierd" },
          markdown = { "prettierd" },
          rust = { "rustfmt" },
          go = { "gofumpt" },
          sh = { "shfmt" },
        },
        format_on_save = { timeout_ms = 500, lsp_fallback = true },
      })
      require("Comment").setup()
      require("todo-comments").setup({})

      local harpoon = require("harpoon")
      harpoon:setup({})
      vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
      vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
      for i = 1, 5 do
        vim.keymap.set("n", "<leader>" .. i, function() harpoon:list():select(i) end)
      end

      require("toggleterm").setup({
        size = 20,
        open_mapping = "<C-\\>",
        hide_numbers = true,
        shade_terminals = true,
        start_in_insert = true,
        direction = "horizontal",
      })

      require("trouble").setup({})
      vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>")
      vim.keymap.set("n", "<leader>xw", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>")

      require("mini.surround").setup()
      require("mini.pairs").setup()
      require("mini.comment").setup()

      vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
    '';
  };
}

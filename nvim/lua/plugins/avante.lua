-- Avante.nvim - sidebar AI chat with inline code diffs
---@type LazySpec
return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    build = "make",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-telescope/telescope.nvim",
      "HakonHarnes/img-clip.nvim",
      "hrsh7th/nvim-cmp",
    },
    opts = {
      provider = "claude",
      auto_suggestions_provider = "claude",
      providers = {
        claude = {
          endpoint = "https://api.anthropic.com",
          model = "claude-sonnet-4-20250514",
          extra_request_body = {
            max_tokens = 4096,
          },
        },
        ollama = {
          endpoint = "http://localhost:11435",
          model = "qwen2.5-coder:32b",
          extra_request_body = {
            options = {
              num_ctx = 32768,
              temperature = 0.7,
              keep_alive = "5m",
            },
          },
        },
      },
      -- CRITICAL: prevent clobbering <leader>a* (Claude Code)
      mappings = {
        ask = "<leader>Aa",
        edit = "<leader>Ae",
        refresh = "<leader>Ar",
        focus = "<leader>Af",
        toggle = {
          default = "<leader>At",
          debug = "<leader>Ad",
          hint = "<leader>Ah",
          suggestion = "<leader>As",
          repomap = "<leader>AR",
        },
        diff = {
          next = "]x",
          prev = "[x",
        },
        files = {
          add_current = "<leader>A.",
        },
      },
      -- Use snacks.nvim for input prompts (supports concealed/password input)
      input = { provider = "snacks" },
      -- Prevent auto-setting default keymaps that would conflict with Claude Code
      -- The mappings table above handles all bindings under <leader>A
      behaviour = {
        auto_suggestions = false, -- Prevent conflict with NeoCodeium ghost text
        auto_set_keymaps = true,
        auto_set_highlight_group = true,
      },
      windows = {
        position = "right",
        width = 40,
        sidebar_header = {
          enabled = true,
          align = "center",
          rounded = true,
        },
      },
    },
    keys = {
      { "<leader>A", nil, desc = "AI/Avante" },
      { "<leader>Aa", "<cmd>AvanteAsk<cr>", mode = { "n", "v" }, desc = "Avante: Ask" },
      { "<leader>Ae", "<cmd>AvanteEdit<cr>", mode = "v", desc = "Avante: Edit" },
      { "<leader>At", "<cmd>AvanteToggle<cr>", desc = "Avante: Toggle sidebar" },
      { "<leader>Af", "<cmd>AvanteFocus<cr>", desc = "Avante: Focus sidebar" },
      { "<leader>An", "<cmd>AvanteClear<cr>", desc = "Avante: New chat" },
      { "<leader>Ar", "<cmd>AvanteRefresh<cr>", desc = "Avante: Refresh" },
      { "<leader>As", "<cmd>AvanteStop<cr>", desc = "Avante: Stop" },
      { "<leader>Am", "<cmd>AvanteShowRepoMap<cr>", desc = "Avante: Repo map" },
      { "<leader>Ap", "<cmd>AvanteSwitchProvider<cr>", desc = "Avante: Switch provider" },
    },
  },
}

-- Avante.nvim - sidebar AI chat with inline code diffs
---@type LazySpec
return {
  {
    "yetone/avante.nvim",
    -- Loaded on first use (the keys below, or one of these commands), not at
    -- startup: its native modules are the riskiest code in the config, so a
    -- broken build can only break Avante, never every new nvim session.
    cmd = {
      "AvanteACPModels", "AvanteACPModes", "AvanteAsk", "AvanteBuild", "AvanteChat", "AvanteChatNew",
      "AvanteClear", "AvanteEdit", "AvanteFocus", "AvanteHistory", "AvanteModels", "AvanteRefresh",
      "AvanteShowRepoMap", "AvanteStop", "AvanteSwitchInputProvider", "AvanteSwitchProvider",
      "AvanteSwitchSelectorProvider", "AvanteToggle",
    },
    version = false,
    -- avante's Makefile installs its native modules (lua/*.so) with a plain `cp`
    -- over the previous build, i.e. in place. macOS keeps the code signature it
    -- cached for that inode, so it SIGKILLs every new nvim that loads a rebuilt
    -- module. Re-create each module as a new file (new inode) after `make`.
    build = {
      "make",
      function(plugin)
        for _, so in ipairs(vim.fn.glob(plugin.dir .. "/lua/*.so", false, true)) do
          assert(vim.uv.fs_copyfile(so, so .. ".tmp"))
          assert(vim.uv.fs_rename(so .. ".tmp", so))
        end
      end,
    },
    -- Work around avante.nvim's log.lua bug: it builds its numeric->string log
    -- level map by mutating a table during its own pairs() traversal (undefined
    -- behaviour in LuaJIT), which can leave log_levels[3] nil and crash on load
    -- with "Invalid log level: 3". Setting log_level as a STRING before the
    -- plugin loads routes set_level() through the always-present forward map,
    -- sidestepping the corruptible reverse lookup. init runs at startup, before
    -- the plugin loads, so it also covers the module-load read (log.lua:109) that
    -- opts can't reach.
    init = function()
      vim.g.avante = vim.tbl_deep_extend("keep", vim.g.avante or {}, { log_level = "warn" })
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-telescope/telescope.nvim",
      "HakonHarnes/img-clip.nvim",
    },
    opts = {
      provider = "claude",
      auto_suggestions_provider = "claude",
      providers = {
        claude = {
          endpoint = "https://api.anthropic.com",
          model = "claude-sonnet-5",
          extra_request_body = {
            max_tokens = 8192,
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
          suggestion = "<leader>AS",
          repomap = "<leader>AR",
        },
        diff = {
          next = "]a", -- ]x/[x belong to git-conflict
          prev = "[a",
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
        auto_suggestions = false, -- Prevent conflict with Copilot ghost text
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

---@type LazySpec
return {
  -- Session management via auto-session (below) — persistence.nvim removed to avoid conflicts

  -- zen-mode.nvim - 2k+ stars (folke)
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    keys = {
      { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen mode" },
    },
    opts = {},
  },

  -- vim-dadbod - 4k+ stars - database client
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
    },
    cmd = { "DBUI", "DBUIToggle" },
    keys = {
      { "<leader>D", "<cmd>DBUIToggle<cr>", desc = "Database UI" },
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
    end,
  },

  -- neorg - 6k+ stars - task management and organization
  {
    "nvim-neorg/neorg",
    version = "*",
    ft = "norg",
    cmd = "Neorg",
    keys = {
      { "<leader>ni", "<cmd>Neorg index<cr>", desc = "Neorg index" },
      { "<leader>nt", "<cmd>Neorg journal today<cr>", desc = "Neorg today" },
      { "<leader>nw", "<cmd>Neorg workspace<cr>", desc = "Neorg workspace" },
      { "<leader>nn", "<cmd>Neorg toggle-concealer<cr>", desc = "Neorg toggle concealer" },
    },
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    opts = {
      load = {
        ["core.defaults"] = {},
        ["core.concealer"] = {
          config = {
            icon_preset = "diamond",
          },
        },
        ["core.dirman"] = {
          config = {
            workspaces = {
              notes = "~/neorg/notes",
              tasks = "~/neorg/tasks",
            },
            default_workspace = "tasks",
          },
        },
        ["core.completion"] = {
          config = {
            engine = "nvim-cmp",
          },
        },
        ["core.journal"] = {
          config = {
            workspace = "tasks",
          },
        },
        ["core.export"] = {},
        ["core.summary"] = {},
      },
    },
  },

  -- codesnap.nvim - 500+ stars - beautiful code screenshots
  {
    "mistricky/codesnap.nvim",
    build = "make",
    cmd = { "CodeSnap", "CodeSnapSave" },
    keys = {
      { "<leader>cs", "<cmd>CodeSnap<cr>", mode = "x", desc = "Code snapshot (clipboard)" },
      { "<leader>cS", "<cmd>CodeSnapSave<cr>", mode = "x", desc = "Code snapshot (save)" },
    },
    opts = {
      save_path = "~/Pictures/CodeSnaps",
      has_breadcrumbs = true,
      bg_theme = "bamboo",
      watermark = "",
    },
  },

  -- refactoring.nvim - 3k+ stars - code refactoring
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      { "<leader>re", function() require("refactoring").refactor("Extract Function") end, mode = "x", desc = "Extract function" },
      { "<leader>rf", function() require("refactoring").refactor("Extract Function To File") end, mode = "x", desc = "Extract to file" },
      { "<leader>rv", function() require("refactoring").refactor("Extract Variable") end, mode = "x", desc = "Extract variable" },
      { "<leader>ri", function() require("refactoring").refactor("Inline Variable") end, mode = { "n", "x" }, desc = "Inline variable" },
    },
    opts = {},
  },

  -- auto-session - 1k+ stars - better session management
  {
    "rmagatti/auto-session",
    lazy = false,
    opts = {
      log_level = "error",
      auto_session_suppress_dirs = { "~/", "~/Downloads", "/" },
      auto_session_use_git_branch = true,
      auto_restore_enabled = true,
      auto_save_enabled = true,
    },
    keys = {
      { "<leader>qr", "<cmd>SessionRestore<cr>", desc = "Restore session" },
      { "<leader>qS", "<cmd>SessionSave<cr>", desc = "Save session" },
      { "<leader>qd", "<cmd>SessionDelete<cr>", desc = "Delete session" },
    },
  },

  -- nvim-surround and undotree configured in editing.lua

  -- yanky.nvim - 400+ stars - improved yank/paste
  {
    "gbprod/yanky.nvim",
    event = "VeryLazy",
    opts = {
      highlight = { timer = 150 },
      ring = { history_length = 100 },
    },
    keys = {
      { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text" },
      { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put after" },
      { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put before" },
      { "<leader>p", "<cmd>Telescope yank_history<cr>", desc = "Yank history" },
      { "<c-n>", "<Plug>(YankyCycleForward)", desc = "Cycle forward" },
      { "<c-p>", "<Plug>(YankyCycleBackward)", desc = "Cycle backward" },
    },
  },

  -- nvim-spectre configured in editing.lua

  -- wakatime - time tracking (DISABLED)
  -- {
  --   "wakatime/vim-wakatime",
  --   event = "VeryLazy",
  -- },
}

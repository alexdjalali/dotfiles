---@type LazySpec
return {
  -- Sessions: AstroNvim's resession (<leader>S*).

  -- zen-mode.nvim
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    keys = {
      { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen mode" },
    },
    opts = {},
  },

  -- vim-dadbod - database client
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      { "kristijanhusak/vim-dadbod-completion", lazy = true },
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DB" },
    keys = {
      { "<leader>D", "<cmd>DBUIToggle<cr>", desc = "Database UI" },
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      -- Connections are per project: a repo's .nvim.lua (trusted exrc) sets
      -- vim.g.dbs, or add one with :DBUIAddConnection.
    end,
  },

  -- neorg - task management and organization
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

  -- codesnap.nvim - beautiful code screenshots
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

  -- refactoring.nvim - code refactoring
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    -- Operator-style API: each function sets 'operatorfunc' and returns "g@",
    -- so the keys are expr mappings that take a motion (normal) or the
    -- selection (visual). <leader>rr is Refactor This (Ctrl+T).
    keys = {
      { "<leader>rr", function() require("refactoring").select_refactor() end, mode = { "n", "x" }, desc = "Refactor This" },
      { "<leader>re", function() return require("refactoring").extract_func() end, mode = { "n", "x" }, expr = true, desc = "Extract function" },
      { "<leader>rf", function() return require("refactoring").extract_func_to_file() end, mode = { "n", "x" }, expr = true, desc = "Extract to file" },
      { "<leader>rv", function() return require("refactoring").extract_var() end, mode = { "n", "x" }, expr = true, desc = "Extract variable" },
      { "<leader>ri", function() return require("refactoring").inline_var() end, mode = { "n", "x" }, expr = true, desc = "Inline variable" },
      { "<leader>rI", function() return require("refactoring").inline_func() end, mode = { "n", "x" }, expr = true, desc = "Inline function" },
    },
    opts = {},
  },

  -- nvim-surround and undotree configured in editing.lua

  -- yanky.nvim - improved yank/paste
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
      { "<leader>yh", "<cmd>YankyRingHistory<cr>", desc = "Yank history" },
      { "<c-n>", "<Plug>(YankyCycleForward)", desc = "Cycle forward" },
      { "<c-p>", "<Plug>(YankyCycleBackward)", desc = "Cycle backward" },
    },
  },

  -- nvim-spectre configured in editing.lua
}

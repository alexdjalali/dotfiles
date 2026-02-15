---@type LazySpec
return {
  -- lazygit.nvim - 1.5k+ stars
  {
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- toggleterm.nvim - 4k+ stars
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    event = "VeryLazy",  -- Load on startup so DevOps tools work
    keys = {
      { "<C-`>", "<cmd>ToggleTerm<cr>", desc = "Terminal", mode = { "n", "t" } },
    },
    opts = {
      size = 15,
      direction = "horizontal",
    },
  },

  -- kubectl.nvim - newer but useful for k8s
  {
    "ramilito/kubectl.nvim",
    cmd = "Kubectl",
    keys = {
      { "<leader>k", function() require("kubectl").toggle() end, desc = "Kubectl" },
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  -- vim-dadbod - database client for Postgres, Mongo, Redis, etc.
  {
    "tpope/vim-dadbod",
    cmd = "DB",
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    cmd = { "DBUI", "DBUIToggle" },
    dependencies = {
      "tpope/vim-dadbod",
      "kristijanhusak/vim-dadbod-completion",
    },
    keys = {
      { "<leader>D", "<cmd>DBUIToggle<cr>", desc = "Database UI (DadBod)" },
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      local pg_pass = vim.env.HPC_PG_PASSWORD or "changeme"
      vim.g.dbs = {
        { name = "HPC Auth (PostgreSQL)", url = "postgresql://hpc:" .. pg_pass .. "@localhost:5432/hpc_auth" },
        { name = "HPC cspan (MongoDB)", url = "mongodb://localhost:27017/cspan?directConnection=true" },
        { name = "HPC Redis", url = "redis://localhost:6379" },
      }
    end,
  },

  -- firenvim - 4k+ stars - use Neovim in browser
  {
    "glacambre/firenvim",
    lazy = not vim.g.started_by_firenvim,
    build = function()
      vim.fn["firenvim#install"](0)
    end,
    config = function()
      vim.g.firenvim_config = {
        globalSettings = { alt = "all" },
        localSettings = {
          [".*"] = {
            cmdline = "neovim",
            content = "text",
            priority = 0,
            selector = "textarea",
            takeover = "never",
          },
        },
      }
    end,
  },
}

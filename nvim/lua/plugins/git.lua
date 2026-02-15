---@type LazySpec
return {
  -- gitsigns.nvim - 5k+ stars (lewis6991)
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = { delay = 200 },
    },
  },

  -- octo.nvim - 2k+ stars - GitHub issues/PRs in Neovim
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>go", "<cmd>Octo<cr>", desc = "Octo (GitHub)" },
      { "<leader>gpl", "<cmd>Octo pr list<cr>", desc = "PR list" },
      { "<leader>gpc", "<cmd>Octo pr create<cr>", desc = "PR create" },
      { "<leader>gil", "<cmd>Octo issue list<cr>", desc = "Issue list" },
      { "<leader>gic", "<cmd>Octo issue create<cr>", desc = "Issue create" },
    },
    opts = {
      enable_builtin = true,
      default_to_projects_v2 = true,
      default_merge_method = "squash",
    },
  },

  -- git-blame.nvim - 500+ stars - inline git blame
  {
    "f-person/git-blame.nvim",
    event = "BufReadPre",
    opts = {
      enabled = true,
      date_format = "%r", -- Relative date
      message_template = "  <author> • <date> • <summary>",
    },
    keys = {
      { "<leader>gb", "<cmd>GitBlameToggle<cr>", desc = "Toggle git blame" },
    },
  },

  -- git-conflict.nvim - 1k+ stars - merge conflict resolution
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    event = "BufReadPre",
    opts = {
      default_mappings = true, -- disable buffer local mapping created by this plugin
      default_commands = true, -- disable commands created by this plugin
      disable_diagnostics = false, -- This will disable the diagnostics in a buffer whilst it is conflicted
      highlights = {
        incoming = "DiffAdd",
        current = "DiffText",
      },
    },
    keys = {
      { "<leader>gco", "<cmd>GitConflictChooseOurs<cr>", desc = "Choose ours" },
      { "<leader>gct", "<cmd>GitConflictChooseTheirs<cr>", desc = "Choose theirs" },
      { "<leader>gcb", "<cmd>GitConflictChooseBoth<cr>", desc = "Choose both" },
      { "<leader>gc0", "<cmd>GitConflictChooseNone<cr>", desc = "Choose none" },
      { "]x", "<cmd>GitConflictNextConflict<cr>", desc = "Next conflict" },
      { "[x", "<cmd>GitConflictPrevConflict<cr>", desc = "Previous conflict" },
      { "<leader>gcl", "<cmd>GitConflictListQf<cr>", desc = "List conflicts" },
    },
  },
}

---@type LazySpec
return {
  -- gitsigns.nvim
  -- Note: inline blame handled by git-blame.nvim below (better toggle/format)
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      -- Mark every line of a file git doesn't track yet as added. Upstream
      -- defaults this to false, which leaves new files with an empty gutter.
      attach_to_untracked = true,
      current_line_blame = false,
      current_line_blame_opts = { delay = 200 },
    },
  },

  -- octo.nvim - GitHub issues/PRs in Neovim
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      -- <leader>gO ("Octo"): AstroNvim owns <leader>go (git browse) and gitsigns
      -- <leader>gp (preview hunk) in every git buffer.
      { "<leader>gO", nil, desc = "Octo (GitHub)" },
      { "<leader>gOo", "<cmd>Octo<cr>", desc = "Octo actions" },
      { "<leader>gOp", "<cmd>Octo pr list<cr>", desc = "PR list" },
      { "<leader>gOP", "<cmd>Octo pr create<cr>", desc = "PR create" },
      { "<leader>gOi", "<cmd>Octo issue list<cr>", desc = "Issue list" },
      { "<leader>gOI", "<cmd>Octo issue create<cr>", desc = "Issue create" },
    },
    opts = {
      enable_builtin = true,
      default_to_projects_v2 = true,
      default_merge_method = "squash",
    },
  },

  -- git-blame.nvim - inline git blame
  {
    "f-person/git-blame.nvim",
    event = "BufReadPre",
    opts = {
      enabled = true,
      date_format = "%r", -- Relative date
      message_template = "  <author> • <date> • <summary>",
    },
    keys = {
      -- <leader>gb is AstroNvim's git branches picker.
      { "<leader>gB", "<cmd>GitBlameToggle<cr>", desc = "Toggle git blame" },
    },
  },

  -- git-conflict.nvim - merge conflict resolution
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
      -- <leader>gx ("conflict"): <leader>gc is AstroNvim's git commits picker.
      { "<leader>gx", nil, desc = "Git conflict" },
      { "<leader>gxo", "<cmd>GitConflictChooseOurs<cr>", desc = "Choose ours" },
      { "<leader>gxt", "<cmd>GitConflictChooseTheirs<cr>", desc = "Choose theirs" },
      { "<leader>gxb", "<cmd>GitConflictChooseBoth<cr>", desc = "Choose both" },
      { "<leader>gx0", "<cmd>GitConflictChooseNone<cr>", desc = "Choose none" },
      { "]x", "<cmd>GitConflictNextConflict<cr>", desc = "Next conflict" },
      { "[x", "<cmd>GitConflictPrevConflict<cr>", desc = "Previous conflict" },
      { "<leader>gxl", "<cmd>GitConflictListQf<cr>", desc = "List conflicts" },
    },
  },
}

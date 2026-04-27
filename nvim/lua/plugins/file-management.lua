---@type LazySpec
return {
  -- neo-tree configuration override
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = true, -- exclude gitignored dirs (node_modules, .venv, etc.) from tree + fuzzy filter
          never_show = { ".git", "__pycache__", ".venv", "node_modules", ".mypy_cache", ".ruff_cache" },
        },
        window = {
          fuzzy_finder_mappings = {
            ["<C-n>"] = "move_cursor_down",
            ["<C-p>"] = "move_cursor_up",
          },
        },
      },
    },
  },

  -- Disable autopairs in neo-tree popup buffers so fuzzy finder <CR> works
  {
    "windwp/nvim-autopairs",
    opts = function(_, opts)
      local disable = opts.disable_filetype or { "TelescopePrompt" }
      vim.list_extend(disable, { "neo-tree", "neo-tree-popup" })
      opts.disable_filetype = disable
    end,
  },

  -- Disable blink.cmp in neo-tree popup so fuzzy finder Ctrl-N/P and
  -- arrow key navigation works.  Must preserve AstroNvim's default
  -- buftype=="prompt" check (which covers NUI inputs) since lazy.nvim
  -- replaces functions wholesale rather than merging them.
  {
    "saghen/blink.cmp",
    opts = {
      enabled = function()
        local astro = require "astrocore"
        local dap_prompt = astro.is_available "cmp-dap"
          and vim.tbl_contains({ "dap-repl", "dapui_watches", "dapui_hover" }, vim.bo.filetype)
        if vim.bo.buftype == "prompt" and not dap_prompt then return false end
        if vim.bo.filetype == "neo-tree-popup" then return false end
        return vim.F.if_nil(vim.b.completion, astro.config.features.cmp)
      end,
    },
  },

  -- project.nvim - 1k+ stars - project management
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    opts = {
      detection_methods = { "pattern", "lsp" },
      patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", "go.mod" },
      show_hidden = false,
      silent_chdir = true,
      scope_chdir = "global",
    },
    config = function(_, opts)
      require("project_nvim").setup(opts)
      require("telescope").load_extension("projects")
    end,
    keys = {
      { "<leader>fp", "<cmd>Telescope projects<cr>", desc = "Find projects" },
    },
  },

  -- oil.nvim - 2k+ stars - file manager as buffer
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Oil",
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
      { "<leader>-", function() require("oil").toggle_float() end, desc = "Open oil (float)" },
    },
    opts = {
      default_file_explorer = false,
      columns = {
        "icon",
        "permissions",
        "size",
        "mtime",
      },
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
        is_always_hidden = function(name, _)
          return name == ".." or name == ".git"
        end,
      },
      float = {
        padding = 2,
        max_width = 90,
        max_height = 30,
        border = "rounded",
      },
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-v>"] = "actions.select_vsplit",
        ["<C-h>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["<C-r>"] = "actions.refresh",
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["g."] = "actions.toggle_hidden",
      },
    },
  },

  -- telescope-frecency - 700+ stars - frecency sorting
  {
    "nvim-telescope/telescope-frecency.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    keys = {
      { "<leader>fr", "<cmd>Telescope frecency<cr>", desc = "Recent files (frecency)" },
    },
    config = function()
      require("telescope").load_extension("frecency")
    end,
  },
}

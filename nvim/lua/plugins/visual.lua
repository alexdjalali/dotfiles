---@type LazySpec
return {
  -- nvim-treesitter-context - sticky function headers
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    opts = {
      enable = true,
      max_lines = 3,
      min_window_height = 20,
      line_numbers = true,
      multiline_threshold = 1,
      trim_scope = "outer",
    },
    keys = {
      { "<leader>ux", "<cmd>TSContextToggle<cr>", desc = "Toggle treesitter context" },
    },
  },

  -- rainbow-delimiters.nvim - colorful brackets
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufReadPost",
    config = function()
      require("rainbow-delimiters.setup").setup({
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      })
    end,
  },

  -- modes.nvim - visual mode indicators, in Catppuccin Mocha colours
  {
    "mvllow/modes.nvim",
    event = "BufReadPost",
    opts = function()
      local c = require("catppuccin.palettes").get_palette("mocha")
      return {
        colors = { copy = c.yellow, delete = c.red, insert = c.teal, visual = c.mauve },
        line_opacity = 0.15,
        set_cursor = true,
        set_cursorline = true,
        set_number = true,
      }
    end,
  },

  -- nvim-scrollbar - scrollbar with diagnostics (Catppuccin Mocha)
  {
    "petertriho/nvim-scrollbar",
    -- main becomes v2 on 2026-11-16, which rejects these v1 options (and warns at
    -- startup until then); v1 is the maintained branch for this config.
    branch = "v1",
    event = "BufReadPost",
    opts = function()
      local c = require("catppuccin.palettes").get_palette("mocha")
      return {
        handle = { color = c.surface2 },
        marks = {
          Search = { color = c.yellow },
          Error = { color = c.red },
          Warn = { color = c.peach },
          Info = { color = c.sky },
          Hint = { color = c.teal },
          GitAdd = { color = c.green },
          GitChange = { color = c.yellow },
          GitDelete = { color = c.red },
        },
        excluded_filetypes = { "neo-tree", "alpha", "noice" },
      }
    end,
  },

  -- todo-comments.nvim - highlight todos
  {
    "folke/todo-comments.nvim",
    event = "BufReadPost",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      signs = true,
      keywords = {
        FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
    },
    -- Keys (]T, [T, <leader>xt/xT) come from the todo-comments and trouble packs.
  },

  -- trouble.nvim - better diagnostics UI
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = {
      -- <leader>xx/xX/xL/xQ come from the trouble pack (community.lua).
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
      { "<leader>xr", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP references (Trouble)" },
    },
  },

  -- nvim-ufo - better folding
  {
    "kevinhwang91/nvim-ufo",
    event = "BufReadPost",
    dependencies = { "kevinhwang91/promise-async" },
    opts = {
      provider_selector = function()
        return { "treesitter", "indent" }
      end,
    },
    init = function()
      vim.o.foldcolumn = "1"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
    end,
    keys = {
      { "zR", function() require("ufo").openAllFolds() end, desc = "Open all folds" },
      { "zM", function() require("ufo").closeAllFolds() end, desc = "Close all folds" },
      { "zr", function() require("ufo").openFoldsExceptKinds() end, desc = "Open folds" },
      { "zm", function() require("ufo").closeFoldsWith() end, desc = "Close folds" },
      { "zp", function() require("ufo").peekFoldedLinesUnderCursor() end, desc = "Peek fold" },
    },
  },

  -- twilight.nvim - dim inactive code
  {
    "folke/twilight.nvim",
    cmd = "Twilight",
    keys = {
      { "<leader>uT", "<cmd>Twilight<cr>", desc = "Toggle twilight (dim inactive)" },
    },
    opts = {
      dimming = {
        alpha = 0.25,
        inactive = true,
      },
      context = 15,
      treesitter = true,
    },
  },

  -- Breadcrumbs: AstroNvim's heirline winbar (one owner of 'winbar').
  -- Reference highlighting: snacks.words (AstroNvim default).
}

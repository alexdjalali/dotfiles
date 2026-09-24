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
      { "<leader>uc", "<cmd>TSContextToggle<cr>", desc = "Toggle treesitter context" },
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
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
      { "<leader>ft", function() require("snacks").picker.todo_comments() end, desc = "Find todos" },
    },
  },

  -- trouble.nvim - better diagnostics UI
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics (Trouble)" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
      { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP references (Trouble)" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location list (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list (Trouble)" },
    },
  },

  -- illuminate.nvim - highlight word under cursor
  {
    "RRethy/vim-illuminate",
    event = "BufReadPost",
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { "lsp" },
      },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)
    end,
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

  -- barbecue.nvim - VS Code-like breadcrumbs
  {
    "utilyre/barbecue.nvim",
    event = "LspAttach",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      theme = "auto",
      show_dirname = true,
      show_basename = true,
      show_modified = true,
      symbols = {
        separator = "",
      },
      kinds = {
        File = "",
        Module = "",
        Namespace = "",
        Package = "",
        Class = "",
        Method = "",
        Property = "",
        Field = "",
        Constructor = "",
        Enum = "",
        Interface = "",
        Function = "",
        Variable = "",
        Constant = "",
        String = "",
        Number = "",
        Boolean = "",
        Array = "",
        Object = "",
        Key = "",
        Null = "",
        EnumMember = "",
        Struct = "",
        Event = "",
        Operator = "",
        TypeParameter = "",
      },
    },
  },

  -- incline.nvim - floating filenames
  {
    "b0o/incline.nvim",
    event = "BufReadPost",
    opts = {
      window = {
        padding = 0,
        margin = { horizontal = 0, vertical = 0 },
      },
      render = function(props)
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
        local icon, color = require("nvim-web-devicons").get_icon_color(filename)
        return {
          { icon, guifg = color },
          { " " },
          { filename },
        }
      end,
    },
  },
}

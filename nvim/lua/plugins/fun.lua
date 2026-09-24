---@type LazySpec
return {
  -- cellular-automaton.nvim - code animations
  {
    "eandrju/cellular-automaton.nvim",
    cmd = "CellularAutomaton",
    keys = {
      { "<leader>fml", "<cmd>CellularAutomaton make_it_rain<cr>", desc = "Make it rain" },
      { "<leader>fmg", "<cmd>CellularAutomaton game_of_life<cr>", desc = "Game of life" },
    },
  },

  -- neoscroll removed; mini.animate scroll animation also disabled below
  -- (WinScrolled/WinResized loop with snacks dashboard on nvim 0.12+)

  -- beacon.nvim - cursor flash on jump
  {
    "rainbowhxch/beacon.nvim",
    event = "VeryLazy",
    opts = {
      enable = true,
      size = 40,
      fade = true,
      minimal_jump = 10,
      show_jumps = true,
      focus_gained = false,
      shrink = true,
      timeout = 500,
      ignore_buffers = {},
      ignore_filetypes = {},
    },
  },

  -- transparent.nvim - transparent background
  {
    "xiyaowong/transparent.nvim",
    lazy = false,
    config = function()
      require("transparent").setup({
        groups = {
          "Normal",
          "NormalNC",
          "Comment",
          "Constant",
          "Special",
          "Identifier",
          "Statement",
          "PreProc",
          "Type",
          "Underlined",
          "Todo",
          "String",
          "Function",
          "Conditional",
          "Repeat",
          "Operator",
          "Structure",
          "LineNr",
          "NonText",
          "SignColumn",
          "CursorLineNr",
          "EndOfBuffer",
        },
        extra_groups = {
          "NormalFloat",
          "NvimTreeNormal",
          "NeoTreeNormal",
          "NeoTreeNormalNC",
        },
        exclude_groups = {},
      })
      -- Keep the statusline opaque when transparency is toggled on (:TransparentToggle)
      require("transparent").clear_prefix("lualine")
    end,
    keys = {
      { "<leader>ut", "<cmd>TransparentToggle<cr>", desc = "Toggle transparency" },
    },
  },

  -- mini.animate - smooth cursor animation only
  {
    "echasnovski/mini.animate",
    event = "VeryLazy",
    opts = function()
      local animate = require("mini.animate")
      return {
        -- scroll/resize animations disabled: they hook WinScrolled/WinResized and,
        -- on neovim 0.12+, can form a runaway event loop with the snacks dashboard's
        -- resize re-render (dashboard.lua), aborting nvim seconds after startup.
        scroll = { enable = false },
        resize = { enable = false },
        cursor = {
          timing = animate.gen_timing.linear({ duration = 80, unit = "total" }),
        },
        open = { enable = false }, -- Disable window open animation (can be jarring)
        close = { enable = false }, -- Disable window close animation
      }
    end,
  },

  -- duck.nvim - virtual pet duck that walks around your code (<leader>fd*;
  -- <leader>D is the database UI)
  {
    "tamton-aquib/duck.nvim",
    keys = {
      { "<leader>fdd", function() require("duck").hatch("🦆", 10) end, desc = "Hatch a duck" },
      { "<leader>fdk", function() require("duck").cook() end, desc = "Cook a duck" },
      { "<leader>fda", function() require("duck").cook_all() end, desc = "Cook all ducks" },
      -- More animals!
      { "<leader>fdc", function() require("duck").hatch("🐱", 8) end, desc = "Hatch a cat" },
      { "<leader>fdg", function() require("duck").hatch("🐶", 6) end, desc = "Hatch a dog" },
      { "<leader>fdr", function() require("duck").hatch("🦀", 12) end, desc = "Hatch a crab" },
      { "<leader>fds", function() require("duck").hatch("🐍", 4) end, desc = "Hatch a snake" },
    },
  },

  -- vim-be-good - game to practice vim motions
  {
    "ThePrimeagen/vim-be-good",
    cmd = "VimBeGood",
    keys = {
      { "<leader>fv", "<cmd>VimBeGood<cr>", desc = "Vim Be Good (game)" },
    },
  },

  -- leetcode.nvim - solve leetcode problems in neovim (bonus!)
  {
    "kawre/leetcode.nvim",
    build = ":TSUpdate html",
    cmd = "Leet",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      lang = "python3",
    },
    keys = {
      { "<leader>fl", "<cmd>Leet<cr>", desc = "LeetCode" },
    },
  },
}

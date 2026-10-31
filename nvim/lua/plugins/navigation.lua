---@type LazySpec
return {
  -- flash.nvim - lightning fast navigation
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        char = { enabled = false }, -- Disable on f/t to avoid conflicts
      },
    },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      -- Not in visual mode: visual S is nvim-surround's "surround selection".
      { "S", mode = { "n", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },

  -- harpoon - quick file switching, under <leader>j ("jump"; <leader>h is
  -- AstroNvim's Home Screen)
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ja", function() require("harpoon"):list():add() end, desc = "Harpoon add" },
      { "<leader>jj", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Harpoon menu" },
      { "<leader>1", function() require("harpoon"):list():select(1) end, desc = "Harpoon 1" },
      { "<leader>2", function() require("harpoon"):list():select(2) end, desc = "Harpoon 2" },
      { "<leader>3", function() require("harpoon"):list():select(3) end, desc = "Harpoon 3" },
      { "<leader>4", function() require("harpoon"):list():select(4) end, desc = "Harpoon 4" },
    },
    config = function()
      require("harpoon"):setup()
    end,
  },
}

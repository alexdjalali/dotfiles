---@type LazySpec
return {
  -- nvim-surround
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  -- vim-visual-multi - multi-cursor
  {
    "mg979/vim-visual-multi",
    event = "VeryLazy",
    init = function()
      vim.g.VM_maps = {
        ["Find Under"] = "<C-d>",
        ["Find Subword Under"] = "<C-d>",
      }
    end,
  },

  -- undotree
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    keys = {
      { "<leader>U", "<cmd>UndotreeToggle<cr>", desc = "Undo tree" },
    },
  },

  -- nvim-spectre - search/replace
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    keys = {
      { "<leader>sr", function() require("spectre").open() end, desc = "Search/Replace" },
      { "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end, desc = "Search word (Spectre)" },
      { "<leader>sf", function() require("spectre").open_file_search() end, desc = "Search in file (Spectre)" },
    },
    opts = {},
  },
}

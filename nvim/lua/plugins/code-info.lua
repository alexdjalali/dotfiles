---@type LazySpec
return {
  -- glance.nvim - 700+ stars - better peek definitions
  {
    "dnlhc/glance.nvim",
    cmd = "Glance",
    keys = {
      { "gd", "<cmd>Glance definitions<cr>", desc = "Glance definitions" },
      { "gr", "<cmd>Glance references<cr>", desc = "Glance references" },
      { "gy", "<cmd>Glance type_definitions<cr>", desc = "Glance type definitions" },
      { "gi", "<cmd>Glance implementations<cr>", desc = "Glance implementations" },
    },
    opts = {
      height = 18,
      border = {
        enable = true,
        top_char = "―",
        bottom_char = "―",
      },
      list = {
        position = "right",
        width = 0.33,
      },
      theme = {
        enable = true,
        mode = "auto",
      },
    },
  },

  -- package-info.nvim - 400+ stars - show package versions
  {
    "vuki656/package-info.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    ft = "json",
    keys = {
      { "<leader>ns", function() require("package-info").show() end, desc = "Show package info", ft = "json" },
      { "<leader>nc", function() require("package-info").hide() end, desc = "Hide package info", ft = "json" },
      { "<leader>nt", function() require("package-info").toggle() end, desc = "Toggle package info", ft = "json" },
      { "<leader>nu", function() require("package-info").update() end, desc = "Update package", ft = "json" },
      { "<leader>nd", function() require("package-info").delete() end, desc = "Delete package", ft = "json" },
      { "<leader>ni", function() require("package-info").install() end, desc = "Install package", ft = "json" },
      { "<leader>nv", function() require("package-info").change_version() end, desc = "Change version", ft = "json" },
    },
    opts = {},
  },

  -- neogen - 1k+ stars - generate documentation
  {
    "danymat/neogen",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    cmd = "Neogen",
    keys = {
      { "<leader>ngf", function() require("neogen").generate({ type = "func" }) end, desc = "Generate function doc" },
      { "<leader>ngc", function() require("neogen").generate({ type = "class" }) end, desc = "Generate class doc" },
      { "<leader>ngt", function() require("neogen").generate({ type = "type" }) end, desc = "Generate type doc" },
      { "<leader>ngF", function() require("neogen").generate({ type = "file" }) end, desc = "Generate file doc" },
    },
    opts = {
      snippet_engine = "luasnip",
      enabled = true,
      languages = {
        python = {
          template = {
            annotation_convention = "google_docstrings",
          },
        },
      },
    },
  },
}

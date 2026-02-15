---@type LazySpec
return {
  -- Disable Snacks.notifier (conflicts with noice.nvim/nvim-notify)
  -- Disable Snacks.image (iTerm doesn't support kitty graphics protocol)
  {
    "folke/snacks.nvim",
    opts = {
      notifier = { enabled = false },
      image = { enabled = false },
    },
  },

  -- nvim-bqf - 2k+ stars - better quickfix
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    opts = {
      preview = {
        auto_preview = true,
        border = "rounded",
      },
    },
  },

  -- nvim-window-picker - 800+ stars - visual window selection
  {
    "s1n7ax/nvim-window-picker",
    version = "*",
    keys = {
      {
        "<leader>wp",
        function()
          local picked_window_id = require("window-picker").pick_window()
          if picked_window_id then
            vim.api.nvim_set_current_win(picked_window_id)
          end
        end,
        desc = "Pick window",
      },
    },
    opts = {
      hint = "floating-big-letter",
      show_prompt = false,
      filter_rules = {
        bo = {
          filetype = { "neo-tree", "neo-tree-popup", "notify", "noice" },
          buftype = { "terminal", "quickfix" },
        },
      },
    },
  },

  -- nvim-colorizer.lua - 700+ stars
  {
    "NvChad/nvim-colorizer.lua",
    event = "BufReadPost",
    opts = {
      user_default_options = {
        tailwind = true,
        css = true,
        mode = "virtualtext",
      },
    },
  },

  -- noice.nvim - 4k+ stars (folke) - better UI
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      notify = { enabled = false },
      lsp = {
        progress = { enabled = true },
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        hover = { enabled = true },
        signature = { enabled = true, auto_open = { enabled = true } },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
        lsp_doc_border = true,
      },
      views = {
        cmdline_popup = {
          border = { style = "rounded" },
          position = { row = "50%", col = "50%" },
        },
      },
      routes = {
        {
          filter = { event = "msg_show", find = "%d+L, %d+B" },
          view = "mini",
        },
      },
    },
    keys = {
      { "<leader>nl", function() require("noice").cmd("last") end, desc = "Noice last message" },
      { "<leader>nh", function() require("noice").cmd("history") end, desc = "Noice history" },
    },
  },

  -- nvim-notify - 3k+ stars
  {
    "rcarriga/nvim-notify",
    opts = {
      timeout = 2000,
      render = "compact",
      stages = "fade",
      background_colour = "#000000",
    },
  },

}

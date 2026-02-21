-- GitHub Copilot - inline AI ghost text completions
---@type LazySpec
return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        -- Alt-based keybindings to avoid nvim-cmp Tab conflicts
        keymap = {
          accept = "<A-f>",
          accept_word = "<A-w>",
          accept_line = "<A-a>",
          next = "<A-e>",
          prev = "<A-r>",
          dismiss = "<A-c>",
        },
      },
      panel = { enabled = false }, -- Use ghost text only, not the panel
      -- Disable in non-code filetypes
      filetypes = {
        help = false,
        gitcommit = false,
        gitrebase = false,
        ["neo-tree"] = false,
        TelescopePrompt = false,
        AvanteInput = false,
        DressingInput = false,
        ["neo-tree-popup"] = false,
        lazy = false,
        mason = false,
        lspinfo = false,
        toggleterm = false,
        qf = false,
        ["."] = false,
      },
    },
    config = function(_, opts)
      require("copilot").setup(opts)

      -- Normal-mode toggles under <leader>i ("Inline AI")
      vim.keymap.set("n", "<leader>it", function()
        require("copilot.suggestion").toggle_auto_trigger()
      end, { desc = "Toggle Copilot" })
      vim.keymap.set("n", "<leader>id", "<cmd>Copilot disable<cr>", { desc = "Disable Copilot" })
      vim.keymap.set("n", "<leader>ie", "<cmd>Copilot enable<cr>", { desc = "Enable Copilot" })
      vim.keymap.set("n", "<leader>is", "<cmd>Copilot status<cr>", { desc = "Copilot status" })

      -- Suppress ghost text when nvim-cmp menu is visible
      local ok, cmp = pcall(require, "cmp")
      if ok then
        cmp.event:on("menu_opened", function()
          require("copilot.suggestion").dismiss()
          vim.b.copilot_suggestion_hidden = true
        end)
        cmp.event:on("menu_closed", function()
          vim.b.copilot_suggestion_hidden = false
        end)
      end
    end,
  },
}

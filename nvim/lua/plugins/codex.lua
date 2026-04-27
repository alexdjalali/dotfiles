-- OpenAI Codex CLI integration via codex.nvim (floating terminal)
---@type LazySpec
return {
  {
    "kkrampis/codex.nvim",
    lazy = true,
    cmd = { "Codex", "CodexToggle" },
    opts = {
      keymaps = {
        toggle = nil, -- We handle toggle via <leader>O keybindings below
        quit = "<C-q>",
      },
      border = "rounded",
      width = 0.9,
      height = 0.9,
      autoinstall = false, -- Already installed globally via npm
      panel = false, -- Floating window (matches Claude/Cursor/Kilo pattern)
    },
    keys = {
      { "<leader>O", nil, desc = "OpenAI Codex" },
      {
        "<leader>Ot",
        function() require("codex").toggle() end,
        desc = "Toggle Codex",
        mode = { "n", "t" },
      },
      { "<leader>Oc", "<cmd>Codex<cr>", desc = "Open Codex" },
    },
  },
}

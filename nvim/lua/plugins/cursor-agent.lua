-- Cursor Agent (CLI) integration via floating terminal, under <leader>I
-- (<leader>C is AstroNvim's force-close buffer)
---@type LazySpec
return {
  "suiramdev/cursor-nvim",
  lazy = true,
  config = function()
    require("cursorcli").setup {
      command = { "agent" },
      auto_insert = true,
      notify = true,
      path = { relative_to_cwd = true },
      float = {
        width = 0.9,
        height = 0.8,
        border = "rounded",
      },
    }
  end,
  keys = {
    { "<leader>I", nil, desc = "Cursor Agent" },
    { "<leader>It", function() require("cursorcli").toggle() end, desc = "Toggle Cursor Agent", mode = "n" },
    { "<leader>Ic", function() require("cursorcli").close() end, desc = "Close Cursor Agent", mode = "n" },
    { "<leader>Ir", function() require("cursorcli").restart() end, desc = "Restart (new session)", mode = "n" },
    { "<leader>IR", function() require("cursorcli").resume() end, desc = "Resume last session", mode = "n" },
    { "<leader>Il", function() require("cursorcli").list_sessions() end, desc = "List sessions", mode = "n" },
    { "<leader>Is", function() require("cursorcli").add_visual_selection() end, desc = "Send selection", mode = "x" },
    { "<leader>If", function() require("cursorcli").request_fix_error_at_cursor() end, desc = "Fix error at cursor", mode = "n" },
    {
      "<leader>IF",
      function() require("cursorcli").request_fix_error_at_cursor_in_new_session() end,
      desc = "New session: fix error at cursor",
      mode = "n",
    },
    {
      "<leader>IF",
      function() require("cursorcli").add_visual_selection_to_new_session() end,
      desc = "New session: send selection",
      mode = "x",
    },
    { "<leader>Ie", function() require("cursorcli").quick_edit() end, desc = "Quick Edit", mode = "x" },
  },
}

-- Cursor Agent (CLI) integration via floating terminal
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
    { "<leader>C", nil, desc = "Cursor Agent" },
    { "<leader>Ct", function() require("cursorcli").toggle() end, desc = "Toggle Cursor Agent", mode = "n" },
    { "<leader>Cc", function() require("cursorcli").close() end, desc = "Close Cursor Agent", mode = "n" },
    { "<leader>Cr", function() require("cursorcli").restart() end, desc = "Restart (new session)", mode = "n" },
    { "<leader>CR", function() require("cursorcli").resume() end, desc = "Resume last session", mode = "n" },
    { "<leader>Cl", function() require("cursorcli").list_sessions() end, desc = "List sessions", mode = "n" },
    { "<leader>Cs", function() require("cursorcli").add_visual_selection() end, desc = "Send selection", mode = "x" },
    { "<leader>Cf", function() require("cursorcli").request_fix_error_at_cursor() end, desc = "Fix error at cursor", mode = "n" },
    {
      "<leader>CF",
      function() require("cursorcli").request_fix_error_at_cursor_in_new_session() end,
      desc = "New session: fix error at cursor",
      mode = "n",
    },
    {
      "<leader>CF",
      function() require("cursorcli").add_visual_selection_to_new_session() end,
      desc = "New session: send selection",
      mode = "x",
    },
    { "<leader>Ce", function() require("cursorcli").quick_edit() end, desc = "Quick Edit", mode = "x" },
  },
}

-- Cursor Agent (CLI) integration via floating terminal
---@type LazySpec
return {
  "suiramdev/cursor-nvim",
  lazy = true,
  config = function()
    require("cursor_agent").setup {
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
    { "<leader>Ct", function() require("cursor_agent").toggle() end, desc = "Toggle Cursor Agent", mode = "n" },
    { "<leader>Cc", function() require("cursor_agent").close() end, desc = "Close Cursor Agent", mode = "n" },
    { "<leader>Cr", function() require("cursor_agent").restart() end, desc = "Restart (new session)", mode = "n" },
    { "<leader>CR", function() require("cursor_agent").resume() end, desc = "Resume last session", mode = "n" },
    { "<leader>Cl", function() require("cursor_agent").list_sessions() end, desc = "List sessions", mode = "n" },
    { "<leader>Cs", function() require("cursor_agent").add_visual_selection() end, desc = "Send selection", mode = "x" },
    { "<leader>Cf", function() require("cursor_agent").request_fix_error_at_cursor() end, desc = "Fix error at cursor", mode = "n" },
    {
      "<leader>CF",
      function() require("cursor_agent").request_fix_error_at_cursor_in_new_session() end,
      desc = "New session: fix error at cursor",
      mode = "n",
    },
    {
      "<leader>CF",
      function() require("cursor_agent").add_visual_selection_to_new_session() end,
      desc = "New session: send selection",
      mode = "x",
    },
    { "<leader>Ce", function() require("cursor_agent").quick_edit() end, desc = "Quick Edit", mode = "x" },
  },
}

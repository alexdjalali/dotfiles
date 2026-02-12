-- Claude Code CLI integration via toggleterm
---@type LazySpec
return {
  {
    "akinsho/toggleterm.nvim",
    keys = {
      -- Dedicated Claude Code terminal
      {
        "<leader>ac",
        function()
          local Terminal = require("toggleterm.terminal").Terminal
          local claude = Terminal:new({
            cmd = "claude",
            direction = "vertical",
            size = function() return math.floor(vim.o.columns * 0.4) end,
            close_on_exit = false,
            on_open = function(term)
              vim.cmd("startinsert!")
            end,
          })
          claude:toggle()
        end,
        desc = "Claude Code",
      },
      -- Claude with current file context
      {
        "<leader>af",
        function()
          local file = vim.fn.expand("%:p")
          local Terminal = require("toggleterm.terminal").Terminal
          local claude = Terminal:new({
            cmd = "claude --file " .. vim.fn.shellescape(file),
            direction = "vertical",
            size = function() return math.floor(vim.o.columns * 0.4) end,
            close_on_exit = false,
          })
          claude:toggle()
        end,
        desc = "Claude with file",
      },
      -- Claude in float
      {
        "<leader>aF",
        function()
          local Terminal = require("toggleterm.terminal").Terminal
          local claude = Terminal:new({
            cmd = "claude",
            direction = "float",
            float_opts = {
              border = "curved",
              width = math.floor(vim.o.columns * 0.8),
              height = math.floor(vim.o.lines * 0.8),
            },
            close_on_exit = false,
          })
          claude:toggle()
        end,
        desc = "Claude (float)",
      },
    },
  },
}

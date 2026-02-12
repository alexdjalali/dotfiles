-- kulala.nvim - newer HTTP client, no lua 5.1 requirement
---@type LazySpec
return {
  {
    "mistweaverco/kulala.nvim",
    ft = "http",
    keys = {
      { "<leader>rr", function() require("kulala").run() end, desc = "Run HTTP request" },
      { "<leader>ra", function() require("kulala").run_all() end, desc = "Run all requests" },
      { "<leader>rp", function() require("kulala").replay() end, desc = "Replay last request" },
    },
    opts = {},
  },
}

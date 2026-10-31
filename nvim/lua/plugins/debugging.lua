-- Debugging extras on top of AstroNvim's nvim-dap setup.
--
-- AstroNvim ships nvim-dap, nvim-dap-ui (opened and closed with each session)
-- and the <leader>d keys plus F-keys; the go and python packs set up nvim-dap-go
-- and nvim-dap-python (the latter with Mason's debugpy-adapter, so a debug
-- session never depends on the system python3 having debugpy). Only what
-- AstroNvim lacks lives here.
---@type LazySpec
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- Variable values as virtual text while stepping
      { "theHamsta/nvim-dap-virtual-text", opts = {} },
    },
    keys = {
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run last" },
    },
  },
}

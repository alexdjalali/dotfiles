---@type LazySpec
return {
  -- neotest - test runner with inline results
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      -- Test adapters: the go, python and typescript packs register
      -- neotest-golang, neotest-python and neotest-jest through opts.
      "marilari88/neotest-vitest",
    },
    keys = {
      { "<leader>tr", function() require("neotest").run.run() end, desc = "Run nearest test" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run test file" },
      { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug test" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle test summary" },
      { "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Show test output" },
      { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Toggle output panel" },
      { "<leader>tS", function() require("neotest").run.stop() end, desc = "Stop test" },
      { "<leader>tw", function() require("neotest").watch.toggle() end, desc = "Toggle watch" },
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      table.insert(opts.adapters, require("neotest-vitest"))
      opts.quickfix = { enabled = true, open = false }
      opts.status = { virtual_text = true, signs = true }
      opts.output = { enabled = true, open_on_run = false }
      opts.summary = { animated = true, enabled = true }
    end,
  },

  -- The python pack builds its neotest-python adapter from these opts.
  {
    "nvim-neotest/neotest-python",
    opts = {
      dap = { justMyCode = false },
      runner = "pytest",
      python = function()
        local venv = vim.fn.getcwd() .. "/.venv/bin/python"
        if vim.fn.executable(venv) == 1 then return venv end
        return "python"
      end,
    },
  },

  -- coverage.nvim - show test coverage
  {
    "andythigpen/nvim-coverage",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "Coverage", "CoverageLoad", "CoverageShow", "CoverageToggle" },
    keys = {
      { "<leader>tc", "<cmd>Coverage<cr>", desc = "Toggle coverage" },
      { "<leader>tC", "<cmd>CoverageSummary<cr>", desc = "Coverage summary" },
    },
    opts = {
      auto_reload = true,
      lang = {
        python = {
          coverage_command = "coverage json --fail-under=0 -q -o -",
        },
        go = {
          coverage_file = "coverage.out",
        },
      },
    },
  },

  -- kulala.nvim - HTTP/REST client (<leader>H*; <leader>r* is refactoring)
  {
    "mistweaverco/kulala.nvim",
    ft = "http",
    keys = {
      { "<leader>Hr", function() require("kulala").run() end, desc = "Run HTTP request", ft = "http" },
      { "<leader>Ha", function() require("kulala").run_all() end, desc = "Run all requests", ft = "http" },
      { "<leader>Hi", function() require("kulala").inspect() end, desc = "Inspect request", ft = "http" },
      { "<leader>Ht", function() require("kulala").toggle_view() end, desc = "Toggle view", ft = "http" },
      { "<leader>Hc", function() require("kulala").copy() end, desc = "Copy as cURL", ft = "http" },
    },
    opts = {
      default_view = "body",
      default_env = "dev",
      debug = false,
    },
  },
}

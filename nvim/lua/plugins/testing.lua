---@type LazySpec
return {
  -- neotest - 2k+ stars - test runner with inline results
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      -- Test adapters
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-go",
      "nvim-neotest/neotest-jest",
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
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            dap = { justMyCode = false },
            runner = "pytest",
            python = function()
              local venv = vim.fn.getcwd() .. "/.venv/bin/python"
              if vim.fn.executable(venv) == 1 then return venv end
              return "python"
            end,
          }),
          require("neotest-go"),
          require("neotest-jest"),
          require("neotest-vitest"),
        },
        quickfix = {
          enabled = true,
          open = false,
        },
        status = {
          virtual_text = true,
          signs = true,
        },
        output = {
          enabled = true,
          open_on_run = false,
        },
        summary = {
          animated = true,
          enabled = true,
        },
      })
    end,
  },

  -- coverage.nvim - 300+ stars - show test coverage
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

  -- kulala.nvim - HTTP/REST client for testing APIs
  {
    "mistweaverco/kulala.nvim",
    ft = "http",
    keys = {
      { "<leader>rr", function() require("kulala").run() end, desc = "Run HTTP request", ft = "http" },
      { "<leader>ra", function() require("kulala").run_all() end, desc = "Run all requests", ft = "http" },
      { "<leader>ri", function() require("kulala").inspect() end, desc = "Inspect request", ft = "http" },
      { "<leader>rt", function() require("kulala").toggle_view() end, desc = "Toggle view", ft = "http" },
      { "<leader>rc", function() require("kulala").copy() end, desc = "Copy as cURL", ft = "http" },
    },
    opts = {
      default_view = "body",
      default_env = "dev",
      debug = false,
    },
  },
}

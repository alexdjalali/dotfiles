-- Go development enhancements
---@type LazySpec
return {
  -- gopher.nvim - Go code generation and tooling
  {
    "olexsmir/gopher.nvim",
    ft = "go",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    -- Mason installs the tools gopher runs (the go pack lists them); the pack's
    -- build hook runs :GoInstallDeps only when Mason is absent.
    opts = {},
    keys = {
      -- Struct tags
      { "<leader>Gt", "<cmd>GoTagAdd json<cr>", desc = "Add json tags", ft = "go" },
      { "<leader>GT", "<cmd>GoTagRm json<cr>", desc = "Remove json tags", ft = "go" },
      { "<leader>Gy", "<cmd>GoTagAdd yaml<cr>", desc = "Add yaml tags", ft = "go" },
      -- Generate
      { "<leader>Gi", "<cmd>GoImpl<cr>", desc = "Implement interface", ft = "go" },
      { "<leader>Ge", "<cmd>GoIfErr<cr>", desc = "Generate if err", ft = "go" },
      { "<leader>Gc", "<cmd>GoCmt<cr>", desc = "Generate comment", ft = "go" },
      -- Mod
      { "<leader>Gm", "<cmd>GoMod tidy<cr>", desc = "Go mod tidy", ft = "go" },
      -- Tests
      { "<leader>Ga", "<cmd>GoTestAdd<cr>", desc = "Add test for func", ft = "go" },
      { "<leader>GA", "<cmd>GoTestsAll<cr>", desc = "Add tests for all funcs", ft = "go" },
      { "<leader>GE", "<cmd>GoTestsExp<cr>", desc = "Add tests for exported", ft = "go" },
    },
  },

  -- No global build tags (the go pack sets `-tags integration`): tags belong to
  -- the project that uses them, e.g. in its .nvim.lua.
  {
    "AstroNvim/astrolsp",
    opts = function(_, opts)
      local gopls = vim.tbl_get(opts, "config", "gopls", "settings", "gopls")
      if gopls then gopls.buildFlags = nil end
    end,
  },

  -- Configure gopls with enhanced settings
  {
    "AstroNvim/astrolsp",
    opts = {
      config = {
        gopls = {
          settings = {
            gopls = {
              -- gopls keeps to `go vet`'s analyzers; golangci-lint (none-ls) owns the
              -- rest with the repo's exclusions, so no finding shows up twice.
              analyses = {
                shadow = false,
                fieldalignment = false,
                nilness = false,
                unusedparams = false,
                unusedwrite = false,
                useany = false,
                unusedvariable = false,
              },
              -- staticcheck runs in golangci-lint, with the repo's exclusions.
              staticcheck = false,
              -- Inlay hints
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              -- Code lens
              codelenses = {
                gc_details = true,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              -- Formatting
              gofumpt = true,
              -- Semantic tokens
              semanticTokens = true,
              -- Completion
              usePlaceholders = true,
              completeUnimported = true,
              -- Diagnostics
              diagnosticsDelay = "500ms",
              diagnosticsTrigger = "Edit",
            },
          },
        },
      },
    },
  },
}

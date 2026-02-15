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
    build = function()
      vim.cmd([[silent! GoInstallDeps]])
    end,
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

  -- go.nvim - Additional Go tooling (complementary to gopher)
  {
    "ray-x/go.nvim",
    ft = { "go", "gomod" },
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    build = ':lua require("go.install").update_all_sync()',
    opts = {
      -- Disable features that overlap with other plugins
      lsp_cfg = false, -- We use gopls via astrolsp
      lsp_gofumpt = false, -- We use gofumpt via mason
      lsp_keymaps = false, -- We use our own keymaps
      lsp_inlay_hints = { enable = false }, -- Use astrolsp inlay hints
      -- Enable useful features
      trouble = true, -- Use trouble.nvim for diagnostics
      luasnip = true, -- Use luasnip for snippets
      dap_debug = false, -- We use nvim-dap-go
      -- Test settings
      test_runner = "go",
      run_in_floaterm = true,
      floaterm = {
        position = "bottom",
        width = 0.8,
        height = 0.4,
      },
    },
    keys = {
      -- Fill struct
      { "<leader>Gf", "<cmd>GoFillStruct<cr>", desc = "Fill struct", ft = "go" },
      { "<leader>Gp", "<cmd>GoFillSwitch<cr>", desc = "Fill switch", ft = "go" },
      -- Alternate files
      { "<leader>Gv", "<cmd>GoAlt<cr>", desc = "Go to alt file (test/impl)", ft = "go" },
      { "<leader>GV", "<cmd>GoAltV<cr>", desc = "Alt file in vsplit", ft = "go" },
      -- Code lens / Run
      { "<leader>Gr", "<cmd>GoRun<cr>", desc = "Go run", ft = "go" },
      { "<leader>Gs", "<cmd>GoStop<cr>", desc = "Go stop", ft = "go" },
      -- Documentation
      { "<leader>Gd", "<cmd>GoDoc<cr>", desc = "Go doc", ft = "go" },
      -- Linting
      { "<leader>Gl", "<cmd>GoLint<cr>", desc = "Go lint", ft = "go" },
      -- Code generation
      { "<leader>Gj", "<cmd>GoAddTag json<cr>", desc = "Add json tag (go.nvim)", ft = "go" },
      { "<leader>Gx", "<cmd>GoClearTag<cr>", desc = "Clear all tags", ft = "go" },
    },
  },

  -- Configure gopls with enhanced settings
  {
    "AstroNvim/astrolsp",
    opts = {
      config = {
        gopls = {
          settings = {
            gopls = {
              -- Analysis settings
              analyses = {
                unusedparams = true,
                shadow = true,
                nilness = true,
                unusedwrite = true,
                useany = true,
                unusedvariable = true,
              },
              -- Enable all staticcheck analyzers
              staticcheck = true,
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
              -- Build
              buildFlags = { "-tags=integration,e2e" },
            },
          },
        },
      },
    },
  },
}

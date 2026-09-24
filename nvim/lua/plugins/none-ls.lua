-- none-ls.nvim - Additional linters and formatters
---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvimtools/none-ls-extras.nvim", -- Extra sources
  },
  opts = function(_, opts)
    local null_ls = require "null-ls"
    local b = null_ls.builtins

    -- Honour the repo's own config, never impose one: a config-driven linter
    -- runs only where the repo root ships that config (`root_has`).
    local function root_has(bufnr, markers)
      return vim.fs.root(bufnr or 0, markers) ~= nil
    end

    -- Filter out any shellcheck sources added by astrocommunity (removed from none-ls builtins)
    if opts.sources then
      opts.sources = vim.tbl_filter(
        function(source) return not (source and source.name == "shellcheck") end,
        opts.sources
      )
    end

    -- Only insert new sources, do not replace the existing ones
    opts.sources = require("astrocore").list_insert_unique(opts.sources, {
      -- ╭─────────────────────────────────────────────────────────╮
      -- │                         Go                              │
      -- ╰─────────────────────────────────────────────────────────╯
      -- golangci-lint with no extra flags, on save: it reads the repo's own
      -- .golangci.yml, so the editor reports what the repo's lint run reports.
      b.diagnostics.golangci_lint,
      -- goimports - Organize imports
      b.formatting.goimports,
      -- golines - Format long lines
      b.formatting.golines.with {
        extra_args = { "--max-len=120", "--base-formatter=gofumpt" },
      },

      -- ╭─────────────────────────────────────────────────────────╮
      -- │                        Python                           │
      -- ╰─────────────────────────────────────────────────────────╯
      -- No mypy source: basedpyright (the LSP in python.lua) is the type checker.
      -- ruff (from none-ls-extras), preferring the repo's pinned copy in .venv/bin
      -- over Mason's.
      require("none-ls.formatting.ruff").with { prefer_local = ".venv/bin" },
      require("none-ls.formatting.ruff_format").with { prefer_local = ".venv/bin" },

      -- ╭─────────────────────────────────────────────────────────╮
      -- │                  TypeScript / JavaScript                │
      -- ╰─────────────────────────────────────────────────────────╯
      -- eslint from the project's node_modules (its own version and config), on
      -- save. The plain source, not eslint_d, which mason-null-ls skips.
      require("none-ls.diagnostics.eslint").with {
        prefer_local = "node_modules/.bin",
        method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
      },

      -- ╭─────────────────────────────────────────────────────────╮
      -- │                     Infrastructure                      │
      -- ╰─────────────────────────────────────────────────────────╯
      -- Terraform
      b.formatting.terraform_fmt,
      b.diagnostics.terraform_validate,
      -- tflint removed from none-ls builtins; use mason + lspconfig instead

      -- YAML — let yamllint use each project's .yamllint config (auto-discovered
      -- from the repo root). The old hardcoded `-d {...}` overrode and ignored
      -- per-project configs (e.g. GitHub Actions repos that disable `truthy` for
      -- `on:`). Projects without a config fall back to ~/.config/yamllint/config.
      b.diagnostics.yamllint,

      -- Docker
      b.diagnostics.hadolint,

      -- Shell (shellcheck removed from none-ls builtins; use mason + bashls instead)
      b.formatting.shfmt.with {
        extra_args = { "-i", "2", "-ci", "-bn" }, -- 2 space indent, case indent, binary newline
      },

      -- ╭─────────────────────────────────────────────────────────╮
      -- │                        General                          │
      -- ╰─────────────────────────────────────────────────────────╯
      -- Markdown: markdownlint-cli2 (reads .markdownlint-cli2.* and the v1 config
      -- files), only where the repo ships a config. mason-null-ls skips the v1
      -- markdownlint, which can't read cli2 configs.
      b.diagnostics.markdownlint_cli2.with {
        runtime_condition = function(params)
          return root_has(params.bufnr, {
            ".markdownlint-cli2.jsonc",
            ".markdownlint-cli2.yaml",
            ".markdownlint-cli2.cjs",
            ".markdownlint-cli2.mjs",
            ".markdownlint.jsonc",
            ".markdownlint.json",
            ".markdownlint.yaml",
            ".markdownlint.yml",
            ".markdownlint.cjs",
            ".markdownlint.mjs",
            ".markdownlintrc",
          })
        end,
      },

      -- Lua
      b.formatting.stylua,

      -- JSON
      b.formatting.prettier.with {
        -- Use the project's own prettier (node_modules/.bin) when present.
        prefer_local = "node_modules/.bin",
        filetypes = { "json", "jsonc", "markdown", "css", "scss", "html" },
      },

      -- Code actions
      b.code_actions.gitsigns, -- Git code actions
    })

    -- Configure diagnostics appearance
    opts.diagnostics_format = "[#{c}] #{m} (#{s})"
    opts.debounce = 250
    opts.default_timeout = 5000

    return opts
  end,
}

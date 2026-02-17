-- none-ls.nvim - Additional linters and formatters
---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvimtools/none-ls-extras.nvim", -- Extra sources
  },
  opts = function(_, opts)
    local null_ls = require("null-ls")
    local b = null_ls.builtins

    -- Filter out any shellcheck sources added by astrocommunity (removed from none-ls builtins)
    if opts.sources then
      opts.sources = vim.tbl_filter(function(source)
        return not (source and source.name == "shellcheck")
      end, opts.sources)
    end

    -- Only insert new sources, do not replace the existing ones
    opts.sources = require("astrocore").list_insert_unique(opts.sources, {
      -- ╭─────────────────────────────────────────────────────────╮
      -- │                         Go                              │
      -- ╰─────────────────────────────────────────────────────────╯
      -- golangci-lint - Meta linter (runs 50+ linters)
      b.diagnostics.golangci_lint.with({
        extra_args = {
          "--fast",
          "--enable=gosec,prealloc,revive,gocritic,errorlint,exhaustive",
        },
      }),
      -- goimports - Organize imports
      b.formatting.goimports,
      -- golines - Format long lines
      b.formatting.golines.with({
        extra_args = { "--max-len=120", "--base-formatter=gofumpt" },
      }),

      -- ╭─────────────────────────────────────────────────────────╮
      -- │                        Python                           │
      -- ╰─────────────────────────────────────────────────────────╯
      -- mypy - Static type checker (complementary to basedpyright)
      b.diagnostics.mypy.with({
        command = function()
          local venv_mypy = vim.fn.getcwd() .. "/.venv/bin/mypy"
          if vim.fn.executable(venv_mypy) == 1 then
            return venv_mypy
          end
          return "mypy"
        end,
        extra_args = function()
          local venv = vim.fn.getcwd() .. "/.venv"
          local args = { "--no-incremental" }
          if vim.fn.isdirectory(venv) == 1 then
            vim.list_extend(args, { "--python-executable", venv .. "/bin/python" })
          end
          return args
        end,
      }),
      -- ruff - Fast linter and formatter (from none-ls-extras)
      require("none-ls.formatting.ruff").with({}),
      require("none-ls.formatting.ruff_format").with({}),

      -- ╭─────────────────────────────────────────────────────────╮
      -- │                     Infrastructure                      │
      -- ╰─────────────────────────────────────────────────────────╯
      -- Terraform
      b.formatting.terraform_fmt,
      b.diagnostics.terraform_validate,
      -- tflint removed from none-ls builtins; use mason + lspconfig instead

      -- YAML
      b.diagnostics.yamllint.with({
        extra_args = { "-d", "{extends: default, rules: {line-length: {max: 120}}}" },
      }),

      -- Docker
      b.diagnostics.hadolint,

      -- Shell (shellcheck removed from none-ls builtins; use mason + bashls instead)
      b.formatting.shfmt.with({
        extra_args = { "-i", "2", "-ci", "-bn" }, -- 2 space indent, case indent, binary newline
      }),

      -- ╭─────────────────────────────────────────────────────────╮
      -- │                        General                          │
      -- ╰─────────────────────────────────────────────────────────╯
      -- Markdown
      b.diagnostics.markdownlint.with({
        extra_args = { "--disable", "MD013", "MD033" }, -- Allow long lines and inline HTML
      }),

      -- Lua
      b.formatting.stylua,

      -- JSON
      b.formatting.prettier.with({
        filetypes = { "json", "jsonc", "markdown", "css", "scss", "html" },
      }),

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

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
      -- golangci-lint - Meta linter (runs 50+ linters)
      b.diagnostics.golangci_lint.with {
        extra_args = {
          "--fast-only", -- golangci-lint v2 renamed --fast -> --fast-only
          "--enable=gosec,prealloc,revive,gocritic,errorlint,exhaustive",
        },
      },
      -- goimports - Organize imports
      b.formatting.goimports,
      -- golines - Format long lines
      b.formatting.golines.with {
        extra_args = { "--max-len=120", "--base-formatter=gofumpt" },
      },

      -- ╭─────────────────────────────────────────────────────────╮
      -- │                        Python                           │
      -- ╰─────────────────────────────────────────────────────────╯
      -- mypy - Static type checker (complementary to basedpyright)
      b.diagnostics.mypy.with {
        -- Command resolution: the project's own mypy (<root>/.venv/bin/mypy, for
        -- version parity with CI) -> an isolated `uv tool install mypy`
        -- (~/.local/bin/mypy) -> whatever `mypy` is on PATH (Mason) as a last
        -- resort. Mason's mypy is deliberately NOT the primary: its venv is built
        -- with --system-site-packages (hardcoded in mason-core/installer/managers/
        -- pypi.lua), so it resolves imports against the global homebrew/user
        -- site-packages — the cause of "shadows library module" / wrong-env
        -- diagnostics — and Mason re-pollutes it on every auto-update. The uv tool
        -- is fully isolated and pinned, so this resolution stays correct.
        dynamic_command = function(params, done)
          if params.bufname and params.bufname ~= "" then
            for dir in vim.fs.parents(params.bufname) do
              local venv_mypy = dir .. "/.venv/bin/mypy"
              if vim.fn.executable(venv_mypy) == 1 then return done(venv_mypy) end
            end
          end
          local uv_mypy = vim.fn.expand "~/.local/bin/mypy"
          return done(vim.fn.executable(uv_mypy) == 1 and uv_mypy or "mypy")
        end,
        extra_args = function()
          local venv = vim.fn.getcwd() .. "/.venv"
          -- --cache-dir=/dev/null forces mypy to ignore every on-disk .mypy_cache.
          -- The previous --no-incremental only disabled incremental *mode*; mypy
          -- still read stale project caches in process_fresh_modules ->
          -- fix_cross_refs, crashing with "INTERNAL ERROR: Cannot find module for
          -- <X>" (see null-ls.log, recurring across mypy 2.0–2.2). A null cache dir
          -- means there are no fresh-from-cache modules to fix up, so that crash
          -- path can't be entered — with no fidelity loss (imports still followed).
          -- --no-warn-unused-configs: a per-file editor run only checks one module,
          -- so a project's whole-repo [[tool.mypy.overrides]] sections look "unused"
          -- and mypy prints a Warning to stderr that null-ls surfaces as a failed
          -- generator. Silence it for editor runs (CI still validates those sections).
          local args = { "--cache-dir=/dev/null", "--no-warn-unused-configs" }
          if vim.fn.isdirectory(venv) == 1 then
            vim.list_extend(args, { "--python-executable", venv .. "/bin/python" })
          end
          return args
        end,
      },
      -- ruff - Fast linter and formatter (from none-ls-extras)
      -- prefer_local pins these to the repo's pinned ruff (<root>/.venv/bin/ruff)
      -- instead of the auto-updated Mason copy, so format-on-save matches CI.
      require("none-ls.formatting.ruff").with { prefer_local = ".venv/bin" },
      require("none-ls.formatting.ruff_format").with { prefer_local = ".venv/bin" },

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
      -- Markdown
      b.diagnostics.markdownlint.with {
        extra_args = { "--disable", "MD013", "MD033" }, -- Allow long lines and inline HTML
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

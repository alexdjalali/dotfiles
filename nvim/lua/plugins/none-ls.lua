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

    -- A project-config-driven linter should only fire when the project ROOT
    -- actually ships its config — otherwise the editor invents a policy the
    -- repo (and its CI) never asked for, which is exactly the "nvim flags
    -- things the CLI doesn't" complaint. `root_has` returns true only when one
    -- of `markers` exists in the buffer's nearest ancestor directory (the repo
    -- root), so a source gated on it stays silent in repos that don't opt in.
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
      -- golangci-lint - run the repo's .golangci.yml EXACTLY as `search lint --go`
      -- (golangci-lint run ./...) does. No extra_args on purpose:
      --   * --fast-only would DROP the slow linters CI runs (staticcheck, gosec,
      --     unused, unparam, …) — nvim would then miss real CI findings.
      --   * --enable=revive,prealloc,exhaustive,… would FORCE-ADD linters the repo's
      --     `exclusions.rules` deliberately suppress on existing first-party code
      --     (the ADR-0058 burndown) — nvim would then show errors CI never reports.
      -- With no flags the builtin runs `golangci-lint run` in the file's module, so it
      -- auto-discovers .golangci.yml: identical enabled set, settings, and exclusions.
      -- It runs on save (the builtin's default method) since a full-config run is
      -- heavier than the old --fast pass — that's the cost of matching CI exactly.
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
      -- NOTE: no mypy source. This repo's Python type-checking is basedpyright ONLY
      -- — `search typecheck --python` runs `uv run basedpyright`, and there is no
      -- [tool.mypy] config anywhere in the tree. A mypy source here reports errors
      -- the CLI/CI never produce (the complaint that started this). basedpyright is
      -- the type authority (configured as an LSP in python.lua). mason-null-ls is
      -- also told to skip mypy (python.lua handlers) so it can't re-register it.
      -- ruff - Fast linter and formatter (from none-ls-extras)
      -- prefer_local pins these to the repo's pinned ruff (<root>/.venv/bin/ruff)
      -- instead of the auto-updated Mason copy, so format-on-save matches CI.
      require("none-ls.formatting.ruff").with { prefer_local = ".venv/bin" },
      require("none-ls.formatting.ruff_format").with { prefer_local = ".venv/bin" },

      -- ╭─────────────────────────────────────────────────────────╮
      -- │                  TypeScript / JavaScript                │
      -- ╰─────────────────────────────────────────────────────────╯
      -- eslint - matches `search lint --ts` (`pnpm lint` == `eslint .`). prefer_local
      -- pins it to the frontend's OWN eslint (node_modules/.bin) so the rule set is
      -- the project's ESLint v10 flat config (eslint.config.js) — identical to CI —
      -- not a Mason copy with a different eslint/plugin version. On-save (like
      -- golangci-lint) because a full eslint run is heavier than LSP type hints.
      -- (Using the plain `eslint` source, not `eslint_d`, so it's the exact project
      -- binary; mason-null-ls is told to skip eslint_d in python.lua handlers.)
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
      -- Markdown — run markdownlint-cli2 (the tool the repos here actually use),
      -- NOT the plain `markdownlint` v1 that Mason ships. The bloodhound repo (and
      -- others) configure markdown via `.markdownlint-cli2.jsonc`, whose schema
      -- (rules under a "config" key) the v1 CLI cannot read — so the old
      -- `b.diagnostics.markdownlint` ignored the repo's carefully tuned rules and
      -- applied v1 DEFAULTS, flooding docs-heavy trees (CLAUDE.md, docs/, ADRs)
      -- with warnings the repo deliberately disabled. markdownlint-cli2 (Homebrew/
      -- npm; registered in the repo's tools.yaml) auto-discovers the root config
      -- from the file upward, and is a superset of v1 (it also reads
      -- `.markdownlint.{json,yaml}` / `.markdownlintrc`), so it covers every repo.
      -- Gated on a root config so config-less repos stay silent instead of
      -- inheriting the tool's built-in defaults — honour the root, never impose one.
      -- mason-null-ls is told (python.lua handlers) to skip the v1 markdownlint so
      -- it can't re-register the noisy source alongside this one.
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

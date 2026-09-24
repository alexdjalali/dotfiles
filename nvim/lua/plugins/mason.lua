---@type LazySpec
return {
  {
    -- Append Mason's shim dir to PATH instead of prepending it (mason.nvim's
    -- default is "prepend", which puts ~/.local/share/nvim/mason/bin at PATH #1).
    -- Neovim still resolves Mason LSPs/formatters by absolute path, so the editor
    -- is unaffected — but terminals and subprocesses spawned from Neovim (:terminal,
    -- Claude Code, etc.) no longer inherit Mason's bin ahead of the project
    -- toolchain (Homebrew / $GOPATH/bin), where it shadowed golangci-lint, gofumpt,
    -- shellcheck, yamllint, … A Go-toolchain bump made this concrete: Mason's
    -- golangci-lint was still built with the old Go and refused to run against the
    -- repo's target version, breaking `search preflight`.
    "mason-org/mason.nvim",
    opts = {
      PATH = "append",
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        -- Lua
        "lua-language-server",
        "stylua",

        -- Python
        "basedpyright", -- Type checker / LSP (fallback; repo uses <root>/.venv copy)
        "ruff", -- Linter & formatter (fast, replaces flake8/black/isort)
        -- mypy intentionally NOT installed: this repo (and others here) type-check
        -- with basedpyright only. Installing it invites mason-null-ls to surface
        -- mypy errors the project's linters never emit.
        "debugpy", -- Debugger

        -- Go
        "gopls", -- LSP
        "gofumpt", -- Formatter (stricter gofmt)
        "golangci-lint", -- Meta-linter (runs 50+ linters)
        "gomodifytags", -- Struct tag modifier
        "gotests", -- Test generator
        "impl", -- Interface implementation generator
        "delve", -- Debugger
        "goimports", -- Import management
        "golines", -- Long line formatter

        -- TypeScript/JavaScript
        "typescript-language-server",
        "prettier",
        -- eslint_d intentionally NOT installed: none-ls runs the project's own
        -- eslint (node_modules/.bin) for version/flat-config parity with `pnpm lint`.

        -- Infrastructure
        "terraform-ls",
        "tflint", -- Terraform linter
        "yaml-language-server",
        "yamllint",
        "dockerfile-language-server",
        "hadolint", -- Dockerfile linter
        "bash-language-server",
        "shellcheck", -- Shell script linter
        "shfmt", -- Shell formatter

        -- JSON/TOML
        "json-lsp",
        "taplo", -- TOML LSP

        -- Markdown
        "markdownlint",
        "marksman", -- Markdown LSP

        -- LaTeX
        "texlab", -- LaTeX LSP (completion, diagnostics, build, forward search)
        "latexindent", -- LaTeX formatter
      },
      -- auto_update disabled: silent Mason updates drift the fallback linter/LSP
      -- versions away from each repo's pinned toolchain (the project .venv ruff/
      -- basedpyright, Homebrew golangci-lint), which is exactly what reintroduces
      -- "the editor flags things the CLI doesn't". Update deliberately via
      -- :MasonUpdate, then re-run `search preflight` to confirm parity.
      auto_update = false,
      run_on_start = true,
    },
  },
}

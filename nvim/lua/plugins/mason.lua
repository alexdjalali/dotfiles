---@type LazySpec
return {
  {
    -- Append Mason's bin to PATH (the default prepends it). Neovim finds Mason
    -- tools by absolute path; terminals spawned from Neovim keep the project's own
    -- toolchain (Homebrew, $GOPATH/bin) ahead of Mason's copies.
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
        -- No mypy: basedpyright is the type checker.
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
        -- No eslint_d: none-ls runs the project's own eslint.

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
      -- No silent updates: they drift Mason's fallback tools away from the
      -- versions repos pin. Update deliberately with :MasonUpdate.
      auto_update = false,
      run_on_start = true,
    },
  },
}

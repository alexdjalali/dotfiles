---@type LazySpec
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        -- Lua
        "lua-language-server",
        "stylua",

        -- Python
        "basedpyright", -- Type checker / LSP
        "ruff", -- Linter & formatter (fast, replaces flake8/black/isort)
        "mypy", -- Static type checker (complementary to basedpyright)
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
        "eslint_d", -- Fast eslint daemon

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
      },
      auto_update = true,
      run_on_start = true,
    },
  },
}

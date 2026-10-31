-- none-ls.nvim - Additional linters and formatters
--
-- One tool per job: where a language server formats (gopls with gofumpt, ruff,
-- stylua, terraform-ls, yamlls), none-ls adds no second formatter for it.
---@type LazySpec
return {
  -- This file is the one list of none-ls sources. mason-null-ls would also
  -- register a default source for every installed Mason tool, which ran
  -- goimports, golines, golangci-lint, prettier, stylua, yamllint and hadolint
  -- twice and added formatters the LSPs already run; its default handler is off.
  {
    "jay-babu/mason-null-ls.nvim",
    opts = { handlers = { function() end } },
  },
  {
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
        -- gopls formats (gofumpt = true in go.lua); goimports only fixes imports.
        -- golangci-lint with no extra flags, on save: it reads the repo's own
        -- .golangci.yml, so the editor reports what the repo's lint run reports.
        b.diagnostics.golangci_lint,
        b.formatting.goimports,
        -- Code actions for struct tags and interface stubs
        b.code_actions.gomodifytags,
        b.code_actions.impl,

        -- ╭─────────────────────────────────────────────────────────╮
        -- │                        Python                           │
        -- ╰─────────────────────────────────────────────────────────╯
        -- Nothing here: the ruff LSP (astrolsp.lua) lints and formats, and
        -- basedpyright (python.lua) type-checks.

        -- ╭─────────────────────────────────────────────────────────╮
        -- │                  TypeScript / JavaScript                │
        -- ╰─────────────────────────────────────────────────────────╯
        -- eslint from the project's node_modules (its own version and config), on
        -- save. The plain source, not eslint_d.
        require("none-ls.diagnostics.eslint").with {
          prefer_local = "node_modules/.bin",
          method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
        },

        -- ╭─────────────────────────────────────────────────────────╮
        -- │                     Infrastructure                      │
        -- ╰─────────────────────────────────────────────────────────╯
        -- Terraform: terraform-ls formats; validate and tfsec lint on save.
        b.diagnostics.terraform_validate,
        b.diagnostics.tfsec,

        -- YAML — let yamllint use each project's .yamllint config (auto-discovered
        -- from the repo root). Projects without a config fall back to
        -- ~/.config/yamllint/config.
        b.diagnostics.yamllint,

        -- Docker
        b.diagnostics.hadolint,

        -- Shell: shfmt formats (bashls formatting is off in astrolsp.lua).
        b.formatting.shfmt.with {
          extra_args = { "-i", "2", "-ci", "-bn" }, -- 2 space indent, case indent, binary newline
        },

        -- ╭─────────────────────────────────────────────────────────╮
        -- │                        General                          │
        -- ╰─────────────────────────────────────────────────────────╯
        -- Markdown: markdownlint-cli2 (reads .markdownlint-cli2.* and the v1 config
        -- files), only where the repo ships a config.
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

        -- Lua: stylua runs as an LSP (the lua pack); selene only where the repo
        -- ships a selene.toml.
        b.diagnostics.selene.with {
          runtime_condition = function(params) return root_has(params.bufnr, { "selene.toml" }) end,
        },

        -- JSON, Markdown, CSS, HTML: prettier (the project's own when present).
        -- The jsonls/cssls/html LSP formatters are off in astrolsp.lua.
        b.formatting.prettier.with {
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
  },
}

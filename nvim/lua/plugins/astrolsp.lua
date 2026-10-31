-- LSP features, formatting and per-server settings (`:h astrolsp`).
---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    features = {
      codelens = true,
      inlay_hints = true, -- parameter and type hints, as in GoLand/PyCharm (<leader>uH toggles)
      semantic_tokens = true,
    },
    formatting = {
      format_on_save = { enabled = true },
      -- One formatter per filetype: none-ls runs prettier (JSON, CSS, HTML) and
      -- shfmt (shell), so these servers' own formatters stay off.
      disabled = { "jsonls", "cssls", "html", "bashls" },
      timeout_ms = 1000,
    },
    ---@diagnostic disable: missing-fields
    config = {
      -- ruff LSP: launch the project-local ruff (<root>/.venv/bin/ruff) when it
      -- exists so live diagnostics use the version the repo pins, not the global
      -- Mason copy. Falls back to whatever `ruff` is on PATH outside a venv.
      ruff = {
        cmd = function(dispatchers, config)
          local exe = "ruff"
          local root = config.root_dir or vim.fs.root(0, { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" })
          if root then
            local local_ruff = root .. "/.venv/bin/ruff"
            if vim.fn.executable(local_ruff) == 1 then exe = local_ruff end
          end
          return vim.lsp.rpc.start({ exe, "server" }, dispatchers)
        end,
      },
      terraformls = {
        filetypes = { "terraform", "tf", "hcl" },
      },
      yamlls = {
        settings = {
          yaml = {
            schemaStore = { enable = true },
          },
        },
      },
      jsonls = {
        settings = {
          json = {
            validate = { enable = true },
          },
        },
      },
      ansiblels = {
        filetypes = { "yaml.ansible", "ansible" },
      },
      texlab = {
        settings = {
          texlab = {
            -- VimTeX compiles continuously, so texlab builds only on :TexlabBuild;
            -- latexmk's flags come from ~/.latexmkrc.
            build = {
              executable = "latexmk",
              args = { "%f" },
              onSave = false,
              forwardSearchAfter = true,
            },
            forwardSearch = {
              executable = "/Applications/Skim.app/Contents/SharedSupport/displayline",
              args = { "-g", "%l", "%p", "%f" },
            },
            chktex = {
              onOpenAndSave = true, -- lint on open and save
            },
            latexindent = {
              modifyLineBreaks = true,
            },
          },
        },
      },
    },
    handlers = {
      -- Python: basedpyright (types) + ruff (lint/format) only; the python pack
      -- also ships these type checkers, which would overlap basedpyright.
      ty = false,
      pyrefly = false,
    },
    mappings = {
      n = {
        -- Optimize Imports (Ctrl+Alt+O): gopls and ruff both offer it.
        ["<Leader>lo"] = {
          function()
            vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" }, diagnostics = {} }, apply = true })
          end,
          desc = "Organize imports",
          cond = "textDocument/codeAction",
        },
        gD = {
          function() vim.lsp.buf.declaration() end,
          desc = "Declaration of current symbol",
          cond = "textDocument/declaration",
        },
        ["<Leader>uY"] = {
          function() require("astrolsp.toggles").buffer_semantic_tokens() end,
          desc = "Toggle LSP semantic highlight (buffer)",
          cond = function(client)
            return client:supports_method "textDocument/semanticTokens/full" and vim.lsp.semantic_tokens ~= nil
          end,
        },
      },
    },
  },
}

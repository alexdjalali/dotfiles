-- Python development enhancements
---@type LazySpec
return {
  -- Keep ruff as the sole Python formatter. mason-null-ls auto-registers a
  -- null-ls source for every mason-installed tool, which silently pulls in
  -- black + isort (from the astrocommunity python pack) alongside ruff_format
  -- — three formatters fighting over the same buffer on save. An empty handler
  -- tells mason-null-ls to skip registering that source. Matches the project
  -- standard: "ruff replaces flake8/black/isort".
  {
    "jay-babu/mason-null-ls.nvim",
    opts = {
      handlers = {
        black = function() end,
        isort = function() end,
        -- Don't auto-register mypy: this repo uses basedpyright only, so a mypy
        -- source would report errors the CLI/CI never produce. (none-ls.lua also
        -- omits it — this stops mason-null-ls from silently adding it back.)
        mypy = function() end,
        -- Don't auto-register eslint_d either: none-ls.lua wires the project's own
        -- `eslint` binary (flat config, version parity with `pnpm lint`). A second
        -- eslint_d source with a different bundled eslint would diverge from CI.
        eslint_d = function() end,
        -- Don't auto-register the plain markdownlint (v1): none-ls.lua runs
        -- markdownlint-cli2 instead (it reads the repos' `.markdownlint-cli2.jsonc`,
        -- which v1 cannot). A v1 source would ignore that config, apply its own
        -- defaults, and re-flood docs with the warnings the repo config disables.
        markdownlint = function() end,
      },
    },
  },

  -- Configure basedpyright with enhanced settings
  {
    "AstroNvim/astrolsp",
    opts = {
      config = {
        basedpyright = {
          -- Launch the repo's PINNED basedpyright (<root>/.venv/bin) so live type
          -- diagnostics come from the exact version `search typecheck --python`
          -- (uv run basedpyright) uses — not an auto-updated Mason copy whose
          -- default rules can drift. The binary is shared at the workspace root
          -- (uv single-venv), located via the nearest .venv/.git ancestor; falls
          -- back to Mason's `basedpyright-langserver` outside the repo.
          cmd = function(dispatchers)
            local exe = "basedpyright-langserver"
            local root = vim.fs.root(0, { ".venv", ".git" })
            if root then
              local local_exe = root .. "/.venv/bin/basedpyright-langserver"
              if vim.fn.executable(local_exe) == 1 then exe = local_exe end
            end
            return vim.lsp.rpc.start({ exe, "--stdio" }, dispatchers)
          end,
          before_init = function(_, c)
            -- Auto-detect uv .venv or standard venv
            local cwd = vim.fn.getcwd()
            local venv_paths = {
              cwd .. "/.venv",
              cwd .. "/venv",
              cwd .. "/.virtualenv",
              cwd .. "/env",
            }
            for _, venv in ipairs(venv_paths) do
              if vim.fn.isdirectory(venv) == 1 then
                if not c.settings.python then
                  c.settings.python = {}
                end
                c.settings.python.pythonPath = venv .. "/bin/python"
                break
              end
            end
          end,
          settings = {
            basedpyright = {
              analysis = {
                -- ⛔ Do NOT set typeCheckingMode / reportMissingTypeStubs here.
                -- The repo's tier is centralized in pyrightconfig-shared.json
                -- (typeCheckingMode = "strict"), pulled in per package via
                -- `[tool.pyright] extends`, with two packages overriding to
                -- "standard". An LSP-level typeCheckingMode overrides ALL of that,
                -- so forcing "standard" here made nvim under-report vs CI (strict),
                -- and reportMissingTypeStubs=false hid errors strict mode surfaces.
                -- Leaving both unset lets basedpyright read each package's own
                -- config — the exact resolution `uv run basedpyright` performs, so
                -- diagnostics match per package. Only editor-nicety settings (which
                -- never add diagnostics) stay below.
                autoImportCompletions = true,
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
                inlayHints = {
                  variableTypes = true,
                  functionReturnTypes = true,
                  callArgumentNames = true,
                  pytestParameters = true,
                },
              },
            },
          },
        },
      },
    },
  },

  -- venv-selector.nvim - Virtual environment selector
  {
    "linux-cultist/venv-selector.nvim",
    branch = "main",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
      "mfussenegger/nvim-dap-python",
    },
    ft = "python",
    opts = {
      options = {
        notify_user_on_venv_activation = true,
        enable_default_searches = true,
      },
    },
    keys = {
      { "<leader>pv", "<cmd>VenvSelect<cr>", desc = "Select virtualenv", ft = "python" },
      { "<leader>pV", "<cmd>VenvSelectCached<cr>", desc = "Select cached venv", ft = "python" },
    },
  },

  -- Python REPL integration
  {
    "Vigemus/iron.nvim",
    ft = "python",
    opts = function()
      return {
        config = {
          scratch_repl = true,
          repl_definition = {
            python = {
              command = function()
                -- Try to find ipython, fall back to python
                local ipython = vim.fn.executable("ipython") == 1 and { "ipython", "--no-autoindent" }
                  or { "python3" }
                return ipython
              end,
              format = require("iron.fts.common").bracketed_paste_python,
            },
          },
          repl_open_cmd = "vertical botright 80 split",
        },
        keymaps = {
          send_motion = "<leader>ps",
          visual_send = "<leader>ps",
          send_file = "<leader>pf",
          send_line = "<leader>pl",
          send_paragraph = "<leader>pp",
          send_until_cursor = "<leader>pu",
          send_mark = "<leader>pm",
          mark_motion = "<leader>pM",
          mark_visual = "<leader>pM",
          remove_mark = "<leader>pd",
          cr = "<leader>p<cr>",
          interrupt = "<leader>p<space>",
          exit = "<leader>pq",
          clear = "<leader>pc",
        },
        highlight = { italic = true },
        ignore_blank_lines = true,
      }
    end,
    config = function(_, opts)
      require("iron.core").setup(opts)
    end,
    keys = {
      { "<leader>pr", "<cmd>IronRepl<cr>", desc = "Open Python REPL", ft = "python" },
      { "<leader>pR", "<cmd>IronRestart<cr>", desc = "Restart REPL", ft = "python" },
      { "<leader>pH", "<cmd>IronHide<cr>", desc = "Hide REPL", ft = "python" },
    },
  },

  -- Jupyter notebook support
  {
    "GCBallesteros/jupytext.nvim",
    ft = { "python", "ipynb" },
    opts = {
      style = "markdown",
      output_extension = "md",
      force_ft = "markdown",
    },
  },
}

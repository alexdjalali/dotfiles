-- Python development enhancements
---@type LazySpec
return {
  -- Configure basedpyright with enhanced settings
  {
    "AstroNvim/astrolsp",
    opts = {
      config = {
        basedpyright = {
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
                typeCheckingMode = "standard",
                autoImportCompletions = true,
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
                -- Additional analysis settings
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

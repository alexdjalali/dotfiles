-- Python development enhancements
---@type LazySpec
return {
  -- Configure basedpyright with enhanced settings
  {
    "AstroNvim/astrolsp",
    opts = {
      config = {
        basedpyright = {
          -- Prefer the repo's pinned basedpyright (<root>/.venv/bin) over Mason's
          -- copy; Mason's is the fallback outside a repo venv.
          cmd = function(dispatchers, config)
            local exe = "basedpyright-langserver"
            local root = config.root_dir or vim.fs.root(0, { ".venv", ".git" })
            if root then
              local local_exe = root .. "/.venv/bin/basedpyright-langserver"
              if vim.fn.executable(local_exe) == 1 then exe = local_exe end
            end
            return vim.lsp.rpc.start({ exe, "--stdio" }, dispatchers)
          end,
          -- Point basedpyright at the venv in the project root (the LSP root_dir,
          -- not the cwd, which differs when nvim starts in a subdirectory).
          before_init = function(_, c)
            local root = c.root_dir or vim.fn.getcwd()
            for _, name in ipairs({ ".venv", "venv", ".virtualenv", "env" }) do
              local python = root .. "/" .. name .. "/bin/python"
              if vim.fn.executable(python) == 1 then
                c.settings.python = vim.tbl_extend("force", c.settings.python or {}, { pythonPath = python })
                break
              end
            end
          end,
          settings = {
            basedpyright = {
              analysis = {
                -- No typeCheckingMode or rule settings: they would override the
                -- repo's own pyright config. Only editor niceties below.
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
        -- iron sets these keymaps globally (every buffer), so they live under
        -- <leader>X ("eXecute"), not AstroNvim's <leader>p (Packages) group.
        keymaps = {
          send_motion = "<leader>Xs",
          visual_send = "<leader>Xs",
          send_file = "<leader>Xf",
          send_line = "<leader>Xl",
          send_paragraph = "<leader>Xp",
          send_until_cursor = "<leader>Xu",
          send_mark = "<leader>Xm",
          mark_motion = "<leader>XM",
          mark_visual = "<leader>XM",
          remove_mark = "<leader>Xd",
          cr = "<leader>X<cr>",
          interrupt = "<leader>X<space>",
          exit = "<leader>Xq",
          clear = "<leader>Xc",
        },
        highlight = { italic = true },
        ignore_blank_lines = true,
      }
    end,
    config = function(_, opts)
      require("iron.core").setup(opts)
    end,
    keys = {
      { "<leader>X", nil, desc = "Python REPL" },
      { "<leader>Xr", "<cmd>IronRepl<cr>", desc = "Open Python REPL", ft = "python" },
      { "<leader>XR", "<cmd>IronRestart<cr>", desc = "Restart REPL", ft = "python" },
      { "<leader>XH", "<cmd>IronHide<cr>", desc = "Hide REPL", ft = "python" },
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

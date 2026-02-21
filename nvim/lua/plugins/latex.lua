---@type LazySpec
return {
  -- VimTeX: compilation, PDF sync, text objects, citation/label completion
  {
    "lervag/vimtex",
    lazy = false, -- VimTeX handles its own lazy loading via filetype
    init = function()
      -- PDF viewer: Skim (macOS) with SyncTeX support
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_view_skim_sync = 1
      vim.g.vimtex_view_skim_activate = 1

      -- Compiler: latexmk with optimized continuous compilation
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        build_dir = "",
        callback = 1,
        continuous = 1,
        executable = "latexmk",
        options = {
          "-pdf",
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
          "-shell-escape", -- required for minted, TikZ externalization
        },
      }

      -- Conceal settings for rendered math symbols in editor
      vim.g.vimtex_syntax_conceal = {
        accents = 1,
        ligatures = 1,
        cites = 1,
        fancy = 1,
        spacing = 1,
        greek = 1,
        math_bounds = 1,
        math_delimiters = 1,
        math_fracs = 1,
        math_super_sub = 1,
        math_symbols = 1,
        sections = 0,
        styles = 1,
      }

      -- Quickfix settings
      vim.g.vimtex_quickfix_mode = 0 -- don't auto-open quickfix on warnings
      vim.g.vimtex_quickfix_open_on_warning = 0

      -- TOC settings
      vim.g.vimtex_toc_config = {
        split_pos = "vert leftabove",
        split_width = 40,
      }
    end,
  },

  -- LuaSnip: custom LaTeX/TikZ/Beamer snippets
  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      -- Run the default config first
      require("astronvim.plugins.configs.luasnip")(plugin, opts)
      -- Load custom LaTeX snippets (VSCode-style JSON)
      require("luasnip.loaders.from_vscode").lazy_load {
        paths = { vim.fn.stdpath "config" .. "/snippets/tex" },
      }
    end,
  },

  -- Tree-sitter: LaTeX syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "latex", "bibtex" })
      end
    end,
  },
}

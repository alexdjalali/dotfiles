-- Parsers to install. AstroNvim v5 installs from astrocore's
-- treesitter.ensure_installed (merged with the language packs' lists);
-- nvim-treesitter's main branch ignores an ensure_installed in its own opts.
---@type LazySpec
return {
  "AstroNvim/astrocore",
  opts = {
    treesitter = {
      ensure_installed = {
        "lua",
        "vim",
        "vimdoc",
        "python",
        "go",
        "gomod",
        "gosum",
        "typescript",
        "tsx",
        "javascript",
        "json",
        "yaml",
        "toml",
        "bash",
        "dockerfile",
        "hcl", -- terraform
        "html",
        "css",
        "markdown",
        "markdown_inline",
        "regex",
        "query",
        "http",
        "sql",
        "diff",
        "gitcommit",
        "git_rebase",
      },
    },
  },
}

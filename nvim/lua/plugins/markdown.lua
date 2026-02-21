-- markdown-preview.nvim - 6k+ stars
---@type LazySpec
return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = "markdown",
    build = function() vim.fn["mkdp#util#install"]() end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown preview (browser)" },
      { "<leader>ms", "<cmd>MarkdownPreviewStop<cr>", desc = "Stop markdown preview" },
    },
    init = function()
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_theme = "dark"
      vim.g.mkdp_combine_preview = 1
      vim.g.mkdp_preview_options = {
        mkit = {},
        katex = {},
        uml = {},
        maid = { theme = 'dark' }, -- Enable mermaid with dark theme
        disable_sync_scroll = 0,
        sync_scroll_type = 'middle',
        hide_yaml_meta = 1,
        sequence_diagrams = {},
        flowchart_diagrams = {},
        content_editable = false,
      }
      -- Recognize .md and .markdown
      vim.g.mkdp_filetypes = { "markdown" }
      -- Auto-open preview when entering markdown buffer
      vim.g.mkdp_auto_start = 0
    end,
  },

  -- render-markdown.nvim - 2k+ stars - in-editor markdown rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "Avante" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      file_types = { "markdown", "Avante" },
      latex = { enabled = false },
    },
  },
}
